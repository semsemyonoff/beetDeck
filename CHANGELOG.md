# Changelog

All notable changes to the beetDeck release are documented here. beetDeck ships
as a single product version — each entry corresponds to one published
`semsemyonoff/beetdeck` image tag built from the pinned `backend`/`frontend`
submodule commits.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

Umbrella-level notes for the next release go here (CI, compose, docs). The
"Cut release" workflow appends an auto-generated, submodule-derived draft below
the marker — rewrite it into human-readable notes before publishing.

<!-- release-cut inserts new versions below this line -->

## [0.1.0] - 2026-06-15

### backend (v0.1.0)
- style: apply ruff format to library.py after merge
- feat(backend): add GET /api/version endpoint
- chore(backend): upgrade beets 2.10.0 → 2.11.0, migrate off deprecated beets.art
- feat: downscaled WebP cover thumbnails + track has_cover
- docs: remove DWE-environment references from the repo
- refactor: rename src package to beetdeck (flat layout)
- style: apply ruff format to schemas and tests
- feat: report product release version as OpenAPI info.version
- fix: address code review findings
- fix: address code review findings
- docs: retire manual API table, document OpenAPI/Scalar + schemas
- feat: Task 11 — standardize 422 validation-error contract
- feat: Task 10 — annotate scan blueprint (spectree validation)
- feat: Task 9 — annotate items blueprint (spectree validation)
- feat: Task 8 — annotate identify blueprint (spectree validation)
- feat: Task 7 — annotate lyrics blueprint (spectree validation)
- feat: Task 6 — annotate genres blueprint (spectree validation)
- feat: Task 5 — annotate cover blueprint (spectree validation)
- feat: Task 4 — annotate albums blueprint (spectree validation)
- feat: Task 3 — annotate library blueprint (spectree validation)
- feat: Task 2 — shared schemas (error model + common types)
- feat: Task 1 — bootstrap SpecTree singleton + Scalar viewer
- docs: scope README to the backend part, point to deploy entry point
- chore: extract release tooling to the deploy repo
- style: apply ruff format to tag-editor sources
- ci: drop ffmpeg system-deps step from the test job
- ci: add Forgejo Actions workflow (ruff lint/format + pytest)
- style: apply ruff format to src/routes/genres.py
- fix: address code review findings
- fix: address code review findings
- docs: document metadata-batch endpoint and metadata_write_lock
- feat: add POST /api/items/metadata-batch endpoint
- fix: skip path-normalization preflight on a fresh/empty beets DB
- fix: address code review findings
- fix: make sync-frontend-dist directory-safe
- feat: add sync-frontend-dist target and build guard for SPA hand-off
- Move deps into pyproject.toml, add ruff, decouple prod image
- Extract frontend into its own repo (beetDeck/frontend.git)

### frontend (v0.1.0)
- Fix fmt
- feat: display version info from GET /api/version in topbar
- feat: search dropdown polish + downscaled cover thumbnails

## [0.1.0] - 2026-06-14

Initial release of **beetDeck** — a web interface for managing a
[beets](https://beets.io/) music library: identification (MusicBrainz), genres
(Last.fm), cover art, lyrics, and tag browsing on top of an existing library.

Ships as a single multi-arch image built from `backend` v0.1.0 and `frontend`
v0.1.0, published to Docker Hub, GHCR, and `git.horn/beetdeck/app`.

### Added
- First release with the full feature set: library browser, per-artist and
  album pages, MusicBrainz identify, Last.fm genre tagging, cover art, lyrics
  (lrclib), library rescan, untagged-file triage, in-place tag editing,
  full-text search, and a light/dark theme.
- Deployment layer: production `docker-compose.yml`, `.env.example`,
  `config.yaml.example`, a release `Makefile`, and pinned `backend`/`frontend`
  submodules built into one image.
- Self-contained multi-stage `Dockerfile` (SPA build + backend runtime) — the
  release image builds entirely from this repo, with no dependency on the dev
  stack.
- Hybrid release CI: the "Cut release" button builds a multi-arch image and
  pushes it to Docker Hub + GHCR (GitHub Actions) and `git.horn/beetdeck/app`
  (Forgejo Actions).
