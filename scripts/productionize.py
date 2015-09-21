import os
import jinja2
import json
import version
import logging


def create_conf_json(version):
    conf = json.load(open('src/config.json'))

    if os.environ.get('TRAVIS_BRANCH', '') != 'release':
        return

    conf.update({
        "iteration": version,
        "feedurl": "http://files.projecthawkthorne.com/appcast.json",
    })

    with open('src/config.json', 'w') as f:
        json.dump(conf, f, indent=2, sort_keys=True)


def create_info_plist(version):
    template = jinja2.Template(open('templates/Info.plist').read())

    with open('osx/Info.plist', 'w') as f:
        f.write(template.render(version=version))


def create_conf_lua(version):
    template = jinja2.Template(open('templates/conf.lua').read())

    with open('src/conf.lua', 'w') as f:
        f.write(template.render(version=version))


def main():
    if os.environ.get('TRAVIS_BRANCH', '') == 'release':
        v = version.next_version()
    else:
        v = "0.0.0"

    logging.info("Creating osx/Info.plist")
    create_info_plist(v)

    logging.info("Creating src/config.json")
    create_conf_json(v)

    logging.info("Creating src/conf.lua")
    create_conf_lua(v)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()
