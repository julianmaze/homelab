# coredns - external implementation

## Installation

```bash
helm repo add coredns https://coredns.github.io/helm
helm --namespace=dns install coredns coredns/coredns --values values.yaml
```
