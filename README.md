# beetDeck

![logo](assets/logo.svg)

**A web UI for tagging and organizing your [beets](https://beets.io/) music library.**

beetDeck gives your existing music collection a clean browser-based interface for
the tedious part of a library: getting the metadata right. It identifies albums
against MusicBrainz, fetches genres, cover art, and lyrics, lets you edit tags by
hand, and writes everything back into your audio files — no command line needed.

beetDeck is **not** a downloader or an importer. It doesn't fetch music or move
files around. Point it at a folder of audio you already have (managed by hand, or
by something like Lidarr) and it becomes the tagging and browsing layer on top.

<img src="assets/screenshots/library-index.png" alt="Library browser" width="800">

## What you can do with it

- **Browse your library** — artists collapse into a tidy index, or switch to a
  cover-art wall. Each album shows its year and whether it's been identified yet.
- **Open an artist** — a dedicated page with every album for that artist in a grid.
- **Inspect an album** — cover art, full metadata, the file path on disk, and the
  complete track list with per-track actions. Multi-disc albums show each disc
  separately.
- **Identify albums** — match against MusicBrainz, compare candidates, preview
  exactly what will change, then confirm to write the tags into your files.
- **Fetch genres** — look up genres from Last.fm with an old-vs-new preview.
- **Get cover art** — pull artwork from the Cover Art Archive, iTunes, Amazon, or
  the local files; preview and confirm, or upload your own image. Saved as both a
  high-res file and an embedded thumbnail.
- **Manage lyrics** — synced or plain-text lyrics per track or for a whole album
  via lrclib, with an inline editor, online search, and a side-by-side diff before
  you save.
- **Edit tags by hand** — an *Edit tags* modal for album-level and per-track
  fields; album-level changes propagate to every track file.
- **Triage untagged files** — loose files with no album artist are grouped by
  folder and surfaced in a banner at the top of the library, with a bulk editor and
  a hand-off into MusicBrainz identification.
- **Search everything** — full-text search across artists, albums, and tracks,
  with full Unicode support.
- **Rescan** — a quick incremental scan or a full rescan to pick up new files and
  drop stale entries.
- **Light or dark theme** — follows your system preference, with a manual toggle.
- **Hand it to an AI agent** — an optional [MCP](https://modelcontextprotocol.io/)
  server lets Claude (or any MCP client) do the same work in conversation, with a
  preview-then-apply step on every change. Off by default; see below.

### Identify against MusicBrainz

Pick the best candidate, review the diff, and apply only the changes you want.

<img src="assets/screenshots/identify-musicbrainz.png" alt="MusicBrainz identification" width="700">

### Edit tags directly

Every tag on the album and its tracks, editable in one place.

<img src="assets/screenshots/edit-tags.png" alt="Edit tags" width="700">

### Fetch and diff lyrics

Compare your current lyrics against what's found online before saving.

<img src="assets/screenshots/lyrics-diff.png" alt="Lyrics diff" width="800">

### One page per artist

<img src="assets/screenshots/artist-page.png" alt="Artist page" width="800">

## Running it

beetDeck ships as a single Docker image. You need [Docker](https://docs.docker.com/get-docker/)
with Compose, and a folder of music.

```bash
cp .env.example .env                       # set the host port and your paths
mkdir -p config music                      # config/ holds your beets config.yaml
cp config.yaml.example config/config.yaml  # edit if you want; the default works
docker compose up -d
```

Then open **http://localhost:8080** (or whatever `BEETDECK_HTTP_PORT` you set) and
run **Full Scan** in the top bar to load your library into beetDeck.

> **Your music folder must be writable.** beetDeck writes tags, cover art, and
> lyrics back into your audio files — that's the whole point.

### Configuration (`.env`)

| Variable              | Default                 | What it does                          |
|-----------------------|-------------------------|---------------------------------------|
| `BEETDECK_IMAGE`      | `semsemyonoff/beetdeck` | Image to run                          |
| `BEETDECK_TAG`        | `latest`                | Image tag — pin to a version in prod  |
| `BEETDECK_HTTP_PORT`  | `8080`                  | Port the UI is served on              |
| `BEETDECK_CONFIG_DIR` | `./config`              | Your beets config dir (holds `config.yaml`) |
| `BEETDECK_MUSIC_DIR`  | `./music`               | Your music library / import folder    |
| `TZ`                  | `UTC`                   | Timezone for logs and timestamps      |

Your beets database and app state persist in a Docker volume, so your work
survives restarts and upgrades.

### MCP server (optional)

beetDeck can also expose your library to an AI agent (Claude, or anything else
that speaks [MCP](https://modelcontextprotocol.io/)) — browsing, identification,
cover art, lyrics and tag edits, driven in conversation instead of by clicking.

Every change an agent can make is **two-phase**: it asks for a preview, you see
the diff, and only an explicit apply step writes anything. It runs as a second
container from the same image, off by default:

```bash
# in .env — both are required, the server refuses to start without them
BEETDECK_MCP_TOKEN=$(openssl rand -hex 24)
MUSICBRAINZ_USER_AGENT='beetDeck/0.3.0 ( you@example.com )'

docker compose --profile mcp up -d
```

The endpoint is then at `http://localhost:5100/mcp`, authenticated with
`Authorization: Bearer <BEETDECK_MCP_TOKEN>`.

| Variable                     | Default | What it does                                          |
|------------------------------|---------|-------------------------------------------------------|
| `BEETDECK_MCP_TOKEN`         | —       | **Required.** Bearer token(s), comma-separated         |
| `MUSICBRAINZ_USER_AGENT`     | —       | **Required.** MusicBrainz rejects anonymous clients    |
| `BEETDECK_MCP_PORT`          | `5100`  | Host port for the MCP endpoint                         |
| `BEETDECK_MCP_ALLOWED_HOSTS` | *(empty)* | Allowed `Host`/`Origin` values — see the warning below |
| `BEETDECK_MCP_READONLY`      | `false` | `true` lets the agent preview but never apply          |

> **Two things worth knowing before you expose this.** An empty
> `BEETDECK_MCP_ALLOWED_HOSTS` turns the `Host`/`Origin` check off entirely — it
> does *not* quietly fall back to localhost — so on anything but a private
> network, set it. And `BEETDECK_MCP_READONLY` gates the apply step only:
> previews still reach out to MusicBrainz/Last.fm/lrclib, and rescan, BPM
> computation and the ignore toggle sit outside the preview contract and keep
> working.

### Handy commands

A `Makefile` wraps the common operations:

```bash
make up      # start the stack (reads .env)
make down    # stop it
make logs    # tail the logs
make ps      # container status
make pull    # pull a newer image tag
```

### Upgrading

Bump `BEETDECK_TAG` in `.env`, then:

```bash
make pull && make up
```

Your library database is migrated automatically on the first start of the new
image, before it accepts any requests. Some beets upgrades take a backup copy of
the database first, as `library.db-before-*.bak` inside the `beetdeck_data`
volume — nothing prunes those, so delete them once you're happy the upgrade
went through.

## About this repository

This repo is the deployment layer — the `docker-compose.yml`, `.env.example`, and
`config.yaml.example` you need to self-host. The application source lives in
separate repositories and is bundled into the published image; you don't need it to
run beetDeck.
