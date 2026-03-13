# Runbook

## 1. 호스트 상태 확인

```bash
systemctl status k3s
```

## 2. 클러스터 상태 확인

```bash
kubectl get nodes
kubectl get pods -n data-platform
kubectl get svc -n data-platform
kubectl get pvc -n data-platform
```

## 3. 플랫폼 적용

```bash
bash scripts/apply_k8s.sh
```

## 4. 플랫폼 초기화

```bash
bash scripts/reset_k8s.sh
```

## 5. 주요 NodePort 확인

```bash
kubectl get svc -n data-platform
```

## 6. 장애 복구 예시

```bash
sudo systemctl restart k3s
kubectl rollout restart deployment/backend -n data-platform
kubectl rollout restart deployment/frontend -n data-platform
kubectl rollout restart deployment/jupyter -n data-platform
kubectl rollout restart deployment/airflow -n data-platform
kubectl rollout restart deployment/gitlab -n data-platform
```

## 7. Runner 활성화

```bash
kubectl apply -k infra/k8s/runner
kubectl scale deployment/gitlab-runner -n data-platform --replicas=1
```

## 8. 보안 상태

```bash
sudo ufw status verbose
sudo fail2ban-client status
```
