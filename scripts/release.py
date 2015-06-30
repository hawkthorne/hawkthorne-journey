import os
import logging
from collections import namedtuple

import requests
import uritemplate

import version

releases = [
    'hawkthorne-win-x86.zip',
    'hawkthorne-osx.zip',
    'hawkthorne.love',
]

Release = namedtuple('Release', ['id', 'upload_url'])

client = requests.Session()
client.auth = ('token', os.environ['GITHUB_ACCESS_TOKEN'])


def create_release(version, commit, notes):
    url = "https://api.github.com/repos/hawkthorne/hawkthorne-journey/releases"
    body = {
        "tag_name": "v{}".format(version),
        "target_commitish": commit,
        "name": "Version {}".format(version),
        "body": notes,
    }
    resp = client.post(url, json=body)
    resp.raise_for_status()

    blob = resp.json()
    release = Release(blob['id'], blob['upload_url'])

    logging.info('Created new release release={} version={}'.format(
                 release.id, version))

    return release


def upload_asset(release, name, path):
    url = uritemplate.expand(release.upload_url, name=name)

    with open(path, 'rb') as f:
        resp = client.post(url,
                           headers={'Content-Type': 'application/zip'},
                           data=f.read())
        resp.raise_for_status()

    logging.info('Uploaded asset release={} name={}'.format(release.id, name))


def main():
    logging.basicConfig(level=logging.INFO)

    branch = os.environ.get('TRAVIS_BRANCH', '')
    commit = os.environ.get('TRAVIS_COMMIT', '')

    if branch != 'release':
        return

    if commit == '':
        return

    v = version.next_version()

    with open('post.md') as f:
        release = create_release(v, commit, f.read())

    for item in releases:
        upload_asset(release, item, os.path.join('build', item))


if __name__ == "__main__":
    main()
