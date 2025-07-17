# Scraper

## Description

This is a scraper that runs on [wowhead.com/classic](https://www.wowhead.com/classic/).

Currently, it is only used to scrape SoD related data.

## Usage

1. Install [Python](https://www.python.org/downloads/) (version 3.8 or higher)
2. Install the required packages: `pip install -r requirements.txt`
3. Run the scraper, with the desired flag:
   - `python runner.py --quest` to scrape quests
   - `python runner.py --item` to scrape items
   - `python runner.py --npc` to scrape NPCs
   - `python runner.py --object` to scrape objects
     
4. For additional commands and utilities run:
   - `python runner.py -h` 

## Generate new translations

To update the lookup files with the latest translations, the runner has multiple `*-translations` arguments. These will scrape translations for all locales available on wowhead, format them and merge them with the existing lookup files.
