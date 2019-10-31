#!/usr/bin/env python3

import subprocess

def getCommitChangelog():
    # get latest tag
    lastTag = subprocess.run(["git", "describe", "--abbrev=0"], capture_output=True).stdout.decode().strip('\n')
    # get first array of commit messages
    rawLog = subprocess.run(["git", "log", "--pretty=format:%s", f"{lastTag}..HEAD"], capture_output=True).stdout.decode().split('\n')
    # reverse it so it's chronological
    rawLog.reverse()
    # define the tags that should be shown and their order
    keyAndHeader = (
        ('feature', '## New Features\n\n'),
        ('fix', '## General Fixes\n\n'),
        ('quest', '## Quest Fixes\n\n'),
        ('db', '## Database Fixes\n\n'),
        ('locale', '## Localisation Fixes\n\n'),
    )
    categories = {}
    for keyHeader in keyAndHeader:
        categories[keyHeader[0]] = []
    # add lines to the categories
    for line in rawLog:
        for key in categories.keys():
            if f'[{key}]' in line:
                categories[key].append(line.replace(f'[{key}]', '').strip())
    # create the changelog string
    mdLog = ''
    for keyHeader in keyAndHeader:
        key = keyHeader[0]
        if len(categories[key]) > 0:
            header = keyHeader[1]
            mdLog += header
            for line in categories[key]:
                mdLog += f'* {line}\n'.replace('[', '\\[')
            mdLog += '\n'
    return mdLog

if __name__ == "__main__":
    print(getCommitChangelog())
