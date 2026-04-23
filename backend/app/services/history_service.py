"""
services/history_service.py — Chat History Persistence

Handles saving and retrieving conversation history from PostgreSQL.
Serialises AI response JSON to text for storage and deserialises on read.
"""

import json
import uuid
from typing import List, Optional, Tuple

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.logging import get_logger
from app.db.models import ChatHistory

logger = get_logger(__name__)


async def save_chat_message(
    db: AsyncSession,
    user_id: uuid.UUID,
    user_message: str,
    ai_response: dict,
) -> ChatHistory:
    """
    Persist a user–AI exchange to the chat_history table.

    Args:
        db: Active async database session.
        user_id: Internal UUID of the authenticated user.
        user_message: The original user question string.
        ai_response: The validated AI response dict (will be JSON-serialised).

    Returns:
        The newly created ChatHistory ORM instance.
    """
    history_entry = ChatHistory(
        id=uuid.uuid4(),
        user_id=user_id,
        user_message=user_message,
        ai_response=json.dumps(ai_response, ensure_ascii=False),
    )
    db.add(history_entry)
    await db.flush()

    logger.debug(
        "Chat message saved",
        user_id=str(user_id),
        history_id=str(history_entry.id),
    )
    return history_entry


async def get_user_history(
    db: AsyncSession,
    user_id: uuid.UUID,
    limit: int = 50,
    offset: int = 0,
) -> Tuple[List[ChatHistory], int]:
    """
    Retrieve paginated chat history for a user, ordered by most recent first.

    Args:
        db: Active async database session.
        user_id: Internal UUID of the user.
        limit: Maximum number of records to return.
        offset: Number of records to skip (for pagination).

    Returns:
        Tuple of (list of ChatHistory rows, total count).
    """
    # Get total count
    count_result = await db.execute(
        select(func.count(ChatHistory.id)).where(ChatHistory.user_id == user_id)
    )
    total: int = count_result.scalar_one()

    # Get paginated records
    result = await db.execute(
        select(ChatHistory)
        .where(ChatHistory.user_id == user_id)
        .order_by(ChatHistory.created_at.desc())
        .limit(limit)
        .offset(offset)
    )
    items: List[ChatHistory] = list(result.scalars().all())

    return items, total


async def get_history_by_id(
    db: AsyncSession,
    history_id: uuid.UUID,
) -> Optional[ChatHistory]:
    """
    Retrieve a single chat history entry by its ID.

    Returns None if the entry does not exist.
    """
    result = await db.execute(
        select(ChatHistory).where(ChatHistory.id == history_id)
    )
    return result.scalar_one_or_none()

