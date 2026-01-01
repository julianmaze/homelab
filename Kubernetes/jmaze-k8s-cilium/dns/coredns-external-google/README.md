# coredns - external google implementation

You may be asking, how does this DNS server differ from coredns-external? Well, coredns-external ultimately forwards all requests to a set of NextDNS servers used for network level ad blocking. This implementation is a bit different and aims to solve the following use cases simoultaneously:

- Resolve K8s specific records internal to K8s (via cluster IP)
- Resolve custom domain FQDNs
- Forward all requests to Google's DNS servers
- Use DNS over TLS to avoid non encrypted DNS calls
  - https://developers.google.com/speed/public-dns/docs/dns-over-tls

Use cases of this DNS server should be limited. Some examples include:

- Troubleshooting DNS blockage issues
- Jackett, Prowlarr, Byparr, Flaresolverr pods
- Utilizing public DNS while accessing internal services

## Installation

```bash
helm repo add coredns-google https://coredns.github.io/helm
helm --namespace=dns install coredns-google coredns/coredns --values values.yaml
```
