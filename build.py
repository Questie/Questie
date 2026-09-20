#!/usr/bin/env python3

import os
import shutil
import subprocess
import sys
import fileinput
import re

"""
This program accepts optional command line options:

    -r
    --release
        Do not include commit hash and branch name in directory/zip/version names
    -a
    --all
        Included files for all expansions
    -c
    --classic
        Include Classic/Era files
    -t
    --tbc
        Include TBC files
    -w
    --wotlk
        Include WotLK files

    -ca
    --cata
        Include Cata files

    -m
    --mop
        Include MoP files

    -v <versionString>
    --version <versionString>
        Disregard git and toc versions, and use <versionString> instead

"""
addonDir = "Questie"
includedExpansions = []
tocs = ["", "Questie_Vanilla.toc", "Questie_TBC.toc", "Questie_Wrath.toc", "Questie_Cata.toc", "Questie_Mists.toc"]
dbTocs = ["", "QuestieDB_Vanilla.toc", "QuestieDB_TBC.toc", "QuestieDB_Wrath.toc", "QuestieDB_Cata.toc", "QuestieDB_Mists.toc"]

def main():
    # Reject declaration drift before naming or replacing any build outputs.
    get_required_db_contract(tocs[1:])
    isReleaseBuild = False
    versionOverride = ""
    if len(sys.argv) > 1:
        ver = False
        for arg in sys.argv[1:]:
            if ver:
                versionOverride = arg
                ver = False
            elif arg in ["-r", "--release"]:
                isReleaseBuild = True
                print("Creating a release build")
            elif arg in ["-v", "--version"]:
                ver = True
            elif arg in ["-a", "--all"]:
                if 1 not in includedExpansions:
                    includedExpansions.append(1)
                if 2 not in includedExpansions:
                    includedExpansions.append(2)
                if 3 not in includedExpansions:
                    includedExpansions.append(3)
                if 4 not in includedExpansions:
                    includedExpansions.append(4)
                if 5 not in includedExpansions:
                    includedExpansions.append(5)
            elif arg in ["-c", "--classic"] and 1 not in includedExpansions:
                includedExpansions.append(1)
            elif arg in ["-t", "--tbc"] and 2 not in includedExpansions:
                includedExpansions.append(2)
            elif arg in ["-w", "--wotlk"] and 3 not in includedExpansions:
                includedExpansions.append(3)
            elif arg in ["-ca", "--cata"] and 4 not in includedExpansions:
                includedExpansions.append(4)
            elif arg in ["-m", "--mop"] and 5 not in includedExpansions:
                includedExpansions.append(5)
    if len(includedExpansions) == 0:
        # If expansions go online/offline their major version needs to be added/removed here
        includedExpansions.append(1)
        includedExpansions.append(2)
        includedExpansions.append(3)
        includedExpansions.append(5)

    release_dir = get_version_dir(isReleaseBuild, versionOverride)

    if os.path.isdir("releases/%s" % release_dir):
        print("Warning: Folder already exists, removing!")
        shutil.rmtree("releases/%s" % release_dir)

    release_folder_path = "releases/%s" % release_dir
    release_addon_folder_path = release_folder_path + ("/tmp/%s" % addonDir)

    copy_content_to(release_addon_folder_path)
    copy_db_content_to(release_folder_path + "/tmp")
    dbVersion, dbHash = get_db_version(release_folder_path + "/tmp/QuestieDB/")
    print("DB version:", dbVersion, dbHash)

    if versionOverride != "":
        for tocN in includedExpansions:
            toc = tocs[tocN]
            questie_toc_path = release_addon_folder_path + "/" + toc
            with fileinput.FileInput(questie_toc_path, inplace=True) as file:
                for line in file:
                    if line[:10] == "## Version":
                        print("## Version: " + versionOverride)
                    else:
                        print(line, end="")

    zip_name = "%s-%s" % (addonDir, release_dir)
    zip_release_folder(zip_name, release_dir, isReleaseBuild, dbVersion, dbHash)

    interface_classic = get_interface_versions()
    interface_bcc = get_interface_versions("TBC")
    interface_wotlk = get_interface_versions("Wrath")
    interface_cata = get_interface_versions("Cata")
    interface_mop = get_interface_versions("Mists")

    def flavor_entries(flavor, versions):
        result = ""
        for v in versions:
            result += """
                {
                    "flavor": "%s",
                    "interface": %s
                },""" % (flavor, v)
        return result

    flavorString = ""
    if 1 in includedExpansions:
        flavorString += flavor_entries("classic", interface_classic)
    if 2 in includedExpansions:
        flavorString += flavor_entries("bcc", interface_bcc)
    if 3 in includedExpansions:
        flavorString += flavor_entries("wrath", interface_wotlk)
    if 4 in includedExpansions:
        flavorString += flavor_entries("cata", interface_cata)
    if 5 in includedExpansions:
        flavorString += flavor_entries("mists", interface_mop)

    with open(release_folder_path + "/release.json", "w") as rf:
        rf.write("""{
    "releases": [
        {
            "filename": "%s.zip",
            "nolib": false,
            "metadata": [%s
            ]
        }
    ]
}""" % (zip_name, flavorString[:-1]))

    print("New release '%s' created successfully" % release_dir)


def get_required_db_contract(toc_paths: list[str]) -> int:
    """Return the shared provider requirement, rejecting missing, duplicate, or inconsistent declarations."""
    required = None
    for path in toc_paths:
        with open(path, encoding="utf-8") as source:
            declarations = re.findall(
                r"^##[ \t]*X-QuestieDB-Contract:[ \t]*(.*)$", source.read(), re.MULTILINE | re.IGNORECASE
            )
        if len(declarations) != 1 or not re.fullmatch(r"[1-9][0-9]*", declarations[0].strip()):
            raise ValueError(f"{path}: expected one positive integer X-QuestieDB-Contract")
        value = int(declarations[0].strip())
        if required is not None and value != required:
            raise ValueError(f"{path}: X-QuestieDB-Contract {value} differs from {required} in the other TOCs")
        required = value
    if required is None:
        raise ValueError("No Questie TOCs supplied for contract validation")
    return required


def get_version_dir(is_release_build, versionOverride):
    version, nr_of_commits, recent_commit = get_git_information()
    if versionOverride != "":
        version = versionOverride
    print("Tag: " + version)
    if is_release_build:
        release_dir = "%s" % version
    else:
        release_dir = "%s-%s" % (version, recent_commit)

    print("Number of commits since tag: " + nr_of_commits)
    print("Most Recent commit: " + recent_commit)
    branch = get_branch()
    if branch != "master" and branch != "HEAD" and versionOverride == "" and not is_release_build:
        release_dir += "-%s" % branch
    print("Current branch: " + branch)

    return release_dir

def get_db_version(dbPath):
    with open(dbPath + dbTocs[includedExpansions[0]], "r") as toc:
        match = re.search("## Version: (.*?)\n.*?## X-BUILD-COMMIT: (.*?)\n", toc.read(), re.DOTALL)
        return match.group(1), match.group(2)

directoriesToInclude = ["Database", "Icons", "Libs", "Localization", "Modules", "Public"]
filesToInclude = ["Bindings.xml", "embeds.xml", "Questie.lua", "Questie.toc", "README.md", "README_ES.md", "README_CN.md"]
expansionStrings = ["", "Classic", "TBC", "Wotlk", "Cata", "MoP"]
ignorePatterns = ["*.test.lua"]


def copy_content_to(release_folder_path):
    for i in [1, 2, 3, 4, 5]:
        if i in includedExpansions:
            filesToInclude.append(tocs[i])
        else:
            ignorePatterns.append(f"{expansionStrings[i]}")

    for _, directories, files in os.walk("."):
        for directory in directories:
            if directory in directoriesToInclude:
                shutil.copytree(directory, "%s/%s" % (release_folder_path, directory), ignore=shutil.ignore_patterns(*ignorePatterns))
        for file in files:
            if file in filesToInclude:
                shutil.copy2(file, "%s/%s" % (release_folder_path, file))
        break

def copy_db_content_to(release_folder_path, useLocal=False):
    if useLocal:
        dbPath = "../QuestieDB"
        # TODO add manual file copy from local repo
    else:
        from urllib.request import urlretrieve
        zipPath = release_folder_path + '/QuestieDB-all.zip'
        urlretrieve('https://github.com/Questie/QuestieDB/releases/latest/download/QuestieDB-all.zip', zipPath)
        shutil.unpack_archive(zipPath, release_folder_path)
        os.remove(zipPath)

def zip_release_folder(zip_name, version_dir, is_release_build, dbVersion, dbHash):
    root = os.getcwd()
    os.chdir("releases/%s" % version_dir)
    print("Creating %s.zip" % zip_name)
    shutil.make_archive(zip_name, "zip", "tmp/Questie", ".")
    dbZipName = "%s+v%s" % (zip_name, dbVersion)
    if not is_release_build:
        dbZipName += "-%s" % dbHash[:9]
    print("Creating %s.zip" % dbZipName)
    shutil.make_archive(dbZipName, "zip", "tmp", ".")
    shutil.rmtree("tmp")
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


def get_interface_versions(expansion="Vanilla"):
    with open("Questie_%s.toc" % expansion, "r") as toc:
        match = re.match("## Interface: (.*?)\n", toc.read(), re.DOTALL)
        return [v.strip() for v in match.group(1).split(",")]


def is_tool(name):
    """Check whether `name` is on PATH and marked as executable."""
    return shutil.which(name) is not None


if __name__ == "__main__":
    main()
