# nginx-sre-ova

WSL Ubuntu 환경에서 **Packer + Ansible**로 NGINX 기반 단일 VM을 만들고, SRE 관점의 기본 운영 요소를 포함한 뒤 **OVA로 export하여 VMware에서 배포**하는 실습용 레포입니다.

이 레포는 다음 목적에 맞춰 구성했습니다.

- WSL Ubuntu에서 재현 가능한 빌드 흐름
- NGINX 서비스 + 기본 보안 + 헬스체크 + 메트릭 + 로그 수집
- VMware Workstation / Player / vSphere 계열로 가져갈 수 있는 OVA 산출물 생성
- 로컬 관제 스택(Prometheus / Grafana / Loki / Promtail) 동봉

## 포함 구성

### 서비스
- NGINX
- 정적 헬스 엔드포인트 `/healthz`
- 상태 엔드포인트 `/nginx_status`
- 샘플 index 페이지

### SRE 기본 요소
- **Monitoring**: node exporter, nginx prometheus exporter
- **Logging**: promtail, loki 연동 샘플
- **Security**: ufw, fail2ban, unattended-upgrades
- **Reliability**: systemd override, healthcheck script, restart 정책
- **Operations**: logrotate, chrony, journal 관리

### 로컬 관제 스택
- Prometheus
- Grafana
- Loki
- Promtail

---

## 디렉터리 구조

```text
nginx-sre-ova/
├── README.md
├── docs/
│   ├── runbook.md
│   └── sre-checklist.md
├── packer/
│   ├── nginx-sre.pkr.hcl
│   ├── variables.pkr.hcl.example
│   └── http/
│       └── meta-data
├── ansible/
│   ├── inventory.ini
│   ├── playbook.yml
│   └── roles/
│       ├── base/
│       ├── nginx/
│       ├── exporters/
│       ├── logging/
│       └── security/
├── monitoring/
│   ├── docker-compose.yml
│   ├── prometheus/
│   │   └── prometheus.yml
│   ├── loki/
│   │   └── local-config.yaml
│   ├── promtail/
│   │   └── config.yml
│   └── grafana/
│       ├── dashboards/
│       │   └── nginx-sre-overview.json
│       └── provisioning/
│           ├── dashboards/
│           │   └── dashboards.yml
│           └── datasources/
│               └── datasources.yml
├── scripts/
│   ├── build_ova.sh
│   ├── export_ova.ps1
│   ├── healthcheck.sh
│   └── verify.sh
└── .github/
    └── workflows/
        └── validate.yml
```

---

## 전체 흐름

```text
WSL Ubuntu
   ↓
Packer (vmware-iso)
   ↓
Ansible Provisioning
   ↓
VMX / VMDK 산출
   ↓
OVF Tool 로 OVA export
   ↓
VMware Import
```

---

## 사전 요구사항

### Windows 측
- VMware Workstation Pro / Player 또는 VMware Fusion 계열
- VMware OVF Tool
- Ubuntu Server ISO 파일

### WSL Ubuntu 측
- packer
- ansible
- sshpass
- curl
- jq

예시:

```bash
sudo apt update
sudo apt install -y ansible sshpass curl jq unzip
```

Packer 설치는 HashiCorp 공식 저장소 또는 바이너리 사용.

---

## 빠른 시작

### 1) 변수 파일 준비

```bash
cp packer/variables.pkr.hcl.example packer/variables.pkr.hcl
```

`packer/variables.pkr.hcl`에서 다음 값을 환경에 맞게 수정합니다.

- `iso_url`
- `iso_checksum`
- `vmware_workstation_path`
- `ovftool_path_windows`
- `ssh_username`
- `ssh_password`

### 2) ISO 준비

Windows에 ISO를 두고 WSL 경로로 접근하거나, WSL 파일시스템 안에 둡니다.

예:

```hcl
iso_url = "file:///mnt/c/isos/ubuntu-22.04.5-live-server-amd64.iso"
```

### 3) 이미지 빌드

WSL에서 전체 빌드 흐름을 한 번에 실행하려면:

```bash
bash scripts/run_wsl.sh
```

옵션 예시:

```bash
bash scripts/run_wsl.sh --with-monitoring
bash scripts/run_wsl.sh --skip-export
```

직접 명령을 나눠 실행하려면:

```bash
cd packer
packer init .
packer validate -var-file=variables.pkr.hcl nginx-sre.pkr.hcl
packer build -var-file=variables.pkr.hcl nginx-sre.pkr.hcl
```

빌드가 끝나면 `output-nginx-sre/` 아래에 VMX/VMDK가 생성됩니다.

### 4) OVA export

WSL에서 바로 호출:

```bash
bash scripts/build_ova.sh
```

또는 Windows PowerShell에서:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\export_ova.ps1
```

성공 시 루트에 `dist/nginx-sre.ova`가 생성됩니다.

`ovftool_path_windows`는 다음 두 형식을 모두 사용할 수 있습니다.

- `C:\Program Files\VMware\VMware OVF Tool\ovftool.exe`
- `/mnt/c/Program Files/VMware/VMware OVF Tool/ovftool.exe`

---

## 빌드 결과 기본 정보

- HTTP: `80`
- node exporter: `9100`
- nginx exporter: `9113`
- nginx stub_status: `127.0.0.1:8080/nginx_status`
- health endpoint: `/healthz`

기본 페이지:

```text
NGINX SRE OVA Lab
```

---

## 모니터링 스택 실행

```bash
cd monitoring
docker compose up -d
```

접속:

- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000`
- Loki: `http://localhost:3100`

Grafana 기본 계정:

- ID: `admin`
- PW: `admin`

최초 로그인 후 변경 권장.

---

## 운영 포인트

### SLI 예시
- HTTP 200 응답률
- `/healthz` 성공률
- NGINX 응답 지연
- VM CPU / Memory / Disk 사용률

### SLO 예시
- 월간 가용성 99.9%
- `/healthz` 성공률 99.95% 이상
- p95 응답시간 300ms 이하

### Error Budget 예시
- 월 기준 허용 장애시간 약 43분

---

## 실습 시나리오

1. VMware로 OVA import
2. VM 부팅 후 HTTP 확인
3. exporter 포트 확인
4. Prometheus target 등록
5. Grafana 대시보드 확인
6. NGINX 강제 중지 후 systemd restart 정책 확인
7. UFW / fail2ban 동작 점검
8. 로그 확인 및 promtail 수집 확인

---

## 주의사항

- WSL 내부에서 VMware 빌더를 사용할 때는 **Windows 쪽 VMware 설치 경로**와 연동이 필요합니다.
- 환경에 따라 `vmware-iso` 대신 `vmware-vmx` 후처리 방식이 더 안정적일 수 있습니다.
- 자동 설치는 Ubuntu Server autoinstall 기준으로 맞춰져 있습니다.
- 네트워크, DHCP, 브리지 설정은 사용자 환경에 맞게 수정해야 합니다.

---

## 다음 확장 아이디어

- Alertmanager 추가
- Blackbox exporter 추가
- NGINX TLS 구성
- Keepalived / HAProxy 이중화 실습
- Telegraf / VictoriaMetrics 대체 실습
- Terraform + vSphere provider 로 배포 자동화
- AWS EC2 변환용 qemu-img / vmimport 흐름 추가
