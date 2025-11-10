# Install Rancher 
## Add Rancher Helm Repository
```bash
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
kubectl create namespace cattle-system
```
## Install Rancher
```bash
helm install rancher rancher-stable/rancher \
--namespace cattle-system \
--set hostname=rancher.manly.dylangroff.com \
--set bootstrapPassword=admin
kubectl -n cattle-system rollout status deploy/rancher
kubectl -n cattle-system get deploy rancher
```
## Expose Rancher via Loadbalancer
```bash
kubectl get svc -n cattle-system
kubectl expose deployment rancher --name=rancher-lb --port=443 --type=LoadBalancer -n cattle-system
kubectl get svc -n cattle-system
```