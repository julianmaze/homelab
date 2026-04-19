# observability

## [Prometheus Operator](https://prometheus-operator.dev/)

### Operator

```bash
NAMESPACE=observability
DIR=./00_operator
LATEST=$(curl -s https://api.github.com/repos/prometheus-operator/prometheus-operator/releases/latest | jq -cr .tag_name)
curl -s "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/refs/tags/$LATEST/kustomization.yaml" > "$DIR/kustomization.yaml"
curl -s "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/refs/tags/$LATEST/bundle.yaml" > "$DIR/bundle.yaml"
# Ensure namespace: observability is defined in ./00_operator/kustomization.yaml
kubectl apply -k "$DIR"
```

### Kube Prom

```bash
git clone https://github.com/prometheus-operator/kube-prometheus.git
cd kube-prometheus/manifests
```

## Deploy

```bash
kubectl kustomize .
kubectl apply -k .
```

## Scraping Additional Namespaces

To scrape pods in a namespace outside of `observability`, add a `Role` and `RoleBinding` in that namespace granting the `prometheus-k8s` ServiceAccount access.

Edit the two files in `02_kube_prom/cross-namespace-rbac/`:

**`prometheus-roleSpecificNamespaces.yaml`** — add a new Role:
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: prometheus-k8s-<namespace>
  namespace: <namespace>
rules:
- apiGroups: [discovery.k8s.io]
  resources: [endpointslices]
  verbs: [get, list, watch]
- apiGroups: [""]
  resources: [services, pods]
  verbs: [get, list, watch]
- apiGroups: [networking.k8s.io]
  resources: [ingresses]
  verbs: [get, list, watch]
```

**`prometheus-roleBindingSpecificNamespaces.yaml`** — add a new RoleBinding:
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: prometheus-k8s-<namespace>
  namespace: <namespace>
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: prometheus-k8s-<namespace>
subjects:
- kind: ServiceAccount
  name: prometheus-k8s
  namespace: observability
```

No changes to `kustomization.yaml` are needed as these files are already included.
