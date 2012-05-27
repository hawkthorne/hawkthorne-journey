import os
import argparse
import requests
import jinja2
import json

class Reddit(object):

    def __init__(self, user_agent):
        self.sessions = {}
        self.user_agent = user_agent

    def _authenticate(self, auth):
        username, password = auth

        if username in self.sessions:
            return self.sessions[username]

        payload = {'user': username, 'passwd': password}

        resp = requests.post('https://ssl.reddit.com/api/login', data=payload)
        resp.raise_for_status()

        self.sessions[username] = resp.cookies
        return resp.cookies
 

    def submit(self, subreddit, title, text='', auth=None):
        payload = {
            'kind': 'self',
            'sr': subreddit,
            'title': title,
            'text': text,
        }

        resp = requests.post('http://www.reddit.com/api/submit',
            data=payload, cookies=self._authenticate(auth))

        resp.raise_for_status()


url = ("https://api.github.com/repos/kyleconroy/"
       "hawkthorne-journey/compare/{}...{}")
title = "[RELEASE] Journey to the Center of Hawkthorne {}"

parser = argparse.ArgumentParser()
parser.add_argument('base')
parser.add_argument('head')
parser.add_argument('-d', '--debug', default=False, action='store_true')
args = parser.parse_args()

def post_content(base, head):

    diff = json.loads(requests.get(url.format(base, head)).text)

    template = jinja2.Template(open('templates/post.md').read())

    for commit in diff['commits']:
        commit['commit']['message'] = commit['commit']['message'].replace("\n\n", "\n\n    ")

    return template.render(commits=diff['commits'], version=args.head)


if args.debug:
    print post_content(args.base, args.head)
    exit(0)

r = Reddit(os.environ['BRITTA_BOT_USER'])

r.submit('hawkthorne', title.format(args.head),
    text=post_content(args.base, args.head),
    auth=(os.environ['BRITTA_BOT_USER'], os.environ['BRITTA_BOT_PASS']))
