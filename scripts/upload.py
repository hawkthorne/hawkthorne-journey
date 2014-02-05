import os
import argparse
import boto
import logging
from boto.s3 import key

parser = argparse.ArgumentParser(description="Upload files to S3")
parser.add_argument("prefix", help="Prefix for file of upload")
parser.add_argument("path", help="File to upload")


def upload_path(b, prefix, path):
    if 'TRAVIS' not in os.environ:
        logging.info('[DRYRUN] uploading {} to {}'.format(path, prefix))
        return

    name = os.path.basename(path)
    k = key.Key(b)
    k.key = os.path.join(prefix, name)

    logging.info('Uploading {} to {}'.format(path, prefix))
    k.set_contents_from_filename(path)
    k.set_acl('public-read')


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    args = parser.parse_args()

    c = boto.connect_s3()
    b = c.get_bucket('files.projecthawkthorne.com', validate=False)
    upload_path(b, args.prefix, args.path)
