## AWS JWT auth example

Creates a workload that uses envoy proxy sidecar, configured to validate AWS Cognito JWT tokens.

### Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) must be installed.

1. Clone this repo and update the `values.yaml` file as needed.

   If you change the `gvc` parameter, also update the GVC for the command below.

2. If the GVC does not exist, create it and select location(s).

   ```bash
   cpln gvc create --name aws-jwt-auth --location aws-us-west-2
   ```

3. Run the command below from this directory.

   ```bash
   cpln helm install aws-jwt-auth --gvc aws-jwt-auth
   ```

4. Inspect the workload and access the external endpoint. Notice how access depends on the existance of a valid AWS Cognito JWT token.

### Cleanup

**HELM**

```bash
cpln helm uninstall aws-jwt-auth
```