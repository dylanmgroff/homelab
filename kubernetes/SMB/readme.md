# Map SMB Shares to Pods
## Install CSI Driver
```bash
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/refs/heads/master/deploy/install-driver.sh
```

## Create SMB Creds
```bash
kubectl create secret generic smbcreds --from-literal username=USERNAME --from-literal password="PASSWORD"
```

## Create Storage Class
```bash
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/example/storageclass-smb.yaml
```

