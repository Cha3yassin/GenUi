# 🇹🇳 Fberaucracy Backend

**Tunisia Bureaucracy Navigator — FastAPI Backend**

AI-powered backend that helps Tunisian users understand government procedures through structured, multilingual guidance.

---

## Architecture Overview

```
Flutter App
    │
    ▼ POST /api/v1/chat  (Bearer token)
Firebase Token Verification
    │
    ▼
Get/Create User (PostgreSQL)
    │
    ▼
RAG Search (ChromaDB + Google text-embedding-004)
    │  Top-5 relevant procedure chunks
    ▼
Gemini 1.5 Flash  (strict anti-hallucination prompt)
    │  Structured JSON output
    ▼
Pydantic Validation
    │
    ▼  (on failure → ErrorResponse)
Persist to chat_history (PostgreSQL)
    │
    ▼
Return JSON to Flutter
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | FastAPI 0.115 + Uvicorn |
| AI Model | Gemini 1.5 Flash |
| Embeddings | Google text-embedding-004 |
| Vector DB | ChromaDB (embedded, persistent) |
| Database | PostgreSQL 16 + Async SQLAlchemy 2 |
| Auth | Firebase Admin SDK |
| Validation | Pydantic v2 |
| Migrations | Alembic |
| Logging | structlog |
| Containers | Docker + Docker Compose |

---

## Project Structure

```
backend/
├── app/
│   ├── main.py                    # App factory, lifespan, routers
│   ├── core/
│   │   ├── config.py              # Settings (Pydantic BaseSettings)
│   │   ├── security.py            # Firebase token verification
│   │   └── logging.py             # Structlog setup
│   ├── api/routes/
│   │   ├── chat.py                # POST /chat — main pipeline
│   │   ├── auth.py                # GET /auth/me, POST /auth/register
│   │   ├── categories.py          # GET /categories
│   │   └── history.py             # GET /history/{user_id}
│   ├── services/
│   │   ├── gemini_service.py      # Gemini API + prompt building
│   │   ├── rag_service.py         # ChromaDB embed + search + ingest
│   │   ├── auth_service.py        # User upsert
│   │   ├── history_service.py     # Chat history CRUD
│   │   └── procedure_service.py   # Category seed + CRUD
│   ├── db/
│   │   ├── models.py              # SQLAlchemy ORM models
│   │   └── session.py             # Async engine + get_db dependency
│   ├── schemas/
│   │   ├── requests.py            # ChatRequest (Pydantic)
│   │   └── responses.py           # ProcedureGuideResponse, ErrorResponse, etc.
│   ├── utils/
│   │   └── validators.py          # Gemini output validator
│   └── data/
│       ├── ingest.py              # CLI ingest script
│       └── raw/                   # Raw procedure text files
│           ├── extrait_naissance_sfax.txt
│           ├── carte_grise_sfax.txt
│           └── attestation_residence_sfax.txt
├── migrations/
│   ├── env.py                     # Alembic async env
│   └── versions/
│       └── 0001_initial_schema.py
├── tests/
│   ├── conftest.py                # Fixtures (SQLite, mock Firebase)
│   ├── test_health.py
│   ├── test_categories.py
│   ├── test_chat.py
│   └── test_validators.py
├── Dockerfile                     # Multi-stage production image
├── docker-compose.yml             # Postgres + API services
├── alembic.ini
├── requirements.txt
├── pytest.ini
└── .env.example
```

---

## Quick Start

### 1. Clone & Configure

```bash
cd backend
cp .env.example .env
# Edit .env — fill in:
#   GOOGLE_API_KEY
#   FIREBASE_SERVICE_ACCOUNT_PATH  (or FIREBASE_SERVICE_ACCOUNT_JSON)
#   POSTGRES_PASSWORD
```

### 2. Start Services with Docker Compose

```bash
docker compose up -d postgres        # Start Postgres first
docker compose up -d --build api     # Build and start the API
```

The API will be available at **http://localhost:8000**

Swagger docs: **http://localhost:8000/docs** (development only)

### 3. Local Development (without Docker)

```bash
# Create virtual environment
python -m venv .venv
.venv\Scripts\activate          # Windows
# source .venv/bin/activate     # macOS/Linux

# Install dependencies
pip install -r requirements.txt

# Run database migrations
alembic upgrade head

# Start the server
uvicorn app.main:app --reload --port 8000
```

### 4. Ingest Procedure Documents

```bash
# First time — index all documents
python -m app.data.ingest

# Preview chunks without writing to ChromaDB
python -m app.data.ingest --dry-run

# Full re-index (clears existing vectors)
python -m app.data.ingest --reset
```

---

## API Endpoints

### `POST /api/v1/chat` 🔒 *(requires Bearer token)*

Main endpoint — full RAG → Gemini → structured JSON pipeline.

**Request:**
```json
{
  "message": "Comment obtenir un extrait de naissance?",
  "language": "fr",
  "category": "civil_status"
}
```

**Success Response (`procedure_guide`):**
```json
{
  "type": "procedure_guide",
  "title": { "ar": "...", "fr": "...", "en": "..." },
  "steps": [{ "number": 1, "title": "...", "description": "...", "location": "..." }],
  "documents": ["CIN originale", "Livret de famille"],
  "costs": { "total": 0.6, "currency": "TND", "breakdown": [...] },
  "office": { "name": "...", "address": "...", "hours": "..." },
  "warnings": ["Valable 3 mois"],
  "source": "extrait_naissance_sfax",
  "last_verified": "2024-01-15"
}
```

**Error Response:**
```json
{
  "type": "error",
  "message": "Unable to generate procedure safely.",
  "code": "VALIDATION_FAILED"
}
```

---

### `GET /api/v1/categories` *(public)*

```json
[
  { "id": "civil_status", "name_ar": "الحالة المدنية", "name_fr": "État Civil", "name_en": "Civil Status", "icon": "document_text" },
  { "id": "vehicles", "name_ar": "المركبات", "name_fr": "Véhicules", "name_en": "Vehicles", "icon": "car" }
]
```

---

### `GET /api/v1/history/{user_id}` 🔒

```json
{
  "user_id": "uuid",
  "total": 42,
  "items": [
    {
      "id": "uuid",
      "user_message": "...",
      "ai_response": { "type": "procedure_guide", ... },
      "created_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

**Query params:** `?limit=20&offset=0`

---

### `GET /api/v1/auth/me` 🔒

Returns current user profile.

### `POST /api/v1/auth/register` 🔒

Explicit user registration (also auto-triggered by `/chat`).

### `GET /health` *(public)*

```json
{ "status": "healthy", "service": "fberaucracy-api", "version": "1.0.0", "environment": "production" }
```

---

## Running Tests

```bash
# Install test dependencies (already in requirements.txt)
pip install aiosqlite

# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=term-missing
```

Tests use:
- **SQLite in-memory** — no real Postgres required
- **Mocked Firebase** — no real token needed
- **Mocked Gemini + RAG** — no real API keys in CI

---

## Database Migrations

```bash
# Apply all migrations
alembic upgrade head

# Create a new migration (after model changes)
alembic revision --autogenerate -m "add_field_xyz"

# Roll back one version
alembic downgrade -1

# View migration history
alembic history
```

---

## Adding New Procedure Documents

1. Add a `.txt` file to `app/data/raw/`
2. Register it in `app/data/ingest.py` under `DOCUMENT_REGISTRY`
3. Run `python -m app.data.ingest` to index it

---

## Environment Variables Reference

| Variable | Required | Description |
|---|---|---|
| `GOOGLE_API_KEY` | ✅ | Gemini + Embedding API key |
| `FIREBASE_SERVICE_ACCOUNT_PATH` | ✅* | Path to Firebase JSON key file |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | ✅* | Inline Firebase JSON (Docker alternative) |
| `POSTGRES_HOST` | ✅ | PostgreSQL host |
| `POSTGRES_PASSWORD` | ✅ | PostgreSQL password |
| `POSTGRES_DB` | ✅ | Database name |
| `GEMINI_MODEL` | ⚙️ | Default: `gemini-1.5-flash` |
| `EMBEDDING_MODEL` | ⚙️ | Default: `models/text-embedding-004` |
| `CHROMA_PERSIST_DIRECTORY` | ⚙️ | Default: `./chroma_data` |
| `RAG_TOP_K` | ⚙️ | Chunks to retrieve (default: 5) |
| `DEBUG` | ⚙️ | Enables SQL logging + Swagger UI |

*Either `FIREBASE_SERVICE_ACCOUNT_PATH` or `FIREBASE_SERVICE_ACCOUNT_JSON` must be set.

---

## Production Checklist

- [ ] Set `APP_ENV=production` (disables Swagger UI)
- [ ] Set a strong `SECRET_KEY`
- [ ] Use `FIREBASE_SERVICE_ACCOUNT_JSON` env var instead of mounted file
- [ ] Configure `ALLOWED_ORIGINS` for your Flutter app domain
- [ ] Run `alembic upgrade head` before first boot
- [ ] Run `python -m app.data.ingest` to populate ChromaDB
- [ ] Set up log aggregation (structlog outputs JSON in production)
- [ ] Configure a reverse proxy (nginx/Caddy) in front of Uvicorn
