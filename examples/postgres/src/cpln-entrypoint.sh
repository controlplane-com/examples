#!/usr/bin/env bash

source /usr/local/bin/docker-entrypoint.sh

restore_db() {
	while [ ! -S /var/run/postgresql/.s.PGSQL.5432 ]
	do
    echo "Waiting 5s for db socket to be available"
    sleep 5s
  done

	if [ ! -f "$PGDATA/CPLN_RESTORED" ]; then
	  echo "It appears db '$1' does not exist. Attempting to restore it from $2"
	  aws s3 cp "$2" - | pg_restore --clean --no-acl --no-owner -d "$1" -U "$POSTGRES_USER"
	  echo "$(date): $2" | cat >> "$PGDATA/CPLN_RESTORED"
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


