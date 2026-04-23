# 🇹🇳 Fberaucracy — Sfax Municipality Navigator

**Scope:** Sfax municipality bureaucracy  
**Stack:** Flutter + FastAPI + Gemini 1.5 Flash + ChromaDB (RAG)  
**Languages:** Arabic 🇸🇦 · French 🇫🇷 · English 🇬🇧  
**Auth:** Google Sign-In  

---

## Final Stack Decision

| Layer | Choice | Reason |
|---|---|---|
| Frontend | Flutter | GenUI, cross-platform |
| Backend | **FastAPI** ✅ | Best RAG ecosystem (Python), fast, lightweight |
| AI | Gemini 1.5 Flash | Structured output, low token cost |
| RAG Vector DB | **ChromaDB** | Local, free, easy setup → upgrade to Pinecone later |
| Auth | Google OAuth (Firebase Auth) | One SDK for Flutter + backend verification |
| DB | PostgreSQL | User data, conversation history |
| Embeddings | `text-embedding-004` (Google) | Same API, no extra cost |

> Spring Boot was eliminated — too much boilerplate for an AI-heavy app. FastAPI + Python = perfect for RAG.

---

## Architecture

```
Flutter App
  │
  ├── Google Sign-In → Firebase Auth token
  │
  └── FastAPI Backend
        ├── POST /chat          ← main endpoint
        │     ├── Verify Firebase token
        │     ├── ChromaDB similarity search (RAG)
        │     │     └── Top-k Sfax procedure chunks
        │     ├── Build Gemini prompt (context + user query)
        │     ├── Gemini 1.5 Flash → structured JSON
        │     └── Return GenUI JSON → Flutter renders widgets
        │
        ├── POST /auth/verify
        ├── GET  /categories     ← Sfax procedure categories
        └── GET  /history/{uid}  ← conversation history
```

---

## RAG Pipeline

```
INGESTION (one-time):
  Sfax procedure docs (PDF/text)
    → chunk into 512-token segments
    → embed with text-embedding-004
    → store in ChromaDB

QUERY (per request):
  User question
    → embed with text-embedding-004
    → top-5 similar chunks from ChromaDB
    → inject into Gemini prompt as context
    → structured JSON output
```

### Sfax Knowledge Base (seed data)
- Carte Grise / Immatriculation (ATTT Sfax)
- Extrait de naissance (Commune de Sfax)
- Permis de construire (Municipalité de Sfax)  
- Registre du Commerce (RNE Sfax)
- Attestation de résidence
- CIN renouvellement
- Taxe foncière (Sfax)
- CNAM / CNSS affiliations

---

## Project Structure

```
fberaucracy/
├── backend/                         # FastAPI
│   ├── main.py
│   ├── routers/
│   │   ├── chat.py                  # /chat endpoint
│   │   ├── auth.py                  # Google token verify
│   │   └── categories.py
│   ├── services/
│   │   ├── gemini_service.py        # Gemini client + prompt builder
│   │   ├── rag_service.py           # ChromaDB query
│   │   └── embedding_service.py     # text-embedding-004
│   ├── data/
│   │   ├── raw/                     # Sfax procedure docs
│   │   └── ingest.py                # One-time ingestion script
│   ├── models/
│   │   └── schemas.py               # Pydantic models
│   └── requirements.txt
│
├── mobile/                          # Flutter
│   ├── lib/
│   │   ├── main.dart
│   │   ├── features/
│   │   │   ├── auth/                # Google Sign-In
│   │   │   ├── home/                # Category grid
│   │   │   └── chat/                # Chat + GenUI renderer
│   │   ├── core/
│   │   │   ├── api/                 # FastAPI client (Dio)
│   │   │   ├── genui/               # JSON → Flutter widgets
│   │   │   └── l10n/                # AR/FR/EN strings
│   │   └── shared/widgets/
│   └── pubspec.yaml
│
└── docker-compose.yml               # FastAPI + PostgreSQL + ChromaDB
```

---

## GenUI JSON Schema (Gemini output)

```json
{
  "type": "procedure_guide",
  "title": { "ar": "...", "fr": "...", "en": "..." },
  "steps": [
    { "number": 1, "title": "...", "description": "...", "location": "Sfax ..." }
  ],
  "documents": ["CIN", "Acte de naissance", "..."],
  "costs": { "total": 150, "currency": "TND", "breakdown": [...] },
  "warnings": ["..."],
  "office": { "name": "Municipalité de Sfax", "hours": "8h-15h", "address": "..." }
}
```

---

## Key FastAPI Endpoints

```python
# POST /chat
{
  "message": "Comment obtenir un extrait de naissance?",
  "language": "fr",           # ar | fr | en
  "category": "civil_docs",
  "uid": "firebase_uid"
}

# Response → structured GenUI JSON
```

---

## Flutter Dependencies

```yaml
# Auth
firebase_auth, google_sign_in

# API
dio, riverpod

# UI
flutter_animate, go_router

# i18n
flutter_localizations, intl
```

---

## FastAPI Dependencies

```
fastapi, uvicorn
google-generativeai       # Gemini + embeddings
chromadb                  # Vector store
firebase-admin            # Token verification
sqlalchemy, asyncpg       # PostgreSQL (history)
python-dotenv
langchain-text-splitters  # Chunking only
```

---

## Implementation Phases

### Phase 1 — Backend Core (Week 1)
- [ ] FastAPI project + Docker setup
- [ ] Google Auth token verification
- [ ] ChromaDB setup + ingestion script
- [ ] RAG service (embed + query)
- [ ] Gemini service + structured output
- [ ] `/chat` endpoint wired end-to-end

### Phase 2 — Flutter App (Week 2)
- [ ] Flutter project + FlutterFire
- [ ] Google Sign-In flow
- [ ] Category home screen
- [ ] Chat UI + FastAPI integration
- [ ] GenUI renderer (5 widget types)
- [ ] AR/FR/EN localization

### Phase 3 — Polish (Week 3)
- [ ] Seed all Sfax procedures into ChromaDB
- [ ] Conversation history (PostgreSQL)
- [ ] Offline cache (Hive)
- [ ] Dark mode + Arabic RTL layout
- [ ] Deploy backend (Railway / Render)
