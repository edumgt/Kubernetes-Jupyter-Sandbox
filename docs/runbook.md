# Runbook

## 1. 서비스 상태 확인

```bash
systemctl status nginx
systemctl status node_exporter
systemctl status nginx-prometheus-exporter
systemctl status promtail
```

## 2. 포트 확인

```bash
ss -tulpn | egrep '80|9100|9113'
```

## 3. 헬스체크

```bash
bash /usr/local/bin/healthcheck.sh
```

## 4. 로그 확인

```bash
journalctl -u nginx -n 100 --no-pager
journalctl -u promtail -n 100 --no-pager
```

## 5. 장애 복구 예시

### NGINX 재시작
```bash
sudo systemctl restart nginx
```

### 설정 검증 후 reload
```bash
sudo nginx -t && sudo systemctl reload nginx
```

## 6. 방화벽 상태

```bash
sudo ufw status verbose
```

## 7. Fail2ban 상태

```bash
sudo fail2ban-client status
```

## 8. 패키지 보안 업데이트 확인

```bash
sudo unattended-upgrade --dry-run --debug
```
