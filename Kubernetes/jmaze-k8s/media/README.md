# Upgrading radarr and sonarr

1. Pull latest helm chart versions

```console
PS C:\Users\jmmaz\OneDrive\Homelab\Projects\Kubernetes\jmaze-k8s\media\sonarr-ds1522-uhd> helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "metallb" chart repository
...Successfully got an update from the "utkuozdemir" chart repository
...Successfully got an update from the "mojo2600" chart repository
...Successfully got an update from the "twingate" chart repository
...Successfully got an update from the "jetstack" chart repository
...Successfully got an update from the "rancher-stable" chart repository
...Successfully got an update from the "coredns" chart repository
...Successfully got an update from the "longhorn" chart repository
...Successfully got an update from the "rancher-latest" chart repository
...Successfully got an update from the "stable" chart repository
...Successfully got an update from the "bitnami" chart repository
...Successfully got an update from the "truecharts" chart repository
Update Complete. ⎈Happy Helming!⎈
```

2. Run the upgrade commands

```powershell
cd "C:\Users\jmmaz\OneDrive\Homelab\Projects\Kubernetes\jmaze-k8s\media\sonarr-ds1522-uhd"
helm upgrade sonarr-ds1522-uhd truecharts/sonarr -n media -f .\helm_values.yaml

cd "C:\Users\jmmaz\OneDrive\Homelab\Projects\Kubernetes\jmaze-k8s\media\sonarr-ds1522"
helm upgrade sonarr-ds1522 truecharts/sonarr -n media -f .\helm_values.yaml

cd "C:\Users\jmmaz\OneDrive\Homelab\Projects\Kubernetes\jmaze-k8s\media\radarr-ds1522"
helm upgrade radarr-ds1522 truecharts/radarr -n media -f .\helm_values.yaml

cd "C:\Users\jmmaz\OneDrive\Homelab\Projects\Kubernetes\jmaze-k8s\media\radarr-ds1522-uhd"
helm upgrade radarr-ds1522-uhd truecharts/radarr -n media -f .\helm_values.yaml
```
