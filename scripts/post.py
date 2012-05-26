import os
import argparse
import requests
import jinja2
import json
import reddit

url = ("https://api.github.com/repos/kyleconroy/"
       "hawkthorne-journey/compare/{}...{}")
title = "[RELEASE] Journey to the Center of Hawkthorne {}"

parser = argparse.ArgumentParser()
parser.add_argument('base')
parser.add_argument('head')
args = parser.parse_args()

def post_content(base, head):

    diff = json.loads(requests.get(url.format(base, head)).text)

    template = jinja2.Template(open('templates/post.md').read())

    for commit in diff['commits']:
        commit['commit']['message'] = commit['commit']['message'].replace("\n\n", "\n\n    ")

    return template.render(**diff)

r = reddit.Reddit(user_agent=os.environ['BRITTA_BOT_USER'])
r.login(os.environ['BRITTA_BOT_USER'], os.environ['BRITTA_BOT_PASS'])
r.submit('hawkthorne', title.format(args.head),
    text=post_content(args.base, args.head))





