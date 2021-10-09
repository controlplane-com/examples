terraform {
  required_providers {
    cpln = {
      version = "1.0.1"
      source   = "controlplane.com/com/cpln"
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

variable token {
  type    = string
  default = ""
}

provider "cpln" {
  org      = var.org
  endpoint = var.endpoint
  profile  = var.profile
  token    = var.token
}

resource "cpln_service_account" "terraform_service_account_example" {

  name        = "service-account-terraform-example"
  description = "service account description example"

  tags = {
    terraform_generated = "true"
    acceptance_test     = "true"
  }
}

resource "cpln_group" "terraform_group_example" {

  depends_on = [cpln_service_account.terraform_service_account_example]

  name        = "group-terraform-example"
  description = "group description example"

  tags = {
    terraform_generated = "true"
    acceptance_test     = "true"
  }

  // user_id_email = ["unittest@controlplane.com"]

  service_account = [cpln_service_account.terraform_service_account_example.name]

  member_query {

    fetch = "items"
    kind  = "user"

    spec {
      match = "all"

      terms {
        op    = "="
        tag   = "firebase/sign_in_provider"
        value = "microsoft.com"
      }
    }
  }
}
