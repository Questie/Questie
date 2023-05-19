#!/bin/sh

LATEST_GIT_TAG=$(git describe --tags --abbrev=0)
CHANGELOG=$(jq --slurp --raw-input '.' < "CHANGELOG.md")

#### CurseForge Upload

CF_METADATA=$(cat <<-EOF
{
    "displayName": "$LATEST_GIT_TAG",
    "releaseType": "alpha",
    "changelog": $CHANGELOG,
    "changelogType": "markdown",
    "gameVersions": [9894, 9895],
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

curl -sS \
    -H "X-API-TOKEN: $CF_API_TOKEN" \
    -F "metadata=$CF_METADATA" \
    -F "file=@releases/$LATEST_GIT_TAG/Questie-$LATEST_GIT_TAG.zip" \
    "http://localhost:3000"
#    "https://wow.curseforge.com/api/projects/334372/upload-file"


### WAGO Upload

WAGO_METADATA=$(cat <<-EOF
{
   "label": "$LATEST_GIT_TAG",
   "stability": "alpha",
   "changelog": $CHANGELOG,
   "supported_wotlk_patch": "3.4.2",
   "supported_classic_patch": "1.14.4"
}
EOF
)

curl -sS \
    -H "authorization: Bearer $WAGO_API_TOKEN" \
    -H "accept: application/json" \
    -F "metadata=$WAGO_METADATA" \
    -F "file=@releases/$LATEST_GIT_TAG/Questie-$LATEST_GIT_TAG.zip" \
    "http://localhost:3000"
#    "https://addons.wago.io/api/projects/qv634BKb/version"
