# Generating Quest XP files

In order to run the `generateQuestXp.lua` script, you need two files:

1. The `QuestXP` DBC file. It can be found online (e.g. https://wago.tools/db2/QuestXP).
   - Place this file in the `DBC - WoW.tools` folder.
   - Remove the header line from the DBC file
2. The `data.csv`. It is extracted from a matching database (e.g. Mangos, Trinity, ...).
   - Place this file in the `data` folder.
   - You extract it with the following SQL query:
   ```sql
   SELECT entry, QuestLevel, RewXPId FROM quest_template ORDER BY entry;
   ```

Afterward, make sure the `generateQuestXp.lua` script reads the correct DBC-file and just run it. Place the generated `xpDB.lua` file with the correct name in `Database/QuestXP/DB`.
