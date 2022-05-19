terraform {
  required_providers {
    cpln = {
      source = "controlplane-com/cpln"
      version = "1.0.3"
    }
  }
}

# REQUIRED
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

variable "token" {
  type    = string
  default = ""
}

variable "aws-region" {
  type    = string
  default = "us-west-2"
}

provider "cpln" {
  org      = var.org
  endpoint = var.endpoint
  profile  = var.profile
  token    = var.token
}


module "aws-network" {
  source = "./aws/network"
  region = var.aws-region
}

module "aws-postgres" {
  source     = "./aws/postgres"
  region     = var.aws-region
  vpc_id     = module.aws-network.vpc_id
  cidr_block = module.aws-network.vpc_cidr_block
  subnet_id  = module.aws-network.subnet_id
}


# Create agent
resource "cpln_agent" "terraform-aws-agent-example" {
  name        = "terraform-aws-agent"
  description = "AWS Agent created using terraform"
}

# Launch wormhole agent in AWS

module "aws-agent" {
  source    = "./aws"
  vpc_id    = module.aws-network.vpc_id
  subnet_id = module.aws-network.subnet_id
  user_data = cpln_agent.terraform-aws-agent-example.user_data
}

# Create GVC
resource "cpln_gvc" "terraform-gvc-example" {

  name        = "terraform-gvc"
  description = "GVC created using terraform"

  # Sample locations: aws-eu-central-1, aws-us-west-2, azure-eastus2, gcp-us-east1
  locations = ["aws-us-west-2"]

  tags = {
    terraform_generated = "true"
  }
}

# Create identity and network resource
resource "cpln_identity" "terraform-identity-example" {

  gvc = cpln_gvc.terraform-gvc-example.name

  name        = "terraform-identity"
  description = "Identity created using terraform"

  tags = {
    terraform_generated = "true"
  }

  network_resource {

    agent_link = cpln_agent.terraform-aws-agent-example.self_link

    name = module.aws-postgres.postgres_address
    fqdn = module.aws-postgres.postgres_address

    # Multiple ports must be entered in ascending order (e.g., [80, 8080, 5439])
    ports = [module.aws-postgres.postgres_port]
  }
}

resource "cpln_secret" "pgAdmin-password" {

  name        = "pgadminpassword"
  description = "Password for pgAdmin"

  tags = {
    terraform_generated = "true"
  }

  opaque {
    payload  = "p@ssw0rd"
    encoding = "plain"
  }
}

resource "cpln_policy" "pgAdmin-password-policy" {

  name        = "pgadmin-password-policy"
  description = "Policy for pgAdmin password access"

  tags = {
    terraform_generated = "true"
  }

  target_kind  = "secret"
  target_links = [cpln_secret.pgAdmin-password.name]

  binding {
    permissions     = ["reveal"]
    principal_links = ["gvc/${cpln_gvc.terraform-gvc-example.name}/identity/${cpln_identity.terraform-identity-example.name}"]
  }
}

# Create Workload For Toolbox
resource "cpln_workload" "terraform-cp-workload-toolbox-example" {

  gvc = cpln_gvc.terraform-gvc-example.name

  name        = "toolbox"
  description = "Toolbox workload created using terraform"

  tags = {
    terraform_generated = "true"
  }

  identity_link = cpln_identity.terraform-identity-example.self_link

  container {
    name   = "toolbox"
    image  = "gcr.io/cpln-build/toolbox:421"
    port   = 4200
    memory = "256Mi"
    cpu    = "500m"

    readiness_probe {
      tcp_socket {
        port = 4200
      }

      period_seconds        = 10
      timeout_seconds       = 2
      failure_threshold     = 4
      success_threshold     = 1
      initial_delay_seconds = 1
    }

  }

  options {
    capacity_ai     = false
    timeout_seconds = 30

    autoscaling {
      metric          = "concurrency"
      target          = 100
      max_scale       = 2
      min_scale       = 1
      max_concurrency = 500
    }
  }

  firewall_spec {
    external {
      inbound_allow_cidr  = ["0.0.0.0/0"]
      outbound_allow_cidr = ["0.0.0.0/0"]
    }
    internal {
      # Allowed Types: "none", "same-gvc", "same-org", "workload-list"
      inbound_allow_type     = "none"
      inbound_allow_workload = []
    }
  }
}


# Create Workload for pgAdmin
resource "cpln_workload" "terraform-cp-workload-01-example" {

  gvc = cpln_gvc.terraform-gvc-example.name

  name        = "workload-pgadmin"
  description = "Workload created using terraform"

  tags = {
    terraform_generated = "true"
  }

  identity_link = cpln_identity.terraform-identity-example.self_link

  container {
    name   = "pgadmin4"
    image  = "dpage/pgadmin4"
    port   = 80
    memory = "256Mi"
    cpu    = "500m"

    env = {
      PGADMIN_DEFAULT_EMAIL    = "support@controlplane.com",
      PGADMIN_DEFAULT_PASSWORD = "cpln://secret/${cpln_secret.pgAdmin-password.name}.payload",
      PGADMIN_CONFIG_ENHANCED_COOKIE_PROTECTION = "False"
    }

    readiness_probe {
      tcp_socket {
        port = 80
      }

      period_seconds        = 10
      timeout_seconds       = 2
      failure_threshold     = 4
      success_threshold     = 1
      initial_delay_seconds = 1
    }

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

  options {
    capacity_ai     = false
    timeout_seconds = 30

    autoscaling {
      metric          = "concurrency"
      target          = 100
      max_scale       = 1
      min_scale       = 1
      max_concurrency = 500
    }
  }

  firewall_spec {
    external {
      inbound_allow_cidr  = ["0.0.0.0/0"]
      outbound_allow_cidr = ["0.0.0.0/0"]
    }
    internal {
      # Allowed Types: "none", "same-gvc", "same-org", "workload-list"
      inbound_allow_type     = "none"
      inbound_allow_workload = []
    }
  }
}
