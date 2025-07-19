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

# Configure host to accept SSH public key connections
## On host machine
```
sudo nano /etc/ssh/sshd_config
```
## Scroll down and remove comment hash for line:
```
#PubkeyAuthentication yes
```
## Write out
## Restart SSH service
```
sudo systemctl restart ssh
```

# Add SSH identity on Host machine
### Helps avoid some identity issues
```
ssh-add ~/.ssh/ansible
```