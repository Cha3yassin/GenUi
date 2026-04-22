"""
services/gemini_service.py — Gemini AI Integration

Responsibilities:
- Build strict structured prompts for Gemini 1.5 Flash
- Call Gemini asynchronously with retry logic
- Return the raw text response for downstream validation
- Support both RAG-grounded and general-knowledge modes
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
                temperature=0.1,        # Very low – factual but not fully deterministic
                top_p=0.95,
                top_k=40,
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
    "hours": "...",
    "phone": null
  },
  "warnings": ["..."],
  "source": "...",
  "last_verified": null
}"""


def build_prompt(
    user_message: str,
    context_chunks: List[dict],
    language: str = "fr",
) -> str:
    """
    Construct the full Gemini prompt.

    Supports two modes:
    - Grounded mode: context chunks from ChromaDB are available
    - General knowledge mode: no chunks, Gemini uses its own knowledge
      about Tunisian government procedures

    Args:
        user_message: The original user question.
        context_chunks: List of RAG-retrieved chunks (text + metadata).
        language: ISO 639-1 language code for the response.

    Returns:
        A formatted prompt string ready for Gemini.
    """
    language_names = {"ar": "Arabic", "fr": "French", "en": "English"}
    language_name = language_names.get(language, "French")

    has_context = len(context_chunks) > 0

    if has_context:
        # ── Grounded mode: use only RAG context ──────────────────────────────
        context_parts = []
        for i, chunk in enumerate(context_chunks, start=1):
            source = chunk.get("metadata", {}).get("source_id", "unknown")
            context_parts.append(
                f"--- Context Chunk {i} (source: {source}) ---\n{chunk['text']}\n"
            )
        context_block = "\n".join(context_parts)

        prompt = f"""You are a precise structured data formatter for Sahil — a Tunisian government procedures guide app.

STRICT RULES:
1. Return ONLY valid JSON. No markdown fences, no explanations, no comments.
2. Use ONLY the information in the CONTEXT CHUNKS below. Do NOT invent data.
3. Preserve exact fees, document names, and office names from the context.
4. If a field lacks context, use null or an empty array — never make up values.
5. The "title" field MUST have "ar", "fr", AND "en" translations simultaneously.
6. All other text fields (steps, documents, warnings) use language: {language_name}.
7. The "type" field MUST always be "procedure_guide".
8. Provide at least 3 concrete, actionable procedural steps when context allows.
9. Set "source" from context metadata; set "last_verified" only if present in context.
10. The "costs.total" and "costs.breakdown[].amount" MUST be numbers (floats), not strings.

USER QUESTION:
{user_message}

CONTEXT CHUNKS (authoritative — use only these):
{context_block}

OUTPUT SCHEMA:
{_JSON_SCHEMA}

Return ONLY the JSON object:"""

    else:
        # ── General knowledge mode: Gemini knows Tunisian procedures ─────────
        prompt = f"""You are Sahil, an expert assistant on Tunisian government (administration) procedures.
You will answer a question about official Tunisian administrative procedures based on your training knowledge.

CRITICAL RULES:
1. Return ONLY valid JSON matching the schema below. No markdown, no code fences.
2. Provide accurate, helpful information about Tunisian administrative procedures.
3. You MAY use your general knowledge about Tunisian bureaucracy (ATTT, CNSS, RNE, Ministries, etc.).
4. Be honest: if something varies by region or situation, mention it in "warnings".
5. The "title" field MUST have "ar", "fr", AND "en" translations simultaneously.
6. All other text fields (steps, documents, warnings) use language: {language_name}.
7. The "type" field MUST always be "procedure_guide".
8. Give at least 3 clear, actionable steps with real office names (ATTT, RNE, CNSS, etc.).
9. Estimate fees in TND when known; use 0 and note uncertainty in warnings if unknown.
10. The "costs.total" and "costs.breakdown[].amount" MUST be numbers (floats), not strings.
11. Set "source" to "Sahil AI Knowledge Base" and "last_verified" to null.

USER QUESTION:
{user_message}

OUTPUT SCHEMA (return JSON matching this exact shape):
{_JSON_SCHEMA}

Return ONLY the JSON object now:"""

    return prompt


# ── Gemini API Call ────────────────────────────────────────────────────────────

async def generate_procedure_response(
    user_message: str,
    context_chunks: List[dict],
    language: str = "fr",
    max_retries: int = 3,
) -> str:
    """
    Call Gemini with the constructed prompt and return the raw text response.

    Implements exponential back-off retry for transient API failures.
    Works in both grounded (RAG) and general-knowledge modes.

    Args:
        user_message: Original user question.
        context_chunks: Retrieved RAG context (may be empty list).
        language: Preferred response language.
        max_retries: Number of retry attempts on transient errors.

    Returns:
        Raw string from Gemini (expected to be JSON).

    Raises:
        RuntimeError: If all retries are exhausted.
    """
    model = _get_model()
    prompt = build_prompt(user_message, context_chunks, language)
    mode = "grounded" if context_chunks else "general-knowledge"

    logger.info(
        "Calling Gemini",
        mode=mode,
        context_chunks=len(context_chunks),
        language=language,
        query_preview=user_message[:80],
    )

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
                mode=mode,
                response_length=len(raw_text),
            )
            return raw_text

        except Exception as exc:
            last_error = exc
            wait_time = 2 ** attempt  # 1s, 2s, 4s, 8s ...
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
