# INSTALL.md
## Kubernetes-Jupyter-Sandbox 설치 가이드 (OVA/VM 공통)

이 문서는 `CHECK.md` 체크리스트 기준으로 운영자가 설치 시 필요한 최소 절차를 정리합니다.

## 1) 사전 준비
- OS: Ubuntu 24.04 계열
- 필수: `curl`, `vim`, `net-tools`, `kubectl`, `bash`
- 권장 권한: `sudo` 가능 사용자

## 2) 저장소 배치
- 기본 경로: `/opt/k8s-data-platform`
- 대체(검증용): `/home/ubuntu/Kubernetes-Jupyter-Sandbox`

## 3) 표준 디렉터리 구성(`/opt/company/*`)
- 아래 스크립트로 생성:

```bash
bash scripts/provision_company_layout.sh
```

생성 경로:
- `/opt/company/bin`
- `/opt/company/config`
- `/opt/company/images`
- `/opt/company/packages`
- `/opt/company/scripts`
- `/opt/company/docs`

## 4) Kubernetes 플랫폼 배포

```bash
bash scripts/svc-up.sh --env dev
```

확인:

```bash
bash scripts/status_k8s.sh --env dev
```

## 5) 종료/정리

```bash
bash scripts/svc-down.sh --env dev
```

전체 네임스페이스 정리:

```bash
bash scripts/svc-down.sh --env dev --delete-namespace
```

## 6) 백업/복구

백업:

```bash
bash scripts/backup_platform.sh --env dev
```

복구:

```bash
bash scripts/restore_platform.sh --env dev --backup-dir <backup-dir>
```

## 7) 네트워크/호스트 기본 설정

정적 IP:

```bash
sudo bash scripts/set_static_ip.sh \
  --ip 192.168.253.10 \
  --prefix 24 \
  --gateway 192.168.253.2 \
  --dns 8.8.8.8,1.1.1.1 \
  --iface ens160
```

호스트명/hosts fallback:

```bash
sudo bash scripts/set_hostname_hosts.sh \
  --hostname k8s-data-platform \
  --entry "192.168.253.10 k8s-data-platform"
```

