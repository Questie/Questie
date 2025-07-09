---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")

local tinsert = table.insert
local eventQuests = QuestieEvent.eventQuests

tinsert(eventQuests, {"Love is in the Air", 8897}) -- Dearest Colara
tinsert(eventQuests, {"Love is in the Air", 8898}) -- Dearest Colara
tinsert(eventQuests, {"Love is in the Air", 8899}) -- Dearest Colara
tinsert(eventQuests, {"Love is in the Air", 8900}) -- Dearest Elenia
tinsert(eventQuests, {"Love is in the Air", 8901}) -- Dearest Elenia
tinsert(eventQuests, {"Love is in the Air", 8902}) -- Dearest Elenia
tinsert(eventQuests, {"Love is in the Air", 8903}) -- Dangerous Love
tinsert(eventQuests, {"Love is in the Air", 8904}) -- Dangerous Love
tinsert(eventQuests, {"Love is in the Air", 8979}) -- Fenstad's Hunch
tinsert(eventQuests, {"Love is in the Air", 8980}) -- Zinge's Assessment
tinsert(eventQuests, {"Love is in the Air", 8981, nil, nil, Questie.IsClassic}) -- Gift Giving
tinsert(eventQuests, {"Love is in the Air", 8982}) -- Tracing the Source
tinsert(eventQuests, {"Love is in the Air", 8983}) -- Tracing the Source
tinsert(eventQuests, {"Love is in the Air", 8984}) -- The Source Revealed
tinsert(eventQuests, {"Love is in the Air", 8993, nil, nil, Questie.IsClassic}) -- Gift Giving
tinsert(eventQuests, {"Love is in the Air", 9024}) -- Aristan's Hunch
tinsert(eventQuests, {"Love is in the Air", 9025}) -- Morgan's Discovery
tinsert(eventQuests, {"Love is in the Air", 9026}) -- Tracing the Source
tinsert(eventQuests, {"Love is in the Air", 9027}) -- Tracing the Source
tinsert(eventQuests, {"Love is in the Air", 9028}) -- The Source Revealed
tinsert(eventQuests, {"Love is in the Air", 9029}) -- A Bubbling Cauldron

-- WotLK quests
tinsert(eventQuests, {"Love is in the Air", 14483}) -- Something is in the Air (and it Ain't Love)
tinsert(eventQuests, {"Love is in the Air", 14488}) -- You've Been Served
tinsert(eventQuests, {"Love is in the Air", 24597}) -- A Gift for the King of Stormwind
tinsert(eventQuests, {"Love is in the Air", 24609}) -- A Gift for the Lord of Ironforge
tinsert(eventQuests, {"Love is in the Air", 24610}) -- A Gift for the High Priestess of Elune
tinsert(eventQuests, {"Love is in the Air", 24611}) -- A Gift for the Prophet
tinsert(eventQuests, {"Love is in the Air", 24612}) -- A Gift for the Warchief
tinsert(eventQuests, {"Love is in the Air", 24613}) -- A Gift for the Banshee Queen
tinsert(eventQuests, {"Love is in the Air", 24614}) -- A Gift for the High Chieftain
tinsert(eventQuests, {"Love is in the Air", 24615}) -- A Gift for the Regent Lord of Quel'Thalas
tinsert(eventQuests, {"Love is in the Air", 24629}) -- A Perfect Puff of Perfume
tinsert(eventQuests, {"Love is in the Air", 24635}) -- A Cloudlet of Classy Cologne
tinsert(eventQuests, {"Love is in the Air", 24636}) -- Bonbon Blitz
tinsert(eventQuests, {"Love is in the Air", 24536}) -- Something Stinks
tinsert(eventQuests, {"Love is in the Air", 24655}) -- Something Stinks
tinsert(eventQuests, {"Love is in the Air", 24541}) -- Pilfering Perfume
tinsert(eventQuests, {"Love is in the Air", 24656}) -- Pilfering Perfume
tinsert(eventQuests, {"Love is in the Air", 24745}) -- Something is in the Air (and it Ain't Love)
tinsert(eventQuests, {"Love is in the Air", 24804}) -- Uncommon Scents
tinsert(eventQuests, {"Love is in the Air", 24805}) -- Uncommon Scents

tinsert(eventQuests, {"Love is in the Air", 24576}) -- A Friendly Chat...
tinsert(eventQuests, {"Love is in the Air", 24657}) -- A Friendly Chat...

-- These seem to be breadcrumbs to "You've Been Served" (14488) but aren't available
-- Might either not be in game at all or guarded behind finishing one of the two "A Friendly Chat..." quests above
tinsert(eventQuests, {"Love is in the Air", 24792}) -- Man on the Inside
tinsert(eventQuests, {"Love is in the Air", 24793}) -- Man on the Inside

tinsert(eventQuests, {"Love is in the Air", 24848}) -- Fireworks At The Gilded Rose
tinsert(eventQuests, {"Love is in the Air", 24849}) -- Hot On The Trail
tinsert(eventQuests, {"Love is in the Air", 24850}) -- Snivel's Sweetheart
tinsert(eventQuests, {"Love is in the Air", 24851}) -- Hot On The Trail

-- These "Crushing the Crown" quests are dailies, handed out based on the player's current level.
-- The Durotar + Elwynn quests are available at level 5, with each successive quest being available
-- at 14, 23, 32, 41, 51, 61, and 71, respectively. They are exclusive to each other; once you hit 14,
-- you can no longer pick up the level 5 quest. However, since we have no way of filtering quests based
-- on a "maximum" level, we simply hide all of the higher level ones, which will be picked up automatically
-- instead of the level 5 one. Users can only tell the difference if they're watching quest IDs.
-- TODO: If we implement maxLevel, these hacky workarounds should be implemented properly.
tinsert(eventQuests, {"Love is in the Air", 24638}) -- Crushing the Crown (Durotar)
tinsert(eventQuests, {"Love is in the Air", 24645}) -- Crushing the Crown (Ambermill)
tinsert(eventQuests, {"Love is in the Air", 24647}) -- Crushing the Crown (Hillsbrad H)
tinsert(eventQuests, {"Love is in the Air", 24648}) -- Crushing the Crown (Theramore H)
tinsert(eventQuests, {"Love is in the Air", 24649}) -- Crushing the Crown (Aerie Peak H)
tinsert(eventQuests, {"Love is in the Air", 24650}) -- Crushing the Crown (Everlook H)
tinsert(eventQuests, {"Love is in the Air", 24651}) -- Crushing the Crown (Shattrath H)
tinsert(eventQuests, {"Love is in the Air", 24652}) -- Crushing the Crown (Crystalsong H)
tinsert(eventQuests, {"Love is in the Air", 24658}) -- Crushing the Crown (Elwynn)
tinsert(eventQuests, {"Love is in the Air", 24659}) -- Crushing the Crown (Darkshore)
tinsert(eventQuests, {"Love is in the Air", 24660}) -- Crushing the Crown (Hillsbrad A)
tinsert(eventQuests, {"Love is in the Air", 24662}) -- Crushing the Crown (Theramore A)
tinsert(eventQuests, {"Love is in the Air", 24663}) -- Crushing the Crown (Aerie Peak A)
tinsert(eventQuests, {"Love is in the Air", 24664}) -- Crushing the Crown (Everlook A)
tinsert(eventQuests, {"Love is in the Air", 24665}) -- Crushing the Crown (Shattrath A)
tinsert(eventQuests, {"Love is in the Air", 24666}) -- Crushing the Crown (Crystalsong A)

-- Cata quests
tinsert(eventQuests, {"Love is in the Air", 28934}) -- Crushing the Crown (Uldum A)
tinsert(eventQuests, {"Love is in the Air", 28935}) -- Crushing the Crown (Uldum H)
