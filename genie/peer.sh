#!/bin/bash
# Connect to all the genie sites from aacr.org
domains="nki.nl dana-farber.org gustaveroussy.fr hopkinsmedicine.org mskcc.org uhn.ca mdanderson.org vicc.org"
# domains="nki.nl dana-farber.org"

for domain in $domains; do
    echo "Adding $domain as peer"
    address=`docker exec -it genie_$domain curl localhost:5000/v0/address | jq -r '.address'`
    docker exec -it genie_aacr.org curl -X POST localhost:5000/v0/peers/$address
done
