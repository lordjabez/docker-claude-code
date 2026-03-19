#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

prompt="${1}"

docker run --rm -e ANTHROPIC_API_KEY \
  -v $(pwd)/claude:/home/claude/.claude \
  lordjabez/claude-code:latest "${prompt}"
