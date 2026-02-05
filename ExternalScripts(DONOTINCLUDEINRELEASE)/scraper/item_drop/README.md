To scrape new Wowhead data:

1. Launch WoW with the desired expansion level and Questie installed.
2. Once Questie is fully loaded ingame, run /questie itemdrop
3. Copy that list of IDs into the file Questie/ExternalScripts(DONOTINCLUDEINRELEASE)/scraper/item_drop/item_ids.py
4. Run:   `python Questie/ExternalScripts(DONOTINCLUDEINRELEASE)/scraper/runner.py --item-drop -ex #`   where # is the expansion level; 0 for classic, 1 for tbc, etc. also accepts strings
5. Once it's done scraping, the data will be in Questie/ExternalScripts(DONOTINCLUDEINRELEASE)/scraper/item_drop/item_drop_data_wowhead.lua

To extract cmangos/mangos3 data:

1. Host the relevant MySQL database locally on your machine
2. Tweak Questie/ExternalScripts(DONOTINCLUDEINRELEASE)/scraper/item_drop/cmangos_itemdrops.py for your host IP, user, password, and database ID, if necessary
3. Run:   `python cmangos_itemdrops.py`
4. Once it's done extracting, the data will be in Questie/ExternalScripts(DONOTINCLUDEINRELEASE)/scraper/item_drop/item_drop_data_cmangos.lua
(we don't need a list of IDs like for wowhead because we rely on cmangos' own data for what items are quest-only drops)