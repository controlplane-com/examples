#!/bin/sh

set -x

if [ -z "$CUSTOM_RPK_REPLICAS" ]; then
  echo "CUSTOM_RPK_REPLICAS is not set"
  exit 1
fi

CONSOLE_CONFIG_FILE="
kafka:
    brokers: ["
i=0
while [ $i -lt "$CUSTOM_RPK_REPLICAS" ]; do
  CONSOLE_CONFIG_FILE="$CONSOLE_CONFIG_FILE\"${CUSTOM_RPK_WORKLOAD_NAME}-${i}.${CUSTOM_RPK_WORKLOAD_NAME}.${CPLN_GVC_ALIAS}.svc.cluster.local:${CUSTOM_RPK_PORT}\""
  if [ $i -lt $(($CUSTOM_RPK_REPLICAS-1)) ]; then
    CONSOLE_CONFIG_FILE="$CONSOLE_CONFIG_FILE,"
  fi
  i=$(($i + 1))
done
CONSOLE_CONFIG_FILE="$CONSOLE_CONFIG_FILE]
    schemaRegistry:
        enabled: true
        urls: ["
i=0
while [ $i -lt "$CUSTOM_RPK_REPLICAS" ]; do
  CONSOLE_CONFIG_FILE="$CONSOLE_CONFIG_FILE\"http://${CUSTOM_RPK_WORKLOAD_NAME}-${i}.${CUSTOM_RPK_WORKLOAD_NAME}.${CPLN_GVC_ALIAS}.svc.cluster.local:8081\""
  if [ $i -lt $(($CUSTOM_RPK_REPLICAS-1)) ]; then
    CONSOLE_CONFIG_FILE="$CONSOLE_CONFIG_FILE,"
  fi
  i=$(($i + 1))
done
CONSOLE_CONFIG_FILE="$CONSOLE_CONFIG_FILE]
redpanda:
    adminApi:
        enabled: true
        urls: ["
i=0
while [ $i -lt "$CUSTOM_RPK_REPLICAS" ]; do
  CONSOLE_CONFIG_FILE="$CONSOLE_CONFIG_FILE\"http://${CUSTOM_RPK_WORKLOAD_NAME}-${i}.${CUSTOM_RPK_WORKLOAD_NAME}.${CPLN_GVC_ALIAS}.svc.cluster.local:9644\""
  if [ $i -lt $(($CUSTOM_RPK_REPLICAS-1)) ]; then
    CONSOLE_CONFIG_FILE="$CONSOLE_CONFIG_FILE,"
  fi
  i=$(($i + 1))
done
CONSOLE_CONFIG_FILE="$CONSOLE_CONFIG_FILE]"

echo "$CONSOLE_CONFIG_FILE" > "$CONFIG_FILEPATH"

# Execute the console application
/app/console
