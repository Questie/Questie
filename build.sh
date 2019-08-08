#!/bin/bash
LOCKFILE="Configuration\\package.lock"
PREFIX="## Version:"
FOLDERNAME="Questie"
CLASSICVERSION=11302
RETAILVERSION=80000
VERSION=$(grep "## Version:" Configuration\\general.toc.conf)
VERSION=${VERSION#"## Version:"}
VERSION=${VERSION//[^A-Za-z0-9._-]/_}
ROOT=$(pwd)
if [ ! -f $LOCKFILE ] ; then
    > $LOCKFILE;

    echo "--> Generating develop toc files"
    echo "----> Classic"
    echo "#DO NOT MODIFY"> Questie.toc
    echo "#AUTOMATICALLY GENERATED FROM Configuration/general.toc.conf" >> Questie.toc
    echo "## Interface: $CLASSICVERSION" >> Questie.toc
    cat Configuration/general.toc.conf >> Questie.toc

    #echo "----> Retail"
    #echo "#DO NOT MODIFY"> QuestieDev-master-retail.toc
    #echo "#AUTOMATICALLY GENERATED FROM Configuration/general.toc.conf" >> QuestieDev-master-retail.toc
    #echo "## Interface: $RETAILVERSION" >> QuestieDev-master-retail.toc
    #cat Configuration/general.toc.conf >> QuestieDev-master-retail.toc

    #Had to do this because reading a file with this didn't seem to work because it read linebreak and stuff...
    echo "Moving code!"
    mkdir Configuration/$FOLDERNAME

    cp -R ./Database Configuration/$FOLDERNAME
    cp -R ./Icons Configuration/$FOLDERNAME
    cp -R ./Libs Configuration/$FOLDERNAME
    cp -R ./Locale Configuration/$FOLDERNAME
    cp -R ./Modules Configuration/$FOLDERNAME
    cp -r embeds.xml Configuration/$FOLDERNAME
    cp -r Questie.lua Configuration/$FOLDERNAME
    cp -r README.md Configuration/$FOLDERNAME

    echo "--> Generating develop toc files"
    echo "----> Classic"
    echo "#DO NOT MODIFY"> Configuration/$FOLDERNAME/$FOLDERNAME.toc
    echo "#AUTOMATICALLY GENERATED FROM Configuration/general.toc.conf" >> Configuration/$FOLDERNAME/$FOLDERNAME.toc
    echo "## Interface: $CLASSICVERSION" >> Configuration/$FOLDERNAME/$FOLDERNAME.toc
    cat Configuration/general.toc.conf >> Configuration/$FOLDERNAME/$FOLDERNAME.toc

    #echo "----> Retail"
    #echo "#DO NOT MODIFY"> Configuration/$FOLDERNAME/$FOLDERNAME-retail.toc
    #echo "#AUTOMATICALLY GENERATED FROM Configuration/general.toc.conf" >> Configuration/$FOLDERNAME/$FOLDERNAME-retail.toc
    #echo "## Interface: $RETAILVERSION" >> Configuration/$FOLDERNAME/$FOLDERNAME-retail.toc
    #cat Configuration/general.toc.conf >> Configuration/$FOLDERNAME/$FOLDERNAME-retail.toc

    echo "Packaging release"
    rm -rf Configuration/Questie-$VERSION.zip
    cd Configuration/
    7z a -tzip Questie-v$VERSION.zip $FOLDERNAME
    cd "$ROOT"
    rm -rf Configuration/$FOLDERNAME

    echo "Done!"
    rm $LOCKFILE
fi
