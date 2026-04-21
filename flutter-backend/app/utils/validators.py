"""
utils/validators.py — Gemini Response Validators

Parses and validates raw Gemini output into typed Pydantic response models.
Provides a single safe entrypoint so route handlers never deal with raw JSON.
"""

import json
from typing import Union

from pydantic import ValidationError

from app.core.logging import get_logger
from app.schemas.responses import ErrorResponse, ProcedureGuideResponse

logger = get_logger(__name__)

# The canonical fallback when Gemini output is unusable
FALLBACK_ERROR = ErrorResponse(
    type="error",
    message="Unable to generate procedure safely. Please try rephrasing your question.",
    code="VALIDATION_FAILED",
)


def validate_gemini_response(
    raw: str,
) -> Union[ProcedureGuideResponse, ErrorResponse]:
    """
    Attempt to parse and validate a raw JSON string from Gemini.

    Steps:
    1. Strip any accidental markdown fences (```json ... ```)
    2. Parse as JSON
    3. Validate against ProcedureGuideResponse
    4. Return FALLBACK_ERROR on any failure

    Returns a ProcedureGuideResponse on success, ErrorResponse on failure.
    """
    # ── Step 1: Strip markdown code fences if Gemini wrapped the JSON ─────────
    cleaned = raw.strip()
    if cleaned.startswith("```"):
        lines = cleaned.splitlines()
        # Remove first line (```json or ```) and last line (```)
        lines = [l for l in lines if not l.strip().startswith("```")]
        cleaned = "\n".join(lines).strip()

    # ── Step 2: JSON parse ─────────────────────────────────────────────────────
    try:
        data = json.loads(cleaned)
    except json.JSONDecodeError as exc:
        logger.error(
            "Gemini returned invalid JSON",
            error=str(exc),
            raw_preview=raw[:300],
        )
        return FALLBACK_ERROR

    # ── Step 3: Pydantic validation ────────────────────────────────────────────
    try:
        return ProcedureGuideResponse.model_validate(data)
    except ValidationError as exc:
        logger.error(
            "Gemini JSON failed Pydantic validation",
            errors=exc.errors(),
            raw_preview=cleaned[:300],
        )
        return FALLBACK_ERROR
