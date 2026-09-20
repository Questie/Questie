#!/usr/bin/env python3

"""
Each build writes one ZIP and a matching release.json with component metadata.
Standalone builds (the default) do not download QuestieDB; combined builds include it.

This program accepts optional command line options:

    --standalone
        Build Questie only (default); QuestieDB must be installed separately
    --combined
        Build Questie and QuestieDB together

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

import fileinput
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from typing import Iterable

import changelog


addonDir = "Questie"
includedExpansions = []
# Expansion settings shared by selection, packaging, and addon-manager metadata.
# Defaults apply only when no flavor is selected.
EXPANSIONS = {
    1: {
        "flags": ("-c", "--classic"),
        "toc_suffix": "Vanilla",
        "flavor": "classic",
        "default": True,
    },
    2: {
        "flags": ("-t", "--tbc"),
        "toc_suffix": "TBC",
        "flavor": "bcc",
        "default": True,
    },
    3: {
        "flags": ("-w", "--wotlk"),
        "toc_suffix": "Wrath",
        "flavor": "wrath",
        "default": True,
    },
    4: {
        "flags": ("-ca", "--cata"),
        "toc_suffix": "Cata",
        "flavor": "cata",
        "default": False,
    },
    5: {
        "flags": ("-m", "--mop"),
        "toc_suffix": "Mists",
        "flavor": "mists",
        "default": True,
    },
}
tocs = {}
dbTocs = {}
for number, expansion in EXPANSIONS.items():
    tocs[number] = f"Questie_{expansion['toc_suffix']}.toc"
    dbTocs[number] = f"QuestieDB_{expansion['toc_suffix']}.toc"

directoriesToInclude = ["Database", "Icons", "Libs", "Localization", "Modules", "Public"]
filesToInclude = ["Bindings.xml", "embeds.xml", "Questie.lua", "Questie.toc", "README.md", "README_ES.md", "README_CN.md"]
ignorePatterns = ["*.test.lua"]


def main():
    """Stage the selected addons, package one ZIP, and describe it in release.json."""
    # Reject declaration drift before naming or replacing any build outputs.
    get_required_db_contract(tocs.values())
    isReleaseBuild = False
    if "--standalone" in sys.argv and "--combined" in sys.argv:
        raise ValueError("Choose either --standalone or --combined")
    combined = "--combined" in sys.argv
    includedExpansions.clear()
    versionOverride = ""
    if len(sys.argv) > 1:
        expect_version = False
        for arg in sys.argv[1:]:
            if expect_version:
                versionOverride = arg
                expect_version = False
            elif arg in ["-r", "--release"]:
                isReleaseBuild = True
                print("Creating a release build")
            elif arg in ["-v", "--version"]:
                expect_version = True
            elif arg in ["-a", "--all"]:
                for number in EXPANSIONS:
                    if number not in includedExpansions:
                        includedExpansions.append(number)
            else:
                for number, expansion in EXPANSIONS.items():
                    if arg in expansion["flags"] and number not in includedExpansions:
                        includedExpansions.append(number)
    if not includedExpansions:
        for number, expansion in EXPANSIONS.items():
            if expansion["default"]:
                includedExpansions.append(number)

    # Rebuild this output directory from fresh staging; previous outputs are replaced.
    release_dir = get_version_dir(isReleaseBuild, versionOverride)

    if os.path.isdir("releases/%s" % release_dir):
        print("Warning: Folder already exists, removing!")
        shutil.rmtree("releases/%s" % release_dir)

    release_folder_path = "releases/%s" % release_dir
    release_addon_folder_path = release_folder_path + ("/tmp/%s" % addonDir)

    copy_content_to(release_addon_folder_path)

    # Standalone builds need no download. Combined builds verify the provider before bundling.
    dbManifest = None
    dbVersion, dbHash = None, None
    if combined:
        dbManifest = copy_db_content_to(release_folder_path + "/tmp")
        dbVersion, dbHash = get_db_version(release_folder_path + "/tmp/QuestieDB/")
        # Names and notes must describe the provider that was actually extracted.
        for expansion_id in includedExpansions:
            with open(release_folder_path + "/tmp/QuestieDB/" + dbTocs[expansion_id], encoding="utf-8") as toc:
                contents = toc.read()
            versions = re.findall(r"^## Version: (.*?)$", contents, re.MULTILINE)
            commits = re.findall(r"^## X-BUILD-COMMIT: (.*?)$", contents, re.MULTILINE)
            if versions != [dbManifest["version"]] or commits != [dbManifest["producerCommit"]]:
                raise ValueError("QuestieDB TOC does not match the downloaded manifest: " + dbTocs[expansion_id])
        print("DB version:", dbVersion, dbHash)

    # Stamp only staged Questie TOCs; source files and the provider version remain unchanged.
    if versionOverride != "":
        for expansion_id in includedExpansions:
            toc = tocs[expansion_id]
            questie_toc_path = release_addon_folder_path + "/" + toc
            with fileinput.FileInput(questie_toc_path, inplace=True) as file:
                for line in file:
                    if line[:10] == "## Version":
                        print("## Version: " + versionOverride)
                    else:
                        print(line, end="")

    with open(release_addon_folder_path + "/" + tocs[includedExpansions[0]], encoding="utf-8") as toc:
        questieVersion = re.search(r"^## Version: (.*?)$", toc.read(), re.MULTILINE).group(1)

    # Questie's identity is independent of build mode and the selected database.
    script_dir = os.path.dirname(os.path.realpath(__file__))
    questie = {
        "repository": "https://github.com/Questie/Questie",
        "version": questieVersion,
        "producerCommit": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=script_dir, text=True).strip(),
        "changelog": changelog.get_changelog_entries(),
    }
    # Archive creation removes staging. Write release metadata only after the ZIP succeeds.
    zip_name = "%s-%s" % (addonDir, release_dir)
    filename = zip_release_folder(zip_name, release_dir, isReleaseBuild, dbVersion, dbHash)

    # Advertise every declared interface for each selected flavor.
    metadata = []
    for expansion_id, expansion in EXPANSIONS.items():
        if expansion_id in includedExpansions:
            for interface in get_interface_versions(expansion["toc_suffix"]):
                metadata.append({"flavor": expansion["flavor"], "interface": int(interface)})

    release = {
        "releases": [{"filename": filename, "nolib": False, "metadata": metadata}],
        "questie": questie,
    }
    if combined:
        # Preserve upstream extensions and original artifact records without rewriting them.
        release["questiedb"] = dbManifest
    with open(release_folder_path + "/release.json", "w", encoding="utf-8") as result:
        json.dump(release, result, indent=4)
        result.write("\n")

    print("New release '%s' created successfully" % release_dir)


def get_required_db_contract(toc_paths: Iterable[str]) -> int:
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
    """Choose the output name from Git or an override, adding source details for development builds."""
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
    """Read the first selected provider TOC; main checks that every selected TOC agrees with its manifest."""
    with open(dbPath + dbTocs[includedExpansions[0]], "r") as toc:
        match = re.search("## Version: (.*?)\n.*?## X-BUILD-COMMIT: (.*?)\n", toc.read(), re.DOTALL)
        return match.group(1), match.group(2)


def copy_content_to(release_folder_path):
    """Copy runtime directories and selected root files, excluding tests without changing shared lists."""
    selected_files = list(filesToInclude)
    for number in EXPANSIONS:
        if number in includedExpansions:
            selected_files.append(tocs[number])

    for _, directories, files in os.walk("."):
        for directory in directories:
            if directory in directoriesToInclude:
                shutil.copytree(
                    directory, "%s/%s" % (release_folder_path, directory),
                    ignore=shutil.ignore_patterns(*ignorePatterns),
                )
        for file in files:
            if file in selected_files:
                shutil.copy2(file, "%s/%s" % (release_folder_path, file))
        break


def copy_db_content_to(release_folder_path):
    """Keep latest-stable selection, but verify its ZIP against one retained manifest."""
    from urllib.request import urlretrieve
    release_url = 'https://github.com/Questie/QuestieDB/releases/latest/download/'
    # The download is only an input. Its addon section is retained in our release.json.
    with tempfile.TemporaryDirectory(prefix="questiedb-manifest-") as temporary:
        manifest_path = os.path.join(temporary, "release.json")
        urlretrieve(release_url + 'release.json', manifest_path)
        with open(manifest_path, encoding="utf-8") as source:
            manifest = json.load(source)["questiedb"]
    # This version is used in the output filename, not just displayed in notes.
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+(?:[.-][A-Za-z0-9]+)*", manifest["version"]):
        raise ValueError("QuestieDB manifest has an invalid version")
    if not re.fullmatch(r"[0-9a-fA-F]{40}", manifest["producerCommit"]):
        raise ValueError("QuestieDB manifest has an invalid producerCommit")
    # Only this fixed filename is downloaded; unrelated artifact records are not consumed.
    artifacts = manifest["artifacts"]
    if not isinstance(artifacts, list):
        raise ValueError("QuestieDB manifest needs an artifacts array")
    archives = []
    for artifact in artifacts:
        if isinstance(artifact, dict) and artifact.get("file") == "QuestieDB-all.zip":
            archives.append(artifact)
    if len(archives) != 1:
        raise ValueError("Expected exactly one QuestieDB-all.zip artifact")
    archive = archives[0]
    zipPath = release_folder_path + '/QuestieDB-all.zip'
    urlretrieve(release_url + 'QuestieDB-all.zip', zipPath)

    # A release can change between downloads. Reject mixed generations before extraction.
    checksum = hashlib.sha256()
    with open(zipPath, "rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            checksum.update(block)
    if os.path.getsize(zipPath) != archive["bytes"] or checksum.hexdigest() != archive["sha256"].lower():
        raise ValueError("QuestieDB archive checksum or size does not match its manifest")
    shutil.unpack_archive(zipPath, release_folder_path)
    os.remove(zipPath)
    return manifest


def zip_release_folder(zip_name, version_dir, is_release_build, dbVersion=None, dbHash=None):
    """Write one ZIP, remove successful staging, and restore the caller's working directory.

    A database version selects the combined two-addon layout; otherwise Questie's
    files remain at the archive root, matching the existing standalone layout.
    """
    root = os.getcwd()
    os.chdir("releases/%s" % version_dir)
    try:
        archive_root = "tmp/Questie"
        if dbVersion is not None:
            zip_name += "+v" + dbVersion
            if not is_release_build:
                zip_name += "-" + dbHash[:9]
            archive_root = "tmp"
        print("Creating %s.zip" % zip_name)
        shutil.make_archive(zip_name, "zip", archive_root, ".")
        shutil.rmtree("tmp")
    finally:
        os.chdir(root)
    return zip_name + ".zip"


def get_git_information():
    """Return the nearest tag, commit count, and short SHA. Git is required; no fallback is implemented."""
    if is_tool("git"):
        script_dir = os.path.dirname(os.path.realpath(__file__))
        output = subprocess.check_output(["git", "describe", "--tags", "--long"], cwd=script_dir, stderr=subprocess.STDOUT)
        tag_string = str(output).rstrip("\\n'").lstrip("b'")

        # Split from the right because version tags themselves can contain hyphens.
        version_tag, nr_of_commits, recent_commit = tag_string.rsplit("-", maxsplit=2)
        recent_commit = recent_commit.lstrip("g")  # There is a "g" before all the commits.
        return version_tag, nr_of_commits, recent_commit
    else:
        raise RuntimeError("Warning: Git not found on the computer, using fallback to get a version.")


def get_branch():
    """Read the branch used in development output names, or HEAD for a detached checkout."""
    if is_tool("git"):
        script_dir = os.path.dirname(os.path.realpath(__file__))
        output = subprocess.check_output(["git", "rev-parse", "--abbrev-ref", "HEAD"], cwd=script_dir)
        branch = str(output).rstrip("\\n'").lstrip("b'")
        return branch


def get_interface_versions(expansion):
    """Read every interface version from the source TOC for this flavor suffix."""
    with open("Questie_%s.toc" % expansion, "r") as toc:
        match = re.match("## Interface: (.*?)\n", toc.read(), re.DOTALL)
        return [v.strip() for v in match.group(1).split(",")]


def is_tool(name):
    """Check whether `name` is on PATH and marked as executable."""
    return shutil.which(name) is not None


if __name__ == "__main__":
    main()
