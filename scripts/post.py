import os
import argparse
import requests
import jinja2
import json
import time
import tweepy


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

        return resp


url = ("https://api.github.com/repos/kyleconroy/"
       "hawkthorne-journey/compare/{}...{}")
issues_url = "https://api.github.com/repos/kyleconroy/hawkthorne-journey/issues"

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

    diff = requests.get(url.format(base, head)).json

    template = jinja2.Template(open('templates/post.md').read())

    for commit in diff['commits']:
        commit['commit']['message'] = commit['commit']['message'].replace("\n\n", "\n\n    ")

    diff = json.loads(requests.get(url.format(base, head)).text)


    bugs = requests.get(issues_url, params={'labels': 'bug'}).json
    features = requests.get(issues_url, params={'labels': 'enhancement'}).json

    return template.render(commits=diff['commits'], version=head,
                           bugs=bugs, features=features)


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
