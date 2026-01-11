#!/bin/bash

# Set the IP addresses of the admin, managers, and workers nodes
admin=10.9.50.5
manager1=10.9.50.21
manager2=10.9.50.22
manager3=10.9.50.23
worker1=10.9.50.24
worker2=10.9.50.25
worker3=10.9.50.26

# Set the workers' hostnames (if using cloud-init in Proxmox it's the name of the VM)
workerHostname1=dockerSwarm-w01
workerHostname2=dockerSwarm-w02
workerHostname3=dockerSwarm-w03

# User of remote machines
user=dylangroff

# Interface used on remotes
interface=eth0

# Array of all manager nodes
allmanagers=($manager1 $manager2 $manager3)

# Array of extra managers
managers=($manager2 $manager3)

# Array of worker nodes
workers=($worker1 $worker2 $worker3)

# Array of all
all=($manager1 $manager2 $manager3 $worker1 $worker2 $worker3)

#ssh certificate name variable
certName=manlyswarm

# Install dependencies for each node (Docker, GlusterFS)
for newnode in "${all[@]}"; do
  ssh $user@$newnode -i /home/$user/.ssh/$certName sudo su <<EOF
  echo -e " \033[32;5m$newnode - We're in to $newnode !\033[0m"
  systemctl start glusterd
  echo -e " \033[32;5m$newnode - glusterd is started in $newnode !\033[0m"
  systemctl enable glusterd
  echo -e " \033[32;5m$newnode - glusterd is enabled in $newnode !\033[0m"
  mkdir -p /gluster/volume1
  echo -e " \033[32;5m$newnode - directory is created in $newnode !\033[0m"
  exit
EOF
  echo -e " \033[32;5m$newnode - Done and Moving On!\033[0m"
done