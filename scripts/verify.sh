#!/usr/bin/env bash
set -euo pipefail

echo '[1] Docker service'
systemctl --no-pager --full status docker | sed -n '1,40p'

echo '[2] k3s service'
systemctl --no-pager --full status k3s | sed -n '1,60p'

echo '[3] Cluster nodes'
kubectl get nodes || sudo k3s kubectl get nodes

echo '[4] Platform pods'
kubectl get pods -n data-platform || sudo k3s kubectl get pods -n data-platform

echo '[5] Listening ports'
ss -tulpn | egrep '(:80|:443|:6443|:30080|:30081|:30088|:30090)' || true
