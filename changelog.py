#!/usr/bin/env python3

import subprocess
import sys

# define the tags that should be shown and their order
commit_keys_and_header = (
    ('feature', '## New Features\n\n'),
    ('fix', '## General Fixes\n\n'),
    ('quest', '## Quest Fixes\n\n'),
    ('db', '## Database Fixes\n\n'),
    ('locale', '## Localization Fixes\n\n'),
)

def is_python_36():
    return sys.version_info.major == 3 and sys.version_info.minor >= 6

def get_commit_changelog():
    last_tag = get_last_git_tag()
    git_log = get_chronological_git_log(last_tag)
    categories = get_sorted_categories(git_log)

    contributors = get_contributors(last_tag)

    return get_changelog_string(categories, contributors)


def get_last_git_tag():
    return subprocess.run(
        ["git", "describe", "--tags", "--abbrev=0", "HEAD^"],
        **({"stdout": subprocess.PIPE, "stderr": subprocess.PIPE} if is_python_36() else {"capture_output": True, })
    ).stdout.decode().strip('\n')


def get_chronological_git_log(last_tag):
    # get array of the first line of the commit messages since last tag
    git_log = subprocess.run(
        ["git", "log", "--pretty=format:%s", f"{last_tag}..HEAD"],
        **({"stdout": subprocess.PIPE, "stderr": subprocess.PIPE} if is_python_36() else {"capture_output": True, })
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
            if line.startswith(f'[{key}]'):
                line = line.replace(f'[{key}]', '').strip()
                line = transform_lines_into_past_tense(line)
                categories[key].append(line)
            elif line.startswith(f'[{key.capitalize()}]'):
                line = line.replace(f'[{key.capitalize()}]', '').strip()
                line = transform_lines_into_past_tense(line)
                categories[key].append(line)

    for key in categories.keys():
        categories[key].sort()

    return categories


def replace_start(line, a, b):
    if line.strip().startswith(a):
        return line.replace(a, b)
    else:
        return line

def transform_lines_into_past_tense(line):
    line = replace_start(line, 'Add ', 'Added ')
    line = replace_start(line, 'Fix ', 'Fixed ')
    line = replace_start(line, 'Mark ', 'Marked ')
    line = replace_start(line, 'Improve ', 'Improved ')
    line = replace_start(line, 'Change ', 'Changed ')
    line = replace_start(line, 'Update ', 'Updated ')
    line = replace_start(line, 'Blacklist ', 'Blacklisted ')
    line = replace_start(line, 'Remove ', 'Removed ')
    return line

def get_contributors(last_tag):
    log_output = subprocess.run(
        ["git", "log", f"{last_tag}..HEAD", "--pretty=format:%an"],
        **({"stdout": subprocess.PIPE, "stderr": subprocess.PIPE} if is_python_36() else {"capture_output": True, })
    ).stdout.decode().strip().split('\n')

    # Remove duplicates
    contributors = set(log_output)

    return contributors


def get_changelog_string(categories, contributors):
    changelog = '## Contributors\n\n'

    for contributor in contributors:
        changelog += f'{contributor}, '
    changelog = changelog[:-2] + '\n\n'

    for key_header in commit_keys_and_header:
        key = key_header[0]
        if len(categories[key]) > 0:
            header = key_header[1]
            changelog += header
            for line in categories[key]:
                changelog += f'* {line}\n'.replace('\\[', '[')
            changelog += '\n'

    return changelog


if __name__ == "__main__":
    print(get_commit_changelog())
