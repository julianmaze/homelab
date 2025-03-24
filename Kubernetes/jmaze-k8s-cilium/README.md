# jmaze-k8s-cilium

## Cluster setup

See the setup\_\*.sh scripts to setup a cilium based k8s cluster

### K3s configs

All K3s configs have been made in the setup scripts. See the yaml file that is written to `etc/rancher/k3s/config.yaml`.

See the ADR to understand why each config option has been set.

### Links

https://docs.cilium.io/en/stable/installation/k3s/
https://docs.k3s.io/installation/configuration
https://docs.k3s.io/datastore/ha-embedded

## Cilium Service Mesh via the K8s Gateway API

Gateway API is a Kubernetes SIG-Network subproject to design a successor for the Ingress object. It is a set of resources that model service networking in Kubernetes, and is designed to be role-oriented, portable, expressive, and extensible.

https://docs.cilium.io/en/latest/network/servicemesh/gateway-api/gateway-api/

# ADRs

## K3s

I chose to use K3s because it is a lightweight, single binary installation of Kubernetes that comes out of the box ready to use. It supports everything I want out of a K8s cluster: simplicity, high availability, and built in integrations. Additionally, K3s natively supports other SUSE products such as Rancher and Longhorn which I have made technical investments in. Also, Viasat uses Rancher as its CS (container services) control plane, so it makes sense to use the same tech in the homelab.

| Config Option            | Set to                             | Reason                                                                                                                                        |
| ------------------------ | ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `disable`                | `traefik, servicelb`               | Traefik and ServiceLB are being disabled in favor of Cilium and its service mesh.                                                             |
| `flannel-backend`        | `none`                             | Flannel is being disabled in favor of Ciliums Pod and Service networking inside the kernel (eBPF)                                             |
| `disable-network-policy` | `true`                             | This is needed for Cilium.                                                                                                                    |
| `disable-kube-proxy`     | `true`                             | The [kube-proxy](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/) is being disabled in favor of Cilium's proxy. |
| `resolv-conf`            | `/run/systemd/resolve/resolv.conf` | This is needed to bypass K3s from setting its on resolv-conf config if an IPv6 DNS server is present.                                         |

## Cilium

I chose Cilium primarily due to performance considerations over standard flannel based networking. I also enjoyed its native support for many CNI features, including but not limited to the sidecarless service mesh, L2 IP announcement, eBPF based routing, and ease of use.

### Service Mesh via the Gateway API
Gateway API was chosen over standard ingress primarily due to TLSRoute support. I want to try and route TLS traffic to pods in K8s via the service mesh for services like wireguard. Additionally, I want more practice utilizing a production grade service mesh, and utilizing its feature set fully.
