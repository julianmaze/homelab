# Voltaire <> Conrad Wireguard Site to Site Tunnel

## Site Info

### Voltaire

The Voltaire site is managed by Julian Maze and hosts the RadiantRealm Plex Server and all supporting infrastructure and storage. The S2S tunnel at the Voltaire site runs inside a Docker container on an rPi 4.

#### Networks

| Name      | Subnet          | Description                                                                                |
| --------- | --------------- | ------------------------------------------------------------------------------------------ |
| Internal  | `10.50.70.0/27` | Legacy internal server network. Will be retired in favor on storage or container networks. |
| Server    | `10.0.10.0/24`  | Server and storage network for non containerized workloads.                                |
| Container | `10.50.25.0/24` | Container network for hosts serving containerized workloads.                               |

#### VPN router

Raspberry Pi 4 with a DHCP reservation set to `10.50.25.65`

### Conrad

The Conrad site is managed by Ayerton Zoutendijk and hosts the backup storage server. The S2S tunnel at the Conrad site runs inside a Docker container on an rPi 4.

#### Networks

| Name | Subnet        | Description       |
| ---- | ------------- | ----------------- |
| Flat | `10.0.1.0/24` | Internal Network. |

#### VPN Router

## Setting up the S2S tunnel

> [!IMPORTANT]  
> This set of steps will be written in the context from a single site (Voltaire). It will be referred to throughout this guide as the primary site. Repeat this set of steps for another site, this time using the context of that site as primary.
>
> The guide is loosely derived from https://documentation.ubuntu.com/server/how-to/wireguard-vpn/site-to-site/ and several steps are adopted from https://www.linuxserver.io/blog/routing-docker-host-and-container-traffic-through-wireguard.

### Docker

1. Create the external Docker network on the rPi host. Ensure the docker network is a bridge network.

```bash
docker network create --subnet 172.19.0.0/24 wgnet
```

2. Deploy the docker compose services defined in the [docker compose](./docker-compose.yml) file to init the conf files, then stop the container.

First, Ensure the following env vars are set correctly:

For Voltaire, ensure the server URL is set to the FQDN pointing to the IP of the site, and ensure the allowed IPs encompass all the CIDRs of the Conrad site.

```yaml
- SERVERURL=julianmaze.link
- SERVER_ALLOWEDIPS_PEER_1=10.0.1.0/24
- INTERNAL_SUBNET=10.10.9.0/30
```

For Conrad, ensure the server URL is set to the FQDN pointing to the IP of the site, and ensure the allowed IPs encompass all the CIDRs of the Voltaire site.

```yaml
- SERVERURL=vpn.zfam.us
- SERVER_ALLOWEDIPS_PEER_1=10.50.70.0/27,10.50.25.0/24,10.0.10.0/24
- INTERNAL_SUBNET=10.10.9.0/30
```

Additionally, ensure that the created docker network name is set correctly, and is marked as external. Also ensure the volume mount is configured to a valid path on the VPN router host (rPi).

```bash
docker compose up -d
docker compose down
```

### Wireguard

```console
pi@jmaze-rpi:~/wireguard$ ll
total 32
drwxrwxr-x 7 root root 4096 Nov  1  2024 ./
drwxr-x--- 9 pi   pi   4096 Nov  1  2024 ../
-rw------- 1 root root  190 Nov  1  2024 .donoteditthisfile
drwxr-xr-x 2 root root 4096 Nov  1  2024 coredns/
drwx------ 2 root root 4096 Nov  1  2024 peer1/
drwxr-xr-x 2 root root 4096 Nov  1  2024 server/
drwxr-xr-x 2 root root 4096 Nov  1  2024 templates/
drwxr-xr-x 2 root root 4096 Aug  1 19:14 wg_confs/
```

The initialization of the linuxserver wireguard container will create many configuration files in the mapped volume mount path.

3. Share the peer information with the alternate (Conrad) site.

> [!IMPORTANT]  
> Remember, each wireguard container is acting as both a client and a server. This portion of the setup is to ensure the alternate site's wireguard container is configured correctly as a client (peer) to the primary site.

Since the `PEERS` env var is set to `1`, there is a single peer directory that is created. The `peer1.conf` file contains most of the necessary information under the `[Peer]` section of the INI formatted file.

Here is the original info:

```ini
[Peer]
PublicKey = <BASE64_key>
PresharedKey = <BASE64_key>
Endpoint = julianmaze.link:51820
AllowedIPs = 0.0.0.0/0, ::/0
```

Before sharing the peer information, the `AllowedIPs` field must be altered to include all of the CIDRs of the primary site, and the CIDR of the internal wireguard subnet. This is to ensure only the appropriate traffic is routed over the VPN tunnel.

```ini
[Peer]
PublicKey = <BASE64_key>
PresharedKey = <BASE64_key>
Endpoint = julianmaze.link:51820
AllowedIPs = 10.10.9.0/30, 10.50.70.0/27, 10.0.10.0/24, 10.50.25.0/24
```

Add the peer information into the alternate sites `wg_confs/wg0.conf` file.

4.
