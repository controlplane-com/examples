terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


variable "region" {
  type    = string
  default = "us-west-2"
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  #   access_key = "my-access-key"
  #   secret_key = "my-secret-key"
}

resource "aws_vpc" "vpc" {
  # cidr_block = "10.0.0.0/16"
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
}


resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-west-2a"
  # cidr_block        = "10.0.0.0/24"
  cidr_block = "172.31.32.0/20"
  # map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "subnet_id" {
  value = aws_subnet.subnet.id
}

