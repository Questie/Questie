#!/usr/bin/env python3
import argparse
import html
import json
import re
import subprocess
import sys

QUESTIE_REPOSITORY = "https://github.com/Questie/Questie"
# Any TOC works: build.py stamps the same version on all of them.
VERSION_TOC = "Questie_Vanilla.toc"

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


def get_changelog_entries(tag_from=None, tag_to="HEAD"):
    """Capture current Questie changes and author credits for the packaged manifest."""
    if not tag_from:
        last_tag = get_last_git_tag() or ""
        if last_tag != "": last_tag += ".."
    revision = f"{tag_from}..{tag_to}" if tag_from else f"{last_tag}{tag_to}"
    # NUL-separated fields preserve multiline commit bodies and author display names.
    log = subprocess.check_output(
        ["git", "log", "--reverse", "-z", "--format=%H%x00%an%x00%s%x00%b", revision], text=True
    )
    fields = log.split("\0")[:-1]
    entries = []
    for offset in range(0, len(fields), 4):
        commit, author, subject, body = fields[offset:offset + 4]
        coauthors = re.findall(r"^Co-authored-by:[ \t]*(.*?)[ \t]*<[^>\r\n]+>[ \t]*$", body, re.MULTILINE | re.IGNORECASE)
        # Reuse Questie's marked categories and wording transforms, not rendered Markdown.
        for category, texts in get_sorted_categories([subject]).items():
            for text in texts:
                entries.append({
                    "category": category, "text": text, "commit": commit,
                    "author": author or "Contributor", "coAuthors": coauthors,
                })
    order = [category for category, _ in commit_keys_and_header]
    entries.sort(key=lambda entry: (order.index(entry["category"]), entry["text"]))
    return entries


def get_questie_manifest(version, tag_from=None, tag_to="HEAD"):
    """Describe Questie the way release.json does, so builds and local previews render identically."""
    return {
        "repository": QUESTIE_REPOSITORY,
        "version": version,
        "producerCommit": subprocess.check_output(["git", "rev-parse", "--verify", f"{tag_to}^{{commit}}"], text=True).strip(),
        "changelog": get_changelog_entries(tag_from, tag_to),
    }


def get_toc_version(revision):
    # Older commits may predate this TOC, so fall back to naming the revision itself.
    try:
        toc = subprocess.check_output(["git", "show", f"{revision}:{VERSION_TOC}"], text=True, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        return revision
    match = re.search(r"^## Version: (.*?)\s*$", toc, re.MULTILINE)
    return match.group(1) if match else revision


def get_last_git_tag():
    # Tags on this source commit must not erase its notes when rebundling with a newer database.
    # Start before HEAD and ignore prereleases; legacy v* releases remain valid baselines.
    return subprocess.run(
        ["git", "describe", "--tags", "--match", "bundle/v*", "--match", "v*", "--exclude", "*-pre.*", "--abbrev=0", "HEAD^"],
        **({"stdout": subprocess.PIPE, "stderr": subprocess.PIPE} if is_python_36() else {"capture_output": True, })
    ).stdout.decode().strip('\n')


def get_sorted_categories(git_log):
    categories = {}
    for key_header in commit_keys_and_header:
        categories[key_header[0]] = []

    for line in git_log:
        for key in categories.keys():
            line = line.strip()
            if line.startswith(f'[{key}]'):
                line = line.replace(f'[{key}]', '').strip()
                line = transform_lines_into_past_tense(line)
                categories[key].append(line)
            elif line.startswith(f'[{key.capitalize()}]'):
                line = line.replace(f'[{key.capitalize()}]', '').strip()
                line = transform_lines_into_past_tense(line)
                categories[key].append(line)

    for key in categories.keys():
        categories[key] = sorted(set(categories[key]))

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


def _escape_markdown(text):
    # Credits are display text, not Markdown, HTML, or GitHub usernames.
    if not isinstance(text, str) or not text.strip():
        raise ValueError("Release notes need nonempty display text")
    text = html.escape(text, quote=False).replace("\r", " ").replace("\n", " ")
    return re.sub(r"([\\`*_\[\]()~])", r"\\\1", text)


def get_addon_changelog(name, manifest):
    """Render retained addon changes in their supplied order, without rewriting their wording.

    Identical text within a category becomes one line that credits everyone who made that change.
    """
    repository = manifest["repository"]
    # Repositories form Markdown link targets. Reject credentials, query strings and markup.
    if not re.fullmatch(r"https://[A-Za-z0-9.-]+/[A-Za-z0-9._-]+(?:/[A-Za-z0-9._-]+)+", repository):
        raise ValueError("Expected a canonical HTTPS repository URL without a trailing slash")
    commit_url = repository + "/commit/"
    producer = manifest["producerCommit"]
    if not isinstance(producer, str) or not re.fullmatch(r"[0-9a-fA-F]{40}", producer):
        raise ValueError("Release metadata has an invalid producerCommit")
    result = f"## {name} {_escape_markdown(manifest['version'])}\n\n"
    if producer == "0" * 40:
        result += "Build commit unavailable (local build without Git history).\n\n"
    else:
        result += f"Build: [{producer[:7]}]({commit_url}{producer})\n\n"
    headings = dict(commit_keys_and_header)
    # Missing or empty entries leave version/build information, not a claim that nothing changed.
    entries = manifest.get("changelog", [])
    if not isinstance(entries, list):
        raise ValueError("Addon changelog must be an array")
    # Merge when rendering, not when capturing: release_notes.py needs every commit in the manifest
    # to know which ones it already describes.
    credits_by_line = {}
    for entry in entries:
        commit = entry["commit"]
        if not isinstance(commit, str) or not re.fullmatch(r"[0-9a-fA-F]{40}", commit) or commit == "0" * 40:
            raise ValueError("Addon changelog has an invalid commit")
        coauthors = entry["coAuthors"]
        if not isinstance(coauthors, list):
            raise ValueError("Addon changelog coAuthors must be an array")
        credits = credits_by_line.setdefault((entry["category"], _escape_markdown(entry["text"])), {})
        for author in [entry["author"], *coauthors]:
            author = _escape_markdown(author)
            credits.setdefault(author, f"[{author}]({commit_url}{commit})")
    previous_category = None
    for (category, text), credits in credits_by_line.items():
        heading = headings[category]
        if category != previous_category:
            if previous_category is not None:
                result += "\n"
            result += "#" + heading
            previous_category = category
        result += f"- {text} ({', '.join(credits.values())})\n"
    if entries:
        result += "\n"
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description="Render release notes from Git history or a packaged release.json.")
    parser.add_argument("--release-manifest", help="Render retained component metadata without Git or network access")
    parser.add_argument("-f", "--from_pointer", help="Changelog from this commit/pointer (default: last tag before HEAD)")
    parser.add_argument("-t", "--to_pointer", default="HEAD", help="Changelog to this commit/pointer (default: HEAD)")
    args = parser.parse_args(argv)
    if args.release_manifest:
        with open(args.release_manifest, encoding="utf-8") as source:
            manifest = json.load(source)
    else:
        version = get_toc_version(args.to_pointer)
        manifest = {"questie": get_questie_manifest(version, args.from_pointer, args.to_pointer)}
    # The two components keep independent identities. Questie's changes always come first.
    print(get_addon_changelog("Questie", manifest["questie"]))
    if "questiedb" in manifest:
        print(get_addon_changelog("QuestieDB", manifest["questiedb"]))


if __name__ == "__main__":
    main()
