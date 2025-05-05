# Generate zoneTables

This directory contains files to generate the zoneTables Questie uses to map areaIds to the actual ingame UiMapIDs. 

## Where does the data come from?

The CSV files used in the script were taken from https://wago.tools/. The patch and build number is included in the file name.

## Running the script

1. Make sure you have Python 3.x installed on your system.
2. Run the `generate_zone_tables.py` script.
3. Take the content of the generated `areaIdToUiMapId.lua` file and replace the previously used data.
3. Take the content of the generated `uiMapIdToAreaId.lua` file and replace the previously used data.

