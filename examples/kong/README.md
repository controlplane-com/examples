## Helm chart for Kong on Control Plane

This example walks through the steps to create a Kong on Control Plane.

### Steps to run this example:

Before you begin, ensure that the [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) and [Control Plane CLI](https://docs.controlplane.com/reference/cli#install-npm) are installed.

1. Clone or fork this repository. It is recommended to fork the repository to store your environment configurations in your own repository.

2. Modify the `values.yaml` as needed. Guidelines for modifications:

   - `cpln.gvc` - A GVC where Kong will be created. If a GVC does not exist, you can create one by setting `cpln.create_gvc` to `true`.
   - `kong.name` - This is the unique name for your deployment, for example, **kong-dev**.
   - Only one of the options, `kong.configurations.kong.postgres` or `kong.configurations.kong.dbless`, can be used per deployment. Comment out the option that is not in use, depending on the type of backend you need.
   - Make any necessary changes to the rest of the configuration to suit your needs. Optionally, change the values of the Secrets to be unique.

3. When ready. Install the helm chart.

   ```bash
   cpln helm install kong-dev -f values.yaml
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