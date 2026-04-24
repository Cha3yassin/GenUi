# ============================================================
# Fberaucracy Backend — Dockerfile
# Multi-stage build for lean production image
# ============================================================

# ── Stage 1: Builder ──────────────────────────────────────────────────────────
FROM python:3.12-slim AS builder

# Install build dependencies for native extensions (asyncpg, chromadb, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy only requirements first to leverage Docker layer cache
COPY requirements.txt .

# Install dependencies into a virtual environment for clean isolation
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


# ── Stage 2: Production Runtime ───────────────────────────────────────────────
FROM python:3.12-slim AS production

# Runtime system deps only (libpq for asyncpg)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for security
RUN groupadd --gid 1000 appuser && \
    useradd --uid 1000 --gid appuser --shell /bin/bash --create-home appuser

WORKDIR /app

# Copy the virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application source
COPY --chown=appuser:appuser . .

# Create directories that the app will write to at runtime
RUN mkdir -p /app/chroma_data /app/logs && \
    chown -R appuser:appuser /app/chroma_data /app/logs

# Switch to non-root user
USER appuser

# Expose the application port
EXPOSE 8000

# Health check — Docker will restart the container if this fails
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Production server: Uvicorn with multiple workers
# Workers = (2 * CPU cores) + 1 is a common heuristic
CMD ["uvicorn", "app.main:app", \
     "--host", "0.0.0.0", \
     "--port", "8000", \
     "--workers", "2", \
     "--loop", "uvloop", \
     "--access-log"]
