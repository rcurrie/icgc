#!/usr/bin/env python
import os
import requests
# import requests_cache
# requests_cache.install_cache('/data/icgc_cache')

projects = [p["id"] for p in requests.get("https://dcc.icgc.org/api/v1/projects?size=1000").json()["hits"]]
print("Found {} projects".format(len(projects)))

data_type = ["simple_somatic_mutation.open", "exp_array", "donor"]

files = [{"name": "{1}.{0}.tsv.gz".format(p, d),
          "url": "https://dcc.icgc.org/api/v1/download?fn=/release_22/Projects/{0}/{1}.{0}.tsv.gz".format(p, d)}
         for p in projects for d in data_type]

for f in files:
    if not os.path.isfile("/data/icgc/{}".format(f["name"])):
        print("Downloading {}".format(f["name"]))
        r = requests.get(f["url"], allow_redirects=True, verify=False)
        if r.status_code == requests.codes.ok:
            with open("/data/icgc/{}".format(f["name"]), 'wb+') as tar:
                tar.write(r.content)
        else:
            print("Problems downloading {}: {}".format(f["name"],
                                                       r.status_code))
