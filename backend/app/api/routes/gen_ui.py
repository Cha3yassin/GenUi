"""
api/routes/gen_ui.py — Public Gen UI endpoint (with Redis cache + Celery queue)

Creates structured JSON UI plans from a search query.
Implements the full cache-first, async-task-queue flow:

1. Check Redis for an exact-match cached response → instant 200
2. Cache miss → dispatch Celery background task → return 202 with task_id
3. Frontend polls GET /tasks/{task_id}/status every 2 seconds
4. Worker completes → result cached in Redis for future hits
"""

import json
from typing import Any, Union

from celery.result import AsyncResult
from fastapi import APIRouter, status
from fastapi.responses import JSONResponse

from app.cache import get_cached_response
from app.celery_app import celery
from app.core.logging import get_logger
from app.schemas.requests import ChatRequest, QuizRequest
from app.schemas.responses import (
    ErrorResponse,
    ProcedureGuideResponse,
    QuizWidgetResponse,
    TaskAcceptedResponse,
    TaskStatusResponse,
)
from app.services import gemini_service

logger = get_logger(__name__)

router = APIRouter(prefix="/gen-ui", tags=["Gen UI"])


@router.post(
    "/quiz",
    response_model=Union[QuizWidgetResponse, ErrorResponse],
    summary="Generate an AI quiz widget",
    description=(
        "Generates a complete quiz widget plan with questions, answer options, "
        "explanations, and GenUI result blocks. Flutter renders the returned JSON."
    ),
)
async def generate_quiz_widget(
    request: QuizRequest,
) -> Union[QuizWidgetResponse, ErrorResponse]:
    logger.info(
        "AI quiz widget request received",
        topic=request.topic[:80],
        language=request.language,
        role=request.role,
        question_count=request.question_count,
    )

    try:
        raw_response = await gemini_service.generate_quiz_widget_response(
            topic=request.topic,
            language=request.language,
            role=request.role,
            difficulty=request.difficulty,
            question_count=request.question_count,
        )
        parsed = _validate_quiz_widget(raw_response, request)
        for question in parsed.questions:
            if question.correct_index >= len(question.options):
                raise ValueError("correct_index points outside options")
        return parsed
    except Exception as exc:
        logger.error("AI quiz widget generation failed", error=str(exc))
        return ErrorResponse(
            message="AI could not generate the quiz widget safely. Please try again.",
            code="QUIZ_GENERATION_FAILED",
        )


def _validate_quiz_widget(raw_response: str, request: QuizRequest) -> QuizWidgetResponse:
    payload = json.loads(raw_response)
    if not isinstance(payload, dict):
        raise ValueError("quiz payload is not a JSON object")

    payload["type"] = "quiz_widget"
    payload["language"] = request.language
    payload["topic"] = str(payload.get("topic") or request.topic)
    payload["title"] = str(payload.get("title") or "Quiz IA")
    payload["subtitle"] = str(
        payload.get("subtitle") or "Questions generees par IA."
    )
    payload["source"] = str(payload.get("source") or "OpenRouter AI")

    payload["questions"] = _normalise_questions(payload.get("questions"))
    payload["result_bands"] = _normalise_result_bands(payload.get("result_bands"))
    return QuizWidgetResponse.model_validate(payload)


def _normalise_questions(value: Any) -> list[dict[str, Any]]:
    questions = value if isinstance(value, list) else []
    normalised: list[dict[str, Any]] = []

    for item in questions:
        if not isinstance(item, dict):
            continue

        raw_options = item.get("options") if isinstance(item.get("options"), list) else []
        options = []
        for option in raw_options:
            if isinstance(option, dict):
                text = str(option.get("text") or "").strip()
            else:
                text = str(option).strip()
            if text:
                options.append({"text": text})

        if len(options) < 2:
            continue

        try:
            correct_index = int(item.get("correct_index", 0))
        except (TypeError, ValueError):
            correct_index = 0
        correct_index = max(0, min(correct_index, len(options) - 1))

        normalised.append(
            {
                "prompt": str(item.get("prompt") or "").strip(),
                "options": options[:4],
                "correct_index": correct_index,
                "explanation": str(item.get("explanation") or "").strip(),
            }
        )

    if len(normalised) < 3:
        raise ValueError("AI returned fewer than 3 valid quiz questions")
    return normalised


def _normalise_result_bands(value: Any) -> list[dict[str, Any]]:
    bands = value if isinstance(value, list) else []
    normalised: list[dict[str, Any]] = []

    for item in bands:
        if not isinstance(item, dict):
            continue
        try:
            min_score = int(item.get("min_score", 0))
        except (TypeError, ValueError):
            min_score = 0
        blocks = item.get("blocks") if isinstance(item.get("blocks"), list) else []
        normalised.append(
            {
                "min_score": max(0, min_score),
                "title": str(item.get("title") or "Resultat").strip(),
                "message": str(item.get("message") or "").strip(),
                "blocks": [block for block in blocks if isinstance(block, dict)],
            }
        )

    if normalised:
        return normalised

    return [
        {
            "min_score": 0,
            "title": "Resultat",
            "message": "Le quiz IA est termine.",
            "blocks": [
                {
                    "type": "info_card",
                    "data": {
                        "title": "Conseil",
                        "body": "- Verifiez les documents avant le depart.",
                        "icon": "shield",
                    },
                }
            ],
        }
    ]


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
