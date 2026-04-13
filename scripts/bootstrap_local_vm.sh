#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-/tmp/k8s-data-platform-src}"
TARGET_ROOT="${TARGET_ROOT:-/opt/k8s-data-platform}"
SKIP_APT=0

usage() {
  cat <<'EOF'
Usage: bash scripts/bootstrap_local_vm.sh [options]

Bootstraps a local VM with shell scripts:
  1) validates copied repo payload
  2) installs minimal base packages (optional)
  3) syncs payload into /opt/k8s-data-platform
  4) provisions /opt/company layout links

Options:
  --repo-root <path>    Repository payload root inside the VM.
  --target-root <path>  Install target root. Defaults to /opt/k8s-data-platform.
  --skip-apt            Skip apt install for base tools.
  -h, --help            Show this help.
EOF
}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

require_path() {
  local path="$1"
  [[ -e "${path}" ]] || die "Required path not found: ${path}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-root)
      [[ $# -ge 2 ]] || die "--repo-root requires a value"
      REPO_ROOT="$2"
      shift 2
      ;;
    --target-root)
      [[ $# -ge 2 ]] || die "--target-root requires a value"
      TARGET_ROOT="$2"
      shift 2
      ;;
    --skip-apt)
      SKIP_APT=1
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

[[ "${EUID}" -eq 0 ]] || die "Run as root (sudo)."
require_path "${REPO_ROOT}"
require_path "${REPO_ROOT}/apps"
require_path "${REPO_ROOT}/infra"
require_path "${REPO_ROOT}/scripts"
require_path "${REPO_ROOT}/docs"
require_path "${REPO_ROOT}/README.md"

if [[ "${SKIP_APT}" == "0" ]]; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y --no-install-recommends rsync ca-certificates curl jq
fi

install -d -m 0755 "${TARGET_ROOT}"
rsync -a --delete "${REPO_ROOT}/" "${TARGET_ROOT}/"

bash "${TARGET_ROOT}/scripts/provision_company_layout.sh" --platform-root "${TARGET_ROOT}"

printf '[bootstrap_local_vm.sh] Bootstrap completed. target=%s\n' "${TARGET_ROOT}"
