# Voltaire <> Conrad Wireguard Site to Site Tunnel

## Site Info

### Voltaire

The Voltaire site is managed by Julian Maze and hosts the RadiantRealm Plex Server and all supporting infrastructure and storage. The S2S tunnel at the Voltaire site runs inside a Docker container on an rPi 4. 

#### Networks

| Name      | Subnet        | Description                                                                                |
| --------- | ------------- | ------------------------------------------------------------------------------------------ |
| Internal  | `10.50.70.0/27` | Legacy internal server network. Will be retired in favor on storage or container networks. |
| Server    | `10.0.10.0/24`  | Server and storage network for non containerized workloads.                                |
| Container | `10.50.25.0/24` | Container network for hosts serving containerized workloads.                               |

#### VPN router

Raspberry Pi 4 with a DHCP reservation set to `10.50.25.65`

### Conrad

The Conrad site is managed by Ayerton Zoutendijk and hosts the backup storage server. The S2S tunnel at the Conrad site runs inside a Docker container on an rPi 4.

#### Networks

#### VPN Router

## Setting up the S2S tunnel

> [!IMPORTANT]  
> This set of steps will be written in the context from a single site (Voltaire). Repeat this set of steps for the alternate site. It is loosely derived from https://documentation.ubuntu.com/server/how-to/wireguard-vpn/site-to-site/

### Docker

1. Create the external Docker network on the rPi host. Ensure the docker network is a bridge network.

```bash
docker network create --subnet 172.19.0.0/24 wgnet
```

2. Deploy the docker compose services defined in the [docker compose](./docker-compose.yml) file. Ensure the following env vars are set correctly.

For Voltaire
```yaml
- SERVERURL=julianmaze.link
- SERVER_ALLOWEDIPS_PEER_1=10.0.1.0/24
- INTERNAL_SUBNET=10.10.9.1/31
```

For Conrad
```yaml
- SERVERURL=vpn.zfam.us
- SERVER_ALLOWEDIPS_PEER_1=10.50.70.0/27,10.50.25.0/24,10.0.10.0/24
- INTERNAL_SUBNET=10.10.9.1/31
```

Additionally, ensure that the created docker network name is set correctly, and is marked as external. Also ensure the volume mount is configured to a valid path on the VPN router host.

```bash
docker compose up -d
```

This should create a set of directories in the mapped volume path.

### Wireguard
3. The linuxserver wireguard container will automatically create many configuration files. We will need to ajust all of these configurations. First, extract the peer configs from 
