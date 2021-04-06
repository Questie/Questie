---@class QuestieTBCNpcFixes
local QuestieTBCNpcFixes = QuestieLoader:CreateModule("QuestieTBCNpcFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function QuestieTBCNpcFixes:Load()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs
    local npcFlags = QuestieDB.npcFlags

    return {
        [16992] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{43.24,76.62},{42.95,76.43},{42.88,75.41},{43.11,78.29},{42.58,78.1},{44.3,79.35},{43.19,80.51},{26.33,66.82},{26.2,66.41},{23.66,61.87},{24.33,60.97},{22.99,58.95},{23.72,59.86},{22.45,58.09},{24.6,58.71},{24.39,57.88},{23.65,57.97},{23.06,56.98},{24.79,62.83},{25.41,63.77},{24.78,56.3},{24.05,55.43},{24.26,57.07},{25.19,53.55},{23.41,56.27},{23.56,54.34},{24.27,54.24},{23.98,52.22},{24.61,51.82},{23.11,53.18},{23.08,51.08},{24.0,50.7},{22.46,52.25},{22.4,54.07},{21.74,55.02},{22.37,55.94},{19.96,54.71},{21.19,55.99},{20.03,56.73},{20.36,57.06},{21.79,56.96},{19.04,56.28},{19.04,55.08},{18.66,56.61},{18.32,53.76},{17.58,54.21},{16.99,52.16},{17.39,53.31},{27.45,42.55},{25.59,41.21},{26.48,37.46},{26.74,37.48},{28.07,39.46},{27.31,39.01},{26.83,40.01},{27.57,41.47},{27.15,41.57},{28.34,41.75},{28.29,40.58},{29.45,43.69},{31.44,44.43},{30.88,43.32},{31.05,41.48},{29.47,39.59},},},
        },
        [16994] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{39.04,40.32},},},
        },
        [17000] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{40.22,31.09},},},
        },
        [17087] = {
            [npcKeys.spawns] = {[zoneIDs.AZUREMYST_ISLE] = {{71.8,40.2},},},
        },
        [17311] = {
            [npcKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{54.08,55.1},},[zoneIDs.AZUREMYST_ISLE] = {{16,94},},},
        },
        [18152] = {
            [npcKeys.spawns] = {[zoneIDs.ZANGARMARSH] = {{26.4,22},},},
        },
        [19305] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{13.64,39.12},},},
        },
        [21638] = {
            [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{50.88,54.76},},},
        },
    }
end