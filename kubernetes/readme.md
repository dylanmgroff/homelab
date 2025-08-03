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
</br>
</br>
</br>
</br>
# Deploy new VMs by cloning the template (full clone)
One master and one worker node per machine
</br>
</br>
</br>
</br>
# Deploy K3S
Copy k3s/k3s.sh to admin machine home directory and make it executable.

Copy cloud-init id_rsa to admin machine home directory

Execute the script
#
#
#
#
# Install helm
``` bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

# Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

# Install Cert-Manager
``` bash
brew install cmctl
helm repo add jetstack https://charts.jetstack.io
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.yaml
kubectl get pods --namespace cert-manager
cmctl check api
```

## End-to-end verify the installation
```bash
cat <<EOF > test-resources.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: test-selfsigned
  namespace: cert-manager
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: selfsigned-cert
  namespace: cert-manager
spec:
  dnsNames:
    - example.com
  secretName: selfsigned-cert-tls
  issuerRef:
    name: test-selfsigned
EOF
```
```bash
kubectl apply -f test-resources.yaml
kubectl describe certificate -n cert-manager
```
Status of certificate should be "Certificate issued successfully"
## Clean up test resources
```bash
kubectl delete -f test-resources.yaml
```

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

# Go to Rancher GUI

# Install Crowdsec
## Install Emberstack
```bash
helm install reflector --namespace=reflector emberstack/reflector -f ~/reflector/reflector-values.yaml
``` 
## READ ALL OF THIS FIRST!!
```bash
helm install crowdsec crowdsec/crowdsec -f ~/crowdsec/crowdsec-values.yaml
```
## Right away drop in the next command, find the container code and replace the <> then drop in that command. It will spit out a registry code.
```bash
kubectl get pods
kubectl exec -it crowdsec-lapi-<> -- cscli bouncers add traefik-bouncer
```

# Update crowdsec-values.yaml with the generated key then upgrade the deployment
```bash
helm upgrade crowdsec crowdsec/crowdsec -f ~/crowdsec/crowdsec-values.yaml
```
# Apply Bouncer Middleware
```bash
kubectl apply -f ~/crowdsec/bouncer-middleware.yaml