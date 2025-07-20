Copy K3S folder to admin machine

Add password to line 54 of all.yml

Install ansible requirements
```
ansible-galaxy install -r ./collections/requirements.yml
```

I had to install netaddr
```
sudo apt install python3-pip
pip install netaddr
```

run playbook
```
ansible-playbook ./site.yml -i ./inventory/hosts.ini
```

boostrap access
```
scp dylangroff@10.9.50.11:~/.kube/config ~/.kube/config
```

