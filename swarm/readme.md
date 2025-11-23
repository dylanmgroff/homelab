## Install Proxmox as OS on host machine
1.  Download the ISO
    https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso

1.  Flash to a USB drive using Balena Etcher
    https://etcher.balena.io/#download-etcher

1.  Boot the host machine from the USB and follow the prompts

## Create a Proxmox Cloud-Init Template
1.  Download the Ubuntu Server ISO using the GUI
    https://ubuntu.com/download/server

    1.  Navigate to the local storage of any node
    1.  Find "Download from URL" and paste in the download link to your chosen ISO</br>
        Currently tested with </a href="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img">24.04 LTS (Noble)</a>

1.  Open the shell of that same node; Create the VM via the CLI

```bash
qm create 5000 --memory 2048 --core 2 --name ubuntu-cloud --net0 virtio,bridge=vmbr0
cd /var/lib/vz/template/iso/
qm importdisk 5000 lunar-server-cloudimg-amd64-disk-kvm.img <YOUR STORAGE HERE>
```