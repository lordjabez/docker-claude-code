#!/usr/bin/env bash
set -e

now_ms() { echo $(( $(date +%s%N) / 1000000 )); }
elapsed() {
    local ms=$(( $(now_ms) - $1 ))
    printf "%d.%03d" $(( ms / 1000 )) $(( ms % 1000 ))
}

input="$*"
entrypoint_start=$(now_ms)

# Extract the prompt from the JSON input
prompt=$(echo "${input}" | jq -r '.prompt')

# Run pre-hook if provided by child image
if [[ -f /home/claude/hooks/pre.py ]]; then
    pre_start=$(now_ms)
    uv run /home/claude/hooks/pre.py "${input}"
    echo "Pre-hook completed in $(elapsed "${pre_start}")s"
fi

# Always emit the prompt to stdout
echo "${prompt}"

# Run Claude from the workspace directory so it can't modify hooks or config
cd /home/claude/workspace
exit_code=0
claude_start=$(now_ms)
response=$(claude --model "${CLAUDE_MODEL:-claude-opus-4-6}" \
    --dangerously-skip-permissions \
    --print \
    "${prompt}") || exit_code=$?
echo "Claude completed in $(elapsed "${claude_start}")s (exit code ${exit_code})"

# Always emit the response to stdout
echo "${response}"

# Run post-hook if provided by child image
if [[ -f /home/claude/hooks/post.py ]]; then
    post_start=$(now_ms)
    uv run /home/claude/hooks/post.py "${input}" "${response}"
    echo "Post-hook completed in $(elapsed "${post_start}")s"
fi

echo "Total elapsed: $(elapsed "${entrypoint_start}")s"

exit "${exit_code}"
