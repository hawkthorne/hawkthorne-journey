import os
import sys
from datetime import datetime
import argparse
import requests
import jinja2
import json
import time
import subprocess

pulls_url = "https://api.github.com/repos/hawkthorne/hawkthorne-journey/pulls"
issues_url = "https://api.github.com/repos/hawkthorne/hawkthorne-journey/issues"
tag_url = "https://api.github.com/repos/hawkthorne/hawkthorne-journey/git/tags/{}"
GITHUB_TIME = "%Y-%m-%dT%H:%M:%SZ"

title = "[RELEASE] Journey to the Center of Hawkthorne {}"


def post_content(base, head):
    sha = subprocess.check_output(["git", "show-ref", base]).split(" ")[0]

    tag = requests.get(tag_url.format(sha)).json()

    # Just pretend the date is UTC.
    tag_date = datetime.strptime(tag['tagger']['date'], GITHUB_TIME)

    new_features = []

    for pull_request in requests.get(pulls_url, params={'state': 'closed'}).json():
        if not pull_request['merged_at']:
            continue
	if datetime.strptime(pull_request['merged_at'], GITHUB_TIME) > tag_date:
            new_features.append(pull_request)

    template = jinja2.Template(open('templates/post.md').read())

    bugs = requests.get(issues_url, params={'labels': 'bug'}).json()

    return template.render(new_features=new_features, version=head, bugs=bugs)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('base')
    parser.add_argument('head')
    parser.add_argument('output', type=argparse.FileType('w'))
    args = parser.parse_args()

    content = post_content(args.base, args.head)

    args.output.write(content)


if __name__ == "__main__":
    main()
