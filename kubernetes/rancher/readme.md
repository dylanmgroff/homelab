# Install helm
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```
# Add Rancher Helm Repository
```
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
kubectl create namespace cattle-system
```

# Install Cert-Manager
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
--namespace cert-manager \
--create-namespace \
--version v1.13.2
kubectl get pods --namespace cert-manager
```

# Install Rancher
```
helm install rancher rancher-stable/rancher \
--namespace cattle-system \
--set hostname=rancher.manly.dylangroff.com \
--set bootstrapPassword=admin
--set ingress.tls.source=letsEncrypt \
--set letsEncrypt.email=me@example.org \
--set letsEncrypt.ingress.class=traefik \
--set ingress.tls.source=secret
kubectl -n cattle-system rollout status deploy/rancher
kubectl -n cattle-system get deploy rancher
```

# Apply Rancher TLS Secret
```
kubectl apply -f ~/rancher/tls-rancher-ingress.yaml
```

# Expose Rancher via Loadbalancer
```
kubectl get svc -n cattle-system
kubectl expose deployment rancher --name=rancher-lb --port=443 --type=LoadBalancer -n cattle-system
kubectl get svc -n cattle-system
```

# Go to Rancher GUI