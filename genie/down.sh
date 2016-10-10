#!/bin/sh
echo "Stopping and removing all genie_ containers"
docker ps -a | grep 'genie_' | awk '{print $1}' | xargs docker stop || true
docker ps -a | grep 'genie_' | awk '{print $1}' | xargs docker rm || true
