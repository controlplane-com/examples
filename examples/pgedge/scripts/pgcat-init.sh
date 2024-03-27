#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

cp /etc/pgcat/pgcat.toml-template /etc/pgcat/pgcat.toml

# Set env
export PGCAT_LOCATION=$(echo ${CPLN_LOCATION##*/})
export PGCAT_CONFIG_FILE=/etc/pgcat/pgcat.toml

# Function to replace placeholder in pgcat.toml
replace_placeholder() {
    local placeholder="${1:?missing placeholder value}"
    local value="${2:?missing value}"
    sed -i "s/$placeholder/$value/g" "$PGCAT_CONFIG_FILE"
}

# Function to extract the domain and port from the server variable
extract_domain_and_port() {
  local server_var=$1
  local server_value=${!server_var}
  domain=$(echo $server_value | cut -d':' -f1)
  port=$(echo $server_value | cut -d':' -f2)
  echo "Match found for location $PGCAT_LOCATION:"
  echo "Domain: $domain"
  echo "Port: $port"

  replace_placeholder "___pgedge_server___" $domain
  replace_placeholder "___pgedge_port___" $port
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
  pgcat /etc/pgcat/pgcat.toml
else
  echo "No matching PGEDGE location found for $PGCAT_LOCATION"
  exit 1
fi
