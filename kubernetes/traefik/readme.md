# Install Traefik
## Add Helm Repos
```bash
helm repo add traefik https://traefik.github.io/charts
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo add crowdsec https://crowdsecurity.github.io/helm-charts
helm repo update
```
## Create Traefik Namespace
```bash
kubectl create namespace traefik
```
## Check Traefik Namespace
```bash
kubectl get namespaces
```
## Install Traefik
```bash
helm install traefik --namespace=traefik traefik/traefik -f ~/traefik/traefik-values.yaml
```
## Check Traefik deployment
```bash
kubectl get svc -n traefik
kubectl get pods -n traefik
```
## Apply Middleware
```bash
kubectl apply -f ~/traefik/default-headers.yaml
```
## Check Middleware
```bash
kubectl get middleware
```
## Create Secret for Traefik Dashboard
```bash
kubectl apply -f ~/traefik/dashboard/dashboard-secret.yaml
```
## Check Secret for Traefik Dashboard
```bash
kubectl get secrets --namespace traefik
```
## Apply Middleware
```bash
kubectl apply -f ~/traefik/dashboard/middleware.yaml
```
## Apply Ingress to Access Service
```bash
kubectl apply -f ~/traefik/dashboard/ingress.yaml
```
## Apply secret for certificate (Cloudflare)
```bash
kubectl apply -f ~/traefik/cert-manager/issuers/secret-cf-token.yaml
```
## Apply staging certificate issuer
```bash
kubectl apply -f ~/traefik/cert-manager/issuers/letsencrypt-staging.yaml
```
## Apply staging certificate
```bash
kubectl apply -f ~/traefik/cert-manager/certificates/staging/dylangroffcomtls.yaml
```
## Get cert-manager pods
```bash
kubectl get pods -n cert-manager
```
## Check cert-manager logs
```bash
kubectl get logs -n cert-manager -f cert-manager-#####
```
## Get challenges
```bash
kubectl get challenges
```
## Get more details
```bash
kubectl describe order dylangroff-#####
```
## Apply production certificate issuer
```bash
kubectl apply -f ~/traefik/cert-manager/issuers/letsencrypt-production.yaml
```
## Apply production certificate
```bash
kubectl apply -f ~/traefik/cert-manager/certificates/production/dylangroffcomtls.yaml
kubectl apply -f ~/traefik/cert-manager/certificates/production/manlydylangroffcomtls.yaml
```
Then just wait for the certificate to be issued! Be patient!!