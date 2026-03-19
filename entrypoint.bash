#!/usr/bin/env bash
set -e

prompt="$*"

# Run pre-hook if provided by child image
if [[ -f /home/claude/hooks/pre.py ]]; then
    uv run /home/claude/hooks/pre.py "${prompt}"
fi

# Run Claude from the workspace directory so it can't modify hooks or config
cd /home/claude/workspace
response=$(claude --model "${CLAUDE_MODEL:-claude-opus-4-6}" \
    --dangerously-skip-permissions \
    --print \
    "${prompt}")

# Always emit response to stdout
echo "${response}"

# Run post-hook if provided by child image
if [[ -f /home/claude/hooks/post.py ]]; then
    uv run /home/claude/hooks/post.py "${prompt}" "${response}"
fi
