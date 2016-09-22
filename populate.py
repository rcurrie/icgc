#!/usr/bin/env python
"""
Populate a cgtd server with data extracted from icgc
"""
import os
import json
import requests

submitted = []
for name in [f for f in os.listdir("/data") if f.endswith(".json")][0:2]:
    print("Submitting {}".format(name.rstrip(".json")))

    with open("/data/{}".format(name)) as f:
        r = requests.post("{}/v0/submissions?publish=false".format("http://localhost:5000"),
                          files=[
                              ("files[]",
                               ("{}.tsv".format(name.rstrip(".json")),
                                open("/data/{}.tsv".format(name.rstrip(".json")), "rb")))],
                          data=json.loads(f.read()))
        assert(r.status_code == requests.codes.ok)
        submitted.append(json.loads(r.text)["multihash"])

print("Publishing submissions...")
r = requests.put("{}/v0/submissions".format("http://localhost:5000"),
                 json={"submissions": submitted})
assert(r.status_code == requests.codes.ok)
print("Done.")
