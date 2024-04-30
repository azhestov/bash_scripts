#!/bin/bash

# extract container details
extract_container_details() {
    container_info=$(docker inspect "$1" 2>/dev/null)

    # container exists?
    if [ $? -ne 0 ]; then
        echo "Container '$1' not found"
        exit 1
    fi

    # name, short ID, and IP
    container_name=$(echo "$container_info" | jq -r '.[0].Name' | cut -d'/' -f2)
    container_id=$(echo "$container_info" | jq -r '.[0].Id')
    short_container_id=${container_id:0:12} # Get the short container ID
    container_ip=$(echo "$container_info" | jq -r '.[0].NetworkSettings.Networks | to_entries[0].value.IPAddress // empty')

    if [ -z "$container_ip" ]; then
        echo "Container '$container_name' has no IP address assigned"
        exit 1
    fi
}

# formatted result
format_output() {
    container_name="$1"
    short_container_id="$2"
    container_ip="$3"
    awk -v name="$container_name" -v id="$short_container_id" -v ip="$container_ip" 'BEGIN {printf "%-20s\t%-20s\t%-20s\n", name, id, ip}'
}

# list of containers
all_containers=$(docker ps -a --format "{{.Names}}")

# argument is provided?
if [ -n "$1" ]; then
    # Extract container details
    extract_container_details "$1"

    # single container
    format_output "$container_name" "$short_container_id" "$container_ip"
else
    # full list
    if [ -z "$all_containers" ]; then
        echo "No containers found"
    else
        printf "%-20s\t%-20s\t%-20s\n" "NAME" "ID" "IP"
        while read -r container_name; do
            extract_container_details "$container_name"
            format_output "$container_name" "$short_container_id" "$container_ip"
        done <<< "$all_containers"
    fi
fi
