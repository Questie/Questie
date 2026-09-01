dofile("setupTests.lua")
local LoadQuestieTDBMetaMock = dofile("test/QuestieTDBMetaMock.lua")

describe("QuestieClassicPolicyCorrections", function()
    ---@type QuestieClassicPolicyCorrections
    local QuestieClassicPolicyCorrections
    local elwynnCorrections
    local mulgoreCorrections

    before_each(function()
        LoadQuestieTDBMetaMock()
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

        dofile("Database/Corrections/QuestiePolicy/classicPolicyCorrections.lua")
        QuestieClassicPolicyCorrections = QuestieLoader:ImportModule("QuestieClassicPolicyCorrections")

        local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        local npcKeys = QuestieDB.npcKeys
        local zoneIDs = ZoneDB.zoneIDs

        elwynnCorrections = {
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
        }
        mulgoreCorrections = {
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
        }
    end)

    describe("LoadDarkmoonFixes", function()
        it("returns the complete Elwynn Forest replacement", function()
            assert.are_same(elwynnCorrections, QuestieClassicPolicyCorrections:LoadDarkmoonFixes(false))
        end)

        it("returns the complete Mulgore replacement", function()
            assert.are_same(mulgoreCorrections, QuestieClassicPolicyCorrections:LoadDarkmoonFixes(true))
        end)
    end)
end)
