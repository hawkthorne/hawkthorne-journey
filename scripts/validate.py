import argparse
import os
import json
import xml.etree.ElementTree as etree


def scan(directory):
    errors = False

    for (path, dirs, files) in os.walk(directory):
        for f in files:
            if f.endswith(".json"):
                json_path = os.path.join(path, f)

                try:
                    json.load(open(json_path))
                except ValueError:
                    errors = True
                    print "{} is not valid JSON".format(json_path)

            if f.endswith(".tmx") or f.endswith(".xml"):
                xml_path = os.path.join(path, f)

                try:
                    etree.parse(open(xml_path))
                except etree.ParseError:
                    errors = True
                    print "{} is not valid XML".format(xml_path)


    if errors:
        exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('directory', help="Directory to scan")
    args = parser.parse_args()
    scan(args.directory)
