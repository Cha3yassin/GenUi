"""
tasks.py — Celery Background Tasks

Defines the heavy-lifting task that calls OpenRouter via the existing
gemini_service, validates the response, and caches the result in Redis.

Because Celery workers run synchronously but our services are async,
we bridge with asyncio.run() — safe because each worker process owns
its own event loop.
"""

import asyncio
from typing import List, Optional

from app.cache import set_cached_response
from app.celery_app import celery
from app.core.logging import get_logger
from app.utils.validators import validate_gemini_response

logger = get_logger(__name__)


def _run_async(coro):
    """Run an async coroutine in a fresh event loop (safe inside Celery)."""
    return asyncio.run(coro)


@celery.task(
    name="fbureaucracy.generate_procedure",
    bind=True,
    max_retries=2,
    default_retry_delay=10,
    acks_late=True,
)
def generate_procedure_task(
    self,
    user_message: str,
    language: str = "fr",
    category: Optional[str] = None,
):
    """
    Background task: RAG search → OpenRouter → Validate → Cache.

    Args:
        user_message: The user's natural-language query.
        language: ISO 639-1 code (ar/fr/en).
        category: Optional category slug for narrowing RAG search.

    Returns:
        dict — Validated ProcedureGuideResponse or ErrorResponse as a dict.
    """
    logger.info(
        "Task started",
        task_id=self.request.id,
        query_preview=user_message[:80],
        language=language,
        category=category,
    )

    # ── Step 1: RAG search ────────────────────────────────────────────────────
    context_chunks: List[dict] = []
    try:
        from app.services import rag_service

        context_chunks = _run_async(
            rag_service.search_similar_chunks(
                query=user_message,
                category_filter=category,
            )
        )
        logger.info(
            "RAG search complete (task)",
            task_id=self.request.id,
            chunks_found=len(context_chunks),
        )
    except Exception as exc:
        logger.warning(
            "RAG search failed in task — proceeding without context",
            task_id=self.request.id,
            error=str(exc),
        )

    # ── Step 2: OpenRouter call ───────────────────────────────────────────────
    try:
        from app.services import gemini_service

        raw_response = _run_async(
            gemini_service.generate_procedure_response(
                user_message=user_message,
                context_chunks=context_chunks,
                language=language,
            )
        )
    except RuntimeError as exc:
        logger.error(
            "OpenRouter call failed in task",
            task_id=self.request.id,
            error=str(exc),
        )
        return {
            "type": "error",
            "message": "Le service IA est temporairement indisponible. Veuillez réessayer.",
            "code": "OPENROUTER_UNAVAILABLE",
        }

    # ── Step 3: Validate & repair ─────────────────────────────────────────────
    validated = validate_gemini_response(raw_response)
    result_dict = validated.model_dump()

    # ── Step 4: Cache the result (only if successful) ─────────────────────────
    if result_dict.get("type") == "procedure_guide":
        set_cached_response(user_message, language, result_dict)

    logger.info(
        "Task completed",
        task_id=self.request.id,
        result_type=result_dict.get("type"),
    )
    return result_dict
