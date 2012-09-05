"""
Bump the version number
"""
import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('action', choices=['next', 'current', 'previous'])
args = parser.parse_args()

version = None
title = None

for line in open('src/conf.lua'):
    line = line.strip()
    if 't.title' not in line:
        continue
    _, full_title = line.replace('"', '').split('=')
    title, current = full_title.strip().rsplit(' ', 1)
    x, y, z = current.split('.')
    
    if args.action == 'next':
        z = int(z) + 1
    elif args.action == 'previous':
        z = int(z) - 1
    else:
        z = int(z)

    version = "{0}.{0}.{0}".format(x,y,z) 

if not title or not version:
    print "Could not find version number"
    exit(1)

if version == '0.8.0':
    print "This is the LOVE version, not safe"
    exit(1)

print version
exit(0)

