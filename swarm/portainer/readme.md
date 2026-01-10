copy yml file to the home folder one of the nodes

ssh to that node

deploy the service
```bash
sudo docker stack deploy -c portainer-compose-swarm.yml portainer
```