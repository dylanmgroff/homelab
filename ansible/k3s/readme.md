# Boostrap K3S

Copy K3S folder to admin machine home folder using filezilla

SSH to admin machine from iterm

```
ssh dylangroff@10.9.50.5
```

Add password to line 54 of all.yml
```
nano k3s/inventory/groupvars/all.yml
```

Install ansible requirements
```
ansible-galaxy install -r ./collections/requirements.yml
```

install netaddr
```
sudo apt install python3-pip
pip install netaddr
```

run playbook
```
ansible-playbook ./site.yml -i ./inventory/hosts.ini
```

boostrap local access
```
cd ~
mkdir .kube
scp dylangroff@10.9.50.11:~/.kube/config ~/.kube/config
```

Testing cluster
```
ping 10.9.50.11
```

ssh to master1 from iterm
```
ssh dylangroff@10.9.50.11
```

change permissions on K3S yaml
```
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
```

# Install Rancher

Install helm
```
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

add helm repo stable
```
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
```

create rancher namespace
```
kubectl create namespace cattle-system
```

install cert manager
```
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml
```

create name-space for cert-manager
```
kubectl create namespace cert-manager
```

add Jetstack Helm repository
```
helm repo add jetstack https://charts.jetstack.io
```

update helm repo
```
helm repo update
```

install cert-manager helm chart
```
	

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.7.1
```

check rollout of cert-manager
```
kubectl get pods --namespace cert-manager
```
Wait to ensure all pods have finished deployment

Install rancher with helm
```
helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=rancher.montreal.dylangroff.com
```

check rancher rollout and wait for completion
```
kubectl -n cattle-system rollout status deploy/rancher
```