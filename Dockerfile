# syntax=docker/dockerfile:1
#
# Production image for beetDeck — the Flask API plus the pre-built SPA in a
# single container. The build context is THIS deploy repo root, so both pinned
# submodules are visible:
#   frontend/ — React/Vite SPA, built to static assets in stage 1
#   backend/  — Flask app; serves the API and the baked SPA on :5000
#
# Build with ./build.sh (multi-arch, pushes) or `make release` / `make release-local`.
# This is fully self-contained: it does NOT depend on the DWE dev stack.

# ---- Stage 1: build the SPA ----
FROM node:20-slim AS spa
WORKDIR /app
# Manifests first for layer caching. Any committed frontend/.npmrc (registry
# concurrency cap) is brought in with the full source copy below before build.
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
# vite.config.js pins base=/static/dist/ for the production build; output -> /app/dist.
RUN npm run build

# ---- Stage 2: backend runtime ----
FROM python:3.14-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Dependencies are declared in pyproject.toml (single source of truth; pulls the
# pinned beets release tarball).
COPY backend/pyproject.toml backend/README.md backend/app.py ./
COPY backend/src ./src
RUN pip install --no-cache-dir .

# Bake the built SPA where Flask serves it: /static/dist/ (resolved via the Vite
# manifest at request time — see backend src/__init__.py + src/templates/index.html).
COPY --from=spa /app/dist ./src/static/dist

RUN mkdir -p /tmp/beetdeck && chmod 1777 /tmp/beetdeck

EXPOSE 5000
ENV TMPDIR=/tmp/beetdeck

# Product release version, baked at build time (build.sh passes the release tag,
# e.g. 1.2.3). The backend reads APP_VERSION at startup and reports it as the
# OpenAPI info.version (/apidoc/openapi.json, Scalar header). No git history is
# needed in the image — .dockerignore strips .git, so the version is injected
# here instead of derived from a tag at runtime. Defaults to 0.0.0 for plain
# `docker build` without --build-arg.
ARG APP_VERSION=0.0.0
ENV APP_VERSION=$APP_VERSION

# Single worker is mandatory: the app shares in-memory state across request
# threads (scan/identify tasks). Scale with threads, never workers.
CMD ["gunicorn", "-b", "0.0.0.0:5000", "-w", "1", "--threads", "4", "--worker-tmp-dir", "/tmp/beetdeck", "app:app"]
