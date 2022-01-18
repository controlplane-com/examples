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

REGION="us-east-1"
BROKER_INSTANCE_TYPE="kafka.t3.small"

usage () {
  echo "Usage: create-infrastructure <cluster> [ -r | --region ] [ -b | --broker-instance-type ] 
  
  Options:
  -r, --region                The AWS region in which to create the infrastructure.
  -b, --broker-instance-type  The Kafka instance type to use for the brokers in the MSK cluster."
  exit 2
}

ARGS=$(getopt -a -n "create-infrastructure" -o r:b:k: --long "region:,broker-instance-type:,key-pair-name" "$@")
eval set -- "$ARGS"

while :
do
  case "$1" in 
  -r | --region) REGION=$2; shift 2;;
  -b | --broker-instance-type) BROKER_INSTANCE_TYPE=$2; shift 2;;
  --) shift; break;;
  esac
done
CLUSTER_NAME="$@"

if [ "$CLUSTER_NAME" == "" ]
  then usage
fi

if [ "$(echo "$CLUSTER_NAME" | grep "\s")" != "" ]
  then echo "Invalid cluster name: $CLUSTER_NAME" 
       usage
fi

#if [ "$KEY_NAME" == "" ]
#  then echo "Missing required option key-pair-name."
#       usage
#fi

cd msk-cluster || exit
terraform init
terraform apply \
  -var="broker-instance-type=$BROKER_INSTANCE_TYPE" \
  -var="name=$CLUSTER_NAME" \
  -var="aws-region=$REGION"

cd ../networking || exit
terraform init
terraform apply \
  -var="name=$CLUSTER_NAME" \
  -var="aws-region=$REGION" 

