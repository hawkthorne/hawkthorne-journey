import argparse
import os
import json


def scan(directory):
    errors = False

    for (path, dirs, files) in os.walk(directory):
        for f in files:
            if not f.endswith(".json"):
                continue
            
            json_path = os.path.join(path, f)

            try:
                json.load(open(json_path))
            except ValueError:
                errors = True
                print "{} is not valid JSON".format(json_path)

    if errors:
        exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('directory', help="Directory to scan")
    args = parser.parse_args()
    scan(args.directory)
