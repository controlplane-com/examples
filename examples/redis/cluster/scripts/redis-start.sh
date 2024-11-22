#!/bin/bash

set -ex


cp /usr/local/etc/redis/redis-default.conf /usr/local/etc/redis/redis.conf
ip=$(hostname -I)

# Find which member of the Stateful Set this pod is running
# e.g. "redis-cluster-0" -> "0"
PET_ORDINAL=$(echo "$POD_NAME" | rev | cut -d'-' -f 1 | rev)
WORKLOAD_NAME=$(echo $CPLN_WORKLOAD | sed 's|.*/workload/\([^/]*\)$|\1|')
NODE_LIST=""

echo "" >> /usr/local/etc/redis/redis.conf
echo "cluster-announce-ip $WORKLOAD_NAME-$PET_ORDINAL.$WORKLOAD_NAME" >> /usr/local/etc/redis/redis.conf
redis-server /usr/local/etc/redis/redis.conf > /dev/null 2>&1 &
sleep 10

# Waiting for redis to become Healthy
while true; do
    response=$(redis-cli ping 2>&1)
    # Check if the response is "PONG"
    if [[ "$response" == *"PONG"* ]]; then
        echo "Redis node is HEALTHY"
        break
    else
        echo "Waiting for Redis node to become healthy"
    fi
    sleep 5
done

# Construct NODE_LIST
for (( i=0; i<CUSTOM_NUM_NODES; i++ )); do
    NODE_LIST+="$WORKLOAD_NAME-$i.$WORKLOAD_NAME:$CUSTOM_REDIS_PORT "
done

# Trim the trailing space
NODE_LIST=$(echo $NODE_LIST | sed 's/ $//')

# Cluster init
cluster_status=$(redis-cli cluster info | grep "cluster_state" | cut -d':' -f2 | tr -d '\r')

if [[ "$cluster_status" == "ok" ]]; then
    echo "Redis cluster is HEALTHY"
    cluster_status=$(redis-cli cluster info)
    echo "$cluster_status"
else
    while true; do
        all_nodes_healthy=true
        for (( i=0; i<CUSTOM_NUM_NODES; i++ )); do
            # Attempt to ping the current Redis node
            response=$(redis-cli -h "$WORKLOAD_NAME-$i.$WORKLOAD_NAME" -p $CUSTOM_REDIS_PORT ping 2>&1) || true
            # Check if the response is "PONG"
            if [[ "$response" == *"PONG"* ]]; then
                echo "Node $i is HEALTHY. Received PONG."
            else
                echo "Node $i did not respond with PONG. Restarting check from the first node..."
                all_nodes_healthy=false
                break
            fi
        done

        # If this is replica *-0, all nodes are healthy, and the cluster is not initiated, create the cluster
        if [[ $PET_ORDINAL == 0 && "$all_nodes_healthy" == true ]]; then
            cluster_status=$(redis-cli cluster info | grep "cluster_state" | cut -d':' -f2 | tr -d '\r')
            if [ "$cluster_status" = "ok" ]; then
                echo "All nodes are healthy and cluster status is OK."
                break
            else
                echo "Creating Cluster"
                redis-cli --cluster create $NODE_LIST --cluster-replicas 1 --cluster-yes
                break
            fi   
        fi

        # Short delay before restarting loop
        sleep 5
    done
fi

wait