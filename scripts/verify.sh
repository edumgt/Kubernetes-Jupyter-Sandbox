#!/usr/bin/env bash
set -euo pipefail

echo '[1] k3s service'
systemctl --no-pager --full status k3s | sed -n '1,60p'

echo '[2] Cluster nodes'
kubectl get nodes || sudo k3s kubectl get nodes

echo '[3] Platform pods'
kubectl get pods -n data-platform || sudo k3s kubectl get pods -n data-platform

echo '[4] Services'
kubectl get svc -n data-platform || sudo k3s kubectl get svc -n data-platform

echo '[5] Persistent volumes'
kubectl get pvc -n data-platform || sudo k3s kubectl get pvc -n data-platform
