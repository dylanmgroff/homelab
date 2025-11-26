# General

to restart the service you can identify what's running with
```bash
sudo docker service ls
```

then restart the service with
```bash
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
1.  Download the Ubuntu Server ISO using the GUI
    https://ubuntu.com/download/server

    1.  Navigate to the local storage of any node
    1.  Find "Download from URL" and paste in the download link to your chosen ISO</br>
        Currently tested with </a href="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img">22.04 LTS (Jammy Jellyfish)</a>

1.  

1.  Open the shell of that same node; Create the VM via the CLI

```bash
qm create 5000 --memory 2048 --core 2 --name ubuntu-cloud --net0 virtio,bridge=vmbr0
cd /var/lib/vz/template/iso/
qm importdisk 5000 lunar-server-cloudimg-amd64-disk-kvm.img local-lvm
```

This creates a template at 5000 with: 2GB of memory and 2 cores; named ubuntu-cloud; and with a virtual network adapter at net0 which will address the singlular ethernet port on the host machine.

We then CD into the folder where we'll find the ISO we downloaded earlier. We can ls this folder to verify that the iso is present.

On these hosts the local storage name is left as default and so we point it to "local-lvm".

```bash
# Creates a virtual hard disk at scsi0.
qm set 5000 --scsihw virtio-scsi-pci --scsi0 local:vm-5000-disk-0
# This command creates a virtual CD drive for the cloud-init assets.
qm set 5000 --ide2 local:cloudinit
# This command sets the VM to boot from scsi0 that we created earlier.
qm set 5000 --boopt c --bootdisk scsi0
# This command creates a serial port so we can login through VNC in proxmox as a failsafe in case we lose SSH access.
qm set 5000 --serial0 socket --vga serial0
```

You can now go into the cloud-init template and edit the template as needed.

For example you can change the hardware to allocate a different number of cores, or more memory.

## Set the Cloud Init Parameters
1. Set the username and password
1. Add your SSH key

If adding the Proxmox default key:

Find the id_rsa and id_rsa.pub on the Proxmox host in ~/.ssh

Add the Public SSH key to the cloud-init template

## Convert to Template
Right click the VM and select "convert to template"

# Deploy Nodes
Whe it comes time to deploy select "Clone Template" and set the mode to "Full Clone".

Create a Master and Worder VM on each node.

Create one Admin VM on any node.

Assign a static IP for each VM in the Unifi console using the VM MAC Address. IP assignments per below from swarm.sh

admin       10.9.50.5</br>
manager1    10.9.50.21</br>
manager2    10.9.50.22</br>
manager3    10.9.50.23</br>
worker1     10.9.50.24</br>
worker2     10.9.50.25</br>
worker3     10.9.50.26</br>

# Automated Install from Script
Copy swarm.sh and SSH keys to admin node. Make swarm.sh executable. Execute.

# Manual Install
## Install Docker
### Repeat this on each VM
```bash
# switch to super user
sudo su
# Add Docker's official GPG key:

apt update && sudo apt install ca-certificates curl && sudo install -m 0755 -d /etc/apt/keyrings && sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# install docker and other relevant components
apt update && sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# wait for docker install to complete and then reboot the system
shutdown -r now

# when the system is back up check that docker is running
sudo systemctl status docker

# if docker is running you can kill the process
^C

# run hello world to validate docker install
sudo docker run hello-world
```

## Install GlusterFS
### repeat this on each VM
```bash
# switch to super user
sudo su

# install glusterfs, start glusterd, enable glusterd, make gluster volume directory
apt install software-properties-common glusterfs-server -y && systemctl start glusterd && systemctl enable glusterd && mkdir -p /gluster/volume1

# exit super user
exit
```

## Create GlusterFS Cluster across all nodes
### ssh to swarmm01
```bash
# Add each VM to peer list
gluster peer probe 10.9.50.21; gluster peer probe 10.9.50.22; gluster peer probe 10.9.50.23; gluster peer probe 10.9.50.24; gluster peer probe 10.9.50.25; gluster peer probe 10.9.50.26;

# Create gluster volumes
gluster volume create staging-gfs replica 6 10.9.50.21:/gluster/volume1 10.9.50.22:/gluster/volume1 10.9.50.23:/gluster/volume1 10.9.50.24:/gluster/volume1 10.9.50.25:/gluster/volume1 10.9.50.26:/gluster/volume1 force

# Start gluster service
gluster volume start staging-gfs

# change permissions to give access to docker socket
chmod 666 /var/run/docker.sock

# update labels for worker nodes
docker node update --label-add worker=true dockerSwarm-w01 && docker node update --label-add worker=true dockerSwarm-w02 && docker node update --label-add worker=true dockerSwarm-w03

#exit super user
exit
```

## Ensure GlusterFS mount restarts after boot
### Repeat on each VM
```bash
sudo su
echo '127.0.0.1:/staging-gfs /mnt glusterfs defaults,_netdev,backupvolfile-server=127.0.0.1 0 0' >> /etc/fstab
mount.glusterfs 127.0.0.1:/staging-gfs /mnt
chown -R root:docker /mnt
shutdown -r now
```