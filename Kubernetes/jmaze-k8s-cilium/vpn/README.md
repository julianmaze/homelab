# VPN

An agent node (`k3s-cilium-vpn`) has been created to handle VPN connections and currently there is a single connection configured to cyberghost. The connection is made using `openvpn3` and is persistent across reboots.

The VPN runs on iface `tun0`.

The plan is to use the cilium egress gateway to send specific cluster traffic through that iface out of `k3s-cilium-vpn`.

The node is not scheduable without a matching toleration of `kubernetes.io/role=VPN:NoSchedule`
