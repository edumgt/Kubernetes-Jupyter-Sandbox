#!/usr/bin/env bash
set -euo pipefail

systemctl is-active --quiet docker
systemctl is-active --quiet k3s
kubectl get nodes >/dev/null 2>&1 || sudo k3s kubectl get nodes >/dev/null
exit 0
