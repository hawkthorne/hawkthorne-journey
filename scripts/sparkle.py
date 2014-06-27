import datetime
import os
import urllib
import logging
import json
import codecs
from email.utils import formatdate
from calendar import timegm

logging.basicConfig(level=logging.INFO)


CHANGES_URL = "http://files.projecthawkthorne.com/releases/{}/notes.html"
CAST_URL = "http://files.projecthawkthorne.com/appcast.json"
HAWK_URL = "http://files.projecthawkthorne.com/releases/{}/hawkthorne-osx.zip"
FILE_URL = "http://files.projecthawkthorne.com/releases/{}/win/{}"


def appcast_item(version, sparkle_version):
    zip_path = os.path.join("build", "hawkthorne-osx.zip")

    osx = {
        "name": "macosx",
        "files": [{
            "url": HAWK_URL.format(version),
            "length": os.path.getsize(zip_path),
        }],
    }

    paths = [
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

    def windows_file(filename):
        size = os.path.getsize(os.path.join("win32", filename))

        return {
            "url": FILE_URL.format(version, filename),
            "length": size,
        }

    windows = {
        "name": "windows",
        "files": [windows_file(path) for path in paths],
    }

    item = {
        "title": "Version {}".format(version),
        "published": formatdate(timegm(datetime.datetime.now().utctimetuple())),
        "version": sparkle_version,
        "changelog": CHANGES_URL.format(version),
        "platforms": [osx, windows],
    }

    return item


if __name__ == "__main__":
    config = json.load(open('src/config.json'))
    sparkle_version = config['iteration']
    current_version = "v" + sparkle_version

    try:
        os.mkdir('sparkle')
    except OSError:
        pass

    if not os.path.exists("sparkle/appcast.json"):
        urllib.urlretrieve(CAST_URL, "sparkle/appcast.json")

    appcast = json.load(codecs.open("sparkle/appcast.json", "r", "utf-8"))

    for item in appcast['items']:
        if sparkle_version == item['version']:
            raise ValueError('Item with this version already exists')

    appcast['items'].insert(0, appcast_item(current_version, sparkle_version))

    json.dump(appcast, codecs.open("sparkle/appcast.json", "w", "utf-8"))
