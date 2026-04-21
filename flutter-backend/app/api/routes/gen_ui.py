"""
api/routes/gen_ui.py — Public Gen UI endpoint

Creates structured Gemini JSON from a specific search query so the frontend
can render dynamic widgets directly from the response.
"""

from typing import Union

from fastapi import APIRouter

from app.core.logging import get_logger
from app.schemas.requests import ChatRequest
from app.schemas.responses import ErrorResponse, ProcedureGuideResponse
from app.services import gemini_service, rag_service
from app.utils.validators import validate_gemini_response

logger = get_logger(__name__)

router = APIRouter(prefix="/gen-ui", tags=["Gen UI"])


@router.post(
    "/search",
    response_model=Union[ProcedureGuideResponse, ErrorResponse],
    summary="Generate structured UI JSON from search query",
    description=(
        "Public endpoint for Gen UI prototypes. "
        "Takes a specific search query, runs RAG + Gemini, and returns "
        "validated JSON ready for widget rendering."
    ),
)
async def generate_ui_from_search(
    request: ChatRequest,
) -> Union[ProcedureGuideResponse, ErrorResponse]:
    try:
        context_chunks = await rag_service.search_similar_chunks(
            query=request.message,
            category_filter=request.category,
        )
    except Exception as exc:
        logger.error("Gen UI RAG search failed", error=str(exc))
        context_chunks = []

    if len(context_chunks) == 0:
        logger.warning("Gen UI request rejected due to empty context", query=request.message)
        return ErrorResponse(
            type="error",
            message=(
                "No trusted procedure context was found for this query. "
                "Please rephrase your search or ingest more official documents."
            ),
            code="NO_CONTEXT",
        )

    try:
        raw_response = await gemini_service.generate_procedure_response(
            user_message=request.message,
            context_chunks=context_chunks,
            language=request.language,
        )
    except RuntimeError as exc:
        logger.error("Gen UI Gemini call failed", error=str(exc))
        return ErrorResponse(
            type="error",
            message="AI generation is temporarily unavailable.",
            code="GEMINI_UNAVAILABLE",
        )

    return validate_gemini_response(raw_response)
