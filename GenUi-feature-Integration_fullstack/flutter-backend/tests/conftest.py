"""
tests/conftest.py — Pytest Fixtures

Shared fixtures for all test modules:
- In-memory async SQLite engine (no Postgres required for tests)
- FastAPI test client with dependency overrides
- Mock Firebase token (bypasses real Firebase in CI)
"""

import asyncio
import json
import uuid
from typing import AsyncGenerator
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
import pytest_asyncio
from fastapi import FastAPI
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.security import DecodedToken
from app.db.models import Base
from app.db.session import get_db
from app.main import create_app

# ── Test Database (SQLite in-memory) ──────────────────────────────────────────

TEST_DB_URL = "sqlite+aiosqlite:///:memory:"


@pytest_asyncio.fixture(scope="session")
def event_loop():
    """Use a single event loop for all session-scoped fixtures."""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest_asyncio.fixture(scope="session")
async def test_engine():
    """Create a shared in-memory SQLite engine for the test session."""
    engine = create_async_engine(TEST_DB_URL, echo=False)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    await engine.dispose()


@pytest_asyncio.fixture
async def db_session(test_engine) -> AsyncGenerator[AsyncSession, None]:
    """Provide a transactional test session that rolls back after each test."""
    session_factory = async_sessionmaker(
        bind=test_engine,
        class_=AsyncSession,
        expire_on_commit=False,
    )
    async with session_factory() as session:
        yield session
        await session.rollback()


# ── Mock Firebase Token ────────────────────────────────────────────────────────

MOCK_UID = "test-firebase-uid-123"
MOCK_EMAIL = "test@fberaucracy.tn"


def make_mock_token() -> DecodedToken:
    return DecodedToken(
        {"uid": MOCK_UID, "email": MOCK_EMAIL, "email_verified": True}
    )


# ── Test App with Dependency Overrides ────────────────────────────────────────

@pytest_asyncio.fixture
async def client(db_session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    """
    Async test client with:
    - DB dependency overridden to use the in-memory test session
    - Firebase auth bypassed with a mock token
    - Firebase Admin SDK initialization skipped
    """
    from app.core.security import verify_firebase_token

    app = create_app()

    # Override DB dependency
    async def override_get_db():
        yield db_session

    # Override Firebase auth dependency
    async def override_firebase_token():
        return make_mock_token()

    app.dependency_overrides[get_db] = override_get_db
    app.dependency_overrides[verify_firebase_token] = override_firebase_token

    # Skip Firebase and DB initialization for tests
    with (
        patch("app.core.security.initialize_firebase"),
        patch("app.db.session.init_db", AsyncMock()),
        patch("app.services.procedure_service.seed_categories", AsyncMock(return_value=0)),
    ):
        async with AsyncClient(
            transport=ASGITransport(app=app),
            base_url="http://test",
        ) as ac:
            yield ac
