copy yml file to the home folder one of the nodes

```bash
cd ~/Documents/GitHub/homelab/swarm/pihole
scp pihole-compose-swarm.yaml dylangroff@10.9.50.22:
```

ssh to that node

deploy the service
```bash
sudo su
mkdir /mnt/pihole/etc
mkdir /mnt/pihole/dns
docker stack deploy -c pihole-compose-swarm.yaml pihole --detach=false
```

once pihole is started, attach the console through portainer
```bash
pihole setpassword
```

Login through the admin panel

In settings: 
- change the DNS upstream servers to Cloudflare
- change interface settings to "permit all origins"
- enable misc.etc_dnsmasq_d in "all settings / Miscellaneous"