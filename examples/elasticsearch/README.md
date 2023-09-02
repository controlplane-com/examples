## Elasticsearch Example

### Elasticsearch single-node

This example sets up a single-node elasticsearch, featuring the following configuration:
* Single-node Elasticsearch deployment
* A persistent storage of 10 GB
* Authentication with `elastic` user and password
* mTLS is enforced by default with Control Plane outside of Elastic configuration
* Deploy to AWS us-east-2 location

Note: This configuration will be created for this example. To modify the configuration to suit your needs, please edit the [elastic.yaml](./elastic.yaml) file.

### Steps to run this example:

#### Requirements
* [Control Plane Account](https://controlplane.com)

Deploy with [CLI](#cli) or [UI](#ui)

### CLI

If you haven't already installed the Control Plane CLI, [click here](https://docs.controlplane.com/reference/cli) to do so.

#### Deploy Elasticsearch single-node setup

```bash
cpln apply --gvc elasticsearch -f ./elastic.yaml
```
It will take a few minutes for elasticsearch  to get to ready state.

#### Connect to Elasticsearch

The Elasticsearch instance we created can be accessed by any workload within your ORG. The connection between the client and server uses mTLS encryption. To test the connection to the database, run the following command from one of the workloads in your ORG:

```BASH
curl -u elastic:34f#@F43d2k87mbv43 http://elasticsearch.elasticsearch.cpln.local:9200
``` 

### UI

#### Deploy Elasticsearch single-node setup

1. Create a GVC named `elasticsearch` and assign the location(s) that you would like to use.
2. Apply the `elastic.yaml` file using the `cpln apply >_` option in the upper right corner. Ensure that the `locationLinks` match the GVC location(s) you selected before applying.

It will take a few minutes for Elasticsearch to get to ready state.

#### [Test Elasitcsearch connectivity](#connect-to-elasticsearch)

### cleanup:

#### cli

```bash
cpln delete --gvc elasticsearch -f ./elastic.yaml
```

#### ui

1. delete the gvc `elasticsearch`.
1. delete the policy `elasticsearch-policy`.
1. delete the secrets `elasticsearch-config` and `elasticsearch-secrets`.