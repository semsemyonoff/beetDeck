# beetDeck

![logo](assets/logo.svg)

A web interface for managing a [beets](https://beets.io/) music library. beetDeck does not handle file importing — it enhances an existing library with identification (MusicBrainz autotag), genres (Last.fm), cover art, lyrics, and tag browsing.

Works well alongside tools like Lidarr that manage the file library, while beets serves as an additional tagging layer on top.

## Features

- **Library browser** — collapsible artist list with album thumbnails, year, and tagged status (Index and Wall layout)
- **Artist page** — dedicated page with album grid for a single artist
- **Album detail** — cover art, metadata, file path, full track listing with per-track action buttons
- **Multi-disc albums** — disc sections shown separately on the album page; cover art and file paths resolve to the common parent directory (e.g. `CD1/` / `CD2/` layouts)
- **Search** — full-text search across artists, albums, and tracks (full Unicode support)
- **Filter by status** — filter albums by tagged / untagged on library and artist pages
- **Identification** — MusicBrainz autotag with candidate selection, diff preview, confirm & write
- **Genre tagging** — Last.fm genre lookup with old/new preview and confirm
- **Cover art** — fetch from multiple sources (filesystem, Cover Art Archive, iTunes, Amazon), preview, confirm; manual upload supported. High-res file + embedded thumbnail
- **Lyrics** — per-track and bulk album lyrics via lrclib (synced and plain text). Inline viewer/editor, online search with diff preview, external `.lrc` file embed
- **Rescan** — quick (incremental) or full library rescan to add new files and remove stale entries
- **Untagged triage** — loose files (no albumartist) are grouped by directory and surfaced in a pinned banner atop the library; a per-folder editor offers bulk album-level fields plus a per-track grid, then a MusicBrainz identify hand-off to create a properly tagged album
- **Tag editing** — edit album-level and per-track tags (title, artist, track #, year, genre) directly from the album page via an *Edit tags* modal; album-level changes propagate to the album row and are written to every track file
- **Light/dark theme** — auto-detects system preference with manual toggle, persisted in localStorage

---

## This repository — the entry point

This is the **release layer** that ties the product together. It contains no
application source — that lives in two repositories, pinned here as submodules
and built into a single image:

| Submodule    | Source                                              | Role                          |
|--------------|-----------------------------------------------------|-------------------------------|
| `backend/`   | `semsemyonoff/beetDeck-backend` (Flask API + beets) | App; serves API + SPA on :5000 |
| `frontend/`  | `semsemyonoff/beetDeck-frontend` (React/Vite SPA)   | Built into the image          |

beetDeck ships as **one product version** = **one container** = **one image**
(`semsemyonoff/beetdeck`). The Vite SPA is built to static assets and baked into
the backend image, which Flask/gunicorn serves alongside the API on port `5000`.
There is no separate frontend container in production.

---

## For operators (self-hosting)

You only need this `README`, `docker-compose.yml`, `.env.example`, and
`config.yaml.example` — not the submodules.

```bash
cp .env.example .env                       # set image tag, host port, paths
mkdir -p config music                      # config/ holds your beets config.yaml
cp config.yaml.example config/config.yaml  # then edit if needed
docker compose up -d
```

Open `http://localhost:8080` (or the `BEETDECK_HTTP_PORT` you set), then run
**Rescan Library → Full Scan** in the UI to populate the database.

### Environment variables (`.env`)

| Variable              | Default                | Description                          |
|-----------------------|------------------------|--------------------------------------|
| `BEETDECK_IMAGE`      | `semsemyonoff/beetdeck`| Image repository                     |
| `BEETDECK_TAG`        | `latest`               | Image tag; pin to a release in prod  |
| `BEETDECK_HTTP_PORT`  | `8080`                 | Host port (container serves on 5000) |
| `BEETDECK_CONFIG_DIR` | `./config`             | Host dir bind-mounted to `/config`   |
| `BEETDECK_MUSIC_DIR`  | `./music`              | Host dir bind-mounted to `/music`    |
| `TZ`                  | `UTC`                  | Container timezone                   |

The image also honors `BEETSDIR`, `BEETS_LIBRARY_DB`, `BEETS_IMPORT_DIR`,
`BEETS_LIBRARY_ROOT` — set in `docker-compose.yml` and normally left as-is.

### Volumes

| Container path  | Source                  | Purpose                                       |
|-----------------|-------------------------|-----------------------------------------------|
| `/config`       | `BEETDECK_CONFIG_DIR`   | beets config dir (`config.yaml`) — `BEETSDIR` |
| `/music`        | `BEETDECK_MUSIC_DIR`    | audio library / import dir (read-write)       |
| `/data/beets`   | `beetdeck_data` volume  | beets SQLite DB + state (persistent)          |

The music mount must be **writable** — beetDeck writes tags, cover art, and
lyrics into the files.

Upgrade: bump `BEETDECK_TAG` in `.env`, then `make pull && make up`.
Handy commands: `make up` · `make down` · `make pull` · `make logs` · `make ps`.

---

## For maintainers (cutting a release)

A release is **reproducible**: one (backend, frontend) tag pair → one product
version → one multi-arch image, built from a self-contained `Dockerfile` (stage 1
builds the SPA, stage 2 is the backend runtime).

### Where the image is published

The same image is pushed to both public registries by CI. Operators can pull
from whichever they like via `BEETDECK_IMAGE` in `.env`:

| Registry  | Image ref                        | Built by        | Audience                 |
|-----------|----------------------------------|-----------------|--------------------------|
| Docker Hub| `semsemyonoff/beetdeck`          | GitHub Actions  | public (default)         |
| GHCR      | `ghcr.io/semsemyonoff/beetdeck`  | GitHub Actions  | public                   |

The Forgejo repo is the source of truth and push-mirrors to GitHub.

### Cutting a release (the one button)

Run **Forgejo → Actions → Cut release → Run workflow**, pick a bump
(`patch`/`minor`/`major`). The `release-cut` workflow then:

1. repins `backend`/`frontend` to their latest semver tag (or a ref you pass);
2. bumps `VERSION`;
3. appends an auto-generated `CHANGELOG.md` section from each submodule's commit
   range (refine the wording afterwards if needed — keep umbrella-level notes in
   the `Unreleased` section);
4. commits `release: X.Y.Z`, tags `vX.Y.Z`, and pushes.

The tag fans out to the build pipelines: `.forgejo/workflows/release.yml` builds
and pushes the image on internal infra, and — via the mirror —
`.github/workflows/release.yml` pushes Docker Hub + GHCR. It must be triggered on
Forgejo because the mirror is one-way (Forgejo → GitHub), so the tag has to
originate there.

A **Release** page is created on each platform from the same CHANGELOG section
(notes only, no attached assets): Forgejo via its API in `release-cut`, GitHub
via `action-gh-release` in the public build. Release objects aren't mirrored, so
each side publishes its own — that's expected.

### One-time setup

- **Push mirror** (Forgejo repo → Settings → Mirror → Push): mirror this repo to
  `github.com/semsemyonoff/deploy` (or wherever the public copy lives) with a
  GitHub PAT, so tags/commits propagate and trigger the public build.
- **GitHub secrets:** `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` (GHCR uses the
  built-in `GITHUB_TOKEN`).
- **Forgejo Actions secrets** (names can't start with `FORGEJO_`/`GITEA_`/`GITHUB_`):
  `HORN_REGISTRY_USER` + `HORN_REGISTRY_TOKEN` (a token with `write:package`) for
  the registry push, and `RELEASE_TOKEN` (a PAT with repo write) used by
  `release-cut` to push the tag. It must be a PAT — a tag pushed by the automatic
  Actions token would not trigger the build jobs.
- **Runner CA:** add the internal registry host to `FORGEJO_RUNNER_DOCKER_CA_HOSTS`
  in the git stack's `.env` and redeploy the runner, so its Docker daemon trusts
  the registry's CA when pushing (otherwise the push fails with x509).

### Local fallback

CI is the primary path, but the same build runs locally with Docker only:

```bash
git submodule update --init --recursive
git -C backend checkout <tag> && git -C frontend checkout <tag> && git add backend frontend
make release VERSION=1.0.0           # builds + pushes (override targets via IMAGES=...)
```

Smoke-test a build without pushing:

```bash
make release-local VERSION=1.0.0
BEETDECK_TAG=1.0.0 docker compose up -d
```

### Relationship to the DWE dev workspace

The `beetDeck` DWE workspace remains the **development** environment (live
bind-mounts, Vite HMR, separate dev containers, dbgate). This repo is strictly
about producing and running the **release** artifact. The two are independent;
nothing here changes the dev workflow.
