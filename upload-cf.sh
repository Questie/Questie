#!/bin/sh
# Manual upload to CurseForge:
# First publish the bundle on GitHub with "Build and publish bundle". This script
# distributes that existing release; it does not build or create a GitHub release.
# Run from the checkout root with git, gh, jq and curl installed, gh authenticated,
# and permission to push tags to origin. Continue only when each step succeeds.
#
# 1. Choose an existing release (replace these example values). Use a fresh download
#    directory so files from another release cannot be reused accidentally.
#    RELEASE_TAG="bundle/v12.0.0+v1.0.3"
#    export BUNDLED_ZIP="Questie-v12.0.0+v1.0.3.zip"
#    export RELEASE_DIR="$(mktemp -d)"
#
#    For a beta, use these values instead BEFORE downloading:
#    RELEASE_TAG="bundle/v12.0.0-pre.c24dba5+v1.0.3"
#    export BUNDLED_ZIP="Questie-v12.0.0-pre.c24dba5+v1.0.3.zip"
#
# 2. Download the manifest and ZIP from that same GitHub release:
#    gh release download "$RELEASE_TAG" --repo Questie/Questie --pattern release.json --dir "$RELEASE_DIR"
#
#    Optional: read the ZIP filename with jq instead of entering it manually:
#    export BUNDLED_ZIP="$(jq -er '.releases[0].filename' "$RELEASE_DIR/release.json")"
#
#    gh release download "$RELEASE_TAG" --repo Questie/Questie --pattern "$BUNDLED_ZIP" --dir "$RELEASE_DIR"
#
# 3. Fetch the published notes, just as the upload workflow does. This overwrites
#    CHANGELOG.md in the checkout root; save any local edits to that file first.
#    gh release view "$RELEASE_TAG" --repo Questie/Questie --json body --template '{{.body}}' > CHANGELOG.md
#
#    Alternatively, render notes from the downloaded manifest with Python via uv
#    (no gh needed for this step; later edits to the GitHub release notes are not included):
#    uv run --no-project changelog.py --release-manifest "$RELEASE_DIR/release.json" > CHANGELOG.md
#
# 4. Check the downloaded files and notes, then export CF_API_TOKEN securely in
#    your shell. Do not commit the token or paste it here. Start the upload:
#    sh upload-cf.sh "$RELEASE_TAG"
#
# Tags containing -pre.<commit> upload as beta; other tags upload as release.
# "latest" is not accepted here. The script still requires jq with a manual ZIP name.
# This performs a REAL upload and pushes a reservation tag to origin. There is no
# dry-run mode. If it fails, check CurseForge before following the printed retry steps.
set -eu

command -v git >/dev/null 2>&1 || { echo "Git is required to reserve a CurseForge upload" >&2; exit 1; }
LATEST_GIT_TAG="${1:?Usage: upload-cf.sh bundle/vQUESTIE+vDATABASE}"
case "$LATEST_GIT_TAG" in
  bundle/v*) ;;
  *) echo "Expected a bundle/v... release tag" >&2; exit 1 ;;
esac
git check-ref-format "refs/tags/$LATEST_GIT_TAG"
UPLOAD_TAG="bundle/curse/${LATEST_GIT_TAG#bundle/}"
RETRY_HINT="Check CurseForge and the previous workflow run before retrying.
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
: "${RELEASE_DIR:?}" "${BUNDLED_ZIP:?}" "${CF_API_TOKEN:?}"
if [ ! -f "$RELEASE_DIR/$BUNDLED_ZIP" ]; then
  echo "Artifact $RELEASE_DIR/$BUNDLED_ZIP not found" >&2
  exit 1
fi
# Validate the downloaded bundle before reserving or uploading it.
sh "$(dirname "$0")/validate-bundle.sh" "$RELEASE_DIR/release.json" "$LATEST_GIT_TAG" "$bundle_commit" "$BUNDLED_ZIP"
CHANGELOG=$(jq --slurp --raw-input '.' < "CHANGELOG.md")

case "$LATEST_GIT_TAG" in
  *-pre.*) RELEASE_TYPE="beta" ;;
  *) RELEASE_TYPE="release" ;;
esac

echo "Uploading $RELEASE_TYPE $LATEST_GIT_TAG to CurseForge"

#### CurseForge Upload
# Docs: https://support.curseforge.com/en/support/solutions/articles/9000197321-curseforge-upload-api

# We get the "gameVersions" by doing an authenticated GET to https://wow.curseforge.com/api/game/versions
# You can do so by opening the API in your browser and manually add the X-API-TOKEN Header with an API-Token to the request (https://authors-old.curseforge.com/account/api-tokens).
# Check the answer for the required version (e.g. name = "1.14.4") and take the "id" field for the gameVersions.

# The order of the "gameVersions" below is: Classic Era, Forever, TBC, Wrath (3.80.1), MoP
CF_METADATA=$(cat <<-EOF
{
    "displayName": "${LATEST_GIT_TAG#bundle/}",
    "releaseType": "$RELEASE_TYPE",
    "changelog": $CHANGELOG,
    "changelogType": "markdown",
    "gameVersions": [16630, 17053, 16533, 16785, 16168],
    "relations": {
        "projects": [
            {slug: "Ace3", type: "embeddedLibrary"},
            {slug: "CallbackHandler", type: "embeddedLibrary"},
            {slug: "HereBeDragons", type: "embeddedLibrary"},
            {slug: "LibCompress", type: "embeddedLibrary"},
            {slug: "LibDataBroker-1-1", type: "embeddedLibrary"},
            {slug: "LibDBIcon-1-0", type: "embeddedLibrary"},
            {slug: "LibSharedMedia-3-0", type: "embeddedLibrary"},
            {slug: "LibStub", type: "embeddedLibrary"},
            {slug: "LibUIDropDownMenu", type: "embeddedLibrary"}
        ]
    }
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
    -H "X-API-TOKEN: $CF_API_TOKEN" \
    -F "metadata=$CF_METADATA" \
    -F "file=@$RELEASE_DIR/$BUNDLED_ZIP" \
    "https://wow.curseforge.com/api/projects/334372/upload-file") || fail_upload "$?"

http_status=$(echo "$response" | tail -n1) || fail_upload "$?"

if [ "$http_status" -eq 200 ]; then
  echo "CurseForge upload successful"
else
  echo "CurseForge upload failed, HTTP-code: $http_status"
  cat response.txt || fail_upload "$?"
  fail_upload 1
fi