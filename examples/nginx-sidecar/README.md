## nginx sidecar example

Creates an nginx proxy which runs as a sidecar to a workload, intercepts requests and rewrites the X-FORWARDED-PROTO header from `http` to `https` before forwarding the request to the local workload container.

### Default Routing Rules

- all requests starting with `/health` -> 200
- all requests starting with `/` -> local workload workload

### Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) must be installed.

1. Clone this repo and update the `values.yaml` file as needed.

   If you change the `gvc` parameter, also update the GVC for the commands below.

2. If the GVC does not exist, create it and select location(s).

3. Run the command below from this directory.

   ```bash
   helm template . | cpln apply --gvc nginx-sidecar -f -

   ```

### Cleanup

**HELM**

```bash
helm template . | cpln delete --gvc nginx-sidecar -f -
```
