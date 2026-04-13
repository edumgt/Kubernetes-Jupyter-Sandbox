### 현재 비번은 문서상 다음 중 하나 입니다.
- P@ssw0rd1!
- P@ssword1!

### vpn 설치 후 접속
```
ssh disadm@10.111.111.76
ssh-copy-id disadm@10.111.111.76
```

### bh 에서 각 node 접속 테스트
```
ssh -p 10022 disadm@10.110.2.215
ssh -p 10022 disadm@10.110.2.216
ssh -p 10022 disadm@10.110.2.217
ssh -p 10022 disadm@10.110.2.218
```

### k8s 설치 전 체크 사항
- 1.35.3 버젼
- Calico 로 설치
- Pod CIDR은 10.244.0.0/16

## k8s 설치

### 1) swap off
```
sudo swapoff -a
sudo sed -ri 's@^([^#].*[[:space:]]swap[[:space:]]+[^[:space:]]+[[:space:]]+.*)$@# \1@' /etc/fstab
```

### 2) 커널 모듈/네트워크
```
cat <<'EOF' | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
```
```
cat <<'EOF' | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
```

### 3) containerd 설치/설정
```
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gpg apt-transport-https containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -ri 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
```

### 4) Kubernetes v1.35 repo
```
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null
```

### 5) kubeadm/kubelet/kubectl 1.35.3 설치
```
sudo apt-get update -y
sudo apt-get install -y kubelet=1.35.3-1.1 kubeadm=1.35.3-1.1 kubectl=1.35.3-1.1
sudo apt-mark hold kubelet kubeadm kubectl
```

### 6) control plane init
```
sudo kubeadm init --kubernetes-version=v1.35.3 --apiserver-advertise-address=10.110.2.215 --pod-network-cidr=10.244.0.0/16
```

### 7) kubeconfig 설정
```
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 8) Calico 설치 (CIDR 10.244.0.0/16 적용)
```
curl -fsSL https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/calico.yaml -o calico.yaml
sed -i 's#192.168.0.0/16#10.244.0.0/16#g' calico.yaml
kubectl apply -f calico.yaml
```

### 9) 확인
```
kubectl get nodes -o wide
kubectl -n kube-system get pods -o wide
```
---
```
disadm@hdlamst-devl:~$ kubectl get nodes -o wide
NAME           STATUS     ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
hdlamst-devl   NotReady   control-plane   48s   v1.35.3   10.110.2.215   <none>        Ubuntu 24.04.4 LTS   6.8.0-106-generic   containerd://2.2.1
disadm@hdlamst-devl:~$ kubectl -n kube-system get pods -o wide
NAME                                       READY   STATUS                  RESTARTS   AGE   IP             NODE           NOMINATED NODE   READINESS GATES
calico-kube-controllers-7679b9ffb8-p7x62   0/1     Pending                 0          14s   <none>         <none>         <none>           <none>
calico-node-jx58b                          0/1     Init:ImagePullBackOff   0          14s   10.110.2.215   hdlamst-devl   <none>           <none>
coredns-7d764666f9-c85vt                   0/1     Pending                 0          48s   <none>         <none>         <none>           <none>
coredns-7d764666f9-zpbvm                   0/1     Pending                 0          49s   <none>         <none>         <none>           <none>
etcd-hdlamst-devl                          1/1     Running                 0          57s   10.110.2.215   hdlamst-devl   <none>           <none>
kube-apiserver-hdlamst-devl                1/1     Running                 0          57s   10.110.2.215   hdlamst-devl   <none>           <none>
kube-controller-manager-hdlamst-devl       1/1     Running                 0          57s   10.110.2.215   hdlamst-devl   <none>           <none>
kube-proxy-lt9fz                           1/1     Running                 0          49s   10.110.2.215   hdlamst-devl   <none>           <none>
kube-scheduler-hdlamst-devl                1/1     Running                 0          57s   10.110.2.215   hdlamst-devl   <none>           <none>
disadm@hdlamst-devl:~$ 
```

## 워커 노드 조인

### worker node 사전 준비
```
sudo swapoff -a
sudo sed -ri 's@^([^#].*[[:space:]]swap[[:space:]]+[^[:space:]]+[[:space:]]+.*)$@# \1@' /etc/fstab

cat <<'EOF' | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<'EOF' | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gpg apt-transport-https containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -ri 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl enable --now containerd

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

sudo apt-get update -y
sudo apt-get install -y kubelet=1.35.3-1.1 kubeadm=1.35.3-1.1
sudo apt-mark hold kubelet kubeadm
```

### cp 에서 토큰 생성
```
kubeadm token create --print-join-command
```

### worker node 조인
```
sudo kubeadm join 10.110.2.215:6443 --token j966jn.59wobqv8428b5cby --discovery-token-ca-cert-hash sha256:2224d3ebc0612f167469e905d54c841f94558fa461c2710f067d18e8e34811a9
```

## cp / w1 체크
```
kubectl -n kube-system get pods -o wide
kubectl describe node hdlawork1-devl | sed -n '/Conditions:/,/Addresses:/p'
```

## 나머지 worker node 동일 작업 후 최종 확인
```
disadm@hdlamst-devl:~$ kubectl get node
NAME              STATUS   ROLES           AGE   VERSION
hdlamst-devl      Ready    control-plane   37m   v1.35.3
hdlawork1-devl    Ready    <none>          23m   v1.35.3
hdlawork2-devl    Ready    <none>          2m    v1.35.3
hdlaworkml-devl   Ready    <none>          33s   v1.35.3
```