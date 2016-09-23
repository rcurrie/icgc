#!/bin/bash
domains="China  France  Germany  South_Korea  United_Kingdom  United_States"
for domain in $domains; do
    echo $domain
    docker exec demo_$domain python /populate.py
done
