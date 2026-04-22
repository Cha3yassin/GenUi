"""
utils/validators.py — Gemini Response Validators

Parses and validates raw Gemini output into typed Pydantic response models.
Tolerant validation: partial responses are repaired rather than rejected.
"""

import json
from typing import Union

from pydantic import ValidationError

from app.core.logging import get_logger
from app.schemas.responses import (
    CostInfo,
    ErrorResponse,
    OfficeInfo,
    ProcedureGuideResponse,
    ProcedureStep,
)

logger = get_logger(__name__)


# ── Fallback error when Gemini output is completely unusable ───────────────────

FALLBACK_ERROR = ErrorResponse(
    type="error",
    message="Unable to generate procedure safely. Please try rephrasing your question.",
    code="VALIDATION_FAILED",
)


def _repair_data(data: dict) -> dict:
    """
    Attempt to repair a partially valid Gemini response.
    Fills missing required fields with safe defaults so the response
    can pass Pydantic validation instead of being rejected outright.

    Args:
        data: Parsed JSON dict from Gemini.

    Returns:
        Repaired dict ready for Pydantic validation.
    """
    # ── Title ──────────────────────────────────────────────────────────────────
    if "title" not in data or not isinstance(data["title"], dict):
        raw_title = str(data.get("title", "Procedure administrative"))
        data["title"] = {"ar": raw_title, "fr": raw_title, "en": raw_title}
    else:
        title = data["title"]
        fallback = title.get("fr") or title.get("en") or title.get("ar") or "Procédure"
        title.setdefault("ar", fallback)
        title.setdefault("fr", fallback)
        title.setdefault("en", fallback)

    # ── Steps ──────────────────────────────────────────────────────────────────
    if not data.get("steps") or not isinstance(data["steps"], list):
        data["steps"] = [
            {
                "number": 1,
                "title": "Consultez un guichet administratif",
                "description": "Renseignez-vous auprès de l'administration compétente pour obtenir les informations à jour.",
                "location": None,
            }
        ]
    else:
        for i, step in enumerate(data["steps"]):
            if not isinstance(step, dict):
                continue
            step.setdefault("number", i + 1)
            step.setdefault("title", f"Étape {i + 1}")
            step.setdefault("description", "")
            step.setdefault("location", None)
            # Ensure number is int
            try:
                step["number"] = int(step["number"])
            except (ValueError, TypeError):
                step["number"] = i + 1

    # ── Documents ──────────────────────────────────────────────────────────────
    if not isinstance(data.get("documents"), list):
        data["documents"] = []

    # ── Costs ──────────────────────────────────────────────────────────────────
    if not isinstance(data.get("costs"), dict):
        data["costs"] = {"total": 0, "currency": "TND", "breakdown": []}
    else:
        costs = data["costs"]
        # Coerce total to float
        try:
            costs["total"] = float(str(costs.get("total", 0)).replace(" TND", "").strip() or 0)
        except (ValueError, TypeError):
            costs["total"] = 0.0
        costs.setdefault("currency", "TND")
        if not isinstance(costs.get("breakdown"), list):
            costs["breakdown"] = []
        else:
            # Coerce amounts in breakdown
            for item in costs["breakdown"]:
                if isinstance(item, dict):
                    try:
                        item["amount"] = float(
                            str(item.get("amount", 0)).replace(" TND", "").strip() or 0
                        )
                    except (ValueError, TypeError):
                        item["amount"] = 0.0
                    item.setdefault("label", "Frais")

    # ── Office ─────────────────────────────────────────────────────────────────
    if not isinstance(data.get("office"), dict):
        data["office"] = {
            "name": "Administration compétente",
            "address": None,
            "hours": None,
            "phone": None,
        }
    else:
        office = data["office"]
        office.setdefault("name", "Administration compétente")
        office.setdefault("address", None)
        office.setdefault("hours", None)
        office.setdefault("phone", None)

    # ── Warnings ───────────────────────────────────────────────────────────────
    if not isinstance(data.get("warnings"), list):
        data["warnings"] = []

    # ── Type ───────────────────────────────────────────────────────────────────
    data["type"] = "procedure_guide"

    return data


def validate_gemini_response(
    raw: str,
) -> Union[ProcedureGuideResponse, ErrorResponse]:
    """
    Attempt to parse and validate a raw JSON string from Gemini.

    Pipeline:
    1. Strip accidental markdown fences (```json ... ```)
    2. Parse as JSON
    3. Repair missing / malformed fields with safe defaults
    4. Validate against ProcedureGuideResponse
    5. Return FALLBACK_ERROR only if JSON itself is unparseable

    Returns ProcedureGuideResponse on success, ErrorResponse on failure.
    """
    # ── Strip markdown code fences if Gemini wrapped the JSON ─────────────────
    cleaned = raw.strip()
    if cleaned.startswith("```"):
        lines = cleaned.splitlines()
        lines = [ln for ln in lines if not ln.strip().startswith("```")]
        cleaned = "\n".join(lines).strip()

    # ── JSON parse ─────────────────────────────────────────────────────────────
    try:
        data = json.loads(cleaned)
    except json.JSONDecodeError as exc:
        logger.error(
            "Gemini returned invalid JSON",
            error=str(exc),
            raw_preview=raw[:400],
        )
        return FALLBACK_ERROR

    # ── Repair partial response ────────────────────────────────────────────────
    if not isinstance(data, dict):
        logger.error("Gemini JSON root must be an object", root_type=type(data).__name__)
        return FALLBACK_ERROR

    if data.get("type", "procedure_guide") != "procedure_guide":
        logger.error("Gemini JSON has an unsupported response type", response_type=data.get("type"))
        return FALLBACK_ERROR

    if "steps" not in data:
        logger.error("Gemini JSON is missing required steps")
        return FALLBACK_ERROR

    data = _repair_data(data)

    # ── Pydantic validation (should pass after repair) ─────────────────────────
    try:
        result = ProcedureGuideResponse.model_validate(data)
        logger.debug(
            "Gemini response validated successfully",
            title_fr=result.title.fr,
            steps_count=len(result.steps),
        )
        return result
    except ValidationError as exc:
        logger.error(
            "Gemini JSON failed Pydantic validation even after repair",
            errors=exc.errors(),
            repaired_preview=str(data)[:400],
        )
        return FALLBACK_ERROR
