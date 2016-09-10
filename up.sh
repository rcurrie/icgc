#!/bin/bash
# Start a set of demo cgtd and associated ipfs containers, one per $domain
# ipfs data is stored in ./ipfs/$domain so that it is persistent
# between running of this script. If you want to start completely fresh
# delete ./ipfs/*

# domains="cgt.ucsf.edu cgt.ucdavis.edu cgt.mskcc.org cgt.nki.nl cgt.unimelb.edu.au cgt.singhealth.com.sg"
domains="cgt.ucsf.edu"

source "${BASH_SOURCE%/*}/down.sh"

# Get the latest containers
docker pull ipfs/go-ipfs:release
docker pull robcurrie/cgtd:latest

for domain in $domains; do
    echo "Launching $domain ipfs server stored in ./ipfs/$domain"
    mkdir -p `pwd`/ipfs/$domain
    # Initialize the ipfs datastore
	docker run -it --rm --name demo_ipfs_$domain -v `pwd`/ipfs/$domain:/data/ipfs --entrypoint=ipfs \
        ipfs/go-ipfs:release init
    # By default ipfs only listens on 127.0.0.1, make it listen to lined cgtd
	docker run -it --rm --name demo_ipfs_$domain -v `pwd`/ipfs/$domain:/data/ipfs --entrypoint=ipfs \
		ipfs/go-ipfs:release config Addresses.API /ip4/0.0.0.0/tcp/5001
	docker run -it --rm --name demo_ipfs_$domain -v `pwd`/ipfs/$domain:/data/ipfs --entrypoint=ipfs \
		ipfs/go-ipfs:release config Addresses.Gateway /ip4/0.0.0.0/tcp/8080
    # REMIND: What about incoming swarm ports?
    docker run -d --name demo_ipfs_$domain -v `pwd`/ipfs/$domain:/data/ipfs ipfs/go-ipfs:release
done

echo "Waiting until ipfs servers are up..."
sleep 5

for domain in $domains; do
    echo "Launching and initializing $domain cgtd server"
    # Initialize its index. Can't check to see if its already without an ipns timeout wait
    docker exec demo_ipfs_$domain sh -c "echo '{\"domain\": \"$domain\", \"submissions\": [], \"peers\": []}' | ipfs add -q | xargs ipfs name publish"
    docker run -d --name demo_$domain --link demo_ipfs_$domain:ipfs robcurrie/cgtd:latest
done

# for domain in $domains; do
#     docker exec icgc_$domain python tests/demo_data.py
# done
