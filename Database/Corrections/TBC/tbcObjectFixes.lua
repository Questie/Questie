---@class QuestieTBCObjectFixes
local QuestieTBCObjectFixes = QuestieLoader:CreateModule("QuestieTBCObjectFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function QuestieTBCObjectFixes:Load()
    QuestieDB.objectData[184588] = {}; -- Captain Tyralis's Prison
    QuestieDB.objectData[190483] = {}; -- Document chest
    QuestieDB.objectData[190484] = {}; -- Document chest
    QuestieDB.objectData[400000] = {};
    QuestieDB.objectData[400001] = {};
    QuestieDB.objectData[400002] = {};
    QuestieDB.objectData[400003] = {};
    QuestieDB.objectData[400004] = {};
    QuestieDB.objectData[400005] = {};
    QuestieDB.objectData[400006] = {};
    QuestieDB.objectData[400007] = {};
    QuestieDB.objectData[400008] = {};
    QuestieDB.objectData[400009] = {};
    QuestieDB.objectData[400010] = {};
    QuestieDB.objectData[400011] = {};
    QuestieDB.objectData[400012] = {};

    local objectKeys = QuestieDB.objectKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
        [177281] = {
            [objectKeys.spawns] = {[zoneIDs.ZANGARMARSH]={{80.32,65.06},},},
        },
        [177790] = {
            [objectKeys.spawns] = {[zoneIDs.SILVERPINE_FOREST]={{29.56,29.2},},},
        },
        [181138] = {
            [objectKeys.spawns] = {[zoneIDs.GHOSTLANDS]={{12.53,26.51},{14.7,26.4},{13.69,26.84},},},
        },
        [181697] = {
            [objectKeys.spawns] = {[zoneIDs.AZUREMYST_ISLE]={{33.7,74.4},{37,69.4},{37,69.5},{38,72},{38.2,69.4},{38.2,69.6},{38.8,74.4},{38.8,74.6},{39.9,69.5},{39.9,71.2},{39.9,71.5},{40,69.2},{41.3,67.1},{42.4,66.1},{42.4,68.8},{42.6,66},{42.6,68.9},{43.9,65.8},{44.4,69},{44.6,68.8},{44.8,70.4},{44.8,70.5},{46.3,66.3},{46.5,66.2},{48.3,64.9},{48.5,64.7},{49.3,61.9},{50.1,57.4},{50.1,57.5},{50.2,60.1},{50.3,63.3},{50.3,66.9},{50.4,63.5},{50.5,63.1},{51.1,64.7},{51.4,65.9},{51.5,66},{52.8,67},{54.4,64.4},{54.4,64.5},{54.5,64.4},{54.5,64.5},{55.4,62},{55.5,62.1},{55.7,63.9},{57,63.6},},},
        },
        [181746] = {
            [objectKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{38.5,22.5},{40.6,20.1},{44,22.5},{46.4,20.5},},},
            [objectKeys.zoneID] = zoneIDs.BLOODMYST_ISLE,
        },
        [181757] = {
            [objectKeys.spawns] = {[zoneIDs.AZUREMYST_ISLE]={{33.3,26.1},{33.4,26.7},{33.5,26.5},{33.6,26.4},{33.7,18.7},{33.9,15.5},{34.1,14.7},{34.8,22.1},{34.9,12},},},
            [objectKeys.zoneID] = zoneIDs.AZUREMYST_ISLE,
        },
        [181781] = {
            [objectKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{41,30},},},
            [objectKeys.zoneID] = zoneIDs.BLOODMYST_ISLE,
        },
        [181897] = {
            [objectKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{68.3,21.7},{69.98,26.3},{70.6,16.5},{71.4,11.7},{71.4,28.2},{72.7,21.4},{74.7,16.3},{75,8.7},{75.4,19.1},{75.7,28.4},{75.54,13.85},{76,24.8},{76.8,21.4},},},
        },
        [182116] = {
            [objectKeys.spawns] = {[zoneIDs.ZANGARMARSH]={{61.5,56.1},{62.4,53.0},{62.4,59.2},{62.5,53.0},{62.5,59.2},{62.9,45.5},{63.0,45.4},{64.1,51.2},{64.8,49.3},{64.8,49.5},{65.0,53.8},{65.4,50.6},{65.6,50.7},{65.8,47.5},{65.9,47.4},{66.0,62.2},{66.1,46.4},{66.4,52.1},{66.5,52.1},{66.6,47.9},{67.3,50.1},{67.3,54.7},{67.7,53.4},{68.0,48.3},{68.3,44.7},{68.3,53.7},{68.6,54.4},{68.6,54.5},{68.8,47.8},{70.2,47.9},{70.7,50.2},{71.0,53.9},{71.1,51.7},{71.2,47.2},{71.6,45.4},{71.6,45.5},{73.1,46.8},},},
        },
        [182950] = {
            [objectKeys.factionID] = 80,
        },
        [183050] = {
            [objectKeys.spawns] = {[zoneIDs.SETHEKK_HALLS]={{-1,-1}}},
        },
        [184588] = {
            [objectKeys.name] = "Captain Tyralius's Prison",
            [objectKeys.spawns] = {[zoneIDs.NETHERSTORM] = {{53.3,41.4}}},
            [objectKeys.zoneID] = zoneIDs.NETHERSTORM,
        },
        [184980] = {
            [objectKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA]={{45.9,28.2},{46.2,29.1},{46.4,32.5},{46.5,28.6},{46.6,29.5},{46.6,32.6},{46.7,32.4},{46.7,39.6},{46.8,28.3},{46.8,39.3},{46.8,40.7},{46.9,35.6},{46.9,37.4},{46.9,37.6},{47.3,35.2},{47.4,30.7},{47.5,29.1},{47.5,34.4},{47.5,35.3},{47.5,35.9},{47.7,30.7},{47.8,32.5},{48.1,30.1},{48.3,31.9},{48.6,29.6},{48.8,29.0},{48.9,30.9},{48.9,31.5},{49.4,28.1},{49.4,42.8},{49.6,28.4},{49.6,31.3},{49.7,29.8},{50.0,28.7},{50.0,38.4},{50.1,43.5},{50.2,35.9},{50.2,38.6},{50.2,40.5},{50.2,43.2},{50.2,44.9},{50.2,45.7},{50.3,27.4},{50.3,37.4},{50.3,40.3},{50.4,41.5},{50.5,28.7},{50.5,38.6},{50.6,42.9},{50.7,38.1},{50.7,40.0},{50.8,26.6},{50.8,29.6},{50.8,43.5},{50.8,44.7},{51.0,26.0},{51.0,27.9},{51.3,23.5},{51.3,31.2},{51.4,40.5},{51.5,40.7},{51.5,44.2},{51.5,44.7},{51.6,21.4},{51.8,22.8},{52.2,22.2},{52.8,44.3},{52.8,44.5},{53.4,45.7},{53.5,43.8},{53.8,44.8},{55.2,45.5},},},
        },
        [184998] = {
            [objectKeys.name] = "Ethereum Prison",
        },
        [185460] = {
            [objectKeys.name] = "Ethereum Prison",
        },
        [185574] = {
            [objectKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST]={{20.5,17.8}}},
        },
        [186273] = {
            [objectKeys.spawns] = {[zoneIDs.DUSTWALLOW_MARSH]={{61.7,18.2},},},
        },
        [187260] = {
            [objectKeys.spawns] = {[zoneIDs.FELWOOD]={{34.82,52.95}}}, -- TBC only Mailbox
        }, 
        [188123] = {
            [objectKeys.spawns] = {[zoneIDs.DARNASSUS]={{67.18,16.47}}}, -- TBC only Mailbox
        },
        [190483] = {
            [objectKeys.name] = "Document Chest",
            [objectKeys.spawns] = {[zoneIDs.THOUSAND_NEEDLES]={{33.76,39.99},},},
            [objectKeys.zoneID] = zoneIDs.THOUSAND_NEEDLES,
        },
        [190484] = {
            [objectKeys.name] = "Document Chest",
            [objectKeys.spawns] = {[zoneIDs.THOUSAND_NEEDLES]={{39.34,41.53},},},
            [objectKeys.zoneID] = zoneIDs.THOUSAND_NEEDLES,
        },

        -- Below are fake objects
        [400000] = {
            [objectKeys.name] = "Mailbox",
            [objectKeys.questStarts] = {9672},
            [objectKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{55.2,59.2},},},
            [objectKeys.zoneID] = zoneIDs.BLOODMYST_ISLE,
        },
        [400001] = {
            [objectKeys.name] = "Open the Survival Kit",
            [objectKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{40.5,19},},},
            [objectKeys.zoneID] = zoneIDs.ORGRIMMAR,
        },
        [400002] = {
            [objectKeys.name] = "Equip a Weapon",
            [objectKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{39.5,19},},},
            [objectKeys.zoneID] = zoneIDs.ORGRIMMAR,
        },
        [400003] = {
            [objectKeys.name] = "Open the Survival Kit",
            [objectKeys.spawns] = {[zoneIDs.THUNDER_BLUFF]={{76.8,29.7},},},
            [objectKeys.zoneID] = zoneIDs.THUNDER_BLUFF,
        },
        [400004] = {
            [objectKeys.name] = "Equip a Weapon",
            [objectKeys.spawns] = {[zoneIDs.THUNDER_BLUFF]={{76.8,29.7},},},
            [objectKeys.zoneID] = zoneIDs.THUNDER_BLUFF,
        },
        [400005] = {
            [objectKeys.name] = "Train a Spell at your class trainer",
            [objectKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{40,19},},},
            [objectKeys.zoneID] = zoneIDs.ORGRIMMAR,
        },
        [400006] = {
            [objectKeys.name] = "Train a Spell at your class trainer",
            [objectKeys.spawns] = {[zoneIDs.THUNDER_BLUFF]={{77.15,29.82},},},
            [objectKeys.zoneID] = zoneIDs.THUNDER_BLUFF,
        },
        [400007] = {
            [objectKeys.name] = "Spend a Talent Point",
            [objectKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{40,19},},},
            [objectKeys.zoneID] = zoneIDs.ORGRIMMAR,
        },
        [400008] = {
            [objectKeys.name] = "Spend a Talent Point",
            [objectKeys.spawns] = {[zoneIDs.THUNDER_BLUFF]={{77.15,29.82},},},
            [objectKeys.zoneID] = zoneIDs.THUNDER_BLUFF,
        },
        [400009] = {
            [objectKeys.name] = "Open the Survival Kit",
            [objectKeys.spawns] = {[zoneIDs.STORMWIND_CITY]={{83.5,37},},},
            [objectKeys.zoneID] = zoneIDs.STORMWIND_CITY,
        },
        [400010] = {
            [objectKeys.name] = "Equip a Weapon",
            [objectKeys.spawns] = {[zoneIDs.STORMWIND_CITY]={{84.5,37},},},
            [objectKeys.zoneID] = zoneIDs.STORMWIND_CITY,
        },
        [400011] = {
            [objectKeys.name] = "Train a Spell at your class trainer",
            [objectKeys.spawns] = {[zoneIDs.STORMWIND_CITY]={{84,37},},},
            [objectKeys.zoneID] = zoneIDs.STORMWIND_CITY,
        },
        [400012] = {
            [objectKeys.name] = "Spend a Talent Point",
            [objectKeys.spawns] = {[zoneIDs.STORMWIND_CITY]={{84,37},},},
            [objectKeys.zoneID] = zoneIDs.STORMWIND_CITY,
        },
    }
end
