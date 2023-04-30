#!/usr/bin/env python3

import sys

if not len(sys.argv) > 1:
    print('Needs new version number provided as argument')
    exit()

version = sys.argv[1]

import subprocess
import fileinput

tocs = ['Questie-Classic.toc', 'Questie-BCC.toc', 'Questie-WOTLKC.toc']

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

changelog = subprocess.check_output(['./changelog.py'], stderr=subprocess.STDOUT).decode()

print('######### START CHANGELOG')
print('# Questie v' + version + '\n\n' + changelog)
print('######### END CHANGELOG')

subprocess.run(['git', 'add', 'README.md'])
subprocess.run(['git', 'add', '*.toc'])
subprocess.run(['git', 'commit', '-mBump version to ' + version])
subprocess.run(['git', 'tag', 'v' + version])
