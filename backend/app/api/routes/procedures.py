"""
api/routes/procedures.py — Procedure discovery endpoints for frontend lists.
"""

from typing import List, Literal

from fastapi import APIRouter, Query

from app.core.logging import get_logger
from app.services import rag_service
from app.services.gemini_service import check_administrative_intent

logger = get_logger(__name__)

router = APIRouter(prefix="/procedures", tags=["Procedures"])


_CATEGORY_LABELS = {
    "civil_status": "Civil Status",
    "vehicles": "Vehicles",
    "taxation": "Taxation",
    "residence": "Residence",
    "passports_travel": "Passports & Travel",
    "business": "Business",
    "social_security": "Social Security",
    "property": "Property",
}


@router.get("/search")
async def search_procedures(
    q: str = Query(..., min_length=2, max_length=200),
    language: Literal["ar", "fr", "en"] = Query("fr"),
    limit: int = Query(6, ge=1, le=20),
) -> List[dict]:
    is_admin = await check_administrative_intent(q)
    if not is_admin:
        return [{
            "id": f"query-{q}",
            "slug": q.strip().lower().replace(" ", "-"),
            "title": _fallback_title(q, language),
            "summary": _fallback_summary(language),
            "categoryId": "non-administrative",
            "categoryLabel": "Non Administrative",
            "estimatedDuration": "-",
            "estimatedCost": "-",
            "officesToVisit": 0,
            "isAdministrative": False
        }]

    try:
        chunks = await rag_service.search_similar_chunks(query=q, top_k=limit * 2)
    except Exception as exc:
        logger.warning(
            "Procedure search RAG failed; returning generated fallback",
            query=q[:80],
            error=str(exc),
        )
        chunks = []
    return _chunks_to_summaries(
        chunks,
        fallback_query=q,
        limit=limit,
        language=language,
    )


@router.get("/by-category/{category_id}")
async def procedures_by_category(
    category_id: str,
    language: Literal["ar", "fr", "en"] = Query("fr"),
    limit: int = Query(6, ge=1, le=20),
) -> List[dict]:
    is_admin = await check_administrative_intent(category_id.replace("_", " "))
    if not is_admin:
        return [{
            "id": f"query-{category_id}",
            "slug": category_id.strip().lower().replace(" ", "-"),
            "title": _fallback_title(category_id, language),
            "summary": _fallback_summary(language),
            "categoryId": "non-administrative",
            "categoryLabel": "Non Administrative",
            "estimatedDuration": "-",
            "estimatedCost": "-",
            "officesToVisit": 0,
            "isAdministrative": False
        }]

    try:
        chunks = await rag_service.search_similar_chunks(
            query=category_id.replace("_", " "),
            top_k=limit * 2,
            category_filter=category_id,
        )
    except Exception as exc:
        logger.warning(
            "Category procedure RAG failed; returning generated fallback",
            category=category_id,
            error=str(exc),
        )
        chunks = []
    return _chunks_to_summaries(
        chunks,
        fallback_query=category_id,
        limit=limit,
        language=language,
    )


def _chunks_to_summaries(
    chunks: List[dict],
    fallback_query: str,
    limit: int,
    language: str = "fr",
) -> List[dict]:
    grouped: dict[str, dict] = {}
    for item in chunks:
        meta = item.get("metadata", {}) or {}
        source_id = str(meta.get("source_id", "generated-procedure"))
        category = str(meta.get("category", "civil_status"))
        if source_id in grouped:
            continue

        snippet = " ".join(str(item.get("text", "")).strip().split())
        grouped[source_id] = {
            "id": source_id,
            "slug": source_id.replace("_", "-"),
            "title": source_id.replace("_", " ").title(),
            "summary": snippet[:180] + ("..." if len(snippet) > 180 else ""),
            "categoryId": category,
            "categoryLabel": _CATEGORY_LABELS.get(category, "Procedures"),
            "estimatedDuration": "~ variable",
            "estimatedCost": "~ variable",
            "officesToVisit": 1,
            "isAdministrative": True,
        }

    results = list(grouped.values())[:limit]
    if results:
        return results

    # fallback: one virtual result so frontend can still open Gen UI detail
    return [
        {
            "id": f"query-{fallback_query}",
            "slug": fallback_query.strip().lower().replace(" ", "-"),
            "title": _fallback_title(fallback_query, language),
            "summary": _fallback_summary(language),
            "categoryId": "ai-generated",
            "categoryLabel": _fallback_category_label(language),
            "estimatedDuration": _fallback_duration(language),
            "estimatedCost": _fallback_cost(language),
            "officesToVisit": 1,
            "isAdministrative": True,
        }
    ]


def _fallback_title(query: str, language: str) -> str:
    if language == "ar":
        return query.strip()
    return query.strip().title()


def _fallback_summary(language: str) -> str:
    if language == "ar":
        return "إجراء مولد بالذكاء الاصطناعي من بحثك."
    if language == "en":
        return "AI generated procedure from your search query."
    return "Procédure générée par l'IA à partir de votre recherche."


def _fallback_category_label(language: str) -> str:
    if language == "ar":
        return "مولد بالذكاء الاصطناعي"
    if language == "en":
        return "AI Generated"
    return "Généré par IA"


def _fallback_duration(language: str) -> str:
    return "متغير" if language == "ar" else "~ variable"


def _fallback_cost(language: str) -> str:
    return "متغير" if language == "ar" else "~ variable"
