#!/bin/bash

# Update the server
apt update -y
apt upgrade -y

# OPTIONAL - Reboot the server
reboot -n

# Configure and install k3s on agent node
# The token can be found in /var/lib/rancher/k3s/server/token on the first master node
mkdir -p /etc/rancher/k3s
cat <<EOF > /etc/rancher/k3s/config.yaml
server: https://10.50.25.50:6443
token: $TOKEN
EOF

# Configure agent node specific settings
mkdir -p /etc/rancher/k3s/config.yaml.d

# VPN node
cat <<EOF >> /etc/rancher/k3s/config.yaml.d/vpn.yaml
node-taint:
  - "kubernetes.io/role=VPN:NoSchedule"
EOF

# Plex node
cat <<EOF >> /etc/rancher/k3s/config.yaml.d/plex.yaml
node-taint:
  - "kubernetes.io/role=Plex:NoSchedule"
EOF

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.31.6+k3s1 sh -s - agent

# OPTIONAL - Install Cilium CLI
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
# This can additionally be run on your workstation with Cilium CLI installed
cilium status --wait

