# Install Nextcloud

## Create Nextcloud namespace
```bash
kubectl create namespace nextcloud
```

## Deploy Nextcloud
```bash
kubectl apply -f ~/nextcloud
```

## Expose MariaDB to Loadbalancer
```bash
kubectl expose deployment ncdg-db --type=NodePort --name=ncdg-db --port=3306 --namespace=nextcloud
```