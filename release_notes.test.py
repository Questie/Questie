"""Offline tests for changes between releases. Run with: python3 release_notes.test.py."""

import contextlib
import copy
import io
import subprocess
import unittest
from unittest.mock import call, patch

import release_notes


def component(repository, version, commit):
    return {"repository": "https://github.com/Questie/" + repository, "version": version,
            "producerCommit": commit * 40, "changelog": []}


def commit(sha, message):
    return {"sha": sha * 40, "commit": {"message": message, "author": {"name": "Primary author"}}}


class ReleaseNotesTests(unittest.TestCase):
    def setUp(self):
        self.before = {"releases": [], "questie": component("Questie", "12.0.0", "a"),
                       "questiedb": component("QuestieDB", "1.0.0", "b")}
        self.after = copy.deepcopy(self.before)
        self.after["questiedb"] = component("QuestieDB", "1.3.0", "e")

    def test_skipped_releases_include_all_pages_and_keep_supplied_notes(self):
        self.after["questiedb"]["changelog"] = [
            {"category": "db", "text": "Supplied 1.3 wording.", "commit": "e" * 40,
             "author": "Release author", "coAuthors": ["Release coauthor"]},
            {"category": "db", "text": "Outside this comparison.", "commit": "b" * 40,
             "author": "Old author", "coAuthors": []},
        ]
        pages = [
            {"status": "ahead", "total_commits": 3, "commits": [commit("c", "[db] Intermediate 1.1 correction.")]},
            {"status": "ahead", "total_commits": 3, "commits": [
                commit("d", "[DB] Intermediate 1.2 correction.\n\nCo-authored-by: Other author <other@example.org>"),
                commit("e", "[db] Raw 1.3 wording."),
            ]},
        ]
        with patch.object(release_notes, "gh_json", return_value=pages) as gh:
            notes = release_notes.release_changes(self.before, self.after)
        gh.assert_called_once_with("api", "--paginate", "--slurp",
                                   f"repos/Questie/QuestieDB/compare/{'b' * 40}...{'e' * 40}?per_page=100")
        self.assertIn("## QuestieDB 1.0.0 → 1.3.0", notes)
        for text in ("Intermediate 1.1 correction.", "Intermediate 1.2 correction.", "Supplied 1.3 wording.",
                     "[Other author]", "[Release author]", "[Release coauthor]"):
            self.assertIn(text, notes)
        for text in ("## Questie ", "Raw 1.3 wording", "Outside this comparison", "example.org"):
            self.assertNotIn(text, notes)
        self.assertIn(f"[All commits](https://github.com/Questie/QuestieDB/compare/{'b' * 40}...{'e' * 40})", notes)

    def test_questie_only_update_uses_questie_repository_and_omits_database(self):
        self.after = copy.deepcopy(self.before)
        self.after["questie"] = component("Questie", "12.1.0", "f")
        pages = [{"status": "ahead", "total_commits": 1, "commits": [commit("f", "[fix] Tracker correction.")]}]
        with patch.object(release_notes, "gh_json", return_value=pages) as gh:
            notes = release_notes.release_changes(self.before, self.after)
        self.assertIn(f"repos/Questie/Questie/compare/{'a' * 40}...{'f' * 40}", gh.call_args.args[-1])
        self.assertIn("## Questie 12.0.0 → 12.1.0", notes)
        self.assertNotIn("QuestieDB", notes)

    def test_same_commits_need_no_comparison_even_if_versions_changed(self):
        self.after = copy.deepcopy(self.before)
        self.after["questie"]["version"] = "12.0.1"
        with patch.object(release_notes, "gh_json") as gh:
            self.assertEqual("No component source changes.\n", release_notes.release_changes(self.before, self.after))
        gh.assert_not_called()

    def test_same_version_with_a_new_preview_commit_still_has_changes(self):
        self.after["questiedb"]["version"] = "1.0.0"
        pages = [{"status": "ahead", "total_commits": 1, "commits": [commit("e", "[db] Preview correction.")]}]
        with patch.object(release_notes, "gh_json", return_value=pages):
            notes = release_notes.release_changes(self.before, self.after)
        self.assertIn("Preview correction.", notes)

    def test_unmarked_commits_are_not_reported_as_no_source_changes(self):
        pages = [{"status": "ahead", "total_commits": 1, "commits": [commit("e", "Internal cleanup")]}]
        with patch.object(release_notes, "gh_json", return_value=pages):
            notes = release_notes.release_changes(self.before, self.after)
        self.assertIn("No changelog entries were marked in this range.", notes)
        self.assertIn("[All commits]", notes)
        self.assertNotIn("No component source changes", notes)

    def test_reverse_diverged_and_incomplete_ranges_fail_instead_of_printing_partial_notes(self):
        for status, total, message in (("behind", 0, "descend"), ("diverged", 1, "descend"), ("ahead", 2, "incomplete")):
            with self.subTest(status=status):
                pages = [{"status": status, "total_commits": total, "commits": [commit("e", "[db] Correction.")]}]
                with patch.object(release_notes, "gh_json", return_value=pages):
                    with self.assertRaisesRegex(ValueError, message):
                        release_notes.release_changes(self.before, self.after)

    def test_incompatible_manifests_fail_before_github_comparison(self):
        invalid = [copy.deepcopy(self.after) for _ in range(4)]
        invalid[0].pop("questiedb")
        invalid[1]["questiedb"]["repository"] = "https://github.com/Other/Database"
        invalid[2]["questiedb"]["producerCommit"] = "0" * 40
        invalid[3]["questiedb"]["producerCommit"] = "short"
        with patch.object(release_notes, "gh_json") as gh:
            for manifest in invalid:
                with self.subTest(manifest=manifest), self.assertRaises(ValueError):
                    release_notes.release_changes(self.before, manifest)
        gh.assert_not_called()

    def test_latest_is_resolved_once_then_its_exact_manifest_is_downloaded(self):
        with patch.object(release_notes, "gh_json", side_effect=[{"tag_name": "bundle/v12.0.0+v1.3.0"}, self.after]) as gh:
            self.assertEqual(self.after, release_notes.load_release("Questie/Questie", "latest"))
        self.assertEqual([
            call("api", "repos/Questie/Questie/releases/latest"),
            call("release", "download", "--repo", "Questie/Questie", "--pattern", "release.json", "--output", "-",
                 "--", "bundle/v12.0.0+v1.3.0"),
        ], gh.call_args_list)

    def test_cli_defaults_to_latest_and_prints_only_markdown(self):
        with patch.object(release_notes, "load_release", return_value=self.before) as load:
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                release_notes.main(["bundle/v12.0.0+v1.0.0"])
        self.assertEqual([call("Questie/Questie", "bundle/v12.0.0+v1.0.0"), call("Questie/Questie", "latest")], load.call_args_list)
        self.assertEqual("No component source changes.\n", output.getvalue())

    def test_github_failure_exits_without_partial_output(self):
        with patch.object(release_notes, "load_release", side_effect=subprocess.CalledProcessError(1, "gh")):
            output, errors = io.StringIO(), io.StringIO()
            with contextlib.redirect_stdout(output), contextlib.redirect_stderr(errors):
                with self.assertRaises(SystemExit) as exit:
                    release_notes.main(["v12.0.0"])
        self.assertEqual(1, exit.exception.code)
        self.assertEqual("", output.getvalue())
        self.assertIn("Cannot generate release notes", errors.getvalue())


if __name__ == "__main__":
    unittest.main()
