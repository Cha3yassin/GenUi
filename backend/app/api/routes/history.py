"""
api/routes/history.py — Chat History Endpoints

GET /history/{user_id} — Returns paginated chat history for a user (legacy).
GET /history/me/summaries — Lightweight summaries for sidebar drawer.
GET /history/me/{history_id} — Full detail for re-rendering a past procedure.
"""

import json
import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.logging import get_logger
from app.core.security import CurrentUser
from app.db.session import get_db
from app.schemas.responses import (
    ChatHistoryItem,
    ChatHistoryResponse,
    HistoryDetailResponse,
    HistorySummaryItem,
    HistorySummaryResponse,
)
from app.services.auth_service import get_user_by_firebase_uid
from app.services.history_service import get_user_history, get_history_by_id, save_chat_message

logger = get_logger(__name__)

router = APIRouter(prefix="/history", tags=["History"])


# ── Lightweight summaries for the Drawer ──────────────────────────────────────

@router.get(
    "/me/summaries",
    response_model=HistorySummaryResponse,
    summary="Get history summaries for sidebar",
    description=(
        "Returns lightweight history items (title + date) for the "
        "authenticated user. Used by the Flutter Drawer sidebar."
    ),
)
async def get_my_history_summaries(
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
    limit: int = Query(default=50, ge=1, le=200),
    language: str = Query(default="fr", pattern="^(fr|en|ar)$"),
) -> HistorySummaryResponse:
    """
    Returns title + date only — no full ai_response payloads.
    Title is extracted from the stored JSON's title field.
    """
    user = await get_user_by_firebase_uid(db, current_user.uid)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found. Please login first.",
        )

    history_rows, total = await get_user_history(
        db=db, user_id=user.id, limit=limit, offset=0,
    )

    items = []
    for row in history_rows:
        # Extract title from the stored JSON
        title = row.user_message  # fallback
        try:
            ai_data = json.loads(row.ai_response)
            title_obj = ai_data.get("title", {})
            if isinstance(title_obj, dict):
                title = (
                    title_obj.get(language)
                    or title_obj.get("fr")
                    or title_obj.get("en")
                    or title_obj.get("ar")
                    or row.user_message
                )
            elif isinstance(title_obj, str):
                title = title_obj
        except (json.JSONDecodeError, TypeError):
            pass

        items.append(
            HistorySummaryItem(
                id=row.id,
                title=title,
                created_at=row.created_at,
            )
        )

    return HistorySummaryResponse(items=items, total=total)


# ── Save a GenUI result to history ────────────────────────────────────────────

class _SaveHistoryRequest(BaseModel):
    """Payload for saving a GenUI result to history."""
    user_message: str
    ai_response: dict

@router.post(
    "/me/save",
    status_code=status.HTTP_201_CREATED,
    summary="Save a GenUI procedure to history",
    description=(
        "Called by the Flutter frontend after a successful GenUI procedure "
        "generation. Saves the user_message and ai_response JSON to the "
        "chat_history table for the authenticated user."
    ),
)
async def save_to_history(
    body: _SaveHistoryRequest,
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> dict:
    """
    Persist a GenUI exchange to the user's history.
    This is separate from /gen-ui/search because GenUI is public
    but history saving requires authentication.
    """
    user = await get_user_by_firebase_uid(db, current_user.uid)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found. Please login first.",
        )

    try:
        entry = await save_chat_message(
            db=db,
            user_id=user.id,
            user_message=body.user_message,
            ai_response=body.ai_response,
        )
        await db.commit()
        logger.info(
            "GenUI result saved to history",
            user_id=str(user.id),
            history_id=str(entry.id),
        )
        return {"status": "saved", "history_id": str(entry.id)}
    except Exception as exc:
        logger.error("Failed to save to history", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to save to history.",
        )


# ── Full detail for re-rendering a past procedure ─────────────────────────────

@router.get(
    "/me/{history_id}",
    response_model=HistoryDetailResponse,
    summary="Get full history detail",
    description=(
        "Returns the full ai_response JSON for a single history item. "
        "Flutter renders this directly via ProcedureGuideAdapter."
    ),
)
async def get_history_detail(
    history_id: uuid.UUID,
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> HistoryDetailResponse:
    """
    Returns full JSON for instant re-rendering without LLM call.
    """
    user = await get_user_by_firebase_uid(db, current_user.uid)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found.",
        )

    row = await get_history_by_id(db, history_id)
    if not row or row.user_id != user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="History item not found.",
        )

    try:
        ai_response_dict = json.loads(row.ai_response)
    except (json.JSONDecodeError, TypeError):
        ai_response_dict = {"type": "error", "message": "Malformed response data."}

    return HistoryDetailResponse(
        id=row.id,
        user_message=row.user_message,
        ai_response=ai_response_dict,
        created_at=row.created_at,
    )


# ── Legacy paginated history (existing endpoint) ─────────────────────────────

@router.get(
    "/{user_id}",
    response_model=ChatHistoryResponse,
    summary="Get user chat history (legacy)",
    description=(
        "Returns paginated chat history for the specified user. "
        "Users can only access their own history."
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
    """
    requesting_user = await get_user_by_firebase_uid(db, current_user.uid)
    if not requesting_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Authenticated user not found in database.",
        )

    if requesting_user.id != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to access this user's history.",
        )

    history_rows, total = await get_user_history(
        db=db, user_id=user_id, limit=limit, offset=offset,
    )

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

    return ChatHistoryResponse(user_id=user_id, total=total, items=items)
