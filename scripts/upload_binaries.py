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

files = [
    "DevIL.dll",
    "love.dll",
    "lua51.dll",
    "mpg123.dll",
    "msvcp110.dll",
    "msvcr110.dll",
    "OpenAL32.dll",
    "SDL2.dll",
    "hawkthorne.exe",
]


def main():
    logging.basicConfig(level=logging.INFO)
    c = boto.connect_s3()
    b = c.get_bucket('files.projecthawkthorne.com')

    branch = os.environ.get('TRAVIS_BRANCH', '')

    v = 'v' + version.next_version()

    if branch == 'master':
        path = os.path.join('releases', 'tip')
    else:
        path = os.path.join('releases', 'v' + version.next_version())

    for item in releases:
        upload.upload_path(b, path, os.path.join('build', item))

    if branch != 'release':
        logging.info('[DRYRUN] Upload windows files')
        logging.info('[DRYRUN] Create release symlinks')
        return

    for f in files:
        wpath = os.path.join(path, "win")
        upload.upload_path(b, wpath, os.path.join('win32', f))

    for item in releases:
        k = b.get_key("releases/latest/{}".format(item))
        k.set_redirect("/releases/{}/{}".format(v, item))
        k.set_acl('public-read')


if __name__ == "__main__":
    main()

