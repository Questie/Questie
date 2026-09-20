"""Offline provider-note tests. Run with: uv run --no-project changelog.test.py."""
import contextlib
import copy
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import changelog


class QuestieDBChangelogTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.path = Path(temporary.name) / "questiedb-release.json"
        self.manifest = {
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
        return changelog.load_questiedb_manifest(self.path)

    def test_existing_questie_output_is_unchanged_and_database_follows_it(self):
        self.load()
        questie_notes = "## General Fixes\n\n* Fixed an existing Questie issue.\n\n"
        with patch.object(changelog, "get_commit_changelog", return_value=questie_notes):
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                changelog.main(["--questiedb-manifest", str(self.path)])
            self.assertTrue(output.getvalue().startswith(questie_notes + "\n\n## QuestieDB 1.0.1\n"))
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                changelog.main([])
            self.assertEqual(questie_notes + "\n", output.getvalue())

    def test_producer_and_entry_links_are_distinct_and_credits_keep_author_order(self):
        notes = changelog.get_questiedb_changelog(self.load())
        commit_url = "https://github.com/Questie/QuestieDB/commit/"
        self.assertIn(f"Database build: [aaaaaaa]({commit_url}{'a' * 40})", notes)
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
        notes = changelog.get_questiedb_changelog(self.load())
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
        notes = changelog.get_questiedb_changelog(self.load())
        self.assertIn("- Add a new location.", notes)
        self.assertNotIn("Added a new location", notes)
        self.assertLess(notes.index("### New Features"), notes.index("### Database Fixes"))
        self.assertLess(notes.index("Zebra entry"), notes.index("Alphabetical entry"))
        self.assertEqual(1, notes.count("### Database Fixes"))

    def test_empty_and_older_changelogs_keep_only_version_and_producer_information(self):
        for entries in ([], None):
            with self.subTest(entries=entries):
                manifest = copy.deepcopy(self.manifest)
                if entries is None:
                    del manifest["changelog"]
                else:
                    manifest["changelog"] = entries
                notes = changelog.get_questiedb_changelog(self.load(manifest))
                self.assertEqual(
                    "## QuestieDB 1.0.1\n\nDatabase build: [aaaaaaa]"
                    f"(https://github.com/Questie/QuestieDB/commit/{'a' * 40})\n\n", notes,
                )

    def test_preview_versions_unknown_fields_and_manifest_key_order_are_supported(self):
        self.manifest["version"] = "1.0.2-dev.abcdef0"
        self.manifest["newProviderField"] = {"future": True}
        self.manifest["artifacts"][0]["rawBytes"] = 999
        manifest = dict(reversed(list(self.manifest.items())))
        notes = changelog.get_questiedb_changelog(self.load(manifest))
        self.assertIn("## QuestieDB 1.0.2-dev.abcdef0", notes)
        self.assertIn("Correct quest prerequisites.", notes)

    def test_rejects_unsafe_package_identity(self):
        for field, value in (
            ("version", "../1.0.1"), ("version", None), ("producerCommit", "short"),
        ):
            with self.subTest(field=field, value=value):
                manifest = dict(self.manifest, **{field: value})
                with self.assertRaises(ValueError):
                    self.load(manifest)

    def test_rendering_requires_a_changelog_array(self):
        self.manifest["changelog"] = {}
        with self.assertRaisesRegex(ValueError, "changelog must be an array"):
            changelog.get_questiedb_changelog(self.load())

    def test_rejects_malformed_changelog_entries(self):
        for field, value in (
            ("text", ""), ("author", None),
            ("commit", "short"), ("coAuthors", "not an array"), ("coAuthors", [None]),
        ):
            with self.subTest(field=field, value=value):
                manifest = copy.deepcopy(self.manifest)
                manifest["changelog"][0][field] = value
                with self.assertRaises(ValueError):
                    changelog.get_questiedb_changelog(self.load(manifest))


if __name__ == "__main__":
    unittest.main()
