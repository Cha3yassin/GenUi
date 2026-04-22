"""
tests/test_offices.py - Office location endpoint tests.
"""

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_nearby_offices_returns_locations(client: AsyncClient) -> None:
    response = await client.get("/api/v1/offices/nearby")

    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 1
    assert {"id", "name", "address", "lat", "lng", "distance"}.issubset(data[0])


@pytest.mark.asyncio
async def test_nearby_offices_filters_vehicle_services(client: AsyncClient) -> None:
    response = await client.get(
        "/api/v1/offices/nearby",
        params={"stepId": "carte-grise"},
    )

    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 1
    assert any("ATTT" in item["name"] for item in data)
