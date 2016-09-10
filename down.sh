#!/bin/sh
echo "Stopping and removing all demo_ containers"
docker ps -a | grep 'demo_' | awk '{print $1}' | xargs docker stop || true
docker ps -a | grep 'demo_' | awk '{print $1}' | xargs docker rm || true
