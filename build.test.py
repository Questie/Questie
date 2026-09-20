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
        with patch.object(build, "tocs", {1: path}), patch.object(build.shutil, "rmtree") as remove:
            with self.assertRaisesRegex(ValueError, "X-QuestieDB-Contract"):
                build.main()
            remove.assert_not_called()

    def test_committed_tocs_declare_one_requirement_and_load_compatibility_check(self):
        root = Path(__file__).resolve().parent
        paths = [str(root / toc) for toc in build.tocs.values()]
        self.assertGreater(build.get_required_db_contract(paths), 0)
        for path in paths:
            with self.subTest(toc=path):
                lines = Path(path).read_text(encoding="utf-8").splitlines()
                self.assertIn("## RequiredDeps: QuestieDB", lines)
                self.assertLess(lines.index("Modules\\VersionCheckDB.lua"), lines.index("Modules\\QuestieInit.lua"))


class BuildModeTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        original_directory = Path.cwd()
        os.chdir(self.root)
        self.addCleanup(os.chdir, original_directory)
        for name in build.tocs.values():
            (self.root / name).write_text(
                "## Interface: 11508, 11509\n## Version: 11.39.0\n## X-QuestieDB-Contract: 2\n",
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
        self.enterContext(patch.object(build.subprocess, "check_output", return_value="e" * 40 + "\n"))
        self.questie_entries = [{"category": "fix", "text": "Fixed a Questie issue.", "commit": "f" * 40,
                                 "author": "Questie author", "coAuthors": []}]
        self.enterContext(patch.object(changelog, "get_changelog_entries", return_value=self.questie_entries))
        self.provider_zip = self.root / "provider.zip"
        self.write_provider_zip()
        self.database = {
            "repository": "https://github.com/Questie/QuestieDB",
            "version": "1.0.0", "producerCommit": "a" * 40, "questieCommit": "b" * 40,
            "contractVersion": 2, "minSupportedContract": 1,
            "artifacts": [{"file": "QuestieDB-all.zip", "bytes": self.provider_zip.stat().st_size,
                           "sha256": hashlib.sha256(self.provider_zip.read_bytes()).hexdigest()},
                          {"file": "other-format.tar", "future": True}],
            "futureField": {"preserve": [1, 2]},
            "changelog": [{"category": "db", "text": "Correct quest prerequisites.",
                           "commit": "c" * 40, "author": "Muehe", "coAuthors": ["Logonz"]}],
        }
        self.provider_manifest = {"releases": [{"filename": "QuestieDB-all.zip"}], "questiedb": self.database}
        self.downloads = self.enterContext(patch("urllib.request.urlretrieve", side_effect=self.download_provider))

    def write_provider_zip(self, version="1.0.0"):
        with zipfile.ZipFile(self.provider_zip, "w") as archive:
            for name in build.dbTocs.values():
                archive.writestr("QuestieDB/" + name,
                                 "## Version: " + version + "\n## X-BUILD-COMMIT: " + "a" * 40 + "\n")

    def download_provider(self, url, destination):
        if url.endswith("/latest/download/release.json"):
            Path(destination).write_text(json.dumps(self.provider_manifest), encoding="utf-8")
        elif url.endswith("/latest/download/QuestieDB-all.zip"):
            shutil.copyfile(self.provider_zip, destination)
        else:
            self.fail("Unexpected download: " + url)

    def run_build(self, *arguments, directory="v11.38.0", selection=("-c",)):
        with patch.object(build.sys, "argv", ["build.py", *selection, *arguments]):
            build.main()
        output = self.root / "releases" / directory
        manifest = json.loads((output / "release.json").read_text())
        self.assertEqual({"release.json", manifest["releases"][0]["filename"]}, {p.name for p in output.iterdir()})
        return output, manifest

    def test_standalone_has_matching_metadata_without_a_provider_download(self):
        output, manifest = self.run_build("--standalone", "-r")
        self.downloads.assert_not_called()
        self.assertEqual({"releases", "questie"}, set(manifest))
        self.assertEqual("11.39.0", manifest["questie"]["version"])
        self.assertEqual("e" * 40, manifest["questie"]["producerCommit"])
        self.assertEqual(self.questie_entries, manifest["questie"]["changelog"])
        release = manifest["releases"][0]
        self.assertEqual("Questie-v11.38.0.zip", release["filename"])
        self.assertEqual([{"flavor": "classic", "interface": 11508},
                          {"flavor": "classic", "interface": 11509}], release["metadata"])
        with zipfile.ZipFile(output / release["filename"]) as archive:
            self.assertIn(build.tocs[1], archive.namelist())
            self.assertNotIn(build.tocs[2], archive.namelist())
            self.assertFalse(any(name.startswith("QuestieDB/") for name in archive.namelist()))

    def test_standalone_is_default_without_a_provider_download(self):
        output, manifest = self.run_build("-r")
        self.downloads.assert_not_called()
        self.assertEqual({"releases", "questie"}, set(manifest))
        filename = manifest["releases"][0]["filename"]
        self.assertEqual("Questie-v11.38.0.zip", filename)
        with zipfile.ZipFile(output / filename) as archive:
            self.assertIn(build.tocs[1], archive.namelist())
            self.assertFalse(any(name.startswith("QuestieDB/") for name in archive.namelist()))

    def test_combined_preserves_the_complete_provider_section(self):
        output, manifest = self.run_build("--combined", "-r")
        self.assertEqual(self.database, manifest["questiedb"])
        self.assertEqual("11.39.0", manifest["questie"]["version"])
        filename = manifest["releases"][0]["filename"]
        self.assertEqual("Questie-v11.38.0+v1.0.0.zip", filename)
        with zipfile.ZipFile(output / filename) as archive:
            roots = {name.split("/")[0] for name in archive.namelist()}
            self.assertEqual({"Questie", "QuestieDB"}, roots)
        self.assertEqual(2, self.downloads.call_count)

    def test_all_flavors_advertise_every_declared_interface(self):
        output, manifest = self.run_build("--combined", "--all", "-r")
        expected = [{"flavor": flavor, "interface": interface}
                    for flavor in ("classic", "bcc", "wrath", "cata", "mists")
                    for interface in (11508, 11509)]
        self.assertEqual(expected, manifest["releases"][0]["metadata"])
        with zipfile.ZipFile(output / manifest["releases"][0]["filename"]) as archive:
            for toc in build.tocs.values():
                self.assertIn("Questie/" + toc, archive.namelist())

    def test_default_selection_excludes_cata_even_after_an_all_flavor_build(self):
        for selection, expected_flavors in (
            ((), ["classic", "bcc", "wrath", "mists"]),
            (("--all",), ["classic", "bcc", "wrath", "cata", "mists"]),
            ((), ["classic", "bcc", "wrath", "mists"]),
        ):
            with self.subTest(selection=selection):
                output, manifest = self.run_build("--standalone", "-r", selection=selection)
                expected_metadata = [{"flavor": flavor, "interface": interface}
                                     for flavor in expected_flavors for interface in (11508, 11509)]
                self.assertEqual(expected_metadata, manifest["releases"][0]["metadata"])
                with zipfile.ZipFile(output / manifest["releases"][0]["filename"]) as archive:
                    self.assertEqual("cata" in expected_flavors, "Questie_Cata.toc" in archive.namelist())
        self.downloads.assert_not_called()

    def test_expansion_aliases_select_matching_tocs_and_metadata(self):
        cases = (
            (("-c", "--classic"), "Vanilla", "classic"),
            (("-t", "--tbc"), "TBC", "bcc"),
            (("-w", "--wotlk"), "Wrath", "wrath"),
            (("-ca", "--cata"), "Cata", "cata"),
            (("-m", "--mop"), "Mists", "mists"),
        )
        for flags, suffix, flavor in cases:
            for flag in flags:
                with self.subTest(flag=flag):
                    output, manifest = self.run_build("--standalone", "-r", selection=(flag, flag))
                    release = manifest["releases"][0]
                    self.assertEqual([
                        {"flavor": flavor, "interface": 11508},
                        {"flavor": flavor, "interface": 11509},
                    ], release["metadata"])
                    with zipfile.ZipFile(output / release["filename"]) as archive:
                        packaged_tocs = [name for name in archive.namelist() if name.endswith(".toc")]
                        self.assertEqual([f"Questie_{suffix}.toc"], packaged_tocs)
        self.downloads.assert_not_called()

    def test_flat_provider_manifest_is_not_silently_accepted(self):
        self.provider_manifest = self.database
        with self.assertRaisesRegex(KeyError, "questiedb"):
            self.run_build("--combined", "-r")
        self.assertEqual(1, self.downloads.call_count)

    def test_modes_preserve_development_naming_and_explicit_versions(self):
        for mode, db_suffix in (("--standalone", ""), ("--combined", "+v1.0.0-aaaaaaaaa")):
            with self.subTest(mode=mode):
                directory = "v11.38.0-abc123def-staticdb-cd"
                _, manifest = self.run_build(mode, directory=directory)
                self.assertEqual(f"Questie-{directory}{db_suffix}.zip", manifest["releases"][0]["filename"])
                output, manifest = self.run_build(mode, "-r", "-v", "v12.0.0.alpha0", directory="v12.0.0.alpha0")
                self.assertEqual("v12.0.0.alpha0", manifest["questie"]["version"])
                prefix = "Questie/" if mode == "--combined" else ""
                with zipfile.ZipFile(output / manifest["releases"][0]["filename"]) as archive:
                    self.assertIn("## Version: v12.0.0.alpha0\n", archive.read(prefix + build.tocs[1]).decode())

    def test_database_update_does_not_change_questie_metadata(self):
        _, first = self.run_build("--standalone", "-r")
        self.database["version"] = "1.0.1"
        self.write_provider_zip("1.0.1")
        self.database["artifacts"][0].update(bytes=self.provider_zip.stat().st_size,
            sha256=hashlib.sha256(self.provider_zip.read_bytes()).hexdigest())
        _, combined = self.run_build("--combined", "-r")
        self.assertEqual(first["questie"], combined["questie"])
        self.assertEqual("1.0.1", combined["questiedb"]["version"])

    def test_conflicting_modes_do_not_delete_existing_output(self):
        with patch.object(build.sys, "argv", ["build.py", "--standalone", "--combined"]):
            with patch.object(build.shutil, "rmtree") as remove:
                with self.assertRaisesRegex(ValueError, "either"):
                    build.main()
                remove.assert_not_called()
        self.downloads.assert_not_called()

    def test_selected_archive_must_be_unambiguous_before_download(self):
        archive = self.database["artifacts"][0]
        for artifacts in ([], [archive, archive]):
            with self.subTest(artifacts=artifacts):
                self.database["artifacts"] = artifacts
                self.downloads.reset_mock()
                with self.assertRaisesRegex(ValueError, "exactly one QuestieDB-all.zip"):
                    self.run_build("--combined", "-r")
                self.assertEqual(1, self.downloads.call_count)

    def test_checksum_or_size_mismatch_is_rejected_before_extraction_or_packaging(self):
        archive = self.database["artifacts"][0]
        for field, value in (("sha256", "f" * 64), ("sha256", "not-a-checksum"), ("bytes", 1)):
            with self.subTest(field=field, value=value), patch.dict(archive, {field: value}):
                with patch.object(build.shutil, "unpack_archive") as extract:
                    with self.assertRaisesRegex(ValueError, "checksum or size"):
                        self.run_build("--combined", "-r")
                    extract.assert_not_called()
                self.assertFalse((self.root / "releases/v11.38.0/release.json").exists())

    def test_packaged_toc_must_agree_with_manifest_producer(self):
        self.database["producerCommit"] = "d" * 40
        with self.assertRaisesRegex(ValueError, "TOC does not match"):
            self.run_build("--combined", "-r")

    def test_notes_use_copied_metadata_after_latest_changes(self):
        _, retained = self.run_build("--combined", "-r")
        self.database["version"] = "9.0.0"
        self.database["changelog"][0]["text"] = "An unrelated later release."
        notes = changelog.get_addon_changelog("QuestieDB", retained["questiedb"])
        self.assertIn("## QuestieDB 1.0.0", notes)
        self.assertIn("Correct quest prerequisites.", notes)
        self.assertNotIn("An unrelated later release", notes)
        self.assertEqual(2, self.downloads.call_count)

    def test_failed_packaging_does_not_write_success_metadata(self):
        with patch.object(build.shutil, "make_archive", side_effect=OSError("archive failed")):
            with self.assertRaisesRegex(OSError, "archive failed"):
                self.run_build("-r")
        self.assertFalse((self.root / "releases/v11.38.0/release.json").exists())


if __name__ == "__main__":
    unittest.main()
