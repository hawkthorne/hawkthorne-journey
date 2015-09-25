import argparse
import boto
import requests

pulls_url = "https://api.github.com/repos/hawkthorne/hawkthorne-journey/pulls"
GITHUB_TIME = "%Y-%m-%dT%H:%M:%SZ"


def post_content():
    resp = requests.get(pulls_url, params={
        'state': 'closed',
        'base': 'release'
    })
    pulls = resp.json()

    if not pulls:
        raise ValueError(('No pull request for this release, which means no'
                          'post'))

    return pulls[0]['body']


def commithash(version):
    bucket = boto.s3.get_bucket("files.projecthawkthorne.com", validate=False)
    key = bucket.get_key("releases/v{}/hawkthorne-osx.zip".format(version))

    if key is None:
        return key

    return key.get_contents()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('output', type=argparse.FileType('w'))
    args = parser.parse_args()
    args.output.write(post_content())


if __name__ == "__main__":
    main()
