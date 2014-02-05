import os
import boto
import logging
from boto.s3 import key

import upload
import version

def main():
    logging.basicConfig(level=logging.INFO)
    c = boto.connect_s3()
    b = c.get_bucket('files.projecthawkthorne.com', validate=False)

    path = os.path.join('releases', 'v' + version.current_version())

    upload.upload_path(b, path, 'notes.html')


if __name__ == "__main__":
    main()
