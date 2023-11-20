#!/bin/bash


set -x


subscribe() {
    local this="$1"
    local nodes="$2"
    local count=0

    for on in $nodes; do
        count=$((count + 1))
        on_short="n$count"
        on_hostname="${on%%:*}"
        on_port="${on##*:}"
        if [[ "$this" == "$on_short" ]]; then
            continue
        else
            while true; do
                #nodectl spock sub-create SUBSCRIPTION_NAME PROVIDER_DSN DB
                ./nodectl spock sub-create sub_${this}${on_short} "host=${on_hostname} port=${on_port} user=pgedge dbname=${POSTGRES_DB}" "${POSTGRES_DB}" && break
                sleep 10s
            done
            ./nodectl spock sub-add-repset sub_${this}${on_short} $SET_NAME demo
        fi
    done
}


if [ "`id -u`" = "0" ]; then
    echo "****** Phase 1 running as root"

    export WORKLOAD_NAME=$(echo $CPLN_WORKLOAD | sed 's|.*/workload/\([^/]*\)$|\1|')
    export HOSTNAME="${WORKLOAD_NAME}.${CPLN_GVC}.cpln.local"

    # mkdir -p /opt/pgedge
    chown -R pgedge /opt/pgedge

    cat <<EOF > /home/pgedge/pgedge.env
HOSTNAME=$HOSTNAME

CLUSTER_NODES="$CLUSTER_NODES"

POSTGRES_DB=$POSTGRES_DB

POSTGRES_PASSWORD=$POSTGRES_PASSWORD

EOF

    # and then rerun this script as pgedge
    su pgedge - $0
    exit
fi


#------ from here down we are user pgedge....


echo "****** Phase 2 running as pgedge"


source /home/pgedge/pgedge.env


cd /opt/pgedge/


if [ ! -d /opt/pgedge/pgedge/nodectl ]; then
    python3 -c "$(curl -fsSL https://pgedge-download.s3.amazonaws.com/REPO/install.py)"
fi


cd /opt/pgedge/pgedge


NODE_COUNT=0


for NODE in $CLUSTER_NODES; do
    NODE_COUNT=$((NODE_COUNT + 1))
    NODE_SHORT="n$NODE_COUNT"
    NODE_HOSTNAME="${NODE%%:*}"
    NODE_PORT="${NODE##*:}"

    if [ "$NODE_HOSTNAME" == "$HOSTNAME" ]; then
    echo "This host ($HOSTNAME) is part of the cluster."
    # sed -i 's/export PGPORT=5432/export PGPORT=$NODE_PORT/' pg16/pg16.env
    # source pg16/pg16.env
    SET_NAME="cpln_default"
    output=$(./nodectl status pgedge)
    pg_ctl_path="/opt/pgedge/pgedge/pg16/bin/pg_ctl"

    if ([ "$output" == "pgedge installed" ] || [ "$output" == "pgedge stopped" ]) && [ -f "$pg_ctl_path" ]; then
        # Restore the password
        cp /opt/pgedge/pgedge/pg16/.pgpass ~pgedge/.pgpass
        ./nodectl start pg16
        ./nodectl spock node-create $NODE_SHORT "host=$HOSTNAME port=$NODE_PORT user=pgedge dbname=$POSTGRES_DB" "${POSTGRES_DB}" || true
        ./nodectl spock repset-create "${SET_NAME}" "${POSTGRES_DB}" || true
        subscribe "$NODE_SHORT" "$CLUSTER_NODES" &
    else
        ./nodectl install pgedge -U $POSTGRES_DB -P $POSTGRES_PASSWORD -d $POSTGRES_DB -p $NODE_PORT
        # backup the pass file
        cp ~pgedge/.pgpass /opt/pgedge/pgedge/pg16/.pgpass
        ./nodectl spock node-create $NODE_SHORT "host=$HOSTNAME port=$NODE_PORT user=pgedge dbname=$POSTGRES_DB" "${POSTGRES_DB}" || true
        ./nodectl spock repset-create "${SET_NAME}" "${POSTGRES_DB}" || true
        subscribe "$NODE_SHORT" "$CLUSTER_NODES" &
    fi
    break
    fi
done


wait


/opt/pgedge/pgedge/pg16/bin/psql $POSTGRES_DB -c "SELECT * FROM spock.node;"
-p $NODE_PORT

/opt/pgedge/pgedge/pg16/bin/psql $POSTGRES_DB -p $NODE_PORT -f
/scripts/replication.sql

sleep 99999d