# external-dns

https://kubernetes-sigs.github.io/external-dns/latest/docs/tutorials/aws/#when-using-clusters-without-rbac-enabled

External DNS syncs all gateway route hostnames to my private DNS zones in AWS. They are then served via a CoreDNS server.

```bash
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm upgrade --install external-dns external-dns/external-dns --values values.yaml
```
