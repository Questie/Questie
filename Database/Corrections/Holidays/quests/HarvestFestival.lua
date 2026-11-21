---@type QuestieLoader
local QuestieLoader = select(2, ...).QuestieLoader

---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")

local tinsert = table.insert
local eventQuests = QuestieEvent.eventQuests

tinsert(eventQuests, {"Harvest Festival", 8149}) -- Honoring a Hero
tinsert(eventQuests, {"Harvest Festival", 8150}) -- Honoring a Hero
