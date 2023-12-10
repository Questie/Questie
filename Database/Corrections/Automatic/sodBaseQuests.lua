---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

--- Load the base quests for Season of Discovery
--- These are generated, do NOT EDIT the data entries here.
--- If you want to edit a quest, do so in sodQuestFixes.lua
function SeasonOfDiscovery:LoadBaseQuests()
    local questKeys = QuestieDB.questKeys
    local zoneIDs = ZoneDB.zoneIDs
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local sortKeys = QuestieDB.sortKeys

    return {
        [78916] = {
            [questKeys.name] = "The Heart of the Void",
            [questKeys.startedBy] = nil,
            [questKeys.finishedBy] = nil,
            [questKeys.requiredLevel] = 25,
            [questKeys.questLevel] = 25,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Bring the Blackfathom Pearl to Dawnwatcher Selgorm in Darnassus."},
        },
        [78917] = {
            [questKeys.name] = "The Heart of the Void",
            [questKeys.startedBy] = nil,
            [questKeys.finishedBy] = nil,
            [questKeys.requiredLevel] = 25,
            [questKeys.questLevel] = 25,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Bring the Blackfathom Pearl to Bashana Runetotem in Thunder Bluff."},
        },
        [78920] = {
            [questKeys.name] = "Baron Aquanis",
            [questKeys.startedBy] = nil,
            [questKeys.finishedBy] = {{12736,}},
            [questKeys.requiredLevel] = 25,
            [questKeys.questLevel] = 27,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Bring the Strange Water Globe to Je'neu Sancrea at Zoram'gar Outpost, Ashenvale."},
        },
        [78921] = {
            [questKeys.name] = "Blackfathom Villainy",
            [questKeys.startedBy] = {{4787}},
            [questKeys.finishedBy] = {{4783,}},
            [questKeys.requiredLevel] = 25,
            [questKeys.questLevel] = 27,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Bring the head of Twilight Lord Kelris to Dawnwatcher Selgorm in Darnassus."},
        },
        [78922] = {
            [questKeys.name] = "Blackfathom Villainy",
            [questKeys.startedBy] = {{4787}},
            [questKeys.finishedBy] = {{9087,}},
            [questKeys.requiredLevel] = 25,
            [questKeys.questLevel] = 27,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Bring the head of Twilight Lord Kelris to Bashana Runetotem in Thunder Bluff."},
        },
        [78923] = {
            [questKeys.name] = "Knowledge in the Deeps",
            [questKeys.startedBy] = {{2786}},
            [questKeys.finishedBy] = {{2786,}},
            [questKeys.requiredLevel] = 25,
            [questKeys.questLevel] = 27,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Bring the Lorgalis Manuscript to Gerrig Bonegrip in the Forlorn Cavern in Ironforge."},
        },
        [78925] = {
            [questKeys.name] = "Twilight Falls",
            [questKeys.startedBy] = {{4784}},
            [questKeys.finishedBy] = {{4784,}},
            [questKeys.requiredLevel] = 25,
            [questKeys.questLevel] = 27,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Bring 10 Twilight Pendants to Argent Guard Manados in Darnassus."},
        },
        [78926] = {
            [questKeys.name] = "Researching the Corruption",
            [questKeys.startedBy] = {{8997}},
            [questKeys.finishedBy] = {{8997,}},
            [questKeys.requiredLevel] = 25,
            [questKeys.questLevel] = 27,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Gershala Nightwhisper in Auberdine wants 8 Corrupt Brain stems."},
        },
        [78927] = {
            [questKeys.name] = "Allegiance to the Old Gods",
            [questKeys.startedBy] = {{12736}},
            [questKeys.finishedBy] = {{12736,}},
            [questKeys.requiredLevel] = 25,
            [questKeys.questLevel] = 27,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Kill Lorgus Jett in Blackfathom Deeps and then return to Je'neu Sancrea in Ashenvale."},
        },
        [79099] = {
            [questKeys.name] = "Baron Aquanis",
            [questKeys.startedBy] = {{214876}},
            [questKeys.finishedBy] = {{214876,}},
            [questKeys.requiredLevel] = 25,
            [questKeys.questLevel] = 27,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Bring the Strange Water Globe to Davidus Voidstar in Auberdine, Darkshore."},
        },

    }
end
