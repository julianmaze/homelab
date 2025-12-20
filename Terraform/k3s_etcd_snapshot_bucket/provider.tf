# Master Payer Account (mpa) AWS SSO Profile
provider "aws" {
  region  = var.region
  profile = "mpa" # Configured via AWS SSO
}

terraform {
  required_providers {
    aws = {
      version = "6.27.0"
    }
  }

  // jmaze-k8s-cilium cluster
  backend "kubernetes" {
    secret_suffix  = "aws-k3s-etcd-snapshots"
    config_path    = "~/.kube/config"
    namespace      = "terraform-state"
    config_context = "jmaze-k8s-cilium"
  }
}