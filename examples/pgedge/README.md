## pgEdge multi-region multi-master example

Creates a pgEdge cluster with a multi-master configuration, allowing you to write to each of the masters. The masters can be located in different locations, each for your clients to use the closest master to read and write to. DDL replication is enabled for the database.

By default, `pgcat` will be created in a `pgcat-pgedge` GVC. The endpoint `pgcat.pgcat-pgedge.cpln.local:6432` can be used to serve internal clients from the closest location and load balance the requests to the PostgreSQL servers.

### Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) and [Control Plane CLI](https://docs.controlplane.com/reference/cli#install-npm) must be installed.

1. Clone this repo and update the [values.yaml](values.yaml) file as needed

2. Run the command below from this directory, to install `pgedge-cluster` helm.

   ```bash
   cpln helm install pgedge-cluster -f values.yaml
   ```
   
   Allow a few minutes for database and pgcat to initialize. 

### Testing

1. Connect to the `pgadmin` that is deployed by default in the `pgcat-pgedge` GVC, by navigating to it's canonical endpoint available in Control Plane console. 
   Connection details are as provided in the [values.yaml](values.yaml)

2. Connecting to pgEdge. Either pgcat or directly to pgEdge can be used to connect to the servers.
   The syntax to connect to pgcat: `pgcat.pgcat-pgedge.cpln.local:6432`
   Or directly to pgEdge servers: `WORKLOAD_NAME.GVC_NAME.cpln.local`, port 5432.
   In our example, we create two replicas:
   - pgedge.pg-eastus.cpln.local
   - pgedge.pg-westus.cpln.local

3. Create a table using either connection method above.

4. Now, you should be able to write to and read from the table on any one of the nodes, and the data will be replicated.

For advanced configuration of pgEdge, please refer to the pgEdge [documentation](https://docs.pgedge.com/).

### Cleanup

**HELM**

```bash
cpln helm uninstall pgedge-cluster
```
