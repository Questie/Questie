"""Offline uploader tests using temporary Git remotes and a fake curl. Run: python3 upload-wago.test.py."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("upload-wago.sh").resolve()
GIT = shutil.which("git")


@unittest.skipUnless(GIT and shutil.which("jq"), "git and jq are required")
class WagoUploadTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.remote = self.root / "origin.git"
        self.work = self.root / "work"
        self.bin = self.root / "bin"
        self.bin.mkdir()
        subprocess.run([GIT, "init", "--bare", "-q", str(self.remote)], check=True)
        subprocess.run([GIT, "clone", "-q", str(self.remote), str(self.work)], check=True, capture_output=True)
        self.git("-c", "user.name=Test", "-c", "user.email=test@example.org", "commit", "--allow-empty", "-qm", "Source")
        self.commit = self.git("rev-parse", "HEAD")
        self.tag = "bundle/v12.0.0+v1.0.0"
        self.marker = "bundle/wago/v12.0.0+v1.0.0"
        self.release_dir = self.work / "releases/v12.0.0"
        self.release_dir.mkdir(parents=True)
        self.zip = self.release_dir / "Questie-v12.0.0+v1.0.0.zip"
        self.zip.write_bytes(b"test artifact")
        (self.work / "CHANGELOG.md").write_text("Test release notes\n")
        self.calls = self.root / "uploads"
        self.env = dict(os.environ, PATH=str(self.bin) + os.pathsep + os.environ["PATH"],
                        WAGO_API_TOKEN="test-token", UPLOAD_LOG=str(self.calls), EXPECTED_MARKER=self.marker,
                        UPLOAD_STATUS="201", UPLOAD_EXIT="0", REAL_GIT=GIT, REMOTE_PATH=str(self.remote),
                        BUNDLE_COMMIT=self.commit, RELEASE_DIR="releases/v12.0.0", BUNDLED_ZIP=self.zip.name)
        self.stub("curl", '''#!/bin/sh
"$REAL_GIT" ls-remote --exit-code --tags origin "refs/tags/$EXPECTED_MARKER" >/dev/null || exit 33
printf 'upload\\n' >> "$UPLOAD_LOG"
printf '%s\\n' "$@" > "$UPLOAD_LOG.args"
printf '{"id":123}' > response.txt
printf '%s' "$UPLOAD_STATUS"
exit "$UPLOAD_EXIT"
''')

    def git(self, *args):
        return subprocess.check_output([GIT, "-C", str(self.work), *args], text=True, stderr=subprocess.PIPE).strip()

    def stub(self, name, contents):
        path = self.bin / name
        path.write_text(contents)
        path.chmod(0o755)

    def publish_bundle_tag(self):
        self.git("push", "origin", f"{self.commit}:refs/tags/{self.tag}")

    def run_upload(self):
        return subprocess.run(["/bin/sh", str(SCRIPT), self.tag], cwd=self.work,
                              env=self.env, text=True, capture_output=True)

    def has_remote_marker(self):
        return bool(self.git("ls-remote", "--tags", "origin", f"refs/tags/{self.marker}"))

    def test_requires_git_before_doing_anything(self):
        self.env["PATH"] = str(self.root / "empty-path")
        result = self.run_upload()
        self.assertNotEqual(0, result.returncode)
        self.assertIn("Git is required", result.stderr)
        self.assertFalse(self.calls.exists())

    def test_requires_remote_bundle_even_if_a_stale_local_tag_exists(self):
        self.git("tag", self.tag)
        result = self.run_upload()
        self.assertNotEqual(0, result.returncode)
        self.assertIn("does not exist on origin", result.stderr)
        self.assertFalse(self.has_remote_marker())
        self.assertFalse(self.calls.exists())

    def test_fetches_bundle_and_reserves_before_uploading_the_workflow_zip(self):
        self.publish_bundle_tag()
        self.assertEqual("", self.git("tag", "--list", self.tag))
        result = self.run_upload()
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertTrue(self.has_remote_marker())
        self.assertEqual("upload\n", self.calls.read_text())
        arguments = Path(str(self.calls) + ".args").read_text()
        self.assertIn(f"file=@releases/v12.0.0/{self.zip.name}", arguments)
        self.assertIn('"stability": "stable"', arguments)
        self.assertIn("authorization: Bearer test-token", arguments)
        self.assertIn("https://addons.wago.io/api/projects/qv634BKb/version", arguments)
        self.assertIn(self.commit, self.git("ls-remote", "--tags", "origin", f"refs/tags/{self.marker}"))

    def test_curseforge_reservation_does_not_block_wago(self):
        self.publish_bundle_tag()
        self.git("push", "origin", f"{self.commit}:refs/tags/bundle/curse/v12.0.0+v1.0.0")
        result = self.run_upload()
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertTrue(self.has_remote_marker())
        self.assertEqual("upload\n", self.calls.read_text())

    def test_existing_reservation_blocks_a_second_upload(self):
        self.publish_bundle_tag()
        self.assertEqual(0, self.run_upload().returncode)
        result = self.run_upload()
        self.assertNotEqual(0, result.returncode)
        self.assertIn("already exists", result.stderr)
        self.assertEqual("upload\n", self.calls.read_text())

    def test_failed_http_upload_keeps_reservation_and_blocks_retry(self):
        self.publish_bundle_tag()
        self.env["UPLOAD_STATUS"] = "500"
        result = self.run_upload()
        self.assertNotEqual(0, result.returncode)
        self.assertTrue(self.has_remote_marker())
        self.assertNotEqual(0, self.run_upload().returncode)
        self.assertEqual("upload\n", self.calls.read_text())

    def test_transport_failure_keeps_reservation(self):
        self.publish_bundle_tag()
        self.env["UPLOAD_EXIT"] = "7"
        self.assertNotEqual(0, self.run_upload().returncode)
        self.assertTrue(self.has_remote_marker())

    def test_fetch_failure_does_not_reserve_or_upload(self):
        self.publish_bundle_tag()
        self.stub("git", '#!/bin/sh\nif [ "$1" = fetch ]; then exit 128; fi\nexec "$REAL_GIT" "$@"\n')
        self.assertNotEqual(0, self.run_upload().returncode)
        self.assertFalse(self.has_remote_marker())
        self.assertFalse(self.calls.exists())

    def test_concurrent_same_commit_reservation_cannot_upload_twice(self):
        self.publish_bundle_tag()
        self.stub("git", '''#!/bin/sh
if [ "$1" = push ]; then
  "$REAL_GIT" --git-dir="$REMOTE_PATH" update-ref "refs/tags/$EXPECTED_MARKER" "$BUNDLE_COMMIT"
fi
exec "$REAL_GIT" "$@"
''')
        result = self.run_upload()
        self.assertNotEqual(0, result.returncode)
        self.assertIn("not newly created", result.stderr)
        self.assertTrue(self.has_remote_marker())
        self.assertFalse(self.calls.exists())

    def test_prerelease_has_its_own_reservation_and_beta_upload_type(self):
        self.tag += "-pre." + self.commit[:7]
        self.marker += "-pre." + self.commit[:7]
        self.env["EXPECTED_MARKER"] = self.marker
        self.publish_bundle_tag()
        result = self.run_upload()
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertTrue(self.has_remote_marker())
        self.assertIn('"stability": "beta"', Path(str(self.calls) + ".args").read_text())


if __name__ == "__main__":
    unittest.main()
