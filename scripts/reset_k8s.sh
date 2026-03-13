#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WITH_RUNNER=1
DRY_RUN=0
DELETE_NAMESPACE=0

usage() {
  cat <<'EOF'
Usage: bash scripts/reset_k8s.sh [options]

Options:
  --skip-runner       Do not delete the GitLab Runner overlay.
  --delete-namespace  Delete the full data-platform namespace instead of manifest-by-manifest deletion.
  --dry-run           Print commands without executing them.
  -h, --help          Show this help.
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
    --skip-runner)
      WITH_RUNNER=0
      shift
      ;;
    --delete-namespace)
      DELETE_NAMESPACE=1
      shift
      ;;
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

require_command kubectl

if [[ "${DELETE_NAMESPACE}" == "1" ]]; then
  run_cmd kubectl delete namespace data-platform --ignore-not-found
  exit 0
fi

if [[ "${WITH_RUNNER}" == "1" ]]; then
  run_cmd kubectl delete -k "${ROOT_DIR}/infra/k8s/runner" --ignore-not-found
fi

run_cmd kubectl delete -k "${ROOT_DIR}/infra/k8s/base" --ignore-not-found
