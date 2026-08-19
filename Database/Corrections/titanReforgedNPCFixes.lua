---@class TitanReforgedNpcFixes
local TitanReforgedNpcFixes = QuestieLoader:CreateModule("TitanReforgedNpcFixes")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

---Returns Titan-only NPC corrections applied before database compilation.
---@return table<NpcId, table>
function TitanReforgedNpcFixes.LoadNPCs()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
        -- Relationship corrections replace whole fields, so these lists intentionally repeat inherited WotLK quest IDs.
        [14910] = { -- Exzhal
            [npcKeys.questStarts] = {8201,98183},
            [npcKeys.questEnds] = {8201,98183},
        },
        [14921] = { -- Rin'wosho the Trader
            [npcKeys.questStarts] = {8196,8243,8246,95205},
            [npcKeys.questEnds] = {8196,8243,8246,95205},
        },
        [15042] = { -- Zanza the Restless
            [npcKeys.questStarts] = {8184,8185,8186,8187,8188,8189,8190,8191,8192,9208,9209,9210,95072,95074,95075,95076,95077,95078,95079,95080,95081,95082,95083,95084,95085,95088,95089,95090,95092,95093,95094,95095,95096,95097,95098,95099,95100,95101,95102,95103,95104,95105,95106},
            [npcKeys.questEnds] = {8184,8185,8186,8187,8188,8189,8190,8191,8192,9208,9209,9210,95072,95074,95075,95076,95077,95078,95079,95080,95081,95082,95083,95084,95085,95088,95089,95090,95092,95093,95094,95095,95096,95097,95098,95099,95100,95101,95102,95103,95104,95105,95106},
        },
        [20735] = { -- Archmage Lan'dalock
            [npcKeys.questStarts] = {13245,13246,13247,13248,13249,13250,13251,13252,13253,13254,13255,13256,14199,24579,24580,24581,24582,24583,24584,24585,24586,24587,24588,24589,24590,78752,78753,83713,83714,83717,87379,93975,94577,94579,95037,96312,96315,96318},
            [npcKeys.questEnds] = {13245,13246,13247,13248,13249,13250,13251,13252,13253,13254,13255,13256,14199,24579,24580,24581,24582,24583,24584,24585,24586,24587,24588,24589,24590,78752,78753,83713,83714,83717,87379,93975,94577,94579,95037,96312,96315,96318},
        },
        [31136] = {
            [npcKeys.questStarts] = {94576},
            [npcKeys.questEnds] = {94576},
        },
        [80007] = {
            [npcKeys.name] = "?",
            [npcKeys.spawns] = {[zoneIDs.ZUL_GURUB] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.ZUL_GURUB,
            [npcKeys.questEnds] = {96211},
        },
        [256887] = { -- Greater Dust Stormer
            [npcKeys.name] = "Greater Dust Stormer",
            [npcKeys.minLevel] = 80,
            [npcKeys.maxLevel] = 80,
            [npcKeys.minLevelHealth] = 11752,
            [npcKeys.maxLevelHealth] = 11752,
            [npcKeys.spawns] = {[zoneIDs.SILITHUS] = {{27.49,18.13},{28.47,19.96},{30.17,13.88},{30.37,16.82},{29.25,15.28},{32.1,14.26},{32.05,16.82},{31.22,16.03},{31.19,18.16},{33.25,12.89},{32.95,15.27},{34.21,13.5},{34.71,12.45},{28.53,22.51},{29.51,21.45},{29.39,18.51},{30.16,20.12},{28.41,17.51},{34.73,25.49},{22.78,28.24},{19.68,27.37},{18.57,25.46},{23.65,27.15},{18.97,22.24},{19.59,21.27},{18.73,19.9},{17.62,23.56},{17.61,26.59},{17.04,24.91},{18.7,28.5},{17.09,26.72},{18.01,29.51},{19.98,29.55},{22.63,25.15},{19.9,18.2},{21.71,24.19},{22.46,22.77},{21.81,21.27},{20.48,23.06},{21.81,26.95},{20.75,25.49},{21.55,30.04},{20.37,31.18},{19.86,32.0},{20.59,28.25},{18.11,32.46}}},
            [npcKeys.zoneID] = zoneIDs.SILITHUS,
        },
        [256889] = { -- Greater Desert Rumbler
            [npcKeys.name] = "Greater Desert Rumbler",
            [npcKeys.minLevel] = 80,
            [npcKeys.maxLevel] = 80,
            [npcKeys.minLevelHealth] = 11752,
            [npcKeys.maxLevelHealth] = 11752,
            [npcKeys.spawns] = {[zoneIDs.SILITHUS] = {{27.0,15.53},{18.73,17.13},{22.63,19.54},{25.45,15.16},{26.91,10.98},{28.31,14.1},{25.53,12.26},{26.48,14.24},{22.04,11.62},{24.61,11.32},{25.25,9.65},{24.58,13.77},{23.45,15.51},{23.65,9.9},{21.83,15.84},{20.68,16.6},{20.82,14.0},{21.62,10.01},{21.06,10.57},{22.18,8.63},{21.82,12.73},{22.7,14.46},{19.97,15.7},{23.49,17.91},{22.72,17.4},{21.48,17.76}}},
            [npcKeys.zoneID] = zoneIDs.SILITHUS,
        },
        [257012] = { -- Algalon the Observer
            [npcKeys.name] = "Algalon the Observer",
            [npcKeys.minLevel] = 83,
            [npcKeys.maxLevel] = 83,
            [npcKeys.rank] = 3,
            [npcKeys.minLevelHealth] = 8367000,
            [npcKeys.maxLevelHealth] = 8367000,
            [npcKeys.questStarts] = {93950},
            [npcKeys.questEnds] = {93950},
            [npcKeys.spawns] = {
                [zoneIDs.AZUREMYST_ISLE] = {{83.23,43.38}},
                [zoneIDs.MULGORE] = {{45.28,77.47}},
                [zoneIDs.EVERSONG_WOODS] = {{38.1,19.99}},
                [zoneIDs.DUROTAR] = {{44.15,67.51}},
                [zoneIDs.TIRISFAL_GLADES] = {{31.38,70.3}},
                [zoneIDs.ELWYNN_FOREST] = {{47.82,42.34}},
                [zoneIDs.DUN_MOROGH] = {{28.85,71.35}},
                [zoneIDs.TELDRASSIL] = {{58.38,41.76}}
            },
            [npcKeys.friendlyToFaction] = "AH",
        },
        [257403] = { -- Algalon the Observer
            [npcKeys.name] = "Algalon the Observer",
            [npcKeys.minLevel] = 83,
            [npcKeys.maxLevel] = 83,
            [npcKeys.rank] = 3,
            [npcKeys.minLevelHealth] = 8367000,
            [npcKeys.maxLevelHealth] = 8367000,
            [npcKeys.questStarts] = {94376},
            [npcKeys.questEnds] = {94376},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{45.42,16.06}}},
            [npcKeys.friendlyToFaction] = "AH",
        },
        [262258] = { -- Boss Gobb Goldnick
            [npcKeys.name] = "Boss Gobb Goldnick",
            [npcKeys.minLevel] = 80,
            [npcKeys.maxLevel] = 80,
            [npcKeys.minLevelHealth] = 12600,
            [npcKeys.maxLevelHealth] = 12600,
            [npcKeys.questStarts] = {95705,95706,95844,95845},
            [npcKeys.questEnds] = {95705,95706,95844,95845},
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{32.12,50.75}},
                [zoneIDs.DUN_MOROGH] = {{52.46,35.32}},
                [zoneIDs.TELDRASSIL] = {{56.29,90.01}},
                [zoneIDs.DUROTAR] = {{45.01,12.61}},
                [zoneIDs.UNDERCITY] = {{65.99,21.77}},
                [zoneIDs.THUNDER_BLUFF] = {{29.61,65.38}}
            },
            [npcKeys.friendlyToFaction] = "AH",
        },
    }
end

---Returns runtime overrides for NPCs inherited from the WotLK database.
---@return table<NpcId, table>
function TitanReforgedNpcFixes.LoadNPCOverrides()
    local npcKeys = QuestieDB.npcKeys

    return {
        [14834] = {
            [npcKeys.minLevel] = 83,
            [npcKeys.maxLevel] = 83,
            [npcKeys.minLevelHealth] = 32702700,
            [npcKeys.maxLevelHealth] = 32702700,
        },
        [15042] = {
            [npcKeys.minLevel] = 80,
            [npcKeys.maxLevel] = 80,
            [npcKeys.minLevelHealth] = 79668,
            [npcKeys.maxLevelHealth] = 79668,
        },
    }
end

---Selects the capital used for Titan NPCs that serve both factions.
---@return table<NpcId, table>
function TitanReforgedNpcFixes.LoadFactionNPCOverrides()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs

    if UnitFactionGroup("Player") == "Horde" then
        return {
            [257012] = { -- Algalon the Observer
                [npcKeys.zoneID] = zoneIDs.DUROTAR,
            },
            [262258] = { -- Boss Gobb Goldnick
                [npcKeys.zoneID] = zoneIDs.DUROTAR,
            },
        }
    end

    return {
        [257012] = { -- Algalon the Observer
            [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
        },
        [262258] = { -- Boss Gobb Goldnick
            [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
        },
    }
end
