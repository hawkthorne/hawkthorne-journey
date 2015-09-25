import os
import sys
from datetime import datetime
import argparse
import boto
import requests
import jinja2
import json
import time
import subprocess

import version

pulls_url = "https://api.github.com/repos/hawkthorne/hawkthorne-journey/pulls"
compare_url = "https://github.com/hawkthorne/hawkthorne-journey/compare/{}...{}"
GITHUB_TIME = "%Y-%m-%dT%H:%M:%SZ"


def post_content():
    resp = requests.get(pulls_url, params={'state': 'closed', 'base': 'release'})
    pulls = resp.json()

    if not pulls:
        raise ValueError(('No pull request for this release, which means no'
                          'post'))

    template = jinja2.Template(open('templates/post.md').read())
    return template.render(pull=pulls[0], version=version.current_version())


def commithash(version):
    bucket = boto.s3.get_bucket("files.projecthawkthorne.com", validate=False)
    key = bucket.get_key("releases/v{}/hawkthorne-osx.zip".format(version))

    if key is None:
        return key

    return key.get_contents()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('output', type=argparse.FileType('w'))
    args = parser.parse_args()
    args.output.write(post_content())


if __name__ == "__main__":
    main()
