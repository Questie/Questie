#!/usr/bin/env python3

import changelog  # Our own changelog.py
import fileinput
import subprocess
import sys

if not len(sys.argv) > 1:
    print('Needs new version number provided as argument')
    exit()

version = sys.argv[1]

if version[0] == "v":
    print('Please omit the "v" prefix. The script will add it')
    exit()

tocs = ['Questie-Classic.toc', 'Questie-BCC.toc', 'Questie-WOTLKC.toc', 'Questie-Cata.toc']

for toc in tocs:
    with fileinput.FileInput(toc, inplace=True) as file:
        for line in file:
            if line[:10] == '## Version':
                print('## Version: ' + version)
            elif line[:8] == '## Title':
                print('## Title: Questie|cFF00FF00 v' + version + '|r')
            else:
                print(line, end='')

with fileinput.FileInput('README.md', inplace=True) as file:
    for line in file:
        if line[:20] == '[![Downloads Latest]':
            print('[![Downloads Latest](https://img.shields.io/github/downloads/Questie/Questie/v' + version + '/total.svg)](https://github.com/Questie/Questie/releases/latest)')
        else:
            print(line, end='')

changelogString = changelog.get_commit_changelog()

print('######### START CHANGELOG')
print('# Questie v' + version + '\n\n' + changelogString)
print('######### END CHANGELOG')

subprocess.run(['git', 'add', 'README.md'])
subprocess.run(['git', 'add', '*.toc'])
subprocess.run(['git', 'commit', '-mBump version to v' + version])
subprocess.run(['git', 'tag', 'v' + version])
