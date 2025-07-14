#!/bin/bash

# Step 1: Add Helm Repos
helm repo add traefik https://helm.traefik.io/traefik
helm repo add emberstack https://emberstack.github.io/helm-charts # required to share certs for CrowdSec
helm repo add crowdsec https://crowdsecurity.github.io/helm-charts
helm repo update

# Step 2: Create Traefik namespace
kubectl create namespace traefik

# Step 3: Install Traefik
helm install --namespace=traefik traefik traefik/traefik -f ./Helm/Traefik/values.yaml

# Step 4: Check Traefik deployment
kubectl get svc -n traefik
kubectl get pods -n traefik

# Step 5: Apply Middleware
kubectl apply -f ./Helm/Traefik/default-headers.yaml

# Step 6: Create Secret for Traefik Dashboard
kubectl apply -f ./Helm/Traefik/Dashboard/secret-dashboard.yaml

# Step 7: Apply Middleware
kubectl apply -f ./Helm/Traefik/Dashboard/middleware.yaml

# Step 8: Apply Ingress to Access Service
kubectl apply -f ./Helm/Traefik/Dashboard/ingress.yaml

# Step 9: Apply secret for certificate (Cloudflare)
kubectl apply -f ./Helm/Traefik/Cert-Manager/Issuers/secret-cf-token.yaml

# Step 10: Apply production certificate issuer (technically you should use the staging to test as per documentation)
kubectl apply -f ./Helm/Traefik/Cert-Manager/Issuers/letsencrypt-production.yaml

# Step 11: Apply production certificate
kubectl apply -f ./Helm/Traefik/Cert-Manager/Certificates/Production/jimsgarage-production.yaml

# Step 12: Create PiHole namespace
kubectl create namespace pihole

# Step 13: Deploy PiHole
kubectl apply -f ./Manifest/PiHole

echo -e " \033[32;5mScript finished. Be sure to create PVC for PiHole in Longhorn UI\033[0m"