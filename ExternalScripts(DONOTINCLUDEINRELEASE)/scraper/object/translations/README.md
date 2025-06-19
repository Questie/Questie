# How to generate object name translations

1. Make sure you have enough time to do this. Scraping wowhead for all localized names takes a while.
2. Run `runner.py` with the `--object-translations` argument to start the scraper.
   Currently, it scrapes the Cataclysm data for all object IDs inside `cata_object_ids.py`. Feel free to adjust this list or the languages to your needs.
3. After the scraping a file called `scraped_data.json` will be generated and then formatted in `object_names_<locale>.lua` files.
4. Now you need to copy the current lookup files from `Localization/lookups/Cata/lookupObjects` into a new `lookups` directory inside this directory.
5. Run `lua merge_object_lookups.lua` to merge the scraped data with the current lookup data.
6. Replace the existing lookup files with the newly generated ones.