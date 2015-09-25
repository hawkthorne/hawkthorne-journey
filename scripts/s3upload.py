import argparse
import os
import boto

conn = boto.connect_s3()

parser = argparse.ArgumentParser(description="Upload files to S3")
parser.add_argument("path", help="File to upload")
parser.add_argument("version", help="Version to upload")
args = parser.parse_args()
name = os.path.basename(args.path)

bucket = conn.get_bucket('hawkthorne.journey.builds', validate=False)
key = bucket.new_key(os.path.join(args.version, name))

key.set_contents_from_filename(os.path.abspath(args.path))




