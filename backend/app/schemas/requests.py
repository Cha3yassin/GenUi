"""
schemas/requests.py — Pydantic Request Schemas

Defines and validates all incoming request payloads from the Flutter app.
"""

from typing import Literal, Optional

from pydantic import BaseModel, Field, field_validator


class ChatRequest(BaseModel):
    """
    Payload for POST /chat and POST /gen-ui/search.

    - message: The user's natural-language question.
    - language: ISO 639-1 code. Controls the response language preference.
    - category: Optional hint that narrows RAG search scope.
    - role: Optional user role for context-aware LLM generation.
    """
    message: str = Field(
        ...,
        min_length=2,
        max_length=1000,
        description="User's question in natural language.",
        examples=["How do I renew my carte grise?"],
    )
    language: Literal["ar", "fr", "en"] = Field(
        default="fr",
        description="Preferred response language.",
    )
    category: Optional[str] = Field(
        default=None,
        max_length=64,
        description="Optional procedure category slug to narrow the search.",
        examples=["vehicles", "civil_status", "taxation"],
    )
    role: Optional[Literal["individual", "enterprise"]] = Field(
        default=None,
        description="User role for context-aware LLM generation.",
    )

    @field_validator("message")
    @classmethod
    def strip_message(cls, v: str) -> str:
        """Remove leading/trailing whitespace from the message."""
        return v.strip()

    @field_validator("category")
    @classmethod
    def normalise_category(cls, v: Optional[str]) -> Optional[str]:
        """Lowercase the category slug for consistent lookups."""
        return v.lower().strip() if v else None

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "message": "How do I renew my carte grise?",
                    "language": "fr",
                    "category": "vehicles",
                    "role": "individual",
                }
            ]
        }
    }


class QuizRequest(BaseModel):
    """
    Payload for POST /gen-ui/quiz.

    The AI generates a small interactive quiz widget plan for Flutter.
    """
    topic: str = Field(
        default="Tunisian administrative procedures",
        min_length=2,
        max_length=240,
        description="Quiz topic or user goal.",
        examples=["Prepare for a Tunisian administrative office visit"],
    )
    language: Literal["ar", "fr", "en"] = Field(
        default="fr",
        description="Preferred quiz language.",
    )
    role: Optional[Literal["individual", "enterprise"]] = Field(
        default=None,
        description="Optional user role for context-aware quiz generation.",
    )
    difficulty: Literal["easy", "medium"] = Field(
        default="easy",
        description="Quiz difficulty.",
    )
    question_count: int = Field(
        default=5,
        ge=3,
        le=8,
        description="Number of quiz questions to generate.",
    )

    @field_validator("topic")
    @classmethod
    def strip_topic(cls, v: str) -> str:
        return v.strip()


class LoginRequest(BaseModel):
    """
    Payload for POST /auth/login.

    Flutter sends the Firebase ID token and the user's selected role.
    """
    id_token: str = Field(
        ...,
        min_length=10,
        description="Firebase ID token from Flutter Google Sign-In.",
    )
    role: Literal["individual", "enterprise"] = Field(
        default="individual",
        description="User's selected role.",
    )
