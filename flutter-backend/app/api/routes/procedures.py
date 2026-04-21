"""
api/routes/procedures.py — Procedure discovery endpoints for frontend lists.
"""

from typing import List

from fastapi import APIRouter, Query

from app.core.logging import get_logger
from app.services import rag_service

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
    limit: int = Query(6, ge=1, le=20),
) -> List[dict]:
    chunks = await rag_service.search_similar_chunks(query=q, top_k=limit * 2)
    return _chunks_to_summaries(chunks, fallback_query=q, limit=limit)


@router.get("/by-category/{category_id}")
async def procedures_by_category(
    category_id: str,
    limit: int = Query(6, ge=1, le=20),
) -> List[dict]:
    chunks = await rag_service.search_similar_chunks(
        query=category_id.replace("_", " "),
        top_k=limit * 2,
        category_filter=category_id,
    )
    return _chunks_to_summaries(chunks, fallback_query=category_id, limit=limit)


def _chunks_to_summaries(chunks: List[dict], fallback_query: str, limit: int) -> List[dict]:
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
        }

    results = list(grouped.values())[:limit]
    if results:
        return results

    # fallback: one virtual result so frontend can still open Gen UI detail
    return [
        {
            "id": f"query-{fallback_query}",
            "slug": fallback_query.strip().lower().replace(" ", "-"),
            "title": fallback_query.strip().title(),
            "summary": "AI generated procedure from your search query.",
            "categoryId": "ai-generated",
            "categoryLabel": "AI Generated",
            "estimatedDuration": "~ variable",
            "estimatedCost": "~ variable",
            "officesToVisit": 1,
        }
    ]
