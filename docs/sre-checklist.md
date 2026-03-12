# SRE Checklist

## Reliability
- [ ] `/healthz` 응답 확인
- [ ] NGINX systemd restart 정책 확인
- [ ] time sync(chrony) 정상 확인
- [ ] 디스크 사용률 80% 이하 확인

## Observability
- [ ] node exporter 메트릭 수집 확인
- [ ] nginx exporter 메트릭 수집 확인
- [ ] Grafana 대시보드 정상 확인
- [ ] Loki 로그 수집 확인

## Security
- [ ] UFW 활성화 확인
- [ ] fail2ban 정상 동작 확인
- [ ] SSH 접근 정책 확인
- [ ] unattended-upgrades 설정 확인

## Performance
- [ ] p95 응답시간 측정
- [ ] worker_connections / keepalive 설정 확인
- [ ] access log volume / rotation 확인

## Operational Readiness
- [ ] Runbook 최신화
- [ ] 복구 절차 문서화
- [ ] Import / Export 절차 재현 확인
