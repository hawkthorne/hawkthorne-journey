import version
import os
import urllib
import logging
import subprocess
from os import path

logging.basicConfig(level=logging.INFO)

HAWK_URL = "http://files.projecthawkthorne.com/releases/{}/hawkthorne-osx.zip"
BDIFF_URL = "https://bitbucket.org/kyleconroy/love/downloads/BinaryDelta.zip"


def download(version):
    app_dir = path.join("sparkle", "releases", version)
    zip_path = path.join(app_dir, "hawk-osx.zip")
    app_path = path.join(app_dir, "Journey to the Center of Hawkthorne.app")
    # Check S3 for existing delta?? Probably a good idea

    if not path.exists(app_dir):
        os.makedirs(app_dir)

    if not path.exists(zip_path):
        logging.info("Fetching {}".format(zip_path))
        urllib.urlretrieve(HAWK_URL.format(version), zip_path)

    if not path.exists(app_path):
        subprocess.call(["unzip", "-q", zip_path, "-d", app_dir])


if __name__ == "__main__":
    x, y, z = version.current_version_tuple()
    versions = ["{}.{}.{}".format(x, y, int(z) - i) for i in range(2)]

    current_version = versions[0]
    current_dir = path.join("sparkle", "releases", current_version)

    if not path.exists("sparkle/releases"):
        os.makedirs("sparkle/releases")

    if not path.exists("sparkle/deltas"):
        os.makedirs("sparkle/deltas")

    if not path.exists("sparkle/BinaryDelta"):

        if not path.exists("sparkle/BinaryDelta.zip"):
            logging.info("Fetching BinaryDelta")
            urllib.urlretrieve(BDIFF_URL, "sparkle/BinaryDelta.zip")

        subprocess.call(["unzip", "-q", "sparkle/BinaryDelta.zip", "-d", "sparkle"])

    download(current_version)

    for version in versions[1:]:
        download(version)

        delta_path = path.join("sparkle", "deltas",
                               "{}-{}.delta".format(version, current_version))

        if path.exists(delta_path):
            continue

        app_dir = path.join("sparkle", "releases", version)
        
        subprocess.call(["sparkle/BinaryDelta", "create", 
                         path.join(app_dir, "Journey to the Center of Hawkthorne.app"),
                         path.join(current_dir, "Journey to the Center of Hawkthorne.app"),
                         delta_path])
