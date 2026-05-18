"""
tests/test_validators.py — Gemini Response Validator Unit Tests
"""

import json
import pytest

from app.utils.validators import validate_gemini_response
from app.schemas.responses import ProcedureGuideResponse, ErrorResponse


VALID_PAYLOAD = {
    "type": "procedure_guide",
    "title": {"ar": "شهادة", "fr": "Titre", "en": "Title"},
    "steps": [
        {
            "number": 1,
            "title": "Go to office",
            "description": "Bring your ID card.",
            "location": "Sfax Municipality",
        }
    ],
    "documents": ["CIN"],
    "costs": {"total": 0.6, "currency": "TND", "breakdown": []},
    "office": {"name": "Municipalité de Sfax", "address": "Sfax", "hours": "8h-16h"},
    "warnings": [],
    "source": "test",
    "last_verified": "2024-01-15",
}


def test_validate_valid_json():
    """Valid JSON matching the schema returns ProcedureGuideResponse."""
    result = validate_gemini_response(json.dumps(VALID_PAYLOAD))
    assert isinstance(result, ProcedureGuideResponse)
    assert result.type == "procedure_guide"
    assert result.costs.currency == "TND"


def test_validate_invalid_json_string():
    """Non-JSON input returns ErrorResponse."""
    result = validate_gemini_response("not json at all")
    assert isinstance(result, ErrorResponse)
    assert result.type == "error"


def test_validate_missing_required_field():
    """JSON missing required 'steps' returns ErrorResponse."""
    bad_payload = {**VALID_PAYLOAD}
    del bad_payload["steps"]
    result = validate_gemini_response(json.dumps(bad_payload))
    assert isinstance(result, ErrorResponse)


def test_validate_strips_markdown_fences():
    """Gemini sometimes wraps JSON in markdown fences — validator strips them."""
    wrapped = f"```json\n{json.dumps(VALID_PAYLOAD)}\n```"
    result = validate_gemini_response(wrapped)
    assert isinstance(result, ProcedureGuideResponse)


def test_validate_empty_string():
    """Empty string returns ErrorResponse."""
    result = validate_gemini_response("")
    assert isinstance(result, ErrorResponse)


def test_validate_wrong_type_field():
    """'type' field value other than 'procedure_guide' fails validation."""
    bad = {**VALID_PAYLOAD, "type": "something_else"}
    result = validate_gemini_response(json.dumps(bad))
    assert isinstance(result, ErrorResponse)
