dofile("setupTests.lua")

describe("CataNpcFixes", function()
    it("uses the island spawn zone for the six relocated Darkmoon Faire NPCs", function()
        ---@type QuestieDB
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.npcKeys = {
            spawns = 1, zoneID = 2, questStarts = 3, questEnds = 4, waypoints = 5,
            name = 6, friendlyToFaction = 7, subName = 8, npcFlags = 9,
        }
        QuestieDB.waypointPresets = {}
        QuestieDB.npcFlags = {NONE = 0, STABLEMASTER = 4194304}
        QuestieLoader:ImportModule("Phasing").phases = {}
        ---@type ZoneDB
        local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        local island = ZoneDB.zoneIDs.DARKMOON_FAIRE_ISLAND

        dofile("Database/Corrections/cataNPCFixes.lua")
        local corrections = QuestieLoader:ImportModule("CataNpcFixes").Load()

        for _, npcId in ipairs({14828, 14829, 14832, 14833, 14841, 14871}) do
            local correction = corrections[npcId]
            local spawns = correction[QuestieDB.npcKeys.spawns]
            assert.equals(island, correction[QuestieDB.npcKeys.zoneID], "NPC " .. npcId)
            assert.is_table(spawns[island])
            assert.equals(island, next(spawns))
            assert.is_nil(next(spawns, island))
        end
    end)
end)
