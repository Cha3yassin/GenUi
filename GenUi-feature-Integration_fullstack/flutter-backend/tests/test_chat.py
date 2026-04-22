"""
tests/test_chat.py — Chat Endpoint Tests

Uses mocked Gemini and RAG services so no real API keys are needed.
"""

import json
import pytest
from unittest.mock import AsyncMock, patch
from httpx import AsyncClient


# ── Fixture Data ──────────────────────────────────────────────────────────────

VALID_GEMINI_RESPONSE = json.dumps({
    "type": "procedure_guide",
    "title": {
        "ar": "استخراج شهادة الميلاد",
        "fr": "Obtenir un Extrait de Naissance",
        "en": "Get a Birth Certificate",
    },
    "steps": [
        {
            "number": 1,
            "title": "Rendez-vous à la Municipalité",
            "description": "Apportez votre CIN et rendez-vous au guichet de l'état civil.",
            "location": "Municipalité de Sfax, Avenue Habib Bourguiba",
        }
    ],
    "documents": ["CIN originale", "Livret de famille"],
    "costs": {
        "total": 0.6,
        "currency": "TND",
        "breakdown": [{"label": "Timbre fiscal", "amount": 0.6}],
    },
    "office": {
        "name": "Service de l'État Civil — Municipalité de Sfax",
        "address": "Avenue Habib Bourguiba, Sfax 3000",
        "hours": "Lundi-Vendredi 8h00-16h00",
    },
    "warnings": ["Valable 3 mois à compter de la date de délivrance."],
    "source": "extrait_naissance_sfax",
    "last_verified": "2024-01-15",
})

MOCK_RAG_CHUNKS = [
    {
        "text": "L'extrait de naissance est délivré à la Municipalité de Sfax.",
        "metadata": {"source_id": "extrait_naissance_sfax", "category": "civil_status"},
        "distance": 0.12,
    }
]


# ── Tests ─────────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_chat_success(client: AsyncClient) -> None:
    """Happy path — returns a valid procedure_guide response."""
    with (
        patch(
            "app.api.routes.chat.rag_service.search_similar_chunks",
            AsyncMock(return_value=MOCK_RAG_CHUNKS),
        ),
        patch(
            "app.api.routes.chat.gemini_service.generate_procedure_response",
            AsyncMock(return_value=VALID_GEMINI_RESPONSE),
        ),
        patch(
            "app.api.routes.chat._persist_history",
            AsyncMock(),
        ),
    ):
        response = await client.post(
            "/api/v1/chat",
            json={
                "message": "Comment obtenir un extrait de naissance?",
                "language": "fr",
                "category": "civil_status",
            },
            headers={"Authorization": "Bearer mock-token"},
        )

    assert response.status_code == 200
    data = response.json()
    assert data["type"] == "procedure_guide"
    assert "title" in data
    assert "steps" in data
    assert len(data["steps"]) >= 1
    assert "documents" in data
    assert "costs" in data
    assert data["costs"]["currency"] == "TND"
    assert "office" in data


@pytest.mark.asyncio
async def test_chat_gemini_failure_returns_error(client: AsyncClient) -> None:
    """When Gemini is unavailable, the endpoint returns an error response (not 500)."""
    with (
        patch(
            "app.api.routes.chat.rag_service.search_similar_chunks",
            AsyncMock(return_value=[]),
        ),
        patch(
            "app.api.routes.chat.gemini_service.generate_procedure_response",
            AsyncMock(side_effect=RuntimeError("Gemini unavailable")),
        ),
        patch(
            "app.api.routes.chat._persist_history",
            AsyncMock(),
        ),
    ):
        response = await client.post(
            "/api/v1/chat",
            json={"message": "How do I get a passport?", "language": "en"},
            headers={"Authorization": "Bearer mock-token"},
        )

    assert response.status_code == 200   # Graceful degradation — not a 500
    data = response.json()
    assert data["type"] == "error"
    assert "message" in data


@pytest.mark.asyncio
async def test_chat_invalid_gemini_json_returns_error(client: AsyncClient) -> None:
    """Invalid Gemini JSON triggers validation fallback, not a crash."""
    with (
        patch(
            "app.api.routes.chat.rag_service.search_similar_chunks",
            AsyncMock(return_value=MOCK_RAG_CHUNKS),
        ),
        patch(
            "app.api.routes.chat.gemini_service.generate_procedure_response",
            AsyncMock(return_value="this is not valid json!!!"),
        ),
        patch(
            "app.api.routes.chat._persist_history",
            AsyncMock(),
        ),
    ):
        response = await client.post(
            "/api/v1/chat",
            json={"message": "What documents do I need?", "language": "fr"},
            headers={"Authorization": "Bearer mock-token"},
        )

    assert response.status_code == 200
    assert response.json()["type"] == "error"


@pytest.mark.asyncio
async def test_chat_message_too_short(client: AsyncClient) -> None:
    """Messages shorter than 2 characters are rejected at schema validation."""
    response = await client.post(
        "/api/v1/chat",
        json={"message": "?", "language": "fr"},
        headers={"Authorization": "Bearer mock-token"},
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_chat_invalid_language(client: AsyncClient) -> None:
    """Unsupported language codes are rejected."""
    response = await client.post(
        "/api/v1/chat",
        json={"message": "What documents do I need?", "language": "es"},
        headers={"Authorization": "Bearer mock-token"},
    )
    assert response.status_code == 422
