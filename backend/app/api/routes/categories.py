"""
api/routes/categories.py — Procedure Categories Endpoints

GET /categories — Returns the list of all procedure categories.
Supports optional ?role= query parameter for role-based filtering.
"""

from typing import Annotated, List, Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.logging import get_logger
from app.db.session import get_db
from app.schemas.responses import CategoryResponse
from app.services.procedure_service import get_all_categories, get_categories_by_role

logger = get_logger(__name__)

router = APIRouter(prefix="/categories", tags=["Categories"])


@router.get(
    "",
    response_model=List[CategoryResponse],
    summary="List procedure categories",
    description=(
        "Returns available procedure categories. "
        "Use ?role=individual or ?role=enterprise to filter by user role. "
        "Without a role parameter, returns all categories (backward compatible). "
        "This endpoint is public — no authentication required."
    ),
)
async def list_categories(
    db: Annotated[AsyncSession, Depends(get_db)],
    role: Optional[str] = Query(
        default=None,
        description="Filter categories by user role: 'individual' or 'enterprise'",
    ),
) -> List[CategoryResponse]:
    """
    Retrieves categories from the database and maps them to the
    CategoryResponse schema expected by the Flutter UI.

    If role is provided, filters to show only 'all' + matching role categories.
    """
    if role and role in ("individual", "enterprise"):
        categories = await get_categories_by_role(db, role)
    else:
        categories = await get_all_categories(db)

    logger.debug("Categories listed", count=len(categories), role_filter=role)

    return [
        CategoryResponse(
            id=cat.slug,
            name_ar=cat.name_ar,
            name_fr=cat.name_fr,
            name_en=cat.name_en,
            icon=cat.icon,
        )
        for cat in categories
    ]
