#!/bin/bash
docker ps --filter status=dead --filter status=exited -aq | xargs -r docker rm -v
    
docker images --no-trunc | grep '<none>' | awk '{ print $3 }' | xargs -r docker rmi

find '/var/lib/docker/volumes/' -mindepth 1 -maxdepth 1 -type d | grep -vFf <(
  docker ps -aq | xargs docker inspect | jq -r '.[] | .Mounts | .[] | .Name | select(.)'
) | xargs -r rm -fr

docker rmi $(docker images -aq --filter dangling=true)

#docker system prune -a -f
