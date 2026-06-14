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
