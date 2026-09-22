#!/usr/bin/env python3
"""Generate announcement Markdown (for example, for Discord) between published GitHub releases."""

import argparse
import json
import re
import subprocess

import changelog


def gh_json(*args):
    """Use the existing GitHub CLI authentication; all callers perform read-only requests."""
    return json.loads(subprocess.check_output(["gh", *args], text=True))


def load_release(repository: str, tag: str) -> dict:
    """Resolve latest once, then download that GitHub release's manifest."""
    if tag == "latest":
        tag = gh_json("api", f"repos/{repository}/releases/latest")["tag_name"]
    return gh_json("release", "download", "--repo", repository,
                   "--pattern", "release.json", "--output", "-", "--", tag)


def component_changes(name: str, before: dict, after: dict) -> str:
    """Compare exact producer commits, including changes from skipped component releases."""
    repository = after["repository"]
    match = re.fullmatch(r"https://github.com/([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)", repository)
    if not match or before["repository"] != repository:
        raise ValueError(f"{name}: both manifests must identify the same GitHub repository")
    base, head = before["producerCommit"], after["producerCommit"]
    for commit in (base, head):
        if not re.fullmatch(r"[0-9a-fA-F]{40}", commit) or commit == "0" * 40:
            raise ValueError(f"{name}: comparison requires real producerCommit SHAs")
    if base == head:
        return ""

    # Pagination matters when an announcement skips several releases.
    pages = gh_json("api", "--paginate", "--slurp",
                    f"repos/{match[1]}/compare/{base}...{head}?per_page=100")
    if pages[0]["status"] != "ahead":
        raise ValueError(f"{name}: the target commit must descend from the starting commit")
    commits = [commit for page in pages for commit in page["commits"]]
    if len(commits) != pages[0]["total_commits"]:
        raise ValueError(f"{name}: GitHub returned an incomplete commit range")

    # Keep supplied wording/credits where available. Marked Git subjects fill gaps
    # from intermediate releases that the target manifest no longer describes.
    retained = after.get("changelog", [])
    covered = {entry["commit"] for entry in retained}
    categories = dict(changelog.commit_keys_and_header)
    entries = []
    for commit in commits:
        if commit["sha"] in covered:
            continue
        message = commit["commit"]["message"]
        subject = message.splitlines()[0]
        marker = re.match(r"^\[([^]]+)\]\s*(.+)$", subject)
        if not marker or marker[1].lower() not in categories:
            continue
        entries.append({
            "category": marker[1].lower(), "text": marker[2], "commit": commit["sha"],
            "author": commit["commit"]["author"]["name"] or "Contributor",
            "coAuthors": re.findall(r"^Co-authored-by:[ \t]*(.*?)[ \t]*<[^>\r\n]+>[ \t]*$",
                                    message, re.MULTILINE | re.IGNORECASE),
        })
    included = {commit["sha"] for commit in commits}
    entries.extend(entry for entry in retained if entry["commit"] in included)
    order = list(categories)
    entries.sort(key=lambda entry: order.index(entry["category"]))

    notes = changelog.get_addon_changelog(name, {
        **after, "version": f"{before['version']} → {after['version']}", "changelog": entries,
    })
    if not entries:
        notes += "No changelog entries were marked in this range.\n\n"
    return notes + f"[All commits]({repository}/compare/{base}...{head})\n"


def release_changes(before: dict, after: dict) -> str:
    """Render each changed component; require matching component sets rather than guessing a baseline."""
    components = set(after) - {"releases"}
    if not components or components != set(before) - {"releases"}:
        raise ValueError("Both release.json files must contain the same addon sections")
    sections = []
    for component in sorted(components):
        name = {"questie": "Questie", "questiedb": "QuestieDB"}.get(component, component)
        notes = component_changes(name, before[component], after[component])
        if notes:
            sections.append(notes)
    return "\n".join(sections) if sections else "No component source changes.\n"


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("from_tag", help="Starting GitHub release tag (excluded)")
    parser.add_argument("to_tag", nargs="?", default="latest", help="Ending GitHub release tag; defaults to latest stable")
    parser.add_argument("--repo", default="Questie/Questie", help="Repository containing the bundle releases")
    args = parser.parse_args(argv)
    try:
        before = load_release(args.repo, args.from_tag)
        after = load_release(args.repo, args.to_tag)
        print(release_changes(before, after), end="")
    except (ValueError, KeyError, OSError, subprocess.CalledProcessError) as error:
        parser.exit(1, f"Cannot generate release notes: {error}\n")


if __name__ == "__main__":
    main()
