"""
This script generates Lua database files for faction templates based on CSV data.

It performs the following steps:
1. Ensures the latest FactionTemplate CSV files are available locally by calling
   a function from `downloadFactionTemplate`. If downloads fail, it relies on
   existing local files.
2. For each specified game version (Classic, TBC, WotLK, etc.), it finds the
   latest corresponding CSV file on disk.
3. It reads the CSV file, extracting Faction IDs and their enemy group IDs.
4. It writes the extracted data into a formatted .lua file, which will be
   used by the Questie addon.
"""

from typing import List, Dict, Any, Optional
import csv
import os
import re
from downloadFactionTemplate import ensure_faction_templates_on_disk

# A list of dictionaries, each defining a major game version and the
# corresponding output Lua file name. This structure allows for easy
# extension to support future game expansions.
factionTemplates: List[Dict[str, Any]] = [
    {
        "majorVersion": "1",
        "fileName": "factionTemplateClassic.lua",
    },
    {
        "majorVersion": "2",
        "fileName": "factionTemplateTBC.lua",
    },
    {
        "majorVersion": "3",
        "fileName": "factionTemplateWotlk.lua",
    },
    {
        "majorVersion": "4",
        "fileName": "factionTemplateCata.lua",
    },
    {
        "majorVersion": "5",
        "fileName": "factionTemplateMoP.lua",
    },
]


def get_latest_version_on_disk(major_version: str) -> Optional[str]:
    """
    Finds the latest version of a FactionTemplate CSV file on disk for a given major version.

    This function is the primary fallback mechanism. If `ensure_faction_templates_on_disk`
    fails to download the newest files, this function will find the best available
    local file, ensuring the script can still run.

    Args:
        major_version (str): The major game version (e.g., "1", "2", "3").

    Returns:
        str or None: The full filename of the latest CSV file for that version,
                     or None if no matching file is found.
    """
    dbc_dir: str = "../DBC - WoW.tools/"
    if not os.path.isdir(dbc_dir):
        print(f"Error: Directory not found at {dbc_dir}")
        return None
    files: List[str] = os.listdir(dbc_dir)
    # Regex to match files like "FactionTemplate.1.15.2.53535.csv"
    # Using .format() to avoid potential f-string escape sequence issues.
    pattern: str = r"FactionTemplate\.{}\..*\.csv".format(major_version)

    matching_files: List[str] = [f for f in files if re.match(pattern, f)]
    if not matching_files:
        return None

    # Sort files based on the numerical parts of their version numbers.
    # This is crucial for correctly identifying the "latest" version.
    # For example, "1.15.2" should come after "1.2.0".
    # The key lambda splits the filename by '.' and ' ' and converts found digits to integers for sorting.
    try:
        matching_files.sort(
            key=lambda f: list(map(int, re.findall(r"\d+", f))), reverse=True
        )
    except (ValueError, TypeError):
        # Fallback to simple alphabetical sort if version number parsing fails.
        # This is less accurate but prevents a crash.
        print(
            "Warning: Could not parse version numbers for sorting, falling back to alphabetical sort."
        )
        matching_files.sort(reverse=True)

    return matching_files[0]


if __name__ == "__main__":
    # Step 1: Ensure the latest CSV files are on disk. This script will attempt
    # to download any missing files. If it fails, the script will proceed
    # with the latest files already present.
    ensure_faction_templates_on_disk(factionTemplates)

    # The root of the project is two directories up from the script's location.
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
    output_dir = os.path.join(project_root, 'Database', 'FactionTemplates')

    # Ensure the output directory exists.
    if not os.path.isdir(output_dir):
        print(f"Error: Output directory not found at {output_dir}")
        exit(1)

    # Step 2: Process each template configuration.
    for template in factionTemplates:
        file_name: str = template["fileName"]
        output_file: str = os.path.join(output_dir, file_name)
        major_version: str = template["majorVersion"]

        # Step 3: Find the best available local file for the current major version.
        # This serves as a fallback if the download step failed.
        faction_template_filename: Optional[str] = get_latest_version_on_disk(
            major_version
        )

        if faction_template_filename:
            faction_template_file: str = (
                f"../DBC - WoW.tools/{faction_template_filename}"
            )
            print(
                f"Using file on disk for version {major_version}: {faction_template_filename}"
            )
        else:
            print(f"No local file found for major version {major_version}. Skipping.")
            continue  # Continue to the next template instead of exiting

        try:
            with (
                open(faction_template_file, "r", encoding="utf-8") as csvfile,
                open(output_file, "w", encoding="utf-8", newline="\n") as luafile,
            ):
                # Step 4: Read the CSV and prepare the data.
                # Using DictReader allows accessing columns by name, which is more robust
                # to changes in column order.
                reader: csv.DictReader = csv.DictReader(csvfile)
                rows: List[tuple[int, str]] = []
                for row in reader:
                    # .get() is used to avoid KeyErrors if a column is missing.
                    entry_id: str = row.get("ID", "").strip()
                    enemy_group: str = row.get("EnemyGroup", "").strip()
                    # Ensure both ID and EnemyGroup are present and valid before adding.
                    if entry_id and enemy_group and entry_id.isdigit():
                        rows.append((int(entry_id), enemy_group))

                # Sort by Faction ID to ensure a consistent and readable output file.
                rows.sort()

                # Step 5: Write the data to the Lua file.
                luafile.write(
                    "-- * File was auto-generated by generateFactionTemplate.py\n"
                )
                luafile.write(
                    f"-- * Faction Template File Used: {os.path.basename(faction_template_file)}\n\n"
                )
                luafile.write("---@class QuestieDB\n")
                luafile.write(
                    'local QuestieDB = QuestieLoader:ImportModule("QuestieDB")\n\n'
                )
                luafile.write(
                    "-- ? If you want to make corrections to the faction template\n"
                )
                luafile.write(
                    "-- ? please do so in the _factionTemplateFixes.lua file.\n\n"
                )
                luafile.write("---@type table<FactionId, EnemyGroup>\n")
                luafile.write("QuestieDB.factionTemplate = {\n")
                for entryId, enemy_group in rows:
                    # Write each entry in the format expected by Lua.
                    luafile.write(f"    [{entryId}] = {enemy_group},\n")
                luafile.write("}\n")
            print(f"Successfully generated {output_file}")
        except FileNotFoundError:
            print(f"Error: Could not find the file {faction_template_file}")
        except Exception as e:
            print(
                f"An unexpected error occurred while processing {faction_template_filename}: {e}"
            )
