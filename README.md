# beetDeck — deployment & release

This repository is the **release layer** for beetDeck. It contains no
application source — that lives in two repositories, pinned here as submodules:

| Submodule    | Source                                  | Role                          |
|--------------|-----------------------------------------|-------------------------------|
| `backend/`   | `beetDeck/backend` (Flask API + beets)  | App; serves API + SPA on :5000 |
| `frontend/`  | `beetDeck/frontend` (React/Vite SPA)    | Built into the image          |

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

The image is built from the **pinned submodule commits**, so a release is
reproducible: one (backend, frontend) commit pair → one version. The build is a
self-contained multi-stage `Dockerfile` (stage 1 builds the SPA, stage 2 is the
backend runtime), so it needs only Docker — not the DWE dev stack.

```bash
git submodule update --init --recursive

# Point the submodules at the commits you want to ship, then stage them.
git -C backend checkout <ref> && git -C frontend checkout <ref>
git add backend frontend

# Bump the product version and record changes.
echo 1.0.0 > VERSION
$EDITOR CHANGELOG.md

# Build the multi-arch image from the submodules and push.
make release VERSION=1.0.0

git commit -m "release: 1.0.0"
git tag v1.0.0 && git push --follow-tags
```

Smoke-test a build locally without pushing:

```bash
make release-local VERSION=1.0.0
BEETDECK_TAG=1.0.0 docker compose up -d
```

### Relationship to the DWE dev workspace

The `beetDeck` DWE workspace remains the **development** environment (live
bind-mounts, Vite HMR, separate dev containers, dbgate). This repo is strictly
about producing and running the **release** artifact. The two are independent;
nothing here changes the dev workflow.
