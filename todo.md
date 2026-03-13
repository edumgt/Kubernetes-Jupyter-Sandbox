지금 요구는 사용자별 Jupyter 세션 -> 작업 저장 -> Harbor 이미지화 -> 다음 로그인 시 그 사용자 이미지로 재기동 흐름으로 이해했습니다. 먼저 현재 per-user Jupyter 세션 로직과 Harbor 관련 설정을 다시 확인해서, 최소한의 추가로 snapshot/publish/restore 경로를 넣을 수 있게 구조를 잡겠습니다.

이번 변경의 핵심은 두 가지입니다. per-user workspace를 PVC subPath로 지속시키고, 그 workspace를 Kaniko Job으로 Harbor 이미지로 올린 뒤, 다음 세션 생성 시 그 이미지를 우선 사용하도록 백엔드와 UI를 같이 확장하겠습니다.

Jupyter 쪽은 공통 식별자와 workspace 경로가 여러 군데서 쓰이게 되어서, 먼저 username -> session id -> pod/service/workspace/image 규칙을 한 군데로 모으고 그 위에 snapshot 모듈을 얹겠습니다.



전체 프로세스를 flowchart 및 sequence 로 readme 에 포함시켜줘
Steer


현재 이 구조가 k8s 가 맞는지 다시 한번 확인 하고, 아니면 k8s 로 맞춰줘
Steer


이 repo 에 사용한 모든 컨테이너를 https://hub.docker.com/repositories/edumgt 에 public 하게 push 히고, 이후 pull 은 모두 https://hub.docker.com/repositories/edumgt 에서 하도록 수정변경
Steer


github actions 에서 변경 docker container 에 대한 docker hub push, 내 로컬 환경의 docker 구성으로
Steer


이후 폐쇄망에서 사용하기 위한 라이브러리 다운로드 등 모든 작업을 해줘
Steer


이걸 OVA VM 이미지로 구성할때, docker 엔진, vi 에디터, curl 등 필요로 하는 모든 솔루션 , 라이브러리 , 모듈도 미리 설치하고, OS 는 ubuntu 로 