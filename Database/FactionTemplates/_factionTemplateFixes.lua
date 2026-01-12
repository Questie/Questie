---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

--- This file contains fixes for the faction template.

C_Timer.After(0, function()
    -- These factions need to be hostile towards the opposite faction
    -- https://wago.tools/db2/FactionTemplate?build=5.5.0.61798&filter%5BID%5D=534&page=1
    QuestieDB.factionTemplate[534] = 4 --* Changed from 0 -> 4 to be hostile towards horde
    -- https://wago.tools/db2/FactionTemplate?build=5.5.0.61798&filter%5BID%5D=714&page=1
    QuestieDB.factionTemplate[714] = 2 --* Changed from 0 -> 2 to be hostile towards alliance
end)
