# docker-claude-code

A minimal Docker image for running Claude Code in headless mode. Designed as a
sandboxed task runner: pass a JSON input object, get results.

## What's included

- Claude Code CLI (headless/`-p` mode with permissions skipped, defaults to `claude-opus-4-6`)
- Python (latest CPython via uv)
- uv package manager
- Standard bash utilities (bash, curl, jq)

## What's not included

This image is intentionally minimal. No git, no SSH, no development toolchains
beyond Python. The container is the sandbox boundary.

## Input format

The container accepts a JSON object as its argument. The `prompt` key is
required and is passed to Claude. The full JSON object is forwarded to
pre/post hooks, so child images can include additional keys for their own use.

```bash
docker run --rm -e ANTHROPIC_API_KEY \
  lordjabez/claude-code:latest '{"prompt": "say hello"}'
```

## Authentication

Pass credentials via environment variables. The image supports multiple backends:

**Anthropic API key:**

```bash
docker run --rm -e ANTHROPIC_API_KEY \
  lordjabez/claude-code:latest '{"prompt": "your prompt here"}'
```

**AWS Bedrock:**

```bash
docker run --rm \
  -e CLAUDE_CODE_USE_BEDROCK=1 \
  -e AWS_REGION=us-east-1 \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN \
  lordjabez/claude-code:latest '{"prompt": "your prompt here"}'
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
  lordjabez/claude-code:latest '{"prompt": "your prompt here"}'
```

## Workspace

Claude runs inside `/home/claude/workspace`, isolated from hooks and config.
Mount or copy files there to give Claude something to work with:

```bash
docker run --rm \
  -e ANTHROPIC_API_KEY \
  -v $(pwd):/home/claude/workspace \
  lordjabez/claude-code:latest '{"prompt": "refactor the code"}'
```

## Model override

The default model is `claude-opus-4-6`. Override it with the `CLAUDE_MODEL` env var:

```bash
docker run --rm -e ANTHROPIC_API_KEY -e CLAUDE_MODEL=claude-sonnet-4-6 \
  lordjabez/claude-code:latest '{"prompt": "your prompt here"}'
```

## Building derivative images

The image is designed as a base for specialized task runners. Child images can
install tools, bake in config and data, and wire up pre/post hooks that run
around the Claude invocation.

```dockerfile
FROM lordjabez/claude-code:latest

# Install additional tools
RUN uv pip install pandas

# Bake in Claude config
COPY claude/ /home/claude/.claude/

# Optional: bake in data or workspace files
COPY data/ /home/claude/workspace/

# Optional: add pre/post hooks
COPY hooks/pre.py /home/claude/hooks/pre.py
COPY hooks/post.py /home/claude/hooks/post.py
```

Hooks live in `/home/claude/hooks/` and are executed via `uv run`, so they have
access to any Python packages installed in the image:

- `pre.py` runs before Claude and receives the full JSON input as `sys.argv[1]`
- `post.py` runs after Claude and receives the full JSON input as `sys.argv[1]` and Claude's response as `sys.argv[2]`

Both are optional. If absent, they are silently skipped.

## Security model

- Runs as a non-root `claude` user
- Claude's working directory is `/home/claude/workspace`, keeping hooks and config out of reach
- `--dangerously-skip-permissions` is set because the container itself is the
  permission boundary
- Auto-updates and telemetry are disabled

## Development

Helper scripts in `bin/` for local development:

- `bin/build.bash` — builds the image locally
- `bin/run.bash` — runs a JSON input containing a prompt against the local image
- `bin/push.bash` — pushes the image to Docker Hub

## License

MIT-0
