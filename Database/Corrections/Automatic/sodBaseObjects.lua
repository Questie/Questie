---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

--- Load the base quests for Season of Discovery
--- These are generated, do NOT EDIT the data entries here.
--- If you want to edit an object, do so in sodObjectFixes.lua
function SeasonOfDiscovery:LoadBaseObjects()
    local objectKeys = QuestieDB.objectKeys

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
        [375545] = {
            [objectKeys.name] = "Unstable Chromatic Egg",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [375878] = {
            [objectKeys.name] = "Sandpile",
            [objectKeys.zoneID] = 2677,
            [objectKeys.spawns] = {
                [2677] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [386675] = {
            [objectKeys.name] = "Buried Treasure",
            [objectKeys.zoneID] = 1,
            [objectKeys.spawns] = {
                [1] = {{47,43.7}},
                [12] = {{80.4,79.4},{80.5,79.2}},
                [14] = {{62.1,94.8}},
                [85] = {{52.9,54}},
                [141] = {{55.3,90.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [386691] = {
            [objectKeys.name] = "Library Book",
            [objectKeys.zoneID] = 1537,
            [objectKeys.spawns] = {
                [1537] = {{75.4,10.5},{75.6,10.4},{75.7,10.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [386759] = {
            [objectKeys.name] = "Library Book",
            [objectKeys.zoneID] = 12,
            [objectKeys.spawns] = {
                [12] = {{65.4,70.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [386777] = {
            [objectKeys.name] = "Dusty Chest",
            [objectKeys.zoneID] = 1519,
            [objectKeys.spawns] = {
                [1519] = {{61.9,29.3}},
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
                [1] = {{47,52}},
                [12] = {{46.2,62.1}},
                [14] = {{53.8,27.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [387477] = {
            [objectKeys.name] = "Defias Stashbox",
            [objectKeys.zoneID] = 12,
            [objectKeys.spawns] = {
                [12] = {{52.4,52},{52.6,51.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [392029] = {
            [objectKeys.name] = "Swordsman's Reward",
            [objectKeys.zoneID] = 1,
            [objectKeys.spawns] = {
                [1] = {{53.4,47.8},{53.5,47.8}},
                [12] = {{22.3,73.3},{25.3,70.2},{30,73.4},{38.6,75.6},{40.9,74.7}},
                [14] = {{40.9,49.3}},
                [215] = {{46,36.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [397987] = {
            [objectKeys.name] = "Kobold Stashbox",
            [objectKeys.zoneID] = 12,
            [objectKeys.spawns] = {
                [12] = {{50.6,27.2}},
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
            [objectKeys.zoneID] = 215,
            [objectKeys.spawns] = {
                [215] = {{63.4,39.4}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [403102] = {
            [objectKeys.name] = "Bristleback Loot Cache",
            [objectKeys.zoneID] = 215,
            [objectKeys.spawns] = {
                [215] = {{61.6,76}},
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
                [215] = {{31.6,49.4},{31.6,49.5}},
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
                [405] = {{74.4,19},{74.5,19},{75.9,16.6},{75.9,21.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [404433] = {
            [objectKeys.name] = "Lunar Chest",
            [objectKeys.zoneID] = 141,
            [objectKeys.spawns] = {
                [141] = {{52.8,78.8}},
                [215] = {{35.7,69.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [404695] = {
            [objectKeys.name] = "Waterlogged Stashbox",
            [objectKeys.zoneID] = 14,
            [objectKeys.spawns] = {
                [14] = {{43,54.4},{43,54.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [404830] = {
            [objectKeys.name] = "Dusty Chest",
            [objectKeys.zoneID] = 1637,
            [objectKeys.spawns] = {
                [1637] = {{55.9,44.7}},
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
                [14] = {{43.2,69.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [404941] = {
            [objectKeys.name] = "Relic Coffer",
            [objectKeys.zoneID] = 85,
            [objectKeys.spawns] = {
                [85] = {{52.4,25.8},{52.5,25.8}},
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
                [85] = {{66.6,24.4},{66.7,24.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [405628] = {
            [objectKeys.name] = "Frostmane Loot Cache",
            [objectKeys.zoneID] = 1,
            [objectKeys.spawns] = {
                [1] = {{30.8,80.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [405633] = {
            [objectKeys.name] = "Rockjaw Footlocker",
            [objectKeys.zoneID] = 1,
            [objectKeys.spawns] = {
                [1] = {{26.8,72.6}},
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
                [85] = {{59.4,52.3}},
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
                [1537] = {{51.9,13},{52,13.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [406006] = {
            [objectKeys.name] = "Idol",
            [objectKeys.zoneID] = 141,
            [objectKeys.spawns] = {
                [141] = {{59.7,42.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [406736] = {
            [objectKeys.name] = "Lost Stash",
            [objectKeys.zoneID] = 85,
            [objectKeys.spawns] = {
                [85] = {{24.6,59.5},{24.7,59.4}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [406918] = {
            [objectKeys.name] = "Messenger Bag",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{22.4,24.2},{22.5,24.2}},
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
                [17] = {{58.2,26.7}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407352] = {
            [objectKeys.name] = "Gnarlpine Stash",
            [objectKeys.zoneID] = 141,
            [objectKeys.spawns] = {
                [141] = {{37.9,82.5}},
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
                [17] = {{44.8,81.4}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407510] = {
            [objectKeys.name] = "Etched Carving",
            [objectKeys.zoneID] = 17,
            [objectKeys.spawns] = {
                [17] = {{45.4,80},{45.5,80}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407566] = {
            [objectKeys.name] = "Goblin Tome",
            [objectKeys.zoneID] = 17,
            [objectKeys.spawns] = {
                [17] = {{62.7,36.3}},
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
                [38] = {{46.4,12.7},{46.5,12.7}},
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
                [141] = {{43.1,60.8},{44.1,61.2},{44.5,62.4},{44.5,62.5},{44.7,59},{44.8,59.9},{45,61.4},{45.3,58.1},{45.7,57}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407844] = {
            [objectKeys.name] = "Libram of Blessings",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{35.7,49.4},{35.8,49.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407850] = {
            [objectKeys.name] = "Sunken Reliquary",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{36.8,91.4},{36.8,91.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407918] = {
            [objectKeys.name] = "Empty Trophy Display",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{83.6,65.4},{83.6,65.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [407983] = {
            [objectKeys.name] = "Pile of Stolen Books",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{54.2,27}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [408004] = {
            [objectKeys.name] = "Tangled Blight Pile",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{71.7,21.4},{71.8,21.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [408014] = {
            [objectKeys.name] = "Gnomish Tome",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{35.6,48.9}},
                [40] = {{52.7,53.8}},
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
                [148] = {{44.1,20.8},{47.3,15.3},{48.3,18},{49.2,16.2}},
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
                [130] = {{45.2,67.2}},
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
                [148] = {{56.2,26.4},{56.2,26.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409311] = {
            [objectKeys.name] = "Spear of Mannoroth",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{89.4,77.1},{89.5,77}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {78092},
        },
        [409315] = {
            [objectKeys.name] = "Shattered Orb",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{89.4,77},{89.5,77}},
            },
            [objectKeys.questStarts] = {78093},
            [objectKeys.questEnds] = nil,
        },
        [409496] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 148,
            [objectKeys.spawns] = {
                [148] = {{59.6,22.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409501] = {
            [objectKeys.name] = "Dalaran Digest",
            [objectKeys.zoneID] = 130,
            [objectKeys.spawns] = {
                [130] = {{63.5,63.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409562] = {
            [objectKeys.name] = "Spellbook",
            [objectKeys.zoneID] = 40,
            [objectKeys.spawns] = {
                [40] = {{45.4,70.4},{45.4,70.5}},
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
                [17] = {{56.3,8.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409711] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 406,
            [objectKeys.spawns] = {
                [406] = {{74.4,85.7}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409717] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 11,
            [objectKeys.spawns] = {
                [11] = {{33.6,47.9}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409731] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{77.4,14},{77.5,14}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409735] = {
            [objectKeys.name] = "Spellbook",
            [objectKeys.zoneID] = 10,
            [objectKeys.spawns] = {
                [10] = {{16.6,28.5},{16.7,28.4}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409754] = {
            [objectKeys.name] = "Wall-Mounted Shield",
            [objectKeys.zoneID] = 44,
            [objectKeys.spawns] = {
                [44] = {{69.8,55.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [409758] = {
            [objectKeys.name] = "Discarded Helm",
            [objectKeys.zoneID] = 209,
            [objectKeys.spawns] = {
                [209] = {{-1,-1}},
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
                [10] = {{49.4,34},{49.5,34}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [410082] = {
            [objectKeys.name] = "Carved Stone",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{86.9,43.2}},
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
        [410158] = {
            [objectKeys.name] = "Altar of Reverence",
            [objectKeys.zoneID] = 46,
            [objectKeys.spawns] = {
                [46] = {{39.4,27.9},{39.6,28}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {84124},
        },
        [410168] = {
            [objectKeys.name] = "Voodoo Pile",
            [objectKeys.zoneID] = 14,
            [objectKeys.spawns] = {
                [14] = {{68.7,71.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {78199},
        },
        [410220] = {
            [objectKeys.name] = "Gift of the Wisp",
            [objectKeys.zoneID] = 361,
            [objectKeys.spawns] = {
                [361] = {{39.5,22},{41.1,19},{41.8,19.9},{42.2,16.3},{42.3,17.1},{42.3,17.9},{42.4,14.7},{42.6,17.2},{42.6,18.4},{42.6,20.2},{42.8,16.1},{43,15.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [410299] = {
            [objectKeys.name] = "Arcane Secrets",
            [objectKeys.zoneID] = 130,
            [objectKeys.spawns] = {
                [130] = {{43.4,41.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [410369] = {
            [objectKeys.name] = "Dead Drop",
            [objectKeys.zoneID] = 130,
            [objectKeys.spawns] = {
                [130] = {{47.1,71.1}},
            },
            [objectKeys.questStarts] = {78261,78676,80455},
            [objectKeys.questEnds] = {78261,78307,78676,78699,80454},
        },
        [410528] = {
            [objectKeys.name] = "Ornamented Chest",
            [objectKeys.zoneID] = 209,
            [objectKeys.spawns] = {
                [209] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [410779] = {
            [objectKeys.name] = "Offering Box",
            [objectKeys.zoneID] = 10,
            [objectKeys.spawns] = {
                [10] = {{81.2,71.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [410847] = {
            [objectKeys.name] = "Rusty Safe",
            [objectKeys.zoneID] = 28,
            [objectKeys.spawns] = {
                [28] = {{59.4,84.6}},
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
                [10] = {{26,31}},
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
                [130] = {{65.8,23.4},{65.8,23.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [411710] = {
            [objectKeys.name] = "Demonic Reliquary",
            [objectKeys.zoneID] = 44,
            [objectKeys.spawns] = {
                [44] = {{80.1,49.5},{80.2,49.4}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [411715] = {
            [objectKeys.name] = "Bough of Altek",
            [objectKeys.zoneID] = 148,
            [objectKeys.spawns] = {
                [148] = {{56.2,26.4},{56.3,26.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [412147] = {
            [objectKeys.name] = "Supply Locker",
            [objectKeys.zoneID] = 85,
            [objectKeys.spawns] = {
                [85] = {{81.2,32.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [412198] = {
            [objectKeys.name] = "Stone Coffer",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [412224] = {
            [objectKeys.name] = "Dark Ritual Stone",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{79,80.3}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {78681},
        },
        [412261] = {
            [objectKeys.name] = "Padlocked Reliquary",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [412759] = {
            [objectKeys.name] = "Personal Letterbox",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1,-1}},
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
                [331] = {{89.8,37.3},{89.8,37.5},{91.2,37.5},{92.5,40.4},{94,41.7}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [414532] = {
            [objectKeys.name] = "Clliffspring Chest",
            [objectKeys.zoneID] = 148,
            [objectKeys.spawns] = {
                [148] = {{56.3,34.9}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [414624] = {
            [objectKeys.name] = "Lighthouse Stash",
            [objectKeys.zoneID] = 148,
            [objectKeys.spawns] = {
                [148] = {{32.7,37.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [414646] = {
            [objectKeys.name] = "Remnant",
            [objectKeys.zoneID] = 148,
            [objectKeys.spawns] = {
                [148] = {{30.4,48}},
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
                [148] = {{59.2,22.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [414713] = {
            [objectKeys.name] = "Storage Locker",
            [objectKeys.zoneID] = 267,
            [objectKeys.spawns] = {
                [267] = {{79.7,41}},
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
                [17] = {{46.4,73.9}},
            },
            [objectKeys.questStarts] = {79007,79192},
            [objectKeys.questEnds] = {79008},
        },
        [415107] = {
            [objectKeys.name] = "Burned-Out Remains",
            [objectKeys.zoneID] = 40,
            [objectKeys.spawns] = {
                [40] = {{37.4,50.6},{37.5,50.7}},
            },
            [objectKeys.questStarts] = {79008,79192},
            [objectKeys.questEnds] = {79007},
        },
        [415614] = {
            [objectKeys.name] = "Mysterious Formulae",
            [objectKeys.zoneID] = 719,
            [objectKeys.spawns] = {
                [719] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [417072] = {
            [objectKeys.name] = "Nailed Plank",
            [objectKeys.zoneID] = 17,
            [objectKeys.spawns] = {
                [17] = {{46.4,73.8}},
            },
            [objectKeys.questStarts] = {79192},
            [objectKeys.questEnds] = {79008},
        },
        [417353] = {
            [objectKeys.name] = "Extinguished Campfire",
            [objectKeys.zoneID] = 405,
            [objectKeys.spawns] = {
                [405] = {{47.4,54.6},{47.5,54.6}},
            },
            [objectKeys.questStarts] = {79229},
            [objectKeys.questEnds] = nil,
        },
        [418855] = {
            [objectKeys.name] = "Illari's Loot Cache",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{94.1,69.3}},
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
                [33] = {{41.5,50.9}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [421568] = {
            [objectKeys.name] = "Weathered Cache",
            [objectKeys.zoneID] = 400,
            [objectKeys.spawns] = {
                [400] = {{46.8,53.4},{46.8,53.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [422483] = {
            [objectKeys.name] = "The Salvagematic 9000",
            [objectKeys.zoneID] = 721,
            [objectKeys.spawns] = {
                [721] = {{-1,-1}},
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
                [405] = {{27.7,57.4},{27.8,57.7}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [422902] = {
            [objectKeys.name] = "Crystal Waters of Lake Elune'ara",
            [objectKeys.zoneID] = 493,
            [objectKeys.spawns] = {
                [493] = {{55.7,66.3},{55.8,66.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [422911] = {
            [objectKeys.name] = "Sealed Barrel",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{21.3,84},{21.5,83.9}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [422919] = {
            [objectKeys.name] = "Tapped Shadowforge Keg",
            [objectKeys.zoneID] = 3,
            [objectKeys.spawns] = {
                [3] = {{41.3,27.9},{41.5,28.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423569] = {
            [objectKeys.name] = "Dropped Pouch",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{93.4,71.1},{93.5,70.4},{93.8,71.4},{93.8,71.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423695] = {
            [objectKeys.name] = "Libram of Deliverance",
            [objectKeys.zoneID] = 405,
            [objectKeys.spawns] = {
                [405] = {{66.5,7.4},{66.5,7.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423703] = {
            [objectKeys.name] = "Broken Warhammer",
            [objectKeys.zoneID] = 405,
            [objectKeys.spawns] = {
                [405] = {{52.7,84.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423841] = {
            [objectKeys.name] = "Frozen Remains",
            [objectKeys.zoneID] = 36,
            [objectKeys.spawns] = {
                [36] = {{39.7,60.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423895] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 400,
            [objectKeys.spawns] = {
                [400] = {{34.4,40.1},{34.5,40.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423896] = {
            [objectKeys.name] = "Manual",
            [objectKeys.zoneID] = 36,
            [objectKeys.spawns] = {
                [36] = {{48.4,57.6},{48.5,57.7}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423897] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{73.6,65.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423898] = {
            [objectKeys.name] = "Mysterious Book",
            [objectKeys.zoneID] = 405,
            [objectKeys.spawns] = {
                [405] = {{55.1,26.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423899] = {
            [objectKeys.name] = "Scrolls",
            [objectKeys.zoneID] = 3,
            [objectKeys.spawns] = {
                [3] = {{56.7,39.9}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423900] = {
            [objectKeys.name] = "Waterlogged Book",
            [objectKeys.zoneID] = 15,
            [objectKeys.spawns] = {
                [15] = {{57.2,20.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423901] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 8,
            [objectKeys.spawns] = {
                [8] = {{61.4,22.4},{61.4,22.5},{61.5,22.6},{61.6,22.4}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423920] = {
            [objectKeys.name] = "Warrior's Bounty",
            [objectKeys.zoneID] = 400,
            [objectKeys.spawns] = {
                [400] = {{67.9,89.3},{68,89.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423926] = {
            [objectKeys.name] = "Conspicuous Cache",
            [objectKeys.zoneID] = 8,
            [objectKeys.spawns] = {
                [8] = {{42.7,30.9}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [423930] = {
            [objectKeys.name] = "Sizable Stolen Strongbox",
            [objectKeys.zoneID] = 400,
            [objectKeys.spawns] = {
                [400] = {{18.7,21}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424002] = {
            [objectKeys.name] = "Kurzen Supply Crate",
            [objectKeys.zoneID] = 33,
            [objectKeys.spawns] = {
                [33] = {{49.6,7.7}},
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
                [406] = {{40.7,52.4},{40.8,52.5}},
            },
            [objectKeys.questStarts] = {79980},
            [objectKeys.questEnds] = {79192},
        },
        [424006] = {
            [objectKeys.name] = "Hastily Rolled-Up Satchel",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{22.4,24.2},{22.5,24.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {79976},
        },
        [424007] = {
            [objectKeys.name] = "Carved Figurine",
            [objectKeys.zoneID] = 38,
            [objectKeys.spawns] = {
                [38] = {{49.4,12.9},{49.5,12.8}},
            },
            [objectKeys.questStarts] = {79975},
            [objectKeys.questEnds] = {79974},
        },
        [424010] = {
            [objectKeys.name] = "Nailed Plank",
            [objectKeys.zoneID] = 40,
            [objectKeys.spawns] = {
                [40] = {{37.4,50.9},{37.5,50.8}},
            },
            [objectKeys.questStarts] = {79192},
            [objectKeys.questEnds] = {79007},
        },
        [424012] = {
            [objectKeys.name] = "Mound of Dirt",
            [objectKeys.zoneID] = 406,
            [objectKeys.spawns] = {
                [406] = {{39.6,49.9}},
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
                [406] = {{40.6,52.4}},
            },
            [objectKeys.questStarts] = {80001},
            [objectKeys.questEnds] = {80001},
        },
        [424110] = {
            [objectKeys.name] = "Swordsman's Reward",
            [objectKeys.zoneID] = 3,
            [objectKeys.spawns] = {
                [3] = {{14.5,44.8},{23.2,60},{23.6,57.5},{23.6,59.5},{23.8,58.5},{24.5,61.7},{24.8,59},{24.9,57.6},{25.2,57.4},{26.6,68.7},{26.8,67.8},{27,66.2},{27.1,72.8},{27.4,67},{27.5,70.5},{27.6,66.3},{27.9,69},{28,68.2},{28,69.5},{28.5,68.1},{32.6,69.5},{32.7,70.6},{33.2,68.1},{33.4,68.6},{33.7,68},{33.8,69.5},{34.2,68.8},{34.7,69.5},{34.8,57.3},{35.2,58.2},{35.4,58.6},{35.4,59.6},{35.6,56.9},{35.6,59.1},{35.7,59.7},{36.4,57.9},{36.7,56.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424264] = {
            [objectKeys.name] = "Grave",
            [objectKeys.zoneID] = 15,
            [objectKeys.spawns] = {
                [15] = {{63.7,42.4},{63.7,42.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424265] = {
            [objectKeys.name] = "Grave",
            [objectKeys.zoneID] = 8,
            [objectKeys.spawns] = {
                [8] = {{16.7,53.7}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424266] = {
            [objectKeys.name] = "Grave",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424267] = {
            [objectKeys.name] = "Grave",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{62.2,54.3},{62.2,54.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [424373] = {
            [objectKeys.name] = "Remnant",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [425896] = {
            [objectKeys.name] = "Archivists of the Monastery",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [425897] = {
            [objectKeys.name] = "Archivists of the Monastery",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [425898] = {
            [objectKeys.name] = "Archivists of the Monastery",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [425899] = {
            [objectKeys.name] = "Archivists of the Monastery",
            [objectKeys.zoneID] = 796,
            [objectKeys.spawns] = {
                [796] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [428144] = {
            [objectKeys.name] = "Fount",
            [objectKeys.zoneID] = 33,
            [objectKeys.spawns] = {
                [33] = {{23.6,8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [428228] = {
            [objectKeys.name] = "Conspicuous Cache",
            [objectKeys.zoneID] = 8,
            [objectKeys.spawns] = {
                [8] = {{42.6,30.7}},
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
                [10] = {{32.2,69.3},{35.2,64.2},{35.2,71.8},{37.3,84.6},{40.4,67.1},{40.5,67},{44.2,36.6},{46.3,55.1},{47.8,42.9},{48.8,77.9},{50.9,76.6},{53.9,62.7},{56.8,71.3},{61.3,75.8},{61.6,75.8},{64.3,72.8},{64.4,72.4},{65.2,58.7},{65.7,67.1},{66.3,76.4},{66.4,76.5},{66.5,76.7}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439558] = {
            [objectKeys.name] = "Cold Iron Deposit",
            [objectKeys.zoneID] = 10,
            [objectKeys.spawns] = {
                [10] = {{33.2,68},{33.7,76.7},{35.4,68.1},{35.5,68},{36.9,84.7},{38,84.1},{41.2,75.4},{41.2,75.5},{42.4,34.7},{42.5,34.6},{44.9,63.9},{46.8,56.2},{46.8,56.5},{50.2,78.8},{50.3,46.4},{50.3,46.5},{52.1,72.1},{55.8,74.4},{55.8,74.5},{59.1,56.5},{59.2,56.4},{63.2,64.1},{63.2,64.5},{64.2,65},{67.6,78.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439627] = {
            [objectKeys.name] = "Dreamroot",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{78.3,43.3},{80.7,50.6},{81,44.8},{82.7,50.2},{82.7,55},{84.3,44.9},{85.6,60},{85.9,56.4},{85.9,56.5},{86.2,47},{86.4,54.6},{86.5,54.4},{86.5,54.5},{87.3,52.3},{87.7,62.6},{89.5,44.7},{89.7,58},{89.8,50.7},{93.4,38.3},{93.5,38.3}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439628] = {
            [objectKeys.name] = "Fool's Gold Vein",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{79.2,49.9},{81.6,52.1},{82.7,45.8},{84.8,55.4},{85.8,46.7},{86,49.7},{87.7,64.9},{88.1,62.1},{89,45.6},{89.8,42.9},{91,56.3},{91.3,37.4},{91.3,37.6},{92.6,35.2},{93.4,42.4},{93.4,42.5},{93.5,42.5},{94.1,36.6}},
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
                [47] = {{45.1,43.2},{46.1,38.4},{46.1,38.5},{49.4,38},{49.5,38},{57.3,41.9},{57.5,41.8},{58.9,43.4},{59.1,43.7},{61.7,25.5},{61.8,25.3},{66.1,43},{66.6,17.9},{66.6,32.9},{68.4,46.6},{68.5,46.4},{68.5,46.6},{70.4,45.2},{70.4,45.5},{70.5,45.4},{70.5,45.5},{71.3,48.4},{71.3,48.5},{73,53.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439778] = {
            [objectKeys.name] = "Starsilver Vein",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{45.4,39.4},{45.4,39.5},{46.9,34.8},{48.8,45.5},{49,49.8},{56.6,43.3},{56.9,43.6},{57.9,49.8},{58.1,16.6},{58.1,41},{58.9,43.2},{63.7,43.4},{63.8,43.5},{66.3,50.7},{72.1,52.5},{72.2,52.3},{73.6,53.7}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439810] = {
            [objectKeys.name] = "Moonroot",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{37.4,17.3},{37.5,17.4},{38.2,11.1},{39.1,11.1},{40.4,11.4},{40.4,11.5},{40.5,11.4},{40.5,11.5},{41.6,18.4},{41.6,18.5},{41.9,13.9},{44.7,23.1},{45.4,10.9},{46.5,18.3},{49,4.4},{50.8,18.3},{52,12.1},{53.5,17.4},{53.6,17.5},{54.9,6.9}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [439815] = {
            [objectKeys.name] = "Greater Moonstone Formation",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{37.6,16.8},{37.7,20.4},{37.7,20.5},{40.3,19.7},{40.8,9.9},{40.8,12.5},{42.8,23.2},{47.4,21.9},{47.5,21.8},{51,19.8},{51.2,14.8},{54,13.4},{54,13.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441061] = {
            [objectKeys.name] = "Weathered Etching",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{14.4,36.3},{14.5,36.4},{14.5,36.5}},
            },
            [objectKeys.questStarts] = {81900},
            [objectKeys.questEnds] = nil,
        },
        [441113] = {
            [objectKeys.name] = "Ogre Magi Text",
            [objectKeys.zoneID] = 10,
            [objectKeys.spawns] = {
                [10] = {{35.7,80.1},{37.9,84.3}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441114] = {
            [objectKeys.name] = "Mysterious Box",
            [objectKeys.zoneID] = 10,
            [objectKeys.spawns] = {
                [10] = {{65.7,67.4},{65.7,67.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441119] = {
            [objectKeys.name] = "Unhatched Green Dragon Egg",
            [objectKeys.zoneID] = 10,
            [objectKeys.spawns] = {
                [10] = {{48.9,72.8},{49,72.2},{49.5,72.4},{49.5,72.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441124] = {
            [objectKeys.name] = "Dream-Touched Dragon Egg",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{86.1,45.9}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441128] = {
            [objectKeys.name] = "Vibrating Crate",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{88.4,55.4},{88.4,55.5},{88.5,55.1},{91,58.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441129] = {
            [objectKeys.name] = "Azsharan Prophecy",
            [objectKeys.zoneID] = 331,
            [objectKeys.spawns] = {
                [331] = {{80.7,48.9}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441133] = {
            [objectKeys.name] = "Star-Touched Dragon Egg",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{45.4,38.8},{45.5,38.7}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441140] = {
            [objectKeys.name] = "Humming Box",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{56.2,43.9},{56.6,43.4},{56.7,43.5},{57.5,40.8},{57.8,43.3}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441141] = {
            [objectKeys.name] = "Dreampearl",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{72.3,54.1},{72.7,54.2}},
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
                [440] = {{72.6,47.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441249] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{50.6,15.7}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441250] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 16,
            [objectKeys.spawns] = {
                [16] = {{20.7,62}},
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
                [47] = {{36,72.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441253] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{37.8,49.3},{37.9,49.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441254] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 4,
            [objectKeys.spawns] = {
                [4] = {{55.4,32.2},{55.4,32.5},{55.5,32.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441310] = {
            [objectKeys.name] = "Moonglow Dragon Egg",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{50.7,17.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441312] = {
            [objectKeys.name] = "Mad Keeper's Notes",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{45,20},{46.6,19}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441314] = {
            [objectKeys.name] = "Harpy Screed",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{38.4,15.9},{38.6,15.7},{38.9,13.3}},
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
                [16] = {{20.6,61.9}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441870] = {
            [objectKeys.name] = "Satyrweed Bramble",
            [objectKeys.zoneID] = 16,
            [objectKeys.spawns] = {
                [16] = {{18.5,61.3},{18.5,63},{19.3,59.6},{19.7,58.9},{19.8,60.5},{19.8,61.6},{19.9,64},{20.9,58.4},{20.9,58.5},{21.1,63.6},{21.3,60.1},{21.3,60.8},{21.6,63.5},{21.9,59.3},{22,62.7},{22.2,60.3},{22.2,61},{22.2,61.8}},
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
                [51] = {{43.9,32.4},{44,32.9}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441913] = {
            [objectKeys.name] = "Giant Golem Foot",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{42.3,30.4},{42.4,30.8},{42.5,30.4},{42.5,30.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441914] = {
            [objectKeys.name] = "Giant Golem Arm",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{49.4,37.3},{49.6,37.5},{49.7,37.4}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441915] = {
            [objectKeys.name] = "Giant Golem Arm",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{41.9,44.3},{41.9,44.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441946] = {
            [objectKeys.name] = "Shrine of the Moon",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{66.2,53.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441947] = {
            [objectKeys.name] = "Shrine of the Beast",
            [objectKeys.zoneID] = 16,
            [objectKeys.spawns] = {
                [16] = {{34.6,49}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [441948] = {
            [objectKeys.name] = "Shrine of the Warden",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{58.6,52.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [442397] = {
            [objectKeys.name] = "Treasure of the Bat",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{72.8,53}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [442398] = {
            [objectKeys.name] = "Treasure of the Bat",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{72.7,52.9}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [442404] = {
            [objectKeys.name] = "Stormcrow Egg",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{53.1,56}},
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
                [357] = {{76.6,48}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [442728] = {
            [objectKeys.name] = "Chest",
            [objectKeys.zoneID] = 440,
            [objectKeys.spawns] = {
                [440] = {{45.8,37.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [442742] = {
            [objectKeys.name] = "Box of Scarlet Dye",
            [objectKeys.zoneID] = 28,
            [objectKeys.spawns] = {
                [28] = {{45.2,15.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [443727] = {
            [objectKeys.name] = "Grimtotem Chest",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{69.6,43.3}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [443728] = {
            [objectKeys.name] = "Woodpaw Bag",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{66.4,50.9}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [445036] = {
            [objectKeys.name] = "Extraplanar Eye",
            [objectKeys.zoneID] = 4,
            [objectKeys.spawns] = {
                [4] = {{49.8,14.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [445037] = {
            [objectKeys.name] = "Extraplanar Eye",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{43.8,45.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [445039] = {
            [objectKeys.name] = "Extraplanar Eye",
            [objectKeys.zoneID] = 47,
            [objectKeys.spawns] = {
                [47] = {{58.4,72.7}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [445040] = {
            [objectKeys.name] = "Extraplanar Eye",
            [objectKeys.zoneID] = 440,
            [objectKeys.spawns] = {
                [440] = {{56.4,73.8},{56.5,73.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [445041] = {
            [objectKeys.name] = "Extraplanar Eye",
            [objectKeys.zoneID] = 357,
            [objectKeys.spawns] = {
                [357] = {{57.2,68.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [445042] = {
            [objectKeys.name] = "Extraplanar Eye",
            [objectKeys.zoneID] = 361,
            [objectKeys.spawns] = {
                [361] = {{36.4,55.7},{36.5,55.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [445044] = {
            [objectKeys.name] = "Extraplanar Eye",
            [objectKeys.zoneID] = 33,
            [objectKeys.spawns] = {
                [33] = {{32.9,88.3}},
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
            [objectKeys.zoneID] = 1477,
            [objectKeys.spawns] = {
                [1477] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {82097},
        },
        [454487] = {
            [objectKeys.name] = "Monument to Grom Hellscream",
            [objectKeys.zoneID] = 15475,
            [objectKeys.spawns] = {
                [15475] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [455023] = {
            [objectKeys.name] = "Regurgitated Skeleton",
            [objectKeys.zoneID] = 139,
            [objectKeys.spawns] = {
                [139] = {{20.2,25.8},{29.1,40.6},{31.3,39.8},{45.1,39.1},{46.7,80.6},{47.3,73.8},{47.5,73.4},{47.9,73.5},{48.3,59.6},{48.7,65.9},{49.1,59.4},{49.2,77.5},{49.3,77.4},{49.7,77.7},{49.8,77.4},{51.2,54.3},{51.2,77.8},{51.5,62.9},{51.5,77.8},{51.6,56.8},{55.1,49.5},{60.6,54},{64.9,64.8},{66.5,71.9},{68.3,65.5},{68.6,65.4},{68.7,65.5},{68.9,67.6},{70.3,79.9},{72.5,70},{72.6,55.6},{74,55.7},{74.6,56.2},{75.6,58.8},{75.7,59.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [455812] = {
            [objectKeys.name] = "Squire Cuthbert's Sword",
            [objectKeys.zoneID] = 28,
            [objectKeys.spawns] = {
                [28] = {{45.7,53.9}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [456674] = {
            [objectKeys.name] = "Altar of Reverence",
            [objectKeys.zoneID] = 46,
            [objectKeys.spawns] = {
                [46] = {{39.4,27.9},{39.5,28}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [456682] = {
            [objectKeys.name] = "Half-Buried Mech",
            [objectKeys.zoneID] = 440,
            [objectKeys.spawns] = {
                [440] = {{59.2,91.5},{59.3,91.4}},
            },
            [objectKeys.questStarts] = {84135},
            [objectKeys.questEnds] = nil,
        },
        [456685] = {
            [objectKeys.name] = "Access Hatch",
            [objectKeys.zoneID] = 440,
            [objectKeys.spawns] = {
                [440] = {{59.3,91.4},{59.3,91.5}},
            },
            [objectKeys.questStarts] = {84137},
            [objectKeys.questEnds] = {84135},
        },
        [456775] = {
            [objectKeys.name] = "Remnant",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [456814] = {
            [objectKeys.name] = "Vertically Composited Patch Hampler",
            [objectKeys.zoneID] = 46,
            [objectKeys.spawns] = {
                [46] = {{52.3,25},{53.2,26.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [456815] = {
            [objectKeys.name] = "Brass-fitted Flam-Tamp Flange",
            [objectKeys.zoneID] = 46,
            [objectKeys.spawns] = {
                [46] = {{52.3,25},{52.5,25.1},{52.5,25.5},{53,23.9},{53.2,26.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [456874] = {
            [objectKeys.name] = "Sending Pillar",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [456875] = {
            [objectKeys.name] = "Sending Pillar",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [456876] = {
            [objectKeys.name] = "Sending Pillar",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [456877] = {
            [objectKeys.name] = "Sending Pillar",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [456879] = {
            [objectKeys.name] = "Sending Pillar",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [456883] = {
            [objectKeys.name] = "Adon's Trunk",
            [objectKeys.zoneID] = 139,
            [objectKeys.spawns] = {
                [139] = {{62.2,7.4},{62.2,7.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [456918] = {
            [objectKeys.name] = "Console",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457088] = {
            [objectKeys.name] = "Advanced Swordplay",
            [objectKeys.zoneID] = 41,
            [objectKeys.spawns] = {
                [41] = {{43,74.4},{43.1,74.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457089] = {
            [objectKeys.name] = "The Shadow Connection",
            [objectKeys.zoneID] = 4,
            [objectKeys.spawns] = {
                [4] = {{33.6,48.7}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457090] = {
            [objectKeys.name] = "Famous (and Infamous) Rangers of Azeroth",
            [objectKeys.zoneID] = 139,
            [objectKeys.spawns] = {
                [139] = {{26.2,74.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457091] = {
            [objectKeys.name] = "Chen's Training Manual",
            [objectKeys.zoneID] = 16,
            [objectKeys.spawns] = {
                [16] = {{76.9,44.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457092] = {
            [objectKeys.name] = "The Fury of Stormrage",
            [objectKeys.zoneID] = 361,
            [objectKeys.spawns] = {
                [361] = {{62.8,7.4},{62.8,7.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457093] = {
            [objectKeys.name] = "Blunt Justice: A Dwarf's Tale",
            [objectKeys.zoneID] = 11,
            [objectKeys.spawns] = {
                [11] = {{74,69.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457094] = {
            [objectKeys.name] = "The True Nature of the Light",
            [objectKeys.zoneID] = 139,
            [objectKeys.spawns] = {
                [139] = {{83.6,78.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457095] = {
            [objectKeys.name] = "Elements for Dummies Volume I: Frost",
            [objectKeys.zoneID] = 618,
            [objectKeys.spawns] = {
                [618] = {{58.9,59.9}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457096] = {
            [objectKeys.name] = "Be First: A Brawler's Guide to Boxing",
            [objectKeys.zoneID] = 1377,
            [objectKeys.spawns] = {
                [1377] = {{38.1,45.4},{38.2,45.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457097] = {
            [objectKeys.name] = "Elements for Dummies Volume II: Fire",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{40.4,35},{40.5,35.4},{40.5,35.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457098] = {
            [objectKeys.name] = "Finding Your Inner Feline: A Guide to Modern Druidism",
            [objectKeys.zoneID] = 618,
            [objectKeys.spawns] = {
                [618] = {{49.6,8.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457099] = {
            [objectKeys.name] = "Zirene's Guide to Getting Punched",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457100] = {
            [objectKeys.name] = "Renzik's Thoughts on \"Fair\" Fighting",
            [objectKeys.zoneID] = 1377,
            [objectKeys.spawns] = {
                [1377] = {{20,85.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457101] = {
            [objectKeys.name] = "The Rites of Mak'Gora",
            [objectKeys.zoneID] = 46,
            [objectKeys.spawns] = {
                [46] = {{39.9,34.2},{40,34.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457102] = {
            [objectKeys.name] = "Elements for Dummies Volume III: Arcane",
            [objectKeys.zoneID] = 28,
            [objectKeys.spawns] = {
                [28] = {{47.3,13.7}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457387] = {
            [objectKeys.name] = "Heirloom Coffer",
            [objectKeys.zoneID] = 28,
            [objectKeys.spawns] = {
                [28] = {{54.8,81.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457389] = {
            [objectKeys.name] = "Family Records",
            [objectKeys.zoneID] = 28,
            [objectKeys.spawns] = {
                [28] = {{53.9,80.3}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457390] = {
            [objectKeys.name] = "Survivor Journal",
            [objectKeys.zoneID] = 28,
            [objectKeys.spawns] = {
                [28] = {{54.1,80.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [457443] = {
            [objectKeys.name] = "Scarlet Ledger",
            [objectKeys.zoneID] = 28,
            [objectKeys.spawns] = {
                [28] = {{42.2,18.1}},
            },
            [objectKeys.questStarts] = {84322},
            [objectKeys.questEnds] = {84321,84406},
        },
        [459259] = {
            [objectKeys.name] = "Mech Arm",
            [objectKeys.zoneID] = 40,
            [objectKeys.spawns] = {
                [40] = {{52.3,40.8},{52.3,48.9},{52.5,38.4},{53.1,40},{53.1,41.4},{53.3,37.1},{53.3,41.8},{53.5,38.7},{53.5,40.7},{53.9,39.8},{54.1,41.6},{54.8,40}},
                [85] = {{52.4,57.7},{53,55.8},{53.2,57},{53.3,57.5},{53.9,56.5},{54.2,57.5},{54.2,58.7},{54.5,56.7},{54.5,58.2},{54.8,56.4},{57.9,56.9}},
                [1519] = {{55.8,62}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {84213},
        },
        [459388] = {
            [objectKeys.name] = "Artifact Cache",
            [objectKeys.zoneID] = 139,
            [objectKeys.spawns] = {
                [139] = {{83.4,79.5},{83.5,79.4},{83.5,79.5}},
            },
            [objectKeys.questStarts] = {84323,84407},
            [objectKeys.questEnds] = {84322},
        },
        [461155] = {
            [objectKeys.name] = "Console",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [461632] = {
            [objectKeys.name] = "Marked Crate",
            [objectKeys.zoneID] = 28,
            [objectKeys.spawns] = {
                [28] = {{45.8,18.4},{45.9,18.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [461633] = {
            [objectKeys.name] = "Belavus' Safe Box",
            [objectKeys.zoneID] = 28,
            [objectKeys.spawns] = {
                [28] = {{46.5,14.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [461639] = {
            [objectKeys.name] = "Orthas' Hammer",
            [objectKeys.zoneID] = 139,
            [objectKeys.spawns] = {
                [139] = {{61.3,69.2}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [462201] = {
            [objectKeys.name] = "Shards of Light",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [462233] = {
            [objectKeys.name] = "Shimmering Molten Crag",
            [objectKeys.zoneID] = 51,
            [objectKeys.spawns] = {
                [51] = {{48.7,37.3},{48.7,37.5}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [462236] = {
            [objectKeys.name] = "Mysterious Chest",
            [objectKeys.zoneID] = 139,
            [objectKeys.spawns] = {
                [139] = {{27.4,85.8},{27.5,85.8}},
            },
            [objectKeys.questStarts] = {84332},
            [objectKeys.questEnds] = {84332,84414},
        },
        [462432] = {
            [objectKeys.name] = "Wooden Chest",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [463206] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [463207] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 139,
            [objectKeys.spawns] = {
                [139] = {{81.7,57.8}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [463208] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 139,
            [objectKeys.spawns] = {
                [139] = {{54.4,51.1},{54.5,51.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [463209] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 361,
            [objectKeys.spawns] = {
                [361] = {{65.2,3.3}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [463211] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [463212] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 139,
            [objectKeys.spawns] = {
                [139] = {{31.2,21}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [463213] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 28,
            [objectKeys.spawns] = {
                [28] = {{38.2,54.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [463214] = {
            [objectKeys.name] = "Book",
            [objectKeys.zoneID] = 618,
            [objectKeys.spawns] = {
                [618] = {{60.7,37.7}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [463540] = {
            [objectKeys.name] = "Scarlet Toolbox",
            [objectKeys.zoneID] = 28,
            [objectKeys.spawns] = {
                [28] = {{45,14.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [464128] = {
            [objectKeys.name] = "Gift of the Wisp",
            [objectKeys.zoneID] = 361,
            [objectKeys.spawns] = {
                [361] = {{33.5,66.5},{39.4,21},{39.5,22},{40.3,20.1},{41.2,18.9},{41.2,20.4},{41.5,18.6},{41.6,21.2},{41.7,21.6},{41.8,20.1},{42.1,16.2},{42.3,17.1},{42.3,18.4},{42.4,15.4},{42.5,14.4},{42.5,15.1},{42.5,17.8},{42.6,20.2},{42.7,16.8},{42.8,15.5},{43.6,14.3},{44.9,14},{45.6,18.7},{48.2,16.4}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [465021] = {
            [objectKeys.name] = "Skull",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [465022] = {
            [objectKeys.name] = "Skull",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [467315] = {
            [objectKeys.name] = "Old Campsite",
            [objectKeys.zoneID] = 618,
            [objectKeys.spawns] = {
                [618] = {{57.9,20.9}},
            },
            [objectKeys.questStarts] = {84950},
            [objectKeys.questEnds] = {84853},
        },
        [469600] = {
            [objectKeys.name] = "Dry Wood",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [469796] = {
            [objectKeys.name] = "Campsite",
            [objectKeys.zoneID] = 618,
            [objectKeys.spawns] = {
                [618] = {{58,21},{59.5,24.2},{60.3,22.6}},
            },
            [objectKeys.questStarts] = {85525},
            [objectKeys.questEnds] = {84950,85525},
        },
        [477110] = {
            [objectKeys.name] = "Brazier of Madness",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [477757] = {
            [objectKeys.name] = "Hitching Post",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [478062] = {
            [objectKeys.name] = "Damaged Silver Hand Breastplate",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [478075] = {
            [objectKeys.name] = "Campsite",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [478076] = {
            [objectKeys.name] = "Extinguished Campfire",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [489963] = {
            [objectKeys.name] = "Blistering Stone",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [495500] = {
            [objectKeys.name] = "Shadowflame Cache",
            [objectKeys.zoneID] = 2677,
            [objectKeys.spawns] = {
                [2677] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [495503] = {
            [objectKeys.name] = "Chromatic Hoard",
            [objectKeys.zoneID] = 2677,
            [objectKeys.spawns] = {
                [2677] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [495505] = {
            [objectKeys.name] = "Favored Riches",
            [objectKeys.zoneID] = 2677,
            [objectKeys.spawns] = {
                [2677] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [495577] = {
            [objectKeys.name] = "Chromatic Stash",
            [objectKeys.zoneID] = 2677,
            [objectKeys.spawns] = {
                [2677] = {{-1,-1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [499987] = {
            [objectKeys.name] = "Spellbook",
            [objectKeys.zoneID] = 45,
            [objectKeys.spawns] = {
                [45] = {{34.1,80.4},{34.1,80.6}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
        [499988] = {
            [objectKeys.name] = "Spellbook",
            [objectKeys.zoneID] = 400,
            [objectKeys.spawns] = {
                [400] = {{80.1,77.1}},
            },
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = nil,
        },
    }
end
