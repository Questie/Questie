@echo off
SET foldername="Questie"
SET classicversion=11302
SET retailversion=80000
IF EXIST "Configuration\\package.lock" (
    echo "Lock file already exists... manually delete "Configuration\\package.lock" if something is wrong!"
) ELSE (
    copy NUL "Configuration\\package.lock"

    FINDSTR /r /c:"## Version:" Configuration\\general.toc.conf > Configuration\\versionOutput.temporary
    SET /p rawversions= < Configuration\\versionOutput.temporary
    del Configuration\\versionOutput.temporary
    SET versions=%rawversions:~11%

    echo "--> Generating develop toc files"
    echo "----> Classic"
    @echo #DO NOT MODIFY> QuestieDev-master.toc
    @echo #AUTOMATICALLY GENERATED FROM Configuration\\general.toc.conf >> QuestieDev-master.toc
    @echo ## Interface: %classicversion% >> QuestieDev-master.toc
    type Configuration\\general.toc.conf >> QuestieDev-master.toc

    echo "----> Retail"
    @echo #DO NOT MODIFY> QuestieDev-master-retail.toc
    @echo #AUTOMATICALLY GENERATED FROM Configuration\\general.toc.conf >> QuestieDev-master-retail.toc
    @echo ## Interface: %retailversion% >> QuestieDev-master-retail.toc
    type Configuration\\general.toc.conf >> QuestieDev-master-retail.toc

    @echo "#Had to do this because reading a file with this didn't seem to work because it read linebreak and stuff..."
    echo "Moving code!"
    rmdir /S /Q Configuration\\%foldername%
    mkdir Configuration\\%foldername%
    xcopy /E/H/K Database Configuration\%foldername%\Database\
    xcopy /E/H/K Icons Configuration\%foldername%\Icons\
    xcopy /E/H/K Libs Configuration\%foldername%\Libs\
    xcopy /E/H/K Locale Configuration\%foldername%\Locale\
    xcopy /E/H/K Modules Configuration\%foldername%\Modules\
    xcopy embeds.xml Configuration\%foldername%
    xcopy Questie.lua Configuration\%foldername%
    xcopy %foldername%-retail.toc Configuration\%foldername%
    xcopy %foldername%.toc Configuration\%foldername%
    xcopy README.md Configuration\%foldername%

    echo "--> Generating release toc files"
    echo "----> Classic"
    @echo #DO NOT MODIFY> Configuration\%foldername%\%foldername%.toc
    @echo #AUTOMATICALLY GENERATED FROM Configuration\\general.toc.conf >> Configuration\%foldername%\%foldername%.toc
    @echo ## Interface: %classicversion% >> Configuration\%foldername%\%foldername%.toc
    type Configuration\\general.toc.conf >> Configuration\%foldername%\%foldername%.toc

    echo "----> Retail"
    @echo #DO NOT MODIFY> Configuration\%foldername%\%foldername%-retail.toc
    @echo #AUTOMATICALLY GENERATED FROM Configuration\\general.toc.conf >> Configuration\%foldername%\%foldername%-retail.toc
    @echo ## Interface: %retailversion% >> Configuration\%foldername%\%foldername%-retail.toc
    type Configuration\\general.toc.conf >> Configuration\%foldername%\%foldername%-retail.toc
    echo "--> Packaging release"
    del "Configuration\\Questie-%versions%.zip"
    cd Configuration
    7z a -tzip "Questie-%versions%.zip" %foldername%
    cd ..

    echo "--> Removing packed items"
    rmdir /S /Q Configuration\\%foldername%

    echo "--> Done!"
    echo %versions%
    del "Configuration\\package.lock"
)
