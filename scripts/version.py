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

def next_version():
    x, y, z = current_version_tuple()
    return "{0}.{1}.{2}".format(x,y,int(z) + 1) 

def next_minor_version():
    x, y, z = current_version_tuple()
    return "{0}.{1}.0".format(x,int(y)+1) 

def prev_version():
    x, y, z = current_version_tuple()
    return "{0}.{1}.{2}".format(x,y,int(z) - 1) 


def current_version_tuple():
    bucket = s3.get_bucket("files.projecthawkthorne.com")
    key = bucket.get_key("releases/latest/hawkthorne-osx.zip")
    redirect = key.get_redirect()
    _, _, version, _ = redirect.split('/')
    return tuple(version.replace('v', '').split('.'))

def is_release(pull_request_number):
    base = "https://api.github.com/repos/hawkthorne/hawkthorne-journey/pulls/{}"
    resp = requests.get(base.format(pull_request_number))
    if not resp.ok:
        return False
    pull_request = resp.json()
    return 'release' in pull_request.get('title', '').lower()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=['next', 'current', 'previous'])
    parser.add_argument('--sparkle', action='store_true', default=False)
    print(current_version_tuple())
