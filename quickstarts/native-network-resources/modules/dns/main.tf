# Copyright 2022 Control Plane Corporation
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

resource "aws_route53_zone" "msk-broker-zone" {
  name = "kafka.${var.region}.amazonaws.com"
  vpc {
    vpc_id = var.vpc-id
  }
}

resource "aws_route53_record" "broker-aliases" {
  for_each = var.aliases
  zone_id = aws_route53_zone.msk-broker-zone.zone_id
  name = each.value.from-name
  type = "A"
  
  alias {
    name = each.value.to-name
    zone_id = var.nlb-zone-id
    evaluate_target_health = true
  }
}