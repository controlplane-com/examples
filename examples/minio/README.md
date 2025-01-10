# Minio Example

[Minio](https://min.io/docs/minio/kubernetes/upstream/index.html) is an open-source, s3-compatible object storage solution, featuring redundancy and high availability.

## Steps to run this example:

**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) and [Control Plane CLI](https://docs.controlplane.com/reference/cli#install-npm) must be installed.

1. Clone this repo and update the [values.yaml](values.yaml) file as needed.

2. Run the command below from this directory.

   ```bash
   cpln helm install minio --gvc mygvc [--org myorg]
   ```

## Connecting to the Minio dashboard

Once you've deployed the workload, you can access the public endpoint in your browser
(if you've allowed either all inbound connections, or your ip)

When prompted for credentials, give the `accessKey` as the username and the `secretKey` as the password.
The default credentials are:

* ___Username___: some-key
* ___Password___: some-secret