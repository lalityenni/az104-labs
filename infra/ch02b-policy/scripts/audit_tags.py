import csv
import os
from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient

# ---- Input parameters ----
subscription_id = os.environ.get("AZ_SUBSCRIPTION_ID") or "1234-5678"   # required
tag_name = "Environment"  # required
resource_group = None     # optional, e.g., "az104-rg2"
out_csv = "./missing-tag.csv"

# ---- Authenticate ----
credential = DefaultAzureCredential()
client = ResourceManagementClient(credential, subscription_id)

# ---- Get resources ----
if resource_group:
    resources = client.resources.list_by_resource_group(resource_group)
else:
    resources = client.resources.list()

# ---- Check tags ----
missing = []
for r in resources:
    tags = r.tags or {}   # tags come as a dict or None
    if tag_name not in tags:
        missing.append({
            "Name": r.name,
            "ResourceGroup": r.id.split("/")[4],  # extract RG from resource ID
            "ResourceType": r.type,
            "Location": r.location
        })

# ---- Print and export ----
print(f"{len(missing)} resources missing tag '{tag_name}'")

with open(out_csv, "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["Name", "ResourceGroup", "ResourceType", "Location"])
    writer.writeheader()
    writer.writerows(missing)

print(f"List exported to: {os.path.abspath(out_csv)}")