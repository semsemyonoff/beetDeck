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
