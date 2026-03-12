#!/usr/bin/env bash
set -euo pipefail

curl -fsS http://127.0.0.1/healthz >/dev/null
systemctl is-active --quiet nginx
exit 0
