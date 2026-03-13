#!/usr/bin/env bash
set -euo pipefail

kubectl get nodes
echo
kubectl get pods -n data-platform
echo
kubectl get svc -n data-platform
echo
kubectl get pvc -n data-platform
