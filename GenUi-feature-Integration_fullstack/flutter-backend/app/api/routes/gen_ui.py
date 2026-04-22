"""
api/routes/gen_ui.py — Public Gen UI endpoint

Creates structured Gemini JSON from a search query so the Flutter frontend
can render dynamic widgets directly from the response.

Works in two modes:
- Grounded: ChromaDB has matching documents → uses RAG context
- General-knowledge: ChromaDB is empty → Gemini answers from training data
"""

from typing import Union

from fastapi import APIRouter
from fastapi.responses import JSONResponse

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
        "Public endpoint for Gen UI. "
        "Takes a search query, runs RAG (if documents are available) + Gemini, "
        "and returns validated JSON ready for widget rendering. "
        "Falls back to Gemini general knowledge when ChromaDB has no matching context."
    ),
)
async def generate_ui_from_search(
    request: ChatRequest,
) -> Union[ProcedureGuideResponse, ErrorResponse]:
    """
    Main GenUI handler — always attempts to respond.

    Flow:
    1. Try RAG search in ChromaDB
    2. Whether chunks found or not, call Gemini
       - With context → grounded mode (high accuracy)
       - Without context → general-knowledge mode (fallback)
    3. Validate and repair Gemini output
    4. Return structured JSON
    """
    # ── Step 1: RAG search ────────────────────────────────────────────────────
    context_chunks = []
    try:
        context_chunks = await rag_service.search_similar_chunks(
            query=request.message,
            category_filter=request.category,
        )
        logger.info(
            "RAG search complete",
            query=request.message[:60],
            chunks_found=len(context_chunks),
            mode="grounded" if context_chunks else "general-knowledge",
        )
    except Exception as exc:
        logger.warning(
            "RAG search failed — proceeding with general-knowledge mode",
            error=str(exc),
        )
        # Do NOT return error — proceed with empty context

    # ── Step 2: Gemini generation ─────────────────────────────────────────────
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
            message="Le service IA est temporairement indisponible. Veuillez réessayer dans quelques instants.",
            code="GEMINI_UNAVAILABLE",
        )

    # ── Step 3: Validate and repair output ────────────────────────────────────
    return validate_gemini_response(raw_response)
