#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WITH_RUNNER=0
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: bash scripts/apply_k8s.sh [options]

Options:
  --with-runner    Apply the optional GitLab Runner k8s overlay too.
  --dry-run        Print commands without executing them.
  -h, --help       Show this help.
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
    --with-runner)
      WITH_RUNNER=1
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

run_cmd kubectl apply -k "${ROOT_DIR}/infra/k8s/base"

if [[ "${WITH_RUNNER}" == "1" ]]; then
  run_cmd kubectl apply -k "${ROOT_DIR}/infra/k8s/runner"
fi

if [[ "${DRY_RUN}" != "1" ]]; then
  kubectl get pods -n data-platform
fi
