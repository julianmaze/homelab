# cert-manager

> [!IMPORTANT]  
> Cert-manager is only used in this cluster to rotate the cert for `rancher.local.julianmaze.com`. Additionally, use the same API token and lets encrypt private key that is used in the jmaze-k8s-cilium cluster.

## Installation

https://cert-manager.io/docs/installation/helm/

```bash
helm install \
  cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --version v1.19.2 \
  --namespace cert-manager \
  --create-namespace \
  --values values.yaml
```
