# General

```bash
# list docker nodes
sudo docker node ls
# list docker services
sudo docker service ls
# list gluster pools
sudo gluster pool list
# restart docker service
sudo docker service update --force $serviceName
```

# Install Proxmox as OS on host machine
1.  Download the ISO
    https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso

1.  Flash to a USB drive using Balena Etcher
    https://etcher.balena.io/#download-etcher

1.  Boot the host machine bios and configure:

    1. Check to enable VT-x and VT-d are enabled

1. Boot to the USB drive and follow the prompts</br>
    Once installation is complete you'll be dropped into the command line with the host IP and port specified

# Create a Proxmox Cloud-Init Template
## Create the Template
ssh to one of the proxmox nodes

1. Download Ubuntu Image

```bash
wget -P /var/lib/vz/template/iso/ https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
```

1. Create the base VM

```bash
qm create 9000 --name "ubuntu-24.04-cloud-init-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 /var/lib/vz/template/iso/noble-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
```

1. Configure cloud-init

non-balooning memory
Set the username and password
Add your SSH key
Increase disk size to 10GB
Start at boot

1. Convert to template
```bash
qm template 9000
```

1. Create a VM from the template
```bash
qm clone 9000 201 --name "new-ubuntu-vm"
```

# Deploy Nodes
When it comes time to deploy select "Clone Template" and set the mode to "Full Clone".

Create a Master and Worker VM on each node.

Create one Admin VM on any node.

Assign a static IP for each VM in the Unifi console using the VM MAC Address. IP assignments per below from swarm.sh

admin       10.9.50.5</br>
manager1    10.9.50.21</br>
manager2    10.9.50.22</br>
manager3    10.9.50.23</br>
worker1     10.9.50.24</br>
worker2     10.9.50.25</br>
worker3     10.9.50.26</br>

# Fix Node Networking
There was an interesting issue where the nodes didn't have any networking configured. Solve is as follows:

Open console for the node and login

```bash
sudo su
cd /etc/netplan
touch 01-netcfg.yaml
chmod 600 01-netcfg.yaml
nano 01-netcfg.yaml
```

paste in the following then writeout

```
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s18:
      dhcp4: true
```

```bash
netplan apply
```

now the network should be working

# Swarm Init

Copy swarm.sh and SSH keys to admin node. Make swarm.sh executable. Execute.

```bash
# on management commputer
cd Documents/GitHub/homelab/swarm
scp swarm.sh dylangroff@10.9.50.5:
# on node
chmod 744 swarm.sh
```