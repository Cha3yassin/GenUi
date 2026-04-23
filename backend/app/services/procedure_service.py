"""
services/procedure_service.py — Procedure Category Service

Handles CRUD operations for procedure categories stored in PostgreSQL.
Also provides seed data logic to initialise the categories table.
"""

import uuid
from typing import List, Optional

from sqlalchemy import select, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.logging import get_logger
from app.db.models import Category

logger = get_logger(__name__)

# ── Seed Data ─────────────────────────────────────────────────────────────────

SEED_CATEGORIES = [
    {
        "slug": "civil_status",
        "name_ar": "الحالة المدنية",
        "name_fr": "État Civil",
        "name_en": "Civil Status",
        "icon": "document_text",
        "target_role": "individual",
    },
    {
        "slug": "vehicles",
        "name_ar": "المركبات",
        "name_fr": "Véhicules",
        "name_en": "Vehicles",
        "icon": "car",
        "target_role": "individual",
    },
    {
        "slug": "taxation",
        "name_ar": "الضرائب",
        "name_fr": "Fiscalité",
        "name_en": "Taxation",
        "icon": "receipt_percent",
        "target_role": "enterprise",
    },
    {
        "slug": "residence",
        "name_ar": "الإقامة",
        "name_fr": "Résidence",
        "name_en": "Residence",
        "icon": "home",
        "target_role": "individual",
    },
    {
        "slug": "passports_travel",
        "name_ar": "جوازات السفر",
        "name_fr": "Passeports & Voyages",
        "name_en": "Passports & Travel",
        "icon": "passport",
        "target_role": "individual",
    },
    {
        "slug": "business",
        "name_ar": "الأعمال التجارية",
        "name_fr": "Création d'entreprise",
        "name_en": "Business Registration",
        "icon": "briefcase",
        "target_role": "enterprise",
    },
    {
        "slug": "social_security",
        "name_ar": "الضمان الاجتماعي",
        "name_fr": "Sécurité Sociale",
        "name_en": "Social Security",
        "icon": "shield_check",
        "target_role": "all",
    },
    {
        "slug": "property",
        "name_ar": "العقارات",
        "name_fr": "Immobilier",
        "name_en": "Property",
        "icon": "building_office",
        "target_role": "all",
    },
]


async def seed_categories(db: AsyncSession) -> int:
    """
    Insert seed categories into the database if they don't already exist.
    Uses slug as the unique key — safe to call multiple times (idempotent).

    Returns:
        Number of categories inserted.
    """
    inserted = 0
    for cat_data in SEED_CATEGORIES:
        result = await db.execute(
            select(Category).where(Category.slug == cat_data["slug"])
        )
        existing = result.scalar_one_or_none()

        if existing is None:
            db.add(Category(id=uuid.uuid4(), **cat_data))
            inserted += 1

    await db.flush()
    logger.info("Category seed complete", inserted=inserted)
    return inserted


async def get_all_categories(db: AsyncSession) -> List[Category]:
    """Return all categories ordered alphabetically by slug."""
    result = await db.execute(
        select(Category).order_by(Category.slug)
    )
    return list(result.scalars().all())


async def get_categories_by_role(
    db: AsyncSession,
    role: str,
) -> List[Category]:
    """
    Return categories where target_role is 'all' or matches the given role.
    """
    result = await db.execute(
        select(Category)
        .where(or_(Category.target_role == "all", Category.target_role == role))
        .order_by(Category.slug)
    )
    return list(result.scalars().all())
