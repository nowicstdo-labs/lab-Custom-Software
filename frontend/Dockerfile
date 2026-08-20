# ── Stage 1: Build Flutter Web Release ────────────────────────────────────────
FROM ghcr.io/cirrusci/flutter:3.24.0 AS builder

WORKDIR /app

# Copy dependency definition files first for optimal layer caching
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy application source code
COPY . .

# Build production Flutter Web bundle with live Render API endpoint
ARG API_BASE_URL=https://astha-diagnostic-2.onrender.com/api/v1
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

# ── Stage 2: Serve via Production Nginx ──────────────────────────────────────
FROM nginx:alpine

# Copy custom Nginx configuration supporting SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled Flutter Web bundle
COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
