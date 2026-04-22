"""
api/routes/categories.py — Procedure Categories Endpoints

GET /categories — Returns the list of all procedure categories.
"""

from typing import Annotated, List

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.logging import get_logger
from app.db.session import get_db
from app.schemas.responses import CategoryResponse
from app.services.procedure_service import get_all_categories

logger = get_logger(__name__)

router = APIRouter(prefix="/categories", tags=["Categories"])


@router.get(
    "",
    response_model=List[CategoryResponse],
    summary="List procedure categories",
    description=(
        "Returns all available procedure categories. "
        "This endpoint is public — no authentication required. "
        "The Flutter app uses this to build the home screen category grid."
    ),
)
async def list_categories(
    db: Annotated[AsyncSession, Depends(get_db)],
) -> List[CategoryResponse]:
    """
    Retrieves all categories from the database and maps them to the
    CategoryResponse schema expected by the Flutter UI.
    """
    categories = await get_all_categories(db)

    logger.debug("Categories listed", count=len(categories))

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
