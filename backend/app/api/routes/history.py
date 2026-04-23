"""
api/routes/history.py — Chat History Endpoint

GET /history/{user_id} — Returns paginated chat history for a user.
Only the authenticated user can access their own history.
"""

import json
import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.logging import get_logger
from app.core.security import CurrentUser
from app.db.session import get_db
from app.schemas.responses import ChatHistoryItem, ChatHistoryResponse
from app.services.auth_service import get_user_by_firebase_uid
from app.services.history_service import get_user_history

logger = get_logger(__name__)

router = APIRouter(prefix="/history", tags=["History"])


@router.get(
    "/{user_id}",
    response_model=ChatHistoryResponse,
    summary="Get user chat history",
    description=(
        "Returns paginated chat history for the specified user. "
        "Users can only access their own history. "
        "Responses are returned as parsed JSON objects, not raw strings."
    ),
)
async def get_history(
    user_id: uuid.UUID,
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
    limit: int = Query(default=20, ge=1, le=100, description="Results per page"),
    offset: int = Query(default=0, ge=0, description="Pagination offset"),
) -> ChatHistoryResponse:
    """
    Returns a user's conversation history.

    Authorization: A user may only retrieve their own history.
    Admins are not currently supported (can be added via custom claims).
    """
    # Look up the requesting user to get their internal UUID
    requesting_user = await get_user_by_firebase_uid(db, current_user.uid)
    if not requesting_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Authenticated user not found in database. Please register first.",
        )

    # Authorization check — users can only see their own history
    if requesting_user.id != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to access this user's history.",
        )

    history_rows, total = await get_user_history(
        db=db,
        user_id=user_id,
        limit=limit,
        offset=offset,
    )

    # Deserialise ai_response from JSON string to dict for Flutter
    items = []
    for row in history_rows:
        try:
            ai_response_dict = json.loads(row.ai_response)
        except (json.JSONDecodeError, TypeError):
            ai_response_dict = {"type": "error", "message": "Malformed response data."}

        items.append(
            ChatHistoryItem(
                id=row.id,
                user_message=row.user_message,
                ai_response=ai_response_dict,
                created_at=row.created_at,
            )
        )

    logger.debug(
        "History retrieved",
        user_id=str(user_id),
        total=total,
        returned=len(items),
    )

    return ChatHistoryResponse(
        user_id=user_id,
        total=total,
        items=items,
    )
