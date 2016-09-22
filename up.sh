#!/bin/bash
# Start a set of demo cgtd and associated ipfs containers, one per $domain
# ipfs data is stored in ./ipfs/$domain so that it is persistent
# between running of this script. If you want to start completely fresh
# delete ./ipfs/*

domains="Australia  Brazil  European Union  France  United_Kingdom  United_States"
# domains="Australia  Brazil"

for domain in $domains; do
    echo "Launching and initializing $domain ipfs server"
    mkdir -p /data/ipfs/$domain
    docker run -d --name demo_ipfs_$domain -v /data/ipfs/$domain:/data/ipfs ipfs/go-ipfs:v0.4.3-rc4
done

echo "Waiting until ipfs servers are up..."
sleep 10

for domain in $domains; do
    echo "Launching and initializing $domain cgtd server"
    # Initialize its index. Can't check to see if its already without an ipns timeout wait
    docker exec demo_ipfs_$domain sh -c "echo '{\"domain\": \"$domain\", \"submissions\": [], \"peers\": []}' | ipfs add -q | xargs ipfs name publish"
    docker run -d --name demo_$domain --link demo_ipfs_$domain:ipfs \
        -v /data/icgc_extracted/$domain:/data \
        -v `pwd`/populate.py:/populate.py robcurrie/cgtd:latest
done

for domain in $domains; do
    docker exec demo_$domain python /populate.py
done
