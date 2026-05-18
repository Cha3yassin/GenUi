"""
core/security.py — Firebase Token Verification & Auth Dependencies

Provides FastAPI dependency injection for verifying Firebase Bearer tokens.
The verified token's decoded claims are injected directly into route handlers.
"""

import json
from typing import Annotated, Optional

import firebase_admin
from firebase_admin import auth as firebase_auth
from firebase_admin import credentials
from fastapi import Depends, HTTPException, Security, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)

# HTTP Bearer scheme — extracts token from "Authorization: Bearer <token>"
bearer_scheme = HTTPBearer(auto_error=True)

# ── Firebase App Initialization ────────────────────────────────────────────────

_firebase_initialized = False


def initialize_firebase() -> None:
    """
    Initialize the Firebase Admin SDK. Called once at application startup.
    Supports both a file path and an inline JSON string for the service account,
    allowing flexible deployment (local files vs. Docker secrets / env vars).
    """
    global _firebase_initialized
    if _firebase_initialized:
        return

    try:
        if settings.FIREBASE_SERVICE_ACCOUNT_JSON:
            # Inline JSON takes priority (useful in containerised environments)
            service_account_info = json.loads(settings.FIREBASE_SERVICE_ACCOUNT_JSON)
            if "private_key" in service_account_info:
                service_account_info["private_key"] = service_account_info["private_key"].replace("\\n", "\n")
            cred = credentials.Certificate(service_account_info)
        elif settings.FIREBASE_SERVICE_ACCOUNT_PATH:
            with open(settings.FIREBASE_SERVICE_ACCOUNT_PATH, "r", encoding="utf-8") as f:
                service_account_info = json.load(f)
            if "private_key" in service_account_info:
                service_account_info["private_key"] = service_account_info["private_key"].replace("\\n", "\n")
            cred = credentials.Certificate(service_account_info)
        else:
            raise RuntimeError(
                "Neither FIREBASE_SERVICE_ACCOUNT_PATH nor "
                "FIREBASE_SERVICE_ACCOUNT_JSON is set. "
                "Firebase authentication cannot be initialised."
            )

        firebase_admin.initialize_app(cred)
        _firebase_initialized = True
        logger.info("Firebase Admin SDK initialised successfully.")
    except Exception as exc:
        logger.error("Failed to initialise Firebase Admin SDK", error=str(exc))
        raise


# ── Token Verification Dependency ─────────────────────────────────────────────

class DecodedToken:
    """Thin wrapper around the Firebase decoded token claims dict."""

    def __init__(self, claims: dict) -> None:
        self.uid: str = claims["uid"]
        self.email: Optional[str] = claims.get("email")
        self.email_verified: bool = claims.get("email_verified", False)
        self.claims: dict = claims


async def verify_firebase_token(
    credentials: Annotated[HTTPAuthorizationCredentials, Security(bearer_scheme)],
) -> DecodedToken:
    """
    FastAPI dependency that:
    1. Extracts the Bearer token from the Authorization header.
    2. Verifies the token with Firebase Admin SDK (checks signature + expiry).
    3. Returns decoded token claims for use in the route handler.

    Raises HTTP 401 if the token is missing, expired, or invalid.
    """
    token = credentials.credentials
    try:
        # Use check_revoked=False to perform fast local signature verification
        # and avoid credential metadata lookup exceptions.
        decoded = firebase_auth.verify_id_token(token, check_revoked=False)
        logger.debug("Firebase token verified", uid=decoded.get("uid"))
        return DecodedToken(decoded)
    except firebase_auth.RevokedIdTokenError:
        logger.warning("Revoked Firebase token presented")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has been revoked. Please sign in again.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except firebase_auth.ExpiredIdTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired. Please sign in again.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except firebase_auth.InvalidIdTokenError as exc:
        logger.warning("Invalid Firebase token", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except Exception as exc:
        logger.error("Unexpected error during token verification", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication failed.",
            headers={"WWW-Authenticate": "Bearer"},
        )


# Annotated shorthand for use in route signatures
CurrentUser = Annotated[DecodedToken, Depends(verify_firebase_token)]
