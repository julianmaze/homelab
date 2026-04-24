# Rancher

Rancher is deployed via Helm on `jmaze-k8s` (single-node K3s). It manages a second downstream cluster, `jmaze-k8s-cilium`.

- **URL**: https://rancher.local.julianmaze.com
- **Namespace**: `cattle-system`
- **Replicas**: 1

## Upgrade Procedure

> **CRITICAL: You must upgrade one minor version at a time.**
> Skipping minor versions (e.g. v2.10.3 → v2.13.3) will break the login UI and corrupt Fleet state.

### Valid upgrade path example

```
v2.10.3 → v2.11.x → v2.12.x → v2.13.x
```

### Steps

```bash
helm repo update
helm search repo rancher-stable -l | grep rancher/rancher

# Upgrade to next minor version
helm upgrade rancher rancher-stable/rancher \
  --namespace cattle-system \
  -f values.yaml \
  --version <TARGET_VERSION>
```

After each upgrade, verify before proceeding to the next:

```bash
kubectl rollout status deployment/rancher -n cattle-system
kubectl get pods -n cattle-fleet-system
kubectl get clusters.management.cattle.io
```

---

## Post-Upgrade Checklist

After every Rancher upgrade, run this to verify all downstream clusters have the correct desired agent image:

```bash
kubectl get clusters.management.cattle.io \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.desiredAgentImage}{"\t"}{.status.agentImage}{"\n"}{end}'
```

Both `desiredAgentImage` and `agentImage` should match the new Rancher version's agent. If `desiredAgentImage` is stale (from a previous version), patch it manually:

```bash
kubectl patch clusters.management.cattle.io <cluster-id> --type=merge \
  -p '{"spec":{"desiredAgentImage":"rancher/rancher-agent:<NEW_VERSION>"}}'
```

Then bump the downstream cluster agent pod to force re-registration:

```bash
# On the downstream cluster:
kubectl rollout restart deployment/cattle-cluster-agent -n cattle-system
```

---

## Troubleshooting

### Login screen hangs after upgrade

**Cause**: Version skip. The `ui-sql-cache` feature introduced in v2.11 requires the SQL-backed `SummarizedObject` API. Jumping from v2.10 skips the migration.

**Fix**: Roll back to the previous version and upgrade sequentially through each minor version.

### Fleet chart install fails (`no chart version found for fleet-108.x.x`)

**Cause**: Catalog timing — Rancher starts trying to install fleet charts before the `rancher-charts` ClusterRepo finishes downloading the new `release-vX.XX` branch.

**Fix**: Wait for the catalog to re-index (watch for new `rancher-charts-*` ConfigMaps in `cattle-system`), or force a refresh:

```bash
kubectl annotate clusterrepo rancher-charts catalog.cattle.io/force-update="$(date +%s)" --overwrite
```

### Downstream cluster shows Disconnected after upgrade

**Cause**: `spec.desiredAgentImage` on the management cluster's cluster object was not updated during a failed upgrade attempt. When the downstream agent (new version) tries to register, Rancher sees a version mismatch and kills the websocket to "correct" it — preventing credentials from ever being pushed, so the agent loops forever at the `/v3/connect/register` step.

**Symptom**: Rancher logs show `Handling backend connection request [c-m-XXXXX]` immediately followed by `websocket: close 1006 (abnormal closure): unexpected EOF`. Agent pod shows no restarts and no log lines after `Connected to proxy`.

**Fix**:

```bash
# 1. Check what Rancher thinks the desired agent version is
kubectl get clusters.management.cattle.io <cluster-id> \
  -o jsonpath='{.spec.desiredAgentImage}'

# 2. If stale, patch to the correct version
kubectl patch clusters.management.cattle.io <cluster-id> --type=merge \
  -p '{"spec":{"desiredAgentImage":"rancher/rancher-agent:v<RANCHER_VERSION>"}}'

# 3. The agent should reconnect automatically within ~30 seconds
kubectl get clusters.management.cattle.io <cluster-id> \
  -o jsonpath='{range .status.conditions[*]}{.type}{": "}{.status}{"\n"}{end}' \
  | grep -E "Connected|Ready"
```

### Admin password reset

`bootstrapPassword` in `values.yaml` only applies on first install. To reset after the fact:

```bash
kubectl -n cattle-system exec $(kubectl -n cattle-system get pods -l app=rancher -o name | head -1) \
  -- reset-password
```

### Re-register a disconnected downstream cluster

If credentials are fully stale on the downstream cluster:

```bash
# 1. Get the import manifest URL from the management cluster
kubectl get clusterregistrationtoken.management.cattle.io default-token \
  -n <cluster-namespace> \
  -o jsonpath='{.status.manifestUrl}'

# 2. On the downstream cluster, delete stale credentials and re-apply
kubectl delete deployment cattle-cluster-agent -n cattle-system
kubectl delete secret -n cattle-system \
  $(kubectl get secrets -n cattle-system -o name | grep cattle-credentials)

kubectl apply -f <MANIFEST_URL_FROM_STEP_1>
```

The cluster namespace on the management cluster corresponds to the cluster ID (e.g. `c-m-qdq82n67`), visible via:

```bash
kubectl get clusters.management.cattle.io
```
