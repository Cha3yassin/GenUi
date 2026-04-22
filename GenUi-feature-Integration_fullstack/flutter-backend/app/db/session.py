"""
db/session.py — Async Database Session & Engine

Provides an async SQLAlchemy engine and session factory.
The `get_db` dependency injects a session into route handlers and ensures
proper commit/rollback semantics via an async context manager.
"""

from contextlib import asynccontextmanager
from typing import AsyncGenerator

from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)

# ── Engine ─────────────────────────────────────────────────────────────────────

def create_engine() -> AsyncEngine:
    """
    Build an async engine with sensible connection pool defaults.
    pool_pre_ping=True re-validates stale connections before use.
    """
    kwargs = {
        "echo": settings.DEBUG,
        "pool_recycle": 3600,
    }
    if "sqlite" in settings.DATABASE_URL:
        kwargs["connect_args"] = {"check_same_thread": False}
    else:
        kwargs["pool_pre_ping"] = True
        kwargs["pool_size"] = 10
        kwargs["max_overflow"] = 20
        
    return create_async_engine(
        settings.DATABASE_URL,
        **kwargs
    )


engine: AsyncEngine = create_engine()

# Session factory — do NOT create sessions directly; use get_db() instead
AsyncSessionLocal: async_sessionmaker[AsyncSession] = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,           # Avoid lazy-load errors after commit
    autoflush=False,
    autocommit=False,
)


# ── Database Initialisation ────────────────────────────────────────────────────

async def init_db() -> None:
    """
    Create all tables defined in the ORM models if they don't already exist.
    In production you would use Alembic migrations instead.
    """
    from app.db.models import Base  # Local import to avoid circular deps

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    logger.info("Database tables created / verified.")


async def close_db() -> None:
    """Dispose of the connection pool on application shutdown."""
    await engine.dispose()
    logger.info("Database connection pool disposed.")


# ── Dependency ─────────────────────────────────────────────────────────────────

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    FastAPI dependency that provides a scoped async database session.

    Usage in a route:
        async def my_route(db: Annotated[AsyncSession, Depends(get_db)]):
            ...

    The session is automatically committed on success and rolled back on error.
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
