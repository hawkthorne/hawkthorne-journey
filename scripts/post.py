import os
from datetime import datetime
import argparse
import requests
import jinja2
import json
import time
import tweepy
import subprocess


class Reddit(object):

    def __init__(self, user_agent):
        self.user_agent = user_agent

    def _authenticate(self, auth):
        username, password = auth
        payload = {'user': username, 'passwd': password}

        resp = requests.post('https://ssl.reddit.com/api/login', data=payload)
        resp.raise_for_status()

        return resp.cookies
 

    def submit(self, subreddit, title, text='', auth=None):
        cookies = self._authenticate(auth)

        resp = requests.get('http://www.reddit.com/api/me.json', cookies=cookies)
        resp.raise_for_status()

        payload = {
            'kind': 'self',
            'sr': subreddit,
            'title': title,
            'text': text,
            'uh': resp.json['data']['modhash'],
        }

        resp = requests.post('http://www.reddit.com/api/submit',
            data=payload, cookies=self._authenticate(auth))
        resp.raise_for_status()

        return resp


pulls_url = "https://api.github.com/repos/kyleconroy/hawkthorne-journey/pulls"
issues_url = "https://api.github.com/repos/kyleconroy/hawkthorne-journey/issues"
tag_url = "https://api.github.com/repos/kyleconroy/hawkthorne-journey/git/tags/{}"
GITHUB_TIME = "%Y-%m-%dT%H:%M:%SZ"

title = "[RELEASE] Journey to the Center of Hawkthorne {}"


def reddit_url(api_response):
    """Return the post url from the reddit API response."""
    # This is because of reddit's insane return values
    return  api_response['jquery'][-1][3][0]


def update_twitter(version, api_response):
    post_url = reddit_url(api_response)

    consumer_key = "wCIocGQX6rGhkwXGDAIeiw"
    consumer_secret = os.environ['BRITTA_BOT_CONSUMER_SECRET']
    access_token = "769023462-ehzty7lqwnJdkcO72iGFzBWymGOy5bGKD90VyB8"
    access_token_secret = os.environ['BRITTA_BOT_ACCESS_SECRET']

    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    api = tweepy.API(auth)

    tweet = "Journey to Center of Hawkthorne {} {}".format(version, post_url)
    api.update_status(tweet)


def post_content(base, head):
    sha = subprocess.check_output(["git", "show-ref", base]).split(" ")[0]

    tag = requests.get(tag_url.format(sha)).json

    # Just pretend the date is UTC.
    tag_date = datetime.strptime(tag['tagger']['date'].rsplit('-', 1)[0] + 'Z', GITHUB_TIME)

    new_features = []

    for pull_request in requests.get(pulls_url, params={'state': 'closed'}).json:
        if not pull_request['merged_at']:
            continue
	if datetime.strptime(pull_request['merged_at'], GITHUB_TIME) > tag_date:
            new_features.append(pull_request)

    template = jinja2.Template(open('templates/post.md').read())

    bugs = requests.get(issues_url, params={'labels': 'bug'}).json

    return template.render(new_features=new_features, version=head, bugs=bugs)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('base')
    parser.add_argument('head')
    parser.add_argument('-d', '--debug', default=False, action='store_true')
    args = parser.parse_args()

    if args.debug:
        print post_content(args.base, args.head)
        return

    r = Reddit(os.environ['BRITTA_BOT_USER'])

    resp = r.submit('hawkthorne', title.format(args.head),
        text=post_content(args.base, args.head),
        auth=(os.environ['BRITTA_BOT_USER'], os.environ['BRITTA_BOT_PASS']))

    update_twitter(args.head, resp.json)


if __name__ == "__main__":
    main()
