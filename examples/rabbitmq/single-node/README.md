## RabbitMQ example

This example creates a single node RabbitMQ on Control Plane Platform and can be further customized as needed.

### Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) and [Control Plane CLI](https://docs.controlplane.com/reference/cli#install-npm) must be installed.

1. Clone this repo and update the [values.yaml](./values.yaml) file as needed.

2. Run the command below from this directory.

   ```bash
   cpln helm install rabbitmq-dev --gvc mygvc
   ```

### Accessing RabbitMQ

Workloads are allowed to access Rabbitmq based on the `firewallConfig` you specify. You can learn more about in our [documentation](https://docs.controlplane.com/reference/workload#internal).

#### Option 1:

Syntax: <WORKLOAD_NAME>:<PORT>
```
rabbitmq-dev.mygvc.cpln.local:5672
```
#### Option 2: (By replica)

Syntax: <REPLICA_NAME>.<WORKLOAD_NAME>
```
rabbitmq-dev-0.rabbitmq-dev:5672
```

### Cleanup

**HELM**

```bash
cpln helm uninstall rabbitmq-dev
```
