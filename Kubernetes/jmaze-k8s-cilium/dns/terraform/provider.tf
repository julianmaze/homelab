# Networking account
provider "aws" {
  region = var.region
  profile = "admin-networking" # Configured via AWS SSO
}

terraform {
  required_providers {
    aws = {
      version = "5.98.0"
    }
  }
  
  // jmaze-k8s cluster
  backend "kubernetes" {
    secret_suffix = "aws-dns-state"
    config_path   = "~/.kube/config"
    namespace     = "development"
  }
}