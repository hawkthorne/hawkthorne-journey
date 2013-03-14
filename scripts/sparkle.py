import version
import datetime
import os
import urllib
import logging
import subprocess
import xml.etree.ElementTree as etree
from os import path
from email.utils import formatdate
from calendar import timegm
import upload

logging.basicConfig(level=logging.INFO)

etree.register_namespace('dc',"http://purl.org/dc/elements/1.1/")
etree.register_namespace('sparkle', "http://www.andymatuschak.org/xml-namespaces/sparkle")

HAWK_URL = "http://files.projecthawkthorne.com/releases/{}/hawkthorne-osx.zip"
DELTA_URL = "http://files.projecthawkthorne.com/deltas/{}"
CHANGES_URL = "http://files.projecthawkthorne.com/releases/{}/notes.html"
BDIFF_URL = "https://bitbucket.org/kyleconroy/love/downloads/BinaryDelta.zip"
CAST_URL = "http://files.projecthawkthorne.com/appcast.xml"
VERSION_KEY = '{http://www.andymatuschak.org/xml-namespaces/sparkle}version'


def upload_deltas(delta_paths):
    for delta in delta_paths:
        logging.info('Uploading {}'.format(delta))
        upload.upload_path("deltas", delta)


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


def sign(path):
    return subprocess.check_output(["ruby", "scripts/sign_update.rb", path,
                                    "dsa_priv.pem"]).strip()


def make_appcast_item(version, sparkle_version, delta_paths):
    item = etree.Element('item')
    zip_path = path.join("sparkle", "releases", version, "hawk-osx.zip")

    title = etree.SubElement(item, 'title')
    title.text = "Version {}".format(version)

    notes = etree.SubElement(item, 'sparkle:releaseNotesLink')
    notes.text = CHANGES_URL.format(version)

    date = etree.SubElement(item, 'pubDate')
    date.text = formatdate(timegm(datetime.datetime.now().utctimetuple()))

    full_zip = etree.SubElement(item, 'enclosure')
    full_zip.attrib['url'] = HAWK_URL.format(version) 
    full_zip.attrib['length'] = unicode(os.path.getsize(zip_path))
    full_zip.attrib['type'] = "application/octet-stream"
    full_zip.attrib['sparkle:version'] = sparkle_version
    full_zip.attrib['sparkle:dsaSignature'] = sign(zip_path)

    deltas = etree.SubElement(item, 'sparkle:deltas')

    for delta_path in delta_paths:
        _, filename = os.path.split(delta_path)
        old_version, _ = filename.split('-')

        delta = etree.SubElement(deltas, 'enclosure')
        delta.attrib['url'] = DELTA_URL.format(filename) 
        delta.attrib['length'] = unicode(os.path.getsize(delta_path))
        delta.attrib['type'] = "application/octet-stream"
        delta.attrib['sparkle:version'] = sparkle_version
        delta.attrib['sparkle:deltaFrom'] = old_version
        delta.attrib['sparkle:dsaSignature'] = sign(delta_path)

    return item


if __name__ == "__main__":
    x, y, z = version.current_version_tuple()
    versions = ["{}.{}.{}".format(x, y, int(z) - i) for i in range(3)]

    current_version = versions[0]
    sparkle_current_version = current_version.replace("v", "")
    current_dir = path.join("sparkle", "releases", current_version)

    if not path.exists("sparkle/appcast.xml"):
        urllib.urlretrieve(CAST_URL, "sparkle/appcast.xml")

    appcast = etree.parse("sparkle/appcast.xml")

    channel = appcast.find('channel')

    # Namespace bull
    root = appcast.getroot()

    if not "xmlns:dc" in root.attrib:
        root.set('xmlns:dc',"http://purl.org/dc/elements/1.1/")

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

    deltas = []

    for version in versions[1:]:
        download(version)

        sparkle_version = version.replace("v", "")

        delta_path = path.join("sparkle", "deltas",
                "{}-{}.delta".format(sparkle_version, sparkle_current_version))

        if not path.exists(delta_path):
            app_dir = path.join("sparkle", "releases", version)

            subprocess.call(["sparkle/BinaryDelta", "create", 
                path.join(app_dir, "Journey to the Center of Hawkthorne.app"),
                path.join(current_dir, "Journey to the Center of Hawkthorne.app"),
                delta_path])

        deltas.append(delta_path)

    index = channel.getchildren().index(channel.find('language')) + 1

    for i, item in enumerate(channel.findall('item')):

        info = item.find('enclosure')

        if info is not None and info.attrib[VERSION_KEY] == sparkle_current_version:
            index = channel.getchildren().index(item)
            channel.remove(item)

    item = make_appcast_item(current_version, sparkle_current_version, deltas)
    channel.insert(index, item)

    appcast.write("sparkle/appcast.xml", xml_declaration=True,
                  encoding='utf-8')

    upload_deltas(deltas)
