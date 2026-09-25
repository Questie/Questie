#!/bin/sh
set -eu

manifest_path="${1:?Usage: validate-bundle.sh MANIFEST TAG COMMIT ZIP}"
release_tag="${2:?}"
bundle_commit="${3:?}"
bundled_zip="${4:?}"

fail_validation() {
  printf 'Bundle validation failed: %s\n' "$1" >&2
  exit 1
}

# Read exactly one JSON document, not an empty file or concatenated manifests.
manifest=$(jq -es '
  if length == 1 then .[0] else error("Expected one release manifest") end
' "$manifest_path") || fail_validation "Cannot read a single release manifest from $manifest_path"

read_manifest_string() {
  # Reject control characters before shell command substitution can strip trailing newlines.
  printf '%s\n' "$manifest" | jq -er "$1 | strings | select(length > 0 and (test(\"[[:cntrl:]]\") | not))" ||
    fail_validation "$1 must be a nonempty string without control characters in $manifest_path"
}

questie_version=$(read_manifest_string '.questie.version')
database_version=$(read_manifest_string '.questiedb.version')
manifest_commit=$(read_manifest_string '.questie.producerCommit')
manifest_zip=$(read_manifest_string '.releases[0].filename')

# The manifest must describe the source commit and versions named by the release tag.
if [ "$manifest_commit" != "$bundle_commit" ]; then
  fail_validation "Manifest commit $manifest_commit does not match tag commit $bundle_commit"
fi

short_commit=$(printf '%.7s' "$bundle_commit")
stable_tag="bundle/v$questie_version+v$database_version"
beta_tag="bundle/v$questie_version-pre.$short_commit+v$database_version"
if [ "$release_tag" != "$stable_tag" ] && [ "$release_tag" != "$beta_tag" ]; then
  fail_validation "Release tag $release_tag must be $stable_tag or $beta_tag"
fi

# Do not upload a different archive, or label a stable archive as a beta.
if [ "$bundled_zip" != "$manifest_zip" ]; then
  fail_validation "Selected ZIP $bundled_zip does not match manifest ZIP $manifest_zip"
fi

expected_zip="Questie-${release_tag#bundle/}.zip"
if [ "$bundled_zip" != "$expected_zip" ]; then
  fail_validation "Selected ZIP $bundled_zip does not match expected ZIP $expected_zip"
fi
