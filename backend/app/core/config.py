"""
Application configuration.

Loads settings from environment variables and the backend .env file.
"""

from functools import lru_cache
from pathlib import Path
from typing import List, Optional

from pydantic import Field, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


BACKEND_DIR = Path(__file__).resolve().parents[2]
ENV_FILE_PATH = BACKEND_DIR / ".env"


def _resolve_backend_path(raw_path: Optional[str]) -> Optional[str]:
    """Resolve relative filesystem paths from the backend root directory."""
    if not raw_path:
        return raw_path

    path = Path(raw_path).expanduser()
    if path.is_absolute():
        return str(path)
    return str((BACKEND_DIR / path).resolve())


def _resolve_sqlite_url(database_url: str) -> str:
    """Resolve relative SQLite URLs from the backend root directory."""
    for prefix in ("sqlite+aiosqlite:///", "sqlite:///"):
        if not database_url.startswith(prefix):
            continue

        raw_path = database_url[len(prefix) :]
        if not raw_path or raw_path == ":memory:":
            return database_url

        db_path = Path(raw_path).expanduser()
        if not db_path.is_absolute():
            db_path = (BACKEND_DIR / db_path).resolve()

        return f"{prefix}{db_path.as_posix()}"

    return database_url


class Settings(BaseSettings):
    """Central application settings."""

    model_config = SettingsConfigDict(
        env_file=str(ENV_FILE_PATH),
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    APP_ENV: str = Field(default="development")
    APP_HOST: str = Field(default="0.0.0.0")
    APP_PORT: int = Field(default=8000)
    DEBUG: bool = Field(default=False)
    SECRET_KEY: str = Field(default="change-me-in-production")

    POSTGRES_HOST: str = Field(default="localhost")
    POSTGRES_PORT: int = Field(default=5432)
    POSTGRES_USER: str = Field(default="fberaucracy")
    POSTGRES_PASSWORD: str = Field(default="password")
    POSTGRES_DB: str = Field(default="fberaucracy_db")
    DATABASE_URL: Optional[str] = Field(default=None)

    OPENROUTER_API_KEY: str = Field(default="")
    OPENROUTER_BASE_URL: str = Field(default="https://openrouter.ai/api/v1")
    OPENROUTER_MODEL: str = Field(default="google/gemini-2.5-flash")
    OPENROUTER_APP_TITLE: str = Field(default="Fbureaucracy")
    OPENROUTER_SITE_URL: Optional[str] = Field(default=None)

    GOOGLE_API_KEY: str = Field(default="")
    GEMINI_MODEL: str = Field(default="gemini-2.5-flash")
    EMBEDDING_MODEL: str = Field(default="models/gemini-embedding-2-preview")

    FIREBASE_SERVICE_ACCOUNT_PATH: Optional[str] = Field(default=None)
    FIREBASE_SERVICE_ACCOUNT_JSON: Optional[str] = Field(default=None)

    CHROMA_PERSIST_DIRECTORY: str = Field(default="./chroma_data")
    CHROMA_COLLECTION_NAME: str = Field(default="fberaucracy_procedures")

    RAG_CHUNK_SIZE: int = Field(default=500)
    RAG_CHUNK_OVERLAP: int = Field(default=50)
    RAG_TOP_K: int = Field(default=5)

    REDIS_URL: str = Field(default="redis://localhost:6379/0")
    CACHE_TTL_SECONDS: int = Field(default=86400)
    CACHE_ENABLED: bool = Field(default=True)

    ALLOWED_ORIGINS: str = Field(default="http://localhost:3000")

    @model_validator(mode="after")
    def normalise_paths(self) -> "Settings":
        """
        Make settings independent from the current working directory.

        This keeps launches from the repo root and backend folder consistent.
        """
        if not self.DATABASE_URL:
            default_db_path = (BACKEND_DIR / "fberaucracy.db").resolve()
            self.DATABASE_URL = f"sqlite+aiosqlite:///{default_db_path.as_posix()}"
        else:
            self.DATABASE_URL = _resolve_sqlite_url(self.DATABASE_URL)

        self.FIREBASE_SERVICE_ACCOUNT_PATH = _resolve_backend_path(
            self.FIREBASE_SERVICE_ACCOUNT_PATH
        )
        self.CHROMA_PERSIST_DIRECTORY = _resolve_backend_path(
            self.CHROMA_PERSIST_DIRECTORY
        ) or self.CHROMA_PERSIST_DIRECTORY
        return self

    @property
    def cors_origins(self) -> List[str]:
        """Parse comma-separated origins into a list."""
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",") if origin.strip()]

    @property
    def is_production(self) -> bool:
        return self.APP_ENV.lower() == "production"


@lru_cache()
def get_settings() -> Settings:
    """Return a cached singleton of application settings."""
    return Settings()


settings: Settings = get_settings()
