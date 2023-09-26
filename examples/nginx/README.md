## nginx custom routing example

Creates an nginx proxy which routes traffic to different internally accessable workloads for different request paths.

### Default Routing Rules

- all requests starting with `/` -> `default` workload
- all requests starting with `/user` -> `user` workload
- all requests starting with `/health` -> 200
- all requests starting with `/fail` -> 502
- Any 5XX errors are returned the same as the custom `/fail` response.

### Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) must be installed.

1. Clone this repo and update the `values.yaml` file as needed.

   If you change the `gvc` parameter, also update the GVC for the commands below.

2. If the GVC does not exist, create it and select location(s).

3. Run the command below from this directory.

   ```bash
   helm template . | cpln apply --gvc nginx-example -f -

   ```

### Cleanup

**HELM**

```bash
helm template . | cpln delete --gvc nginx-example -f -
```
