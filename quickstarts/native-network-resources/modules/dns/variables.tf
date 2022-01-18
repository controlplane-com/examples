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

variable "region" {
  type = string
  default = "us-east-1"
  description = "The region in which the DNS resources will be configured"
}

variable "aliases" {
  type = map(object({
    from-name = string
    to-name = string
  }))
}

variable "vpc-id" {
  type = string
}

variable "nlb-zone-id" {
  type = string
}