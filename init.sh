#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cat <<MSG
[init.sh] Legacy VM bootstrap flow has been removed.
[init.sh] This repository is now aligned to 3.docx server migration mode.
[init.sh] Apply manifests directly:
  kubectl apply -k "${ROOT_DIR}/infra/k8s/fss/overlays/dev"
MSG
