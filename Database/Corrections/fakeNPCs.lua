---@class FakeData
local FakeData = QuestieLoader:CreateModule("FakeData")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

--- This function loads fake NPCs which are used for quests with too many starters.
--- The IDs are starting at 300000 to not collide with real NPCs.
---@return table<number, table<string, any>>
function FakeData:LoadNPCs()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
        [300000] = { -- 90008
            [npcKeys.name] = "Defias Pillager",
            [npcKeys.minLevel] = 14,
            [npcKeys.maxLevel] = 15,
            [npcKeys.zoneID] = zoneIDs.WESTFALL,
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{31.4,45},{38.1,57.2},{42.9,67.7}},
            },
        },
        [300001] = { -- 90009
            [npcKeys.name] = "Dalaran Apprentice",
            [npcKeys.minLevel] = 13,
            [npcKeys.maxLevel] = 14,
            [npcKeys.zoneID] = zoneIDs.SILVERPINE_FOREST,
            [npcKeys.spawns] = {
                [zoneIDs.SILVERPINE_FOREST] = {{51.2,60.6},{50.7,68.8},{55.9,73}},
            },
        },
        [300002] = { -- 90010
            [npcKeys.name] = "Polymorphed Apprentice",
            [npcKeys.minLevel] = 1,
            [npcKeys.maxLevel] = 1,
            [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{47.2,80.3}},
            },
        },
        [300003] = { -- 90011
            [npcKeys.name] = "Odd Melon",
            [npcKeys.minLevel] = 1,
            [npcKeys.maxLevel] = 1,
            [npcKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{53.5,57.3}},
            },
        },
        [300004] = { -- 90015
            [npcKeys.name] = "Kobold Geomancer",
            [npcKeys.minLevel] = 7,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{61.8,53.2}},
            },
        },
        [300005] = { -- 90016
            [npcKeys.name] = "Frostmane Shadowcaster",
            [npcKeys.minLevel] = 9,
            [npcKeys.maxLevel] = 10,
            [npcKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{25.2,50.7}},
            },
        },
        [300006] = { -- 90017
            [npcKeys.name] = "Burning Blade Fanatic",
            [npcKeys.minLevel] = 9,
            [npcKeys.maxLevel] = 10,
            [npcKeys.zoneID] = zoneIDs.DUROTAR,
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{54.7,9.9},{42.5,26.3}},
            },
        },
        [300007] = { -- 90018
            [npcKeys.name] = "Scarlet Warrior",
            [npcKeys.minLevel] = 6,
            [npcKeys.maxLevel] = 7,
            [npcKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{32.6,47.9}},
            },
        },
        [300008] = { -- 90020
            [npcKeys.name] = "Stonesplinter Seer",
            [npcKeys.minLevel] = 13,
            [npcKeys.maxLevel] = 14,
            [npcKeys.zoneID] = zoneIDs.LOCH_MODAN,
            [npcKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{30.6,80.1},{36,83.2}},
            },
        },
        [300009] = { -- 90023
            [npcKeys.name] = "Grimtotem Tauren",
            [npcKeys.minLevel] = 14,
            [npcKeys.maxLevel] = 15,
            [npcKeys.zoneID] = zoneIDs.STONETALON_MOUNTAINS,
            [npcKeys.spawns] = {
                [zoneIDs.STONETALON_MOUNTAINS] = {{74.2,91.6}},
            },
        },
        [300010] = { -- 90036
            [npcKeys.name] = "Harvest Watcher",
            [npcKeys.minLevel] = 14,
            [npcKeys.maxLevel] = 15,
            [npcKeys.zoneID] = zoneIDs.WESTFALL,
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{38.2,51.9}},
            },
        },
        [300011] = { -- 90036
            [npcKeys.name] = "Rusty Harvest Golem",
            [npcKeys.minLevel] = 9,
            [npcKeys.maxLevel] = 10,
            [npcKeys.zoneID] = zoneIDs.WESTFALL,
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{54,32}},
            },
        },
        [300012] = { -- 90036
            [npcKeys.name] = "Dust Devil",
            [npcKeys.minLevel] = 18,
            [npcKeys.maxLevel] = 19,
            [npcKeys.zoneID] = zoneIDs.WESTFALL,
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{62.1,52.6}},
            },
        },
        [300013] = { -- 90036
            [npcKeys.name] = "Harvest Reaper Prototype",
            [npcKeys.minLevel] = 18,
            [npcKeys.maxLevel] = 18,
            [npcKeys.zoneID] = zoneIDs.WESTFALL,
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{45.4,38.5}},
            },
        },
        [300014] = { -- 90016
            [npcKeys.name] = "Frostmane Seer",
            [npcKeys.minLevel] = 9,
            [npcKeys.maxLevel] = 10,
            [npcKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{40.7,43.6}},
            },
        },
        [300015] = { -- 90077
            [npcKeys.name] = "Wendigo",
            [npcKeys.minLevel] = 5,
            [npcKeys.maxLevel] = 6,
            [npcKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{42.6,53.7}},
            },
        },
        [300016] = { -- 90077
            [npcKeys.name] = "Wolf",
            [npcKeys.minLevel] = 1,
            [npcKeys.maxLevel] = 1,
            [npcKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{44.6,46.5}},
            },
        },
        [300017] = { -- 90077
            [npcKeys.name] = "Soboz", -- duplicate of NPC 204070
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{42.2, 35.4}},
            },
        },
        [300018] = { -- 90078
            [npcKeys.name] = "Kobold",
            [npcKeys.minLevel] = 7,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{61.8,53.2}},
            },
        },
        [300019] = { -- 90078
            [npcKeys.name] = "Gnoll",
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 9,
            [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{27.73,86.64}},
            },
        },
        [300020] = { -- 90079
            [npcKeys.name] = "Voodoo Troll",
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 9,
            [npcKeys.zoneID] = zoneIDs.DUROTAR,
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{67.22,87.34}},
            },
        },
        [300021] = { -- 90079
            [npcKeys.name] = "Makrura",
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 9,
            [npcKeys.zoneID] = zoneIDs.DURATAR,
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{60.28,73.5}},
            },
        },
        [300022] = { -- 90079
            [npcKeys.name] = "Kul Tiran",
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 9,
            [npcKeys.zoneID] = zoneIDs.DURATAR,
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{60.22,59.18}},
            },
        },
        [300023] = { -- 90079
            [npcKeys.name] = "Soboz", -- duplicate of NPC 204070
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.DUROTAR,
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{67.4, 87.8}},
            },
        },
        [300024] = { -- 90080
            [npcKeys.name] = "Soboz", -- duplicate of NPC 204070
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.UNDERCITY,
            [npcKeys.spawns] = {
                [zoneIDs.UNDERCITY] = {{22.8, 42.8}},
            },
        },
        [300025] = { -- 90078
            [npcKeys.name] = "Soboz", -- duplicate of NPC 204070
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.STORMWIND_CITY,
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{25.6, 78}},
            },
        },
        [300026] = { -- 90080
            [npcKeys.name] = "Darkeye Bonecaster",
            [npcKeys.minLevel] = 7,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{48.1,35.6}},
            },
        },
        [300027] = { -- 90080
            [npcKeys.name] = "Gnoll",
            [npcKeys.minLevel] = 7,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{59.4,35.3}},
            },
        },
        [300028] = { -- 90080
            [npcKeys.name] = "Darkhound",
            [npcKeys.minLevel] = 5,
            [npcKeys.maxLevel] = 6,
            [npcKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{46.8,51.4}},
            },
        },
        [300029] = { -- 90078
            [npcKeys.name] = "Wolf",
            [npcKeys.minLevel] = 1,
            [npcKeys.maxLevel] = 1,
            [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{47.2,80.3}},
            },
        },
        [300030] = { -- 968
            [npcKeys.name] = "Twilight Member",
            [npcKeys.minLevel] = 17,
            [npcKeys.maxLevel] = 17,
            [npcKeys.zoneID] = zoneIDs.DARKSHORE,
            [npcKeys.spawns] = {
                [zoneIDs.DARKSHORE] = {{38.9,86.7}},
            },
        },
        [300031] = { -- 90035
            [npcKeys.name] = "Dark Strand Fanatic",
            [npcKeys.minLevel] = 16,
            [npcKeys.maxLevel] = 17,
            [npcKeys.zoneID] = zoneIDs.DARKSHORE,
            [npcKeys.spawns] = {
                [zoneIDs.DARKSHORE] = {{56.2,26.8}},
            },
        },
        [300032] = { -- 90069
            [npcKeys.name] = "Ravenclaw Member",
            [npcKeys.minLevel] = 16,
            [npcKeys.maxLevel] = 17,
            [npcKeys.zoneID] = zoneIDs.SILVERPINE_FOREST,
            [npcKeys.spawns] = {
                [zoneIDs.SILVERPINE_FOREST] = {{58.9,71.7}},
            },
        },
        [300033] = { -- 90085
            [npcKeys.name] = "Dark Iron Insurgent",
            [npcKeys.minLevel] = 1,
            [npcKeys.maxLevel] = 1,
            [npcKeys.zoneID] = zoneIDs.LOCH_MODAN,
            [npcKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{58.95,13.51}},
            },
        },
        [300034] = { -- 1480
            [npcKeys.name] = "Burning Blade Member",
            [npcKeys.minLevel] = 30,
            [npcKeys.maxLevel] = 31,
            [npcKeys.zoneID] = zoneIDs.DESOLACE,
            [npcKeys.spawns] = {
                [zoneIDs.DESOLACE] = {{56.6,30.6}},
            },
        },
        [300035] = { -- 178
            [npcKeys.name] = "Shadowhide Gnoll",
            [npcKeys.minLevel] = 23,
            [npcKeys.maxLevel] = 25,
            [npcKeys.zoneID] = zoneIDs.REDRIDGE_MOUNTAINS,
            [npcKeys.spawns] = {
                [zoneIDs.REDRIDGE_MOUNTAINS] = {{78.1,39}},
            },
        },
        [300036] = { -- 136
            [npcKeys.name] = "Murloc",
            [npcKeys.minLevel] = 11,
            [npcKeys.maxLevel] = 17,
            [npcKeys.zoneID] = zoneIDs.WESTFALL,
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{34.4,83.1},{28.1,70.2},{27.1,48.8},{32.4,25.6},{47,10.7}},
            },
        },
        [300037] = { -- 4451
            [npcKeys.name] = "Dark Iron Member",
            [npcKeys.minLevel] = 47,
            [npcKeys.maxLevel] = 48,
            [npcKeys.zoneID] = zoneIDs.SEARING_GORGE,
            [npcKeys.spawns] = {
                [zoneIDs.SEARING_GORGE] = {{33.5,53.5},{36.5,60.4},{44.4,62.1},{49.7,55.6},{41.1,49.9}},
            },
        },
    }
end
