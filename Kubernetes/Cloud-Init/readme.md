1. Download the ISO using the GUI
    https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

2. Create the VM via CLI
    `qm create 5000 --memory 2048 --core 2 --name ubuntu-cloud --net0 virtio,bridge=vmbr0
    cd /var/lib/vz/template/iso/
    qm importdisk 5000 lunar-server-cloudimg-amd64-disk-kvm.img local-lvm
    qm set 5000 --scsihw virtio-scsi-pci --scsi0 local-lvm:5000/vm-5000-disk-0.raw
    qm set 5000 --ide2 local-lvm:cloudinit
    qm set 5000 --boot c --bootdisk scsi0
    qm set 5000 --serial0 socket --vga serial0`

3. Expand the VM disk size to a suitable size (suggest 10GB)
    `qm disk resize 5000 scsi0 10G`

4. Create the Cloud-Init template
5. Deploy new VMs by cloning the template (full clone)
