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

## Adding Grafana Dashboards

Grafana dashboards that are not part of the kube-prometheus stack are kept at the `observability/` root level, separate from `02_kube_prom/`. Adding a new dashboard requires three steps:

### 1. Create a ConfigMap for the dashboard JSON

Create a file at `observability/grafana-dashboardDefinitions-<name>.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard-<name>
  namespace: observability
  labels:
    app.kubernetes.io/component: grafana
    app.kubernetes.io/name: grafana
    app.kubernetes.io/part-of: kube-prometheus
data:
  <name>.json: |-
    { ... dashboard JSON ... }
```

Grafana dashboards downloaded from grafana.com use a `${DS_PROMETHEUS}` input variable. Replace all occurrences with `$datasource` before embedding, and remove the `__inputs`, `__requires`, and `__elements` top-level keys.

### 2. Patch the Grafana deployment

Add a new `volumeMount` and `volume` entry to `grafana-deployment-patch.yaml`. Kustomize applies this as a strategic merge patch on top of the `02_kube_prom` Grafana deployment — list entries are merged by `name`, so each new entry is appended without affecting the existing ones:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: observability
spec:
  template:
    spec:
      containers:
        - name: grafana
          volumeMounts:
            - mountPath: /grafana-dashboard-definitions/0/<name>
              name: grafana-dashboard-<name>
              readOnly: false
      volumes:
        - configMap:
            name: grafana-dashboard-<name>
          name: grafana-dashboard-<name>
```

All dashboards mounted under `/grafana-dashboard-definitions/0/` are served by the existing `"0"` dashboard provider configured in `02_kube_prom/grafana-dashboardSources.yaml`, so no provider changes are needed.

### 3. Add the ConfigMap to the top-level kustomization

Edit `observability/kustomization.yaml` and add the new file to `resources`:

```yaml
resources:
  - ./02_kube_prom
  - http_route.yaml
  - grafana-dashboardDefinitions-<name>.yaml
```

### Validate before applying

```bash
kubectl kustomize .
```

## k3s Limitations

The following ServiceMonitors from kube-prometheus are **not applicable on k3s** and will always show empty scrape pools:

- `kube-controller-manager`
- `kube-scheduler`

On k3s, these components run embedded inside the `k3s-server` binary rather than as separate processes or pods. They do not expose individual metrics ports and no corresponding Services exist in `kube-system`. The ServiceMonitors are left in place (they are harmless) but will never have active targets.
