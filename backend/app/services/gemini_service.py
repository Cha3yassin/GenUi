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
    role: Optional[str] = None,
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

        role_context = _build_role_context(role)

        return f"""You are a precise structured data formatter for Fbureaucracy, a Tunisian government procedures guide app.
{role_context}

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

    role_context = _build_role_context(role)

    return f"""You are Fbureaucracy, an expert assistant on Tunisian government administration procedures.
You will answer a question about official Tunisian administrative procedures based on your training knowledge.
{role_context}

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
11. Set "source" to "Fbureaucracy AI Knowledge Base" and "last_verified" to null.
12. Answer the exact USER QUESTION. Do not switch to a related but different procedure.

USER QUESTION:
{user_message}

OUTPUT SCHEMA:
{_JSON_SCHEMA}

Return ONLY the JSON object now:"""


def _build_role_context(role: Optional[str]) -> str:
    """Return a one-line role context string for the LLM prompt."""
    if role == "enterprise":
        return "USER CONTEXT: The user is a business/enterprise owner asking about corporate procedures.\n"
    elif role == "individual":
        return "USER CONTEXT: The user is an individual citizen asking about personal administrative procedures.\n"
    return ""


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


def _build_quiz_payload(prompt: str) -> dict:
    payload = _build_payload(prompt)
    payload["temperature"] = 0.75
    payload["top_p"] = 0.9
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
    role: Optional[str] = None,
    max_retries: int = 3,
) -> str:
    """
    Call OpenRouter with the constructed prompt and return the raw JSON text.

    Implements exponential backoff retry for transient API failures.
    Works in both grounded (RAG) and general-knowledge modes.
    """
    prompt = build_prompt(user_message, context_chunks, language, role=role)
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

import json

_QUIZ_SCHEMA = """{
  "type": "quiz_widget",
  "title": "...",
  "subtitle": "...",
  "topic": "...",
  "language": "fr",
  "questions": [
    {
      "prompt": "...",
      "options": [{"text": "..."}, {"text": "..."}, {"text": "..."}],
      "correct_index": 1,
      "explanation": "..."
    }
  ],
  "result_bands": [
    {
      "min_score": 0,
      "title": "...",
      "message": "...",
      "blocks": [
        {"type": "section_title", "data": {"title": "...", "subtitle": "..."}},
        {"type": "info_card", "data": {"title": "...", "body": "- ...\\n- ...", "icon": "shield"}},
        {"type": "checklist", "data": {"items": [{"title": "...", "note": "...", "required": true}]}}
      ]
    }
  ],
  "source": "OpenRouter AI"
}"""


def build_quiz_prompt(
    topic: str,
    language: str = "fr",
    role: Optional[str] = None,
    difficulty: str = "easy",
    question_count: int = 5,
) -> str:
    language_names = {"ar": "Arabic", "fr": "French", "en": "English"}
    language_name = language_names.get(language, "French")
    role_context = _build_role_context(role)

    return f"""You are the GenUI generator for f-idarty, a Tunisian administration guide app.
Generate an interactive quiz widget plan that Flutter can render directly.
{role_context}

STRICT RULES:
1. Return ONLY valid JSON. No markdown fences, no comments, no prose outside JSON.
2. The top-level "type" MUST be "quiz_widget".
3. Write all user-facing text in {language_name}.
4. Generate exactly {question_count} questions.
5. Each question MUST have 3 answer options.
6. "correct_index" MUST be 0, 1, or 2 and point to the correct option.
7. Vary correct_index across the quiz. Do not put the correct answer in the same option every time.
8. Keep it practical for Tunisian administrative procedures: documents, offices, fees, copies, appointments, and verification.
9. Do not ask legal trick questions. Make it simple, useful, and beginner-friendly.
10. result_bands must include three bands: min_score 0, min_score 2, min_score 4.
11. The result band "blocks" are GenUI blocks Flutter already knows: section_title, info_card, checklist, faq_list.
12. Checklist items must be objects with title, note, and required.
13. The JSON must match this schema shape:
{_QUIZ_SCHEMA}

TOPIC:
{topic}

DIFFICULTY:
{difficulty}

Return ONLY the JSON object now:"""


async def generate_quiz_widget_response(
    topic: str,
    language: str = "fr",
    role: Optional[str] = None,
    difficulty: str = "easy",
    question_count: int = 5,
    max_retries: int = 2,
) -> str:
    prompt = build_quiz_prompt(
        topic=topic,
        language=language,
        role=role,
        difficulty=difficulty,
        question_count=question_count,
    )

    logger.info(
        "Calling OpenRouter for quiz widget",
        model=settings.OPENROUTER_MODEL or "user-default",
        language=language,
        question_count=question_count,
        topic_preview=topic[:80],
    )

    last_error: Optional[Exception] = None
    for attempt in range(max_retries + 1):
        try:
            async with httpx.AsyncClient(timeout=_OPENROUTER_TIMEOUT_SECONDS) as client:
                response = await client.post(
                    f"{settings.OPENROUTER_BASE_URL.rstrip('/')}/chat/completions",
                    headers=_build_headers(),
                    json=_build_quiz_payload(prompt),
                )
                response.raise_for_status()

            raw_text = _extract_response_text(response.json())
            logger.debug(
                "OpenRouter quiz response received",
                attempt=attempt,
                response_length=len(raw_text),
            )
            return raw_text
        except Exception as exc:
            last_error = exc
            logger.warning(
                "OpenRouter quiz API error; retrying",
                attempt=attempt,
                max_retries=max_retries,
                error=str(exc),
            )
            if attempt < max_retries:
                await asyncio.sleep(2 ** attempt)

    raise RuntimeError(
        f"OpenRouter quiz generation unavailable after {max_retries + 1} attempts: {last_error}"
    )

async def check_administrative_intent(query: str, max_retries: int = 1) -> bool:
    prompt = f"""You are an intent classifier for a Tunisian government services app.
Does this query relate to a Tunisian administrative procedure, legal document, business creation, or government service?
Query: "{query}"
Reply strictly with valid JSON: {{"is_administrative": true}} or {{"is_administrative": false}}"""
    
    logger.info("Classifying administrative intent", query=query[:80])
    last_error: Optional[Exception] = None
    
    for attempt in range(max_retries + 1):
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.post(
                    f"{settings.OPENROUTER_BASE_URL.rstrip('/')}/chat/completions",
                    headers=_build_headers(),
                    json={
                        "messages": [{"role": "user", "content": prompt}],
                        "temperature": 0.0,
                        "max_tokens": 20,
                        "response_format": {"type": "json_object"},
                        "model": settings.OPENROUTER_MODEL,
                    },
                )
                response.raise_for_status()
            
            raw_text = _extract_response_text(response.json())
            data = json.loads(raw_text)
            return bool(data.get("is_administrative", True))
        except Exception as exc:
            last_error = exc
            if attempt < max_retries:
                await asyncio.sleep(1)
    
    logger.warning("Intent classification failed, defaulting to True", error=str(last_error))
    return True

