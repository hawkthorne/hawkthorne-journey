import os
from datetime import datetime
import argparse
import requests
import jinja2
import json
import time
import tweepy
import logging

import version


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
            'uh': resp.json()['data']['modhash'],
        }

        resp = requests.post('http://www.reddit.com/api/submit',
            data=payload, cookies=self._authenticate(auth))
        resp.raise_for_status()

        return resp


pulls_url = "https://api.github.com/repos/hawkthorne/hawkthorne-journey/pulls"
issues_url = "https://api.github.com/repos/hawkthorne/hawkthorne-journey/issues"
tag_url = "https://api.github.com/repos/hawkthorne/hawkthorne-journey/git/tags/{}"
GITHUB_TIME = "%Y-%m-%dT%H:%M:%SZ"

title = "Journey to the Center of Hawkthorne v{} has been released"


def reddit_url(api_response):
    """Return the post url from the reddit API response."""
    # This is because of reddit's insane return values
    return  api_response['jquery'][-1][3][0]


def update_twitter(version, post_url):
    tweet = "Journey to Center of Hawkthorne {} {}".format(version, post_url)

    if 'TRAVIS' not in os.environ:
        logging.info('[DRYRUN] Tweeting {}'.format(tweet))
        return

    consumer_key = "wCIocGQX6rGhkwXGDAIeiw"
    consumer_secret = os.environ['BRITTA_BOT_CONSUMER_SECRET']
    access_token = "769023462-ehzty7lqwnJdkcO72iGFzBWymGOy5bGKD90VyB8"
    access_token_secret = os.environ['BRITTA_BOT_ACCESS_SECRET']

    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)

    api = tweepy.API(auth)
    api.update_status(tweet)


def update_reddit(title, post, community=False):
    if 'TRAVIS' not in os.environ:
        logging.info('[DRYRUN] Posting {}'.format(title))
        logging.info(post)
        return

    r = Reddit(os.environ['BRITTA_BOT_USER'])

    resp = r.submit('hawkthorne', title,
        text=post,
        auth=(os.environ['BRITTA_BOT_USER'], os.environ['BRITTA_BOT_PASS']))

    if not community:
        return reddit_url(resp.json())

    r.submit('community', title,
        text=post,
        auth=(os.environ['BRITTA_BOT_USER'], os.environ['BRITTA_BOT_PASS']))

    return reddit_url(resp.json())


def main():
    logging.basicConfig(level=logging.INFO)

    parser = argparse.ArgumentParser()
    parser.add_argument('input', type=argparse.FileType('r'))
    parser.add_argument('-d', '--debug', default=False, action='store_true')
    args = parser.parse_args()
    
    v = version.current_version()
    body = args.input.read()
    template = open('templates/post.md').read()
    post = template.format(body=body, version=v)

    post_url = update_reddit(title.format(v), post,
                             community=version.is_release())
    update_twitter(v, post_url)


if __name__ == "__main__":
    main()
