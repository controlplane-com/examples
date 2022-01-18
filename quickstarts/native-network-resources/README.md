# Purpose #
Native network resources exist to save you as much money as possible on network 
egress costs.

Network resources connected using Control Plane's Wormhole technology, and which
receive a high traffic volume can quickly generate a correspondingly high egress bill.
Native network resources are directly connected to workloads running on Control Plane,
therefore outbound traffic to those resources is not billed at the standard egress 
rate.

# Prerequisites #
All of the guides require:
* [Terraform](https://www.terraform.io/downloads)
* The CLI for the corresponding cloud provider, configured with proper access
  credentials.

# Usage #
## AWS MSK (Managed Streaming for Apache Kafka) ##
### Disclaimer ###
While the infrastructure set up in this quick start is production-ready, Control Plane
recommends that you choose an appropriate [backend](terraform.io/language/settings/backends)
for terraform so that the state can be shared and re-used by your team.

### Create the infrastructure
Open a shell to the directory: vpc-endpoint-service-for-msk and run the 
create-infrastructure.sh script. E.g. 

```shell
./create-infrastructure.sh <your-msk-cluster-name-here> -r us-east-1 -b kafka.t3.small
```

The script will ask you to confirm the planned infrastructure additions twice, once for
the cluster itself, and once for the networking configuration. After you confirm the 
MSK cluster you might want to grab a cup of coffee, because the process
can take quite a while - up to 40 minutes in some cases.

### Validate the MSK cluster and networking setup
1. Get the bootstrap brokers using the AWS cli. Replace terraform-msk-0 in the command below with your chosen cluster
   name. 
   ```shell
   aws kafka get-bootstrap-brokers --cluster-arn $(aws kafka list-clusters --query 'ClusterInfoList[?ClusterName == `terraform-msk-0`].ClusterArn | [0]' | tr -d '"')
   ``` 
   Sample output: 
   ```shell
   {
    "BootstrapBrokerStringTls": "b-1.terraform-msk-0.c034on.c12.kafka.us-east-1.amazonaws.com:9094,b-2.terraform-msk-0.c034on.c12.kafka.us-east-1.amazonaws.com:9094,b-3.terraform-msk-0.c034on.c12.kafka.us-east-1.amazonaws.com:9094"
   }
   ```
   Use the value of ```BootstrapBrokerStringTls``` in the commands listed below. 
2. Use the AWS console to connect to the bastion host created by
   create-infrastructure.sh.
3. Create a topic.
   ```shell
   /opt/kafka/bin/kafka-topics.sh --topic _cpln_validate_ --bootstrap-server <BootstrapBrokerStringTls> --create --command-config $HOME/client.properties --replication-factor 3 --partitions 3  
   ```
4. Produce messages.
   ```shell
   /opt/kafka/bin/kafka-console-producer.sh --topic _cpln_validate_ --bootstrap-server <BootstrapBrokerStringTls> --producer.config $HOME/client.properties 
   ```
   After you enter the command above, the script will await your input. Each time you press Return/Enter the script
   will write the text you typed to the topic.
5. Consume messages.
   ```shell
   /opt/kafka/bin/kafka-console-consumer.sh --topic _cpln_validate_ --bootstrap-server <BootstrapBrokerStringTls> --from-beginning --consumer.config $HOME/client.properties 
   ```
   You should see all of the messages you wrote in step 4. NOTE: the messages may not be in the same order. In Kafka
   message ordering is preserved within each partition, but not across the entire topic.

### (Optional) Terminate the bastion ec2 instance
create-infrastructure.sh produces a t2.micro ec2 instance that allows for easy access
to the MSK cluster via the Kafka CLI. If you wish, you can terminate this instance now.
But unless you have another way to access the cluster for administrative purposes,
Control Plane recommends that you leave the instance in place.