## ClickHouse Cluster example

### ClickHouse Cluster 

This example sets up a ClickHouse cluster with 3 replicas, featuring the following configuration:
* ClickHouse Keeper cluster with 3 replicas
* ClickHouse Cluster with 1 Shard and 2 Replicas (1S_2R)
* A persistent disk of 20 GB
* Deploy to AWS us-east-2 location

Note: This configuration will be created for this example. To modify the configuration to suit your needs, edit the `clickhouse-cluster.yaml` file.

Service discovery is made using the stateful workload service endpoint of `clickhouse-cluster` and the unique `$HOSTNAME` environment variable for each replica.

These names will be `clickhouse-cluster-0`, `clickhouse-cluster-1` and `clickhouse-cluster-2` at runtime.

### Steps to run this example:

#### Requirements
* [Control Plane Account](https://controlplane.com)

### cli

If you haven't already installed the Control Plane CLI, [click here](https://docs.controlplane.com/reference/cli) to do so.

#### Deploy ClickHouse Cluster

```bash
cpln apply --gvc clickhouse-example -f ./clickhouse-cluster.yaml
```
It will take a few minutes for ClickHouse cluster to get to ready state.

#### Test ClickHouse Cluster

1. Connect to one of the `clickhouse-cluster` workload replicas from the **UI** or with **CLI**
```BASH
# Connect to the replica
cpln workload connect clickhouse-cluster --location aws-us-east-2 --replica clickhouse-cluster-0 --container clickhouse-cluster --shell bash --gvc clickhouse-example
``` 
2. Connect to ClickHouse server using clickhouse-client
```BASH
# Connect 
clickhouse-client --host clickhouse-cluster-0.clickhouse-cluster
```
3. Test Reading, writing and shard replication
```BASH
# Check the Cluster State, Shards, and Replicas
SELECT cluster, shard_num, replica_num, host_name, host_address, is_local 
FROM system.clusters;

# EXAMPLE
CREATE DATABASE restaurant_db ON CLUSTER my_cluster;

CREATE TABLE restaurant_db.menu_table ON CLUSTER my_cluster
(
    id UInt64,
    dish_name String,
    ingredients Array(String),
    price Float64
) ENGINE = Distributed(my_cluster, restaurant_db, menu_table_local, id);

CREATE TABLE restaurant_db.menu_table_local
(
    id UInt64,
    dish_name String,
    ingredients Array(String),
    price Float64
) ENGINE = MergeTree()
PARTITION BY id
ORDER BY id;

INSERT INTO restaurant_db.menu_table (id, dish_name, ingredients, price) VALUES
(1, 'Spaghetti Carbonara', ['Spaghetti', 'Eggs', 'Pancetta', 'Pecorino Romano'], 10.50),
(2, 'Margherita Pizza', ['Pizza Dough', 'Tomato Sauce', 'Mozzarella', 'Basil'], 8.00),
(3, 'Caesar Salad', ['Romaine Lettuce', 'Croutons', 'Parmesan', 'Caesar Dressing'], 7.50),
(4, 'Chicken Tikka Masala', ['Chicken', 'Yogurt', 'Tomato Sauce', 'Spices'], 12.00),
(5, 'Beef Burger', ['Bun', 'Beef Patty', 'Lettuce', 'Tomato', 'Cheese'], 9.50);

SELECT * FROM restaurant_db.menu_table;
```

4. To disconnect from the current host, press ctrl+d. Then, connect to the `clickhouse-cluster-1` replica to read from the database.
```BASH
clickhouse-client --host clickhouse-cluster-1.clickhouse-cluster

SELECT * FROM restaurant_db.menu_table;
```

### ui

#### Deploy ClickHouse Cluster

1. Create a GVC named `clickhouse-example` and assign the location(s) that you would like to use.
2. Apply the `clickhouse-cluster.yaml` file using the `cpln apply >_` option in the upper right corner. Ensure that the `locationLinks` match the GVC location(s) you selected.

It will take a few minutes for ClickHouse cluster to get to ready state.

#### [Test Clickhouse Cluster](#test-clickhouse-cluster)

### cleanup:

#### cli

```bash
cpln delete --gvc clickhouse-example -f ./clickhouse-cluster.yaml
```

#### ui

1. delete the gvc `clickhouse-example`.
1. delete the policy `clickhouse-cluster-policy`.
1. delete the secrets `clickhouse-cluster-scripts` and `clickhouse-keeper-configuration`.