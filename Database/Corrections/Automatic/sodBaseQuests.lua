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
        [78124] = {
            [questKeys.name] = "Nar'thalas Almanac",
            [questKeys.startedBy] = {{211033}},
            [questKeys.finishedBy] = {{211022,211033,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [78127] = {
            [questKeys.name] = "The Dalaran Digest",
            [questKeys.startedBy] = {{211033}},
            [questKeys.finishedBy] = {{211022,211033,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [78142] = {
            [questKeys.name] = "Bewitchments and Glamours",
            [questKeys.startedBy] = {{211033}},
            [questKeys.finishedBy] = {{211022,211033,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [78143] = {
            [questKeys.name] = "Secrets of the Dreamers",
            [questKeys.startedBy] = {{211033}},
            [questKeys.finishedBy] = {{211022,211033,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [78145] = {
            [questKeys.name] = "Arcanic Systems Manual",
            [questKeys.startedBy] = {{211033}},
            [questKeys.finishedBy] = {{211022,211033,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [78146] = {
            [questKeys.name] = "Goaz Scrolls",
            [questKeys.startedBy] = {{211033}},
            [questKeys.finishedBy] = {{211022,211033,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [78147] = {
            [questKeys.name] = "Crimes Against Anatomy",
            [questKeys.startedBy] = {{211033}},
            [questKeys.finishedBy] = {{211022,211033,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [78148] = {
            [questKeys.name] = "Runes of the Sorceror-Kings",
            [questKeys.startedBy] = {{211033}},
            [questKeys.finishedBy] = {{211022,211033,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [78149] = {
            [questKeys.name] = "Fury of the Land",
            [questKeys.startedBy] = {{211033}},
            [questKeys.finishedBy] = {{211022,211033,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [78265] = {
            [questKeys.name] = "Fish Oil",
            [questKeys.startedBy] = {{211653}},
            [questKeys.finishedBy] = {{211653,}},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = 25,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [78266] = {
            [questKeys.name] = "Dark Iron Ordinance",
            [questKeys.startedBy] = {{211653}},
            [questKeys.finishedBy] = {{211653,}},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = 25,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [78267] = {
            [questKeys.name] = "Shredder Turbochargers",
            [questKeys.startedBy] = {{211653}},
            [questKeys.finishedBy] = {{211653,}},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = 25,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [79091] = {
            [questKeys.name] = "Archmage Antonidas: The Unabridged Autobiography",
            [questKeys.startedBy] = {{211033}},
            [questKeys.finishedBy] = {{211033,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [79092] = {
            [questKeys.name] = "Archmage Theocritus's Research Journal",
            [questKeys.startedBy] = {{211033}},
            [questKeys.finishedBy] = {{211033,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [79093] = {
            [questKeys.name] = "Rumi of Gnomeregan: The Collected Works",
            [questKeys.startedBy] = {{211033}},
            [questKeys.finishedBy] = {{211033,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [79094] = {
            [questKeys.name] = "The Lessons of Ta'zo",
            [questKeys.startedBy] = {{211022}},
            [questKeys.finishedBy] = {{211022,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [79095] = {
            [questKeys.name] = "The Apothecary's Metaphysical Primer",
            [questKeys.startedBy] = {{211022}},
            [questKeys.finishedBy] = {{211022,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [79096] = {
            [questKeys.name] = "Ataeric: On Arcane Curiosities",
            [questKeys.startedBy] = {{211022}},
            [questKeys.finishedBy] = {{211022,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [79097] = {
            [questKeys.name] = "Baxtan: On Destructive Magics",
            [questKeys.startedBy] = {{211033}},
            [questKeys.finishedBy] = {{211022,211033,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
    }
end
