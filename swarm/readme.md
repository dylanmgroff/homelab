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
qm set 5000 --scsihw virtio-scsi-pci --scsi0 local:vm-5000-disk-0
```

This command creates a virtual hard disk at scsi0.

```bash
qm set 5000 --ide2 local:cloudinit
```

This command creates a virtual CD drive for the cloud-init assets.

```bash
qm set 5000 --boopt c --bootdisk scsi0
```

This command sets the VM to boot from scsi0 that we created earlier.

```bash
qm set 5000 --serial0 socket --vga serial0
```

This command creates a serial port so we can login through VNC in proxmox as a failsafe in case we lose SSH access.

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

## Create a master and worker node on each host machine using the cloud-init Template