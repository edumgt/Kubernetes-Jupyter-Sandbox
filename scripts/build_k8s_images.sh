#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="${TMP_DIR:-${ROOT_DIR}/.tmp-k8s-images}"
DRY_RUN=0

IMAGES=(
  "backend|apps/backend|harbor.local/data-platform/backend:latest"
  "frontend|apps/frontend|harbor.local/data-platform/frontend:latest"
  "airflow|apps/airflow|harbor.local/data-platform/airflow:latest"
  "jupyter|apps/jupyter|harbor.local/data-platform/jupyter:latest"
)

usage() {
  cat <<'EOF'
Usage: bash scripts/build_k8s_images.sh [options]

Options:
  --dry-run   Print build/import commands without executing them.
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
require_command sudo

run_cmd mkdir -p "${TMP_DIR}"

for item in "${IMAGES[@]}"; do
  IFS='|' read -r name context image <<<"${item}"
  archive="${TMP_DIR}/${name}.tar"

  build_args=(docker build -t "${image}")
  if [[ "${name}" == "frontend" ]]; then
    build_args+=(--build-arg "VITE_API_BASE_URL=http://localhost:30081")
  fi
  build_args+=("${ROOT_DIR}/${context}")

  run_cmd "${build_args[@]}"
  run_cmd docker save -o "${archive}" "${image}"
  run_cmd sudo k3s ctr images import "${archive}"
done
