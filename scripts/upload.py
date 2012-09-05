import os
import json
import argparse
import requests
from collections import OrderedDict

downloads_url = "https://api.github.com/repos/{user}/{repo}/downloads".format(
    user="kyleconroy", repo="hawkthorne-journey")

auth = ("kyleconroy", os.environ['GITHUB_PASSWORD'])

parser = argparse.ArgumentParser(description="Upload files to Github")
parser.add_argument("path", help="File to upload")
args = parser.parse_args()

name = os.path.basename(args.path)

downloads = json.loads(requests.get(downloads_url).text)
download = [d for d in downloads if d['name'] == name]

if download:

    with open('stats.json', 'r') as f:
        # Track download stats since I will be deleting downloads often
        stats = json.load(f)
        stats[name] = download[0]['download_count'] + stats.get(name, 0)
        json.dump(stats, open('stats.json', 'w'), indent=4)

    requests.delete(download[0]['url'], auth=auth).raise_for_status()


upload_info = {
    'name': name,
    'size': os.path.getsize(args.path),
    }

resp = requests.post(downloads_url, data=json.dumps(upload_info), auth=auth)
resp.raise_for_status()

s3 = json.loads(resp.text)

files = {'file' : open(args.path, 'rb')}

s3_info = OrderedDict([
    ('key', s3['path']),
    ('acl', s3['acl']),
    ('success_action_status', 201),
    ('Filename', s3['name']),
    ('AWSAccessKeyId', s3['accesskeyid']),
    ('Policy', s3['policy']),
    ('Signature', s3['signature']),
    ('Content-Type', s3['mime_type']),
])

resp = requests.post(s3['s3_url'], data=s3_info, files=files)
resp.raise_for_status()

print resp.text
