## pgedge multi-region multi-master example

Creates a pgedge cluster with multi-master configuration, allowing you to write to each of the masters. The masters can be located in different location each for your clients to use the closes master to read and write to. Please review the values.yaml file.

### Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) must be installed.

1. Clone this repo and update the `values.yaml` file as needed.

2. Run the command below from this directory.

   ```bash
   helm template . | cpln apply -f -

   ```

### Cleanup

**HELM**

```bash
helm template . | cpln delete -f -
```
