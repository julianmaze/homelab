# Networking account
provider "aws" {
  region = "us-west-2"
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