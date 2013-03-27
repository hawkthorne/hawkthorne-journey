import re
import argparse
import subprocess

def post_content(version):
    commit = subprocess.check_output(["git", "show", "-s", "--format=%b",
                                      "{}^{{commit}}".format(version)])

    post = []
    capture = True
    started_list = False

    for line in commit.split("\n"):
        if line.startswith("**How can"):
            capture = False
        if line.startswith("**CHANGES"):
            capture = True

        if not capture or "[love]" in line:
            continue

        bbcode = re.sub(r'\*\*(.+)\*\*', r'[b]\1[/b]', line)
        bbcode = re.sub(r'\- \[(.+)\]\((.+)\)', r'[*][url=\2]\1[/url]', bbcode)

        if line.startswith("- [") and not started_list:
            print "[list]"
            started_list = True

        if len(line) == 0 and started_list:
            started_list = False
            print "[/list]"

        print bbcode


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('version')
    args = parser.parse_args()
    post_content(args.version)

if __name__ == "__main__":
    main()
