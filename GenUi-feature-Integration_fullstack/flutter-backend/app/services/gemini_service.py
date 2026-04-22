"""
services/gemini_service.py - OpenRouter AI integration.

The module name is kept for compatibility with the existing route imports.
"""

import asyncio
from typing import List, Optional

import httpx

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)

_OPENROUTER_TIMEOUT_SECONDS = 90.0

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
    Construct the full structured-output prompt.

    Supports two modes:
    - Grounded mode: context chunks from ChromaDB are available.
    - General knowledge mode: no chunks, so the model uses its own knowledge
      about Tunisian government procedures.
    """
    language_names = {"ar": "Arabic", "fr": "French", "en": "English"}
    language_name = language_names.get(language, "French")

    if context_chunks:
        context_parts = []
        for i, chunk in enumerate(context_chunks, start=1):
            source = chunk.get("metadata", {}).get("source_id", "unknown")
            context_parts.append(
                f"--- Context Chunk {i} (source: {source}) ---\n{chunk['text']}\n"
            )
        context_block = "\n".join(context_parts)

        return f"""You are a precise structured data formatter for Sahil, a Tunisian government procedures guide app.

STRICT RULES:
1. Return ONLY valid JSON. No markdown fences, no explanations, no comments.
2. Use ONLY the information in the CONTEXT CHUNKS below. Do NOT invent data.
3. Preserve exact fees, document names, and office names from the context.
4. If a field lacks context, use null or an empty array. Never make up values.
5. The "title" field MUST have "ar", "fr", AND "en" translations simultaneously.
6. All other text fields (steps, documents, warnings) use language: {language_name}.
7. The "type" field MUST always be "procedure_guide".
8. Provide at least 3 concrete, actionable procedural steps when context allows.
9. Set "source" from context metadata; set "last_verified" only if present in context.
10. The "costs.total" and "costs.breakdown[].amount" MUST be numbers, not strings.
11. Answer the exact USER QUESTION. Do not switch to a related but different procedure.

USER QUESTION:
{user_message}

CONTEXT CHUNKS (authoritative; use only these):
{context_block}

OUTPUT SCHEMA:
{_JSON_SCHEMA}

Return ONLY the JSON object:"""

    return f"""You are Sahil, an expert assistant on Tunisian government administration procedures.
You will answer a question about official Tunisian administrative procedures based on your training knowledge.

CRITICAL RULES:
1. Return ONLY valid JSON matching the schema below. No markdown, no code fences.
2. Provide accurate, helpful information about Tunisian administrative procedures.
3. You MAY use your general knowledge about Tunisian bureaucracy: ATTT, CNSS, RNE, ministries, municipalities, and similar offices.
4. Be honest: if something varies by region or situation, mention it in "warnings".
5. The "title" field MUST have "ar", "fr", AND "en" translations simultaneously.
6. All other text fields (steps, documents, warnings) use language: {language_name}.
7. The "type" field MUST always be "procedure_guide".
8. Give at least 3 clear, actionable steps with real office names when possible.
9. Estimate fees in TND when known; use 0 and note uncertainty in warnings if unknown.
10. The "costs.total" and "costs.breakdown[].amount" MUST be numbers, not strings.
11. Set "source" to "Sahil AI Knowledge Base" and "last_verified" to null.
12. Answer the exact USER QUESTION. Do not switch to a related but different procedure.

USER QUESTION:
{user_message}

OUTPUT SCHEMA:
{_JSON_SCHEMA}

Return ONLY the JSON object now:"""


def _build_headers() -> dict[str, str]:
    if not settings.OPENROUTER_API_KEY:
        raise RuntimeError("OPENROUTER_API_KEY is not configured")

    headers = {
        "Authorization": f"Bearer {settings.OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
        "X-OpenRouter-Title": settings.OPENROUTER_APP_TITLE,
    }
    if settings.OPENROUTER_SITE_URL:
        headers["HTTP-Referer"] = settings.OPENROUTER_SITE_URL
    return headers


def _build_payload(prompt: str) -> dict:
    payload = {
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.1,
        "top_p": 0.95,
        "max_tokens": 4096,
        "response_format": {"type": "json_object"},
    }
    if settings.OPENROUTER_MODEL:
        payload["model"] = settings.OPENROUTER_MODEL
    return payload


def _extract_response_text(data: dict) -> str:
    choices = data.get("choices")
    if not choices:
        raise RuntimeError("OpenRouter returned no choices")

    choice = choices[0]
    if choice.get("error"):
        message = choice["error"].get("message", "Unknown OpenRouter choice error")
        raise RuntimeError(message)

    message = choice.get("message") or {}
    content = message.get("content")
    if isinstance(content, str) and content.strip():
        return content.strip()

    text = choice.get("text")
    if isinstance(text, str) and text.strip():
        return text.strip()

    raise RuntimeError("OpenRouter returned an empty response")


async def generate_procedure_response(
    user_message: str,
    context_chunks: List[dict],
    language: str = "fr",
    max_retries: int = 3,
) -> str:
    """
    Call OpenRouter with the constructed prompt and return the raw JSON text.

    Implements exponential backoff retry for transient API failures.
    Works in both grounded (RAG) and general-knowledge modes.
    """
    prompt = build_prompt(user_message, context_chunks, language)
    mode = "grounded" if context_chunks else "general-knowledge"

    logger.info(
        "Calling OpenRouter",
        mode=mode,
        model=settings.OPENROUTER_MODEL or "user-default",
        context_chunks=len(context_chunks),
        language=language,
        query_preview=user_message[:80],
    )

    last_error: Optional[Exception] = None

    for attempt in range(max_retries + 1):
        try:
            async with httpx.AsyncClient(timeout=_OPENROUTER_TIMEOUT_SECONDS) as client:
                response = await client.post(
                    f"{settings.OPENROUTER_BASE_URL.rstrip('/')}/chat/completions",
                    headers=_build_headers(),
                    json=_build_payload(prompt),
                )
                response.raise_for_status()

            raw_text = _extract_response_text(response.json())
            logger.debug(
                "OpenRouter response received",
                attempt=attempt,
                mode=mode,
                response_length=len(raw_text),
            )
            return raw_text

        except Exception as exc:
            last_error = exc
            wait_time = 2 ** attempt
            logger.warning(
                "OpenRouter API error; retrying",
                attempt=attempt,
                max_retries=max_retries,
                error=str(exc),
                wait_seconds=wait_time,
            )
            if attempt < max_retries:
                await asyncio.sleep(wait_time)

    logger.error("OpenRouter API failed after all retries", error=str(last_error))
    raise RuntimeError(
        f"OpenRouter API unavailable after {max_retries + 1} attempts: {last_error}"
    )
