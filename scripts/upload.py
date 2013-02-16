import os
import argparse
import boto
from boto.s3 import key

parser = argparse.ArgumentParser(description="Upload files to Github")
parser.add_argument("version", help="Version of upload")
parser.add_argument("path", help="File to upload")
args = parser.parse_args()

name = os.path.basename(args.path)

c = boto.connect_s3()
b = c.get_bucket('files.projecthawkthorne.com')

k = key.Key(b)
k.key = os.path.join("releases", args.version, name)
k.set_contents_from_filename(args.path)
k.set_acl('public-read')
