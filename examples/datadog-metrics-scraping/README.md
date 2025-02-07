# Scraping Control Plane Metrics to Datadog

## Overview

This example demonstrates how to scrape metrics from the Control Plane to Datadog using a Datadog EU agent workload and an OpenMetrics configuration. The provided `manifest.yaml` file contains the necessary configuration to deploy a Datadog agent that scrapes `cpu_used` and `mem_used` metrics.

## How It Works

The OpenMetrics configuration utilizes the `/federate` endpoint from the **Control Plane Metrics API** to retrieve metrics in a plaintext format that OpenMetrics understands. This data is then scraped and ingested into Datadog using the [OpenMetrics integration](https://docs.datadoghq.com/integrations/openmetrics/). These metrics are classified as [custom metrics](https://docs.datadoghq.com/metrics/custom_metrics) in Datadog and can be found in the **Summary** section of the **Metrics** page in the Datadog dashboard.

This method leverages [Prometheus support for Datadog Agent](https://www.datadoghq.com/blog/monitor-prometheus-metrics/), allowing Prometheus metrics to be collected and monitored within Datadog using [OpenMetrics](https://docs.datadoghq.com/integrations/openmetrics/).

## Prerequisites

- A valid [Datadog API Key](https://docs.datadoghq.com/account_management/api-app-keys/) (DD_API_KEY).
- A [Control Plane Service Account](https://docs.controlplane.com/guides/create-service-account) key.

## Setting Up the Control Plane Token

If you haven't created a Service Account yet, you'll need to do so first. Follow the instructions in this guide: [Create a Service Account](https://docs.controlplane.com/guides/create-service-account).

The Control Plane service account token will be used in the Datadog OpenMetrics `conf.yaml`, so it must have the `metricsReader` permission to read from the Control Plane Metrics API. To achieve this, you need to create a policy for the service account.

### Creating a Policy for the Service Account

To set up the necessary permissions, follow these steps:

1. Navigate to the [Control Plane Console](https://console.cpln.io).
2. Click on the Apply button located in the top-right corner of the page.
3. Copy and paste the following policy manifest into the text area:

   ```yaml
   kind: policy
   name: datadog-service-account
   bindings:
     - permissions:
         - view
         - readMetrics
       principalLinks:
         - //serviceaccount/<YOUR-SERVICE-ACCOUNT-NAME>
   target: all
   targetKind: org
   ```

4. Replace `<YOUR-SERVICE-ACCOUNT-NAME>` with the name of your service account.
5. Click **Apply** on the bottom-right corner of the page.

Once the token is set up with the correct permissions, it can be used for scraping metrics as described in the deployment steps below.

## Deployment Methods

You can apply the `manifest.yaml` file using one of the following methods:

### Method 1: Applying via Control Plane UI

1. Navigate to the [Control Plane Console](https://console.cpln.io).
2. Click on the **Apply** button located in the top-right corner of the page.
3. Copy the contents of `manifest.yaml` and paste it into the text area.
4. Update the placeholders:

   - Replace `<YOUR_DD_API_KEY>` with your Datadog API Key.
   - Replace `<YOUR_CPLN_TOKEN>` in the Secret section with your Control Plane Token.
   - Replace `<YOUR_CPLN_ORG_NAME>` with your Control Plane Organization Name.

5. Click Apply on the bottom-right corner of the page.

### Method 2: Applying via Control Plane CLI

1. Download the `manifest.yaml` file.
2. Install and [authenticate](https://docs.controlplane.com/guides/manage-profile) to the [Control Plane CLI](https://docs.controlplane.com/reference/cli).
3. Update the placeholders in `manifest.yaml`:

   - Replace `<YOUR_DD_API_KEY>` with your Datadog API Key.
   - Replace `<YOUR_CPLN_TOKEN>` in the Secret section with your Control Plane Token.
   - Replace `<YOUR_CPLN_ORG_NAME>` with your Control Plane Organization Name.

4. Apply the manifest using the following command:

   ```bash
   cpln apply -f manifest.yaml
   ```

## Available Metrics

Coming Soon...

## Next Steps

- Verify that the Datadog agent is running successfully in your Control Plane environment.
- Check the Datadog dashboard for incoming `cpu_used` and `mem_used` metrics.
- Adjust the OpenMetrics configuration in `manifest.yaml` if additional metrics need to be scraped.

For more details on configuring Datadog agents for Control Plane, refer to the official documentation.

---

If you encounter any issues, please refer to the official [Control Plane Documentation](https://docs.controlplane.com) or [Datadog Documentation](https://docs.datadoghq.com).
