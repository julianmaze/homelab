# external-dns
https://kubernetes-sigs.github.io/external-dns/latest/docs/tutorials/aws/#when-using-clusters-without-rbac-enabled

```bash
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm upgrade --install external-dns external-dns/external-dns --values values.yaml
```