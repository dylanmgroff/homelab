# Install Longhorn
Copy folder to home directory

## Make script executable
```bash
chmod 764 longhorn.sh
```

## Run script
```bash
./longhorn/longhorn.sh
```

## Create SMB secret
```bash
kubectl apply -f ~/longhorn/smb-secret.yaml
```