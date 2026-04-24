"""
api/routes/gen_ui.py — Public Gen UI endpoint (with Redis cache + Celery queue)

Creates structured JSON UI plans from a search query.
Implements the full cache-first, async-task-queue flow:

1. Check Redis for an exact-match cached response → instant 200
2. Cache miss → dispatch Celery background task → return 202 with task_id
3. Frontend polls GET /tasks/{task_id}/status every 2 seconds
4. Worker completes → result cached in Redis for future hits
"""

from typing import Union

from celery.result import AsyncResult
from fastapi import APIRouter, status
from fastapi.responses import JSONResponse

from app.cache import get_cached_response
from app.celery_app import celery
from app.core.logging import get_logger
from app.schemas.requests import ChatRequest
from app.schemas.responses import (
    ErrorResponse,
    ProcedureGuideResponse,
    TaskAcceptedResponse,
    TaskStatusResponse,
)

logger = get_logger(__name__)

router = APIRouter(prefix="/gen-ui", tags=["Gen UI"])


@router.post(
    "/search",
    response_model=Union[ProcedureGuideResponse, TaskAcceptedResponse, ErrorResponse],
    summary="Generate structured UI JSON from search query",
    description=(
        "Public endpoint for Gen UI. "
        "Checks Redis cache first — on hit returns instantly. "
        "On miss, dispatches a Celery background task and returns a task_id "
        "for the frontend to poll via GET /gen-ui/tasks/{task_id}/status."
    ),
    responses={
        200: {"description": "Cache hit — full procedure guide returned immediately"},
        202: {"description": "Cache miss — task dispatched, poll for result"},
    },
)
async def generate_ui_from_search(
    request: ChatRequest,
) -> Union[ProcedureGuideResponse, JSONResponse]:
    """
    Main GenUI handler with caching and async task queue.

    Flow:
    1. Check Redis cache for exact match
    2. Cache hit → return validated ProcedureGuideResponse (HTTP 200)
    3. Cache miss → dispatch Celery task → return task_id (HTTP 202)
    """
    # ── Step 1: Check Redis cache ─────────────────────────────────────────────
    cached = get_cached_response(request.message, request.language)

    if cached is not None:
        logger.info(
            "Cache HIT — returning cached response",
            query_preview=request.message[:60],
            language=request.language,
        )
        # Validate the cached data (should always pass, but be safe)
        try:
            return ProcedureGuideResponse.model_validate(cached)
        except Exception:
            logger.warning("Cached data failed validation — treating as miss")
            # Fall through to cache miss flow

    # ── Step 2: Cache MISS → dispatch Celery task ─────────────────────────────
    logger.info(
        "Cache MISS — dispatching Celery task",
        query_preview=request.message[:60],
        language=request.language,
        category=request.category,
        role=request.role,
    )

    task = celery.send_task(
        "fbureaucracy.generate_procedure",
        kwargs={
            "user_message": request.message,
            "language": request.language,
            "category": request.category,
            "role": request.role,
        },
    )

    logger.info("Celery task dispatched", task_id=task.id)

    return JSONResponse(
        status_code=status.HTTP_202_ACCEPTED,
        content=TaskAcceptedResponse(
            status="processing",
            task_id=task.id,
        ).model_dump(),
    )


@router.get(
    "/tasks/{task_id}/status",
    response_model=TaskStatusResponse,
    summary="Poll for background task status",
    description=(
        "Polling endpoint for the frontend. Returns the current status of a "
        "Celery task: 'processing', 'complete', or 'failed'. "
        "When complete, the full procedure JSON is included in the 'result' field."
    ),
)
async def get_task_status(task_id: str) -> TaskStatusResponse:
    """
    Check the status of a previously dispatched generate_procedure task.

    - PENDING/STARTED → {"status": "processing"}
    - SUCCESS         → {"status": "complete", "result": {...}}
    - FAILURE         → {"status": "failed", "error": "..."}
    """
    result = AsyncResult(task_id, app=celery)

    if result.state in ("PENDING", "STARTED", "RETRY"):
        return TaskStatusResponse(
            status="processing",
            task_id=task_id,
        )

    if result.state == "SUCCESS":
        return TaskStatusResponse(
            status="complete",
            task_id=task_id,
            result=result.result,
        )

    # FAILURE or REVOKED
    error_msg = str(result.result) if result.result else "Task failed unexpectedly."
    return TaskStatusResponse(
        status="failed",
        task_id=task_id,
        error=error_msg,
    )
