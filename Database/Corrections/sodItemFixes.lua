---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function SeasonOfDiscovery:LoadItems()
    local itemKeys = QuestieDB.itemKeys
    local itemClasses = QuestieDB.itemClasses

    return {}
end
