## nginx custom routing example

Creates an nginx proxy which routes traffic to different internally accessable workloads for different request paths and http methods.

### Default Routing Rules

all requests starting with `/` -> `default` workload
all requests starting with `/user` -> `user` workload
all requests starting with `/health` -> 200
all requests starting with `/fail` -> 502
Any 5XX errors are returned the same as the custom `/fail` response.

### Steps to run this example:

**HELM**

update the `values.yaml` file to match the configuration required.

If you change the gvc parameter, also update the GVC for the command below.

```bash
helm template . | cpln apply --gvc nginx-example -f -

```

### Cleanup

**HELM**

```bash
helm template . | cpln delete --gvc nginx-example -f -
```
