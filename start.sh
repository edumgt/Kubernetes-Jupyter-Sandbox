#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERLAY="${1:-dev}"

case "$OVERLAY" in
  dev|prod) ;;
  *)
    echo "Usage: $0 [dev|prod]"
    exit 1
    ;;
esac

echo "[start.sh] Applying FSS manifests overlay: ${OVERLAY}"
kubectl apply -k "${ROOT_DIR}/infra/k8s/fss/overlays/${OVERLAY}"

echo "[start.sh] Done."
if [[ "${OVERLAY}" == "dev" ]]; then
  echo "[start.sh] MetalLB / ingress access check:"
  echo "  kubectl -n ingress-nginx get svc ingress-nginx-controller -o wide"
fi
