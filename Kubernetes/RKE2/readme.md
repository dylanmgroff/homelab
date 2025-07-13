# 1. Install kubectl
## 1-1. ssh to node
## 1-2. Download and Validate the latest kubectl release
Download the latest release:  
`curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"`   

Download the kubectl checksum file:  
`curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"`   

Validate the kubectl binary against the checksum file:  
`echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check`  

### Validation output
If valid, the output is:  
`kubectl: OK`   

If the check fails, `sha256` exits with nonzero status and prints output similar to:  
```
kubectl: FAILED
sha256sum: WARNING: 1 computed checksum did NOT match
```
## 1-3. Install kubectl
`sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl`   
## 1-4. Test to ensure the version you installed is up-to-date:
`kubectl version --client`

# 2. Install Kube VIP
## 2-1. Create RKE2's self-installing manifest dir
`sudo mkdir -p /var/lib/rancher/rke2/server/manifests`

## 2-2. Install the kube-vip deployment into rke2's self-installing manifest folder
`curl -sO https://raw.githubusercontent.com/JamesTurland/JimsGarage/main/Kubernetes/RKE2/kube-vip`
`cat kube-vip | sed 's/$interface/'$interface'/g; s/$vip/'$vip'/g' > $HOME/kube-vip.yaml`
`sudo mv kube-vip.yaml /var/lib/rancher/rke2/server/manifests/kube-vip.yaml`