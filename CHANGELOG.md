# Changelog

All notable changes to the beetDeck release are documented here. beetDeck ships
as a single product version — each entry corresponds to one published
`semsemyonoff/beetdeck` image tag built from the pinned `backend`/`frontend`
submodule commits.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

Umbrella-level notes for the next release go here (CI, compose, docs). The
"Cut release" workflow appends an auto-generated, submodule-derived section
below the marker — keep hand-written notes up here.

### Added
- Initial deployment repository: production `docker-compose.yml`, `.env.example`,
  `config.yaml.example`, release `Makefile`, and pinned `backend`/`frontend`
  submodules.
- Self-contained multi-stage `Dockerfile` (SPA build + backend runtime) and
  `build.sh`, moved out of the backend repo — the release image now builds
  entirely from this repo, with no dependency on the DWE dev stack.
- Hybrid release CI: `make release` is now a fallback; tagging `vX.Y.Z` (via the
  "Cut release" button) builds and pushes to Docker Hub + GHCR (GitHub Actions)
  and `git.horn/beetdeck/app` (Forgejo Actions).

<!-- release-cut inserts new versions below this line -->

## [0.1.0] - 2026-06-14

### backend (v0.1.0)
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

### frontend (v0.1.0)
- (no changes)
