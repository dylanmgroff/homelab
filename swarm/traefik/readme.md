ssh to manager node

```bash
sudo su
cd /mnt/traefik
touch cloudflare_api_token
mkdir ./dynamic
touch ./dynamic/dynamic.yaml
mkdir ./letsencrypt
touch ./letsnecrypt/acme.json
chmod 600 ./letsencrypt/acme.json
mkdir ./logs
touch traefik.yaml
```

copy config to traefik.yaml
copy static to ./dynamic/dynamic.yaml

scp the compose doc to the manager node you're working on

deploy the service
```bash
sudo docker stack deploy -c /home/dylangroff/traefik-compose-swarm.yml traefik --detach=false
```