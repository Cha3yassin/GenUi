"""
api/routes/auth.py — Authentication & Profile Endpoints

Provides:
- POST /auth/login — verifies Firebase token + role, creates/updates user
- GET /auth/me — returns the current user's profile from the database
- POST /auth/register — explicit registration (optional; /chat auto-registers)
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Annotated

from firebase_admin import auth as firebase_auth

from app.core.logging import get_logger
from app.core.security import CurrentUser
from app.db.session import get_db
from app.schemas.requests import LoginRequest
from app.schemas.responses import LoginResponse
from app.services.auth_service import get_or_create_user, get_or_create_user_from_claims

logger = get_logger(__name__)

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post(
    "/login",
    response_model=LoginResponse,
    summary="Login with Firebase token and role",
    description=(
        "Verifies a Firebase ID token sent from Flutter, extracts the user's "
        "identity, creates or updates the user in the database with the "
        "selected role, and returns the user profile."
    ),
)
async def login(
    request: LoginRequest,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> LoginResponse:
    """
    1. Verify the Firebase ID token via firebase_admin
    2. Extract uid + email from decoded claims
    3. Create or update user with chosen role
    4. Return {user_id, email, role}
    """
    try:
        decoded = firebase_auth.verify_id_token(request.id_token, check_revoked=False)
    except firebase_auth.RevokedIdTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has been revoked. Please sign in again.",
        )
    except firebase_auth.ExpiredIdTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired. Please sign in again.",
        )
    except firebase_auth.InvalidIdTokenError as exc:
        logger.warning("Invalid Firebase token during login", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token.",
        )
    except Exception as exc:
        import traceback
        logger.error(
            "Unexpected error during login token verification", 
            error=str(exc), 
            traceback=traceback.format_exc()
        )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Authentication failed: {str(exc)}",
        )

    uid = decoded.get("uid")
    email = decoded.get("email")

    user = await get_or_create_user_from_claims(
        db=db,
        uid=uid,
        email=email,
        role=request.role,
    )

    logger.info("User logged in", uid=uid, role=request.role)

    return LoginResponse(
        user_id=str(user.id),
        email=user.email,
        role=user.role,
    )


@router.get(
    "/me",
    summary="Get current user profile",
    description="Returns the authenticated user's profile from the database.",
)
async def get_current_user_profile(
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> dict:
    """
    Returns the user's internal profile data.
    Creates the user row if this is their first authenticated request.
    """
    user = await get_or_create_user(db, current_user)
    return {
        "id": str(user.id),
        "firebase_uid": user.firebase_uid,
        "email": user.email,
        "role": user.role,
        "created_at": user.created_at.isoformat(),
    }


@router.post(
    "/register",
    summary="Explicit user registration",
    description=(
        "Explicitly registers a user in the database. "
        "The /chat endpoint also auto-registers on first use, "
        "so calling this endpoint is optional."
    ),
    status_code=201,
)
async def register_user(
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> dict:
    """
    Idempotent registration — safe to call multiple times.
    Returns the user profile whether newly created or already existing.
    """
    user = await get_or_create_user(db, current_user)
    logger.info("User registered/verified", uid=current_user.uid)
    return {
        "id": str(user.id),
        "firebase_uid": user.firebase_uid,
        "email": user.email,
        "role": user.role,
        "created_at": user.created_at.isoformat(),
        "message": "User registered successfully.",
    }
