#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAMESPACE="${NAMESPACE:-data-platform-dev}"
NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:30091}"
TARGET_PASSWORD="${TARGET_PASSWORD:-nexus123!}"
CURRENT_PASSWORD="${CURRENT_PASSWORD:-}"
NEXUS_USERNAME="${NEXUS_USERNAME:-admin}"
NEXUS_PASSWORD="${NEXUS_PASSWORD:-}"
OUT_DIR="${OUT_DIR:-${ROOT_DIR}/dist/nexus-prime}"
PYTHON_SEED_FILE="${PYTHON_SEED_FILE:-${ROOT_DIR}/scripts/offline/python-dev-seed.txt}"
NPM_SEED_FILE="${NPM_SEED_FILE:-${ROOT_DIR}/scripts/offline/npm-dev-seed.txt}"
SKIP_PYTHON_SEED=0
SKIP_NPM_SEED=0
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: bash scripts/setup_nexus_offline.sh [options]

Options:
  --namespace <name>       Kubernetes namespace where Nexus is deployed.
  --nexus-url <url>        Reachable Nexus base URL.
  --current-password <pw>  Current admin password (if Nexus is already initialized).
  --target-password <pw>   Password to set for the admin account after bootstrap.
  --username <name>        Repository username for cache priming.
  --password <pw>          Repository password for cache priming.
  --out-dir <path>         Output directory for warmed Python/npm caches.
  --python-seed-file <p>   Extra Python dev seed list path.
  --npm-seed-file <p>      Extra npm dev seed list path.
  --skip-python-seed       Skip extra Python dev seed warming.
  --skip-npm-seed          Skip extra npm dev seed warming.
  --dry-run                Print commands without executing them.
  -h, --help               Show this help.
EOF
}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

run_subcommand() {
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
    --namespace)
      [[ $# -ge 2 ]] || die "--namespace requires a value"
      NAMESPACE="$2"
      shift 2
      ;;
    --nexus-url)
      [[ $# -ge 2 ]] || die "--nexus-url requires a value"
      NEXUS_URL="$2"
      shift 2
      ;;
    --target-password)
      [[ $# -ge 2 ]] || die "--target-password requires a value"
      TARGET_PASSWORD="$2"
      shift 2
      ;;
    --current-password)
      [[ $# -ge 2 ]] || die "--current-password requires a value"
      CURRENT_PASSWORD="$2"
      shift 2
      ;;
    --username)
      [[ $# -ge 2 ]] || die "--username requires a value"
      NEXUS_USERNAME="$2"
      shift 2
      ;;
    --password)
      [[ $# -ge 2 ]] || die "--password requires a value"
      NEXUS_PASSWORD="$2"
      shift 2
      ;;
    --out-dir)
      [[ $# -ge 2 ]] || die "--out-dir requires a value"
      OUT_DIR="$2"
      shift 2
      ;;
    --python-seed-file)
      [[ $# -ge 2 ]] || die "--python-seed-file requires a value"
      PYTHON_SEED_FILE="$2"
      shift 2
      ;;
    --npm-seed-file)
      [[ $# -ge 2 ]] || die "--npm-seed-file requires a value"
      NPM_SEED_FILE="$2"
      shift 2
      ;;
    --skip-python-seed)
      SKIP_PYTHON_SEED=1
      shift
      ;;
    --skip-npm-seed)
      SKIP_NPM_SEED=1
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

if [[ -z "${NEXUS_PASSWORD}" ]]; then
  NEXUS_PASSWORD="${TARGET_PASSWORD}"
fi

run_subcommand bash "${ROOT_DIR}/scripts/bootstrap_nexus_repos.sh" \
  --namespace "${NAMESPACE}" \
  --nexus-url "${NEXUS_URL}" \
  --current-password "${CURRENT_PASSWORD}" \
  --target-password "${TARGET_PASSWORD}" \
  $( [[ "${DRY_RUN}" == "1" ]] && printf '%s' '--dry-run' )

prime_cmd=(
  bash "${ROOT_DIR}/scripts/prime_nexus_caches.sh"
  --nexus-url "${NEXUS_URL}"
  --username "${NEXUS_USERNAME}"
  --password "${NEXUS_PASSWORD}"
  --out-dir "${OUT_DIR}"
  --python-seed-file "${PYTHON_SEED_FILE}"
  --npm-seed-file "${NPM_SEED_FILE}"
)
if [[ "${SKIP_PYTHON_SEED}" == "1" ]]; then
  prime_cmd+=(--skip-python-seed)
fi
if [[ "${SKIP_NPM_SEED}" == "1" ]]; then
  prime_cmd+=(--skip-npm-seed)
fi
if [[ "${DRY_RUN}" == "1" ]]; then
  prime_cmd+=(--dry-run)
fi
run_subcommand "${prime_cmd[@]}"
