#!/bin/sh
# Bring the beets library schema up to date, single-process, before the app
# starts serving.
#
# WHY THIS EXISTS: beets runs its DB migrations inside *any*
# `beets.library.Library(...)` construction — not just the `beet` CLI — and the
# app builds a fresh Library per call, outside its init lock
# (backend beetdeck/utils.py, `_init_beets`). Recording a completed migration is
# a bare `INSERT INTO migrations`, and creating the schema is a bare
# `CREATE TABLE`, so two of gunicorn's threads reaching a not-yet-migrated
# library at the same time is a hard failure — measured on beets 2.13.1 as 2 of 4
# concurrent cold opens dying with `table items already exists` /
# `sqlite3.IntegrityError`. Upstream is still unfixed.
#
# One open here, before any request thread exists, makes every later open a
# no-op hash hit. It is idempotent: on subsequent boots the `migrations` rows
# already exist and this costs a few milliseconds.
#
# 2.13 also copies the whole DB to `<library>.db-before-items-<name>.bak` before
# each migration it applies, and nothing prunes them. See README → Upgrading.
set -e

# Only the Flask app opens the beets library. The MCP sidecar runs from this
# same image with its own `command:` and reaches the library over HTTP, so it
# has no /data mount and must not try to migrate. Matching on the CMD below
# keeps that split in one place instead of adding a compose-side opt-out.
case "$1" in
gunicorn)
    python - <<'PY'
import os
import sys

import beets
import beets.library

db = os.environ.get("BEETS_LIBRARY_DB", "/data/beets/library.db")
music = (
    os.environ.get("BEETS_LIBRARY_ROOT")
    or os.environ.get("BEETS_IMPORT_DIR")
    or "/music"
)

# Normally the compose volume provides this; create it so a bare `docker run`
# fails on something more useful than "unable to open database file".
parent = os.path.dirname(db)
if parent:
    os.makedirs(parent, exist_ok=True)

# Read the operator's config (BEETSDIR) rather than beets' defaults, so this
# open honours the same `timeout` and `create_backup_before_migrations` the app
# will use. A malformed config.yaml therefore fails the container at boot
# instead of on the first request — louder, and visible in `docker logs`.
beets.config.read(user=True, defaults=True)
beets.library.Library(db, directory=music)
print(f"beetdeck: beets library schema up to date ({db})", file=sys.stderr)
PY
    ;;
esac

exec "$@"
