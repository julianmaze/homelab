#!/bin/bash

# Wait for tun0 to be assigned an IP (up to 10 seconds)
for i in {1..10}; do
    VPN_IP=$(ip -4 addr show dev tun0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    [ -n "$VPN_IP" ] && break
    sleep 1
done

if [ -z "$VPN_IP" ]; then
    echo "tun0 IP not found; exiting"
    exit 1
fi

# Optional: flush previous rules for old tun0 IPs
# List and delete rules from previous runs (this is naive but works in most setups)
for ip in $(ip rule show | grep 'lookup vpn' | grep -oP '(?<=from )\d+(\.\d+){3}'); do
    ip rule del from $ip lookup vpn 2>/dev/null
done

# Add routing rule and table if needed
ip rule add from "$VPN_IP" lookup vpn
ip route add default dev tun0 table vpn
ip route replace default dev tun0 table vpn || true

echo "VPN policy route set: traffic from $VPN_IP → tun0 via table vpn"
