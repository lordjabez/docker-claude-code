# Project: docker-claude-code

Minimal Docker image for running Claude Code as a headless task runner.

## Structure

Single-file project: just a `Dockerfile`. No build scripts, no CI config yet.

## Design principles

- Minimal image: only what Claude Code needs to execute tasks (Python, uv, bash basics)
- No git, SSH, or dev toolchains beyond Python
- Non-root user (`claude`)
- Headless only: entrypoint uses `-p` and `--dangerously-skip-permissions`
- Auth is caller's responsibility via environment variables

## Image registry

Published as `lordjabez/claude-code` on Docker Hub.
