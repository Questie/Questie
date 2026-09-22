"""Offline provider-note tests. Run with: python3 changelog.test.py."""
import contextlib
import copy
import io
import json
import os
from pathlib import Path
import tempfile
import unittest
import subprocess
from unittest.mock import patch

import changelog


class QuestieDBChangelogTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.path = Path(temporary.name) / "release.json"
        self.manifest = {
            "repository": "https://github.com/Questie/QuestieDB",
            "producerCommit": "a" * 40,
            "questieCommit": "b" * 40,
            "version": "1.0.1",
            "contractVersion": 2,
            "minSupportedContract": 1,
            "artifacts": [{"file": "QuestieDB-all.zip", "sha256": "c" * 64, "bytes": 123}],
            "changelog": [{
                "category": "db", "text": "Correct quest prerequisites.", "commit": "d" * 40,
                "author": "Muehe", "coAuthors": ["Logonz", "Another author"],
            }],
        }

    def load(self, manifest=None):
        self.path.write_text(json.dumps(self.manifest if manifest is None else manifest), encoding="utf-8")
        return json.loads(self.path.read_text(encoding="utf-8"))

    def test_manifest_notes_use_both_retained_sections_without_git_or_network(self):
        questie = copy.deepcopy(self.manifest)
        questie.update(repository="https://github.com/Questie/Questie", version="12.0.0", producerCommit="e" * 40)
        questie["changelog"][0]["text"] = "Retained Questie change."
        for combined in (False, True):
            with self.subTest(combined=combined):
                manifest = {"releases": [], "questie": questie}
                if combined:
                    manifest["questiedb"] = self.manifest
                self.load(manifest)
                output = io.StringIO()
                with patch.object(changelog.subprocess, "run") as run, patch.object(changelog.subprocess, "check_output") as git:
                    with patch("urllib.request.urlopen") as network, contextlib.redirect_stdout(output):
                        changelog.main(["--release-manifest", str(self.path)])
                    network.assert_not_called()
                    run.assert_not_called()
                    git.assert_not_called()
                notes = output.getvalue()
                self.assertTrue(notes.startswith("## Questie 12.0.0"))
                self.assertIn("Retained Questie change.", notes)
                self.assertIn("https://github.com/Questie/Questie/commit/" + "e" * 40, notes)
                self.assertEqual(combined, "## QuestieDB 1.0.1" in notes)

    def test_no_argument_changelog_remains_unchanged(self):
        questie_notes = "## General Fixes\n\n* Fixed an existing Questie issue.\n\n"
        with patch.object(changelog, "get_commit_changelog", return_value=questie_notes):
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                changelog.main([])
            self.assertEqual(questie_notes + "\n", output.getvalue())

    def test_producer_and_entry_links_are_distinct_and_credits_keep_author_order(self):
        notes = changelog.get_addon_changelog("QuestieDB", self.load())
        commit_url = "https://github.com/Questie/QuestieDB/commit/"
        self.assertIn(f"Build: [aaaaaaa]({commit_url}{'a' * 40})", notes)
        self.assertIn("### Database Fixes\n\n- Correct quest prerequisites.", notes)
        self.assertIn(
            f"([Muehe]({commit_url}{'d' * 40}), [Logonz]({commit_url}{'d' * 40}), "
            f"[Another author]({commit_url}{'d' * 40}))", notes,
        )
        self.assertNotIn("b" * 40, notes)
        self.assertNotIn("@Muehe", notes)

    def test_credit_names_are_literal_text_not_markdown_or_html(self):
        self.manifest["changelog"][0]["author"] = "A [link](url) <img src=x>"
        self.manifest["changelog"][0]["coAuthors"] = ["*bold*_name`code`\\path\nsecond line"]
        notes = changelog.get_addon_changelog("QuestieDB", self.load())
        self.assertIn(r"[A \[link\]\(url\) &lt;img src=x&gt;]", notes)
        self.assertIn(r"[\*bold\*\_name\`code\`\\path second line]", notes)
        self.assertNotIn("<img", notes)

    def test_supplied_wording_and_order_are_not_transformed_or_resorted(self):
        entry = self.manifest["changelog"][0]
        self.manifest["changelog"] = [
            dict(entry, category="feature", text="Add a new location."),
            dict(entry, text="Zebra entry first."),
            dict(entry, text="Alphabetical entry second."),
        ]
        notes = changelog.get_addon_changelog("QuestieDB", self.load())
        self.assertIn("- Add a new location.", notes)
        self.assertNotIn("Added a new location", notes)
        self.assertLess(notes.index("### New Features"), notes.index("### Database Fixes"))
        self.assertLess(notes.index("Zebra entry"), notes.index("Alphabetical entry"))
        self.assertEqual(1, notes.count("### Database Fixes"))
        self.assertRegex(notes, r"- Add a new location\.[^\n]*\n\n### Database Fixes")
        self.assertRegex(notes, r"- Zebra entry first\.[^\n]*\n- Alphabetical entry second\.")
        self.assertTrue(notes.endswith("\n\n"))

    def test_empty_and_older_changelogs_keep_only_version_and_producer_information(self):
        for entries in ([], None):
            with self.subTest(entries=entries):
                manifest = copy.deepcopy(self.manifest)
                if entries is None:
                    del manifest["changelog"]
                else:
                    manifest["changelog"] = entries
                notes = changelog.get_addon_changelog("QuestieDB", self.load(manifest))
                self.assertEqual(
                    "## QuestieDB 1.0.1\n\nBuild: [aaaaaaa]"
                    f"(https://github.com/Questie/QuestieDB/commit/{'a' * 40})\n\n", notes,
                )

    def test_preview_versions_unknown_fields_and_manifest_key_order_are_supported(self):
        self.manifest["version"] = "1.0.2-dev.abcdef0"
        self.manifest["newProviderField"] = {"future": True}
        self.manifest["artifacts"][0]["rawBytes"] = 999
        manifest = dict(reversed(list(self.manifest.items())))
        notes = changelog.get_addon_changelog("QuestieDB", self.load(manifest))
        self.assertIn("## QuestieDB 1.0.2-dev.abcdef0", notes)
        self.assertIn("Correct quest prerequisites.", notes)

    def test_rejects_unsafe_commit_links(self):
        for field, value in (
            ("producerCommit", "short"), ("repository", "http://github.com/Questie/QuestieDB"),
            ("repository", "https://github.com/Questie/QuestieDB/"),
            ("repository", "https://name@github.com/Questie/QuestieDB"),
            ("repository", "https://github.com/Questie/QuestieDB) [link](bad"),
        ):
            with self.subTest(field=field, value=value):
                manifest = dict(self.manifest, **{field: value})
                with self.assertRaises(ValueError):
                    changelog.get_addon_changelog("QuestieDB", manifest)

    def test_local_producer_sentinel_is_not_linked_but_entry_sentinel_is_rejected(self):
        self.manifest["producerCommit"] = "0" * 40
        notes = changelog.get_addon_changelog("QuestieDB", self.manifest)
        self.assertIn("Build commit unavailable", notes)
        self.assertNotIn("0" * 40, notes)
        self.manifest["changelog"][0]["commit"] = "0" * 40
        with self.assertRaisesRegex(ValueError, "invalid commit"):
            changelog.get_addon_changelog("QuestieDB", self.manifest)

    def test_rendering_requires_a_changelog_array(self):
        self.manifest["changelog"] = {}
        with self.assertRaisesRegex(ValueError, "changelog must be an array"):
            changelog.get_addon_changelog("QuestieDB", self.load())

    def test_rejects_malformed_changelog_entries(self):
        for field, value in (
            ("text", ""), ("author", None),
            ("commit", "short"), ("coAuthors", "not an array"), ("coAuthors", [None]),
        ):
            with self.subTest(field=field, value=value):
                manifest = copy.deepcopy(self.manifest)
                manifest["changelog"][0][field] = value
                with self.assertRaises(ValueError):
                    changelog.get_addon_changelog("QuestieDB", self.load(manifest))


class ReleaseTagTests(unittest.TestCase):
    def test_full_questie_notes_survive_database_only_bundle_releases(self):
        with tempfile.TemporaryDirectory() as temporary:
            original_directory = Path.cwd()
            self.addCleanup(os.chdir, original_directory)
            os.chdir(temporary)

            def git(*args):
                subprocess.run(["git", "-c", "user.name=Test", "-c", "user.email=test@example.org", *args],
                               check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

            git("init", "-q")
            git("commit", "--allow-empty", "-qm", "Previous release")
            git("tag", "v11.0.0")
            git("commit", "--allow-empty", "-qm", "[fix] Fix old issue")
            self.assertEqual("v11.0.0", changelog.get_last_git_tag())
            self.assertEqual(["Fixed old issue"], [entry["text"] for entry in changelog.get_changelog_entries()])

            git("tag", "bundle/v11.0.0+v1.1.0")
            git("commit", "--allow-empty", "-qm", "[fix] Fix new issue")
            git("tag", "bundle/v12.0.0-pre.abc1234+v1.1.0")
            git("commit", "--allow-empty", "-qm", "Prepare release")
            self.assertEqual("bundle/v11.0.0+v1.1.0", changelog.get_last_git_tag())
            entries = changelog.get_changelog_entries()
            self.assertEqual(["Fixed new issue"], [entry["text"] for entry in entries])

            git("tag", "bundle/v12.0.0+v1.1.0")
            self.assertEqual(entries, changelog.get_changelog_entries())
            git("tag", "bundle/v12.0.0+v1.2.0")
            self.assertEqual(entries, changelog.get_changelog_entries())
            os.chdir(original_directory)


class QuestieEntriesTests(unittest.TestCase):
    def test_capture_reuses_categories_wording_and_order_with_real_author_credits(self):
        records = [
            ("a" * 40, "Primary Author", "[fix] Fix zebra", "Some body\n\nCo-authored-by: Other Author <other@example.org>\n"),
            ("b" * 40, "Second Author", "[feature] Add something", ""),
            ("c" * 40, "Third Author", "[Fix] Fix alphabet", ""),
            ("d" * 40, "Ignored Author", "Unmarked work", ""),
        ]
        log = "".join("\0".join(record) + "\0" for record in records)
        with patch.object(changelog, "get_last_git_tag", return_value="v11.0.0"):
            with patch.object(changelog.subprocess, "check_output", return_value=log) as git:
                entries = changelog.get_changelog_entries()
        self.assertEqual("v11.0.0..HEAD", git.call_args.args[0][-1])
        self.assertEqual(["Added something", "Fixed alphabet", "Fixed zebra"], [entry["text"] for entry in entries])
        self.assertEqual({"category": "fix", "text": "Fixed zebra", "commit": "a" * 40,
                          "author": "Primary Author", "coAuthors": ["Other Author"]}, entries[-1])
        self.assertNotIn("example.org", json.dumps(entries))

    def test_empty_history_has_no_invented_changes_and_git_errors_propagate(self):
        with patch.object(changelog, "get_last_git_tag", return_value=""):
            with patch.object(changelog.subprocess, "check_output", return_value="") as git:
                self.assertEqual([], changelog.get_changelog_entries())
                self.assertEqual("HEAD", git.call_args.args[0][-1])
            with patch.object(changelog.subprocess, "check_output", side_effect=subprocess.CalledProcessError(1, "git")):
                with self.assertRaises(subprocess.CalledProcessError):
                    changelog.get_changelog_entries()


if __name__ == "__main__":
    unittest.main()
