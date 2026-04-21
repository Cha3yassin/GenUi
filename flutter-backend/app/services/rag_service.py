"""
services/rag_service.py — Retrieval-Augmented Generation (RAG) Service

Responsibilities:
- Chunk raw text documents into 500-token segments
- Embed each chunk using Google text-embedding-004
- Persist embeddings in ChromaDB
- Perform semantic similarity search to retrieve relevant context
"""

import asyncio
import uuid
from typing import List, Optional

import chromadb
import tiktoken
from chromadb.config import Settings as ChromaSettings

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)

# ── Tokeniser ─────────────────────────────────────────────────────────────────

# cl100k_base is compatible with most modern embedding models
_TOKENISER = tiktoken.get_encoding("cl100k_base")


def _count_tokens(text: str) -> int:
    return len(_TOKENISER.encode(text))


# ── ChromaDB Client Singleton ──────────────────────────────────────────────────

_chroma_client: Optional[chromadb.PersistentClient] = None
_collection: Optional[chromadb.Collection] = None


def _get_chroma_collection() -> chromadb.Collection:
    """
    Lazily initialise the ChromaDB persistent client and collection.
    Thread-safe because Python's GIL protects simple assignment.
    """
    global _chroma_client, _collection
    if _collection is not None:
        return _collection

    _chroma_client = chromadb.PersistentClient(
        path=settings.CHROMA_PERSIST_DIRECTORY,
        settings=ChromaSettings(anonymized_telemetry=False),
    )
    _collection = _chroma_client.get_or_create_collection(
        name=settings.CHROMA_COLLECTION_NAME,
        metadata={"hnsw:space": "cosine"},  # Cosine distance for text similarity
    )
    logger.info(
        "ChromaDB collection ready",
        collection=settings.CHROMA_COLLECTION_NAME,
        path=settings.CHROMA_PERSIST_DIRECTORY,
    )
    return _collection


# ── Embedding ─────────────────────────────────────────────────────────────────

async def embed_text(text: str) -> List[float]:
    """
    Generate a dense vector embedding for the given text using
    Google's text-embedding-004 model via the Generative AI SDK.

    Runs the blocking SDK call in a thread pool to stay non-blocking.
    """
    import google.generativeai as genai

    genai.configure(api_key=settings.GOOGLE_API_KEY)

    loop = asyncio.get_event_loop()
    result = await loop.run_in_executor(
        None,
        lambda: genai.embed_content(
            model=settings.EMBEDDING_MODEL,
            content=text,
            task_type="retrieval_document",
        ),
    )
    return result["embedding"]


# ── Chunking ──────────────────────────────────────────────────────────────────

def chunk_text(
    text: str,
    chunk_size: int = None,
    overlap: int = None,
) -> List[str]:
    """
    Split text into overlapping token-based chunks.

    Args:
        text: The source document text.
        chunk_size: Maximum tokens per chunk (default from settings).
        overlap: Number of tokens to overlap between chunks (default from settings).

    Returns:
        List of text chunk strings.
    """
    chunk_size = chunk_size or settings.RAG_CHUNK_SIZE
    overlap = overlap or settings.RAG_CHUNK_OVERLAP

    tokens = _TOKENISER.encode(text)
    chunks: List[str] = []

    start = 0
    while start < len(tokens):
        end = min(start + chunk_size, len(tokens))
        chunk_tokens = tokens[start:end]
        chunk_text_str = _TOKENISER.decode(chunk_tokens)
        chunks.append(chunk_text_str)

        if end == len(tokens):
            break
        start += chunk_size - overlap  # Move forward with overlap

    logger.debug(
        "Text chunked",
        total_tokens=len(tokens),
        num_chunks=len(chunks),
        chunk_size=chunk_size,
        overlap=overlap,
    )
    return chunks


# ── Ingestion ─────────────────────────────────────────────────────────────────

async def ingest_documents(
    documents: List[dict],
    *,
    reset_collection: bool = False,
) -> int:
    """
    Ingest a list of document dicts into ChromaDB.

    Each document dict must have:
        - "text": str  — the raw document text
        - "metadata": dict  — arbitrary metadata (source, category, etc.)

    Args:
        documents: List of document dicts.
        reset_collection: If True, wipe the collection before ingestion.

    Returns:
        Total number of chunks ingested.
    """
    collection = _get_chroma_collection()

    if reset_collection:
        logger.warning("Resetting ChromaDB collection before ingestion.")
        _chroma_client.delete_collection(settings.CHROMA_COLLECTION_NAME)
        # Re-create
        global _collection
        _collection = _chroma_client.get_or_create_collection(
            name=settings.CHROMA_COLLECTION_NAME,
            metadata={"hnsw:space": "cosine"},
        )
        collection = _collection

    total_chunks = 0
    for doc in documents:
        text: str = doc["text"]
        metadata: dict = doc.get("metadata", {})
        source_id: str = metadata.get("source_id", str(uuid.uuid4()))

        chunks = chunk_text(text)
        logger.info(
            "Ingesting document",
            source_id=source_id,
            num_chunks=len(chunks),
        )

        for i, chunk in enumerate(chunks):
            chunk_id = f"{source_id}_chunk_{i}"
            embedding = await embed_text(chunk)
            chunk_meta = {**metadata, "chunk_index": i, "chunk_id": chunk_id}

            collection.upsert(
                ids=[chunk_id],
                embeddings=[embedding],
                documents=[chunk],
                metadatas=[chunk_meta],
            )
            total_chunks += 1

    logger.info("Ingestion complete", total_chunks=total_chunks)
    return total_chunks


# ── Retrieval ─────────────────────────────────────────────────────────────────

async def search_similar_chunks(
    query: str,
    top_k: int = None,
    category_filter: Optional[str] = None,
) -> List[dict]:
    """
    Embed the query and retrieve the most semantically relevant document chunks.

    Args:
        query: User's natural-language question.
        top_k: Number of chunks to return (default from settings).
        category_filter: If provided, limits results to this category slug.

    Returns:
        List of dicts with keys: "text", "metadata", "distance".
    """
    top_k = top_k or settings.RAG_TOP_K
    collection = _get_chroma_collection()

    query_embedding = await embed_text(query)

    # Build optional where clause for category filtering
    where_clause = None
    if category_filter:
        where_clause = {"category": {"$eq": category_filter}}

    results = collection.query(
        query_embeddings=[query_embedding],
        n_results=top_k,
        where=where_clause,
        include=["documents", "metadatas", "distances"],
    )

    chunks = []
    if results and results.get("documents"):
        docs = results["documents"][0]
        metas = results["metadatas"][0]
        distances = results["distances"][0]

        for doc, meta, dist in zip(docs, metas, distances):
            chunks.append(
                {
                    "text": doc,
                    "metadata": meta,
                    "distance": round(dist, 4),
                }
            )

    logger.debug(
        "RAG search complete",
        query=query[:80],
        results_found=len(chunks),
        top_k=top_k,
    )
    return chunks
