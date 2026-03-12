#!/usr/bin/env bash
set -euo pipefail

echo '[1] HTTP check'
curl -I http://127.0.0.1 || true

echo '[2] Health check'
bash /usr/local/bin/healthcheck.sh && echo ok

echo '[3] Services'
systemctl --no-pager --full status nginx prometheus-node-exporter nginx-prometheus-exporter promtail | sed -n '1,80p'

echo '[4] Listening ports'
ss -tulpn | egrep '(:80|:9100|:9113|:9080)'
