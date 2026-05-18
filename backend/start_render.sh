#!/bin/bash
# ============================================================
# Render Startup Script — GenUI Backend
# Runs FastAPI (Uvicorn) and Celery Worker concurrently 
# in the same container to share SQLite and ChromaDB volumes.
# ============================================================

set -e

echo "[STARTUP] Activating virtual environment..."
export PATH="/opt/venv/bin:$PATH"

# Run any migrations if needed (Optional)
# echo "[STARTUP] Running database migrations..."
# alembic upgrade head

echo "[STARTUP] Starting Celery worker in the background..."
# --pool=solo and --concurrency=1 is recommended for single-core or light servers
celery -A app.celery_app worker --loglevel=info --pool=solo --concurrency=1 &
CELERY_PID=$!

echo "[STARTUP] Starting FastAPI Uvicorn server..."
# Using exec so Uvicorn becomes PID 1 and receives OS shutdown signals correctly
exec uvicorn app.main:app \
     --host 0.0.0.0 \
     --port 8000 \
     --workers 1 \
     --access-log
