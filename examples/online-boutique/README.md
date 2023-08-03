## online-boutique examples

### online-boutique with tracing

This example creates an [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) microserices demo-application on Control Plane.

Control Plane has native integration with OTLP to collect tracing data for workloads. In this example, we are using the otel-collector workload and shipping tracing data collected by Control Plane to Data Dog. You can choose to configure the otel-collector with your preferred backend for tracing or skip Step 2 completely.

### Steps to run this example:

#### cli

Step 1 - Deploy online-boutique

```bash
cpln apply --gvc online-boutique -f ./online-boutique.yaml
cpln gvc add-location online-boutique --location aws-us-east-2
```

Step 2 - Configure Tracing

1. Replace `DD_API_KEY` and `DD_SITE` with your Datadog values for the secret object `datadog-config` in `otel-collector.yaml`. 
You can as well configure your otel-collector in this stage to use the tracing backend of your choice.
2. Apply `otel-collector.yaml` to Control Plane
```bash
cpln apply --gvc online-boutique -f ./otel-collector.yaml
```

### ui

Step 1 - Deploy online-boutique

1. Create a GVC named `online-boutique` and assign the location(s) that you would like to use.
2. Apply the `online-boutique.yaml` file using the `cpln apply >_` option in the upper right corner.

Step 2 - Configure Tracing 
1. Replace `DD_API_KEY` and `DD_SITE` with your Datadog values for the secret object `datadog-config` in `otel-collector.yaml`. 
You can as well configure your otel-collector in this stage to use the tracing backend of your choice.
3. Apply the `otel-collector.yaml` file using the `cpln apply >_` option in the upper right corner.

##### cleanup:

###### cli

```bash
cpln delete --gvc online-boutique -f ./online-boutique.yaml
cpln delete --gvc online-boutique -f ./otel-collector.yaml
```

###### ui

1. delete the gvc `online-collector`.
1. delete the policy `otel-collector-online-boutique`.
1. delete the secrets `otel-collector-config`, `datadog-config` and `redis-boutique-conf`.
