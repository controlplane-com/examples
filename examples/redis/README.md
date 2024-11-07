## Redis example

This example creates a Redis cluster with 6 nodes on the Control Plane Platform and can be further customized as needed.

### Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) and [Control Plane CLI](https://docs.controlplane.com/reference/cli#install-npm) must be installed.

1. Clone this repo and update the [values.yaml](./values.yaml) file as needed.

2. Run the command below from this directory.

   ```bash
   cpln helm install redis-cluster --gvc mygvc
   ```
   Note:  Typically, it takes 5 minutes for all replicas of the workload to become ready and for the cluster to be created.

### Accessing redis-cluster

Workloads are allowed to access Redis Cluster based on the `firewallConfig` you specify. You can learn more about in our [documentation](https://docs.controlplane.com/reference/workload#internal).

Improtant: To access workloads listening on a TCP port, the client workload must be in the same GVC. Thus, the Redis cluster is accessible to clients running within the same GVC.

#### Option 1:

Syntax: <WORKLOAD_NAME>
```
redis-cli -c -h redis-cluster -p 6379 set mykey "test"
redis-cli -c -h redis-cluster -p 6379 get mykey
```
#### Option 2: (By replica)

Syntax: <REPLICA_NAME>.<WORKLOAD_NAME>
```
redis-cli -c -h redis-cluster-0.redis-cluster -p 6379 set mykey "test"
redis-cli -c -h redis-cluster-1.redis-cluster -p 6379 get mykey
redis-cli -c -h redis-cluster-2.redis-cluster -p 6379 get mykey
redis-cli -c -h redis-cluster-3.redis-cluster -p 6379 get mykey
redis-cli -c -h redis-cluster-4.redis-cluster -p 6379 get mykey
redis-cli -c -h redis-cluster-5.redis-cluster -p 6379 get mykey
```

### Cleanup

**HELM**

```bash
cpln helm uninstall redis-cluster
```
