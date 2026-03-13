# Runbook

## 1. 호스트 상태 확인

```bash
systemctl status docker
systemctl status k3s
```

## 2. 클러스터 상태 확인

```bash
kubectl get nodes
kubectl get pods -n data-platform
kubectl get svc -n data-platform
```

## 3. 플랫폼 배포

```bash
platform-apply.sh
```

## 4. 애플리케이션 포트

```bash
ss -tulpn | egrep '6443|30080|30081|30088|30090'
```

## 5. 로컬 컨테이너 스택

```bash
docker compose -f infra/docker/docker-compose.yml ps
```

## 6. 장애 복구 예시

### Docker 재시작

```bash
sudo systemctl restart docker
```

### k3s 재시작

```bash
sudo systemctl restart k3s
```

### 플랫폼 워크로드 재적용

```bash
kubectl rollout restart deployment/backend -n data-platform
kubectl rollout restart deployment/frontend -n data-platform
kubectl rollout restart deployment/jupyter -n data-platform
```

## 7. 보안 상태

```bash
sudo ufw status verbose
sudo fail2ban-client status
```
