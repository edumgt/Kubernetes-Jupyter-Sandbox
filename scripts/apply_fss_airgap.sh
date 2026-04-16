#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ENVIRONMENT="${ENVIRONMENT:-dev}"
METALLB_RANGE="${METALLB_RANGE:-}"
INGRESS_LB_IP="${INGRESS_LB_IP:-}"
SKIP_HARBOR_SECRET=1

usage() {
  cat <<'USAGE'
Usage: bash scripts/apply_fss_airgap.sh [options]

Quick apply wrapper for OVA-based VM air-gap FSS deployment.

Options:
  --env dev|prod
  --metallb-range <start-end>   Required unless --skip-modern-stack
  --ingress-lb-ip <ip>
  --use-harbor-secret            Enable harbor secret bootstrap
  -h, --help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      ENVIRONMENT="$2"; shift 2 ;;
    --metallb-range)
      METALLB_RANGE="$2"; shift 2 ;;
    --ingress-lb-ip)
      INGRESS_LB_IP="$2"; shift 2 ;;
    --use-harbor-secret)
      SKIP_HARBOR_SECRET=0; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1 ;;
  esac
done

args=(
  --env "${ENVIRONMENT}"
)

if [[ -n "${METALLB_RANGE}" ]]; then
  args+=(--metallb-range "${METALLB_RANGE}")
fi
if [[ -n "${INGRESS_LB_IP}" ]]; then
  args+=(--ingress-lb-ip "${INGRESS_LB_IP}")
fi
if [[ "${SKIP_HARBOR_SECRET}" -eq 1 ]]; then
  args+=(--skip-harbor-secret)
fi

bash "${SCRIPT_DIR}/setup_fss_platform.sh" "${args[@]}"
