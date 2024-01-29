#!/bin/bash
# list containers with IP
for i in $(docker ps -q)
do
  echo "$(docker inspect -f '{{.Name}}' $id), $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)"
done
