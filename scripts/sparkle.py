import boto
import datetime
import os
import urllib
import requests
import logging
import subprocess
import xml.etree.ElementTree as etree
from os import path
from email.utils import formatdate
from calendar import timegm

import upload
import version

logging.basicConfig(level=logging.INFO)

etree.register_namespace('dc',"http://purl.org/dc/elements/1.1/")
etree.register_namespace('sparkle', "http://www.andymatuschak.org/xml-namespaces/sparkle")

HAWK_URL = "http://files.projecthawkthorne.com/releases/{}/hawkthorne-osx.zip"
DELTA_URL = "http://files.projecthawkthorne.com/deltas/{}"
CHANGES_URL = "http://files.projecthawkthorne.com/releases/{}/notes.html"
CAST_URL = "http://files.projecthawkthorne.com/appcast.xml"
VERSION_KEY = '{http://www.andymatuschak.org/xml-namespaces/sparkle}version'


def download(version):
    app_dir = path.join("sparkle", "releases", version)
    zip_path = path.join(app_dir, "hawk-osx.zip")
    app_path = path.join(app_dir, "Journey to the Center of Hawkthorne.app")

    if not path.exists(app_dir):
        os.makedirs(app_dir)

    if not path.exists(zip_path):
        logging.info("Fetching {}".format(zip_path))
        urllib.urlretrieve(HAWK_URL.format(version), zip_path)


def sign(path):
    return subprocess.check_output(["ruby", "scripts/sign_update.rb", path,
                                    "dsa_priv.pem"]).strip()


def make_appcast_item(version, sparkle_version):
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

    return item


if __name__ == "__main__":
    current_version = "v" + version.current_version()
    sparkle_current_version = current_version.replace("v", "")
    current_dir = path.join("sparkle", "releases", current_version)

    try:
        os.mkdir("sparkle")
    except OSError:
        pass

    if not path.exists("sparkle/appcast.xml"):
        urllib.urlretrieve(CAST_URL, "sparkle/appcast.xml")

    appcast = etree.parse("sparkle/appcast.xml")

    channel = appcast.find('channel')

    # Namespace bull
    root = appcast.getroot()

    if not path.exists("sparkle/releases"):
        os.makedirs("sparkle/releases")

    download(current_version)

    index = channel.getchildren().index(channel.find('language')) + 1

    for i, item in enumerate(channel.findall('item')):

        info = item.find('enclosure')

        if info is not None and info.attrib.get(VERSION_KEY, '') == sparkle_current_version:
            index = channel.getchildren().index(item)
            channel.remove(item)

    item = make_appcast_item(current_version, sparkle_current_version)
    channel.insert(index, item)

    if not "xmlns:dc" in root.attrib:
        root.set('xmlns:dc',"http://purl.org/dc/elements/1.1/")

    appcast.write("sparkle/appcast.xml", xml_declaration=True,
                  encoding='utf-8')
