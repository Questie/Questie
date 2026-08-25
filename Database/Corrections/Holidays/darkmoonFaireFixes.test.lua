dofile("setupTests.lua")

describe("DarkmoonFaireFixes", function()
    ---@type DarkmoonFaireFixes
    local DarkmoonFaireFixes
    ---@type QuestieDB
    local QuestieDB
    ---@type ZoneDB
    local ZoneDB

    before_each(function()
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.npcKeys = {
            spawns = 1,
            zoneID = 2,
        }
        ZoneDB = QuestieLoader:ImportModule("ZoneDB")

        dofile("Database/Corrections/Holidays/darkmoonFaireFixes.lua")
        DarkmoonFaireFixes = QuestieLoader:ImportModule("DarkmoonFaireFixes")
    end)

    it("returns the six Mulgore NPC corrections", function()
        local npcKeys = QuestieDB.npcKeys
        local zoneIDs = ZoneDB.zoneIDs

        assert.are_same({
            [14828] = {
                [npcKeys.spawns] = {[zoneIDs.MULGORE] = {{37.24,37.67}}},
                [npcKeys.zoneID] = zoneIDs.MULGORE,
            },
            [14829] = {
                [npcKeys.spawns] = {[zoneIDs.MULGORE] = {{37.47,39.56}}},
                [npcKeys.zoneID] = zoneIDs.MULGORE,
            },
            [14832] = {
                [npcKeys.spawns] = {[zoneIDs.MULGORE] = {{37.82,39.81}}},
                [npcKeys.zoneID] = zoneIDs.MULGORE,
            },
            [14833] = {
                [npcKeys.spawns] = {[zoneIDs.MULGORE] = {{36.17,35.15}}},
                [npcKeys.zoneID] = zoneIDs.MULGORE,
            },
            [14841] = {
                [npcKeys.spawns] = {[zoneIDs.MULGORE] = {{37.09,37.17}}},
                [npcKeys.zoneID] = zoneIDs.MULGORE,
            },
            [14871] = {
                [npcKeys.spawns] = {[zoneIDs.MULGORE] = {{35.92,35.27}}},
                [npcKeys.zoneID] = zoneIDs.MULGORE,
            },
        }, DarkmoonFaireFixes.GetNpcFixes(DarkmoonFaireFixes.locations.MULGORE))
    end)

    it("returns the six Elwynn Forest NPC corrections", function()
        local npcKeys = QuestieDB.npcKeys
        local zoneIDs = ZoneDB.zoneIDs

        assert.are_same({
            [14828] = {
                [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST] = {{41.5,68.87}}},
                [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            },
            [14829] = {
                [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST] = {{40.17,69.53}}},
                [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            },
            [14832] = {
                [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST] = {{40.49,69.93}}},
                [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            },
            [14833] = {
                [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST] = {{43.61,70.84}}},
                [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            },
            [14841] = {
                [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST] = {{41.71,70.72}}},
                [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            },
            [14871] = {
                [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST] = {{43.34,70.28}}},
                [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            },
        }, DarkmoonFaireFixes.GetNpcFixes(DarkmoonFaireFixes.locations.ELWYNN_FOREST))
    end)

    it("returns the six Terokkar Forest NPC corrections", function()
        local npcKeys = QuestieDB.npcKeys
        local zoneIDs = ZoneDB.zoneIDs

        assert.are_same({
            [14828] = {
                [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{34.68,34.36}}},
                [npcKeys.zoneID] = zoneIDs.TEROKKAR_FOREST,
            },
            [14829] = {
                [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{34.33,35.73}}},
                [npcKeys.zoneID] = zoneIDs.TEROKKAR_FOREST,
            },
            [14832] = {
                [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{34.84,35.15}}},
                [npcKeys.zoneID] = zoneIDs.TEROKKAR_FOREST,
            },
            [14833] = {
                [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{33.82,35.96}}},
                [npcKeys.zoneID] = zoneIDs.TEROKKAR_FOREST,
            },
            [14841] = {
                [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{34.04,34.82}}},
                [npcKeys.zoneID] = zoneIDs.TEROKKAR_FOREST,
            },
            [14871] = {
                [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{33.67,35.93}}},
                [npcKeys.zoneID] = zoneIDs.TEROKKAR_FOREST,
            },
        }, DarkmoonFaireFixes.GetNpcFixes(DarkmoonFaireFixes.locations.TEROKKAR_FOREST))
    end)
end)
