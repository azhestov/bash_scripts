#!/bin/bash
# List name, id and IP of docker contaners. Show same for single container if id or name passed as parameter to script
# Function to output the result in the specified format
format_output() {
    container_name="$1"
    short_container_id="$2"
    container_ip="$3"
    awk -v name="$container_name" -v id="$short_container_id" -v ip="$container_ip" 'BEGIN {printf "%-20s\t%-20s\t%-20s\n", name, id, ip}'
}

# Get a list of all containers
all_containers=$(docker ps -a --format "{{.Names}}")

# If an argument (container name or ID) is provided
if [ -n "$1" ]; then
    # Get container information using docker inspect
    container_info=$(docker inspect "$1" 2>/dev/null)

    # Check if the container exists
    if [ $? -ne 0 ]; then
        echo "Container '$1' not found"
        exit 1
    fi

    # Extract container name, short ID, and IP address using jq
    container_name=$(echo "$container_info" | jq -r '.[0].Name' | cut -d'/' -f2)
    container_id=$(echo "$container_info" | jq -r '.[0].Id')
    short_container_id=${container_id:0:12} # Get the short container ID
    container_ip=$(echo "$container_info" | jq -r '.[0].NetworkSettings.Networks | to_entries[0].value.IPAddress // empty')

    # If IP address is not found, print an error message
    if [ -z "$container_ip" ]; then
        echo "Container '$container_name' has no IP address assigned"
        exit 1
    fi

    # Output the result in the specified format
    format_output "$container_name" "$short_container_id" "$container_ip"
else
    # If no argument is provided, output information for all containers
    if [ -z "$all_containers" ]; then
        echo "No containers found"
    else
        printf "%-20s\t%-20s\t%-20s\n" "NAME" "ID" "IP"
        while read -r container_name; do
            container_info=$(docker inspect "$container_name" 2>/dev/null)
            container_id=$(echo "$container_info" | jq -r '.[0].Id')
            short_container_id=${container_id:0:12}
            container_ip=$(echo "$container_info" | jq -r '.[0].NetworkSettings.Networks | to_entries[0].value.IPAddress // empty')
            format_output "$container_name" "$short_container_id" "$container_ip"
        done <<< "$all_containers"
    fi
fi
