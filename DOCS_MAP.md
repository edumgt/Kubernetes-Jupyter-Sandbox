# DOCS_MAP.md
## OVA + VM Air-gap 문서 인덱스

## 1) 권장 읽기 순서

1. `README.md`
2. `QUICKSTART.md`
3. `docs/phase-1-build-ova.md`
4. `docs/phase-2-ova-solution-ops.md`
5. `docs/phase-3-install-airgap-from-ova.md`
6. `INSTALL.md`
7. `TROUBLESHOOTING.md`
8. `CHECK.md`
9. `CHECKLIST.md`

## 2) 핵심 구조 문서

- `README.md`: 개편된 표준 구조(`applications/`, `manifests/`, `infra/<IP>`)와 실행 흐름
- `infra/README.md`: VMware IP 인벤토리
- `infra/192.168.56.*/server종류.md`: IP 단위 역할 문서
- `docs/migration-fss-ova-airgap.md`: 레거시 경로에서 신규 표준으로의 매핑

## 3) 실행 기준 문서

- OVA 생성: `docs/phase-1-build-ova.md`
- OVA 내부 운영: `docs/phase-2-ova-solution-ops.md`
- 완성 OVA 폐쇄망 설치: `docs/phase-3-install-airgap-from-ova.md`
- 빠른 실행: `QUICKSTART.md`

## 4) 운영 검증 문서

- 포트/접속: `PORTS.md`
- 장애 대응: `TROUBLESHOOTING.md`
- 품질 점검: `CHECK.md`, `CHECKLIST.md`
- 변경 이력: `CHANGELOG.md`

## 5) 호환 경로 정책

다음 경로는 기존 자동화 호환을 위해 유지합니다.

- `apps/`
- `infra/k8s/`
- `offline/manifests/`

신규 기준 경로:

- `applications/`
- `manifests/`
- `infra/<IP>/`
