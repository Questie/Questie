#!/usr/bin/env python3

helptext = """
Usage example:

python versionbump.py 12.0.0

Add --no-git after the version to update TOCs without staging, committing or tagging.

This is a helper script that will:

1. Update the "Version" and "Title" fields in all the toc files except
Questie.toc to "<argument>" and "v<argument>" respectively.
2. Commit the changes with the commit title "Bump version to v<argument>"
3. Set a git tag called "v<argument>"
"""

from build import EXPANSIONS # Our own build.py
import fileinput
import subprocess
import sys

# check for version argument
if not len(sys.argv) > 1:
    print('ERROR: Needs new version number provided as argument')
    print(helptext)
    exit(1)
version = sys.argv[1]
if version[0] == "v":
    print('ERROR: Please omit the "v" prefix. The script will add it')
    print(helptext)
    exit(1)
if version in ["-h", "--help"]:
    print(helptext[1:]) # skip first char (a \n)
    exit()

# update TOC files
for number, expansion in EXPANSIONS.items():
    with fileinput.FileInput(f"Questie_{expansion['toc_suffix']}.toc", inplace=True) as file:
        for line in file:
            if line[:10] == '## Version':
                print('## Version: ' + version)
            elif line[:8] == '## Title':
                print('## Title: Questie|cFF00FF00 v' + version + '|r')
            else:
                print(line, end='')

if '--no-git' in sys.argv[2:]:
    exit()

# commit and tag changes; stop on failure so a failed commit cannot tag the old HEAD
if subprocess.run(['git', 'add', '*.toc']).returncode != 0:
    exit(1)
if subprocess.run(['git', 'commit', '-mBump version to v' + version]).returncode != 0:
    exit(1)
if subprocess.run(['git', 'tag', 'v' + version]).returncode != 0:
    exit(1)
