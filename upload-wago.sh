#!/bin/sh
set -eu

command -v git >/dev/null 2>&1 || { echo "Git is required to reserve a Wago upload" >&2; exit 1; }
LATEST_GIT_TAG="${1:?Usage: upload-wago.sh bundle/vQUESTIE+vDATABASE}"
case "$LATEST_GIT_TAG" in
  bundle/v*) ;;
  *) echo "Expected a bundle/v... release tag" >&2; exit 1 ;;
esac
git check-ref-format "refs/tags/$LATEST_GIT_TAG"
UPLOAD_TAG="bundle/wago/${LATEST_GIT_TAG#bundle/}"
RETRY_HINT="Check Wago and the previous workflow run before retrying.
Only if no upload was accepted and no attempt is still running, remove the remote reservation tag:
  git push origin --delete \"$UPLOAD_TAG\"
Then rerun the upload workflow."

fail_upload() {
  printf '%s\n' "$RETRY_HINT" >&2
  exit "$1"
}

# Fetch the bundle commit, but check the remote directly so stale local tags cannot mislead us.
git fetch --tags origin
remote_tags=$(git ls-remote --tags origin "refs/tags/$LATEST_GIT_TAG" "refs/tags/$UPLOAD_TAG")
if ! printf '%s\n' "$remote_tags" | grep -Fq "refs/tags/$LATEST_GIT_TAG"; then
  echo "Bundle tag $LATEST_GIT_TAG does not exist on origin" >&2
  exit 1
fi
if printf '%s\n' "$remote_tags" | grep -Fq "refs/tags/$UPLOAD_TAG"; then
  echo "$UPLOAD_TAG already exists; refusing another upload" >&2
  fail_upload 1
fi
bundle_commit=$(git rev-parse "refs/tags/$LATEST_GIT_TAG^{commit}")

# Use the artifact already selected by the workflow.
: "${RELEASE_DIR:?}" "${BUNDLED_ZIP:?}" "${WAGO_API_TOKEN:?}"
if [ ! -f "$RELEASE_DIR/$BUNDLED_ZIP" ]; then
  echo "Artifact $RELEASE_DIR/$BUNDLED_ZIP not found" >&2
  exit 1
fi
# Reject mislabeled bundles before reserving an upload, including beta builds from another commit.
if ! jq -es --arg tag "$LATEST_GIT_TAG" --arg commit "$bundle_commit" --arg zip "$BUNDLED_ZIP" '
    (if length == 1 then .[0] else error("Expected one release manifest") end) |
    .questie.version as $questie | .questiedb.version as $database |
    ("bundle/v" + $questie + "+v" + $database) as $stable |
    ("bundle/v" + $questie + "-pre." + $commit[:7] + "+v" + $database) as $beta |
    ($questie | type == "string" and length > 0) and
    ($database | type == "string" and length > 0) and
    (.questie.producerCommit == $commit) and
    ($tag == $stable or $tag == $beta) and
    (.releases[0].filename == $zip) and
    ($zip == ("Questie-" + ($tag | ltrimstr("bundle/")) + ".zip"))
' "$RELEASE_DIR/release.json" >/dev/null; then
  echo "Bundle validation failed: $LATEST_GIT_TAG, its commit and $BUNDLED_ZIP must match release.json" >&2
  exit 1
fi
CHANGELOG=$(jq --slurp --raw-input '.' < "CHANGELOG.md")

case "$LATEST_GIT_TAG" in
  *-pre.*) RELEASE_TYPE="beta" ;;
  *) RELEASE_TYPE="stable" ;;
esac

echo "Uploading $RELEASE_TYPE $LATEST_GIT_TAG to Wago"

### WAGO Upload
# Docs: https://docs.wago.io/#introduction

WAGO_METADATA=$(cat <<-EOF
{
   "label": "$LATEST_GIT_TAG",
   "stability": "$RELEASE_TYPE",
   "changelog": $CHANGELOG,
   "supported_classic_patch": "1.15.9",
   "supported_forever_patch": "1.60.1",
   "supported_bc_patch": "2.5.6",
   "supported_wotlk_patch": "3.80.2",
   "supported_mop_patch": "5.5.4"
}
EOF
)

# Reserve before uploading and keep the marker even if uploading fails.
# Only a newly created remote ref grants permission; an up-to-date push means another run reserved it.
echo "Reserving $UPLOAD_TAG"
reservation=$(git push --porcelain --no-follow-tags origin "$bundle_commit:refs/tags/$UPLOAD_TAG") || fail_upload "$?"
if ! printf '%s\n' "$reservation" | grep -q '^\*'; then
  echo "Upload reservation was not newly created; refusing to upload" >&2
  fail_upload 1
fi

response=$(curl -sS \
    -o response.txt \
    -w "%{http_code}" \
    -H "authorization: Bearer $WAGO_API_TOKEN" \
    -H "accept: application/json" \
    -F "metadata=$WAGO_METADATA" \
    -F "file=@$RELEASE_DIR/$BUNDLED_ZIP" \
    "https://addons.wago.io/api/projects/qv634BKb/version") || fail_upload "$?"

http_status=$(echo "$response" | tail -n1) || fail_upload "$?"

if [ "$http_status" -eq 200 ] || [ "$http_status" -eq 201 ]; then
  echo "Wago upload successful"
else
  echo "Wago upload failed, HTTP-code: $http_status"
  cat response.txt || fail_upload "$?"
  fail_upload 1
fi