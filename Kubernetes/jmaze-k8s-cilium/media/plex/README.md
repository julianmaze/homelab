# Plex

## Worker node w/ taint

I chose to run Plex Media Server on its own dedicated worker node with a node taint of `Plex`. See the [`setup_agent_node.sh`](../setup_agent_node.sh) script for setup instructions.

## Plex Data Directory

I chose to store the Plex Media Server database on a seperate data disk. I mounted this data disk to `/plex`. Follow the instructions in the [longhorn README](../longhorn/README.md) regarding adding an external disk to a linux server.

## Deployment via Helm

Chart: https://github.com/plexinc/pms-docker/tree/master/charts/plex-media-server

```bash
STAGE=dev

helm repo add plex https://raw.githubusercontent.com/plexinc/pms-docker/gh-pages
helm upgrade plex-${STAGE} plex/plex-media-server --values ${STAGE}/values.yaml
```
