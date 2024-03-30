## Ollama example

The user interface is the project https://github.com/open-webui/open-webui
It runs on port 8080 as a sidecar to the ollama API. Since 8080 is the first port specified in the workload definition all external traffic is forwarded to it.

The ollama API is the project https://github.com/ollama/ollama
It runs on port 11434 and is accessed by the open-webui sidecar. There is a persistent storage volume of 10Gib (default) that is used to store the models. On startup, a script is used to download a default model (default llama2) if it does not yet exist on the filesystem.

On Control Plane, you can access GPU's from any cloud provider. You can even deploy this example to multiple cloud provider geo locations at the same time and end users will be routed to the closest available location.

### Prerequisites

A Control Plane GVC with at least one location assigned to it.

### Specification

- NVIDIA T4 GPU

### Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) must be installed.

1. Clone this repo and update the `values.yaml` file as needed.

2. Run the command below from this directory.

   ```bash
   cpln helm install ollama --gvc ollama-example
   ```

3. Inspect the workload and access the external endpoint to view the web-ui

### Access the web-ui using the deployment link, found with [CLI](#CLI) or [UI](#UI)

Documentation and examples of how to use the ollama open-webui are available here:
https://github.com/open-webui/open-webui

#### CLI

1. Run the command below to get the deployment link (replacing gvc and workload as needed)

```bash
cpln workload get ollama-example --gvc ollama-example -o json | jq -r '.status.endpoint'
```

#### UI

1. Navigate to the ollama-example workload and click `Open` next to the worklod name

### Cleanup

**HELM**

```bash
cpln helm uninstall ollama
```
