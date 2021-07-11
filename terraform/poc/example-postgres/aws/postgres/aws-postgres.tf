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

variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
  default     = "passw0rd"
}

variable "vpc_id" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "subnet_id" {
  type = string
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  #   access_key = "my-access-key"
  #   secret_key = "my-secret-key"
}

resource "aws_subnet" "subnet" {
  vpc_id            = var.vpc_id
  availability_zone = "us-west-2b"
  # cidr_block        = "10.0.2.0/24"
  cidr_block = "172.31.16.0/20"
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [var.subnet_id, aws_subnet.subnet.id]
}

resource "aws_security_group" "allow_vpc_only" {
  name   = "allow_vpc_only"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_block]
  }
}

# Create PostgreSQL DB in AWS - Only accessible within the internal VPC
resource "aws_db_instance" "cpln-database-terraform" {

  identifier        = "cpln-database-terraform"
  instance_class    = "db.t2.micro"
  allocated_storage = 20

  engine         = "postgres"
  engine_version = "12.6"

  username = "postgres"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.allow_vpc_only.id]

  publicly_accessible = false
  skip_final_snapshot = true
  apply_immediately   = true
}

output "postgres_address" {
  value = aws_db_instance.cpln-database-terraform.address
}

output "postgres_port" {
  value = aws_db_instance.cpln-database-terraform.port
}
