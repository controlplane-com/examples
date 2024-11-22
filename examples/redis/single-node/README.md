## Redis example

This example creates a single node Redis Control Plane Platform and can be further customized as needed.

### Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) and [Control Plane CLI](https://docs.controlplane.com/reference/cli#install-npm) must be installed.

1. Clone this repo and update the [values.yaml](redis-clsuter/values.yaml) file as needed.

2. Run the command below from this directory.

   ```bash
   cpln helm install redis-dev --gvc mygvc
   ```

### Accessing redis

Workloads are allowed to access Redis based on the `firewallConfig` you specify. You can learn more about in our [documentation](https://docs.controlplane.com/reference/workload#internal).

#### Option 1:

Syntax: <WORKLOAD_NAME>
```
redis-cli -c -h redis-dev -p 6379 set mykey "test"
redis-cli -c -h redis-dev -p 6379 get mykey
```
#### Option 2: (By replica)

Syntax: <REPLICA_NAME>.<WORKLOAD_NAME>
```
redis-cli -c -h redis-dev-0.redis-dev -p 6379 set mykey "test"
redis-cli -c -h redis-dev-1.redis-dev -p 6379 get mykey
```

### Cleanup

**HELM**

```bash
cpln helm uninstall redis-dev
```
