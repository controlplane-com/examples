terraform {
  required_providers {
    cpln = {
      source = "controlplane-com/cpln"
      version = "1.0.3"
    }
  }
}

variable "org" {
  type    = string
  default = ""
}

variable "endpoint" {
  type    = string
  default = "https://api.cpln.io"
}

variable "profile" {
  type    = string
  default = "default"
}

provider "cpln" {
  org      = var.org
  endpoint = var.endpoint
  profile  = var.profile
  token    = var.token
}

resource "cpln_service_account" "tf-sa" {

  name        = "terraform-service-account"
  description = "service account description"

  tags = {
    terraform_generated = "true"
    acceptance_test     = "true"
  }
}

resource "cpln_service_account_key" "tf_sa_key_01" {
  service_account_name = cpln_service_account.tf-sa.name
  description          = "key-01-terraform"
}

resource "cpln_service_account_key" "tf_sa_key_02" {

  // remove below to test parallel adding of keys
  // depends_on = [cpln_service_account_key.tf_sa_key_01]

  service_account_name = cpln_service_account.tf-sa.name
  description          = "key-02-terraform"
}
