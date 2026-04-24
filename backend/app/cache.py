"""
cache.py — Redis Exact-Match Cache for Procedure Responses

Provides lightweight helpers for caching validated GenUI JSON responses
in Redis. Uses SHA-256 hashing of normalised queries as cache keys.

Cache key format:
    fbureaucracy:cache:{sha256(normalised_message + "|" + language)}

The module is designed to fail gracefully: if Redis is unreachable,
cache operations return None / silently no-op so the app continues.
"""

import hashlib
import json
import re
from typing import Optional

import redis

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)

# ── Lazy singleton Redis client ────────────────────────────────────────────────

_redis_client: Optional[redis.Redis] = None


def get_redis_client() -> redis.Redis:
    """
    Return a lazy-initialised Redis connection.
    Uses a connection pool under the hood (redis-py default).
    """
    global _redis_client
    if _redis_client is None:
        _redis_client = redis.from_url(
            settings.REDIS_URL,
            decode_responses=True,        # Store/retrieve as str, not bytes
            socket_connect_timeout=5,
            socket_timeout=5,
        )
    return _redis_client


def close_redis() -> None:
    """Close the Redis connection pool. Called on app shutdown."""
    global _redis_client
    if _redis_client is not None:
        _redis_client.close()
        _redis_client = None
        logger.info("Redis connection closed.")


# ── Query normalisation ───────────────────────────────────────────────────────

_TRAILING_PUNCT = re.compile(r"[?.!]+$")
_MULTI_SPACE = re.compile(r"\s+")


def normalize_query(message: str) -> str:
    """
    Lightweight normalisation for exact-match caching.

    1. Strip leading/trailing whitespace
    2. Lowercase
    3. Collapse multiple whitespace → single space
    4. Remove trailing punctuation (?, ., !)

    This means "How do I renew my carte grise?" and
    "how do i renew my carte grise" are the same cache key.
    """
    text = message.strip().lower()
    text = _MULTI_SPACE.sub(" ", text)
    text = _TRAILING_PUNCT.sub("", text)
    return text.strip()


# ── Cache key construction ────────────────────────────────────────────────────

_KEY_PREFIX = "fbureaucracy:cache"


def make_cache_key(message: str, language: str) -> str:
    """
    Build a deterministic Redis key from the user's query + language.

    Format: fbureaucracy:cache:{sha256_hex}
    """
    normalised = normalize_query(message)
    raw = f"{normalised}|{language}"
    digest = hashlib.sha256(raw.encode("utf-8")).hexdigest()
    return f"{_KEY_PREFIX}:{digest}"


# ── Read / Write ──────────────────────────────────────────────────────────────

def get_cached_response(message: str, language: str) -> Optional[dict]:
    """
    Check Redis for a cached response matching this query + language.

    Returns:
        Parsed JSON dict if found, None on miss or if caching is disabled.
    """
    if not settings.CACHE_ENABLED:
        return None

    key = make_cache_key(message, language)
    try:
        value = get_redis_client().get(key)
    except redis.RedisError as exc:
        logger.warning("Redis GET failed — treating as cache miss", error=str(exc))
        return None

    if value is None:
        logger.debug("Cache MISS", cache_key=key[:40])
        return None

    try:
        data = json.loads(value)
        logger.info("Cache HIT", cache_key=key[:40])
        return data
    except json.JSONDecodeError:
        logger.warning("Corrupt cache entry — deleting", cache_key=key[:40])
        try:
            get_redis_client().delete(key)
        except redis.RedisError:
            pass
        return None


def set_cached_response(message: str, language: str, response: dict) -> None:
    """
    Store a validated response in Redis with the configured TTL.

    Silently no-ops if caching is disabled or Redis is unreachable.
    """
    if not settings.CACHE_ENABLED:
        return

    key = make_cache_key(message, language)
    try:
        get_redis_client().setex(
            name=key,
            time=settings.CACHE_TTL_SECONDS,
            value=json.dumps(response, ensure_ascii=False),
        )
        logger.info(
            "Response cached",
            cache_key=key[:40],
            ttl_seconds=settings.CACHE_TTL_SECONDS,
        )
    except redis.RedisError as exc:
        logger.warning("Redis SET failed — response not cached", error=str(exc))
