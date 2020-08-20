#!/usr/bin/env python3

import sys
import re
import os
import shutil
import subprocess

'''
This program accepts two command line options:

-v versionDir       Overwrites the default version with the provided string so
                    the release will be placed under 'releases/versionDir'.

                    Since the script aborts if a release folder already exists,
                    it is recommended to use this option for test releases, e.g.:
                    build.py -v someFeature

                    Default: Version string from the toc file, e.g. '4.0.10_BETA'

-a addonDir         Overwrites the default addon name with the provided string so
                    the directory name, toc name, and path references in the code
                    can be updated.

                    This affects the addon directory and the .toc file.

                    Default: 'Questie'

-z zipName          If provided, replaces the default zip name.

                    Default: 'Questie-v' plus the version string from the toc
                    file, e.g.: 'Questie-v4.1.1'

-r releaseType      If provided changes the releasetype from BETA, (Release/Alpha etc)

                    Default: ''

Example usage:

'python build.py -v 5.0.0 -a QuestieDev-featureX'

This will create a new release in 'releases/5.0.0/QuestieDev-featureX', unless
the '5.0.0' directory already exists.

'''
releaseType = ''
addonDir = 'Questie'
versionDir = None

def setArgs():
    #set defaults
    global releaseType
    global addonDir
    global versionDir
    version, nrOfCommits, recentCommit = getVersion()
    print("Tag: " + version)
    if version != None and nrOfCommits == None and recentCommit == None:
        versionDir = version.replace(' ', '_')
        zipName = '%s-v%s' % (addonDir, versionDir)
    else:
        if releaseType:
            versionDir = "%s_%s-%s-%s" % (version, releaseType, nrOfCommits, recentCommit)
        else:
            versionDir = "%s_%s-%s" % (version, nrOfCommits, recentCommit)

        print("Number of commits since tag: " + nrOfCommits)
        print("Most Recent commit: " + recentCommit)
        branch = getBranch()
        if branch != "master":
            versionDir += "-%s" % branch
        print("Current branch: " + branch)
        zipName = '%s-%s' % (addonDir, versionDir)

    # overwrite with command line arguments, if provided
    pos = 1
    end = len(sys.argv)
    while(pos < end):
        if (sys.argv[pos] == '-v'):
            pos += 1
            versionDir = sys.argv[pos]
        elif (sys.argv[pos] == '-a'):
            pos += 1
            addonDir = sys.argv[pos]
        elif (sys.argv[pos] == '-z'):
            pos += 1
            zipName = sys.argv[pos]
        elif (sys.argv[pos] == '-r'):
            pos += 1
            releaseType = sys.argv[pos]
        pos += 1
    return versionDir, addonDir, zipName

def main():
    # Setup pre-commit script.
    setHookfolder()
    # set up pathes and handle command line arguments
    versionDir, addonDir, zipName = setArgs()
    # check that nothing is overwritten
    if os.path.isdir('releases/%s' % (versionDir)):
        print("Warning: Folder already exists, removing!")
        shutil.rmtree('releases/%s' % (versionDir))
        #raise RuntimeError('The directory releases/%s already exists' % (versionDir))
    # define release folder
    destination = 'releases/%s/%s' % (versionDir, addonDir)
    # copy directories
    for dir in ['Database', 'Icons', 'Libs', 'Locale', 'Modules']:
        shutil.copytree(dir, '%s/%s' % (destination, dir))
    # copy files
    for file in ['embeds.xml', 'Questie.lua', 'README.md']:
        shutil.copy2(file, '%s/%s' % (destination, file))
    shutil.copy2('QuestieDev-master.toc', '%s/%s.toc' % (destination, addonDir))
    # modify toc
    setVersion()
    # replace path references
    for file in ['Network/QuestieComms.lua', 'Libs/QuestieLib.lua']:
        replacePath('%s/Modules/%s' % (destination, file), 'QuestieDev-master', addonDir)
    # package files
    root = os.getcwd()
    os.chdir('releases/%s' % (versionDir))
    shutil.make_archive(zipName, "zip", ".", addonDir)
    os.chdir(root)
    print('New release "%s" created successfully' % (versionDir))

def setVersion():
    if is_tool("git"):
        global addonDir
        global releaseType
        global versionDir
        scriptDir = os.path.dirname(os.path.realpath(__file__))
        p = subprocess.check_output(["git", "describe", "--tags", "--long"], cwd=scriptDir)
        tagString = str(p).rstrip("\\n'").lstrip("b'")
        #versiontag (v4.1.1) from git, number of additional commits on top of the tagged object and most recent commit.
        versionTag, nrOfCommits, recentCommit = tagString.split("-")
        recentCommit = recentCommit.lstrip("g") # There is a "g" before all the commits.
        tocData = None
        cleanData = None
        readmeData = None
        # Replace the toc data with git information.
        with open('QuestieDev-master.toc') as toc:
            tocData = toc.read()
            cleanData = tocData;
            ## Version: 4.1.1 BETA
            tocData = re.sub(r"## Title:.*", "## Title: |cFFFFFFFF%s|r|cFF00FF00 %s_%s|r" % (addonDir, versionTag, recentCommit), tocData)
            ## Title: |cFFFFFFFFQuestie|r|cFF00FF00 v4.1.1|r|cFFFF0000 Beta|r
            cleanData = re.sub(r"\d+\.\d+\.\d+", versionTag.lstrip("v"), cleanData)
            tocData = re.sub(r"## Version:.*", "## Version: %s %s %s" % (versionTag.lstrip("v"), nrOfCommits, recentCommit), tocData)

        with open('releases/%s/%s/%s.toc' % (versionDir, addonDir, addonDir), "w") as toc:
            toc.write(tocData)
        
        with open("README.md") as readme:
            readmeData = readme.read()
            readmeData = re.sub(r"QuestieDev\/(.+)\/total\.svg", "QuestieDev/%s/total.svg" % versionTag, readmeData)

        with open('README.md', "w") as readme:
            readme.write(readmeData)

        with open('QuestieDev-master.toc', "w") as toc:
            toc.write(cleanData)

def setHookfolder():
    if is_tool("git"):
        scriptDir = os.path.dirname(os.path.realpath(__file__))
        p = subprocess.check_output(["git", "config", "core.hooksPath", ".githooks"], cwd=scriptDir)

def getVersion():
    if is_tool("git"):
        scriptDir = os.path.dirname(os.path.realpath(__file__))
        p = subprocess.check_output(["git", "describe", "--tags", "--long"], cwd=scriptDir)
        tagString = str(p).rstrip("\\n'").lstrip("b'")
        #versiontag (v4.1.1) from git, number of additional commits on top of the tagged object and most recent commit.
        versionTag, nrOfCommits, recentCommit = tagString.split("-")
        recentCommit = recentCommit.lstrip("g") # There is a "g" before all the commits.
        return versionTag, nrOfCommits, recentCommit
    else:
        print("Warning: Git not found on the computer, using fallback to get a version.")

    with open('QuestieDev-master.toc') as toc:
        result = re.search('## Version: (.*?)\n', toc.read(), re.DOTALL)
    if result:
        return result.group(1), None, None
    else:
        raise RuntimeError('toc file or version number not found')

def getBranch():
    if is_tool("git"):
        scriptDir = os.path.dirname(os.path.realpath(__file__))
        #git rev-parse --abbrev-ref HEAD
        p = subprocess.check_output(["git", "rev-parse", "--abbrev-ref", "HEAD"], cwd=scriptDir)
        branch = str(p).rstrip("\\n'").lstrip("b'")
        return branch


def replacePath(filePath, oldPath, newPath):
    with open(filePath, 'r') as file:
        content = file.read()
    with open(filePath, 'w') as file:
        file.write(content.replace(oldPath, newPath))

def is_tool(name):
    """Check whether `name` is on PATH and marked as executable."""
    return shutil.which(name) is not None

if __name__ == "__main__":
    main()
