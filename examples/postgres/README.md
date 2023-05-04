
# Postgres Workload Example

This example demonstrates how to run Postgres on Control Plane

## Usage

### Building the Image

This example relies on an extension of the base `postgres` docker image. Before deploying a workload, you must build and push the Dockerfile in this project image to your preferred registry. Once you do, make a note of the image URI and use it below, in the `IMAGE` parameter

### Generating the YAML manifest

1. Edit `parameters.yaml`, providing arguments for the following parameters:
   - `IMAGE`: The URI of the docker image in this example after it has been pushed to a registry (e.g. `kylecupp/postgres-agent:1.0.0`)
   - `WORKLOAD_NAME`: A unique name for the database workload and its related resources
   - `POSTGRES_ARCHIVE_URI` (**optional**): This should be the URI of a Postgresql archive produced by `pg_dump`, stored in S3. **Note: The URI must be of the form: s3://BUCKET/PATH_TO_ARCHIVE**
   - `ORG`: The name of the Control Plane Organization to which the database will be deployed
   - `GVC`: The name of the Control Plane GVC to which the database will be deployed
   - `POSTGRES_USER`: The name of the default database user
   - `POSTGRES_PASSWORD`: The password for the default database user
2. Run `make build-manifest`. This will produce a file named `manifest.yaml`.
3. Inspect `manifest.yaml` to ensure it matches your expectations. Repeat steps 1 and 2 if necessary.
4. (Optional) Apply `manifest.yaml` using `cpln apply`

### CI/CD

Once the YAML file has been generated, you can customize it if needed and use it in your CI/CD pipelines. 

### (Optional) Allow the Workload Access to S3

If you supplied an argument for `POSTGRES_ARCHIVE_URI`, you'll need to give your new workload access to s3.

1. If you have already created a Cloud Account in Control Plane connected to your AWS account, ignore this step. Otherwise, create a Cloud Account by following the instructions found in the Control Plane Console, under "Cloud Accounts"
2. Edit the identity created for your workload. The identity will be named `$WORKLOAD_NAME-identity`
   - Grant your identity access to the cloud account from step 1 by following the instructions in the Control Plane Console. 