#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-${ROOT_DIR}/docs/screenshots}"
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: bash scripts/capture_k8s_screenshots.sh [options]

Options:
  --dry-run   Print the Playwright container command without executing it.
  -h, --help  Show this help.
EOF
}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

run_cmd() {
  if [[ "${DRY_RUN}" == "1" ]]; then
    printf '+'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi

  "$@"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

require_command docker
run_cmd mkdir -p "${OUTPUT_DIR}"

run_cmd docker run --rm \
  --network host \
  -v "${ROOT_DIR}:/workspace" \
  -w /workspace \
  mcr.microsoft/playwright:v1.53.0-jammy \
  node scripts/playwright/capture.mjs
