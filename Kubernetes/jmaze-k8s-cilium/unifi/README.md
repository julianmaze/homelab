# Unifi Network Application

The Unifi-network-application software is a powerful, enterprise wireless software engine ideal for high-density client deployments requiring low latency and high uptime performance.

https://docs.linuxserver.io/images/docker-unifi-network-application/

## External Database - mongodb

> [!CAUTION]
> Make sure you pin your database image version and do not use latest, as mongodb does not support automatic upgrades between major versions.

The Unifi network application requires an external database. I chose to deploy the [bitnami/mongodb](https://github.com/bitnami/charts/tree/main/bitnami/mongodb) helm chart due to its simplicity. A couple of notes on the chart:

- The chart uses the legacy [`bitnamilegacy/mongodb`](https://hub.docker.com/r/bitnamisecure/mongodb) image in light of the [Broadcom announcement](https://news.broadcom.com/app-dev/broadcom-introduces-bitnami-secure-images-for-production-ready-containerized-applications)
- The chart has been configured to deploy the database as a stateful set

```bash
export password=""
helm install unifidb oci://registry-1.docker.io/bitnamicharts/mongodb -n unifi --values mongodb/values.yaml --set auth.passwords={$password}
```

### Granting the `unifi` user `dbOwner` of the `unifi` database

First, access the unifi database via `mongosh` and the root user

```bash
mongosh unifi --host "unifidb-mongodb.unifi.svc.cluster.local" --authenticationDatabase admin -u root -p <PASSWORD>
```

Then, grant the `unifi` user access to be a dbOwner

```mongosh
db.getUser("unifi")
db.grantRolesToUser("unifi", [
    { db: "unifi", role: "dbOwner" },
    { db: "unifi_stat", role: "dbOwner" },
    { db: "unifi_audit", role: "dbOwner" }
])
```

### Database optimizations

> [!IMPORTANT]  
> No sysctl configs have been implemented in `jmaze-k8s-cilium` since I need to build another node first.

Several warnings are presented on the start/connection of the mongodb database that need to be worked through. Most are sysctl configs added to the `podSecurityContext` or environment variables injected into the pod.

Warnings with a status of `⚠️ Covered ` are proven to be working but require unsafe sysctl configs to be enabled. From [k8s docs](https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/):

```
It is good practice to consider nodes with special sysctl settings as tainted within a cluster, and only schedule pods onto them which need those sysctl settings. It is suggested to use the Kubernetes taints and toleration feature to implement this.
```

| Warning                          | Setting                                          | Value                  | Status                  |
| -------------------------------- | ------------------------------------------------ | ---------------------- | ----------------------- |
| XFS filesystem recommended       | N/A (storage ) - create `XFS` PV/PVC in Longhorn | N/A                    | ✅ Adjusted in longhorn |
| sysfsFile (Transparent Hugepage) | `kernel.mm.transparent_hugepage.enabled`         | `never`                | ✅ Added                |
| vm.max_map_count too low         | `vm.max_map_count`                               | `262144`               | ⚠️ Covered              |
| Swappiness performance           | `vm.swappiness`                                  | `1`                    | ⚠️ Covered              |
| glibc rseq support               | `GLIBC_TUNABLES`                                 | `glibc.pthread.rseq=0` | ⚠️ Covered              |

> [!NOTE] > **XFS Filesystem**: This is a storage layer recommendation and cannot be configured via sysctl. You would need to ensure your PersistentVolume uses XFS formatting. For now, ext4 is acceptable but XFS is preferred.

## Setting up the new controller

1. Restore appliance from backup
2. Inform devices of new LoadBalancer IP by SSH'ing into each device and running the inform command - https://help.ui.com/hc/en-us/articles/204909754-Remote-Adoption-Layer-3

```bash
set-inform http://10.50.25.3:8080/inform
```

## Gateway access - currently broken, blocked on Cilium upgrades

Goal: terminate SSL for `unifi.local.julianmaze.com` at the `default-gateway`
Gateway (using the trusted `wildcard-local-julianmaze-com-tls` cert) and
re-encrypt to the pod's self-signed cert via `BackendTLSPolicy`, instead of
today's TLS Passthrough (which exposes the self-signed cert directly to
browsers).

This is blocked by two separate issues on the currently installed Cilium
`1.19.4`:

1. **`BackendTLSPolicy` isn't implemented until Cilium 1.20** (currently only
   `rc.1`, not GA). Verified empirically: `cilium-operator`'s startup log
   ("Checking for required and optional GatewayAPI resources") does not list
   `backendtlspolicies` in its required or optional GVK set, and no TLS
   `transport_socket` gets added to the generated Envoy cluster for the
   `unifi` Service. See `unifi/app/backend_tls_policy.yaml` and
   `gateway/backend-tls-policy-example.yaml` (both currently unused/inert).
2. **Even plain TLS Passthrough is currently broken** on this Gateway due to
   a Cilium bug affecting `allowedRoutes` namespace/kind restrictions on
   multi-listener Gateways (cilium/cilium#45559, #42159), fixed by
   cilium/cilium#45693 and released in **v1.19.6** (2026-07-16). Until
   upgraded, the `unifi` TLSRoute is rejected with
   `NotAllowedByListeners` even though the Gateway/listener config is correct.

Until Cilium is upgraded to `>=1.20` GA, `unifi.local.julianmaze.com` will not
work through the Gateway at all. In the meantime, access unifi directly via
its LoadBalancer IP (`https://10.50.25.3:8443`, self-signed cert) or the
`inform` endpoint above for device adoption.
