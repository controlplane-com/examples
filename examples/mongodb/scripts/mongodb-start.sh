#!/bin/bash

# Mongo4
set -ex

PET_ORDINAL=$(echo "$POD_NAME" | rev | cut -d'-' -f 1 | rev)
WORKLOAD_NAME=$(echo $CPLN_WORKLOAD | sed 's|.*/workload/\([^/]*\)$|\1|')
MONGODB_INIT_FILE=/scripts/initiate-new.cfg

replace_placeholder() {
    local placeholder="${1:?placeholder name}"
    local placeholder_value="${2:?placeholder value}"
    sed -i "s|$placeholder|$placeholder_value|g" "$MONGODB_INIT_FILE"
}

mongod --replSet $CUSTOM_REPL_SET_NAME --bind_ip "localhost,$HOSTNAME.$WORKLOAD_NAME.$CPLN_GVC_ALIAS.svc.cluster.local" --port $CUSTOM_MONGODB_PORT > /proc/1/fd/1 2>/proc/1/fd/2 &
sleep 10

# Check if 'mongo' command exists
if command -v mongo &> /dev/null; then
    echo "mongo command found"
    mongo_cli=true
else
    # Check if 'mongosh' command exists
    if command -v mongosh &> /dev/null; then
        echo "mongosh command found"
        mongosh_cli=true
    else
        echo "Neither mongo nor mongosh command found"
        exit 1
    fi
fi

# Waiting for mongodb to become Healthy
while true; do
    if [ "$mongo_cli" = true ]; then
        response=$(mongo --eval 'db.runCommand("ping").ok' localhost:$CUSTOM_MONGODB_PORT --quiet 2>&1)
    elif [ "$mongosh_cli" = true ]; then
        response=$(mongosh --eval 'db.runCommand("ping").ok' localhost:$CUSTOM_MONGODB_PORT 2>&1)
    fi
    # Check if the response is "1"
    if [[ "$response" == *"1"* ]]; then
        echo "MongoDB node is HEALTHY"
        break
    else
        echo "Waiting for MongoDB node to become healthy"
    fi
    sleep 5
done

# Replicaset init
if [ "$mongo_cli" = true ]; then
    repset_status=$(mongo --eval 'db.adminCommand( { replSetGetStatus: 1 } ).ok' localhost:$CUSTOM_MONGODB_PORT --quiet 2>&1) || true
elif [ "$mongosh_cli" = true ]; then
    repset_status=$(mongosh --eval 'db.adminCommand( { replSetGetStatus: 1 } ).ok' localhost:$CUSTOM_MONGODB_PORT 2>&1) || true
fi

if [[ "$repset_status" == "1" ]]; then
    echo "MongoDB cluster is initiated"
    if [ "$mongo_cli" = true ]; then
        repset_status=$(mongo --eval 'db.adminCommand( { replSetGetStatus: 1 } )' localhost:$CUSTOM_MONGODB_PORT --quiet 2>&1)
    elif [ "$mongosh_cli" = true ]; then
        repset_status=$(mongosh --eval 'db.adminCommand( { replSetGetStatus: 1 } )' localhost:$CUSTOM_MONGODB_PORT 2>&1)
    fi
    echo "$repset_status"
elif [[ $PET_ORDINAL == 0 ]]; then
    while true; do
        all_nodes_healthy=true

        for (( i=0; i<CUSTOM_NUM_NODES; i++ )); do

            # Attempt to ping the current MongoDB node
            if [ "$mongo_cli" = true ]; then
                response=$(mongo --eval 'db.runCommand("ping").ok' --host $HOSTNAME.$WORKLOAD_NAME.$CPLN_GVC_ALIAS.svc.cluster.local:$CUSTOM_MONGODB_PORT --quiet 2>&1) || true
            elif [ "$mongosh_cli" = true ]; then
                response=$(mongosh --eval 'db.runCommand("ping").ok' --host $HOSTNAME.$WORKLOAD_NAME.$CPLN_GVC_ALIAS.svc.cluster.local:$CUSTOM_MONGODB_PORT 2>&1) || true
            fi
            # Check if the response is "1"
            if [[ "$response" == *"1"* ]]; then
                echo "Node $i is HEALTHY."
            else
                echo "Node $i did not respond as expected. Restarting check from the first node..."
                all_nodes_healthy=false
                break
            fi
        done

        # If this is replica *-0, all nodes are healthy, and the cluster is not initiated, initiate the replica set
        if [[ $PET_ORDINAL == 0 && "$all_nodes_healthy" == true ]]; then
        
            if [ "$mongo_cli" = true ]; then
                repset_status=$(mongo --eval 'db.adminCommand( { replSetGetStatus: 1 } ).ok' localhost:$CUSTOM_MONGODB_PORT --quiet 2>&1) || true
            elif [ "$mongosh_cli" = true ]; then
                repset_status=$(mongosh --eval 'db.adminCommand( { replSetGetStatus: 1 } ).ok' localhost:$CUSTOM_MONGODB_PORT 2>&1) || true
            fi

            if [ "$repset_status" = "1" ]; then
                echo "All nodes are healthy and cluster status is OK."
                break
            else
                echo "Initiating MongoDB replica set"
                cp /scripts/initiate.cfg /scripts/initiate-new.cfg
                replace_placeholder "___CPLN_GVC_ALIAS___" "$CPLN_GVC_ALIAS"
                if [ "$mongo_cli" = true ]; then
                    mongo --host localhost:$CUSTOM_MONGODB_PORT <<EOF
                        var cfg=$(cat /scripts/initiate-new.cfg);
EOF
                elif [ "$mongosh_cli" = true ]; then
                    mongosh --host localhost:$CUSTOM_MONGODB_PORT <<EOF
                        var cfg=$(cat /scripts/initiate-new.cfg);
EOF
                fi
            fi
        fi

        # Short delay before restarting loop
        sleep 5
    done
fi

wait