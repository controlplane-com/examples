terraform {
  required_providers {
    cpln = {
      version = "1.0.2"
      source   = "controlplane.com/com/cpln"
    }
    google = {
      source  = "hashicorp/google"
      version = "3.42.0"
    }
  }
}

# This example requires Google Cloud DNS (https://console.cloud.google.com/net-services/dns) account with the following:
#
# 1) A domain name with the nameservers pointed to Google Cloud DNS
# 2) Google Cloud DNS API Active (https://console.cloud.google.com/apis/api/dns.googleapis.com/overview)
# 3) A service account that has the 'DNS Administrator' role. The key generated for the service account (.json file)
#    is configured within the google provider below. (https://console.cloud.google.com/apis/api/dns.googleapis.com/credentials)
#
# Terraform Google Provider Documentation
# 1) https://www.terraform.io/docs/providers/google/r/dns_record_set.html
# 2) https://www.terraform.io/docs/providers/google/
#

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

variable "google_dns_project" {
  type    = string
  default = "cpln-test"
}

variable "google_dns_zone" {
  type    = string
  default = "cpln-test"
}

variable "domain_name" {
  type    = string
  default = ""
}

variable "domain_name_description" {
  type    = string
  default = "Domain created using terraform"
}

provider "cpln" {
  org      = var.org
  endpoint = var.endpoint
  profile  = var.profile
  token    = var.token
}

provider "google" {
  credentials = file("~/cpln-test.json")
}

# Data source to obtain the ID of the organization. Used during the DNS provisioning.
data "cpln_org" "org" {}

# Uncomment below to show organization id as output during a terraform apply
# output "org_id" {
#   value = data.cpln_org.org.id
# }

resource "google_dns_record_set" "ns" {

  project      = var.google_dns_project
  name         = "${var.domain_name}."
  managed_zone = var.google_dns_zone
  type         = "NS"
  ttl          = 1800

  rrdatas = ["ns1.cpln.cloud.", "ns2.cpln.cloud.", "ns1.cpln.live.", "ns2.cpln.live."]
}

resource "google_dns_record_set" "txt" {

  project      = var.google_dns_project
  name         = "_cpln-${google_dns_record_set.ns.name}"
  managed_zone = var.google_dns_zone
  type         = "TXT"
  ttl          = 600

  rrdatas = [data.cpln_org.org.id]
}

resource "cpln_domain" "example" {

  depends_on = [google_dns_record_set.ns, google_dns_record_set.txt]

  name        = var.domain_name
  description = var.domain_name_description

  tags = {
    terraform_generated = "true"
  }
}

output "domain_name" {
  value = var.domain_name
}
