"""
api/routes/auth.py — Authentication & Profile Endpoints

Provides:
- GET /auth/me — returns the current user's profile from the database
- POST /auth/register — explicit registration (optional; /chat auto-registers)
"""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Annotated

from app.core.logging import get_logger
from app.core.security import CurrentUser
from app.db.session import get_db
from app.services.auth_service import get_or_create_user

logger = get_logger(__name__)

router = APIRouter(prefix="/auth", tags=["Authentication"])


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
        "created_at": user.created_at.isoformat(),
        "message": "User registered successfully.",
    }
