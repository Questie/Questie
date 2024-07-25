# Scraper

## Description

This is a scraper that runs on [wowhead.com/classic](https://www.wowhead.com/classic/).
Currently, it is only used to scrape SoD related data.

## Usage

1. Install [Python](https://www.python.org/downloads/) (version 3.8 or higher)
2. Install the required packages: `pip install -r requirements.txt`
3. Run the scraper, with the desired flag:
   - `python runner.py --quests` to scrape quests
   - `python runner.py --items` to scrape items
   - `python runner.py --npcs` to scrape NPCs
   - `python runner.py --objects` to scrape objects
