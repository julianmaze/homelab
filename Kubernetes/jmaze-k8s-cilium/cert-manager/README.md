# cert-manager

https://cert-manager.io/

## Installation with helm

I chose to use helm since it is the only current way to enable support for the gateway API.

https://cert-manager.io/docs/installation/helm/

Additionally, see https://cert-manager.io/docs/installation/configuring-components/ to enable gateway API support.

```bash
helm repo add jetstack https://charts.jetstack.io --force-update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.17.2 \
  --values values.yaml
```

## Cluster Issuer

I use the ACME cluster issuer with a DNS01 solver speced to Cloudflare validation.
https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/

## How to use the cluster issuer

https://cert-manager.io/docs/usage/gateway/

In order to generate a cert for a gateway API gateway listener, the gateway needs to be configured with a `cert-manager.io/cluster-issuer` annotation.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: example
  annotations:
    cert-manager.io/issuer: cloudflare
```

Review the following listeners, and configure the gateway like example 5

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: my-gateway
  namespace: default
  annotations:
    cert-manager.io/issuer: my-issuer
spec:
  gatewayClassName: foo
  listeners:
    # ❌  Missing "tls" block, the following listener is skipped.
    - name: example-1
      port: 80
      protocol: HTTP
      hostname: example.com

    # ❌  Missing "hostname", the following listener is skipped.
    - name: example-2
      port: 443
      protocol: HTTPS
      tls:
        certificateRefs:
          - name: example-com-tls
            kind: Secret
            group: ""

    # ❌  "mode: Passthrough" is not supported, the following listener is skipped.
    - name: example-3
      hostname: example.com
      port: 8443
      protocol: HTTPS
      tls:
        mode: Passthrough
        certificateRefs:
          - name: example-com-tls
            kind: Secret
            group: ""

    # ❌  Cross-namespace secret references are not supported, the following listener is skipped.
    - name: example-4
      hostname: foo.example.com
      port: 8443
      protocol: HTTPS
      allowedRoutes:
        namespaces:
          from: All
      tls:
        mode: Terminate
        certificateRefs:
          - name: example-com-tls
            kind: Secret
            group: ""
            namespace: other-namespace

    # ✅  The following listener is valid.
    - name: example-5
      hostname: bar.example.com # ✅ Required.
      port: 8443
      protocol: HTTPS
      allowedRoutes:
        namespaces:
          from: All
      tls:
        mode: Terminate # ✅ Required. "Terminate" is the only supported mode.
        certificateRefs:
          - name: example-com-tls # ✅ Required.
            kind: Secret # ✅ Optional. "Secret" is the only valid value.
            group: "" # ✅ Optional. "" is the only valid value.
```
