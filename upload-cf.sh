#!/bin/sh
set -eu

command -v git >/dev/null 2>&1 || { echo "Git is required to reserve a CurseForge upload" >&2; exit 1; }
LATEST_GIT_TAG="${1:?Usage: upload-cf.sh bundle/vQUESTIE+vDATABASE}"
case "$LATEST_GIT_TAG" in
  bundle/v*) ;;
  *) echo "Expected a bundle/v... release tag" >&2; exit 1 ;;
esac
git check-ref-format "refs/tags/$LATEST_GIT_TAG"
UPLOAD_TAG="bundle/curse/${LATEST_GIT_TAG#bundle/}"

# Fetch the bundle commit, but check the remote directly so stale local tags cannot mislead us.
git fetch --tags origin
remote_tags=$(git ls-remote --tags origin "refs/tags/$LATEST_GIT_TAG" "refs/tags/$UPLOAD_TAG")
if ! printf '%s\n' "$remote_tags" | grep -Fq "refs/tags/$LATEST_GIT_TAG"; then
  echo "Bundle tag $LATEST_GIT_TAG does not exist on origin" >&2
  exit 1
fi
if printf '%s\n' "$remote_tags" | grep -Fq "refs/tags/$UPLOAD_TAG"; then
  echo "$UPLOAD_TAG already exists; check the previous upload manually" >&2
  exit 1
fi
bundle_commit=$(git rev-parse "refs/tags/$LATEST_GIT_TAG^{commit}")

# Use the artifact already selected by the workflow.
: "${RELEASE_DIR:?}" "${BUNDLED_ZIP:?}" "${CF_API_TOKEN:?}"
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

# The order of the "gameVersions" below is: WotLK (3.80.1), Era/SoD, TBC, MoP
CF_METADATA=$(cat <<-EOF
{
    "displayName": "$LATEST_GIT_TAG",
    "releaseType": "$RELEASE_TYPE",
    "changelog": $CHANGELOG,
    "changelogType": "markdown",
    "gameVersions": [16785, 16630, 16533, 16168],
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
echo "Reserving $UPLOAD_TAG; failures require manual verification before retrying"
reservation=$(git push --porcelain --no-follow-tags origin "$bundle_commit:refs/tags/$UPLOAD_TAG")
if ! printf '%s\n' "$reservation" | grep -q '^\*'; then
  echo "Upload reservation was not newly created; refusing to upload" >&2
  exit 1
fi

response=$(curl -sS \
    -o response.txt \
    -w "%{http_code}" \
    -H "X-API-TOKEN: $CF_API_TOKEN" \
    -F "metadata=$CF_METADATA" \
    -F "file=@$RELEASE_DIR/$BUNDLED_ZIP" \
    "https://wow.curseforge.com/api/projects/334372/upload-file")

http_status=$(echo "$response" | tail -n1)

if [ "$http_status" -eq 200 ]; then
  echo "CurseForge upload successful"
else
  echo "CurseForge upload failed, HTTP-code: $http_status"
  cat response.txt
  exit 1
fi