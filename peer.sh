#!/bin/bash
domains="ucsf.edu ucdavis.edu nki.nl unimelb.edu.au singhealth.com.sg"
for domain in $domains; do
    echo "Adding $domain as peer"
    address=`docker exec -it demo_$domain curl localhost:5000/v0/address | jq -r '.address'`
    docker exec -it cgtd curl -X POST localhost:5000/v0/peers/$address
done
