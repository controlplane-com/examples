## Traefik custom routing example

Creates a Traefik proxy which routes traffic to different internally accessible workloads for different request paths.

### Default Routing Rules

- all requests starting with `/foo` -> `foo` workload
- all requests starting with `/bar` -> `bar` workload
- all requests starting with `/ping` -> 200

### Default passwords

A middleware plugin [Basic Auth](https://doc.traefik.io/traefik/middlewares/http/basicauth/), is used in the example with the following user password combinations.
- test1:test1
- test2:test2

### Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) must be installed.

1. Clone this repo and update the `values.yaml` file as needed.

2. If the GVC does not exist, create it and select location(s).

   ```bash
   cpln gvc create --name traefik-example --location aws-us-west-2
   ```

3. Run the command below from this directory.

   ```bash
   cpln helm install traefik-example --gvc traefik-example

   ```

4. Inspect the workloads and access the external endpoint of the traefik workload.

   1. Notice how authentication is enforced on the /foo and /bar endpoints.
   
   2. Traffic is routed through the Traefik workload and forwarded to the internally accessible services.

   2. All endpoints use tls by default.

   3. Internal service to service communication uses mutual tls with a verified client certificate.

### Cleanup

**HELM**

```bash
cpln helm uninstall traefik-example
```
