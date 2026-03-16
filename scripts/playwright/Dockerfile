FROM docker.io/edumgt/platform-node:22.22.0-bookworm-slim

ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 \
    NODE_ENV=production \
    NODE_PATH=/opt/playwright-runner/node_modules

WORKDIR /opt/playwright-runner

COPY scripts/playwright/package.json package.json
RUN npm install --omit=dev --no-audit --no-fund

WORKDIR /workspace
