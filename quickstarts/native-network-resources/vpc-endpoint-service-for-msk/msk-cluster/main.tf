# Copyright 2022 Control Plan Corporation
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

terraform {
  required_providers { 
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.1.0"
}

provider "aws" {
  region = var.aws-region
}

module "msk-cluster" {
  source = "../../modules/msk-cluster"
  name-prefix = var.name
  vpc-cidr = var.vpc-cidr
  subnet-cidr-list = var.subnet-cidr-list
  broker-instance-type = var.broker-instance-type
  broker-count = var.broker-count
  broker-storage-capacity = var.broker-storage-capacity
  cluster-tags = var.tags
}