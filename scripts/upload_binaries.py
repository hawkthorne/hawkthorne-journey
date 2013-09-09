import os
import boto
import logging
from boto.s3 import key

import upload
import version

releases = [
    'hawkthorne-win-x86.zip',
    'hawkthorne-osx.zip',
    'hawkthorne.love',
]


def main():
    logging.basicConfig(level=logging.INFO)
    c = boto.connect_s3()
    b = c.get_bucket('files.projecthawkthorne.com')

    path = os.path.join('releases', 'v' + version.next_version())

    for item in releases:
        upload.upload_path(b, path, os.path.join('build', item))

    if 'TRAVIS' not in os.environ:
        logging.info('[DRYRUN] Create release symlinks')
        return

    for item in releases:
        k = b.get_key("releases/latest/{}".format(release))
        k.set_redirect("/releases/{}/{}".format(args.version, release))
        k.set_acl('public-read')


if __name__ == "__main__":
    main()

