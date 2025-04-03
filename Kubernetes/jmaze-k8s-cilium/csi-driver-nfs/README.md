# csi-driver-nfs
https://github.com/kubernetes-csi/csi-driver-nfs

## Installation with Helm
https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/charts/README.md

```bash
helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system --version 4.11.0 --values values.yaml
```