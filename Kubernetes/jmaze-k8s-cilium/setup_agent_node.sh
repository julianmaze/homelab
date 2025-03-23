#!/bin/bash

# Update the server
apt update -y
apt upgrade -y

# Configure and install k3s on second master node - note the cluster-init: false and that cilium is already installed
# The token can be found in /var/lib/rancher/k3s/server/token on the first master node
# mkdir -p /etc/rancher/k3s
# cat <<EOF > /etc/rancher/k3s/config.yaml
# disable:
#   - traefik
#   - servicelb
# flannel-backend: none
# disable-network-policy: true
# cluster-init: false
# server: https://10.50.25.50:6443
# token: $TOKEN
# EOF
# curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.31.6+k3s1 sh -s - server

# Install Cilium CLI
# CLI
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

# Check status
cilium status --wait

