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
        [175755] = {
            [objectKeys.name] = "The Alliance Splinters",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [176366] = {
            [objectKeys.name] = "Pet Fish",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [177260] = {
            [objectKeys.name] = "Symbol of Lost Honor",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [386675] = {
            [objectKeys.name] = "Buried Treasure",
            [objectKeys.zoneID] = 1,
            [objectKeys.spawns] = {
                [1] = {{47, 43.7},},
                [12] = {{80.3, 79.3},{80.5, 79.2},},
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
                [1] = {{53.4, 47.8},{53.5, 47.8},},
                [12] = {{22.3, 73.3},{30, 73.4},{36, 80.6},{38.2, 75.3},{38.6, 75.6},{40.9, 74.7},},
                [14] = {{40.9, 49.3},{56.7, 21.4},{56.7, 21.7},},
                [215] = {{46, 36.1},{52.2, 39},},
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
                [405] = {{74.4, 18.9},{74.5, 19},{75.9, 16.6},{75.9, 21.1},},
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
                [85] = {{52.4, 25.8},{52.5, 25.8},},
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
                [85] = {{66.6, 24.4},{66.7, 24.6},},
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
                [1537] = {{51.9, 13},{52, 13.6},},
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
                [45] = {{22.4, 24.2},{22.5, 24.2},},
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
                [38] = {{36.8, 91.4},{36.8, 91.5},},
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
                [331] = {{89.4, 77.1},{89.5, 77},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {78092},
        },
        [409315] = {
            [objectKeys.name] = "Shattered Orb",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{89.4, 77.1},{89.5, 77},},
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
                [130] = {{63.5, 63.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409562] = {
            [objectKeys.name] = "Spellbook",
            [objectKeys.zoneID] = 40,
            [objectKeys.spawns] = {
                [40] = {{45.4, 70.4},{45.4, 70.5},},
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
                [38] = {{77.4, 14},{77.5, 14},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409735] = {
            [objectKeys.name] = "Spellbook",
            [objectKeys.zoneID] = 10,
            [objectKeys.spawns] = {
                [10] = {{16.6, 28.5},{16.7, 28.4},},
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
            [objectKeys.questStarts] = {78261,78676,80455},
            [objectKeys.questEnds] = {78261,78307,78676,78699,80454},
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
                [331] = {{89.8, 37.3},{89.8, 37.5},{91.2, 37.5},{92.5, 40.4},{94, 41.6},},
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
                [267] = {{79.7, 41},},
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
            [objectKeys.questStarts] = {79192},
            [objectKeys.questEnds] = {79008},
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
                [400] = {{46.8, 53.4},{46.8, 53.5},},
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
            [objectKeys.questEnds] = {79626,79704},
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
                [405] = {{27.7, 57.4},{27.8, 57.7},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [422902] = {
            [objectKeys.name] = "Crystal Waters of Lake Elune'ara",
            [objectKeys.zoneID] = 493,
            [objectKeys.spawns] = {
                [493] = {{55.7, 66.3},{55.8, 66.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [422911] = {
            [objectKeys.name] = "Sealed Barrel",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{21.3, 84},{21.5, 83.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [422919] = {
            [objectKeys.name] = "Tapped Shadowforge Keg",
            [objectKeys.zoneID] = 3,
            [objectKeys.spawns] = {
                [3] = {{41.3, 27.9},{41.5, 28.1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423569] = {
            [objectKeys.name] = "Dropped Pouch",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{93.4, 71.1},{93.5, 70.4},{93.8, 71.4},{93.8, 71.5},},
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
                [36] = {{39.7, 60.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423895] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 400,
            [objectKeys.spawns] = {
                [400] = {{34.4, 40.1},{34.5, 40.1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423896] = {
            [objectKeys.name] = "Manual",
            [objectKeys.zoneID] = 36,
            [objectKeys.spawns] = {
                [36] = {{48.4, 57.7},{48.5, 57.7},},
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
                [3] = {{56.7, 39.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423900] = {
            [objectKeys.name] = "Waterlogged Book",
            [objectKeys.zoneID] = 15,
            [objectKeys.spawns] = {
                [15] = {{57.2, 20.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423901] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 8,
            [objectKeys.spawns] = {
                [8] = {{61.4, 22.4},{61.4, 22.5},{61.5, 22.6},{61.6, 22.4},},
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
            [objectKeys.zoneID] = 33,
            [objectKeys.spawns] = {
                [33] = {{49.6, 7.7},},
            },
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
                [406] = {{40.7, 52.4},{40.8, 52.5},},
            },
            [objectKeys.questStarts] = {79980},
            [objectKeys.questEnds] = {79192},
        },
        [424006] = {
            [objectKeys.name] = "Hastily Rolled-Up Satchel",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{22.4, 24.2},{22.5, 24.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {79976},
        },
        [424007] = {
            [objectKeys.name] = "Carved Figurine",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{49.4, 12.9},{49.5, 12.8},},
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
                [3] = {{14.5, 44.8},{23.6, 57.5},{23.6, 59.5},{23.8, 58.5},{24.5, 61.7},{24.8, 59},{24.9, 57.6},{26.6, 68.7},{27, 66.2},{27.1, 72.8},{27.4, 67},{27.5, 70.5},{27.6, 66.3},{27.8, 68.1},{27.9, 69},{28, 69.5},{28.5, 68.1},{32.6, 69.5},{32.7, 70.6},{33.2, 68.1},{33.4, 68.6},{33.7, 68},{33.8, 69.5},{34.2, 68.8},{34.7, 69.5},{34.8, 57.3},{35.4, 58.6},{35.4, 59.6},{35.6, 56.9},{35.6, 59.1},{35.7, 59.7},{36.4, 57.9},{36.7, 56.6},},
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
                [45] = {{62.2, 54.3},{62.2, 54.5},},
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
        [433066] = {
            [objectKeys.name] = "Sandfury Cache",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [433067] = {
            [objectKeys.name] = "Clay Vessel",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [433591] = {
            [objectKeys.name] = "Shallow Grave",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [433593] = {
            [objectKeys.name] = "Zum'Rah's Satchel",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [433594] = {
            [objectKeys.name] = "Antu'Sul's Satchel",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [433596] = {
            [objectKeys.name] = "Spellbound War Chest",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439549] = {
            [objectKeys.name] = "Idol of Hakkar",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439557] = {
            [objectKeys.name] = "Nightmare Moss",
            [objectKeys.zoneID] = 10,
            [objectKeys.spawns] = {
                [10] = {{32.2, 69.3},{35.2, 71.8},{37.3, 84.6},{40.5, 67.1},{44.3, 36.7},{47.8, 42.9},{48.8, 78},{50.9, 76.6},{65.7, 67.1},{66.3, 76.4},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439558] = {
            [objectKeys.name] = "Cold Iron Deposit",
            [objectKeys.zoneID] = 10,
            [objectKeys.spawns] = {
                [10] = {{44.9, 63.9},{46.8, 56.2},{50.2, 78.8},{50.3, 46.4},{55.7, 74.4},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439627] = {
            [objectKeys.name] = "Dreamroot",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{78.3, 43.3},{80.7, 50.6},{81, 44.8},{82.6, 50.2},{82.7, 55},{84.3, 44.9},{85.6, 60},{85.9, 56.4},{85.9, 56.5},{86.2, 47},{86.4, 54.5},{86.5, 54.5},{87.3, 52.3},{87.7, 62.6},{89.5, 44.7},{89.7, 58},{89.8, 50.7},{93.4, 38.3},{93.5, 38.3},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439628] = {
            [objectKeys.name] = "Fool's Gold Vein",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{79.2, 49.9},{81.6, 52.1},{82.7, 45.8},{84.8, 55.4},{85.8, 46.7},{86, 49.7},{87.7, 64.9},{88.1, 62.1},{89, 45.6},{89.8, 42.9},{91, 56.4},{91.3, 37.6},{92.6, 35.2},{93.4, 42.5},{94.1, 36.6},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439631] = {
            [objectKeys.name] = "Atal'ai Statue",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439632] = {
            [objectKeys.name] = "Atal'ai Statue",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439633] = {
            [objectKeys.name] = "Atal'ai Statue",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439634] = {
            [objectKeys.name] = "Atal'ai Statue",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439635] = {
            [objectKeys.name] = "Atal'ai Statue",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439636] = {
            [objectKeys.name] = "Atal'ai Statue",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439762] = {
            [objectKeys.name] = "Star Lotus",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{46.1, 38.5},{49.4, 37.9},{57.3, 41.9},{61.8, 25.2},{66.1, 43},{68.5, 46.6},{71.3, 48.4},{73, 53.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439778] = {
            [objectKeys.name] = "Starsilver Vein",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{45.4, 39.4},{48.8, 45.6},{56.6, 43.4},{57, 43.6},{57.9, 49.7},{58.1, 40.9},{58.9, 43.3},{63.8, 43.8},{66.2, 50.7},{72.2, 52.4},{73.6, 53.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439810] = {
            [objectKeys.name] = "Moonroot",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{38.2, 11.1},{39.1, 11.1},{46.5, 18.4},{50.8, 18.3},{52, 12.1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439815] = {
            [objectKeys.name] = "Greater Moonstone Formation",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{40.8, 9.9},{40.8, 12.5},{51.2, 14.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441061] = {
            [objectKeys.name] = "Weathered Etching",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{14.4, 36.2},{14.5, 36.4},{14.6, 36.5},},
            },
            [objectKeys.questStarts] = {81900},
            [objectKeys.questEnds] = nil,
        },
        [441113] = {
            [objectKeys.name] = "Ogre Magi Text",
            [objectKeys.zoneID] = 10,
            [objectKeys.spawns] = {
                [10] = {{35.7, 80.3},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441114] = {
            [objectKeys.name] = "Mysterious Box",
            [objectKeys.zoneID] = 10,
            [objectKeys.spawns] = {
                [10] = {{65.7, 67.4},{65.7, 67.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441119] = {
            [objectKeys.name] = "Unhatched Green Dragon Egg",
            [objectKeys.zoneID] = 10,
            [objectKeys.spawns] = {
                [10] = {{49.1, 72.1},{49.1, 73},{49.5, 72.3},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441124] = {
            [objectKeys.name] = "Dream-Touched Dragon Egg",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{86.1, 45.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441128] = {
            [objectKeys.name] = "Vibrating Crate",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{88.4, 55.4},{88.4, 55.5},{88.5, 55.1},{91, 58.1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441129] = {
            [objectKeys.name] = "Azsharan Prophecy",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{80.7, 48.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441133] = {
            [objectKeys.name] = "Star-Touched Dragon Egg",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{45.4, 38.7},{45.5, 38.7},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441140] = {
            [objectKeys.name] = "Humming Box",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{57.8, 43.3},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441141] = {
            [objectKeys.name] = "Dreampearl",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{72.2, 54.1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441222] = {
            [objectKeys.name] = "Grave Mound",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441244] = {
            [objectKeys.name] = "Corrupted Shaman Shrine",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441247] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441248] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 440,
            [objectKeys.spawns] = {
                [440] = {{72.6, 47.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441249] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{50.6, 15.7},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441250] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 16,
            [objectKeys.spawns] = {
                [16] = {{20.8, 62},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441251] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441252] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{36, 72.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441253] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{37.8, 49.3},{37.8, 49.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441254] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 4,
            [objectKeys.spawns] = {
                [4] = {{55.4, 32.2},{55.4, 32.5},{55.5, 32.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441310] = {
            [objectKeys.name] = "Moonglow Dragon Egg",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{50.7, 17.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441312] = {
            [objectKeys.name] = "Mad Keeper's Notes",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{45, 20},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441314] = {
            [objectKeys.name] = "Harpy Screed",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{38.4, 15.9},{38.5, 15.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441848] = {
            [objectKeys.name] = "Small Burrow",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441865] = {
            [objectKeys.name] = "Traveller's Knapsack",
            [objectKeys.zoneID] = 16,
            [objectKeys.spawns] = {
                [16] = {{20.6, 61.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441870] = {
            [objectKeys.name] = "Satyrweed Bramble",
            [objectKeys.zoneID] = 16,
            [objectKeys.spawns] = {
                [16] = {{18.5, 63},{18.8, 60.6},{19.3, 59.6},{19.7, 58.9},{20.9, 58.4},{21.1, 63.6},{21.3, 60.8},{21.4, 58.9},{21.9, 59.3},{22.2, 60.3},{22.2, 61.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441893] = {
            [objectKeys.name] = "Door",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441912] = {
            [objectKeys.name] = "Giant Golem Foot",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{43.9, 32.4},{44, 32.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441913] = {
            [objectKeys.name] = "Giant Golem Foot",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{42.3, 30.4},{42.5, 30.4},{42.5, 30.5},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441914] = {
            [objectKeys.name] = "Giant Golem Arm",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{49.6, 37.5},{49.7, 37.4},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441915] = {
            [objectKeys.name] = "Giant Golem Arm",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{41.9, 44.3},{41.9, 44.7},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441946] = {
            [objectKeys.name] = "Shrine of the Moon",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{66.2, 53.1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441947] = {
            [objectKeys.name] = "Shrine of the Beast",
            [objectKeys.zoneID] = 16,
            [objectKeys.spawns] = {
                [16] = {{34.6, 49},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441948] = {
            [objectKeys.name] = "Shrine of the Warden",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{58.6, 52.2},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [442397] = {
            [objectKeys.name] = "Treasure of the Bat",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{72.8, 53},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [442398] = {
            [objectKeys.name] = "Treasure of the Bat",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{72.7, 52.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [442404] = {
            [objectKeys.name] = "Stormcrow Egg",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{53.1, 55.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [442405] = {
            [objectKeys.name] = "Abandoned Cache",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [442685] = {
            [objectKeys.name] = "Old Chest",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [442688] = {
            [objectKeys.name] = "Old Crate",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{76.6, 48},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [442728] = {
            [objectKeys.name] = "Chest",
            [objectKeys.zoneID] = 440,
            [objectKeys.spawns] = {
                [440] = {{45.8, 37.6},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [442742] = {
            [objectKeys.name] = "Box of Scarlet Dye",
            [objectKeys.zoneID] = 28,
            [objectKeys.spawns] = {
                [28] = {{45.1, 15.1},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [443727] = {
            [objectKeys.name] = "Grimtotem Chest",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{69.6, 43.3},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [443728] = {
            [objectKeys.name] = "Woodpaw Bag",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{66.4, 50.9},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [445036] = {
            [objectKeys.name] = "Extraplanar Eye",
            [objectKeys.zoneID] = 4,
            [objectKeys.spawns] = {
                [4] = {{49.8, 14.6},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [445037] = {
            [objectKeys.name] = "Extraplanar Eye",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{43.8, 45.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [445039] = {
            [objectKeys.name] = "Extraplanar Eye",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{58.4, 72.7},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [445040] = {
            [objectKeys.name] = "Extraplanar Eye",
            [objectKeys.zoneID] = 440,
            [objectKeys.spawns] = {
                [440] = {{56.4, 73.8},{56.5, 73.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [445041] = {
            [objectKeys.name] = "Extraplanar Eye",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{57.2, 68.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [445042] = {
            [objectKeys.name] = "Extraplanar Eye",
            [objectKeys.zoneID] = 361,
            [objectKeys.spawns] = {
                [361] = {{36.4, 55.7},{36.5, 55.8},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [445044] = {
            [objectKeys.name] = "Extraplanar Eye",
            [objectKeys.zoneID] = 33,
            [objectKeys.spawns] = {
                [33] = {{32.9, 88.3},},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [446468] = {
            [objectKeys.name] = "Wondergear Worldporter",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [447821] = {
            [objectKeys.name] = "Torn Scroll",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [448042] = {
            [objectKeys.name] = "Idol of Hakkar",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {82097},
        },
    }
end
