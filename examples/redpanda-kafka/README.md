## Redpanda Kafka cluster example

Instructions on running a Redpanda Kafka cluster.

### Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) and [Control Plane CLI](https://docs.controlplane.com/reference/cli#install-npm) must be installed.

1. Clone this repo and update the [values.yaml](./values.yaml) file as needed. Use the file to edit Kafka Cluster configurations by modifying the `redpanda.custom_configurations` value as required.

2. If custom configurations to Redpanda Kafka cluster are required, make sure to set these for `redpanda.custom_configurations` in the [values.yaml](./values.yaml) file. Please refer to [RPK documentation](https://docs.redpanda.com/current/reference/properties/) for further instructions.

3. To access the Redpanda Console from the Internet, make sure your IP is whitelisted by updating the `redpanda_console.firewall.external_inboundAllowCIDR` setting in the [values.yaml](./values.yaml) file.  
   It is not recommended to expose this setting to `0.0.0.0/0` without authentication. Authentication and authorization of RedPanda console is a feature requires an Enterprise License with Redpanda. [click here to learn more](https://docs.redpanda.com/current/manage/security/console/authentication/).

4. If the GVC does not exist, create it and select location(s).

   ```bash
   cpln gvc create --name redpanda --location aws-us-west-2
   ```

5. Run the command below from this directory.

   ```bash
   cpln helm install redpanda --gvc redpanda
   ```

### Accessing Redpanda cluster

Workloads are allowed to access Redpanda Cluster based on the `firewall` configuration you specify. You can learn more about in our [documentation](https://docs.controlplane.com/reference/workload#internal).

To resolve a specific Redpanda workload's replica, the client must be in the same GVC.  
Syntax1: `<REPLICA_NAME>.<WORKLOAD_NAME>`  
Example1: `redpanda1-0.redpanda1`  
Or  
Syntax2: `<REPLICA_NAME>.<WORKLOAD_NAME>.<GVC_ALIAS>.svc.cluster.local`  
Example2: `redpanda1-1.redpanda1.j3i2ddut40d.svc.cluster.local`  
Look for the GVC Alias on the info page of the GVC in the console, or query using the CLI.

**Note**: All communication between workloads on Control Plane happens within an Istio-based service mesh with enforced mTLS and least privileged access managed using the [firewall](https://docs.controlplane.com/reference/workload#internal) feature. The method described in this example allows only internal communication, secured with mTLS and a firewall, unless this Helm template is modified to support public access.

### Cleanup

**HELM**

```bash
cpln helm uninstall redpanda
```
