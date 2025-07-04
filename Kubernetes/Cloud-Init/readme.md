1. Download the ISO using the GUI </br>
    https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

2. Create the VM via CLI </br>
    `qm create 5000 --memory 2048 --core 2 --name ubuntu-cloud --net0 virtio,bridge=vmbr0`</br>
    `cd /var/lib/vz/template/iso/`</br>
    `qm importdisk 5000 jammy-server-cloudimg-amd64.img local-lvm`</br>
    `qm set 5000 --scsihw virtio-scsi-pci --scsi0 local-lvm:5000/vm-5000-disk-0.raw`</br>
    `qm set 5000 --ide2 local-lvm:cloudinit`</br>
    `qm set 5000 --boot c --bootdisk scsi0`</br>
    `qm set 5000 --serial0 socket --vga serial0`</br>

3. Expand the VM disk size to a suitable size (suggest 10GB) </br>
    `qm disk resize 5000 scsi0 10G`

4. Create the Cloud-Init template
5. Deploy new VMs by cloning the template (full clone)
