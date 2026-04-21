"""
tests/test_categories.py — Category Endpoint Tests
"""

import uuid
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Category
from app.services.procedure_service import SEED_CATEGORIES


@pytest.mark.asyncio
async def test_get_categories_empty(client: AsyncClient) -> None:
    """Returns empty list when no categories exist."""
    response = await client.get("/api/v1/categories")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


@pytest.mark.asyncio
async def test_get_categories_with_data(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """Returns correct structure for seeded categories."""
    # Manually insert a category into the test DB
    cat = Category(
        id=uuid.uuid4(),
        slug="vehicles",
        name_ar="المركبات",
        name_fr="Véhicules",
        name_en="Vehicles",
        icon="car",
    )
    db_session.add(cat)
    await db_session.flush()

    response = await client.get("/api/v1/categories")
    assert response.status_code == 200

    data = response.json()
    assert len(data) >= 1

    # Verify the category schema
    first = data[0]
    assert "id" in first
    assert "name_ar" in first
    assert "name_fr" in first
    assert "name_en" in first
    assert "icon" in first


@pytest.mark.asyncio
async def test_categories_requires_no_auth(client: AsyncClient) -> None:
    """Categories endpoint is public — no Authorization header needed."""
    # The client fixture already strips auth overrides, but this
    # explicitly ensures no 401 is returned without a token.
    response = await client.get("/api/v1/categories")
    assert response.status_code != 401
