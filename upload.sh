#!/bin/sh

LATEST_GIT_TAG=$(git describe --tags --abbrev=0)
CHANGELOG=$(cat CHANGELOG.md)

METADATA="{
   \"label\": \"$LATEST_GIT_TAG\",
   \"stability\": \"alpha\",
   \"changelog\": \"$CHANGELOG\",
   \"supported_wotlk_patch\": \"3.4.2\",
   \"supported_classic_patch\": \"1.14.4\"
}"

curl -f -X POST \
    -F "metadata=$METADATA" \
    -F "file=@releases/$LATEST_GIT_TAG/Questie-$LATEST_GIT_TAG.zip" \
    -H "authorization: Bearer abc123" \
    -H "accept: application/json" \
    http://localhost:3000


#    https://addons.wago.io/api/projects/<project id>/version