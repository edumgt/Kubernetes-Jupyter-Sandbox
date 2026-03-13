# Harbor Integration Notes

이 레포는 Harbor를 별도 인프라 또는 사내 공용 레지스트리로 운용하는 것을 기본 가정으로 둡니다.

## 권장 구성

- Harbor 프로젝트: `data-platform`
- Public project 또는 robot account 사용
- 이미지 경로:
  - `harbor.local/data-platform/backend:latest`
  - `harbor.local/data-platform/frontend:latest`
  - `harbor.local/data-platform/airflow:latest`
  - `harbor.local/data-platform/jupyter:latest`

## GitLab 변수

GitLab CI/CD 변수로 아래 값을 등록합니다.

- `HARBOR_REGISTRY`
- `HARBOR_PROJECT`
- `HARBOR_USER`
- `HARBOR_PASSWORD`
- `KUBECONFIG_B64`

## 운영 메모

- 사내 TLS 인증서를 쓰는 Harbor라면 k3s/Docker 호스트에 해당 CA를 신뢰 저장소로 배포해야 합니다.
- 첫 실습은 Harbor 프로젝트를 public 으로 두면 k8s image pull secret 없이 시작할 수 있습니다.
- private project 를 쓰면 deployment 에 `imagePullSecrets` 를 추가하세요.
