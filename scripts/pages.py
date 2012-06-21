import argparse
import requests
import csv
import json
from collections import defaultdict

parser = argparse.ArgumentParser()
parser.add_argument('media', choices=['audio'])
parser.add_argument('filename')

args = parser.parse_args()

def embed_code(url):
    resp = requests.get("http://soundcloud.com/oembed", params={
        "url": url, "iframe": "true", "format": "json"}
    )
    return json.loads(resp.text)['html']


if args.media == 'audio':
    sheet = csv.reader(open(args.filename))

    links = defaultdict(list)

    # Get rid of headers
    sheet.next()
    sheet.next()

    for row in sheet:
        title, _, kind, _, _, _, _, _, url, _ = row

        if not url or not kind or not title:
            continue

        links[kind.lower()].append((title, url))

    for kind in ['soundtrack', 'sound effect', 'fan service']:
        print "<h2>{}</h2>".format(kind.title())
        print "<ul>"
        for track in links[kind]:
            try:
                print "<li>" + embed_code(track[1]) + "</li>"
            except:
                pass
        print "</ul>"
