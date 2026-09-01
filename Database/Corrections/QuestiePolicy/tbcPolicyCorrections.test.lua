dofile("setupTests.lua")
dofile("Database/Corrections/ContentPhases/ContentPhases.lua")

describe("QuestieTBCPolicyCorrections", function()
    ---@type QuestieTBCPolicyCorrections
    local QuestieTBCPolicyCorrections
    ---@type ContentPhases
    local ContentPhases
    ---@type Expansions
    local Expansions
    local originalExpansion
    local originalTBCPhase
    local elwynnCorrections
    local mulgoreCorrections
    local terokkarCorrections
    local beforePhaseThreeCorrections
    local phaseThreeAndLaterCorrections

    before_each(function()
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.npcKeys = {
            spawns = 7,
            zoneID = 8,
        }
        QuestieDB.questKeys = {
            preQuestGroup = 13,
            preQuestSingle = 14,
        }

        dofile("Database/Corrections/QuestiePolicy/tbcPolicyCorrections.lua")
        QuestieTBCPolicyCorrections = QuestieLoader:ImportModule("QuestieTBCPolicyCorrections")
        ContentPhases = QuestieLoader:ImportModule("ContentPhases")
        Expansions = QuestieLoader:ImportModule("Expansions")
        originalExpansion = Expansions.Current
        originalTBCPhase = ContentPhases.activePhases.TBC

        local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        local npcKeys = QuestieDB.npcKeys
        local questKeys = QuestieDB.questKeys
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
        terokkarCorrections = {
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
        }
        beforePhaseThreeCorrections = {
            [10944] = {
                [questKeys.preQuestGroup] = {10901,11052},
                [questKeys.preQuestSingle] = {},
            },
            [11007] = {
                [questKeys.preQuestSingle] = {10888},
            },
        }
        phaseThreeAndLaterCorrections = {
            [10944] = {
                [questKeys.preQuestGroup] = {},
                [questKeys.preQuestSingle] = {10708,11052},
            },
            [11007] = {
                [questKeys.preQuestSingle] = {},
            },
        }
    end)

    after_each(function()
        Expansions.Current = originalExpansion
        ContentPhases.activePhases.TBC = originalTBCPhase
    end)

    describe("LoadDarkmoonFixes", function()
        it("returns the complete Elwynn Forest replacement", function()
            assert.are_same(elwynnCorrections, QuestieTBCPolicyCorrections:LoadDarkmoonFixes(false, false))
        end)

        it("returns the complete Mulgore replacement", function()
            assert.are_same(mulgoreCorrections, QuestieTBCPolicyCorrections:LoadDarkmoonFixes(true, false))
        end)

        it("returns the complete Terokkar Forest replacement", function()
            assert.are_same(terokkarCorrections, QuestieTBCPolicyCorrections:LoadDarkmoonFixes(false, true))
        end)

        it("gives Terokkar Forest precedence when both location inputs are true", function()
            assert.are_same(terokkarCorrections, QuestieTBCPolicyCorrections:LoadDarkmoonFixes(true, true))
        end)
    end)

    describe("LoadContentPhaseFixes", function()
        it("returns the phase two prerequisites with empty replacement fields", function()
            Expansions.Current = Expansions.Tbc
            ContentPhases.activePhases.TBC = 2

            assert.are_same(beforePhaseThreeCorrections, QuestieTBCPolicyCorrections:LoadContentPhaseFixes())
        end)

        it("returns the phase three prerequisites with empty withdrawal-compatible fields", function()
            Expansions.Current = Expansions.Tbc
            ContentPhases.activePhases.TBC = 3

            assert.are_same(phaseThreeAndLaterCorrections, QuestieTBCPolicyCorrections:LoadContentPhaseFixes())
        end)

        it("keeps the phase three prerequisites in later TBC phases", function()
            Expansions.Current = Expansions.Tbc
            ContentPhases.activePhases.TBC = 4

            assert.are_same(phaseThreeAndLaterCorrections, QuestieTBCPolicyCorrections:LoadContentPhaseFixes())
        end)

        it("keeps the cumulative post-phase-three prerequisites in later expansions", function()
            Expansions.Current = Expansions.Wotlk
            ContentPhases.activePhases.TBC = 2

            assert.are_same(phaseThreeAndLaterCorrections, QuestieTBCPolicyCorrections:LoadContentPhaseFixes())
        end)
    end)
end)
