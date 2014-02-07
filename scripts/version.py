"""
Bump the version number
"""
import os
import boto
import argparse
import requests
import json

s3 = boto.connect_s3()


def current_version():
    x, y, z = current_version_tuple()
    return "{0}.{1}.{2}".format(x,y,z) 


def next_bugfix_version():
    x, y, z = current_version_tuple()
    return "{0}.{1}.{2}".format(x,y,int(z) + 1) 


def next_minor_version():
    x, y, z = current_version_tuple()
    return "{0}.{1}.0".format(x,int(y)+1) 


def next_version():
    if is_release():
        return next_minor_version()
    else:
        return next_bugfix_version()


def prev_version():
    x, y, z = current_version_tuple()
    return "{0}.{1}.{2}".format(x,y,int(z) - 1) 


def current_version_tuple():
    bucket = s3.get_bucket("files.projecthawkthorne.com", validate=False)
    key = bucket.get_key("releases/latest/hawkthorne-osx.zip")
    redirect = key.get_redirect()
    _, _, version, _ = redirect.split('/')
    return tuple(version.replace('v', '').split('.'))


def is_release():
    pulls_url = "https://api.github.com/repos/hawkthorne/hawkthorne-journey/pulls"
    resp = requests.get(pulls_url, params={'state': 'closed', 'base': 'release'})

    if not resp.ok:
        return False

    pulls = resp.json()

    if len(pulls) == 0:
        return False

    return 'release' in pulls[0].get('title', '').lower()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=['next', 'current', 'previous'])
    parser.add_argument('--sparkle', action='store_true', default=False)
    print(current_version_tuple())
