import os
import jinja2
import json
import version
import logging

MIXPANEL_DEV = 'ac1c2db50f1332444fd0cafffd7a5543'
MIXPANEL_TOKEN = os.environ.get('MIXPANEL_TOKEN', MIXPANEL_DEV)


def create_main_lua():
    with open('src/main.lua') as infile:
        contents = infile.read()

    with open('src/main.lua', 'w') as outfile:
        outfile.write(contents.replace(MIXPANEL_DEV, MIXPANEL_TOKEN))


def create_conf_lua(version):
    production_conf = {
        "mixpanel": MIXPANEL_TOKEN,
        "title": "Journey to the Center of Hawkthorne v" + version,
        "url": "http://projecthawkthorne.com",
        "author": "https://github.com/hawkthorne?tab=members",
        "version": "0.8.0",
        "identity": "hawkthorne_release",
        "screen": {
            "width": 1056,
            "height": 672,
            "fullscreen": False,
            },
        "console": False,
        "modules": {
            "physics": False,
            "joystick": False,
            },
        "release": True,
    }

    with open('src/config.json', 'w') as f:
        json.dump(production_conf, f, indent=2, sort_keys=True)


def create_info_plist(version):
    template = jinja2.Template(open('templates/Info.plist').read())

    with open('osx/Info.plist', 'w') as f:
        f.write(template.render(version=version))


def main():
    v = version.next_version()

    logging.info("Creating osx/Info.plist")
    create_info_plist(v)

    logging.info("Creating src/config.json")
    create_conf_lua(v)

    logging.info("Creating src/main.lua")
    create_main_lua()


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()
