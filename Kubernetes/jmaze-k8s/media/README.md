# Upgrading radarr and sonarr

As of 1/3/25, the truecharts helm repo is offline and the [docs](https://truecharts.org/guides/helm/) suggest pulling directly from `oci://tccr.io/truecharts`

Run the upgrade commands

```powershell
cd "C:\Users\jmmaz\OneDrive\Homelab\Projects\Kubernetes\jmaze-k8s\media\sonarr-ds1522-uhd"
helm upgrade sonarr-ds1522-uhd oci://tccr.io/truecharts/sonarr -n media -f .\helm_values.yaml

cd "C:\Users\jmmaz\OneDrive\Homelab\Projects\Kubernetes\jmaze-k8s\media\sonarr-ds1522"
helm upgrade sonarr-ds1522 oci://tccr.io/truecharts/sonarr -n media -f .\helm_values.yaml

cd "C:\Users\jmmaz\OneDrive\Homelab\Projects\Kubernetes\jmaze-k8s\media\radarr-ds1522"
helm upgrade radarr-ds1522 oci://tccr.io/truecharts/radarr -n media -f .\helm_values.yaml

cd "C:\Users\jmmaz\OneDrive\Homelab\Projects\Kubernetes\jmaze-k8s\media\radarr-ds1522-uhd"
helm upgrade radarr-ds1522-uhd oci://tccr.io/truecharts/radarr -n media -f .\helm_values.yaml
```
