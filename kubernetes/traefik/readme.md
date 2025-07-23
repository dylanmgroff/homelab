# Add Helm Repos
```
helm repo add traefik https://traefik.github.io/charts
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo add crowdsec https://crowdsecurity.github.io/helm-charts
helm repo update
```

# Install Emberstack
```
helm install \
reflector emberstack/reflector \
--create-namespace \
--namespace reflector \
-f ~/traefik/reflector-values.yaml
```

# Create Traefik namespace
```
kubectl create namespace traefik
```

# Install Traefik
```
helm install --namespace=traefik traefik traefik/traefik -f ~/traefik/traefik-values.yaml
```

# Check Traefik deployment
```
kubectl get svc -n traefik
kubectl get pods -n traefik
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

# Apply secret for certificate
```
kubectl apply -f ~/traefik/cert-manager/issuers/secret-cf-token.yaml
```

# Apply production certificate issuer
```
kubectl apply -f ~/traefik/cert-manager/issuers/letsencrypt-production.yaml
```

# Apply production certificate
```
kubectl apply -f ~/traefik/cert-manager/certificates/Production/dylangroff-production.yaml
```

# Install Crowdsec
```
helm install \
crowdsec crowdsec/crowdsec \
--create-namespace \
--namespace crowdsec \
-f crowdsec-values.yaml
```

# Apply Bouncer Middleware
```
kubectl apply -f ~/traefik/bouncer-middleware.yaml
```