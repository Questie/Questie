---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

local tinsert = table.insert
local eventQuests = QuestieEvent.eventQuests

tinsert(eventQuests, {"Winter Veil", 6961}) -- Great-father Winter is Here!
tinsert(eventQuests, {"Winter Veil", 7021}) -- Great-father Winter is Here!
tinsert(eventQuests, {"Winter Veil", 7022}) -- Greatfather Winter is Here!
tinsert(eventQuests, {"Winter Veil", 7023}) -- Greatfather Winter is Here!
tinsert(eventQuests, {"Winter Veil", 7024}) -- Great-father Winter is Here!
tinsert(eventQuests, {"Winter Veil", 6962}) -- Treats for Great-father Winter
tinsert(eventQuests, {"Winter Veil", 7025}) -- Treats for Greatfather Winter
tinsert(eventQuests, {"Winter Veil", 7043, nil, nil, Questie.IsSoD}) -- You're a Mean One...
tinsert(eventQuests, {"Winter Veil", 6983, nil, nil, Questie.IsSoD}) -- You're a Mean One...
tinsert(eventQuests, {"Winter Veil", 6984, nil, nil, Questie.IsSoD}) -- A Smokywood Pastures' Thank You!
tinsert(eventQuests, {"Winter Veil", 7045, nil, nil, Questie.IsSoD}) -- A Smokywood Pastures' Thank You!
tinsert(eventQuests, {"Winter Veil", 7063}) -- The Feast of Winter Veil
tinsert(eventQuests, {"Winter Veil", 7061}) -- The Feast of Winter Veil
tinsert(eventQuests, {"Winter Veil", 6963, nil, nil, Expansions.Current >= Expansions.Cata or Questie.IsSoD}) -- Stolen Winter Veil Treats
tinsert(eventQuests, {"Winter Veil", 7042, nil, nil, Expansions.Current >= Expansions.Cata or Questie.IsSoD}) -- Stolen Winter Veil Treats
tinsert(eventQuests, {"Winter Veil", 7062}) -- The Reason for the Season
tinsert(eventQuests, {"Winter Veil", 8763, nil, nil, Questie.IsSoD}) -- The Hero of the Day
tinsert(eventQuests, {"Winter Veil", 8799, nil, nil, Questie.IsSoD}) -- The Hero of the Day
tinsert(eventQuests, {"Winter Veil", 6964}) -- The Reason for the Season
tinsert(eventQuests, {"Winter Veil", 8762, nil, nil, Questie.IsSoD}) -- Metzen the Reindeer
tinsert(eventQuests, {"Winter Veil", 8746, nil, nil, Questie.IsSoD}) -- Metzen the Reindeer
tinsert(eventQuests, {"Winter Veil", 8744, "25/12", "2/1"}) -- A Carefully Wrapped Present
tinsert(eventQuests, {"Winter Veil", 8767, "25/12", "2/1"}) -- A Gently Shaken Gift
tinsert(eventQuests, {"Winter Veil", 8768, "25/12", "2/1"}) -- A Gaily Wrapped Present
tinsert(eventQuests, {"Winter Veil", 8769, "25/12", "2/1", Questie.IsSoD}) -- A Ticking Present
tinsert(eventQuests, {"Winter Veil", 8788, "25/12", "2/1"}) -- A Gently Shaken Gift
tinsert(eventQuests, {"Winter Veil", 8803, "25/12", "2/1"}) -- A Festive Gift
tinsert(eventQuests, {"Winter Veil", 8827, "25/12", "2/1"}) -- Winter's Presents
tinsert(eventQuests, {"Winter Veil", 8828, "25/12", "2/1"}) -- Winter's Presents
tinsert(eventQuests, {"Winter Veil", 8860, "31/12", "1/1"}) -- New Year Celebrations!
tinsert(eventQuests, {"Winter Veil", 8861, "31/12", "1/1"}) -- New Year Celebrations!

-- SoD quests
tinsert(eventQuests, {"Winter Veil", 79482}) -- Stolen Winter Veil Treats
tinsert(eventQuests, {"Winter Veil", 79483}) -- Stolen Winter Veil Treats
tinsert(eventQuests, {"Winter Veil", 79484}) -- You're a Mean One...
tinsert(eventQuests, {"Winter Veil", 79485}) -- You're a Mean One...
tinsert(eventQuests, {"Winter Veil", 79486}) -- A Smokywood Pastures' Thank You!
tinsert(eventQuests, {"Winter Veil", 79487}) -- A Smokywood Pastures' Thank You!
tinsert(eventQuests, {"Winter Veil", 79492}) -- Metzen the Reindeer
tinsert(eventQuests, {"Winter Veil", 79495}) -- Metzen the Reindeer
tinsert(eventQuests, {"Winter Veil", 79501}) -- The Hero of the Day
tinsert(eventQuests, {"Winter Veil", 79502}) -- The Hero of the Day
tinsert(eventQuests, {"Winter Veil", 79637, "25/12", "2/1"}) -- A Ticking Present

-- TBC quests
tinsert(eventQuests, {"Winter Veil", 11528, "25/12", "2/1", Expansions.Current >= Expansions.Cata}) -- A Winter Veil Gift
tinsert(eventQuests, {"Winter Veil", 13203, "25/12", "2/1", Expansions.Current >= Expansions.Cata}) -- A Winter Veil Gift
tinsert(eventQuests, {"Winter Veil", 13966, "25/12", "2/1", Expansions.Current >= Expansions.Cata}) -- A Winter Veil Gift

-- Cata quests
tinsert(eventQuests, {"Winter Veil", 29382, "25/12", "2/1"}) -- Thanks, But No Thanks
tinsert(eventQuests, {"Winter Veil", 29383, "25/12", "2/1"}) -- Thanks, But No Thanks
tinsert(eventQuests, {"Winter Veil", 29385, "25/12", "2/1"}) -- A Winter Veil Gift
--tinsert(eventQuests, {"Winter Veil", 28878, "25/12", "2/1"}) -- A Winter Veil Gift
