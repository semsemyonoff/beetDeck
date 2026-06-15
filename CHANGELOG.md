# Changelog

All notable changes to the beetDeck release are documented here. beetDeck ships
as a single product version — each entry corresponds to one published
`semsemyonoff/beetdeck` image tag built from the pinned `backend`/`frontend`
submodule commits.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

<!-- Write notes for the next release here. "Cut release" promotes this
     section to ## [X.Y.Z] - <date> and uses it as the release body. -->

## [0.1.0] - 2026-06-15

Initial release of **beetDeck** — a web interface for managing a
[beets](https://beets.io/) music library: identification (MusicBrainz), genres
(Last.fm), cover art, lyrics, and tag browsing on top of an existing library.

Ships as a single multi-arch image (linux/amd64 + linux/arm64) built from
`backend` v0.1.0 and `frontend` v0.1.0 on **beets 2.11.0**, published to Docker
Hub and GHCR.

### Added
- Full feature set: library browser, per-artist and album pages, MusicBrainz
  identify, Last.fm genre tagging, cover art, lyrics (lrclib), library rescan,
  untagged-file triage, in-place tag editing, full-text search, and a
  light/dark theme.
- Downscaled WebP cover thumbnails for faster library and search browsing.
- Topbar version readout backed by a `GET /api/version` endpoint (reports the
  baked product version alongside the beets version).
- OpenAPI 3 spec with a Scalar API viewer at `/apidoc`, plus validated
  request/response schemas across every endpoint.
- Responsive layout (4-tier mobile/tablet) with a search hotkey.
- Deployment layer: production `docker-compose.yml`, `.env.example`,
  `config.yaml.example`, a release `Makefile`, and pinned `backend`/`frontend`
  submodules built into one image.
- Self-contained multi-stage `Dockerfile` (SPA build + backend runtime) — the
  release image builds entirely from this repo, with no dependency on the dev
  stack.
- Release CI: the "Cut release" button builds the multi-arch image and
  publishes it to Docker Hub and GHCR.

