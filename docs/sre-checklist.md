# SRE Checklist

- [ ] `systemctl status docker` 가 `active (running)` 인가
- [ ] `systemctl status k3s` 가 `active (running)` 인가
- [ ] `kubectl get nodes` 결과가 `Ready` 인가
- [ ] `kubectl get pods -n data-platform` 에서 핵심 워크로드가 정상 기동되는가
- [ ] Frontend `30080`, Backend `30081`, Jupyter `30088`, Airflow `30090` 접근이 가능한가
- [ ] MongoDB / Redis 가 Backend 헬스 응답에 반영되는가
- [ ] Jupyter pod 에서 노트북 파일이 보이는가
- [ ] Airflow DAG `platform_health_check` 가 로드되는가
- [ ] GitLab CI 가 Harbor 로 이미지를 push 할 수 있는가
- [ ] 보안 그룹/UFW 에서 운영 포트만 열려 있는가
