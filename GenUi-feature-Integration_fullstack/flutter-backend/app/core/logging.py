"""
core/logging.py — Structured Logging Setup

Configures structlog for JSON-formatted, structured logging.
Outputs human-readable logs in development and JSON in production.
"""

import logging
import sys

import structlog

from app.core.config import settings


def setup_logging() -> None:
    """
    Configure structlog processors and the standard library logging bridge.
    Call this once at application startup in main.py.
    """
    log_level = logging.DEBUG if settings.DEBUG else logging.INFO

    # Configure standard library logging to feed into structlog
    logging.basicConfig(
        format="%(message)s",
        stream=sys.stdout,
        level=log_level,
    )

    # Choose processors based on environment
    shared_processors: list = [
        structlog.contextvars.merge_contextvars,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
    ]

    if settings.is_production:
        # Structured JSON output for log aggregators (Datadog, CloudWatch, etc.)
        processors = shared_processors + [
            structlog.processors.dict_tracebacks,
            structlog.processors.JSONRenderer(),
        ]
    else:
        # Pretty, color-coded output for local development
        processors = shared_processors + [
            structlog.dev.ConsoleRenderer(colors=True),
        ]

    structlog.configure(
        processors=processors,  # type: ignore[arg-type]
        wrapper_class=structlog.stdlib.BoundLogger,
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
        cache_logger_on_first_use=True,
    )


def get_logger(name: str = __name__) -> structlog.BoundLogger:
    """Return a bound structlog logger with the given name."""
    return structlog.get_logger(name)
