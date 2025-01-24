## Matomo example

This example creates deploys [Matomo](https://matomo.org/) on Control Plane Platform and can be further customized as needed.

### Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) and [Control Plane CLI](https://docs.controlplane.com/reference/cli#install-npm) must be installed.

1. Clone this repo and update the [values.yaml](./values.yaml) file as needed.

2. Create a [dictionary type secret](https://docs.controlplane.com/reference/secret#dictionary) and update the `existingSecret` the [values.yaml](.values.yaml) file. This secret should include the following keys and their corresponding values:
   - `matomo-password`: Set this to your desired Matomo password.
   - `db-password`: Set this to your desired database password.

3. **Optional:** If you need to enable a sidecar, follow these steps:

   3.1 **Enable Sidecar:** Update the `sidecars` section in the [values.yaml](./values.yaml) file to include the sidecar configuration. Below is an example configuration for a cloud-sql-proxy sidecar:

   Example:
   ```yaml
   sidecars:
     - name: cloud-sql-proxy
       image: gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.14.1
       args:
         - --structured-logs
         - --port=3306
         - mydb-dev:us-central1:matomo
         - --credentials-file=/secrets/credentials.json
       cpu: "500m"
       memory: 1Gi
       volumes:
         - uri: 'cpln://secret/matomo-dev-cloud-sql-secret'
           path: /secrets/credentials.json
   ```

   3.2 **Create Secrets for Sidecar:** If your sidecar requires additional secrets, create them in Control Plane and update the `extraSecrets` section in the [values.yaml](./values.yaml) file. Each secret should be listed under the `extraSecrets` array. Be sure to use the [correct type of secret](https://docs.controlplane.com/reference/secret), such as Opaque, Dictionary, or others.

   Example:
   ```yaml
   extraSecrets:
     - matomo-dev-cloud-sql-secret
   ```

4. From this directory, run the following command to install the Helm chart:

   ```bash
   cpln helm install matomo-dev --gvc <YOUR_GVC_NAME>
   ```

### Accessing Matomo

You can log in with the Matomo username that you provided in the [values.yaml](./values.yaml) file and the Matomo password stored in the secret you created earlier, using the [canonical endpoint](https://docs.controlplane.com/reference/workload/general#canonical-endpoint-global) created for the workload.

### Cleanup

**HELM**

1. 
```bash
cpln helm uninstall matomo-dev
```
2. Remove the secret created in Step 2.
