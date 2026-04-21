"""
services/gemini_service.py — Gemini AI Integration

Responsibilities:
- Build strict structured prompts for Gemini 1.5 Flash
- Call Gemini asynchronously with retry logic
- Return the raw text response for downstream validation
"""

import asyncio
import json
from typing import List, Optional

import google.generativeai as genai
from google.generativeai.types import GenerateContentResponse

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)

# ── Gemini Client Setup ────────────────────────────────────────────────────────

_model: Optional[genai.GenerativeModel] = None


def _get_model() -> genai.GenerativeModel:
    """Lazily initialise and cache the Gemini GenerativeModel."""
    global _model
    if _model is None:
        genai.configure(api_key=settings.GOOGLE_API_KEY)
        _model = genai.GenerativeModel(
            model_name=settings.GEMINI_MODEL,
            generation_config=genai.GenerationConfig(
                temperature=0.0,        # Zero temperature — deterministic, factual
                top_p=1.0,
                top_k=1,
                max_output_tokens=4096,
                response_mime_type="application/json",  # Force JSON output
            ),
        )
        logger.info("Gemini model initialised", model=settings.GEMINI_MODEL)
    return _model


# ── Prompt Building ────────────────────────────────────────────────────────────

_JSON_SCHEMA = """{
  "type": "procedure_guide",
  "title": {"ar": "...", "fr": "...", "en": "..."},
  "steps": [
    {
      "number": 1,
      "title": "...",
      "description": "...",
      "location": "..."
    }
  ],
  "documents": ["..."],
  "costs": {
    "total": 0,
    "currency": "TND",
    "breakdown": [{"label": "...", "amount": 0}]
  },
  "office": {
    "name": "...",
    "address": "...",
    "hours": "..."
  },
  "warnings": ["..."],
  "source": "...",
  "last_verified": "..."
}"""


def build_prompt(
    user_message: str,
    context_chunks: List[dict],
    language: str = "fr",
) -> str:
    """
    Construct the full Gemini prompt.

    Design principles:
    - Context is injected first so Gemini stays grounded.
    - Strict rules prevent hallucination.
    - Language instruction ensures the response matches user preference.
    - Exact JSON schema is provided so Gemini knows the output shape.

    Args:
        user_message: The original user question.
        context_chunks: List of RAG-retrieved chunks (text + metadata).
        language: ISO 639-1 language code for the response.

    Returns:
        A formatted prompt string ready for Gemini.
    """
    # Format retrieved context chunks
    context_parts = []
    for i, chunk in enumerate(context_chunks, start=1):
        source = chunk.get("metadata", {}).get("source_id", "unknown")
        context_parts.append(
            f"--- Context Chunk {i} (source: {source}) ---\n{chunk['text']}\n"
        )
    context_block = "\n".join(context_parts) if context_parts else "No relevant context found."

    language_names = {"ar": "Arabic", "fr": "French", "en": "English"}
    language_name = language_names.get(language, "French")

    prompt = f"""You are a structured data formatter for the Fberaucracy app — a Tunisian government procedures guide.

STRICT RULES — FOLLOW EXACTLY:
1. Return ONLY valid JSON. No markdown, no code fences, no explanations.
2. Do NOT invent, hallucinate, or guess any information.
3. Use ONLY the information provided in the CONTEXT CHUNKS below.
4. Preserve exact fees, document names, and office names from the context.
5. If the context does not contain enough information for a field, use null or an empty array.
6. All text values in "title" must be in Arabic, French, AND English simultaneously.
7. All other text fields (steps, documents, warnings) should be in the user's preferred language: {language_name}.
8. The "type" field MUST always be "procedure_guide".
9. Do not output generic placeholders such as "information not available", "N/A", or "unknown".
10. If context supports it, produce at least 3 concrete procedural steps with actionable descriptions.
11. "source" must be set from the context chunk metadata, and "last_verified" should only be set if present in context.

USER QUESTION:
{user_message}

CONTEXT CHUNKS (authoritative source — use only this):
{context_block}

OUTPUT SCHEMA (return JSON matching this exact shape):
{_JSON_SCHEMA}

Return ONLY the JSON object now:"""

    return prompt


# ── Gemini API Call ────────────────────────────────────────────────────────────

async def generate_procedure_response(
    user_message: str,
    context_chunks: List[dict],
    language: str = "fr",
    max_retries: int = 2,
) -> str:
    """
    Call Gemini with the constructed prompt and return the raw text response.

    Implements exponential back-off retry for transient API failures.

    Args:
        user_message: Original user question.
        context_chunks: Retrieved RAG context.
        language: Preferred response language.
        max_retries: Number of retry attempts on transient errors.

    Returns:
        Raw string from Gemini (expected to be JSON).

    Raises:
        RuntimeError: If all retries are exhausted.
    """
    model = _get_model()
    prompt = build_prompt(user_message, context_chunks, language)

    last_error: Optional[Exception] = None

    for attempt in range(max_retries + 1):
        try:
            loop = asyncio.get_event_loop()

            # Run the blocking Gemini SDK call in a thread pool
            response: GenerateContentResponse = await loop.run_in_executor(
                None,
                lambda: model.generate_content(prompt),
            )

            raw_text = response.text.strip()
            logger.debug(
                "Gemini response received",
                attempt=attempt,
                response_length=len(raw_text),
            )
            return raw_text

        except Exception as exc:
            last_error = exc
            wait_time = 2 ** attempt  # 1s, 2s, 4s ...
            logger.warning(
                "Gemini API error — retrying",
                attempt=attempt,
                max_retries=max_retries,
                error=str(exc),
                wait_seconds=wait_time,
            )
            if attempt < max_retries:
                await asyncio.sleep(wait_time)

    logger.error(
        "Gemini API failed after all retries",
        error=str(last_error),
    )
    raise RuntimeError(f"Gemini API unavailable after {max_retries + 1} attempts: {last_error}")
