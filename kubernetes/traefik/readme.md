# Add Helm Repos
```
helm repo add traefik https://traefik.github.io/charts
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo add crowdsec https://crowdsecurity.github.io/helm-charts
helm repo update
```

# Install Emberstack
```
helm install reflector emberstack/reflector --create-namespace --namespace reflector -f ~/traefik/reflector-values.yaml
```

# Install Traefik
```
helm install --namespace=default traefik traefik/traefik -f ~/traefik/traefik-values.yaml
```

# Check Traefik deployment
```
kubectl get svc
kubectl get pods
```

# Apply Middleware
```
kubectl apply -f ~/traefik/default-headers.yaml
```

# Create Secret for Traefik Dashboard
```
kubectl apply -f ~/traefik/dashboard/secret-dashboard.yaml
```

# Apply Middleware
```
kubectl apply -f ~/traefik/dashboard/middleware.yaml
```

# Apply Ingress to Access Service
```
kubectl apply -f ~/traefik/dashboard/ingress.yaml
```

# Install Crowdsec READ ALL OF THIS FIRST!!
```
helm install crowdsec crowdsec/crowdsec --namespace default -f ~/traefik/crowdsec-values.yaml
```
# Right away drop in the next command, find the container code and replace the <> then drop in that command. It will spit out a registry code.
```
kubectl get pods
kubectl exec -it crowdsec-lapi-<> -- cscli bouncers add traefik-bouncer
```

# Update crowdsec-values.yaml with the generated key then upgrade the deployment
```
helm upgrade crowdsec crowdsec/crowdsec --namespace default -f ~/traefik/crowdsec-values.yaml
```

# Apply Bouncer Middleware
```
kubectl apply -f ~/traefik/bouncer-middleware.yaml
```