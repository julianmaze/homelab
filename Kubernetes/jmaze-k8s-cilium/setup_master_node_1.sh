#!/bin/bash

# Update the server
apt update -y
apt upgrade -y

# Configure and install k3s on first master node
mkdir -p /etc/rancher/k3s
cat <<EOF > /etc/rancher/k3s/config.yaml
disable:
  - traefik
  - servicelb
flannel-backend: none
disable-network-policy: true
disable-kube-proxy: true
cluster-init: true
resolv-conf: /run/systemd/resolve/resolv.conf
EOF
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.31.6+k3s1 sh -s - server

# Install Cilium CLI and install Cilium CNI
# CLI
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

# CNI - only needed on the first master node
cilium upgrade --version 1.17.2 \
  --set kubeProxyReplacement=true \
  --set gatewayAPI.enabled=true \
  --set ipam.operator.clusterPoolIPv4PodCIDRList="10.42.0.0/16" \
  --set k8sServiceHost=127.0.0.1 \
  --set k8sServicePort=6443

# Check status
cilium status --wait

# Run connectivity test
cilium connectivity test