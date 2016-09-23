#!/bin/bash
domains="China  France  Germany  South_Korea  United_Kingdom  United_States"
for domain in $domains; do
    echo "Adding $domain as peer"
    address=`docker exec -it demo_$domain curl localhost:5000/v0/address | jq -r '.address'`
    docker exec -it cgtd curl -X POST localhost:5000/v0/peers/$address
done
