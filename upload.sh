#!/bin/sh

LATEST_GIT_TAG=$(git describe --tags --abbrev=0)
CHANGELOG=$(jq --slurp --raw-input '.' < "CHANGELOG.md")

WAGO_API_TOKEN=$(cat wago-token.txt)

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
