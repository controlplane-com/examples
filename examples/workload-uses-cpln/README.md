# Using the Control Plane CLI within a workload container

This guide is designed to assist you with executing [Control Plane CLI](https://www.npmjs.com/package/@controlplane/cli) commands from within your workload. This capability grants you the flexibility to alter your workload, or any other Control Plane resource, directly within the container. For example, increasing/decreasing the max scale of the workload based the amount of messages in a queue.

The executable of the CLI is: `cpln`.

The [Identity](https://docs.controlplane.com/reference/identity) that is associated with the Workload must be granted the permissions for the commands that will be executed. This is accomplished by creating a [Policy](https://docs.controlplane.com/reference/policy) for each resource that will be modified and binding the necessary permission to the identity.

The `CPLN_TOKEN` environment variable is automatically injected into each workload and is utilized by the CLI for authentication and authorization. For a comprehensive list of built-in environment variables available to the workload, please [click here](https://docs.controlplane.com/reference/workload#built-in-env).

## Installing the CLI within your container

The Dockerfile must be modified to incorporate the installation of the CLI within your container.

There are two installation methods:

1. Using `npm`.
   - If your image has `npm` installed or if the base image is `node`.
2. Downloading and extracting the `cpln` binary compatible with your image.
   - The latest binaries can be downloaded from [here](https://cpln-docs-test.web.app/reference/cli#install-binary).

The following Dockerfile examples demonstrates both of these installation methods.

1. [node](https://github.com/controlplane-com/examples/tree/main/examples/workload-uses-cpln/node/Dockerfile)
   - Executes `npm install -g @controlplane/cli`.
2. [ubuntu](https://github.com/controlplane-com/examples/tree/main/examples/workload-uses-cpln/ubuntu/Dockerfile)
   - Downloads and extracts the `cpln-linux` binary.

## Modify the workload from within the container using the CLI

To allow a workload to modify it's own properties, follow these steps:

1. [Create an Identity](https://docs.controlplane.com/guides/create-identity).
2. [Create the Workload](https://docs.controlplane.com/guides/create-workload) and associate it to the identity created.
3. [Create a policy](https://docs.controlplane.com/guides/policy) targeting the workload, binding the `edit` permission with the identity.

An example of updating the `minScale` property of a workload is available [here](https://github.com/controlplane-com/examples/tree/main/examples/workload-uses-cpln/node) within the `node` folder.
