# FSS 서버 맵 (사무실 연습 기준)

이 문서는 공유된 서버 표를 그대로 재정리한 운영 메모입니다.
민감정보(패스워드)는 저장하지 않고, 사용자명/엔드포인트 중심으로 기록합니다.

## 1) 인프라/도구 서버

- ESXi: `10.111.111.70` (`https://10.111.111.70`)
- NFS 시뮬레이터: `192.168.10.2` (`http://10.111.111.75:8080`)
- Harbor(사무실): `10.111.111.72` / 반입 대역 `10.110.2.195`
- GitLab(사무실): `10.111.111.71` / 반입 대역 `10.110.2.193`
- ELTFR(사무실): `10.111.111.74` / 반입 대역 `10.110.2.186`

## 2) Kubernetes 노드

- `master-1`: `10.110.2.215` (SSH port `10022`)
- `worker-1`: `10.110.2.216` (SSH port `10022`, NFS NIC `192.168.10.x`)
- `worker-2`: `10.110.2.217` (SSH port `10022`, NFS NIC `192.168.10.x`)
- `worker-ml-1`: `10.110.2.218` (SSH port `10022`, NFS NIC `192.168.10.x`)

MetalLB 단일 IP(개발): `10.111.111.77`

## 3) Bastion 정리

- 사무실 설치 작업용 bastion: `10.111.111.76`
- 내부 대역 기준 표기: `10.110.2.100`
- 이 bastion은 "반입 대상 N"(비반입) 이므로, VMware 화면에서 4개 K8s 노드만 보일 수 있습니다.

즉, 화면에 `master/worker` 4대만 보이는 것은 정상이며,
필요 시 `docs/bh-bastion-setup.md` 절차로 `bh`를 별도로 만들어 동일 방식으로 연습하면 됩니다.

## 4) 연습용 env 파일

- 서버 맵 변수 템플릿: `scripts/templates/fss-office-inventory.env.example`
- 클러스터 부트스트랩 템플릿: `scripts/templates/fss-office-dev.env.example`

실행 전에는 런타임 파일로 복사해서 사용하세요.

```bash
mkdir -p /home/disadm/fss-support/k8s-dev/runtime
cp scripts/templates/fss-office-inventory.env.example /home/disadm/fss-support/k8s-dev/runtime/fss-office-inventory.env
cp scripts/templates/fss-office-dev.env.example /home/disadm/fss-support/k8s-dev/runtime/fss-office-dev.env
```
