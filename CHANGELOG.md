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

Fourth feature release, and it is about the artwork gallery: everything the
Cover Art Archive holds for an album, browsable inside beetDeck, any of it one
click from being the cover. Plus a metadata sync with MusicBrainz.

### Added
- **Cover Art Archive gallery** — every scan of a release the Archive has (front,
  back, booklet, the disc itself) in a grid with a fullscreen viewer, and any of
  them can become the album's cover. What it downloads is optionally mirrored to a
  volume, so a second visit never goes back to the Archive.
- **Sync from MusicBrainz** — re-read an identified album's release and apply what
  changed there since, field by field, from a preview you approve.
- **MusicBrainz as a genre source**, next to Last.fm.

### Changed
- **MCP:** `preview_mbsync` is new; `preview_genres` takes a `source`.

### Upgrading
- Nothing to change. The artwork mirror is off by default — turn it on with
  `BEETDECK_ARTWORK_DIR=/data/artwork` in `.env`; see README.
- `config.yaml.example` now spells out `musicbrainz.genres: no`. It is already
  beets' default and beetDeck never raises it, so your own config only needs the
  line if you want the guarantee written down.

## [0.3.2] - 2026-08-12

Patch release: beetDeck no longer reports what it failed to check as a fact
about your library.

### Fixed
- **A search during a rescan looked like an empty library.** Album lists and
  searches now say a scan is in flight and name the run.
- **"Last.fm has no genre for this album" was said when Last.fm could not be
  reached.** A failed lookup is reported as one, with the reason the service
  gave.
- **"No cover art found online" was said for art that was found and then
  refused** by the configured minimum width. Such a cover is now offered with a
  warning; when nothing is usable, the art sources' own reasons are reported.
- **A blocked lyrics source looked like a track with no lyrics.** A run in which
  a source failed says so.
- **Saving a genre could write something other than the preview showed** —
  confirming ran a second Last.fm lookup. The previewed value is what gets
  saved.

### Added
- **Genre Replace or Merge** — merge keeps the genres the album already has and
  adds the fetched ones it lacks. The preview shows current, fetched and
  proposed.
- **Cover preview compares sizes** with the current cover, so an upgrade is
  visible before saving.

### Changed
- **MCP:** `preview_genres` takes `mode`; `preview_cover` carries both sizes and
  flags a candidate the size filter rejects; `list_albums` / `search_library` /
  `list_untagged_items` note an in-flight rescan; `preview_lyrics` separates a
  failed source from an absent lyric.
- **API:** `POST /api/album/<id>/genre` takes `?mode=replace|merge` and answers
  `502` when the lookup itself failed; cover- and lyrics-fetch responses carry
  sizes, warnings and reasons.

### Upgrading
- Nothing to change. Frequent "below the configured minimum width" warnings mean
  `fetchart.minwidth` in your `config.yaml` is stricter than the artwork the
  sources actually have.


## [0.3.1] - 2026-08-10

Patch release: cover art beetDeck saved was unreadable to other programs, quick
rescans were silently doing full ones, and a competing fetch could be committed
in place of the one you previewed.

### Fixed
- **Saved cover art was readable only by beetDeck.** Every `cover.jpg` from a
  fetch or upload landed owner-only, so media servers and other containers
  sharing the music folder saw an album with no artwork. New covers get normal
  permissions; for existing ones,
  `find /path/to/music -name 'cover.jpg' -perm 600 -exec chmod 644 {} +`.
- **`config.yaml.example` set no `statefile`, so quick rescans were never
  incremental.** beets could not write its import history into a read-only
  config dir and said so only in the log, so every quick scan re-read the tags
  of the whole library. The example now keeps the state file beside
  `library.db`. Existing configs are not touched — see *Upgrading*.
- **A cover or lyrics fetch could be committed on top of a newer one.** A second
  fetch — another browser tab, or an AI agent on the same album — silently
  replaced the result you were shown, and confirming saved that one instead.
  Stale confirms are now refused, and concurrent writes to the same album are
  serialized.
- **Cover-art plugins never saw the artwork beetDeck saved** — the beets event
  they hook was not emitted.
- **A corrupt cover file could make its album page fail to load** with a server
  error instead of the album.

### Added
- **Cover art dimensions**, on the album and on a fetched candidate — so you can
  tell whether a new cover is an upgrade before saving it.
- **Instrumental tracks are marked as such** on the album page, instead of being
  indistinguishable from tracks nobody ever looked up.

### Changed
- **MCP: cover and lyrics previews are enforced by the backend**, like
  identification already was — an apply is refused if the fetched result was
  replaced. Their tokens now last the same 15 minutes as every other kind.
- **MCP: `list_albums` takes an `artist` filter**, so answering "what do we have
  by this band" no longer means pulling the whole library.

### Upgrading
- **Add `statefile: /data/beets/state.pickle` to your own `config.yaml`** — it is
  operator-owned and not updated by the image. `state file could not be written`
  in a rescan log (`/data/beets/scan-logs/<run_id>.log`) means you are affected.
  The first scan after the change is still a full one; the ones after it take
  seconds.
- **Existing cover files keep their old permissions** — only newly saved artwork
  gets the fix; see the `find` command above.


## [0.3.0] - 2026-08-08

Third feature release of **beetDeck**, on
[beets 2.13.1](https://github.com/beetbox/beets/releases/tag/v2.13.1). The
headline is an optional **MCP server** — your library, worked on by an AI agent,
with a preview-then-apply step in front of every change.

### Added
- **MCP server (optional, off by default)** — a second container that exposes
  the library to Claude or any other [MCP](https://modelcontextprotocol.io/)
  client: browse and search, identify against MusicBrainz, fetch cover art,
  genres and lyrics, edit tags — in conversation instead of by clicking. Every
  write is two-phase: the agent asks for a preview, you get a diff, and a
  separate apply step is the only thing that touches your files. Bearer-token
  authenticated, with a read-only mode that withholds the apply step entirely.
  Start it with `docker compose --profile mcp up -d`; see README → *MCP server*
  for the two required settings and the exposure caveats.
- **Album and artist names in the browser tab title** — so a row of open album
  tabs is tellable apart, and history and bookmarks read sensibly.

### Changed
- Upgraded to [beets 2.13.1](https://github.com/beetbox/beets/releases/tag/v2.13.1)
  (from 2.12.0).
- **Instrumental tracks are now their own lyrics state.** beets recognises an
  instrumental match instead of storing the literal `[Instrumental]` as the
  lyrics text. beetDeck reports those tracks as instrumental rather than as a
  failed lookup, and they keep counting as "has lyrics" — previously they would
  have quietly flipped to "nothing found" after the upgrade.
- **Genre spellings are normalised** before filtering, by an alias table new in
  beets 2.13. `Shoegazer` now comes back as `Shoegaze`, `Synthpop` as
  `Synth-Pop`, and a handful of previously-valid tags (`dance`, `rhythm and
  blues`, `industrial music`, `psychedelic trance`, `2-step garage`, `noise
  music`) no longer match and are dropped. Genres already in your library are
  left alone, so expect a mix of old and new spellings.

### Fixed
- **A failed identification could permanently lose arranger, composer, lyricist
  and remixer tags.** When identifying an album went wrong part-way through, the
  automatic undo restored everything *except* those four fields — and on a full
  re-tag, where every tag is cleared first, that meant they were gone for good.
  The undo also left an empty stray attribute behind on each track.
- **`config.yaml.example` shipped `duplicate_action: skip`**, which defeated the
  0.2.0 fix for replacing a track with a different-format copy: the old track
  disappeared on one rescan and only came back on the next. The example now says
  `remove`. Existing configs are not touched — see *Upgrading*.

### Upgrading
- **The library database is migrated for you.** beets 2.13 changes the schema,
  and the new image completes that migration in one pass at startup, before it
  accepts any requests. Nothing to run by hand.
- **Delete the backup copies afterwards.** beets copies the whole database
  before each migration it applies, as `library.db-before-*.bak` inside the
  `beetdeck_data` volume. Nothing prunes them. Remove them once you have
  confirmed the upgrade is healthy.
- **Check `duplicate_action` in your own `config.yaml`.** It is operator-owned
  and is *not* updated by the image. If it still reads `skip`, change it to
  `remove` under `import:` and restart, or a rescan that picks up a re-encoded
  track will drop it for one pass.


## [0.2.1] - 2026-07-18

Patch release that makes **BPM tagging** actually work in a self-hosted
deployment. The feature shipped in 0.2.0 but could not run whenever the
container runs under a non-root user.

### Fixed
- **BPM computation under a non-root container** — computing BPM failed with
  `BPM computation failed` whenever the container ran as a non-root user
  (`user: "1000:1000"`, PUID/PGID — the usual self-hosting setup). The audio
  analysis library compiles code on first use and had nowhere to write its
  cache, because neither the install directory nor the home directory is
  writable for that user. The image now ships a dedicated writable cache
  location, so BPM works under any UID.

### Upgrading
Your `config.yaml` is operator-owned and is *not* updated by the image. If BPM
reports `autobpm plugin not loaded`, add `autobpm` to the `plugins:` list and an
`autobpm:` / `auto: no` block to your own config (see `config.yaml.example`),
then restart the container — beets reads its config at startup.


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

