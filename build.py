#!/usr/bin/env python3

import sys
import re
import os
import shutil
import subprocess

'''
This program accepts one optional command line option:

interfaceVersion    If provided sets the interface version to the Classic or TBC version

                    Default: 'tbc'

Example usage:

'python build.py classic'

This will create a new Classic release in 'releases/<version>-classic-<latestCommit>'

'''
interfaceVersion = 'tbc'
addonDir = 'Questie'
versionDir = None


def main():
    version_dir, addon_dir, zip_name = get_args()

    if os.path.isdir('releases/%s' % version_dir):
        print("Warning: Folder already exists, removing!")
        shutil.rmtree('releases/%s' % version_dir)

    release_folder_path = 'releases/%s/%s' % (version_dir, addon_dir)

    copy_content_to(release_folder_path)
    set_toc_version()
    zip_release_folder(zip_name, version_dir, addon_dir)

    print('New release "%s" created successfully' % version_dir)


def get_args():
    global interfaceVersion
    global addonDir
    global versionDir

    if len(sys.argv) > 1:
        interfaceVersion = sys.argv[1]

    version, nr_of_commits, recent_commit = get_git_information()
    print("Tag: " + version)
    versionDir = "%s-%s-%s" % (version, interfaceVersion, recent_commit)

    print("Number of commits since tag: " + nr_of_commits)
    print("Most Recent commit: " + recent_commit)
    branch = get_branch()
    if branch != "master":
        versionDir += "-%s" % branch
    print("Current branch: " + branch)
    zip_name = '%s-%s' % (addonDir, versionDir)

    return versionDir, addonDir, zip_name


def set_toc_version():
    if is_tool("git"):
        global addonDir
        global interfaceVersion
        global versionDir

        # versiontag (v4.1.1) from git, number of additional commits on top of the tagged object and most recent commit.
        version_tag, nr_of_commits, recent_commit = get_git_information()

        # Replace the toc data with git information.
        with open('Questie.toc') as toc:
            toc_data = toc.read()
            clean_data = toc_data

            if interfaceVersion == 'classic':
                toc_data = re.sub(r"## Interface:.*", "## Interface: 11307", toc_data)
            # ## Title: |cFFFFFFFFQuestie|r|cFF00FF00 v6.3.7|r
            toc_data = re.sub(r"## Title:.*", "## Title: |cFFFFFFFF%s|r|cFF00FF00 %s|r" % (addonDir, version_tag), toc_data)
            clean_data = re.sub(r"\d+\.\d+\.\d+", version_tag.lstrip("v"), clean_data)
            # ## Version: 6.3.7
            toc_data = re.sub(r"## Version:.*", "## Version: %s" % (version_tag.lstrip("v")), toc_data)

        with open('releases/%s/%s/%s.toc' % (versionDir, addonDir, addonDir), "w") as toc:
            toc.write(toc_data)

        with open('Questie.toc', "w") as toc:
            toc.write(clean_data)


def copy_content_to(release_folder_path):
    for directory in ['Database', 'Icons', 'Libs', 'Localization', 'Modules']:
        shutil.copytree(directory, '%s/%s' % (release_folder_path, directory))

    for file in ['embeds.xml', 'Questie.lua']:
        shutil.copy2(file, '%s/%s' % (release_folder_path, file))


def zip_release_folder(zip_name, version_dir, addon_dir):
    root = os.getcwd()
    os.chdir('releases/%s' % version_dir)
    shutil.make_archive(zip_name, "zip", ".", addon_dir)
    os.chdir(root)


def get_git_information():
    if is_tool("git"):
        script_dir = os.path.dirname(os.path.realpath(__file__))
        tag_string = ''
        p = subprocess.check_output(["git", "describe", "--tags", "--long"], cwd=script_dir, stderr=subprocess.STDOUT)
        tag_string = str(p).rstrip("\\n'").lstrip("b'")

        # versiontag (v4.1.1) from git, number of additional commits on top of the tagged object and most recent commit.
        version_tag, nr_of_commits, recent_commit = tag_string.rsplit("-", maxsplit=2)
        recent_commit = recent_commit.lstrip("g")  # There is a "g" before all the commits.
        return version_tag, nr_of_commits, recent_commit
    else:
        raise RuntimeError("Warning: Git not found on the computer, using fallback to get a version.")


def get_branch():
    if is_tool("git"):
        script_dir = os.path.dirname(os.path.realpath(__file__))
        # git rev-parse --abbrev-ref HEAD
        p = subprocess.check_output(["git", "rev-parse", "--abbrev-ref", "HEAD"], cwd=script_dir)
        branch = str(p).rstrip("\\n'").lstrip("b'")
        return branch


def is_tool(name):
    """Check whether `name` is on PATH and marked as executable."""
    return shutil.which(name) is not None


if __name__ == "__main__":
    main()
