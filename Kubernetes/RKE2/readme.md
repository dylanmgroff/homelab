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
`curl -sO https://raw.githubusercontent.com/dylanmgroff/homelab/refs/heads/main/Kubernetes/RKE2/kube-vip`

`cat kube-vip | sed 's/$interface/'$interface'/g; s/$vip/'$vip'/g' > $HOME/kube-vip.yaml`

`sudo mv kube-vip.yaml /var/lib/rancher/rke2/server/manifests/kube-vip.yaml`

## 2-3. Find and Replace all k3s entries to represent rke2
`sudo sed -i 's/k3s/rke2/g' /var/lib/rancher/rke2/server/manifests/kube-vip.yaml`

## 2-4. Copy kube-vip.yaml to home directory
`sudo cp /var/lib/rancher/rke2/server/manifests/kube-vip.yaml ~/kube-vip.yaml`

## 2-5. Change owner
`sudo chown $dylangroff:dylangroff kube-vip.yaml`

## 2-6. Make kube folder to run kubectl later
`mkdir ~/.kube`

## 2-7. Create the rke2 config file
```
sudo mkdir -p /etc/rancher/rke2
touch config.yaml
echo "tls-san:" >> config.yaml 
echo "  - 10.9.50.50" >> config.yaml
echo "  - 10.9.50.10" >> config.yaml
echo "  - 10.9.50.20" >> config.yaml
echo "  - 10.9.50.30" >> config.yaml
echo "write-kubeconfig-mode: 0644" >> config.yaml
echo "disable:" >> config.yaml
echo "  - rke2-ingress-nginx" >> config.yaml
```

# 2-8. Copy config.yaml to rancher directory
`sudo cp ~/config.yaml /etc/rancher/rke2/config.yaml`