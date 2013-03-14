import os
import jinja2
import subprocess


ENVVARS = [
    'MIXPANEL_TOKEN',
    'AWS_ACCESS_KEY_ID',
    'AWS_SECRET_ACCESS_KEY',
    'BRITTA_BOT_USER',
    'BRITTA_BOT_PASS',
    'BRITTA_BOT_ACCESS_SECRET',
    'BRITTA_BOT_CONSUMER_SECRET',
]


def encrypt(variable):
    return subprocess.check_output(['travis', 'encrypt', variable + "=" + os.environ[variable]])


def main():
    template = jinja2.Template(open('templates/travis.yml').read())
    print template.render(envvars=map(encrypt, ENVVARS))


if __name__ == "__main__":
    main()
