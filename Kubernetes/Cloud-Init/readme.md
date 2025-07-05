1. Download the ISO using the GUI </br>
    https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

1. Create the VM on Kube1 via CLI </br>
    create a virtual machine at ID 5000 with 4GB of memory, 2 cores, named ubuntu cloud, with a virtual network device bridged to the host NIC</br>
    `qm create 5000 --memory 4096 --core 4 --name ubuntu-cloud --net0 virtio,bridge=vmbr0`</br>
    change directory to location of iso template downloaded in step 1</br>
    `cd /var/lib/vz/template/iso/`</br>
    import the downloaded iso image into the VM using local storage</br>
    `qm importdisk 5000 jammy-server-cloudimg-amd64.img local-lvm`</br>
    add local storage as virtual hard disk within the virtual machine</br>
    `qm set 5000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-5000-disk-0` 
    create a virtual CD drive in the VM</br>
    `qm set 5000 --ide2 local-lvm:cloudinit`</br>
    set to boot from the virtual hard disk created earlier</br>
    `qm set 5000 --boot c --bootdisk scsi0`</br>
    creates virtual serial port to allow VSC access through proxmox</br>
    `qm set 5000 --serial0 socket --vga serial0`</br>
    Expand the VM disk size to a suitable size
    `qm disk resize 5000 scsi0 10G`</br>

1. Create the VM on Kube2 via CLI </br>
    create a virtual machine at ID 5001 with 4GB of memory, 2 cores, named ubuntu cloud, with a virtual network device bridged to the host NIC</br>
    `qm create 5001 --memory 4096 --core 4 --name ubuntu-cloud --net0 virtio,bridge=vmbr0`</br>
    change directory to location of iso template downloaded in step 1</br>
    `cd /var/lib/vz/template/iso/`</br>
    import the downloaded iso image into the VM using local storage</br>
    `qm importdisk 5001 jammy-server-cloudimg-amd64.img local-lvm`</br>
    add local storage as virtual hard disk within the virtual machine</br>
    `qm set 5001 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-5001-disk-0` 
    create a virtual CD drive in the VM</br>
    `qm set 5001 --ide2 local-lvm:cloudinit`</br>
    set to boot from the virtual hard disk created earlier</br>
    `qm set 5001 --boot c --bootdisk scsi0`</br>
    creates virtual serial port to allow VSC access through proxmox</br>
    `qm set 5001 --serial0 socket --vga serial0`</br>
    Expand the VM disk size to a suitable size
    `qm disk resize 5001 scsi0 10G`</br>

1. Create the VM on Kube2 via CLI </br>
    create a virtual machine at ID 5002 with 4GB of memory, 2 cores, named ubuntu cloud, with a virtual network device bridged to the host NIC</br>
    `qm create 5002 --memory 4096 --core 4 --name ubuntu-cloud --net0 virtio,bridge=vmbr0`</br>
    change directory to location of iso template downloaded in step 1</br>
    `cd /var/lib/vz/template/iso/`</br>
    import the downloaded iso image into the VM using local storage</br>
    `qm importdisk 5002 jammy-server-cloudimg-amd64.img local-lvm`</br>
    add local storage as virtual hard disk within the virtual machine</br>
    `qm set 5002 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-5002-disk-0` 
    create a virtual CD drive in the VM</br>
    `qm set 5002 --ide2 local-lvm:cloudinit`</br>
    set to boot from the virtual hard disk created earlier</br>
    `qm set 5002 --boot c --bootdisk scsi0`</br>
    creates virtual serial port to allow VSC access through proxmox</br>
    `qm set 5002 --serial0 socket --vga serial0`</br>
    Expand the VM disk size to a suitable size
    `qm disk resize 5002 scsi0 10G`</br>

1. Modify the VM hardware to fit physical hardware
    - Memory 
        - 4096 MiB (4 GiB)
        - Open advanced and untick "Balooning Device"
    - CPU
        - 1 Socket, 2 Cores
        - Change CPU type to Host <!-- This ensures the VM receives all the instruction sets and capabilities of the host processor -->

    - Hard Disk
        - Enable SSD Emulation

1. Set Cloud-Init parameters
    - User
        - `dylangroff`
    - Password
    - SSH public key
        - Add public keys for all datacenter nodes and admin workstations
    - IP Config
        - set to DHCP 

1. Create the Cloud-Init template

1. Deploy new VMs by cloning the template (full clone)
