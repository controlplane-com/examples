#!/bin/bash

set -ex

if [ "$(id -u)" = "0" ]; then
    mkdir -p /opt/pgedge
    chown pgedge. /opt/pgedge

    if ! mountpoint /opt/pgedge 2>/dev/null; then
        echo DATA is not a mountpoint, maybe you will lose data
    fi

    su pgedge - "$0"
    exit $?
fi

# user is pgedge from now on

if ! [[ -x /opt/pgedge/pgedge/nodectl ]]; then
    cd /opt/pgedge
    export REPO=https://pgedge-download.s3.amazonaws.com/REPO
    python3 -c "$(curl -fsSL $REPO/install.py)"
fi

if [[ -d /opt/pgedge/pgedge/pg16 ]]; then
    echo already initialized
    # restore the pass file
    cp /opt/pgedge/pgedge/pg16/.pgpass ~pgedge/.pgpass
    nodectl start pg16
else
    # probably first run
    nodectl install pgedge -U "$POSTGRES_DB" -P "$POSTGRES_PASSWORD" -d "$POSTGRES_DB"
    # backup the pass file
    cp ~pgedge/.pgpass /opt/pgedge/pgedge/pg16/.pgpass
fi

#nodectl spock node-create NODE_NAME DSN DB
nodectl spock node-create "$NODE" "host=$NODE user=pgedge dbname=$POSTGRES_DB" "${POSTGRES_DB}" || true

SET_NAME="${POSTGRES_DB}_replication_set"
#nodectl spock repset-create SET_NAME DB
nodectl spock repset-create "${SET_NAME}" "${POSTGRES_DB}" || true

shorten() {
    echo "$1" | md5sum | head -c 16
}

subscribe() {
    local this="$1"
    local other="$2"

    while true; do
        #nodectl spock sub-create SUBSCRIPTION_NAME PROVIDER_DSN DB
        nodectl spock sub-create "$(shorten "${this}-${other}")" "host=${other} port=5432 user=pgedge dbname=${POSTGRES_DB}" "${POSTGRES_DB}" && break
        sleep 10s
    done
    nodectl spock sub-add-repset "$(shorten "${this}-${other}")" $SET_NAME $POSTGRES_DB
}

for on in $OTHER_NODES; do
    if [[ "$NODE" == "$on" ]]; then
        continue
    fi

    subscribe "$NODE" "$on" &
done

wait

# TODO restart pg on error
sleep 99999d
