## online-boutique examples

### online-boutique with tracing

This example creates an [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) microservices demo-application on Control Plane.

Tracing in Control Plane is available through either the native Control Plane tracing solution or by integrating with the OTel collector to route trace data to your preferred backend. In this example, we default to using Control Plane tracing, but it can be configured to use the OTel collector instead. The steps for this configuration are outlined below.

It is recommended to use the [Helm chart](./helm/) for the example, as it allows customization and the optional use of a multi-master PostgreSQL backend.

### Steps to run this example:

#### Deployment options
1. [Helm](./helm/) (Recommended)
2. Applying manifests with [CLI](#cli) or [UI](#ui)

#### Requirements
* [Control Plane Account](https://controlplane.com)
* Datadog Account

#### cli

If you haven't already installed the Control Plane CLI, [click here](https://docs.controlplane.com/reference/cli) to do so.

   **Step 1 - Tracing configuration**

   Choose **one** of the options below:

   - If not changed, tracing is enabled with Control Plane tracing. Continue to Step 2.
   - To switch to tracing with OTEL to Datadog:
     1. Replace tracing configuration for the `online-boutique` **GVC** object in the [online-boutique.yaml](./online-boutique.yaml) file with:
     ```yaml
       tracing:
         provider:
           otel:
             endpoint: 'otel-collector.online-boutique.cpln.local:4317'
         sampling: 100
     ```
     2. Replace `___DD_API_KEY_VALUE___` and `___DD_SITE_VALUE___` with the respective values(Can be found in your Datadog account) from the `datadog-config` secret object found in [otel-collector.yaml](./otel-collector.yaml). Additionally, you can configure your otel-collector at this stage to utilize the tracing backend of your preference. EXAMPLE:
      ```YAML
      ---
      kind: secret
      name: datadog-config
      description: datadog-config
      tags: {}
      type: dictionary
      data:
        DD_API_KEY: f32jfio43m2fimifigslsl2
        DD_SITE: us5.datadoghq.com
      ```
   - To disable tracing entirely, comment out the entire `tracing` section in the [online-boutique.yaml](./online-boutique.yaml) file.



  **Step 2 - Deploy online-boutique**

  1. Apply [online-boutique.yaml](./online-boutique.yaml) to Control Plane
  ```bash
  cpln apply --gvc online-boutique -f ./online-boutique.yaml
  ```
  2. **OPTIONALLY: If using OTel collector**, apply [otel-collector.yaml](./otel-collector.yaml) to Control Plane. Otherwise, skip this step.
  ```bash
  cpln apply --gvc online-boutique -f ./otel-collector.yaml
  ```

#### ui

   **Step 1 - Tracing configuration**

   Choose **one** of the options below:

   - If not changed, tracing is enabled with Control Plane tracing. Continue to Step 2.
   - To switch to tracing with OTEL to Datadog:
     1. Replace tracing configuration for the `online-boutique` **GVC** object in the [online-boutique.yaml](./online-boutique.yaml) file with:
     ```yaml
       tracing:
         provider:
           otel:
             endpoint: 'otel-collector.online-boutique.cpln.local:4317'
         sampling: 100
     ```
     2. Replace `___DD_API_KEY_VALUE___` and `___DD_SITE_VALUE___` with the respective values(Can be found in your Datadog account) from the `datadog-config` secret object found in [otel-collector.yaml](./otel-collector.yaml). Additionally, you can configure your otel-collector at this stage to utilize the tracing backend of your preference. EXAMPLE:
      ```YAML
      ---
      kind: secret
      name: datadog-config
      description: datadog-config
      tags: {}
      type: dictionary
      data:
        DD_API_KEY: f32jfio43m2fimifigslsl2
        DD_SITE: us5.datadoghq.com
      ```
   - To disable tracing entirely, comment out the entire `tracing` section in the [online-boutique.yaml](./online-boutique.yaml) file.



  **Step 2 - Deploy online-boutique**

  1. Apply the [online-boutique.yaml](./online-boutique.yaml) file using the `cpln apply >_` option in the upper right corner.
  2. **OPTIONALLY: If using OTel collector**, apply the [otel-collector.yaml](./otel-collector.yaml)  file using the `cpln apply >_` option in the upper right corner. Otherwise, skip this step.

### Autoscaling:

To trigger autoscaling, increase the number of users by changing the environment variable `USERS` for `loadgenerator` workload, either in the UI or in the `online-boutique.yaml` file and reapply it.

### cleanup:

#### cli

```bash
cpln delete --gvc online-boutique -f ./otel-collector.yaml
cpln delete --gvc online-boutique -f ./online-boutique.yaml
```

#### ui

1. delete the gvc `online-collector`.
1. delete the policy `otel-collector-online-boutique`.
1. delete the secrets `otel-collector-config`, `datadog-config` and `redis-boutique-conf`.
