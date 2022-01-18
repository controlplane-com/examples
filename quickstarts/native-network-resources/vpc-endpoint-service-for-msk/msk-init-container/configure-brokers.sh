SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for bEnv in  $(env | awk -F "=" '/^CPLN_MSK_BROKER/ {print $2}')
do
  brokerUrl=$(awk '{print $1}' <<< $bEnv)
  brokerNumber=$(awk '{print $2}' <<< $bEnv)
  port=$((9000 + $brokerNumber))
  /opt/kafka/bin/kafka-configs.sh \
    --bootstrap-server "$brokerUrl:9094" \
    --entity-type brokers \
    --entity-name "$brokerNumber" \
    --alter \
    --command-config opt/client.properties \
    --add-config "advertised.listeners=[ CLIENT_SECURE://$brokerUrl:$port, REPLICATION://$brokerUrl:9093, REPLICATION_SECURE://$brokerUrl:9095 ]"
done
IFS=$SAVEIFS