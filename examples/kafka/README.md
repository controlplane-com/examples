## Helm chart for Kafka on Control Plane

This example walks through the steps to create a Kafka cluster on Control Plane.

### Steps to run this example:

Before you begin, ensure that the [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) and [Control Plane CLI](https://docs.controlplane.com/reference/cli#install-npm) are installed.

1. Clone or fork this repository. It is recommended to fork the repository to store your environment configurations in your own repository.

2. Copy `values-example.yaml` to a file named for your environment, for example, `values-kafka-dev.yaml`

3. Modify the `values-kafka-dev.yaml` as needed. Guidelines for modifications:

   - `kafka.gvc` - It's recommended to use an existing GVC where Kafka clients are deployed. If a GVC does not exist, you can create one by setting `kafka.create_gvc` to `true`.
   - `kafka.name` - This is the unique name for your cluster, for example, **kafka-dev-cluster**.
   - `kafka.replicas` - Choose either 1 or 3 for replicas. For high availability (HA), use 3.
   - `kafka.configurations.client_listener_security_protocol` - Choose **PLAINTEXT** or **SASL_PLAINTEXT**. This is the client security protocol configuration.
   - `kafka.secrets.client_passwords` - Ensure it's enabled when using **SASL_PLAINTEXT**.
   - Make any necessary changes to the rest of the configuration to suit your needs. Optionally, change the values of the Secrets to be unique.
   - To disable additional components including `kafka-exporter`, `kafka_ui`, and `kafka_client`, ensure they are commented out.

4. When ready. Install the helm chart.

   ```bash
   cpln helm install kafka-dev-cluster -f values-kafka-dev.yaml
   ```

   Note: You can modify the values at any time and apply these changes by running the same install command again.


### How to connect to the cluster

You can connect to Kafka from the same GVC in which it's deployed using the following methods:

- To connect using the cluster's general address, use `kafka-dev-cluster:9092`.

- To connect to a specific replica, use one of the following addresses based on the replica you wish to connect to:
  - `kafka-dev-cluster-0.kafka-dev-cluster:9092`
  - `kafka-dev-cluster-1.kafka-dev-cluster:9092`
  - `kafka-dev-cluster-2.kafka-dev-cluster:9092`

### Test Kafka Cluster with Kafka Client

1. To activate the Kafka client, make sure `kafka_client` is uncommented in your values file. If necessary, reinstall the chart with the command:
   ```bash
   cpln helm install kafka-dev-cluster -f values-kafka-dev.yaml
   ```
2. To connect to the `kafka-client` workload, navigate through the UI to the appropriate GVC and select the `kafka-client` workload. In the workload details, find and use the **Connect** feature to establish a connection, which can be done either via the UI or by utilizing the CLI command provided there.
3. Once connected, you can write and consume messages through the `kafka-client` workload. If it's `PLAINTEXT`, producer and consumer configurations should be omitted below:

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

### Cleanup

```bash
cpln helm delete kafka-dev-cluster
```