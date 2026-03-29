# platform-frontend

이 디렉터리는 GitLab 의 개별 app repo 로 push 하는 스캐폴드입니다.

## CI/CD 흐름

- GitLab Runner 가 pipeline 을 실행
- Kaniko 로 Harbor `data-platform/*` 이미지 빌드/푸시
- `kubectl set image` 로 Kubernetes deployment `frontend` 갱신

## 필요한 GitLab CI 변수

- `HARBOR_USERNAME`
- `HARBOR_PASSWORD`
- `NEXUS_PYPI_INDEX_URL` (backend)
- `NEXUS_PYPI_TRUSTED_HOST` (backend)
- `NEXUS_NPM_REGISTRY` (frontend)
- `NEXUS_NPM_AUTH_B64` (frontend, optional)

브랜치는 `dev` 또는 `prod`를 사용하면 환경별 namespace/dev-proxy URL이 자동으로 적용됩니다.

## 배포 대상

- Harbor image: `harbor.local/${HARBOR_PROJECT:-data-platform}/k8s-data-platform-frontend`
- Kubernetes deployment: `frontend`
