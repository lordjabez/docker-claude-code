FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        jq && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash claude
USER claude
WORKDIR /home/claude

RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/claude/.local/bin:${PATH}"
ENV DISABLE_AUTOUPDATER=1
ENV CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/
RUN uv python install

ENTRYPOINT ["claude", "--dangerously-skip-permissions", "-p"]
