# QUICKSTART.md
## OVA 기반 VM Air-gap 빠른 시작

## 1) 플랫폼 기본 스택 적용

```bash
bash scripts/setup_fss_platform.sh \
  --env dev \
  --metallb-range 192.168.56.240-192.168.56.240 \
  --ingress-lb-ip 192.168.56.240 \
  --skip-harbor-secret
```

## 2) 상태 확인

```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A
bash scripts/check_offline_readiness.sh
```

## 3) 주요 서비스

- Ingress: `http://192.168.56.240/`
- Headlamp: `http://192.168.56.240/headlamp-dashboard/?lng=en`

## 4) 종료/정리

```bash
bash scripts/svc-down.sh --env dev
```
