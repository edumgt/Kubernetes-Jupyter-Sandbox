# k8s-fss-ova-airgap

이 저장소는 `/home/ubuntu/k8s-fss` 환경구성을 기준으로, **OVA 중심 VM air-gap 운영**을 위한 표준 구조로 개편된 레포입니다.

## 현재 표준 구조

```text
.
├── applications/   # 앱 소스(backend/frontend/router/jupyter/airflow)
├── manifests/      # Kubernetes 매니페스트(fss/platform/apps/addons)
├── infra/          # VM IP 인벤토리(192.168.56.x)
├── scripts/        # OVA/air-gap 설치·검증 자동화
├── packer/         # OVA 빌드 정의
└── offline/        # 레거시 오프라인 번들 경로(호환 유지)
```

## VMware 기준 대상 토폴로지

- Control Plane: `192.168.56.10`
- Worker: `192.168.56.11~13`
- NFS/Storage: `192.168.56.20`
- General VM: `192.168.56.31~35`
- MetalLB VIP: `192.168.56.240`

상세 VM 인벤토리: `infra/README.md`, `infra/192.168.56.*/server종류.md`

## Air-gap 운영 표준 순서

1. OVA 준비/반입
- `docs/phase-1-build-ova.md`

2. OVA 내부 솔루션 운영
- `docs/phase-2-ova-solution-ops.md`

3. 완성 OVA 배포 후 폐쇄망 설치
- `docs/phase-3-install-airgap-from-ova.md`

## Kubernetes 배포

플랫폼 애드온 + FSS 오버레이 적용:

```bash
bash scripts/setup_fss_platform.sh \
  --env dev \
  --metallb-range 192.168.56.240-192.168.56.240 \
  --ingress-lb-ip 192.168.56.240 \
  --skip-harbor-secret
```

직접 적용 시:

```bash
kubectl apply -f manifests/platform/calico.yaml
kubectl apply -f manifests/platform/ingress-nginx.yaml
kubectl apply -f manifests/platform/metallb-native.yaml
kubectl apply -f manifests/platform/metrics-server.yaml
kubectl apply -k manifests/fss/overlays/dev
```

## 주요 접속

- Ingress VIP: `http://192.168.56.240/`
- Headlamp: `http://192.168.56.240/headlamp-dashboard/?lng=en`

## 오프라인 준비 검증

```bash
bash scripts/check_offline_readiness.sh
```

검증 항목:
- repo/bundle 매니페스트 존재
- containerd preload 이미지 존재
- `ImagePullBackOff`, `ErrImagePull` 잔존 여부

## 호환 정책

기존 자동화/문서 호환을 위해 아래 경로는 당분간 유지합니다.

- `apps/`
- `infra/k8s/`
- `offline/manifests/`

새 표준은 `applications/`, `manifests/`, `infra/<IP>/` 입니다.

경로 매핑 상세: `docs/migration-fss-ova-airgap.md`
