SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for bEnv in  $(env | awk -F "=" '/^CPLN_MSK_BROKER/ {print $2}')
do
  brokerUrl=$(awk '{print $1}' <<< $bEnv)
  internalBrokerUrl=$(echo "$brokerUrl" | awk -F "." '{out=$1"-internal"; for(i=2;i<=NF;i++){out=out"."$i}; print out}')
  brokerNumber=$(awk '{print $2}' <<< $bEnv)
  port=$((9000 + $brokerNumber))
  /opt/kafka/bin/kafka-configs.sh \
    --bootstrap-server "$brokerUrl:9094" \
    --entity-type brokers \
    --entity-name "$brokerNumber" \
    --alter \
    --command-config opt/client.properties \
    --add-config "advertised.listeners=[CLIENT_SECURE://$brokerUrl:$port, REPLICATION://$internalBrokerUrl:9093, REPLICATION_SECURE://$internalBrokerUrl:9095]"
done
IFS=$SAVEIFS