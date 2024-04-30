#!/bin/bash

# Get the current date
current_date=$(date +%s)

# Get the input threshold
threshold_input=$1

# Check if input parameter is not provided
if [ -z "$threshold_input" ]; then
    echo "Error: Please provide a threshold in the format [number][D/W/M] (e.g. 2D for 2 days, 1W for 1 week, 3M for 3 months)"
    exit 1
fi

# Extract the number and unit of the threshold
threshold_num=${threshold_input::-1}
threshold_unit=${threshold_input: -1}

# Check if input unit is not valid
if [ "$threshold_unit" != "D" ] && [ "$threshold_unit" != "W" ] && [ "$threshold_unit" != "M" ]; then
    echo "Error: Invalid input unit. Please provide a threshold in the format [number][D/W/M] (e.g. 2D for 2 days, 1W for 1 week, 3M for 3 months)"
    exit 1
fi

# Check if input number is not a valid number
if ! [[ "$threshold_num" =~ ^[0-9]+$ ]]; then
    echo "Error: Invalid input number. Please provide a threshold in the format [number][D/W/M] (e.g. 2D for 2 days, 1W for 1 week, 3M for 3 months)"
    exit 1
fi

# Set the threshold in seconds based on the input unit
case $threshold_unit in
    D) threshold=$((threshold_num * 24 * 60 * 60)) ;;
    W) threshold=$((threshold_num * 7 * 24 * 60 * 60)) ;;
    M) threshold=$((threshold_num * 30 * 24 * 60 * 60)) ;;
esac

# Get a list of all dangling images
dangling_images=$(docker images -f "dangling=true" -q)

# Iterate over the list of images
for image in $dangling_images; do
    # Get the creation date of the image
    create_date=$(docker inspect -f '{{ .Created }}' $image)

    # Convert the creation date to a timestamp
    create_timestamp=$(date -d "$create_date" +%s)

    # Calculate the age of the image
    age=$((current_date - create_timestamp))

    # If the age of the image is greater than the threshold, remove it
    if [ $age -gt $threshold ]; then
        docker rmi $image
    fi
done
