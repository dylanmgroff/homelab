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
```