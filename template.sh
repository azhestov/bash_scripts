#!/bin/bash
# check is a number
is_number() {
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    return 0 
  else
    return 1 
  fi
}

# check is a string
is_string() {
  if [[ "$1" =~ ^[a-zA-Z]+$ ]]; then
    return 0 
  else
    return 1 
  fi
}

# example of usage
display_usage() {
  echo "Usage: $0 <number> <string>"
}

# parameters count (2 default)
if [ "$#" -ne 2 ]; then
  display_usage
  exit 1
fi

# first is number
if ! is_number "$1"; then
  echo "Error: The first parameter is not a number."
  display_usage
  exit 1
fi

# second is string
if ! is_string "$2"; then
  echo "Error: The second parameter is not a string."
  display_usage
  exit 1
fi

# main
echo "$1 $2"
exit 0
