# VPN

An agent node (`k3s-cilium-vpn`) has been created to handle VPN connections and currently there is a single connection configured to cyberghost. The connection is made using `openvpn3` and is persistent across reboots.

The VPN runs on iface `tun0`.

The plan is to use the cilium egress gateway to send specific cluster traffic through that iface out of `k3s-cilium-vpn`.

The node is not scheduable without a matching toleration of `kubernetes.io/role=VPN:NoSchedule`

## Egress Gateway

Two vital things were needed in order for the egress gateway to route traffic through the VPN interface.

1. ip routes and ip rules

The `openvpn3-cyberghost.service` was extended to call the `setup-cilium-routing.sh` script. The script gets the IP of the tun0 interface and adds a custom routing rule to look at the VPN route table for traffic from that IP. Note that Cilium masquerades pod traffic to that IP ONLY if #2 is done.

2. enabling eBPF masquerading on `tun0` by explicitly setting it in the devices list

If this is not set, traffic is not masqueraded by default, and therefore VPN packets are lost with no return route.

### Testing commands

```bash
# To see the VPN routes
ip route show
ip rule show
ip route get 8.8.8.8 from TUN0_VPN_IP
ip route show table vpn

# To get the packets hiting tun0
tcpdump -ni tun0 -vv

# To check what interfaces are masquerading traffic - run from the cilium pod on the proper node
cilium-dbg status | grep Masquerading

# To check egress gateway configs
cilium-dbg bpf egress list
```
