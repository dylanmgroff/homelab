# Create SSH Key
## Generate Key
```
ssh-keygen -t ed25519 -C "ansible"
```
## Specify Save Location
```
/home/dylangroff/.ssh/ansible
```
## Enter Passphrase
```
** Leave Blank **
```

# Copy SSH Key
```
ssh-copy-id -i ~/.ssh/ansible.pub <target IP Address>
```

Note: You'll be prompted for the password of the target machine

# Ansible Ping Command With New SSH Key
```
ansible all -m ping --key-file ~/.ssh/ansible
```