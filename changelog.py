#!/usr/bin/env python3

import subprocess
import sys

'''
This program accepts optional command line options:

    -p
    --pipeline
        Generate a changelog fit for the GitHub pipeline. This escapes " and '
'''

# define the tags that should be shown and their order
commit_keys_and_header = (
    ('feature', '## New Features\n\n'),
    ('fix', '## General Fixes\n\n'),
    ('quest', '## Quest Fixes\n\n'),
    ('db', '## Database Fixes\n\n'),
    ('locale', '## Localization Fixes\n\n'),
)

is_pipeline_run = False

def is_python_36():
    return sys.version_info.major == 3 and sys.version_info.minor >= 6

def get_commit_changelog():
    global is_pipeline_run
    for arg in sys.argv[1:]:
        if arg in ['-p', '--pipeline']:
            is_pipeline_run = True

    last_tag = get_last_git_tag()
    git_log = get_chronological_git_log(last_tag)
    categories = get_sorted_categories(git_log)

    return get_changelog_string(categories)


def get_last_git_tag():
    return subprocess.run(
        ["git", "describe", "--abbrev=0", "--tags"], 
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
            if f'[{key}]' in line:
                line = line.replace(f'[{key}]', '').strip()
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
    line = replace_start(line, 'Change ', 'Changed ')
    line = replace_start(line, 'Update ', 'Updated ')
    line = replace_start(line, 'Blacklist ', 'Blacklisted ')
    line = replace_start(line, 'Remove ', 'Removed ')
    return line


def get_changelog_string(categories):
    global is_pipeline_run
    changelog = ''
    for key_header in commit_keys_and_header:
        key = key_header[0]
        if len(categories[key]) > 0:
            header = key_header[1]
            changelog += header
            for line in categories[key]:
                line = line.replace('\\[', '[')
                if is_pipeline_run:
                    line = line.replace('"', '\\"').replace('\'', '\\\'')
                changelog += f'* {line}\n'
            changelog += '\n'

    return changelog


if __name__ == "__main__":
    print(get_commit_changelog())
