"""
tests/test_procedures.py - Procedure discovery endpoint tests.
"""

from unittest.mock import AsyncMock, patch

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_search_returns_fallback_when_rag_unavailable(
    client: AsyncClient,
) -> None:
    """Search should still return an openable generated result if RAG is down."""
    with patch(
        "app.api.routes.procedures.rag_service.search_similar_chunks",
        AsyncMock(side_effect=RuntimeError("embedding unavailable")),
    ):
        response = await client.get(
            "/api/v1/procedures/search",
            params={"q": "buy a used car"},
        )

    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["slug"] == "buy-a-used-car"
    assert data[0]["categoryLabel"] == "Généré par IA"


@pytest.mark.asyncio
async def test_search_returns_arabic_fallback_when_language_is_ar(
    client: AsyncClient,
) -> None:
    """Arabic search results should keep Arabic labels before opening detail."""
    with patch(
        "app.api.routes.procedures.rag_service.search_similar_chunks",
        AsyncMock(side_effect=RuntimeError("embedding unavailable")),
    ):
        response = await client.get(
            "/api/v1/procedures/search",
            params={"q": "شراء سيارة مستعملة", "language": "ar"},
        )

    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["title"] == "شراء سيارة مستعملة"
    assert data[0]["categoryLabel"] == "مولد بالذكاء الاصطناعي"


@pytest.mark.asyncio
async def test_category_returns_fallback_when_rag_unavailable(
    client: AsyncClient,
) -> None:
    """Category lists should not crash when embedding search is unavailable."""
    with patch(
        "app.api.routes.procedures.rag_service.search_similar_chunks",
        AsyncMock(side_effect=RuntimeError("embedding unavailable")),
    ):
        response = await client.get("/api/v1/procedures/by-category/vehicles")

    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["slug"] == "vehicles"
