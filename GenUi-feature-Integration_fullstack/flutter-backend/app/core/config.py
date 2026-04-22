"""
core/config.py — Application Configuration

Loads all settings from environment variables using Pydantic BaseSettings.
Provides a single `settings` singleton used across the entire application.
"""

from functools import lru_cache
from typing import List, Optional

from pydantic import Field, PostgresDsn, computed_field, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Central configuration class. All values are loaded from environment
    variables (or a .env file). Pydantic automatically coerces types.
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # ── Application ───────────────────────────────────────────────────────────
    APP_ENV: str = Field(default="development")
    APP_HOST: str = Field(default="0.0.0.0")
    APP_PORT: int = Field(default=8000)
    DEBUG: bool = Field(default=False)
    SECRET_KEY: str = Field(default="change-me-in-production")

    # ── PostgreSQL ─────────────────────────────────────────────────────────────
    POSTGRES_HOST: str = Field(default="localhost")
    POSTGRES_PORT: int = Field(default=5432)
    POSTGRES_USER: str = Field(default="fberaucracy")
    POSTGRES_PASSWORD: str = Field(default="password")
    POSTGRES_DB: str = Field(default="fberaucracy_db")

    @computed_field  # type: ignore[misc]
    @property
    def DATABASE_URL(self) -> str:
        """Build async PostgreSQL DSN from individual components."""
        return "sqlite+aiosqlite:///./fberaucracy.db"

    # ── Google AI ─────────────────────────────────────────────────────────────
    OPENROUTER_API_KEY: str = Field(default="")
    OPENROUTER_BASE_URL: str = Field(default="https://openrouter.ai/api/v1")
    OPENROUTER_MODEL: str = Field(default="google/gemini-2.5-flash")
    OPENROUTER_APP_TITLE: str = Field(default="Sahil")
    OPENROUTER_SITE_URL: Optional[str] = Field(default=None)

    GOOGLE_API_KEY: str = Field(default="")
    GEMINI_MODEL: str = Field(default="gemini-2.5-flash")
    EMBEDDING_MODEL: str = Field(default="models/gemini-embedding-2-preview")

    # ── Firebase ──────────────────────────────────────────────────────────────
    FIREBASE_SERVICE_ACCOUNT_PATH: Optional[str] = Field(default=None)
    FIREBASE_SERVICE_ACCOUNT_JSON: Optional[str] = Field(default=None)

    # ── ChromaDB ──────────────────────────────────────────────────────────────
    CHROMA_PERSIST_DIRECTORY: str = Field(default="./chroma_data")
    CHROMA_COLLECTION_NAME: str = Field(default="fberaucracy_procedures")

    # ── RAG ───────────────────────────────────────────────────────────────────
    RAG_CHUNK_SIZE: int = Field(default=500)
    RAG_CHUNK_OVERLAP: int = Field(default=50)
    RAG_TOP_K: int = Field(default=5)

    # ── CORS ──────────────────────────────────────────────────────────────────
    ALLOWED_ORIGINS: str = Field(default="http://localhost:3000")

    @property
    def cors_origins(self) -> List[str]:
        """Parse comma-separated origins into a list."""
        return [o.strip() for o in self.ALLOWED_ORIGINS.split(",") if o.strip()]

    @property
    def is_production(self) -> bool:
        return self.APP_ENV.lower() == "production"


@lru_cache()
def get_settings() -> Settings:
    """Return a cached singleton of application settings."""
    return Settings()


# Convenience singleton — import this everywhere
settings: Settings = get_settings()
