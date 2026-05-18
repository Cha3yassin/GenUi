# ============================================================
# f-idarty Frontend — Dockerfile
# Multi-stage build: Flutter Web build → Nginx serving
# ============================================================

# ── Stage 1: Flutter Web Build ──────────────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Copy dependency files first for better cache
COPY pubspec.yaml pubspec.lock ./

# Get dependencies (cached layer)
RUN flutter pub get

# Copy the rest of the source
COPY . .

# Build Flutter for web (production, release mode)
# --base-href is "/" since Nginx will serve from root
RUN flutter build web --release --base-href / --dart-define=DOCKER=true


# ── Stage 2: Nginx Production Server ────────────────────────────────────────
FROM nginx:1.27-alpine AS production

# Remove default Nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built Flutter web app from builder stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expose port 80 for the web server
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
