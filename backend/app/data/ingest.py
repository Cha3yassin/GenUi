"""
data/ingest.py — Document Ingestion Script

Reads raw procedure documents from app/data/raw/, chunks them, embeds
them with Google text-embedding-004, and stores them in ChromaDB.

Usage:
    python -m app.data.ingest
    python -m app.data.ingest --reset   (wipe collection before ingestion)
    python -m app.data.ingest --dry-run (show chunks without ingesting)

This script is idempotent — documents are upserted by their chunk ID,
so running it multiple times will not create duplicates.
"""

import argparse
import asyncio
import os
import sys
from pathlib import Path

# Ensure the backend root is on sys.path when running as a script
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

# Load environment variables before importing app modules
from dotenv import load_dotenv
load_dotenv(ROOT / ".env")

from app.core.config import settings
from app.core.logging import get_logger, setup_logging
from app.services.rag_service import ingest_documents

setup_logging()
logger = get_logger(__name__)

# ── Raw Document Registry ─────────────────────────────────────────────────────
# Each entry maps a filename to its metadata.
# Add new documents here when expanding the knowledge base.

RAW_DIR = Path(__file__).parent / "raw"

DOCUMENT_REGISTRY: list[dict] = [
    {
        "filename": "extrait_naissance_sfax.txt",
        "metadata": {
            "source_id": "extrait_naissance_sfax",
            "category": "civil_status",
            "region": "sfax",
            "language": "fr",
            "title_fr": "Extrait de Naissance",
            "title_ar": "شهادة الميلاد",
            "title_en": "Birth Certificate",
        },
    },
    {
        "filename": "carte_grise_sfax.txt",
        "metadata": {
            "source_id": "carte_grise_sfax",
            "category": "vehicles",
            "region": "sfax",
            "language": "fr",
            "title_fr": "Carte Grise (Certificat d'Immatriculation)",
            "title_ar": "بطاقة رمادية",
            "title_en": "Vehicle Registration Certificate",
        },
    },
    {
        "filename": "attestation_residence_sfax.txt",
        "metadata": {
            "source_id": "attestation_residence_sfax",
            "category": "residence",
            "region": "sfax",
            "language": "fr",
            "title_fr": "Attestation de Résidence",
            "title_ar": "شهادة الإقامة",
            "title_en": "Proof of Residence",
        },
    },
]


async def load_documents(dry_run: bool = False) -> list[dict]:
    """
    Read all registered raw documents from disk.
    Returns a list of document dicts ready for ingestion.
    """
    docs = []
    for entry in DOCUMENT_REGISTRY:
        filepath = RAW_DIR / entry["filename"]
        if not filepath.exists():
            logger.warning("File not found — skipping", path=str(filepath))
            continue

        text = filepath.read_text(encoding="utf-8")
        docs.append({"text": text, "metadata": entry["metadata"]})
        logger.info(
            "Loaded document",
            filename=entry["filename"],
            chars=len(text),
            category=entry["metadata"]["category"],
        )

        if dry_run:
            # In dry-run mode, preview chunks without embedding
            from app.services.rag_service import chunk_text
            chunks = chunk_text(text)
            logger.info(
                "DRY RUN — chunks preview",
                filename=entry["filename"],
                num_chunks=len(chunks),
                first_chunk_preview=chunks[0][:200] if chunks else "",
            )

    return docs


async def main(reset: bool = False, dry_run: bool = False) -> None:
    """
    Main ingestion routine.

    Args:
        reset: Wipe the ChromaDB collection before ingesting.
        dry_run: Load and chunk documents but do NOT embed or store.
    """
    logger.info(
        "Starting document ingestion",
        reset=reset,
        dry_run=dry_run,
        chroma_dir=settings.CHROMA_PERSIST_DIRECTORY,
        collection=settings.CHROMA_COLLECTION_NAME,
    )

    documents = await load_documents(dry_run=dry_run)

    if not documents:
        logger.error("No documents loaded. Check the data/raw/ directory.")
        sys.exit(1)

    if dry_run:
        logger.info("Dry run complete — no data written to ChromaDB.")
        return

    total = await ingest_documents(documents, reset_collection=reset)
    logger.info("Ingestion complete", total_chunks_stored=total)


# ── CLI Entrypoint ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Fberaucracy — Ingest procedure documents into ChromaDB"
    )
    parser.add_argument(
        "--reset",
        action="store_true",
        help="Delete all existing vectors before ingesting (full re-index)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Load and chunk documents without embedding or storing",
    )
    args = parser.parse_args()

    asyncio.run(main(reset=args.reset, dry_run=args.dry_run))
