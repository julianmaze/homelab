variable "esxi_password" {
  sensitive = true
  type      = string
}

variable "disk_store" {
  default = "RAID_10_SSD"
  type    = string
}

variable "cilium_node_count" {
  default = 0
  type    = number
}
