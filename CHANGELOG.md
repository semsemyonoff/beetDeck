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

## [0.2.0] - 2026-07-01

Second release of **beetDeck**, on
[beets 2.12.0](https://github.com/beetbox/beets/releases/tag/v2.12.0). Focuses on
richer tag editing, tempo tagging, and a much better feel for scans and bulk
lyrics.

### Added
- **Full tag editing** — a per-track editor for *any* beets field, not just the
  fixed batch set: edit flexible attributes, add known fields, with read-only and
  album-level fields clearly marked. Opens from the album tags view and the
  untagged-folder editor.
- **BPM tagging** — compute tempo for a single track or a whole album via beets'
  `autobpm`, written straight into the files, with a green indicator on tracks and
  albums that already have it.
- **Album lyrics preview** — fetching lyrics for a whole album now opens a modal
  with a per-track before/after diff, parallel downloads with a progress bar, and
  per-track or apply-all confirmation (previously it wrote everything blindly).
- **Open in new tab** — albums, artists, untagged folders, search results, and
  breadcrumbs are now real links, so middle-click, Ctrl/Cmd-click, and "Open in
  new tab" all work.

### Changed
- **Scan progress** — the scan banner now shows a real progress bar with the
  current item and phase, backed by a live scan-log screen; the completion result
  persists until you dismiss it instead of vanishing after a few seconds.
- Upgraded to [beets 2.12.0](https://github.com/beetbox/beets/releases/tag/v2.12.0)
  (from 2.11.0), plus refreshed application dependencies.

### Fixed
- Rescan now correctly *replaces* an existing track when a different-format copy is
  imported, instead of leaving a stale duplicate behind.


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

