import os
import urllib
import version
import json
import sys

if __name__ == "__main__":
    current = version.current_version()
    url = "http://files.projecthawkthorne.com/releases/{}/notes.html"

    feed = urllib.urlopen(url.format(current))

    if feed.getcode() == 403:
        sys.stdout.write('true')
    else:
        sys.stdout.write('false')
    exit(0)
