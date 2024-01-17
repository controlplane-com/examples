## MySQL examples

This example creates a MySQL server on Control Plane.

This example deploys the applications in the `aws-us-east-2` location. You can edit the [mysql.yaml](./mysql.yaml) to further customize the deployment.

### Steps to run this example:

#### Requirements
* [Control Plane Account](https://controlplane.com)

#### cli

If you haven't already installed the Control Plane CLI, [click here](https://docs.controlplane.com/reference/cli) to do so.

Step 1 - Deploy MySQL Server

```bash
cpln apply -f ./mysql.yaml
```

#### ui

Step 1 - Deploy MySQL Server

1. Create a GVC named `mysql-example` and assign the location(s) that you would like to use.
2. Apply the `mysql.yaml` file using the `cpln apply >_` option in the upper right corner.

### To Connect

The MySQL server is accessible internally from other workloads in the same GVC using the syntax: `<replica>.<workload>` ; For this example: `mysql-0.mysql-example`.

### cleanup:

#### cli

```bash
cpln delete -f ./mysql.yaml
```

#### ui

1. delete the workload `mysql`
2. delete the volumeset `mysql-data`
3. delete the policy `mysql-policy`
4. delete the secret `mysql-secret`
5. delete the gvc `mysql-example`
