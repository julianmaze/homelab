# Longhorn
https://longhorn.io/

## Installation Requirements - Important
https://longhorn.io/docs/1.8.1/deploy/install/#installation-requirements

Use the `longhornctl` tool for preflight checks. It will print out a set of issues to address. Note the following script should be run from one of the K3s nodes. If you want to run from a workstation, replace the env vars with the correct K8s connection information.

```bash
# For AMD64 platform
curl -sSfL -o longhornctl https://github.com/longhorn/cli/releases/download/v1.8.1/longhornctl-linux-amd64

chmod +x longhornctl
KUBECONFIG=/etc/rancher/k3s/k3s.yaml KUBERNETES_SERVICE_HOST=127.0.0.1 KUBERNETES_SERVICE_PORT=6443 ./longhornctl check preflight
```

I needed to install NFS and load the dm_crypt module on each of the nodes. As of 3/27/25 these install commands have been added to the node setup scripts
```bash
apt install nfs-common
modprobe dm_crypt
lsmod | grep dm_crypt
echo "dm_crypt" | sudo tee -a /etc/modules
```

## Installation with Helm
https://longhorn.io/docs/1.8.1/deploy/install/install-with-helm/

Follow the guide to install via Helm. The commands have been extracted, but double check them.

> [!CAUTION]
> DO NOT use the Rancher Helm Chart. It uses a custom set of CRDs and can brick your installation.

```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
# helm install [DEPLOYMENT_NAME] [REPO_NAME]/[CHART_NAME]
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.8.1
```
There's an option to configure advanced configuration via Helm. See the article for more details - https://longhorn.io/docs/1.8.1/advanced-resources/deploy/customizing-default-settings/#using-helm

I did not install the helm chart with a custom values file, but this may be necessary for upgrades.

## Cilium Gateway and HTTP Route (ingress)
Apply the cilium gateway and http route to access the longhorn frontend. The code was developed with assistance from: https://longhorn.io/docs/1.8.1/deploy/accessing-the-ui/longhorn-ingress/