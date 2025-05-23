---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

local tinsert = table.insert
local eventQuests = QuestieEvent.eventQuests

-- WotLK quests
tinsert(eventQuests, {"Noblegarden", 13483, nil, nil, Expansions.Current >= Expansions.Cata}) -- Spring Gatherers
tinsert(eventQuests, {"Noblegarden", 13484}) -- Spring Collectors
tinsert(eventQuests, {"Noblegarden", 13479}) -- The Great Egg Hunt
tinsert(eventQuests, {"Noblegarden", 13480}) -- The Great Egg Hunt
tinsert(eventQuests, {"Noblegarden", 13502}) -- A Tisket, a Tasket, a Noblegarden Basket
tinsert(eventQuests, {"Noblegarden", 13503}) -- A Tisket, a Tasket, a Noblegarden Basket
