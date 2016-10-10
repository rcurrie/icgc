#!/bin/bash
# Start a set of demo cgtd and associated ipfs containers, one per $domain
# ipfs data is stored in ./ipfs/$domain so that it is persistent
# between running of this script. If you want to start completely fresh
# delete ./ipfs/*

domains="aacr.org nki.nl dana-farber.org gustaveroussy.fr hopkinsmedicine.org mskcc.org uhn.ca mdanderson.org vicc.org"
# domains="aacr.org nki.nl dana-farber.org"

for domain in $domains; do
    echo "Launching and initializing $domain ipfs server"
    mkdir -p /data/ipfs/$domain
    docker run -d --name genie_ipfs_$domain -P ipfs/go-ipfs:v0.4.3
done

echo "Waiting until ipfs servers are up..."
sleep 10

for domain in $domains; do
    echo "Launching and initializing $domain cgtd server"
    # Initialize its index. Can't check to see if its already without an ipns timeout wait
    docker exec genie_ipfs_$domain sh -c "echo '{\"domain\": \"$domain\", \"submissions\": [], \"peers\": []}' | ipfs add -q | xargs ipfs name publish"
    docker run -d --name genie_$domain --link genie_ipfs_$domain:ipfs ga4gh/cgtd:0.1.0
done
