"""
schemas/responses.py — Pydantic Response Schemas

Defines all structured JSON responses returned to the Flutter frontend.
These schemas also serve as the Gemini output validation layer:
if Gemini's response cannot be parsed into ProcedureGuideResponse,
we return ErrorResponse instead.
"""

import uuid
from datetime import datetime
from typing import Any, Dict, List, Literal, Optional

from pydantic import BaseModel, Field


# ── Sub-models ─────────────────────────────────────────────────────────────────

class MultiLingualText(BaseModel):
    """A text field available in Arabic, French, and English."""
    ar: str = Field(default="", description="Arabic text")
    fr: str = Field(default="", description="French text")
    en: str = Field(default="", description="English text")


class ProcedureStep(BaseModel):
    """A single numbered step in a bureaucratic procedure."""
    number: int = Field(..., ge=1, description="Step sequence number")
    title: str = Field(..., min_length=1, description="Short step title")
    description: str = Field(..., min_length=1, description="Detailed step description")
    location: Optional[str] = Field(
        default=None, description="Physical or online location for this step"
    )


class CostBreakdownItem(BaseModel):
    """A single line in the fee breakdown."""
    label: str = Field(..., description="Description of the fee")
    amount: float = Field(..., ge=0, description="Amount in TND")


class CostInfo(BaseModel):
    """Total cost and optional itemised breakdown."""
    total: float = Field(..., ge=0, description="Total cost in TND")
    currency: Literal["TND"] = Field(default="TND")
    breakdown: List[CostBreakdownItem] = Field(default_factory=list)


class OfficeInfo(BaseModel):
    """The government office responsible for this procedure."""
    name: str = Field(..., description="Official office name")
    address: Optional[str] = Field(default=None, description="Physical address")
    hours: Optional[str] = Field(default=None, description="Opening hours")
    phone: Optional[str] = Field(default=None, description="Contact phone number")


# ── Top-level Response Models ──────────────────────────────────────────────────

class ProcedureGuideResponse(BaseModel):
    """
    Successful structured procedure guide.
    This is the canonical response that Flutter renders dynamically.
    Validated from Gemini's raw JSON output.
    """
    type: Literal["procedure_guide"] = "procedure_guide"
    title: MultiLingualText = Field(..., description="Procedure title in all languages")
    steps: List[ProcedureStep] = Field(..., min_length=1, description="Ordered procedure steps")
    documents: List[str] = Field(
        default_factory=list, description="Required documents list"
    )
    costs: CostInfo = Field(..., description="Fee information")
    office: OfficeInfo = Field(..., description="Responsible government office")
    warnings: List[str] = Field(
        default_factory=list, description="Important warnings or notes"
    )
    source: Optional[str] = Field(
        default=None, description="Source document or reference"
    )
    last_verified: Optional[str] = Field(
        default=None, description="Date this information was last verified"
    )

    model_config = {"populate_by_name": True}


class ErrorResponse(BaseModel):
    """
    Returned when Gemini's output fails validation or any processing error occurs.
    Flutter should render this as a friendly error card.
    """
    type: Literal["error"] = "error"
    message: str = Field(
        default="Unable to generate procedure safely.",
        description="Human-readable error description",
    )
    code: Optional[str] = Field(
        default=None, description="Machine-readable error code"
    )


# ── Category Response ──────────────────────────────────────────────────────────

class CategoryResponse(BaseModel):
    """A single procedure category for the categories listing endpoint."""
    id: str = Field(..., description="Category slug used as identifier")
    name_ar: str = Field(..., description="Arabic category name")
    name_fr: str = Field(..., description="French category name")
    name_en: str = Field(..., description="English category name")
    icon: str = Field(..., description="Icon identifier for Flutter rendering")


# ── Chat History Response ──────────────────────────────────────────────────────

class ChatHistoryItem(BaseModel):
    """A single chat exchange in the history list."""
    id: uuid.UUID
    user_message: str
    ai_response: Dict[str, Any]   # Parsed JSON so Flutter doesn't double-decode
    created_at: datetime

    model_config = {"from_attributes": True}


class ChatHistoryResponse(BaseModel):
    """Paginated chat history for a user."""
    user_id: uuid.UUID
    total: int
    items: List[ChatHistoryItem]


# ── Task Queue Response Models ─────────────────────────────────────────────────

class TaskAcceptedResponse(BaseModel):
    """Returned (HTTP 202) when a cache miss triggers a background Celery task."""
    status: Literal["processing"] = "processing"
    task_id: str = Field(..., description="Celery task ID for polling")


class TaskStatusResponse(BaseModel):
    """Returned by the polling endpoint to report background task progress."""
    status: Literal["processing", "complete", "failed"]
    task_id: str = Field(..., description="Celery task ID")
    result: Optional[Dict[str, Any]] = Field(
        default=None,
        description="Validated procedure JSON — present only when status == 'complete'",
    )
    error: Optional[str] = Field(
        default=None,
        description="Human-readable error — present only when status == 'failed'",
    )
