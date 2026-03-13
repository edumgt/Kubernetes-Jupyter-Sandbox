# k8s-data-platform-ova

WSL Ubuntu에서 `Packer + Ansible`로 Ubuntu 24 기반 OVA를 만들고, 그 안에 `Docker + k3s` 단일 노드 플랫폼을 올린 뒤 아래 스택을 한 번에 실습할 수 있도록 재구성한 레포입니다.

- Kubernetes / Docker
- Python 3.12
- Node 22.22
- Ubuntu 24
- Teradata SQL(ANSI SQL) 연동용 API 골격
- MongoDB
- Redis
- Apache Airflow
- Quasar Framework(Vue 3)
- GitLab / GitLab Runner
- Harbor 연계
- Jupyter를 별도 pod로 띄우는 데이터 워크벤치 구조

## 구조 요약

```text
.
├── apps/
│   ├── airflow/          # Apache Airflow 이미지와 DAG
│   ├── backend/          # FastAPI + MongoDB/Redis/Teradata API
│   ├── frontend/         # Quasar(Vue 3) 대시보드
│   └── jupyter/          # JupyterLab 이미지와 샘플 노트북
├── ansible/             # Ubuntu 24 OVA 내부 플랫폼 부트스트랩
├── infra/
│   ├── docker/          # 로컬 개발용 docker compose
│   ├── gitlab/          # GitLab CE + GitLab Runner compose 템플릿
│   ├── harbor/          # Harbor 연계 가이드
│   └── k8s/base/        # k3s 배포용 매니페스트
├── monitoring/          # 기존 관제 스택(Prometheus/Grafana/Loki)
├── packer/              # Ubuntu 24 OVA 템플릿
└── scripts/             # 빌드/검증 스크립트
```

## 아키텍처

```text
WSL Ubuntu
  -> Packer
  -> Ubuntu 24 OVA
  -> Ansible provisioning
  -> Docker + k3s single-node host
  -> Kubernetes workloads
     - backend (FastAPI)
     - frontend (Quasar)
     - mongodb
     - redis
     - airflow
     - jupyter
  -> GitLab CI/CD
     - Harbor push
     - kubectl apply -k infra/k8s/base
```

## 빠른 시작

### 1. 변수 파일 준비

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

### 2. OVA 빌드

```bash
bash scripts/run_wsl.sh --skip-export
```

OVA까지 한 번에 생성하려면:

```bash
bash scripts/run_wsl.sh
```

옵션:

```bash
bash scripts/run_wsl.sh --with-monitoring
bash scripts/run_wsl.sh --dry-run
```

### 3. 로컬 앱 스택 실행

로컬 개발용 컨테이너 스택:

```bash
docker compose -f infra/docker/docker-compose.yml up --build
```

기본 포트:

- Frontend: `http://localhost:3000`
- Backend API: `http://localhost:8000`
- Airflow: `http://localhost:8080`
- JupyterLab: `http://localhost:8888`
- MongoDB: `localhost:27017`
- Redis: `localhost:6379`

### 4. GitLab / Runner

```bash
docker compose -f infra/gitlab/docker-compose.yml up -d
```

`infra/gitlab/runner-config.toml.template`를 참고해 실제 러너 등록 정보를 채운 뒤 사용합니다.

### 5. k3s에 배포

OVA 내부 또는 k3s가 있는 호스트에서:

```bash
kubectl apply -k infra/k8s/base
kubectl get pods -n data-platform
```

NodePort:

- Frontend: `30080`
- Backend: `30081`
- Jupyter: `30088`
- Airflow: `30090`

## 주요 구성 설명

### Backend

- `FastAPI`
- MongoDB / Redis 헬스 체크
- Teradata ANSI SQL 실행용 `/api/teradata/query`
- 샘플 쿼리 카탈로그 제공
- Jupyter/Airflow/GitLab/Harbor 링크 제공

### Frontend

- `Quasar + Vue 3 + Vite`
- 플랫폼 상태 카드, 서비스 링크, 샘플 SQL 뷰
- `Node 22.22` 빌드 스테이지 사용

### Jupyter

- `Python 3.12`
- JupyterLab
- MongoDB / Redis / Teradata Python 드라이버 포함
- 샘플 노트북 제공

### Airflow

- `apache/airflow` 기반 커스텀 이미지
- 플랫폼 헬스 체크 DAG 포함

### Harbor

Harbor는 이 레포에서 직접 풀스택으로 띄우기보다, 사내 또는 별도 환경의 Harbor를 이미지 레지스트리로 사용하는 흐름을 기본으로 잡았습니다. 배포 예시와 체크리스트는 [infra/harbor/README.md](/home/Kubernetes-OVA-SRE-Archi/infra/harbor/README.md) 에 정리했습니다.

## 파일 포인트

- OVA 템플릿: [packer/k8s-data-platform.pkr.hcl](/home/Kubernetes-OVA-SRE-Archi/packer/k8s-data-platform.pkr.hcl)
- Ansible 플레이북: [ansible/playbook.yml](/home/Kubernetes-OVA-SRE-Archi/ansible/playbook.yml)
- 로컬 compose: [infra/docker/docker-compose.yml](/home/Kubernetes-OVA-SRE-Archi/infra/docker/docker-compose.yml)
- k8s 매니페스트: [infra/k8s/base/kustomization.yaml](/home/Kubernetes-OVA-SRE-Archi/infra/k8s/base/kustomization.yaml)
- GitLab CI: [.gitlab-ci.yml](/home/Kubernetes-OVA-SRE-Archi/.gitlab-ci.yml)

## 참고

- `monitoring/` 디렉터리는 기존 Prometheus/Grafana/Loki 관제 실습 자산을 그대로 유지합니다.
- Teradata 연결은 실제 접속 정보가 없으면 mock 모드로 동작합니다.
- Harbor는 보통 별도 인프라로 운용하므로, 이 레포에서는 CI/CD와 image reference를 Harbor 기준으로 맞춰 두었습니다.
