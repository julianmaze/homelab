# twingate

## Installation with Helm
https://www.twingate.com/docs/k8s-helm-chart

Add a new connector in the twingate portal and generate the access token and refresh token before installing the helm chart. 

```bash
helm repo add twingate https://twingate.github.io/helm-charts

# Search the latest helm chart version
helm search repo twingate/connector

# k3s-cilium-1
helm upgrade --install twingate-k3s-cilium-1 twingate/connector -n twingate --set connector.accessToken="" --set connector.refreshToken="" --values k3s-cilium-1.yaml --version 0.1.29
# k3s-cilium-2
helm upgrade --install twingate-k3s-cilium-2 twingate/connector -n twingate --set connector.accessToken="" --set connector.refreshToken="" --values k3s-cilium-2.yaml --version 0.1.29
# k3s-cilium-3
helm upgrade --install twingate-k3s-cilium-3 twingate/connector -n twingate --set connector.accessToken="" --set connector.refreshToken="" --values k3s-cilium-3.yaml --version 0.1.29
```