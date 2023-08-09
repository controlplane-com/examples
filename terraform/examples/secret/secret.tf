terraform {
  required_providers {
    cpln = {
      source = "controlplane-com/cpln"
      version = "~> 1.0" # This constraint means use any version in the 1.x range
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


# Below are example secret resource HCL. Remove the comments to try one out!
#
# For certificate or long strings, use the available Terraform file command:
# https://www.terraform.io/docs/configuration/functions/file.html
#
# Sample certificate and key-pair located in the './sample_secrets' folder

#### OPAQUE ####

# resource "cpln_secret" "opaque" {
#   name        = "opaque"
#   description = "opaque description"

#   tags = {
#     terraform_generated = "true"
#     acceptance_test     = "true"
#     secret_type         = "opaque"
#   }

#   opaque {
#     payload  = "opaque_secret_payload"
#     encoding = "plain"
#   }
# }


#### TLS ####

# resource "cpln_secret" "tls" {
#   name        = "tls"
#   description = "tls description "

#   tags = {
#     terraform_generated = "true"
#     acceptance_test     = "true"
#     secret_type         = "tls"
#   }

#   tls {
#     key   = ""
#     cert  = ""
#     chain = ""
#   }
# }


#### GCP ####

# resource "cpln_secret" "gcp" {
#   name        = "gcp"
#   description = "gcp description"

#   tags = {
#     terraform_generated = "true"
#     acceptance_test     = "true"
#     secret_type         = "gcp"
#   }

#   gcp = "{\"type\":\"gcp\",\"project_id\":\"cpln12345\",\"private_key_id\":\"pvt_key\",\"private_key\":\"key\",\"client_email\":\"support@cpln.io\",\"client_id\":\"12744\",\"auth_uri\":\"cloud.google.com\",\"token_uri\":\"token.cloud.google.com\",\"auth_provider_x509_cert_url\":\"cert.google.com\",\"client_x509_cert_url\":\"cert.google.com\"}"
# }


#### AWS ####

# resource "cpln_secret" "aws" {
#   name        = "aws"
#   description = "aws description"

#   tags = {
#     terraform_generated = "true"
#     acceptance_test     = "true"
#     secret_type         = "aws"
#   }

#   aws {
#     secret_key = "AKIAIOSFODNN7EXAMPLE"
#     access_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
#     role_arn   = "arn:awskey"
#   }
# }


#### DOCKER ####

# resource "cpln_secret" "docker" {
#   name        = "docker"
#   description = "docker description"

#   tags = {
#     terraform_generated = "true"
#     acceptance_test     = "true"
#     secret_type         = "docker"
#   }

#   docker = "{\"auths\":{\"your-registry-server\":{\"username\":\"your-name\",\"password\":\"your-pword\",\"email\":\"your-email\",\"auth\":\"<Secret>\"}}}"
# }


#### USERPASS ####

# resource "cpln_secret" "userpass" {
#   name        = "userpass"
#   description = "userpass description"

#   tags = {
#     terraform_generated = "true"
#     acceptance_test     = "true"
#     secret_type         = "userpass"
#   }

#   userpass {
#     username = "cpln_username"
#     password = "cpln_password"
#     encoding = "plain"
#   }
# }


#### KEYPAIR ####

# resource "cpln_secret" "keypair" {

#   name        = "keypair"
#   description = "keypair description"

#   tags = {
#     terraform_generated = "true"
#     acceptance_test     = "true"
#     secret_type         = "keypair"
#   }

#   keypair {
#     secret_key = ""
#     public_key = ""
#     passphrase = ""
#   }
# }


#### AZURE-SDK ####

# resource "cpln_secret" "azure_sdk" {
#   name        = "azuresdk"
#   description = "azuresdk description"

#   tags = {
#     terraform_generated = "true"
#     acceptance_test     = "true"
#     secret_type         = "azure-sdk"
#   }

#   azure_sdk = "{\"subscriptionId\":\"2cd8674e-4f89-4a1f-b420-7a1361b46ef7\",\"tenantId\":\"292f5674-c8b0-488b-9ff8-6d30d77f38d9\",\"clientId\":\"649846ce-d862-49d5-a5eb-7d5aad90f54e\",\"clientSecret\":\"cpln\"}"
# }


