"""
Bump the version number
"""
import os
import argparse


def current_version():
    x, y, z = current_version_tuple()
    return "{0}.{1}.{2}".format(x,y,z) 
 

def current_version_tuple():
    for line in open('src/conf.lua'):
        line = line.strip()
        if 't.title' not in line:
            continue
        _, full_title = line.replace('"', '').split('=')
        title, current = full_title.strip().rsplit(' ', 1)
        return current.split('.')


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=['next', 'current', 'previous'])
    parser.add_argument('--sparkle', action='store_true', default=False)
    args = parser.parse_args()

    x, y, z = current_version_tuple()
       
    if args.action == 'next':
        z = int(z) + 1
    elif args.action == 'previous':
        z = int(z) - 1
    else:
        z = int(z)

    version = "{0}.{1}.{2}".format(x,y,z) 

    if not version:
        print "Could not find version number"
        exit(1)

    if version == '0.8.0':
        print "This is the LOVE version, not safe"
        exit(1)

    if args.sparkle:
        version = version.replace("v", "")

    print version
    exit(0)
