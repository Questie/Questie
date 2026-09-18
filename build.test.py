"""Offline tests for release build preflight. Run with: python3 build.test.py."""
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import build


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


if __name__ == "__main__":
    unittest.main()
