#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/kubernetes_runtime.sh
source "${SCRIPT_DIR}/lib/kubernetes_runtime.sh"

ENVIRONMENT="dev"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      [[ $# -ge 2 ]] || { printf '--env requires a value\n' >&2; exit 1; }
      ENVIRONMENT="$2"
      shift 2
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      exit 1
      ;;
  esac
done

case "${ENVIRONMENT}" in
  dev|prod) ;;
  *)
    printf 'Unsupported environment: %s\n' "${ENVIRONMENT}" >&2
    exit 1
    ;;
esac

NAMESPACE="data-platform-${ENVIRONMENT}"

echo '[1] Kubernetes services'
show_kubernetes_service_status

echo '[2] Cluster nodes'
run_kubectl get nodes

echo '[3] Platform pods'
run_kubectl get pods -n "${NAMESPACE}"

echo '[4] Services'
run_kubectl get svc -n "${NAMESPACE}"

echo '[5] Persistent volumes'
run_kubectl get pvc -n "${NAMESPACE}"
