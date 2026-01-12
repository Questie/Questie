"""
This script handles the downloading of FactionTemplate CSV files from wago.tools.
It is designed to be used by generateFactionTemplate.py to ensure the latest
DBC data is available before generating the Lua database files.
"""

from typing import List, Optional, Dict, Any
import requests
import os
import re

# The URL pattern for downloading FactionTemplate CSVs.
# The {f} placeholder is replaced with the specific game version build string.
downloadUrl = "https://wago.tools/db2/FactionTemplate/csv?build={f}"


def get_all_versions() -> List[str]:
    """
    Scrapes the wago.tools DB2 page to find all available game client versions.

    Returns:
        list: A list of version strings (e.g., "3.4.3.52247") found on the page.
              Returns an empty list if the request fails or no versions are found.
    """
    url = "https://wago.tools/db2"
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raises an HTTPError for bad responses (4xx or 5xx)
        # The response text contains HTML entities, "&quot;" needs to be replaced with actual quotes.
        response_text = response.text.replace("&quot;", '"')
        # This regex is critical and potentially fragile. It's designed to find version strings
        # like "1.15.2.53535" from the HTML content of the page. If wago.tools changes
        # its page structure, this regex may need to be updated.
        all_versions = re.findall(r"(\d{1,2}\.\d{1,2}\.\d{1,2}.\d+)", response_text)
        return all_versions
    except requests.exceptions.RequestException as e:
        print(f"An error occurred while fetching versions from {url}: {e}")
        return []
    except Exception as e:
        print(f"An unexpected error occurred in get_all_versions: {e}")
        return []


def get_latest_version(major_version: str, all_versions: List[str]) -> Optional[str]:
    """
    Finds the latest version string for a given major version number from a list of all versions.

    Args:
        major_version (str): The major version to filter by (e.g., "1", "2", "3").
        all_versions (list): A list of all available version strings.

    Returns:
        str or None: The full version string of the latest build for the given
                     major version (e.g., "1.15.2.53535"), or None if not found.
    """
    if not major_version:
        print("Major version is not specified.")
        return None
    largest_version = 0
    largest_version_str = ""
    for version in all_versions:
        split_version = version.split(".")
        # The build number is the last part of the version string.
        build_number = split_version[-1]
        # Check if the version matches the major version and has a higher build number.
        if split_version[0] == major_version and int(build_number) > largest_version:
            largest_version = int(build_number)
            largest_version_str = version
    return largest_version_str


def download_file(url: str, filename: str) -> bool:
    """
    Downloads a file from a URL and saves it to a specified path.

    Args:
        url (str): The URL to download the file from.
        filename (str): The path where the file should be saved.

    Returns:
        bool: True if the download was successful, False otherwise.
    """
    try:
        response = requests.get(url)
        response.raise_for_status()  # Check for request errors
        with open(filename, "wb") as file:
            file.write(response.content)
        print(f"Downloaded {filename} successfully.")
        return True
    except requests.exceptions.RequestException as e:
        print(
            f"Failed to download {filename}. Status code: {e.response.status_code if e.response else 'N/A'}"
        )
        return False


def ensure_faction_templates_on_disk(factionTemplates: List[Dict[str, Any]]) -> None:
    """
    Ensures the latest FactionTemplate CSVs for each major version are present on disk.
    Downloads them if missing. To be imported and called from generateFactionTemplate.py.

    Args:
        factionTemplates (list): A list of dictionaries containing major version information.
    """
    all_versions = get_all_versions()
    if not all_versions:
        print(
            "Could not retrieve any versions from wago.tools. Proceeding with local files."
        )
        return

    for template in factionTemplates:
        major_version = template["majorVersion"]
        latest_version_str = get_latest_version(major_version, all_versions)
        if not latest_version_str:
            print(f"No version found for major version {major_version}")
            continue
        filename = f"FactionTemplate.{latest_version_str}.csv"
        faction_template_file = f"../DBC - WoW.tools/{filename}"
        if not os.path.exists(faction_template_file):
            print(f"Downloading {filename}...")
            download_url = downloadUrl.format(f=latest_version_str)
            # Attempt to download the file. If it fails, the script will
            # later fall back to using whatever latest version is on disk.
            download_file(download_url, faction_template_file)
