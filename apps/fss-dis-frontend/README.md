# fss-dis-frontend

`dis.fss.or.kr`용 Vue3 + Quasar SPA 프론트엔드입니다.

## 배포 대상
- Harbor image: `10.111.111.72/app/fss-dis-frontend`
- Kubernetes deployment: `fss-dis-frontend` (`infra/k8s/fss/base/dis-app.yaml`)

## 로컬 실행
```bash
cd apps/fss-dis-frontend
npm install --no-audit --no-fund
npm run dev
```

## 환경 파일
- `.env.dev` 기본 API: `http://dis.fss.or.kr`
- `.env.prod` 기본 API: `https://dis.fss.or.kr`
