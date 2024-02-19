---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

--- Load the base quests for Season of Discovery
--- These are generated, do NOT EDIT the data entries here.
--- If you want to edit an object, do so in sodObjectFixes.lua
function SeasonOfDiscovery:LoadBaseObjects()
    local objectKeys = QuestieDB.objectKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
        [177260] = {
            [objectKeys.name] = "Symbol of Lost Honor",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [386675] = {
            [objectKeys.name] = "Buried Treasure",
            [objectKeys.zoneID] = 12,
            [objectKeys.spawns] = {
                [12] = {{80.3, 79.3},},
                [14] = {{62.1, 94.8},},
                [85] = {{52.9, 54},},
                [141] = {{55.3, 90.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [386691] = {
            [objectKeys.name] = "Library Book",
            [objectKeys.zoneID] = 1537,
            [objectKeys.spawns] = {
                [1537] = {{75.6, 10.4},{75.7, 10.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [386759] = {
            [objectKeys.name] = "Library Book",
            [objectKeys.zoneID] = 12,
            [objectKeys.spawns] = {
                [12] = {{65.4, 70.1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [386777] = {
            [objectKeys.name] = "Dusty Chest",
            [objectKeys.zoneID] = 1519,
            [objectKeys.spawns] = {
                [1519] = {{61.4, 28.9},{61.7, 29.6},{61.9, 29.3},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [387446] = {
            [objectKeys.name] = "Spell Notes",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [387466] = {
            [objectKeys.name] = "Rusty Lockbox",
            [objectKeys.zoneID] = 1,
            [objectKeys.spawns] = {
                [1] = {{47, 52},},
                [12] = {{46.2, 62.1},},
                [14] = {{53.8, 27.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [387477] = {
            [objectKeys.name] = "Defias Stashbox",
            [objectKeys.zoneID] = 12,
            [objectKeys.spawns] = {
                [12] = {{52.6, 51.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [392029] = {
            [objectKeys.name] = "Swordsman's Reward",
            [objectKeys.zoneID] = 1,
            [objectKeys.spawns] = {
                [1] = {{53.3, 47.2},{53.4, 47.7},{53.5, 47.6},{54, 47.4},},
                [12] = {{22.1, 73.8},{22.3, 73.1},{22.5, 73.2},{22.7, 73.5},{23.5, 74.9},{25.1, 69.9},{25.5, 70.1},{29.8, 74.8},{30.4, 72.9},{30.5, 73.9},{30.5, 75.4},{35.6, 83.7},{36, 80.6},{36.1, 80.4},{38.1, 75.1},{38.1, 75.5},{38.5, 76.2},{38.7, 75.1},{40, 72.7},{40.6, 74.4},{40.6, 74.7},},
                [14] = {{35.9, 47.8},{36.1, 47.4},{40.9, 49.3},{41, 49.5},{41.5, 49},{55.1, 39.5},{56, 38.1},{56, 38.5},{56.2, 27.7},{56.4, 21.7},{56.4, 26.7},{56.5, 26.9},{56.7, 21.6},{56.8, 21.2},},
                [85] = {{79.4, 64.6},{79.8, 65.2},{79.9, 65.5},},
                [141] = {{39.8, 37.8},{39.8, 69.7},{43.8, 76.9},{54.7, 66},{62.6, 71.9},},
                [215] = {{38.3, 55.1},{40.7, 53.1},{40.7, 53.8},{45.5, 36.3},{45.5, 37.1},{52, 39.2},{52.7, 40.6},{60.2, 67.6},{60.3, 67.4},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [397987] = {
            [objectKeys.name] = "Kobold Stashbox",
            [objectKeys.zoneID] = 12,
            [objectKeys.spawns] = {
                [12] = {{50.6, 27.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [402215] = {
            [objectKeys.name] = "Charred Note",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [402537] = {
            [objectKeys.name] = "Beast Track",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [402572] = {
            [objectKeys.name] = "Beast Track",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [402573] = {
            [objectKeys.name] = "Beast Track",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [403041] = {
            [objectKeys.name] = "Blasting Supplies",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [403102] = {
            [objectKeys.name] = "Bristleback Loot Cache",
            [objectKeys.zoneID] = 215,
            [objectKeys.spawns] = {
                [215] = {{61.6, 76},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [403105] = {
            [objectKeys.name] = "Windfury Cone",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [403718] = {
            [objectKeys.name] = "Prairie Flower",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [404352] = {
            [objectKeys.name] = "Artifact Storage",
            [objectKeys.zoneID] = 215,
            [objectKeys.spawns] = {
                [215] = {{31.6, 49.4},{31.6, 49.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [404401] = {
            [objectKeys.name] = "Sandy Loam",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [404402] = {
            [objectKeys.name] = "Blooming Satyrweed",
            [objectKeys.zoneID] = 405,
            [objectKeys.spawns] = {
                [405] = {{74.4, 19},{74.5, 19},{75.9, 16.7},{75.9, 21.1},{78.1, 16.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [404433] = {
            [objectKeys.name] = "Lunar Chest",
            [objectKeys.zoneID] = 141,
            [objectKeys.spawns] = {
                [141] = {{52.8, 78.8},},
                [215] = {{35.7, 69.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [404695] = {
            [objectKeys.name] = "Waterlogged Stashbox",
            [objectKeys.zoneID] = 14,
            [objectKeys.spawns] = {
                [14] = {{43, 54.4},{43, 54.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [404830] = {
            [objectKeys.name] = "Dusty Chest",
            [objectKeys.zoneID] = 1637,
            [objectKeys.spawns] = {
                [1637] = {{55.9, 44.7},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [404846] = {
            [objectKeys.name] = "Beast Track",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [404847] = {
            [objectKeys.name] = "Beast Track",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [404888] = {
            [objectKeys.name] = "Beast Track",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [404911] = {
            [objectKeys.name] = "Hidden Cache",
            [objectKeys.zoneID] = 14,
            [objectKeys.spawns] = {
                [14] = {{43.2, 69.6},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [404941] = {
            [objectKeys.name] = "Relic Coffer",
            [objectKeys.zoneID] = 85,
            [objectKeys.spawns] = {
                [85] = {{52.5, 25.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [405149] = {
            [objectKeys.name] = "Mural of Ta'zo",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [405201] = {
            [objectKeys.name] = "Shipwreck Cache",
            [objectKeys.zoneID] = 85,
            [objectKeys.spawns] = {
                [85] = {{66.6, 24.4},{66.6, 24.6},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [405628] = {
            [objectKeys.name] = "Frostmane Loot Cache",
            [objectKeys.zoneID] = 1,
            [objectKeys.spawns] = {
                [1] = {{30.8, 80.1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [405633] = {
            [objectKeys.name] = "Rockjaw Footlocker",
            [objectKeys.zoneID] = 1,
            [objectKeys.spawns] = {
                [1] = {{26.8, 72.6},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [405827] = {
            [objectKeys.name] = "Apothecary Notes",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [405879] = {
            [objectKeys.name] = "Apothecary Society Primer",
            [objectKeys.zoneID] = 85,
            [objectKeys.spawns] = {
                [85] = {{59.4, 52.3},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [405901] = {
            [objectKeys.name] = "Beast Track",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [405902] = {
            [objectKeys.name] = "Beast Track",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [405903] = {
            [objectKeys.name] = "Beast Track",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [405946] = {
            [objectKeys.name] = "Dusty Chest",
            [objectKeys.zoneID] = 1537,
            [objectKeys.spawns] = {
                [1537] = {{51.9, 12.8},{52, 13.6},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [406006] = {
            [objectKeys.name] = "Idol",
            [objectKeys.zoneID] = 141,
            [objectKeys.spawns] = {
                [141] = {{59.7, 42.6},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [406736] = {
            [objectKeys.name] = "Lost Stash",
            [objectKeys.zoneID] = 85,
            [objectKeys.spawns] = {
                [85] = {{24.6, 59.5},{24.7, 59.4},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [406918] = {
            [objectKeys.name] = "Messenger Bag",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{22.4, 24.2},},
            },
            [objectKeys.questStarts] = {79976},
            [objectKeys.questEnds] = {79975},
        },
        [407117] = {
            [objectKeys.name] = "Abandoned Snapjaw Nest",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407120] = {
            [objectKeys.name] = "Empty Snapjaw Nest",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407247] = {
            [objectKeys.name] = "Glade Flower",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407289] = {
            [objectKeys.name] = "Horde Warbanner",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407291] = {
            [objectKeys.name] = "Alliance Warbanner",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407312] = {
            [objectKeys.name] = "Hungry Idol",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407347] = {
            [objectKeys.name] = "Altar of Thorns",
            [objectKeys.zoneID] = 17,
            [objectKeys.spawns] = {
                [17] = {{58.2, 26.7},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407352] = {
            [objectKeys.name] = "Gnarlpine Stash",
            [objectKeys.zoneID] = 141,
            [objectKeys.spawns] = {
                [141] = {{37.9, 82.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407453] = {
            [objectKeys.name] = "Southsea Loot Stash",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407454] = {
            [objectKeys.name] = "Gunpowder Keg",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407457] = {
            [objectKeys.name] = "Stable Hand's Trunk",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407505] = {
            [objectKeys.name] = "Etched Carving",
            [objectKeys.zoneID] = 17,
            [objectKeys.spawns] = {
                [17] = {{44.8, 81.4},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407510] = {
            [objectKeys.name] = "Etched Carving",
            [objectKeys.zoneID] = 17,
            [objectKeys.spawns] = {
                [17] = {{45.4, 80},{45.5, 80},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407566] = {
            [objectKeys.name] = "Goblin Tome",
            [objectKeys.zoneID] = 17,
            [objectKeys.spawns] = {
                [17] = {{62.7, 36.3},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407708] = {
            [objectKeys.name] = "Beast Track",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407709] = {
            [objectKeys.name] = "Beast Track",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407710] = {
            [objectKeys.name] = "Beast Track",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407731] = {
            [objectKeys.name] = "Stonemason's Toolbox",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{46.4, 12.7},{46.5, 12.7},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407732] = {
            [objectKeys.name] = "Escape Rope",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407734] = {
            [objectKeys.name] = "Gnarlpine Cache",
            [objectKeys.zoneID] = 141,
            [objectKeys.spawns] = {
                [141] = {{43.1, 60.8},{44.1, 61.2},{44.5, 62.4},{44.5, 62.5},{44.7, 59},{44.8, 59.9},{45, 61.4},{45.3, 58.1},{45.7, 57},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407844] = {
            [objectKeys.name] = "Libram of Blessings",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{35.7, 49.4},{35.8, 49.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407850] = {
            [objectKeys.name] = "Sunken Reliquary",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{36.8, 91.6},{36.9, 91.4},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407918] = {
            [objectKeys.name] = "Empty Trophy Display",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{83.6, 65.4},{83.6, 65.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407983] = {
            [objectKeys.name] = "Pile of Stolen Books",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{54.2, 27},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [408004] = {
            [objectKeys.name] = "Tangled Blight Pile",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{71.7, 21.4},{71.8, 21.6},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [408014] = {
            [objectKeys.name] = "Gnomish Tome",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{35.6, 48.9},},
                [40] = {{52.7, 53.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [408718] = {
            [objectKeys.name] = "Equipment Stash",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [408799] = {
            [objectKeys.name] = "Idol of the Deep",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [408802] = {
            [objectKeys.name] = "Gnarled Harpoon",
            [objectKeys.zoneID] = 148,
            [objectKeys.spawns] = {
                [148] = {{44.1, 20.8},{47.3, 15.3},{48.3, 18},{49.2, 16.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [408877] = {
            [objectKeys.name] = "Coyote Feeding Ground",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409131] = {
            [objectKeys.name] = "Rusty Chest",
            [objectKeys.zoneID] = 130,
            [objectKeys.spawns] = {
                [130] = {{45.2, 67.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409144] = {
            [objectKeys.name] = "Waterlogged Captain's Chest",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409289] = {
            [objectKeys.name] = "Strange Orb",
            [objectKeys.zoneID] = 148,
            [objectKeys.spawns] = {
                [148] = {{56.2, 26.4},{56.2, 26.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409311] = {
            [objectKeys.name] = "Spear of Mannoroth",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{89.4, 77},{89.5, 77},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {78092},
        },
        [409315] = {
            [objectKeys.name] = "Shattered Orb",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{89.4, 77},{89.5, 77},},
            },
            [objectKeys.questStarts] = {78093},
            [objectKeys.questEnds] = nil,
        },
        [409496] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 148,
            [objectKeys.spawns] = {
                [148] = {{59.6, 22.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409501] = {
            [objectKeys.name] = "Dalaran Digest",
            [objectKeys.zoneID] = 130,
            [objectKeys.spawns] = {
                [130] = {{63.5, 63.1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409562] = {
            [objectKeys.name] = "Spellbook",
            [objectKeys.zoneID] = 40,
            [objectKeys.spawns] = {
                [40] = {{45.4, 70.4},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409692] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409700] = {
            [objectKeys.name] = "Manual",
            [objectKeys.zoneID] = 17,
            [objectKeys.spawns] = {
                [17] = {{56.3, 8.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409711] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 406,
            [objectKeys.spawns] = {
                [406] = {{74.4, 85.7},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409717] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 11,
            [objectKeys.spawns] = {
                [11] = {{33.6, 47.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409731] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{77.4, 14.1},{77.5, 14.1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409735] = {
            [objectKeys.name] = "Spellbook",
            [objectKeys.zoneID] = 10,
            [objectKeys.spawns] = {
                [10] = {{16.5, 28.4},{16.6, 28.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409754] = {
            [objectKeys.name] = "Wall-Mounted Shield",
            [objectKeys.zoneID] = 44,
            [objectKeys.spawns] = {
                [44] = {{69.8, 55.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409758] = {
            [objectKeys.name] = "Discarded Helm",
            [objectKeys.zoneID] = 209,
            [objectKeys.spawns] = {
                [209] = {{-1, -1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409942] = {
            [objectKeys.name] = "Twin Owl Statue",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409949] = {
            [objectKeys.name] = "Twin Owl Statue",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [410020] = {
            [objectKeys.name] = "Owl Statue",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [410034] = {
            [objectKeys.name] = "Carved Stone",
            [objectKeys.zoneID] = 10,
            [objectKeys.spawns] = {
                [10] = {{49.4, 34},{49.5, 34},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [410082] = {
            [objectKeys.name] = "Carved Stone",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{86.9, 43.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [410089] = {
            [objectKeys.name] = "Owl Statue",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [410168] = {
            [objectKeys.name] = "Voodoo Pile",
            [objectKeys.zoneID] = 14,
            [objectKeys.spawns] = {
                [14] = {{68.7, 71.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {78199},
        },
        [410220] = {
            [objectKeys.name] = "Gift of the Wisp",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [410299] = {
            [objectKeys.name] = "Arcane Secrets",
            [objectKeys.zoneID] = 130,
            [objectKeys.spawns] = {
                [130] = {{43.4, 41.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [410369] = {
            [objectKeys.name] = "Dead Drop",
            [objectKeys.zoneID] = 130,
            [objectKeys.spawns] = {
                [130] = {{47.1, 71.1},},
            },
            [objectKeys.questStarts] = {78261,78676},
            [objectKeys.questEnds] = {78261,78307,78676,78699},
        },
        [410528] = {
            [objectKeys.name] = "Ornamented Chest",
            [objectKeys.zoneID] = 209,
            [objectKeys.spawns] = {
                [209] = {{-1, -1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [410779] = {
            [objectKeys.name] = "Offering Box",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [410847] = {
            [objectKeys.name] = "Rusty Safe",
            [objectKeys.zoneID] = 28,
            [objectKeys.spawns] = {
                [28] = {{59.4, 84.6},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [411328] = {
            [objectKeys.name] = "Slumbering Bones",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [411348] = {
            [objectKeys.name] = "Dusty Coffer",
            [objectKeys.zoneID] = 10,
            [objectKeys.spawns] = {
                [10] = {{26, 31},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [411358] = {
            [objectKeys.name] = "Artisan's Chest",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [411620] = {
            [objectKeys.name] = "Altar of Teleportation",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [411674] = {
            [objectKeys.name] = "Prophecy of a King's Demise",
            [objectKeys.zoneID] = 130,
            [objectKeys.spawns] = {
                [130] = {{65.8, 23.4},{65.8, 23.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [411710] = {
            [objectKeys.name] = "Demonic Reliquary",
            [objectKeys.zoneID] = 44,
            [objectKeys.spawns] = {
                [44] = {{80.1, 49.5},{80.2, 49.4},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [411715] = {
            [objectKeys.name] = "Bough of Altek",
            [objectKeys.zoneID] = 148,
            [objectKeys.spawns] = {
                [148] = {{56.2, 26.4},{56.3, 26.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [412147] = {
            [objectKeys.name] = "Supply Locker",
            [objectKeys.zoneID] = 85,
            [objectKeys.spawns] = {
                [85] = {{81.2, 32.1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [412198] = {
            [objectKeys.name] = "Stone Coffer",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1, -1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [412224] = {
            [objectKeys.name] = "Dark Ritual Stone",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{79, 80.3},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {78681},
        },
        [412261] = {
            [objectKeys.name] = "Padlocked Reliquary",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1, -1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [412759] = {
            [objectKeys.name] = "Personal Letterbox",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1, -1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [413699] = {
            [objectKeys.name] = "Large Nest",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [414197] = {
            [objectKeys.name] = "Bough of Shadows",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{89.8, 37.3},{91.2, 37.5},{94, 41.6},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [414532] = {
            [objectKeys.name] = "Clliffspring Chest",
            [objectKeys.zoneID] = 148,
            [objectKeys.spawns] = {
                [148] = {{56.3, 34.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [414624] = {
            [objectKeys.name] = "Lighthouse Stash",
            [objectKeys.zoneID] = 148,
            [objectKeys.spawns] = {
                [148] = {{32.7, 37.1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [414646] = {
            [objectKeys.name] = "Remnant",
            [objectKeys.zoneID] = 148,
            [objectKeys.spawns] = {
                [148] = {{30.4, 48},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [414658] = {
            [objectKeys.name] = "Rubble",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [414663] = {
            [objectKeys.name] = "Shatterspear Idol",
            [objectKeys.zoneID] = 148,
            [objectKeys.spawns] = {
                [148] = {{59.2, 22.6},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [414713] = {
            [objectKeys.name] = "Storage Locker",
            [objectKeys.zoneID] = 267,
            [objectKeys.spawns] = {
                [267] = {{79.7, 40.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [414904] = {
            [objectKeys.name] = "Shrine",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [415106] = {
            [objectKeys.name] = "Burned-Out Remains",
            [objectKeys.zoneID] = 17,
            [objectKeys.spawns] = {
                [17] = {{46.4, 73.9},},
            },
            [objectKeys.questStarts] = {79007,79192},
            [objectKeys.questEnds] = {79008},
        },
        [415107] = {
            [objectKeys.name] = "Burned-Out Remains",
            [objectKeys.zoneID] = 40,
            [objectKeys.spawns] = {
                [40] = {{37.4, 50.6},{37.5, 50.7},},
            },
            [objectKeys.questStarts] = {79008,79192},
            [objectKeys.questEnds] = {79007},
        },
        [415614] = {
            [objectKeys.name] = "Mysterious Formulae",
            [objectKeys.zoneID] = 719,
            [objectKeys.spawns] = {
                [719] = {{-1, -1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [417072] = {
            [objectKeys.name] = "Nailed Plank",
            [objectKeys.zoneID] = 17,
            [objectKeys.spawns] = {
                [17] = {{46.4, 73.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [417353] = {
            [objectKeys.name] = "Extinguished Campfire",
            [objectKeys.zoneID] = 405,
            [objectKeys.spawns] = {
                [405] = {{47.5, 54.6},},
            },
            [objectKeys.questStarts] = {79229},
            [objectKeys.questEnds] = nil,
        },
        [418855] = {
            [objectKeys.name] = "Illari's Loot Cache",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{94.1, 69.3},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {79242},
        },
        [419741] = {
            [objectKeys.name] = "Sacrificial Altar",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [420054] = {
            [objectKeys.name] = "Rowboat",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [420055] = {
            [objectKeys.name] = "Rowboat",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [421007] = {
            [objectKeys.name] = "Boulder",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [421025] = {
            [objectKeys.name] = "Boulder",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [421526] = {
            [objectKeys.name] = "Research Notes",
            [objectKeys.zoneID] = 33,
            [objectKeys.spawns] = {
                [33] = {{41.5, 50.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [421568] = {
            [objectKeys.name] = "Weathered Cache",
            [objectKeys.zoneID] = 400,
            [objectKeys.spawns] = {
                [400] = {{46.8, 53.4},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [422483] = {
            [objectKeys.name] = "The Salvagematic 9000",
            [objectKeys.zoneID] = 721,
            [objectKeys.spawns] = {
                [721] = {{-1, -1},},
            },
            [objectKeys.questStarts] = {79626},
            [objectKeys.questEnds] = {79626},
        },
        [422895] = {
            [objectKeys.name] = "Tear of Theradras",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [422896] = {
            [objectKeys.name] = "Tear of Theradras",
            [objectKeys.zoneID] = 405,
            [objectKeys.spawns] = {
                [405] = {{27.8, 57.7},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [422902] = {
            [objectKeys.name] = "Crystal Waters of Lake Elune'ara",
            [objectKeys.zoneID] = 493,
            [objectKeys.spawns] = {
                [493] = {{55.6, 66.3},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [422911] = {
            [objectKeys.name] = "Sealed Barrel",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{21.4, 83.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [422919] = {
            [objectKeys.name] = "Tapped Shadowforge Keg",
            [objectKeys.zoneID] = 3,
            [objectKeys.spawns] = {
                [3] = {{41.2, 27.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423569] = {
            [objectKeys.name] = "Dropped Pouch",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{93.8, 71.4},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423695] = {
            [objectKeys.name] = "Libram of Deliverance",
            [objectKeys.zoneID] = 405,
            [objectKeys.spawns] = {
                [405] = {{66.5, 7.4},{66.5, 7.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423703] = {
            [objectKeys.name] = "Broken Warhammer",
            [objectKeys.zoneID] = 405,
            [objectKeys.spawns] = {
                [405] = {{52.7, 84.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423841] = {
            [objectKeys.name] = "Frozen Remains",
            [objectKeys.zoneID] = 36,
            [objectKeys.spawns] = {
                [36] = {{39.8, 60.7},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423895] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 400,
            [objectKeys.spawns] = {
                [400] = {{34.4, 40},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423896] = {
            [objectKeys.name] = "Manual",
            [objectKeys.zoneID] = 36,
            [objectKeys.spawns] = {
                [36] = {{48.4, 57.7},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423897] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{73.6, 65.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423898] = {
            [objectKeys.name] = "Mysterious Book",
            [objectKeys.zoneID] = 405,
            [objectKeys.spawns] = {
                [405] = {{55.1, 26.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423899] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 3,
            [objectKeys.spawns] = {
                [3] = {{56.6, 39.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423900] = {
            [objectKeys.name] = "Waterlogged Book",
            [objectKeys.zoneID] = 15,
            [objectKeys.spawns] = {
                [15] = {{57.1, 20.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423901] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 8,
            [objectKeys.spawns] = {
                [8] = {{61.4, 22.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423920] = {
            [objectKeys.name] = "Warrior's Bounty",
            [objectKeys.zoneID] = 400,
            [objectKeys.spawns] = {
                [400] = {{67.9, 89.3},{67.9, 89.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423926] = {
            [objectKeys.name] = "Conspicuous Cache",
            [objectKeys.zoneID] = 8,
            [objectKeys.spawns] = {
                [8] = {{42.7, 30.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423930] = {
            [objectKeys.name] = "Sizable Stolen Strongbox",
            [objectKeys.zoneID] = 400,
            [objectKeys.spawns] = {
                [400] = {{18.7, 21},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424002] = {
            [objectKeys.name] = "Kurzen Supply Crate",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424003] = {
            [objectKeys.name] = "Cage",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424005] = {
            [objectKeys.name] = "Pocket Litter",
            [objectKeys.zoneID] = 406,
            [objectKeys.spawns] = {
                [406] = {{40.8, 52.5},},
            },
            [objectKeys.questStarts] = {79980},
            [objectKeys.questEnds] = {79192},
        },
        [424006] = {
            [objectKeys.name] = "Hastily Rolled-Up Satchel",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{22.4, 24.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {79976},
        },
        [424007] = {
            [objectKeys.name] = "Carved Figurine",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{49.3, 12.8},},
            },
            [objectKeys.questStarts] = {79975},
            [objectKeys.questEnds] = {79974},
        },
        [424010] = {
            [objectKeys.name] = "Nailed Plank",
            [objectKeys.zoneID] = 40,
            [objectKeys.spawns] = {
                [40] = {{37.4, 50.9},{37.5, 50.8},},
            },
            [objectKeys.questStarts] = {79192},
            [objectKeys.questEnds] = {79007},
        },
        [424012] = {
            [objectKeys.name] = "Mound of Dirt",
            [objectKeys.zoneID] = 406,
            [objectKeys.spawns] = {
                [406] = {{39.6, 49.9},},
            },
            [objectKeys.questStarts] = {79974},
            [objectKeys.questEnds] = {79980},
        },
        [424073] = {
            [objectKeys.name] = "Wondergear Worldporter",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424074] = {
            [objectKeys.name] = "Quadrangulation Beacon 001",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424075] = {
            [objectKeys.name] = "Quadrangulation Beacon 002",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424076] = {
            [objectKeys.name] = "Quadrangulation Beacon 003",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424077] = {
            [objectKeys.name] = "Quadrangulation Beacon 004",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424079] = {
            [objectKeys.name] = "Long Rifle",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424082] = {
            [objectKeys.name] = "Firepit",
            [objectKeys.zoneID] = 406,
            [objectKeys.spawns] = {
                [406] = {{40.6, 52.4},},
            },
            [objectKeys.questStarts] = {80001},
            [objectKeys.questEnds] = {80001},
        },
        [424110] = {
            [objectKeys.name] = "Swordsman's Reward",
            [objectKeys.zoneID] = 3,
            [objectKeys.spawns] = {
                [3] = {{14.5, 44.8},{33.5, 68.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424264] = {
            [objectKeys.name] = "Grave",
            [objectKeys.zoneID] = 15,
            [objectKeys.spawns] = {
                [15] = {{63.7, 42.4},{63.7, 42.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424265] = {
            [objectKeys.name] = "Grave",
            [objectKeys.zoneID] = 8,
            [objectKeys.spawns] = {
                [8] = {{16.7, 53.7},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424266] = {
            [objectKeys.name] = "Grave",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1, -1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424267] = {
            [objectKeys.name] = "Grave",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{62.2, 54.5},{62.3, 54.4},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424373] = {
            [objectKeys.name] = "Remnant",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1, -1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [425896] = {
            [objectKeys.name] = "Archivists of the Monastery",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1, -1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [425897] = {
            [objectKeys.name] = "Archivists of the Monastery",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1, -1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [425898] = {
            [objectKeys.name] = "Archivists of the Monastery",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1, -1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [425899] = {
            [objectKeys.name] = "Archivists of the Monastery",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1, -1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [428144] = {
            [objectKeys.name] = "Fount",
            [objectKeys.zoneID] = 33,
            [objectKeys.spawns] = {
                [33] = {{23.6, 8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [428228] = {
            [objectKeys.name] = "Conspicuous Cache",
            [objectKeys.zoneID] = 8,
            [objectKeys.spawns] = {
                [8] = {{42.6, 30.7},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
    }
end
