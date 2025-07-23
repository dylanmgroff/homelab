# Add Rancher Helm Repository
```
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
kubectl create namespace cattle-system
```

# Install Rancher
```
helm install rancher rancher-stable/rancher \
--namespace cattle-system \
--set hostname=rancher.manly.dylangroff.com \
--set bootstrapPassword=admin
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