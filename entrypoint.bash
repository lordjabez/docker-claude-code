#!/usr/bin/env bash
set -e

input="$*"

# Extract the prompt from the JSON input
prompt=$(echo "${input}" | jq -r '.prompt')

# Run pre-hook if provided by child image
if [[ -f /home/claude/hooks/pre.py ]]; then
    echo "Running pre-hook"
    uv run /home/claude/hooks/pre.py "${input}"
    echo "Pre-hook complete"
fi

# Always emit the prompt to stdout
echo "${prompt}"

# Run Claude from the workspace directory so it can't modify hooks or config
cd /home/claude/workspace
exit_code=0
response=$(claude --model "${CLAUDE_MODEL:-claude-opus-4-6}" \
    --dangerously-skip-permissions \
    --print \
    "${prompt}") || exit_code=$?

# Always emit the response to stdout
echo "${response}"

# Run post-hook if provided by child image
if [[ -f /home/claude/hooks/post.py ]]; then
    echo "Running post-hook"
    uv run /home/claude/hooks/post.py "${input}" "${response}"
    echo "Post-hook complete"
fi

exit "${exit_code}"
