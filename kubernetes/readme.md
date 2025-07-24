# Create Cloud-Init Template
## Download the ISO using the GUI
## Create the VM via CLI
``` bash
qm create 5000 --memory 2048 --core 2 --name ubuntu-cloud --net0 virtio,bridge=vmbr0
cd /var/lib/vz/template/iso/
qm importdisk 5000 lunar-server-cloudimg-amd64-disk-kvm.img <YOUR STORAGE HERE>
qm set 5000 --scsihw virtio-scsi-pci --scsi0 <YOUR STORAGE HERE>:5000/vm-5000-disk-0.raw
qm set 5000 --ide2 <YOUR STORAGE HERE>:cloudinit
qm set 5000 --boot c --bootdisk scsi0
qm set 5000 --serial0 socket --vga serial0
```
## Expand the VM disk size to a suitable size (suggested 10 GB)
``` bash
qm disk resize 5000 scsi0 10G
```
## Create the Cloud-Init template 

# Deploy new VMs by cloning the template (full clone)
One master and one worker node per machine

# Install helm
``` bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

# Install Cert-Manager
``` bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.yaml
```

# Install Cloudflare Origin CA Issuer
## Install Origin CA Issuer
``` bash
kubectl apply -f ~/cforigin/deploy/crds
kubectl apply -f ~/cforigin/deploy/rbac
kubectl apply -f ~/cforigin/deploy/manifests
kubectl get -n origin-ca-issuer pod
```

## Adding an OriginIssuer
### API Token
Origin CA Issuer can use an API token that contains the “Zone / SSL and Certificates / Edit” permission, which can be scoped to specific accounts or zones.
```bash
kubectl apply -f ~/cforigin/deploy/originca/api-token-secret.yaml -f ~/cforigin/deploy/originca/api-token-issuer.yaml
```
Check the status of the OriginIssuer
```bash
kubectl get originissuer.cert-manager.k8s.cloudflare.com prodissuer -o json | jq .status.conditions
```
### Origin CA Key
Use the same API key as above for the secret
```bash
kubectl apply -f ~/cforigin/deploy/originca/service-key-secret.yaml -f ~/cforigin/deploy/originca/service-key-issuer.yaml
```
Check the status of the OriginIssuer
```bash
kubectl get originissuer.cert-manager.k8s.cloudflare.com prodissuer -o json | jq .status.conditions
```

## Create Certificates
```bash
kubectl apply -f ~/cforigin/deploy/certificates
```

# Install Rancher 
## Add Rancher Helm Repository
```bash
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
kubectl create namespace cattle-system
```

# Install Rancher
```bash
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

# Install Traefik
## Add Helm Repos
```bash
helm repo add traefik https://traefik.github.io/charts
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo add crowdsec https://crowdsecurity.github.io/helm-charts
helm repo update
```
## Install Emberstack
```bash
helm install reflector emberstack/reflector -f ~/reflector/reflector-values.yaml
```
## Install Traefik
```bash
helm install traefik traefik/traefik -f ~/traefik/traefik-values.yaml
```
## Check Traefik deployment
```bash
kubectl get svc
kubectl get pods
```
## Apply Middleware
```bash
kubectl apply -f ~/traefik/default-headers.yaml
```
## Create Secret for Traefik Dashboard
```bash
kubectl apply -f ~/traefik/dashboard/dashboard-secret.yaml
```
## Apply Middleware
```bash
kubectl apply -f ~/traefik/dashboard/middleware.yaml
```
## Apply Ingress to Access Service
```bash
kubectl apply -f ~/traefik/dashboard/ingress.yaml
```

# Install Crowdsec 
## READ ALL OF THIS FIRST!!
```bash
helm install crowdsec crowdsec/crowdsec -f ~/traefik/crowdsec-values.yaml
```
## Right away drop in the next command, find the container code and replace the <> then drop in that command. It will spit out a registry code.
```bash
kubectl get pods
kubectl exec -it crowdsec-lapi-<> -- cscli bouncers add traefik-bouncer
```

# Update crowdsec-values.yaml with the generated key then upgrade the deployment
```bash
helm upgrade crowdsec crowdsec/crowdsec -f ~/traefik/crowdsec-values.yaml
```
# Apply Bouncer Middleware
```bash
kubectl apply -f ~/crowdsec/bouncer-middleware.yaml