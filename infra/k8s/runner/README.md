# GitLab Runner Overlay

이 오버레이는 GitLab Runner 를 `kubernetes executor` 기준으로 배포합니다.

## 적용 순서

1. [secret.example.yaml](/home/Kubernetes-OVA-SRE-Archi/infra/k8s/runner/secret.example.yaml#L1)의 `token` 값을 실제 runner token으로 변경합니다.
2. 다음 명령으로 오버레이를 적용합니다.

```bash
kubectl apply -k infra/k8s/runner
kubectl scale deployment/gitlab-runner -n data-platform --replicas=1
```

## 메모

- 기본 `replicas` 는 `0` 입니다.
- 토큰 반영 전에는 scale 하지 않는 것을 권장합니다.
