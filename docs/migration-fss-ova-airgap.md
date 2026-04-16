# Migration Guide: FSS OVA Air-gap

이 문서는 기존 `k8s-jupyter` 경로 체계를 `k8s-fss` 기준 OVA/air-gap 구조로 전환할 때의 기준 매핑입니다.

## 경로 매핑

| 레거시 | 신규 표준 | 비고 |
|---|---|---|
| `apps/*` | `applications/*` | FSS 앱 소스 표준 경로 |
| `infra/k8s/fss/*` | `manifests/fss/*` | FSS 배포 기준 |
| `offline/manifests/*` | `manifests/platform/*`, `manifests/apps/*` | 플랫폼/Headlamp 분리 |
| `infra/*` (k8s 관련 혼합) | `infra/192.168.56.x/*` | VM 인벤토리 중심 |

## 배포 명령 변경

이전:

```bash
kubectl apply -k infra/k8s/fss/overlays/dev
```

현재:

```bash
kubectl apply -k manifests/fss/overlays/dev
```

## 스크립트 동작 기준

- `scripts/setup_fss_platform.sh`:
  - 우선 `manifests/fss/overlays/<env>` 사용
  - 없으면 `infra/k8s/fss/overlays/<env>` fallback

- `scripts/setup_ingress_metallb.sh`:
  - 우선 `manifests/platform/*.yaml` 사용
  - 없으면 `offline/manifests/*.yaml` fallback

- `scripts/setup_kubernetes_dashboard.sh`:
  - 우선 `manifests/apps/headlamp-offline.yaml` 사용
  - 없으면 bundle/legacy 경로 fallback

## 운영 권장

1. 신규 작업은 `applications/`, `manifests/`, `infra/<IP>/`만 사용
2. 레거시 경로는 점진 폐기 대상(호환성 목적)
3. CI/CD 또는 배포 스크립트는 `manifests/fss/overlays/{dev,prod}` 기준으로 통일
