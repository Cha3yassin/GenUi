"""
celery_app.py — Celery Application Instance

Creates and configures the Celery app used for background task processing.
Redis is used as both the message broker and the result backend.

Usage (start worker):
    celery -A app.celery_app worker --loglevel=info --pool=solo
"""

from celery import Celery

from app.core.config import settings

celery = Celery(
    "fbureaucracy",
    broker=settings.REDIS_URL,
    backend=settings.REDIS_URL,
)

# ── Configuration ──────────────────────────────────────────────────────────────

celery.conf.update(
    # Serialisation
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",

    # Timezone
    timezone="UTC",
    enable_utc=True,

    # Reliability: acknowledge task AFTER it completes, not on pickup.
    # This prevents task loss if a worker crashes mid-execution.
    task_acks_late=True,

    # Keep task results for 1 hour (separate from the 24h cache TTL).
    # This controls how long AsyncResult(task_id) can retrieve results.
    result_expires=3600,

    # Prevent workers from prefetching many tasks — process one at a time.
    # Important because our tasks are long-running API calls (not fast I/O).
    worker_prefetch_multiplier=1,

    # Auto-discover tasks from our tasks module
    include=["app.tasks"],
)
