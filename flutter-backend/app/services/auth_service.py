"""
services/auth_service.py — User Management Service

Handles user creation and lookup in PostgreSQL.
Decouples database logic from route handlers and Firebase token details.
"""

import uuid
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.logging import get_logger
from app.core.security import DecodedToken
from app.db.models import User

logger = get_logger(__name__)


async def get_or_create_user(
    db: AsyncSession,
    token: DecodedToken,
) -> User:
    """
    Return the existing User row for this Firebase UID, or create one if
    this is the user's first request.

    Args:
        db: An active async SQLAlchemy session.
        token: Decoded Firebase token claims from the security dependency.

    Returns:
        The User ORM instance (persisted in DB).
    """
    # Attempt to find the user by their Firebase UID
    result = await db.execute(
        select(User).where(User.firebase_uid == token.uid)
    )
    user: Optional[User] = result.scalar_one_or_none()

    if user is None:
        logger.info("Creating new user", firebase_uid=token.uid, email=token.email)
        user = User(
            id=uuid.uuid4(),
            firebase_uid=token.uid,
            email=token.email,
        )
        db.add(user)
        await db.flush()  # Write to DB within the current transaction (no commit yet)
    else:
        # Update email if Firebase has a newer value
        if token.email and user.email != token.email:
            user.email = token.email

    return user


async def get_user_by_firebase_uid(
    db: AsyncSession,
    firebase_uid: str,
) -> Optional[User]:
    """
    Look up a user by their Firebase UID.

    Returns None if the user does not exist in the database.
    """
    result = await db.execute(
        select(User).where(User.firebase_uid == firebase_uid)
    )
    return result.scalar_one_or_none()
