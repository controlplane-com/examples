#!/usr/bin/env bash

source /usr/local/bin/docker-entrypoint.sh

install_deps() {
  apt-get update -y > /dev/null
  apt-get install curl -y > /dev/null
  apt-get install unzip -y > /dev/null
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" > /dev/null
  unzip awscliv2.zip > /dev/null
  ./aws/install > /dev/null
}

db_has_been_restored() {
  if [ ! -f "$PGDATA/CPLN_RESTORED" ]; then
    return 1
  fi

  if ! grep -q "\-> $1$" "$PGDATA/CPLN_RESTORED"; then
    return 1
  else
    return 0
  fi
}

restore_db() {
	while [ ! -S /var/run/postgresql/.s.PGSQL.5432 ]
	do
    echo "Waiting 5s for db socket to be available"
    sleep 5s
  done


	if ! db_has_been_restored "$1"; then
	  echo "It appears db '$1' has not yet been restored from S3. Attempting to restore $1 from $2"
	  install_deps
	  docker_setup_db #Ensures $POSTGRES_DB exists (defined in the entrypoint script from the postgres docker image)
	  aws s3 cp "$2" - | pg_restore --clean --no-acl --no-owner -d "$1" -U "$POSTGRES_USER"
	  echo "$(date): $2 -> $1" | cat >> "$PGDATA/CPLN_RESTORED"
	else
	  echo "Db '$1' already exists. Ready!"
  fi
}

_main "$@" &
backgroundProcess=$!

if [ -n "$POSTGRES_ARCHIVE_URI" ]; then
  restore_db "$POSTGRES_DB" "$POSTGRES_ARCHIVE_URI"
else
  echo "Declining to restore the db because no archive uri was provided"
fi

wait $backgroundProcess


