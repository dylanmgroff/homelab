copy yml file to the home folder one of the nodes

```bash
cd ~/Documents/GitHub/homelab/swarm/portainer
scp portainer-compose-swarm.yaml dylangroff@10.9.50.22:
```

ssh to that node


deploy the service
```bash
mkdir /mnt/portainer/data
sudo docker stack deploy -c portainer-compose-swarm.yml portainer
```