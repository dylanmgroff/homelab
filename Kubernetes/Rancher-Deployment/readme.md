# Install helm
`curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3`</br>
`chmod 700 get_helm.sh` </br>
`./get_helm.sh` </br>

# Add Rancher Helm Repository
`helm repo add rancher-stable https://releases.rancher.com/server-charts/stable`</br>
`kubectl create namespace cattle-system`</br>

# Install Cert-Manager
`kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.crds.yaml`</br>
`helm repo add jetstack https://charts.jetstack.io`</br>
`helm repo update`</br>
`helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.18.2`</br>
`kubectl get pods --namespace cert-manager`</br>

# Install Rancher
`helm install rancher rancher-stable/rancher --namespace cattle-system --set hostname=rancher.montreal.dylangroff.com --set bootstrapPassword=admin`</br>
`kubectl -n cattle-system rollout status deploy/rancher`</br>
`kubectl -n cattle-system get deploy rancher`</br>

# Expose Rancher via Loadbalancer
`kubectl get svc -n cattle-system`</br>
`kubectl expose deployment rancher --name=rancher-lb --port=443 --type=LoadBalancer -n cattle-system`</br>
`kubectl get svc -n cattle-system`</br>

# Go to Rancher GUI
Hit the url… and create your account
Be patient as it downloads and configures a number of pods in the background to support the UI (can be 5-10mins)