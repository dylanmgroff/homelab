copy yml file to the home folder one of the nodes

```bash
scp pihole-compose-swarm.yaml dylangroff@10.9.50.22:
```

ssh to that node

deploy the service
```bash
sudo su
mkdir /mnt/pihole/data
mkdir /mnt/pihole/dnsmasq.d
sudo docker stack deploy -c pihole-compose-swarm.yaml pihole --detach=false
```