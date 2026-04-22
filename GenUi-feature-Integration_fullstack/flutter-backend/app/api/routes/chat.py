"""
api/routes/chat.py — Main Chat Endpoint

POST /chat — Orchestrates the full RAG → Gemini → Validate → Persist pipeline.

Flow:
1. Verify Firebase token (dependency)
2. Get or create user in PostgreSQL
3. Search ChromaDB for relevant procedure chunks
4. Call Gemini with context + user question
5. Validate Gemini's JSON output with Pydantic
6. Persist conversation to history
7. Return structured JSON to Flutter
"""

import json
from typing import Annotated, Union

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.logging import get_logger
from app.core.security import CurrentUser, DecodedToken
from app.db.session import get_db
from app.schemas.requests import ChatRequest
from app.schemas.responses import ErrorResponse, ProcedureGuideResponse
from app.services import auth_service, gemini_service, history_service, rag_service
from app.utils.validators import validate_gemini_response

logger = get_logger(__name__)

router = APIRouter(prefix="/chat", tags=["Chat"])


@router.post(
    "",
    response_model=Union[ProcedureGuideResponse, ErrorResponse],
    summary="Ask a bureaucracy question",
    description=(
        "Main conversational endpoint. Accepts a natural-language question, "
        "retrieves relevant procedure context via RAG, generates a structured "
        "JSON response with Gemini 1.5 Flash, and persists the exchange."
    ),
    responses={
        200: {"description": "Structured procedure guide or error fallback"},
        401: {"description": "Invalid or missing Firebase token"},
        422: {"description": "Request validation error"},
    },
)
async def chat(
    request: ChatRequest,
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> Union[ProcedureGuideResponse, ErrorResponse]:
    """
    Main chat handler. All heavy lifting is delegated to service modules.
    """
    logger.info(
        "Chat request received",
        uid=current_user.uid,
        message_length=len(request.message),
        language=request.language,
        category=request.category,
    )

    # ── Step 1: Resolve internal user (create on first visit) ─────────────────
    user = await auth_service.get_or_create_user(db, current_user)

    # ── Step 2: RAG — retrieve relevant procedure chunks ──────────────────────
    try:
        context_chunks = await rag_service.search_similar_chunks(
            query=request.message,
            category_filter=request.category,
        )
    except Exception as exc:
        logger.error("RAG search failed", error=str(exc), uid=current_user.uid)
        context_chunks = []  # Graceful degradation — continue without context

    logger.info(
        "RAG context retrieved",
        num_chunks=len(context_chunks),
        uid=current_user.uid,
    )

    # ── Step 3: Gemini — generate structured JSON ─────────────────────────────
    try:
        raw_gemini_response = await gemini_service.generate_procedure_response(
            user_message=request.message,
            context_chunks=context_chunks,
            language=request.language,
        )
    except RuntimeError as exc:
        logger.error("Gemini call failed", error=str(exc), uid=current_user.uid)
        error_response = ErrorResponse(
            type="error",
            message="AI service is temporarily unavailable. Please try again.",
            code="GEMINI_UNAVAILABLE",
        )
        # Still persist the failed exchange for debugging/analytics
        await _persist_history(db, user.id, request.message, error_response.model_dump())
        return error_response

    # ── Step 4: Validate Gemini output ────────────────────────────────────────
    validated_response = validate_gemini_response(raw_gemini_response)

    # ── Step 5: Persist to chat history ───────────────────────────────────────
    await _persist_history(
        db, user.id, request.message, validated_response.model_dump()
    )

    logger.info(
        "Chat response sent",
        response_type=validated_response.type,
        uid=current_user.uid,
    )
    return validated_response


async def _persist_history(
    db: AsyncSession,
    user_id,
    user_message: str,
    ai_response: dict,
) -> None:
    """Internal helper — saves history, logs on failure but never raises."""
    try:
        await history_service.save_chat_message(
            db=db,
            user_id=user_id,
            user_message=user_message,
            ai_response=ai_response,
        )
    except Exception as exc:
        # History persistence failure must never break the main response
        logger.error("Failed to persist chat history", error=str(exc))
