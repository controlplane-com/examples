## CockroachDB Example

### CockroachDB multi-region deployment

This example sets up a multi-region CockroachDB, featuring the following configuration:
* Single read-write replica of CockroachDB per location
* A persistent storage of 10 GB
* Deployed in `aws-us-west-2`, `azure-eastus2` and `aws-eu-central-1` locations
* mTLS is enforced by default with Control Plane for node-to-node communication

Note: This configuration will be created for this example. To modify the configuration to suit your needs, please edit the relevant [manifests](./manifests).

### Steps to run this example:

#### Requirements
* [Control Plane Account](https://controlplane.com)

Deploy with [CLI](#cli) or [UI](#ui)

### CLI

If you haven't already installed the Control Plane CLI, [click here](https://docs.controlplane.com/reference/cli) to do so.

### Deploy CockroachDB

#### 1. Create CockroachDB objects

```bash
cpln apply -f manifests/cockroachdb-script.yaml
cpln apply --gvc cockroachdb-useast -f ./cockroachdb-useast.yaml
cpln apply --gvc cockroachdb-uswest -f ./cockroachdb-uswest.yaml
cpln apply --gvc cockroachdb-eucentral -f ./cockroachdb-eucentral.yaml
```
It will take a few minutes for Cockroachdb to get to ready state.

#### 2. Initiate CockroachDB cluster
When the cockroachdb workloads reach a ready state in all of the locations, execute the "init" command on one of the workloads in the cluster.
```bash
# Connect to the CockroachDB replica
cpln workload connect cockroachdb --location azure-eastus2 --replica cockroachdb-0 --container cockroachdb --shell --gvc cockroachdb-useast

# Execute the cluster init command from within the replica
cockroach init --insecure
```

### Connect to CockroachDB

#### 1. Connect to CockroachDB with with Client using the CLI or the UI

```BASH
# Run the Client
cpln apply -f manifests/cockroachdb-client.yaml --gvc cockroachdb-useast

# You can perform this test from the UI or the CLI

# Find the name of the replica to connect
export cockroach_client_replica=$(cpln workload get-replicas cockroachdb-client --gvc cockroachdb-useast --location azure-eastus2 -o json | jq -r '.items[0]')

# Connect to the replica of kafka-client
cpln workload connect cockroachdb-client --location azure-eastus2 --replica $cockroach_client_replica --container cockroachdb-client --shell bash --gvc cockroachdb-useast

# Connect to CockroachDB from within the replica. Ensure the port matches the endpoint
cockroach sql --insecure --host cockroachdb.cockroachdb-useast.cpln.local:26262
``` 
Once connected to the database, you can execute commands for testing. For more information, refer to: [Learn CockroachDB SQL](https://www.cockroachlabs.com/docs/v23.1/learn-cockroachdb-sql)

#### 2. Access Cockroach Web

1. Use the UI or the CLI to whitelist the relevant IP in the firewall. For example:
```bash
firewallConfig:
    external:
      inboundAllowCIDR:
        - 109.184.38.95
      outboundAllowCIDR:
        - 0.0.0.0/0
      outboundAllowHostname: []
      outboundAllowPort: []
```

2. Access the canonical endpoint of the workload 

```bash
cpln workload get cockroachdb --gvc cockroachdb-useast -o json | jq -r '.status.endpoint'
```

### UI

#### Deploy CockroachDB

1. Create three GVCs named `cockroachdb-useast`, `cockroachdb-uswest` and `cockroachdb-eucentral` and assign the location that you would like to use for each of them.
2. Apply the `manifests` files using the `cpln apply >_` option located in the upper right corner. Ensure that the `locationLinks` correspond to the GVC locations you previously selected. Make sure to apply each manifest to its corresponding GVC.

It will take a few minutes for CockroachDB to get to ready state.

#### [Connect to CockroachDB](#connect-to-cockroachdb)

### cleanup:

#### cli

```bash
cpln delete -f manifests/cockroachdb-script.yaml
cpln delete --gvc cockroachdb-useast -f ./cockroachdb-useast.yaml
cpln delete --gvc cockroachdb-uswest -f ./cockroachdb-uswest.yaml
cpln delete --gvc cockroachdb-eucentral -f ./cockroachdb-eucentral.yaml
```
Note: Running above commands couple of times might be needed in order to properly clean up the Workloads and VolumeSets inside the GVC.

#### ui

1. delete the gvc `elasticsearch`. (You will need to clean up the Workloads and VolumeSets first)
1. delete the policies `cockroachdb-eucentral`, `cockroachdb-uswest` and `cockroachdb-useast`.
1. delete the secret `cockroachdb-start-script`.