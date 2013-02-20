import os
import argparse
import boto
from boto.s3 import key

parser = argparse.ArgumentParser(description="Upload files to S3")
parser.add_argument("prefix", help="Prefix for file of upload")
parser.add_argument("path", help="File to upload")

def upload_path(prefix, path):
    name = os.path.basename(path)
    
    c = boto.connect_s3()
    b = c.get_bucket('files.projecthawkthorne.com')
    
    k = key.Key(b)
    k.key = os.path.join(prefix, name)
    k.set_contents_from_filename(path)
    k.set_acl('public-read')


if __name__ == "__main__":
    args = parser.parse_args()
    upload_path(args.prefix, args.path)
