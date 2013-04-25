import os
import jinja2
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
    template = jinja2.Template(open('templates/conf.lua').read())

    with open('src/conf.lua', 'w') as f:
        f.write(template.render(version=version))


def create_info_plist(version):
    template = jinja2.Template(open('templates/Info.plist').read())

    with open('osx/Info.plist', 'w') as f:
        f.write(template.render(version=version))


def main():
    v = version.next_version()

    logging.info("Creating osx/Info.plist")
    create_info_plist(v)

    logging.info("Creating src/conf.lua")
    create_conf_lua(v)

    logging.info("Creating src/main.lua")
    create_main_lua()


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()
