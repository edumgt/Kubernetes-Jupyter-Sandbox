# k8s-jupyter VM/OVA Air-gap Toolkit

이 저장소는 **VM 설치, OVA 생성/내보내기, air-gap 반입/운영** 자동화에 집중한 운영 레포입니다.

## 핵심 디렉터리

```text
.
├── packer/         # VM/OVA 이미지 빌드 정의
├── scripts/        # VM 네트워크/설치/반입/검증 자동화
├── manifests/      # 클러스터 기본 인프라 매니페스트
├── offline/        # 오프라인 반입용 기본 매니페스트
├── docs/           # 단계별 운영 문서
└── infra/          # VM IP 인벤토리 문서
```

## 빠른 시작

```bash
bash scripts/phase1_build_ova_assets.sh all
bash scripts/phase2_operate_airgap_cluster.sh all
bash scripts/phase3_install_from_completed_ova.sh full
bash scripts/status_k8s.sh
bash scripts/check_vm_airgap_status.sh
```

## 설치 절차 (OVA 기준)

1. 준비물
- OVA 파일(노드 수에 맞는 이미지)
- 오프라인 번들 디렉터리(`images/*.tar`, `manifests/`)
- 이 저장소의 `scripts/` 디렉터리

2. VM 기본 설정

```bash
sudo bash scripts/set_static_ip.sh --ip <IP> --prefix 24 --gateway <GW>
sudo bash scripts/set_hostname_hosts.sh --hostname <HOSTNAME> --entry "<IP> <HOSTNAME>"
```

3. 오프라인 번들 반입

```bash
bash scripts/import_offline_bundle.sh --bundle-dir /opt/k8s-data-platform/offline-bundle --apply
```

4. 설치 후 점검

```bash
bash scripts/status_k8s.sh
bash scripts/check_vm_airgap_status.sh
```

5. OVA 재생성(필요 시)

```bash
bash ovabuild.sh --vars-file packer/variables.vmware.auto.pkrvars.hcl --dist-dir C:/ffmpeg
```

## 장애 대응

1. Kubernetes 기본 상태

```bash
bash scripts/status_k8s.sh
kubectl get nodes -o wide
kubectl get pods -A
```

2. containerd/kubelet 비정상

```bash
sudo systemctl status containerd --no-pager
sudo systemctl status kubelet --no-pager
sudo systemctl restart containerd kubelet
```

3. 오프라인 이미지 반입 실패

```bash
bash scripts/import_offline_bundle.sh --bundle-dir /opt/k8s-data-platform/offline-bundle --runtime-only
```

4. VM 네트워크 문제

```bash
ip a
ip route
cat /etc/hosts
sudo bash scripts/set_static_ip.sh --ip <IP> --prefix 24 --gateway <GW>
sudo bash scripts/set_hostname_hosts.sh --hostname <HOSTNAME> --entry "<IP> <HOSTNAME>"
```

## 문서 맵

권장 읽기 순서:
1. `README.md`
2. `docs/phase-1-build-ova.md`
3. `docs/phase-2-ova-solution-ops.md`
4. `docs/phase-3-install-airgap-from-ova.md`
5. `CHECKLIST.md`
6. `PORTS.md`
7. `CHANGELOG.md`

주요 스크립트:
- `scripts/phase1_build_ova_assets.sh`
- `scripts/phase2_operate_airgap_cluster.sh`
- `scripts/phase3_install_from_completed_ova.sh`
- `scripts/import_offline_bundle.sh`
- `ovabuild.sh`
