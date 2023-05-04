
# Postgres Workload Example

## Prerequisites

1. The [Control Plane CLI](https://cpln-docs-test.web.app/quickstart/quick-start-3-cli)
2. make
3. docker

## Usage

To build and deploy the database image:
1. Build and push the docker image to your preferred registry. e.g. `REPOSITORY=kylecupp TAG=0.1.0 make push-image`
2. Edit `parameters.yaml`, providing arguments for the following parameters:
   - `IMAGE`: The URI of the image you deployed in step 1
   - `WORKLOAD_NAME`: A unique name for the database workload and its related resources
   - `POSTGRES_ARCHIVE_URI` (**optional**): This should be the URI of a Postgresql archive produced by `pg_dump`, stored in S3. **Note: The URI must be of the form: s3://BUCKET/PATH_TO_ARCHIVE**
   - `ORG`: The name of the Control Plane Organization to which the database will be deployed
   - `GVC`: The name of the Control Plane GVC to which the database will be deployed
   - `POSTGRES_USER`: The name of the default database user
   - `POSTGRES_PASSWORD`: The password for the default database user
3. Run `make build-manifest`. This will produce a file named `manifest.yaml`.
4. Inspect `manifest.yaml` to ensure it matches your expectations. Repeat steps 2 and 3 if necessary.
5. Push the manifest to your org/gvc by running `make push-manifest`
