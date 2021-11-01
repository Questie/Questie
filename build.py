#!/usr/bin/env python3

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
addonDir = 'Questie'


def main():
    universal_version_dir, tbc_version_dir, era_version_dir = get_version_dirs()

    if os.path.isdir('releases/%s' % universal_version_dir):
        print("Warning: Folder already exists, removing!")
        shutil.rmtree('releases/%s' % universal_version_dir)

    release_folder_path = 'releases/%s' % universal_version_dir
    release_addon_folder_path = release_folder_path + ('/%s' % addonDir)
    questie_toc_path = release_addon_folder_path + '/Questie.toc'

    copy_content_to(release_addon_folder_path)

    zip_name = '%s-%s' % (addonDir, universal_version_dir)
    zip_release_folder(zip_name, universal_version_dir, addonDir)

    zip_name = '%s-%s' % (addonDir, era_version_dir)
    os.remove(questie_toc_path)
    os.rename(release_addon_folder_path + '/Questie-Classic.toc', questie_toc_path)
    zip_release_folder(zip_name, universal_version_dir, addonDir)

    zip_name = '%s-%s' % (addonDir, tbc_version_dir)
    os.remove(questie_toc_path)
    os.rename(release_addon_folder_path + '/Questie-BCC.toc', questie_toc_path)
    zip_release_folder(zip_name, universal_version_dir, addonDir)

    print('New release "%s" created successfully' % universal_version_dir)


def get_version_dirs():
    version, nr_of_commits, recent_commit = get_git_information()
    print("Tag: " + version)
    tbc_version_dir = "%s-tbc-%s" % (version, recent_commit)
    era_version_dir = "%s-era-%s" % (version, recent_commit)
    universal_version_dir = "%s-%s" % (version, recent_commit)

    print("Number of commits since tag: " + nr_of_commits)
    print("Most Recent commit: " + recent_commit)
    branch = get_branch()
    if branch != "master":
        tbc_version_dir += "-%s" % branch
    print("Current branch: " + branch)

    return universal_version_dir, tbc_version_dir, era_version_dir


directoriesToSkip = ['.git', '.github', '.history', '.idea', '.vscode', 'ExternalScripts(DONOTINCLUDEINRELEASE)', 'releases']
filesToSkip = ['.gitattributes', '.gitignore', '.luacheckrc', 'build.py', 'changelog.py', 'cli.lua', '.DS_Store']


def copy_content_to(release_folder_path):
    for _, directories, files in os.walk('.'):
        for directory in directories:
            if directory not in directoriesToSkip:
                shutil.copytree(directory, '%s/%s' % (release_folder_path, directory))
        for file in files:
            if file not in filesToSkip:
                shutil.copy2(file, '%s/%s' % (release_folder_path, file))
        break


def zip_release_folder(zip_name, version_dir, addon_dir):
    root = os.getcwd()
    os.chdir('releases/%s' % version_dir)
    print("Zipping %s" % zip_name)
    shutil.make_archive(zip_name, "zip", ".", addon_dir)
    os.chdir(root)


def get_git_information():
    if is_tool("git"):
        script_dir = os.path.dirname(os.path.realpath(__file__))
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
