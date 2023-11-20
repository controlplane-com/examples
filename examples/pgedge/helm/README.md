## pgEdge multi-region multi-master example

Creates a pgEdge cluster with multi-master configuration, allowing you to write to each of the masters. The masters can be located in different location each for your clients to use the closes master to read and write to. Please review the values.yaml file.

Default specs:
* A trigger and a function to add any table created using `spock.replicate_ddl` function to the `cpln_default` replication set are applied using [replication.sql](scripts/replication.sql). For further infrotmation, you can read in the [pgEdge documentation](https://docs.pgedge.com/spock_ext/advanced_spock/repset_trigger)
* The cluster is created in three locations, unless otherwise specified, and each location has it's own endpoint described below.

### Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) and [Control Plane CLI](https://docs.controlplane.com/reference/cli#install-npm) must be installed.

1. Clone this repo and update the `values.yaml` file as needed

2. (Optional) Build and push pgEdge image to your private Control Plane image registry

   By default, a publicly available image of pgEdge is used in this example as seen in the `values.yaml` files. 
   The image is built using the [Dockerfile](../image/Dockerfile) that is in the [image](../image) folder.

   If you like to customize the image for your needs and push it to Control Plane private registry you would use the following command while in the  [image](../image) folder.

   ```
   cpln image build --name pgedge-cpln:v1 --push
   ```
   

3. Run the command below from this directory.

   ```bash
   helm template . | cpln apply -f -
   ```

### Testing

1. Connect to the `pgadmin` that is deployed in the `pgedge01` GVC, by navigating to it's canonical endpoint available in Control Plane console. 
   Connection details are as provided in the [values.yaml](values.yaml)

2. Add the servers. The syntax for the internal endpoint is: WOKRLOAD_NAME.GVC_NAME.cpln.local , port 5432. 
   In our example we create three replicas: 
   - pgedge.pgedge01.cpln.local
   - pgedge.pgedge02.cpln.local
   - pgedge.pgedge03.cpln.local

3. Create a replicated table on all nodes by running the following query on any one of the nodes: 
   ```
   select spock.replicate_ddl('create table public.testddl (a int primary key, val2 varchar(10))','{cpln_default}');
   ```

4. Now, you should be able to write to and read from the table on any one of the nodes, and the data will be replicated.

For advanced configuration of pgEdge, please refer to the pgEdge [documentation](https://docs.pgedge.com/).

### Cleanup

**HELM**

```bash
helm template . | cpln delete -f -
```
