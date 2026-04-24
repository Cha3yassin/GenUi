from pathlib import Path

from app.core.config import BACKEND_DIR, ENV_FILE_PATH, Settings


def test_env_file_path_is_absolute():
    assert Path(Settings.model_config["env_file"]).is_absolute()
    assert Path(Settings.model_config["env_file"]) == ENV_FILE_PATH


def test_relative_paths_are_resolved_from_backend_dir():
    settings = Settings(
        _env_file=None,
        DATABASE_URL="sqlite+aiosqlite:///./custom.db",
        FIREBASE_SERVICE_ACCOUNT_PATH="./firebase-service-account.json",
        CHROMA_PERSIST_DIRECTORY="./chroma_data",
    )

    assert settings.DATABASE_URL == (
        f"sqlite+aiosqlite:///{(BACKEND_DIR / 'custom.db').resolve().as_posix()}"
    )
    assert settings.FIREBASE_SERVICE_ACCOUNT_PATH == str(
        (BACKEND_DIR / "firebase-service-account.json").resolve()
    )
    assert settings.CHROMA_PERSIST_DIRECTORY == str((BACKEND_DIR / "chroma_data").resolve())


def test_default_sqlite_database_is_under_backend_dir():
    settings = Settings(_env_file=None)

    assert settings.DATABASE_URL == (
        f"sqlite+aiosqlite:///{(BACKEND_DIR / 'fberaucracy.db').resolve().as_posix()}"
    )
