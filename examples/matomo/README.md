## Matomo example

This example creates deploys [Matomo](https://matomo.org/) on Control Plane Platform and can be further customized as needed.

### Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) and [Control Plane CLI](https://docs.controlplane.com/reference/cli#install-npm) must be installed.

1. Clone this repo and update the [values.yaml](./values.yaml) file as needed.

2. Create a [dictionary type secret](https://docs.controlplane.com/reference/secret#dictionary) and update the `existingSecret` the [values.yaml](.values.yaml) file. This secret should include the following keys and their corresponding values:
   - `matomo-password`: Set this to your desired Matomo password.
   - `db-password`: Set this to your desired database password.

3. From this directory, run the following command to install the Helm chart:

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
