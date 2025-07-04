1. Download the ISO using the GUI </br>
    https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

2. Create the VM via CLI </br>
    `qm create 5000 --memory 2048 --core 2 --name ubuntu-cloud --net0 virtio,bridge=vmbr0` <!-- creates a virtual machine at ID 5000 with 2GB of memory, 2 cores, named ubuntu cloud, with a virtual network device bridged to the host NIC --></br>
    `cd /var/lib/vz/template/iso/` <!-- change directory to location of iso template downloaded in step 1 --></br>
    `qm importdisk 5000 jammy-server-cloudimg-amd64.img local-lvm` <!-- import the downloaded iso image into the VM using local storage --></br>
    `qm set 5000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-5000-disk-0` <!-- add local storage as virtual hard disk within the virtual machine --></br>
    `qm set 5000 --ide2 local-lvm:cloudinit` <!-- create a virtual CD drive in the VM --></br>
    `qm set 5000 --boot c --bootdisk scsi0` <!-- set to boot from the virtual hard disk created earlier --></br>
    `qm set 5000 --serial0 socket --vga serial0` <!-- creates virtual serial port to allow VSC access through proxmox --></br>
    `qm disk resize 5000 scsi0 10G` <!-- Expand the VM disk size to a suitable size -->

3. Modify the VM hardware to fit physical hardware
    - Memory 
        - 16384 MiB (16 GiB)
        - Open advanced and untick "Balooning Device"
    - CPU
        - 1 Socket, 4 Cores
        - Change CPU type to Host <!-- This ensures the VM receives all the instruction sets and capabilities of the host processor -->

    - Hard Disk
        - Enable SSD Emulation

4. Set Cloud-Init parameters
    - User
        - `dylangroff`
    - Password
    - SSH public key
        - Add public keys for all datacenter nodes and admin workstations
    - IP Config
        - set to DHCP 

5. Create the Cloud-Init template

6. Deploy new VMs by cloning the template (full clone)
