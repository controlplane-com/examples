terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


variable "region" {
  type    = string
  default = "us-west-2"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type    = string
  default = ""
}

variable "user_data" {
  type      = string
  default   = ""
  sensitive = true
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  #   access_key = "my-access-key"
  #   secret_key = "my-secret-key"
}


resource "aws_security_group" "allow_outbound_only" {
  name   = "allow_outbound_only"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


data "aws_ami" "cpln-latest-agent" {
  most_recent = true

  filter {
    name   = "name"
    values = ["controlplane-agent-*"]
  }

  owners = ["958621391921"]
}

resource "aws_instance" "cpln-aws-agent" {
  
  ami           = data.aws_ami.cpln-latest-agent.id
  instance_type = "t2.micro"

  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.allow_outbound_only.id]

  associate_public_ip_address = true

  user_data = var.user_data
}
