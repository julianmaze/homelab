
resource "esxi_virtual_disk" "longhorn" {
  count                   = var.cilium_node_count
  virtual_disk_disk_store = var.disk_store
  virtual_disk_dir        = "k3s-cilium-${count.index + 1}"
  virtual_disk_name       = "longhorn.vmdk"
  virtual_disk_size       = 200
  virtual_disk_type       = "thin"
}

resource "esxi_guest" "k3s-cilium" {
  count                  = var.cilium_node_count
  guest_name             = "k3s-cilium-${count.index + 1}"
  guest_shutdown_timeout = 20
  guest_startup_timeout  = 120


  boot_firmware  = "efi"
  boot_disk_size = "100" # 100 GB
  boot_disk_type = "thin"
  disk_store     = var.disk_store
  memsize        = "16384" # 16 GB
  numvcpus       = "6"
  guestos        = "ubuntu-64"

  network_interfaces {
    virtual_network = "Docker VLAN 25"
    nic_type        = "vmxnet3"
  }

  power = "off"

  depends_on = [esxi_virtual_disk.longhorn]

  # Additional Disks
  # - Longhorn
  virtual_disks {
    virtual_disk_id = esxi_virtual_disk.longhorn[count.index].id
    slot            = "0:${count.index + 1}"
  }

  lifecycle {
    ignore_changes = [power, virtual_disks[0].virtual_disk_id]
  }
}

resource "esxi_guest" "k3s-cilium-vpn" {
  guest_name             = "k3s-cilium-vpn"
  guest_shutdown_timeout = 20
  guest_startup_timeout  = 120


  boot_firmware  = "efi"
  boot_disk_size = "50" # 50 GB
  boot_disk_type = "thin"
  disk_store     = var.disk_store
  memsize        = "8192" # 8 GB
  numvcpus       = "4"
  guestos        = "ubuntu-64"

  network_interfaces {
    virtual_network = "Docker VLAN 25"
    nic_type        = "vmxnet3"
  }

  power = "off"

  lifecycle {
    ignore_changes = [power, virtual_disks[0].virtual_disk_id]
  }
}
