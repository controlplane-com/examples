## Helm chart for Kong on Control Plane

This example walks through the steps to create a Kong on Control Plane.

Before you begin, ensure that the [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) and [Control Plane CLI](https://docs.controlplane.com/reference/cli#install-npm) are installed.

### Choosing Kong deployment model:

- [DB-less](#db-less) Deployment.
- [Traditional](#traditional-with-postgresql-instructions) with PostgreSQL Instructions.

### DB-less Instructions

For more information, [click here](https://docs.konghq.com/gateway/latest/production/deployment-topologies/db-less-and-declarative-config/).  
Steps to run this example:

1. Clone or fork this repository. It is recommended to fork the repository to store your environment configurations in your own repository.

2. Modify the `values.yaml` as needed. Guidelines for modifications:

   - `cpln.gvc` - A GVC where Kong will be created. If a GVC does not exist, you can create one by setting `cpln.create_gvc` to `true`.
   - `kong.name` - This is the unique name for your deployment, for example, **kong-dev**.
   - Only one of the options, `kong.configurations.kong.postgres` or `kong.configurations.kong.dbless`, can be used per deployment. Comment out the option that is **not in use**, depending on the type of backend you need. For DB-less use: `kong.configurations.kong.dbless`
   - Make any necessary changes to the rest of the configuration to suit your needs. Optionally, change the values of the Secrets to be unique.

3. Edit the [kong.yaml](./config/kong.yaml) configuration file. 

4. When ready. Install the helm chart.

   ```bash
   cpln helm install kong-dev -f values.yaml
   ```

   Note: You can modify the values at any time and apply these changes by running the same install command again.

### Traditional with PostgreSQL Instructions
For more information, [click here](https://docs.konghq.com/gateway/latest/production/deployment-topologies/traditional/).

A few possible options integrating PostgreSQL described in this guide:
- Single replica workload of PostgreSQL running on Control Plane
- Highly available multi-master PostgreSQL running on Control Plane
- Integrate your own PostgreSQL

Steps to run this example:

1. Clone or fork this repository. It is recommended to fork the repository to store your environment configurations in your own repository.

2. Choose one of the methods below to integrate with PostgreSQL:
   #### Create Single Instance of PostgreSQL Workload with Control Plane
   Use the `values-postgres.yaml` file with `kong.configurations.postgres.KONG_PG_HOST` marked out. This will automatically create a PostgreSQL workload and connect it with Kong. Make any necessary changes to the rest of the parameters.

   #### Integrate Existing PostgreSQL
   Use the `values-postgres.yaml` file and ensure `kong.configurations.postgres.KONG_PG_HOST` holds the value of a reachable PostgreSQL endpoint that Kong will connect to. Ensure PostgreSQL is reachable. Make any necessary changes to the rest of the parameters.

   #### Use Highly-Available Multi-Master pgEdge Workload with Control Plane
   1. Create a **pgEdge cluster** by following the [instructions here](../pgedge).

   2. Use the `values-pgedge.yaml` file and ensure `kong.configurations.postgres.KONG_PG_HOST` holds the value of a reachable `pgcat` that is deployed with `pgedge`. Make any necessary changes to the rest of the parameters. 

3. If the GVC does not exist, create it and select location(s).

   If you changed the `gvc` parameter in the values file, also update the GVC for the command below.

   ```bash
   cpln gvc create --name dev --location aws-us-west-2
   ```
4. When ready. Install the helm chart.

   ```bash
   cpln helm install kong-dev --gvc dev -f values.yaml
   ```

   Note: You can modify the values at any time and apply these changes by running the same install command again.


### Accessing Proxy and Admin

Kong proxy is exposed using port `8000`. By default, the first port listed in the workload's port list is accessed publicly by the Canonical endpoint.

To access other ports, such as the Admin API and Admin GUI, there are two options:
* Use a VPN, like [Tailscale](../tailscale), to access the endpoint without exposing it to the internet.
* Create a [Dedicated Load Balancer](https://docs.controlplane.com/reference/gvc#load-balancer) and [configure a domain](https://docs.controlplane.com/guides/configure-domain#configure).


### Cleanup

```bash
cpln helm delete kong-dev
```