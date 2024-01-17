## online-boutique examples

### online-boutique with tracing

This example creates an [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) microservices demo-application on Control Plane.

Control Plane has native integration with OTLP to collect tracing data for workloads. In this example, we are using the otel-collector workload and shipping tracing data collected by Control Plane to Data Dog. You can choose to configure the otel-collector with your preferred backend for tracing or skip Step 2 completely.

It is recommended to use the Helm chart for the example, as it allows customization and the optional use of a multi-master PostgreSQL backend.

### Steps to run this example:

#### Deployment options
1. [Helm](./helm/) (Recommended)
2. Applying manifests with [CLI](#cli) or [UI](#ui)

#### Requirements
* [Control Plane Account](https://controlplane.com)
* Datadog Account

#### cli

If you haven't already installed the Control Plane CLI, [click here](https://docs.controlplane.com/reference/cli) to do so.

Step 1 - Deploy online-boutique 

```bash
cpln apply --gvc online-boutique -f ./online-boutique.yaml
```

Step 2 - Configure Tracing (Optional)

1. Replace `___DD_API_KEY_VALUE___` and `___DD_SITE_VALUE___` with the respective values(Can be found in your Datadog account) from the `datadog-config` secret object found in `otel-collector.yaml`. Additionally, you can configure your otel-collector at this stage to utilize the tracing backend of your preference. EXAMPLE:
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
2. Apply `otel-collector.yaml` to Control Plane
```bash
cpln apply --gvc online-boutique -f ./otel-collector.yaml
```

#### ui

Step 1 - Deploy online-boutique

1. Create a GVC named `online-boutique` and assign the location(s) that you would like to use.
2. Apply the `online-boutique.yaml` file using the `cpln apply >_` option in the upper right corner.

Step 2 - Configure Tracing (Optional)
1. Replace `___DD_API_KEY_VALUE___` and `___DD_SITE_VALUE___` with the respective values (Can be found in your Datadog account) from the `datadog-config` secret object found in `otel-collector.yaml`. Additionally, you can configure your otel-collector at this stage to utilize the tracing backend of your preference. EXAMPLE:
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
3. Apply the `otel-collector.yaml` file using the `cpln apply >_` option in the upper right corner.

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
