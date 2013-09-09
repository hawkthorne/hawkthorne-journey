import os
import argparse
import boto
from boto.s3 import key

parser = argparse.ArgumentParser(description="Upload files to Github")
parser.add_argument("version", help="Version of upload")
args = parser.parse_args()

c = boto.connect_s3()
b = c.get_bucket('files.projecthawkthorne.com')

releases = [
    'hawkthorne-win-x86.zip',
    'hawkthorne-osx.zip',
    'hawkthorne.love',
]

for release in releases:
    k = b.get_key("releases/latest/{}".format(release))
    k.set_redirect("/releases/{}/{}".format(args.version, release))
    k.set_acl('public-read')
