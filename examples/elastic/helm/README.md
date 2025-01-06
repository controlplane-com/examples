## Elasticsearch Example

This example sets up Elasticsearch cluster, featuring the following configuration:

- Elastic search cluster size can be adjusted using the [values.yaml](values.yaml) file. Without chagne the following will be created:
    - Three master nodes
    - Three data nodes
    - Two ingest nodes
- A persistent storage of 10 GB per replica
- User authentication is disabled
- mTLS is enforced by default with Control Plane outside of Elastic configuration

#### Requirements

- [Control Plane Account](https://controlplane.com)

### CLI

If you haven't already installed the Control Plane CLI, [click here](https://docs.controlplane.com/reference/cli) to do so.

#### Deploy Elasticsearch single-node setup

```bash
cpln helm install --gvc my-gvc  elasticsearch
```

It will take a few minutes for elasticsearch to get to ready state.

#### Connect to Elasticsearch

The Elasticsearch instance we created can be accessed by any workload within your ORG. The connection between the client and server uses mTLS encryption. To test the connection to the database, run the following command from one of the workloads in your ORG:

```BASH
curl http://es-master-0.es-master:9200
curl http://es-master-1.es-master:9200
curl http://es-master-2.es-master:9200
curl http://es-data-0.es-data:9200
```

The Elasticsearch instances we created can be accessed by any workload within your **GVC**. The connection between the client and server uses mTLS encryption. To test the connection to the database, run the following command from one of the workloads in the GVC:

```BASH
# For loadbalanced request
curl http://elasticsearch.elasticsearch.cpln.local:9200

# For dedicated node
curl http://elasticsearch-0.elasticsearch:9200
curl http://elasticsearch-1.elasticsearch:9200
curl http://elasticsearch-2.elasticsearch:9200
```

#### [Test Elasticsearch connectivity](#connect-to-elasticsearch-1)

### cleanup:

#### cli

```bash
cpln helm delete elasticsearch
```