#!/bin/bash

# Use first argument from command line as type and defaults to "classic"
RELEASE_TYPE=${0:-"classic"}

FOLDERNAME="Questie"
CLASSICVERSION=11302
RETAILVERSION=80000

# Find version line in toc
VERSION_LINE=$(grep "## Version: " QuestieDev-master.toc)
# Remove prefix
VERSION=${VERSION_LINE#"## Version: "}
# Replace whitespace and unusual symbols
VERSION=${VERSION//[^A-Za-z0-9._-]/_}

# Create release dir if it doesn't exist
if [ ! -d "releases" ] ; then
    mkdir releases/
fi

# Make sure we do not overwrite anything
if [ -d "releases/$VERSION" ] || [ -f releases/Questie-v$VERSION.zip ] ; then
    echo "A release for this version already exists, delete it or bump the version"
    exit 1
fi

# If this file exists, the script will abort
LOCKFILE="releases/package.lock"

if [ -f $LOCKFILE ] ; then
    echo "$LOCKFILE exists, aborting"
    exit 2
fi

# Lockfile wasn't present, create it
> $LOCKFILE;

echo "Copying code!"

# Create directories
mkdir releases/$VERSION
mkdir releases/$VERSION/$FOLDERNAME

# Change path reference in the code
git apply release.patch

# Copy files
cp -R ./Database releases/$VERSION/$FOLDERNAME
cp -R ./Icons releases/$VERSION/$FOLDERNAME
cp -R ./Libs releases/$VERSION/$FOLDERNAME
cp -R ./Locale releases/$VERSION/$FOLDERNAME
cp -R ./Modules releases/$VERSION/$FOLDERNAME
cp -r embeds.xml releases/$VERSION/$FOLDERNAME
cp -r Questie.lua releases/$VERSION/$FOLDERNAME
cp -r README.md releases/$VERSION/$FOLDERNAME

# Reset path reference changes
git apply -R release.patch

# Add hash of currently checked out commit to toc
COMMIT=$(git rev-parse HEAD)
echo "# Commit hash: $COMMIT" >> releases/$VERSION/$FOLDERNAME/$FOLDERNAME.toc
# Copy rest of toc
cat QuestieDev-master.toc >> releases/$VERSION/$FOLDERNAME/$FOLDERNAME.toc

echo "Packaging release"
ROOT=$(pwd)
cd releases/$VERSION
7z a -tzip Questie-v$VERSION.zip $FOLDERNAME
cd $ROOT

rm $LOCKFILE
echo "Done!"

