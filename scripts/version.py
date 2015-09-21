"""
Bump the version number
"""
import argparse
import requests


def current_version():
    x, y, z = current_version_tuple()
    return "{0}.{1}.{2}".format(x, y, z)


def next_bugfix_version():
    x, y, z = current_version_tuple()
    return "{0}.{1}.{2}".format(x, y, int(z) + 1)


def next_minor_version():
    x, y, z = current_version_tuple()
    return "{0}.{1}.0".format(x, int(y)+1)


def next_major_version():
    x, y, z = current_version_tuple()
    return "{0}.0.0".format(int(x)+1)


def next_version():
    if is_major():
        return next_major_version()
    elif is_release():
        return next_minor_version()
    else:
        return next_bugfix_version()


def prev_version():
    x, y, z = current_version_tuple()
    return "{0}.{1}.{2}".format(x, y, int(z) - 1)


def current_version_tuple():
    url = ("https://api.github.com/repos/hawkthorne/"
           "hawkthorne-journey/releases/latest")
    resp = requests.get(url)
    tag_name = resp.json()['tag_name']
    return tuple(tag_name.replace('v', '').split('.'))


def is_release():
    url = "https://api.github.com/repos/hawkthorne/hawkthorne-journey/pulls"
    resp = requests.get(url, params={'state': 'closed', 'base': 'release'})

    if not resp.ok:
        return False

    pulls = resp.json()

    if len(pulls) == 0:
        return False

    return 'release' in pulls[0].get('title', '').lower()


def is_major():
    url = "https://api.github.com/repos/hawkthorne/hawkthorne-journey/pulls"
    resp = requests.get(url, params={'state': 'closed', 'base': 'release'})

    if not resp.ok:
        return False

    pulls = resp.json()

    if len(pulls) == 0:
        return False

    return 'majorversion' in pulls[0].get('title', '').lower()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=['next', 'current', 'previous'])
    parser.add_argument('--sparkle', action='store_true', default=False)
    print(current_version_tuple())
