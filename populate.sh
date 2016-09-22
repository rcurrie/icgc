#!/bin/bash
domains="Australia  Brazil  European Union  France  United_Kingdom  United_States"
for domain in $domains; do
    echo $domain
    docker exec demo_$domain python /populate.py
done
