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

                    Default: Version string from the toc file, e.g. '4.0.10_BETA'

-a addonDir         Overwrites the default addon name with the provided string so
                    the directory name, toc name, and path references in the code
                    can be updated.

                    Default: 'Questie'

Example usage:

'python build.py -v 5.0.0 -a QuestieDev-featureX'

This will create a new release in 'releases/5.0.0/QuestieDev-featureX', unless
the '5.0.0' directory already exists.

'''

def setArgs():
    # set defaults
    versionDir = getVersion().replace(' ', '_')
    addonDir = 'Questie'
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
        pos += 1
    return versionDir, addonDir

def main():
    # check dependencies
    if not shutil.which('7z'):
        raise RuntimeError('7z not in PATH')
    # set up pathes and handle command line arguments
    versionDir, addonDir = setArgs()
    # check that nothing is overwritten
    if os.path.isdir('releases/%s' % (versionDir)):
        raise RuntimeError('The directory releases/%s already exists' % (versionDir))
    # define release folder
    destination = 'releases/%s/%s' % (versionDir, addonDir)
    # copy directories
    for dir in ['Database', 'Icons', 'Libs', 'Locale', 'Modules']:
        shutil.copytree(dir, '%s/%s' % (destination, dir))
    # copy files
    for file in ['embeds.xml', 'Questie.lua', 'README.md']:
        shutil.copy2(file, '%s/%s' % (destination, file))
    shutil.copy2('QuestieDev-master.toc', '%s/%s.toc' % (destination, addonDir))
    # replace path references
    for file in ['QuestieComms.lua', 'QuestieFramePool.lua']:
        replacePath('%s/Modules/%s' % (destination, file), 'QuestieDev-master', addonDir)
    # package files
    root = os.getcwd()
    os.chdir('releases/%s' % (versionDir))
    with open(os.devnull, 'w') as fp:
        if subprocess.run(['7z', 'a', '-tzip', 'Questie-v%s.zip' % (versionDir), addonDir], stdout=fp).returncode != 0:
            raise RuntimeError('Error while packaging release')
    os.chdir(root)
    print('New release "%s" created successfully' % (versionDir))

def getVersion():
    with open('QuestieDev-master.toc') as toc:
        result = re.search('## Version: (.*?)\n', toc.read(), re.DOTALL)
    if result:
        return result.group(1)
    else:
        raise RuntimeError('toc file or version number not found')

def replacePath(filePath, oldPath, newPath):
    with open(filePath, 'r') as file:
        content = file.read()
    with open(filePath, 'w') as file:
        file.write(content.replace(oldPath, newPath))

if __name__ == "__main__":
    main()
