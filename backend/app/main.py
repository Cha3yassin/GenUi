"""
main.py — Fberaucracy FastAPI Application Entry Point

Bootstraps the FastAPI application with:
- Lifespan context manager for startup/shutdown events
- CORS middleware
- Global exception handlers
- API router registration
- OpenAPI metadata
"""

from contextlib import asynccontextmanager
from typing import AsyncGenerator

from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.core.logging import get_logger, setup_logging
from app.core.security import initialize_firebase
from app.db.session import close_db, init_db

# Set up structured logging before anything else
setup_logging()
logger = get_logger(__name__)


# ── Lifespan ───────────────────────────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """
    Application lifespan manager.

    Startup:
    - Initialize Firebase Admin SDK
    - Create/verify PostgreSQL tables
    - Seed categories if the table is empty

    Shutdown:
    - Dispose database connection pool
    """
    logger.info(
        "f-idarty backend starting up",
        env=settings.APP_ENV,
        debug=settings.DEBUG,
    )

    # ── Startup ────────────────────────────────────────────────────────────────
    try:
        initialize_firebase()
    except Exception as exc:
        logger.error("Firebase initialization failed", error=str(exc))
        # Allow startup without Firebase in local dev if key is not set
        if settings.is_production:
            raise

    try:
        await init_db()

        # Seed categories on first run
        from app.db.session import AsyncSessionLocal
        from app.services.procedure_service import seed_categories
        async with AsyncSessionLocal() as session:
            try:
                inserted = await seed_categories(session)
                await session.commit()
                if inserted > 0:
                    logger.info("Categories seeded", count=inserted)
            except Exception as exc:
                await session.rollback()
                logger.error("Category seeding failed", error=str(exc))
    except Exception as exc:
        logger.warning(
            "⚠️ PostgreSQL is not available locally. Application will run in degraded mode (GenUI is still fully functional).",
            error=str(exc)
        )

    # ── Redis health check ─────────────────────────────────────────────────────
    try:
        from app.cache import get_redis_client
        client = get_redis_client()
        client.ping()
        logger.info("Redis connection verified")
    except Exception as exc:
        logger.warning(
            "⚠️ Redis is not available. Caching and task queue will not work.",
            error=str(exc),
        )

    logger.info("Startup complete — accepting requests")

    yield  # ← Application runs here

    # ── Shutdown ───────────────────────────────────────────────────────────────
    logger.info("Shutting down f-idarty backend...")
    try:
        from app.cache import close_redis
        close_redis()
    except Exception:
        pass
    await close_db()
    logger.info("Shutdown complete.")


# ── Application Factory ────────────────────────────────────────────────────────

def create_app() -> FastAPI:
    """
    FastAPI application factory.
    Returns a fully configured FastAPI instance.
    """
    app = FastAPI(
        title="f-idarty API",
        description=(
            "🇹🇳 Tunisia Bureaucracy Navigator — Helps Tunisian users understand "
            "government procedures through AI-powered structured guidance."
        ),
        version="1.0.0",
        docs_url="/docs" if not settings.is_production else None,
        redoc_url="/redoc" if not settings.is_production else None,
        lifespan=lifespan,
    )

    # ── CORS ───────────────────────────────────────────────────────────────────
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # ── Global Exception Handlers ──────────────────────────────────────────────
    @app.exception_handler(Exception)
    async def global_exception_handler(request: Request, exc: Exception) -> JSONResponse:
        """Catch-all handler — returns a safe JSON error without leaking internals in production."""
        import traceback
        logger.error(
            "Unhandled exception",
            path=request.url.path,
            method=request.method,
            error=str(exc),
            exc_info=exc,
        )
        
        # If in debug mode or not production, return the exact exception details
        # so we can see the exact cause of 500 errors in the web developer console.
        if settings.DEBUG or not settings.is_production:
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content={
                    "type": "error",
                    "message": f"Dev Debug: {str(exc)}",
                    "code": "INTERNAL_ERROR",
                    "traceback": traceback.format_exc(),
                },
            )
            
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "type": "error",
                "message": "An internal server error occurred.",
                "code": "INTERNAL_ERROR",
            },
        )

    # ── API Routers ────────────────────────────────────────────────────────────
    from app.api.routes import auth, categories, chat, gen_ui, history, offices, procedures

    app.include_router(auth.router, prefix="/api/v1")
    app.include_router(chat.router, prefix="/api/v1")
    app.include_router(gen_ui.router, prefix="/api/v1")
    app.include_router(offices.router, prefix="/api/v1")
    app.include_router(procedures.router, prefix="/api/v1")
    app.include_router(categories.router, prefix="/api/v1")
    app.include_router(history.router, prefix="/api/v1")

    # ── Health Check ───────────────────────────────────────────────────────────
    @app.get("/health", tags=["System"], summary="Health check")
    async def health_check() -> dict:
        """Simple liveness probe for Docker / load balancer health checks."""
        return {
            "status": "healthy",
            "service": "fberaucracy-api",
            "version": "1.0.0",
            "environment": settings.APP_ENV,
        }

    @app.get("/", tags=["System"], include_in_schema=False)
    async def root() -> dict:
        return {"message": "🇹🇳 f-idarty API — Tunisia Bureaucracy Navigator"}

    logger.info("FastAPI application created", routes=len(app.routes))
    return app


# ── Application Instance ───────────────────────────────────────────────────────
app: FastAPI = create_app()


# ── Dev Server Entrypoint ──────────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host=settings.APP_HOST,
        port=settings.APP_PORT,
        reload=settings.DEBUG,
        log_level="debug" if settings.DEBUG else "info",
    )
