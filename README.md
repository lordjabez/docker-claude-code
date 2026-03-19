# docker-claude-code

A minimal Docker image for running Claude Code in headless mode. Designed as a
sandboxed task runner: mount a workspace, pass a prompt, get results.

## What's included

- Claude Code CLI (headless/`-p` mode with permissions skipped)
- Python (latest CPython via uv)
- uv package manager
- Standard bash utilities (bash, curl, jq)

## What's not included

This image is intentionally minimal. No git, no SSH, no development toolchains
beyond Python. The container is the sandbox boundary.

## Authentication

Pass credentials via environment variables. The image supports multiple backends:

**Anthropic API key:**

```bash
docker run --rm -e ANTHROPIC_API_KEY \
  lordjabez/claude-code:latest "your prompt here"
```

**AWS Bedrock:**

```bash
docker run --rm \
  -e CLAUDE_CODE_USE_BEDROCK=1 \
  -e AWS_REGION=us-east-1 \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN \
  lordjabez/claude-code:latest "your prompt here"
```

On ECS/Fargate, the task role provides credentials automatically; only
`CLAUDE_CODE_USE_BEDROCK=1` and `AWS_REGION` are needed.

**Google Cloud Vertex AI:**

```bash
docker run --rm \
  -e CLAUDE_CODE_USE_VERTEX=1 \
  -e CLOUD_ML_REGION=us-east5 \
  -e ANTHROPIC_VERTEX_PROJECT_ID=my-project \
  -v ~/.config/gcloud:/home/claude/.config/gcloud:ro \
  lordjabez/claude-code:latest "your prompt here"
```

## Workspace

Mount a directory to `/home/claude/workspace` to give Claude Code files to work with:

```bash
docker run --rm \
  -e ANTHROPIC_API_KEY \
  -v $(pwd):/home/claude/workspace \
  lordjabez/claude-code:latest "refactor the code in workspace/"
```

## Security model

- Runs as a non-root `claude` user
- `--dangerously-skip-permissions` is set because the container itself is the
  permission boundary
- Auto-updates and telemetry are disabled

## License

MIT
