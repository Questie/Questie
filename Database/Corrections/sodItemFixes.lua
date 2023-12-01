---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function SeasonOfDiscovery:LoadItems()
    local itemKeys = QuestieDB.itemKeys
    local itemClasses = QuestieDB.itemClasses

    return {
        -- Example from corrections
        -- [3713] = {
        --     [itemKeys.name] = "Soothing Spices",
        --     [itemKeys.relatedQuests] = {555,1218},
        --     [itemKeys.npcDrops] = {2381,4897},
        --     [itemKeys.objectDrops] = {},
        -- },
    }
end
