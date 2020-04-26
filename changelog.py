#!/usr/bin/env python3

import subprocess

# define the tags that should be shown and their order
commit_keys_and_header = (
    ('feature', '## New Features\n\n'),
    ('fix', '## General Fixes\n\n'),
    ('quest', '## Quest Fixes\n\n'),
    ('db', '## Database Fixes\n\n'),
    ('locale', '## Localisation Fixes\n\n'),
)


def get_commit_changelog():
    last_tag = get_last_git_tag()
    git_log = get_chronological_git_log(last_tag)
    categories = get_sorted_categories(git_log)

    return get_changelog_string(categories)


def get_last_git_tag():
    return subprocess.run(
        ["git", "describe", "--abbrev=0", "--tags"], 
        capture_output=True
    ).stdout.decode().strip('\n')


def get_chronological_git_log(last_tag):
    # get array of the first line of the commit messages since last tag
    git_log = subprocess.run(
        ["git", "log", "--pretty=format:%s", f"{last_tag}..HEAD"],
        capture_output=True
    ).stdout.decode().split('\n')

    # reverse it so it's chronological
    git_log.reverse()
    return git_log


def get_sorted_categories(git_log):
    categories = {}
    for key_header in commit_keys_and_header:
        categories[key_header[0]] = []

    for line in git_log:
        for key in categories.keys():
            if f'[{key}]' in line:
                line = line.replace(f'[{key}]', '').strip()
                line = transform_lines_into_past_tense(line)
                categories[key].append(line)

    return categories


def transform_lines_into_past_tense(line):
    line = line.replace('Add', 'Added')
    line = line.replace('Fix', 'Fixed')
    line = line.replace('Mark', 'Marked')
    line = line.replace('Change', 'Changed')
    line = line.replace('Update', 'Updated')
    return line


def get_changelog_string(categories):
    changelog = ''
    for key_header in commit_keys_and_header:
        key = key_header[0]
        if len(categories[key]) > 0:
            header = key_header[1]
            changelog += header
            for line in categories[key]:
                changelog += f'* {line}\n'.replace('[', '\\[')
            changelog += '\n'

    return changelog


if __name__ == "__main__":
    print(get_commit_changelog())
