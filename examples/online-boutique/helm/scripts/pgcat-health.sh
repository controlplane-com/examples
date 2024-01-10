#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Set env
export PGCAT_LOCATION=$(echo ${CPLN_LOCATION##*/})

# Function to extract the domain and port from the server variable
extract_domain_and_port() {
  local server_var=$1
  local server_value=${!server_var}
  export pgedge_domain=$(echo $server_value | cut -d':' -f1)
  export pgedge_port=$(echo $server_value | cut -d':' -f2)
}

# Function to check PostgreSQL readiness
check_pg_readiness() {
  if ! pg_isready -U "$POSTGRES_USER" -h "$pgedge_domain" -p "$pgedge_port"; then
    echo "PostgreSQL is not ready at $pgedge_domain:$pgedge_port"
    exit 1
  fi
  echo "PostgreSQL is ready at $pgedge_domain:$pgedge_port"
}

# Loop through all environment variables
matched=false
while IFS='=' read -r name value ; do
  if [[ $name =~ ^PGEDGE_([0-9]+)_LOCATION$ ]]; then
    index=${BASH_REMATCH[1]}
    location_var="PGEDGE_${index}_LOCATION"
    server_var="PGEDGE_${index}_SERVER"
    
    location_value=${!location_var}
    
    # Check if the PGCAT_LOCATION matches this PGEDGE location
    if [ "$PGCAT_LOCATION" == "$location_value" ]; then
      # Call function to extract domain and port
      extract_domain_and_port $server_var
      matched=true
      break
    fi
  fi
done < <(env)

# Call the readiness check if a match was found
if [ "$matched" = true ]; then
  check_pg_readiness
else
  echo "No matching PGEDGE location found for $PGCAT_LOCATION"
  exit 1
fi
