# ssh to kubeadmin

# copy yaml files to home director

# Add Helm Repos
```
helm repo add traefik https://traefik.github.io/charts
helm repo update
```

# Create Traefik namespace
```
kubectl create namespace traefik
```

# Apply YAML Files
```
kubectl apply -f ./.secrets.yaml
kubectl apply -f ./default-headers.yaml
kubectl apply -f ./dylangroff.yaml
```

# Install Traefik
```
helm install --namespace=traefik traefik traefik/traefik -f ./values.yaml
```