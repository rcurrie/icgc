import os
import json
import requests
import pandas as pd

projects = requests.get("https://dcc.icgc.org/api/v1/projects?size=1000").json()["hits"]
print("Found {} total ICGC projects".format(len(projects)))

projects_with_ssm = [p for p in projects
                     if "availableDataTypes" in p and
                     "ssm" in p["availableDataTypes"] and
                     p["ssmTestedDonorCount"] < 100]
print("Found {} with ssm".format(len(projects_with_ssm)))

data_types = ["donor", "simple_somatic_mutation.open"]
files = [{"name": "{1}.{0}.tsv.gz".format(p["id"], d),
          "url": "https://dcc.icgc.org/api/v1/download?fn=/release_22/Projects"
                 "/{0}/{1}.{0}.tsv.gz".format(p["id"], d)}
         for p in projects_with_ssm for d in data_types]
files_to_download = [f for f in files if not os.path.isfile("/data/icgc/{}".format(f["name"]))]
print("Files to download", len(files_to_download))


for project in projects_with_ssm:
    size = os.path.getsize("/data/icgc/"
                           "simple_somatic_mutation.open.{}.tsv.gz".format(project["id"]))
    if size > 5000000:
        print("{} too big: {}, skipping".format(project["id"], size))
        continue

    directory = "/data/icgc_extracted/{}".format(project["primaryCountries"][0].replace(" ", "_"))
    print("Extracting project {} into {}".format(project["id"], directory))
    if not os.path.exists(directory):
        os.makedirs(directory)

    donors = pd.read_table("/data/icgc/donor.{}.tsv.gz".format(project["id"]))
    variants = pd.read_table(
        "/data/icgc/simple_somatic_mutation.open.{}.tsv.gz".format(project["id"]))
    submissions = variants.groupby(["icgc_donor_id", "icgc_sample_id"])

    print("Creating {} submissions".format(len(submissions)))

    for donor_sample, variants in submissions:
        with open("{}/{}_{}.json".format(directory,
                                         donor_sample[0], donor_sample[1]), "w+") as fields:
            fields.write(json.dumps(
                donors[donors["icgc_donor_id"] == donor_sample[0]].to_dict(orient='records')[0]))
        variants.to_csv("{}/{}_{}.tsv.gz".format(directory, donor_sample[0], donor_sample[1]),
                        sep='\t', compression='gzip')
