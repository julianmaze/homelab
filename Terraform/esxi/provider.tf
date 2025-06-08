terraform {
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
    }
  }

  // jmaze-k8s cluster
  backend "kubernetes" {
    secret_suffix  = "esxi-state"
    config_path    = "~/.kube/config"
    namespace      = "development"
    config_context = "jmaze-k8s"
  }
}

provider "esxi" {
  esxi_hostname = "10.50.70.5"
  esxi_hostport = "22"
  esxi_hostssl  = "443"
  esxi_username = "root"
  esxi_password = nonsensitive(var.esxi_password)
}
