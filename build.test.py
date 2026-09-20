"""Offline tests for release build preflight. Run with: python3 build.test.py."""
import json
import hashlib
import shutil
import os
from pathlib import Path
import tempfile
import unittest
import zipfile
from unittest.mock import patch

import build
import changelog


class ContractRequirementTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)

    def write_toc(self, name: str, text: str) -> str:
        path = self.root / name
        path.write_text(text, encoding="utf-8")
        return str(path)

    def test_reads_requirement_instead_of_hardcoding_current_contract(self):
        first = self.write_toc("Classic.toc", "## X-QuestieDB-Contract: 3\n")
        second = self.write_toc("Mists.toc", "## X-QuestieDB-Contract: 3\n")
        self.assertEqual(3, build.get_required_db_contract([first, second]))

    def test_rejects_missing_or_malformed_requirement(self):
        for value in ("", "0", "-1", "1.5", "2e0", "02", "two"):
            with self.subTest(value=value):
                path = self.write_toc("Questie.toc", "## X-QuestieDB-Contract: " + value + "\n")
                with self.assertRaisesRegex(ValueError, "positive integer X-QuestieDB-Contract"):
                    build.get_required_db_contract([path])
        path = self.write_toc("Questie.toc", "## Version: 1.0.0\n")
        with self.assertRaisesRegex(ValueError, "positive integer X-QuestieDB-Contract"):
            build.get_required_db_contract([path])

    def test_rejects_duplicate_requirement(self):
        path = self.write_toc("Questie.toc", "## X-QuestieDB-Contract: 2\n## X-QuestieDB-Contract: 2\n")
        with self.assertRaisesRegex(ValueError, "expected one"):
            build.get_required_db_contract([path])

    def test_metadata_keys_are_case_insensitive_like_the_client(self):
        path = self.write_toc("Questie.toc", "## x-questiedb-contract: 3\n")
        self.assertEqual(3, build.get_required_db_contract([path]))

    def test_rejects_case_insensitive_duplicate_requirement(self):
        path = self.write_toc("Questie.toc", "## X-QuestieDB-Contract: 2\n## x-questiedb-contract: 3\n")
        with self.assertRaisesRegex(ValueError, "expected one"):
            build.get_required_db_contract([path])

    def test_rejects_disagreement_between_flavors(self):
        first = self.write_toc("Classic.toc", "## X-QuestieDB-Contract: 2\n")
        second = self.write_toc("Mists.toc", "## X-QuestieDB-Contract: 3\n")
        with self.assertRaisesRegex(ValueError, "differs from 2"):
            build.get_required_db_contract([first, second])

    def test_rejects_invalid_metadata_before_touching_build_outputs(self):
        path = self.write_toc("Questie.toc", "## Version: 1.0.0\n")
        with patch.object(build, "tocs", ["", path]), patch.object(build.shutil, "rmtree") as remove:
            with self.assertRaisesRegex(ValueError, "X-QuestieDB-Contract"):
                build.main()
            remove.assert_not_called()

    def test_committed_tocs_declare_one_requirement_and_load_compatibility_check(self):
        root = Path(__file__).resolve().parent
        paths = [str(root / toc) for toc in build.tocs[1:]]
        self.assertGreater(build.get_required_db_contract(paths), 0)
        for path in paths:
            with self.subTest(toc=path):
                lines = Path(path).read_text(encoding="utf-8").splitlines()
                self.assertIn("## RequiredDeps: QuestieDB", lines)
                self.assertLess(lines.index("Modules\\VersionCheckDB.lua"), lines.index("Modules\\QuestieInit.lua"))


class BuildResultTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        original_directory = Path.cwd()
        os.chdir(self.root)
        self.addCleanup(os.chdir, original_directory)
        for name in build.tocs[1:]:
            (self.root / name).write_text(
                "## Interface: 11508\n## Version: 11.39.0\n## X-QuestieDB-Contract: 2\n",
                encoding="utf-8",
            )
        (self.root / "Modules").mkdir()
        (self.root / "Modules/example.lua").write_text("return {}\n", encoding="utf-8")
        for name, value in (
            ("includedExpansions", []),
            ("filesToInclude", list(build.filesToInclude)),
            ("ignorePatterns", list(build.ignorePatterns)),
        ):
            self.enterContext(patch.object(build, name, value))
        self.enterContext(patch.object(build, "get_git_information", return_value=("v11.38.0", "2", "abc123def")))
        self.enterContext(patch.object(build, "get_branch", return_value="staticdb-cd"))
        self.provider_zip = self.root / "provider.zip"
        with zipfile.ZipFile(self.provider_zip, "w") as archive:
            archive.writestr("QuestieDB/" + build.dbTocs[1],
                             "## Version: 1.0.0\n## X-BUILD-COMMIT: " + "a" * 40 + "\n")
        self.provider_manifest = {
            "version": "1.0.0", "producerCommit": "a" * 40, "questieCommit": "b" * 40,
            "contractVersion": 2, "minSupportedContract": 1,
            "artifacts": [{"file": "QuestieDB-all.zip", "bytes": self.provider_zip.stat().st_size,
                           "sha256": hashlib.sha256(self.provider_zip.read_bytes()).hexdigest()},
                          {"file": "../other-format.tar", "sha256": {"future": True}, "bytes": None}],
            "changelog": [{"category": "db", "text": "Correct quest prerequisites.",
                           "commit": "c" * 40, "author": "Muehe", "coAuthors": ["Logonz"]}],
        }
        self.downloads = self.enterContext(patch("urllib.request.urlretrieve", side_effect=self.download_provider))

    def download_provider(self, url, destination):
        if url == "https://github.com/Questie/QuestieDB/releases/latest/download/release.json":
            Path(destination).write_text(json.dumps(self.provider_manifest), encoding="utf-8")
        elif url == "https://github.com/Questie/QuestieDB/releases/latest/download/QuestieDB-all.zip":
            shutil.copyfile(self.provider_zip, destination)
        else:
            self.fail("Unexpected download: " + url)

    def test_result_describes_the_generated_archives_and_packaged_versions(self):
        cases = (
            (["-r"], "v11.38.0", "11.39.0", ""),
            ([], "v11.38.0-abc123def-staticdb-cd", "11.39.0", "-aaaaaaaaa"),
            (["-r", "-v", "v12.0.0.alpha0"], "v12.0.0.alpha0", "v12.0.0.alpha0", ""),
        )
        for arguments, release_dir, questie_version, db_suffix in cases:
            with self.subTest(arguments=arguments), patch.object(build.sys, "argv", ["build.py", "-c", *arguments]):
                build.main()
                output = self.root / "releases" / release_dir
                result = json.loads((output / "build-result.json").read_text(encoding="utf-8"))
                self.assertEqual({
                    "questie_version": questie_version,
                    "questiedb_version": "1.0.0",
                    "standalone_zip": f"Questie-{release_dir}.zip",
                    "combined_zip": f"Questie-{release_dir}+v1.0.0{db_suffix}.zip",
                }, result)
                with zipfile.ZipFile(output / result["standalone_zip"]) as archive:
                    toc = archive.read(build.tocs[1]).decode("utf-8")
                    self.assertIn("## Version: " + result["questie_version"] + "\n", toc)
                with zipfile.ZipFile(output / result["combined_zip"]) as archive:
                    toc = archive.read("QuestieDB/" + build.dbTocs[1]).decode("utf-8")
                    self.assertIn("## Version: " + result["questiedb_version"] + "\n", toc)
                metadata = json.loads((output / "release.json").read_text())
                self.assertEqual(result["combined_zip"], metadata["releases"][0]["filename"])
                self.assertEqual(json.dumps(self.provider_manifest), (output / "questiedb-release.json").read_text())

    def test_selected_archive_must_be_unambiguous_before_download(self):
        archive = self.provider_manifest["artifacts"][0]
        for artifacts in ([], [archive, archive]):
            with self.subTest(artifacts=artifacts):
                self.provider_manifest["artifacts"] = artifacts
                self.downloads.reset_mock()
                with patch.object(build.sys, "argv", ["build.py", "-c", "-r"]):
                    with self.assertRaisesRegex(ValueError, "exactly one QuestieDB-all.zip"):
                        build.main()
                self.assertEqual(1, self.downloads.call_count)
                self.assertFalse((self.root / "releases/v11.38.0/build-result.json").exists())

    def test_checksum_or_size_mismatch_is_rejected_before_extraction_or_packaging(self):
        archive = self.provider_manifest["artifacts"][0]
        for field, value in (("sha256", "f" * 64), ("sha256", "not-a-checksum"), ("bytes", 1)):
            with self.subTest(field=field, value=value), patch.dict(archive, {field: value}):
                with patch.object(build.sys, "argv", ["build.py", "-c", "-r"]):
                    with patch.object(build.shutil, "unpack_archive") as extract:
                        with self.assertRaisesRegex(ValueError, "checksum or size"):
                            build.main()
                        extract.assert_not_called()
                self.assertFalse((self.root / "releases/v11.38.0/build-result.json").exists())

    def test_packaged_toc_must_agree_with_manifest_producer(self):
        self.provider_manifest["producerCommit"] = "d" * 40
        with patch.object(build.sys, "argv", ["build.py", "-c", "-r"]):
            with self.assertRaisesRegex(ValueError, "TOC does not match"):
                build.main()
        self.assertFalse((self.root / "releases/v11.38.0/build-result.json").exists())

    def test_notes_use_retained_manifest_even_after_latest_changes(self):
        with patch.object(build.sys, "argv", ["build.py", "-c", "-r"]):
            build.main()
        retained = self.root / "releases/v11.38.0/questiedb-release.json"
        self.provider_manifest["version"] = "9.0.0"
        self.provider_manifest["changelog"][0]["text"] = "An unrelated later release."
        notes = changelog.get_questiedb_changelog(changelog.load_questiedb_manifest(retained))
        self.assertIn("## QuestieDB 1.0.0", notes)
        self.assertIn("Correct quest prerequisites.", notes)
        self.assertNotIn("An unrelated later release", notes)
        self.assertEqual(2, self.downloads.call_count)

    def test_failed_packaging_does_not_write_a_build_result(self):
        with patch.object(build.sys, "argv", ["build.py", "-c", "-r"]):
            with patch.object(build.shutil, "make_archive", side_effect=OSError("archive failed")):
                with self.assertRaisesRegex(OSError, "archive failed"):
                    build.main()
        self.assertFalse((self.root / "releases/v11.38.0/build-result.json").exists())


if __name__ == "__main__":
    unittest.main()
