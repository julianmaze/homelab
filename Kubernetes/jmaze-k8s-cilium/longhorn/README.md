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

## Prepare the longhorn data disks
I chose to use a seperate data disk to house my longhorn volumes. Each node has a seperate 200gb data disk attached to the VM that needs to be formatted and enabled for scheduling. Follow the below steps to prepare the data disks for longhorn:

1. Identify the new disk:
First, identify the new disk that you want to set up. You can use the `lsblk` command to list all available disks and their partitions:

```bash
lsblk
```

The output will show a list of disks and their partitions. Identify the new disk based on its size or other characteristics.

2. Create a new partition on the disk:
Use a partitioning tool like `fdisk` or `parted` to create a new partition on the new disk. Here, we'll use `fdisk` as an example:

```bash
sudo fdisk /dev/sdX
```

Replace `/dev/sdX` with the actual device name of your new disk (e.g., /dev/sdb).

Inside `fdisk`, use the following steps:
   a. Type `n` to create a new partition.
   b. Select the default partition number (usually 1).
   c. Choose the default start sector to use the whole disk.
   d. Choose the default last sector to use the whole disk.
   e. Type `w` to write the changes and exit.

3. Set up LVM:
Next, you need to set up LVM on the newly created partition. First, initialize the physical volume:

```bash
sudo pvcreate /dev/sdX1
```

Replace `/dev/sdX1` with the partition you created (e.g., /dev/sdb1).

4. Create a volume group:
Create a new volume group and give it a name (e.g., "longhorn_vg"):

```bash
sudo vgcreate longhorn_vg /dev/sdX1
```

Replace `/dev/sdX1` with the partition you created (e.g., /dev/sdb1).

5. Create a logical volume:
Create a logical volume (LV) within the volume group, specifying the size (e.g., 100% of the available space) and a name (e.g., "longhorn_lv"):

```bash
sudo lvcreate -l 100%FREE -n longhorn_lv longhorn_vg
```

6. Format the logical volume:
Format the newly created logical volume with the desired filesystem (e.g., ext4):

```bash
sudo mkfs.ext4 /dev/longhorn_vg/longhorn_lv
```

7. Mount the logical volume:
Create the mount point (/longhorn) and mount the logical volume:

```bash
sudo mkdir /longhorn
sudo mount /dev/longhorn_vg/longhorn_lv /longhorn
```

8. Update /etc/fstab:
To make the mount permanent across reboots, add an entry to `/etc/fstab`:

```bash
echo "/dev/longhorn_vg/longhorn_lv /longhorn ext4 defaults 0 0" | sudo tee -a /etc/fstab
```

Now, the new disk should be set up using LVM, and it will be mounted to `/longhorn` automatically every time the system starts.

## Disk scheduling
In the longhorn UI navigate to Nodes >> Operation >> Edit node disks. Add a new disk of type File System and point to `/longhorn`. I like to delete the default longhorn disk pointing to a path on `/dev/sda`, the OS disk. Be sure to enable scheduling.