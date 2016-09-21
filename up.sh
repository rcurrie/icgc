#!/bin/bash
# Start a set of demo cgtd and associated ipfs containers, one per $domain
# ipfs data is stored in ./ipfs/$domain so that it is persistent
# between running of this script. If you want to start completely fresh
# delete ./ipfs/*

domains="ucsf.edu ucdavis.edu nki.nl unimelb.edu.au singhealth.com.sg"
# domains="ucsf.edu"

for domain in $domains; do
    echo "Launching $domain ipfs server stored in ./data/$domain"
    mkdir -p `pwd`/data/$domain
    docker run -d --name demo_ipfs_$domain -v `pwd`/data/$domain:/data/ipfs ipfs/go-ipfs:v0.4.3-rc4
done

echo "Waiting until ipfs servers are up..."
sleep 5

for domain in $domains; do
    echo "Launching and initializing $domain cgtd server"
    # Initialize its index. Can't check to see if its already without an ipns timeout wait
    docker exec demo_ipfs_$domain sh -c "echo '{\"domain\": \"$domain\", \"submissions\": [], \"peers\": []}' | ipfs add -q | xargs ipfs name publish"
    docker run -d --name demo_$domain --link demo_ipfs_$domain:ipfs robcurrie/cgtd:latest
done

for domain in $domains; do
    docker exec demo_$domain python tests/populate.py
done
