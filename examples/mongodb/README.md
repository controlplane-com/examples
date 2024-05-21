## MongoDB cluster example

Instructions on running MongoDB cluster.
Supported MongoDB versions for the chart: 4.4.29, 5, 6, 7

### Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) and [Control Plane CLI](https://docs.controlplane.com/reference/cli#install-npm) must be installed.

1. Clone this repo and update the [values.yaml](./values.yaml) file as needed.

2. If advanced replica-set configuration is required, make sure to edit [mongodb-config.yaml](./templates/mongodb-config.yaml) file in templates directory. Please refer to [MongoDB documentation](https://www.mongodb.com/docs/v7.0/reference/replica-configuration/#replica-set-configuration-document) for further instructions.

3. If the GVC does not exist, create it and select location(s).

   ```bash
   cpln gvc create --name mongodb --location aws-us-west-2
   ```

4. Run the command below from this directory.

   ```bash
   cpln helm install mongodb --gvc mongodb
   ```

### Accessing MongoDB cluster

Workloads are allowed to access MongoDB Cluster based on the `firewall` configuration you specify. You can learn more about in our [documentation](https://docs.controlplane.com/reference/workload#internal).

To resolve a specific MongoDB workload's replica, the client must be in the same GVC.  
Syntax1: `<REPLICA_NAME>.<WORKLOAD_NAME>`  
Example1: `mongodb1-0.mongodb1`  
Or  
Syntax2: `<REPLICA_NAME>.<WORKLOAD_NAME>.<GVC_ALIAS>.svc.cluster.local`  
Example2: `mongodb1-1.mongodb1.j3i2ddut40d.svc.cluster.local`  
Look for the GVC Alias on the info page of the GVC in the console, or query using the CLI.

**Note**: All communication between workloads on Control Plane happens within an Istio-based service mesh with enforced mTLS and least privileged access managed using the [firewall](https://docs.controlplane.com/reference/workload#internal) feature. The method described in this example allows only internal communication, which is secured with mTLS and a firewall.

### Cleanup

**HELM**

```bash
cpln helm uninstall mongodb
```
