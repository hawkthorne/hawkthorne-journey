import os
import urllib
import version
import json
import sys

if __name__ == "__main__":
    current = version.current_version()

    feed = urllib.urlopen("http://www.reddit.com/user/Britta-bot.json")
    listing = json.load(feed)

    versions = set()

    for post in listing['data']['children']:
        if post['kind'] != 't3':
            continue
        _, v = post['data']['title'].split("Hawkthorne ")
        versions.add(v)

    if current not in versions:
        sys.stdout.write('true')
    else:
        sys.stdout.write('false')
    exit(0)
