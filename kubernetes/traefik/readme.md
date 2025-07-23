# Add Helm Repos
```
helm repo add traefik https://traefik.github.io/charts
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo add crowdsec https://crowdsecurity.github.io/helm-charts
helm repo add jetstack https://charts.jetstack.io
helm repo update
```
# Install Cert-Manager
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.crds.yaml
helm install cert-manager jetstack/cert-manager \
--namespace cert-manager \
--create-namespace \
--version v1.18.2
```

# Create Traefik namespace
```
kubectl create namespace traefik
```

# Install Traefik
```
helm install --namespace=traefik traefik traefik/traefik -f ~/traefik/values.yaml
```

# Check Traefik deployment
```
kubectl get svc -n traefik
kubectl get pods -n traefik
```
# Install Crowdsec
```
helm install \
crowdsec crowdsec/crowdsec \
--create-namespace \
--namespace crowdsec \
-f crowdsec-values.yaml
```

# Install Emberstack
```
helm install \
reflector emberstack/reflector \
--create-namespace \
--namespace reflector \
-f reflector-values.yaml
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

# Apply secret for certificate (Cloudflare)
```
kubectl apply -f ~/traefik/cert-manager/issuers/secret-cf-token.yaml
```

# Apply production certificate issuer (technically you should use the staging to test as per documentation)
```
kubectl apply -f ~/traefik/cert-manager/issuers/letsencrypt-production.yaml
```

# Apply production certificate
```
kubectl apply -f ~/traefik/cert-manager/certificates/production/dylangroff-production.yaml
```

# Apply Crowdsec Middleware
```
kubectl apply -f ~/traefik/bouncer-middleware.yaml
```

# Create PiHole namespace
```
kubectl create namespace pihole
```

# Deploy PiHole
```
kubectl apply -f ~/Manifest/PiHole
```