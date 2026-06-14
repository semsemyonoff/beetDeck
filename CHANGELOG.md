# Changelog

All notable changes to the beetDeck release are documented here. beetDeck ships
as a single product version — each entry corresponds to one published
`semsemyonoff/beetdeck` image tag built from the pinned `backend`/`frontend`
submodule commits.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Initial deployment repository: production `docker-compose.yml`, `.env.example`,
  `config.yaml.example`, release `Makefile`, and pinned `backend`/`frontend`
  submodules.
- Self-contained multi-stage `Dockerfile` (SPA build + backend runtime) and
  `build.sh`, moved out of the backend repo — the release image now builds
  entirely from this repo, with no dependency on the DWE dev stack.
