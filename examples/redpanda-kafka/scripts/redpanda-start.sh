#!/bin/bash

set -x

MAX_SEEDS=3
NUM_REPLICAS=${CUSTOM_RPK_REPLICAS:-3}
NUM_SEEDS=$(( NUM_REPLICAS > MAX_SEEDS ? MAX_SEEDS : NUM_REPLICAS ))
PET_ORDINAL=$(echo "$POD_NAME" | rev | cut -d'-' -f 1 | rev)
WORKLOAD_NAME=$(echo $CPLN_WORKLOAD | sed 's|.*/workload/\([^/]*\)$|\1|')

# Generate the seeds list according to the number of replicas provided and maximum value of 3
SEEDS=""
for i in $(seq 0 $((NUM_SEEDS - 1))); do
  SEED="$WORKLOAD_NAME-$i.$WORKLOAD_NAME.$CPLN_GVC_ALIAS.svc.cluster.local:33145"
  if [ -z "$SEEDS" ]; then
    SEEDS="$SEED"
  else
    SEEDS="$SEEDS,$SEED"
  fi
done

CUSTOM_CONFIGURATIONS=${CUSTOM_CONFIGURATIONS:-""}

rpk redpanda start --kafka-addr internal://0.0.0.0:$CUSTOM_RPK_PORT \
    --advertise-kafka-addr internal://$WORKLOAD_NAME-$PET_ORDINAL.$WORKLOAD_NAME.$CPLN_GVC_ALIAS.svc.cluster.local:$CUSTOM_RPK_PORT \
    --pandaproxy-addr internal://0.0.0.0:8082 \
    --advertise-pandaproxy-addr internal://$WORKLOAD_NAME-$PET_ORDINAL.$WORKLOAD_NAME.$CPLN_GVC_ALIAS.svc.cluster.local:8082 \
    --schema-registry-addr internal://0.0.0.0:8081 \
    --rpc-addr "0.0.0.0:33145" \
    --advertise-rpc-addr $WORKLOAD_NAME-$PET_ORDINAL.$WORKLOAD_NAME.$CPLN_GVC_ALIAS.svc.cluster.local:33145 \
    --smp 1 --default-log-level=$CUSTOM_RPK_LOGLVL \
    --set redpanda.empty_seed_starts_cluster=false \
    --seeds $SEEDS \
    $CUSTOM_CONFIGURATIONS