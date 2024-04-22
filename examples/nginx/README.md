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

   If you change the `gvc` parameter, also update the GVC for the command below.

2. If the GVC does not exist, create it and select location(s).

   ```bash
   cpln gvc create --name nginx-example --location aws-us-west-2
   ```

3. Run the command below from this directory.

   ```bash
   cpln helm install nginx-example --gvc nginx-example

   ```

4. Inspect the workloads and access the external endpoint of the nginx workload.

   1. Notice how traffic routes through the nginx workload and is forwarded to the other workloads.

   2. All endpoints use tls by default.

   3. Internal service to service communication uses mutual tls with a verified client certificate.

### Cleanup

**HELM**

```bash
cpln helm uninstall nginx-example
```
