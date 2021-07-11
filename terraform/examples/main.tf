terraform {
  required_providers {
    cpln = {
      version = "1.0"
      source   = "controlplane.com/com/cpln"
    }
  }
}

# REQUIRED
variable org {
  type    = string
  default = ""
}

# OPTIONAL
variable endpoint {
  type    = string
  default = "https://api.cpln.io"
}

# OPTIONAL
variable profile {
  type    = string
  default = "default"
}

# OPTIONAL
variable token {
  type    = string
  default = ""
}

# REQUIRED
provider "cpln" {
  org      = var.org
  endpoint = var.endpoint
  profile  = var.profile
  token    = var.token
}

variable domain_name {
  type    = string
  default = "domain.example.com"
}

module "domain" {
  source      = "./domain"
  org         = var.org
  domain_name = var.domain_name
}

# Resource declaration must begin with 'cpln_' to match with the name of the provider
# Available resources:
# 1) GVC      -> 'cpln_gvc'
# 2) Workload -> 'cpln_workload'
# 3) Domain   -> 'cpln_domain' (Example .tf file within the /examples/domain folder. Example below uses it as a terraform module)


resource "cpln_gvc" "terraform-cp-gvc-example" {

  name        = "terraform-gvc"
  description = "GVC created using terraform"

  domain = module.domain.domain_name

  # Available locations: aws-eu-central-1, aws-us-west-2, azure-eastus2, gcp-us-east1
  # locations = ["aws-eu-central-1", "aws-us-west-2"]
  locations = ["gcp-us-east1"]

  tags = {
    terraform_generated = "true"
  }
}

resource "cpln_workload" "terraform-cp-workload-01-example" {

  depends_on = [cpln_gvc.terraform-cp-gvc-example]

  gvc = cpln_gvc.terraform-cp-gvc-example.name

  name        = "workload-01"
  description = "Workload 01 created using terraform"

  tags = {
    terraform_generated = "true"
  }

  container {
    name   = "tf-workload-01-container-01"
    image  = "gcr.io/knative-samples/helloworld-go"
    port   = 8080
    memory = "128Mi"
    cpu    = "50m"

    # env = {
    #   env-name-01 = "env-value-01",
    #   env-name-02 = "env-value-02",
    # }

    # args = ["arg-01", "arg-02"]

    # readiness_probe {

    #   tcp_socket {
    #     port = 8181
    #   }

    #   period_seconds        = 11
    #   timeout_seconds       = 2
    #   failure_threshold     = 4
    #   success_threshold     = 2
    #   initial_delay_seconds = 1
    # }

    # liveness_probe {

    #   http_get {
    #     path   = "/"
    #     port   = 8181
    #     scheme = "HTTPS"
    #     http_headers = {
    #       header1 = "value1"
    #     }
    #   }

    #   period_seconds        = 9
    #   timeout_seconds       = 5
    #   failure_threshold     = 2
    #   success_threshold     = 3
    #   initial_delay_seconds = 2
    # }
  }

  # container {
  #   name = "tf-workload-01-container-02"
  #   image  = "gcr.io/knative-samples/helloworld-go"
  #   memory = "128Mi"
  #   cpu    = "50m"

  #   args = ["arg-01", "arg-02"]
  # }

  # options {
  #   capacity_ai     = true
  #   timeout_seconds = 5

  #   autoscaling {
  #     metric          = "concurrency"
  #     target          = 100
  #     max_scale       = 6
  #     min_scale       = 2
  #     max_concurrency = 500
  #   }
  # }

  # firewall_spec {
  #   external {
  #     inbound_allow_cidr      = ["0.0.0.0/0"]
  #     outbound_allow_cidr     = ["0.0.0.0/0"]
  #     outbound_allow_hostname = ["*.controlplane.com", "*.cpln.io"]
  #   }
  #   internal {
  #     # Allowed Types: "none", "same-gvc", "same-org", "workload-list"
  #     inbound_allow_type     = "none"
  #     inbound_allow_workload = []
  #   }
  # }
}


# Uncomment output below to view resources after running terraform apply

# output "terraform-cp-gvc-example" {
#   value = cpln_gvc.terraform-cp-gvc-example
# }

output "terraform-cp-workload-01-example" {
  value = cpln_workload.terraform-cp-workload-01-example
}
