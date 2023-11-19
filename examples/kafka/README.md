## Kafka Cluster Example

### Kafka-cluster 

This example creates a Kafka cluster of 3 replicas, configured with Kraft and persistent storage.

Service discovery is made using the stateful workload service endpoint of `kafka-cluster` and the unique `$HOSTNAME` environment variable for each replica.

These names will be `kafka-cluster-0`, `kafka-cluster-1` and `kafka-cluster-2` at runtime.

### Steps to run this example:

#### Requirements
* [Control Plane Account](https://controlplane.com)

### cli

If you haven't already installed the Control Plane CLI, [click here](https://docs.controlplane.com/reference/cli) to do so.

#### Deploy Kafka Cluster with kafka-exporter

```bash
cpln apply --gvc kafka-cluster-example -f ./kafka-cluster-exporter.yaml
cpln gvc add-location kafka-cluster-example --location aws-us-east-2
```
It will take a few minutes for Kafka cluster to get to ready state.

Note: If you prefer not to include kafka-exporter for reading kafka custom metrics in your deployment, then apply `kafka-cluster.yaml` instead. 

#### Deploy kafka-ui (Optional)

```bash
cpln apply --gvc kafka-cluster-example -f ./kafka-ui.yaml
```

#### Test Kafka Cluster with Kafka Client

1. Deploy kafka-client workload
```BASH
cpln apply --gvc kafka-cluster-example -f ./kafka-client.yaml
```
2. Connect to the kafka-client workload from the UI or with CLI
```BASH
# Find the name of the replica to connect
export kafka_client_replica=$(cpln workload get-replicas kafka-client --gvc kafka-cluster-example --location aws-us-east-2 -o json | jq -r '.items[0]')

# Connect to the replica of kafka-client
cpln workload connect kafka-client --location aws-us-east-2 --replica $kafka_client_replica --container kafka --shell bash --gvc kafka-cluster-example
``` 
3. Write and Consume messages from topic `controlplane` from `kafka-client` workload
```BASH
# Change to bin directory
cd /opt/bitnami/kafka/bin

# Create client.properties
echo "security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"kafka-admin\" password=\"fkor3Dro52oodA\";" > ./client.properties

# Produce messages to the 'controlplane' topic
kafka-console-producer.sh --bootstrap-server kafka-cluster:9092 --topic controlplane --producer.config ./client.properties

# Consume messages from the 'controlplane' topic
kafka-console-consumer.sh --bootstrap-server kafka-cluster:9092 --topic controlplane --from-beginning --consumer.config ./client.properties
```

### ui

#### Deploy Kafka Cluster

1. Create a GVC named `kafka-cluster-example` and assign the location(s) that you would like to use.
2. Apply the `kafka-cluster-exporter.yaml` file using the `cpln apply >_` option in the upper right corner.
3. (Optional) Apply the `kafka-ui.yaml` file using the `cpln apply >_` option in the upper right corner.

It will take a few minutes for Kafka cluster to get to ready state.

Note: If you prefer not to include kafka-exporter for reading kafka custom metrics in your deployment, then apply `kafka-cluster.yaml` instead. 

#### Test Kafka Cluster with Kafka Client

1. Apply the `kafka-client.yaml` file using the `cpln apply >_` option in the upper right corner.
2. Connect to the `kafka-client` workload via the UI by navigating to the GVC `kafka-cluster-example` and selecting the `kafka-client` workload. Once there, locate the "Connect" feature and establish a connection either through the UI or by using the displayed CLI command.
3. Write and Consume messages from topic `controlplane` from `kafka-client` workload
```BASH
# Change to bin directory
cd /opt/bitnami/kafka/bin

# Create client.properties
echo "security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"kafka-admin\" password=\"fkor3Dro52oodA\";" > ./client.properties

# Produce messages to the 'controlplane' topic
kafka-console-producer.sh --bootstrap-server kafka-cluster:9092 --topic controlplane --producer.config ./client.properties

# Consume messages from the 'controlplane' topic
kafka-console-consumer.sh --bootstrap-server kafka-cluster:9092 --topic controlplane --from-beginning --consumer.config ./client.properties
```

### cleanup:

#### cli

```bash
cpln delete --gvc kafka-cluster-example -f ./kafka-client.yaml
cpln delete --gvc kafka-cluster-example -f ./kafka-cluster.yaml
```

#### ui

1. delete the gvc `kafka-cluster-example`.
1. delete the policy `kafka-cluster-policy`.
1. delete the secrets `kafka-cluster-controller-configuration`, `kafka-cluster-kraft-cluster-id`, `kafka-cluster-scripts` and `kafka-cluster-user-passwords`.

#### References
https://github.com/bitnami/charts/tree/main/bitnami/kafka