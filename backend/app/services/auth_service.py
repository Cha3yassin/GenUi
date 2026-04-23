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
    role: Optional[str] = None,
) -> User:
    """
    Return the existing User row for this Firebase UID, or create one if
    this is the user's first request.

    Args:
        db: An active async SQLAlchemy session.
        token: Decoded Firebase token claims from the security dependency.
        role: Optional role to assign ("individual" or "enterprise").

    Returns:
        The User ORM instance (persisted in DB).
    """
    # Attempt to find the user by their Firebase UID
    result = await db.execute(
        select(User).where(User.firebase_uid == token.uid)
    )
    user: Optional[User] = result.scalar_one_or_none()

    if user is None:
        logger.info("Creating new user", firebase_uid=token.uid, email=token.email, role=role)
        user = User(
            id=uuid.uuid4(),
            firebase_uid=token.uid,
            email=token.email,
            role=role or "individual",
        )
        db.add(user)
        await db.flush()  # Write to DB within the current transaction (no commit yet)
    else:
        # Update email if Firebase has a newer value
        if token.email and user.email != token.email:
            user.email = token.email
        # Update role if provided and different
        if role and user.role != role:
            user.role = role
            logger.info("User role updated", firebase_uid=token.uid, new_role=role)

    return user


async def get_or_create_user_from_claims(
    db: AsyncSession,
    uid: str,
    email: Optional[str],
    role: str = "individual",
) -> User:
    """
    Create or update a user from raw Firebase claims (used by /auth/login).

    Unlike get_or_create_user, this doesn't require a DecodedToken wrapper.
    """
    result = await db.execute(
        select(User).where(User.firebase_uid == uid)
    )
    user: Optional[User] = result.scalar_one_or_none()

    if user is None:
        logger.info("Creating new user via login", firebase_uid=uid, email=email, role=role)
        user = User(
            id=uuid.uuid4(),
            firebase_uid=uid,
            email=email,
            role=role,
        )
        db.add(user)
        await db.flush()
    else:
        if email and user.email != email:
            user.email = email
        if user.role != role:
            user.role = role

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
