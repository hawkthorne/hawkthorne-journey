import re

names = set()

for line in open('redditors.txt'):

    line = re.sub(r"\(.*\)", "", line)

    for operator in [" and ", "&", "/", ",", "+"]:
        line = line.replace(operator, "\t")

    for name in line.split("\t"):
        names.add(name.lower().strip())

for name in sorted(names):
    if name:
        print name
