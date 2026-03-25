# Project: docker-claude-code

Minimal Docker image for running Claude Code as a headless task runner.

## Structure

- `Dockerfile` — image definition
- `entrypoint.bash` — wrapper script that runs optional hooks around Claude invocation
- `hooks/pre.py` — no-op pre-hook example; child images replace with their own
- `hooks/post.py` — no-op post-hook example; child images replace with their own
- `bin/build.bash` — builds the image locally
- `bin/run.bash` — runs a JSON input containing a prompt against the local image
- `bin/push.bash` — pushes the image to Docker Hub
- `.github/workflows/publish.yml` — CI/CD pipeline that builds and pushes on every push to main

## Design principles

- Minimal image: only what Claude Code needs to execute tasks (Python, uv, bash basics)
- No git, SSH, or dev toolchains beyond Python
- Non-root user (`claude`)
- Default model: `claude-opus-4-6`, overridable via `CLAUDE_MODEL` env var
- Headless only: entrypoint uses `-p` and `--dangerously-skip-permissions`
- Auth is caller's responsibility via environment variables
- Extensible via derivative images: child images can add tools, config, data, and optional Python pre/post hooks (`pre.py`, `post.py`) in `/home/claude/hooks/`, executed via `uv run`

## CI/CD

GitHub Actions workflow (`.github/workflows/publish.yml`) builds and pushes on every push to main. The image is tagged `latest` plus the installed Claude Code CLI version (e.g. `2.1.83`). Multi-platform: linux/amd64 and linux/arm64. Requires `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` repository secrets.

## Image registry

Published as `lordjabez/claude-code` on Docker Hub.
