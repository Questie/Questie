dofile("Modules/Libs/QuestieLoader.lua")

local playerFaction = "Horde"
_G["UnitFactionGroup"] = function()
    return playerFaction
end
_G["C_QuestLog"] = {}

describe("Phasing", function()
    ---@type Phasing
    local Phasing
    ---@type QuestLogCache
    local QuestLogCache

    local phases

    before_each(function()
        -- Accessing _G["Questie"] is required
        _G["Questie"] = {db = {char = {complete = {}}}}
        Questie = _G["Questie"]

        QuestLogCache = require("Modules.Quest.QuestLogCache")
        QuestLogCache.questLog_DO_NOT_MODIFY = {}

        Phasing = require("Modules.Phasing")
        phases = Phasing.phases
        Phasing.Initialize()
    end)

    it("should return true for phase nil", function()
        assert.is_true(Phasing.IsSpawnVisible(nil))
    end)

    it("should return true for UNKNOWN", function()
        assert.is_true(Phasing.IsSpawnVisible(phases.UNKNOWN))
    end)

    describe("quests in quest log", function()
        it("should return true for phase ID 177 when certain quests are accepted", function()
            QuestLogCache.questLog_DO_NOT_MODIFY = {[13847]={}}

            assert.is_true(Phasing.IsSpawnVisible(phases.CUSTOM_EVENT_3))
        end)
    end)

    describe("Kezan", function()
        it("should return true for KEZAN_CHAPTER_1", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_1))
        end)

        it("should return false for KEZAN_CHAPTER_1 when quest 14121-14124 are complete", function()
            Questie.db.char.complete[14121] = true
            Questie.db.char.complete[14122] = true
            Questie.db.char.complete[14123] = true
            Questie.db.char.complete[14124] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_1))
        end)

        it("should return false for KEZAN_CHAPTER_1 when quest 14125 is complete", function()
            Questie.db.char.complete[14125] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_1))
        end)

        it("should return true for KEZAN_CHAPTER_5 when quest 14115 is complete", function()
            Questie.db.char.complete[14115] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_5))
        end)

        it("should return false for KEZAN_CHAPTER_1 when quest 14115 is complete", function()
            Questie.db.char.complete[14115] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_1))
        end)

        it("should return true for KEZAN_CHAPTER_6 when quest 14121-14124 are complete", function()
            Questie.db.char.complete[14121] = true
            Questie.db.char.complete[14122] = true
            Questie.db.char.complete[14123] = true
            Questie.db.char.complete[14124] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_6))
        end)

        it("should return true for KEZAN_CHAPTER_7 when quest 14125 is complete", function()
            Questie.db.char.complete[14125] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_7))
        end)

        it("should return false for KEZAN_CHAPTER_5 when quest 14125 is complete", function()
            Questie.db.char.complete[14115] = true
            Questie.db.char.complete[14125] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_5))
        end)

        it("should return false for KEZAN_CHAPTER_5 when quest 14121-14124 are complete", function()
            Questie.db.char.complete[14115] = true
            Questie.db.char.complete[14121] = true
            Questie.db.char.complete[14122] = true
            Questie.db.char.complete[14123] = true
            Questie.db.char.complete[14124] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_5))
        end)

        it("should return false for KEZAN_CHAPTER_6 when quest 14125 is complete", function()
            Questie.db.char.complete[14121] = true
            Questie.db.char.complete[14122] = true
            Questie.db.char.complete[14123] = true
            Questie.db.char.complete[14124] = true
            Questie.db.char.complete[14125] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_6))
        end)

        it("should return false for other chapter than chapter 1", function()
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_2))
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_3))
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_4))
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_5))
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_6))
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_7))
        end)

        it("should handle Sassy Hardwrench positioning", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.KEZAN_SASSY_IN_HQ))
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_SASSY_OUTSIDE_HQ))

            QuestLogCache.questLog_DO_NOT_MODIFY = {}
            Questie.db.char.complete[14116] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_SASSY_IN_HQ))
            assert.is_true(Phasing.IsSpawnVisible(phases.KEZAN_SASSY_OUTSIDE_HQ))
        end)

        it("should handle Trade Prince Gallywix positioning", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.KEZAN_GALLYWIX_AT_HQ))
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_GALLYWIX_ON_BOAT))

            QuestLogCache.questLog_DO_NOT_MODIFY = {}
            Questie.db.char.complete[14120] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_GALLYWIX_AT_HQ))
            assert.is_true(Phasing.IsSpawnVisible(phases.KEZAN_GALLYWIX_ON_BOAT))
        end)
    end)

    describe("The Lost Isles", function()
        before_each(function()
            playerFaction = "Horde"
            Phasing.Initialize()
        end)

        it("should return true for chapter 1 when quest 14126 is complete", function()
            Questie.db.char.complete[14126] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_1))
        end)

        it("should return true for chapter 2 when quest 14303 is complete", function()
            Questie.db.char.complete[14303] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_2))
        end)

        it("should return true for chapter 3 when quest 14240 is complete", function()
            Questie.db.char.complete[14240] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_3))
        end)

        it("should return true for chapter 4 when quest 14242 is complete", function()
            Questie.db.char.complete[14242] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_4))
        end)

        it("should return true for chapter 5 when quest 14244 is complete", function()
            Questie.db.char.complete[14244] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_5))
        end)

        it("should return true for chapter 6 when quest 24868 is complete", function()
            Questie.db.char.complete[24868] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_6))
        end)

        it("should return true for chapter 7 when quest 24929 and 24925 are complete", function()
            Questie.db.char.complete[24925] = true
            Questie.db.char.complete[24929] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_7))
        end)

        it("should return true for chapter 8 when quest 24958 is complete", function()
            Questie.db.char.complete[24958] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_8))
        end)

        it("should return true for chapter 9 when quest 25125 is complete", function()
            Questie.db.char.complete[25125] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_9))
        end)

        it("should return true for chapter 10 when quest 25251 is complete", function()
            Questie.db.char.complete[25251] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_10))
        end)

        it("should return false for previous chapters when 25251 is complete", function()
            Questie.db.char.complete[14126] = true
            Questie.db.char.complete[14303] = true
            Questie.db.char.complete[14240] = true
            Questie.db.char.complete[14242] = true
            Questie.db.char.complete[14244] = true
            Questie.db.char.complete[24868] = true
            Questie.db.char.complete[24925] = true
            Questie.db.char.complete[24929] = true
            Questie.db.char.complete[24958] = true
            Questie.db.char.complete[25125] = true
            Questie.db.char.complete[25251] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_1))
            assert.is_false(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_2))
            assert.is_false(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_3))
            assert.is_false(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_4))
            assert.is_false(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_5))
            assert.is_false(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_6))
            assert.is_false(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_7))
            assert.is_false(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_8))
            assert.is_false(Phasing.IsSpawnVisible(phases.LOST_ISLES_CHAPTER_9))
        end)
    end)

    describe("Gilneas", function()
        before_each(function()
            playerFaction = "Alliance"
            Phasing.Initialize()
        end)

        it("should return true for chapter 1 when quest 14078 is complete", function()
            Questie.db.char.complete[14078] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_1))
        end)

        it("should return false for chapter 1 when quest 14159 is complete", function()
            Questie.db.char.complete[14159] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_1))
        end)

        it("should return true for chapter 2 when quest 14159 is complete", function()
            Questie.db.char.complete[14159] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_2))
        end)

        it("should return false for chapter 2 when quest 14293 is complete", function()
            Questie.db.char.complete[14293] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_2))
        end)

        it("should return true for chapter 3 when quest 14293 is complete", function()
            Questie.db.char.complete[14293] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_3))
        end)

        it("should return false for chapter 3 when quest 14221 is complete", function()
            Questie.db.char.complete[14221] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_3))
        end)

        it("should return true for chapter 4 when quest 14221 is complete", function()
            Questie.db.char.complete[14221] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_4))
        end)

        it("should return false for chapter 4 when quest 14375 is complete", function()
            Questie.db.char.complete[14375] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_4))
        end)

        it("should return true for chapter 5 when quest 14375 is complete", function()
            Questie.db.char.complete[14375] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_5))
        end)

        it("should return false for chapter 5 when quest 14321 is complete", function()
            Questie.db.char.complete[14321] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_5))
        end)

        it("should return true for chapter 6 when quest 14321 is complete", function()
            Questie.db.char.complete[14321] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_6))
        end)

        it("should return false for chapter 6 when quest 14386 is complete", function()
            Questie.db.char.complete[14386] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_6))
        end)

        it("should return true for chapter 7 when quest 14386 is complete", function()
            Questie.db.char.complete[14386] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_7))
        end)

        it("should return false for chapter 7 when quest 14402, 14405 or 14463 is complete", function()
            Questie.db.char.complete[14402] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_7))

            Questie.db.char.complete[14402] = false
            Questie.db.char.complete[14405] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_7))

            Questie.db.char.complete[14402] = false
            Questie.db.char.complete[14405] = false
            Questie.db.char.complete[14463] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_7))
        end)

        it("should return true for chapter 8 when quest 14402, 14405 or 14463 is complete", function()
            Questie.db.char.complete[14402] = true
            assert.is_true(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_8))

            Questie.db.char.complete[14402] = false
            Questie.db.char.complete[14405] = true
            assert.is_true(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_8))

            Questie.db.char.complete[14402] = false
            Questie.db.char.complete[14405] = false
            Questie.db.char.complete[14463] = true
            assert.is_true(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_8))
        end)

        it("should return false for chapter 8 when quest 14467 is complete", function()
            Questie.db.char.complete[14467] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_8))
        end)

        it("should return true for chapter 9 when quest 14467 is complete", function()
            Questie.db.char.complete[14467] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_9))
        end)

        it("should return false for chapter 9 when quest 24676 is complete", function()
            Questie.db.char.complete[24676] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_9))
        end)

        it("should return true for chapter 10 when quest 24676 is complete", function()
            Questie.db.char.complete[24676] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_10))
        end)

        it("should return false for chapter 10 when quest 24902 is complete", function()
            Questie.db.char.complete[24902] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_10))
        end)

        it("should return true for chapter 11 when quest 24902 is complete", function()
            Questie.db.char.complete[24902] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_11))
        end)

        it("should return false for chapter 11 when quest 24679 is complete", function()
            Questie.db.char.complete[24679] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_11))
        end)

        it("should return true for chapter 12 when quest 24679 is complete", function()
            Questie.db.char.complete[24679] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.GILNEAS_CHAPTER_12))
        end)
    end)

    describe("Hyjal", function()
        it("should return true for Hyjal Chapter 1 and 2", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.HYJAL_CHAPTER_1))
            assert.is_true(Phasing.IsSpawnVisible(phases.HYJAL_CHAPTER_2))
        end)

        it("should return false for Hyjal Chapter 1 when 25372 is complete", function()
            Questie.db.char.complete[25372] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.HYJAL_CHAPTER_1))
        end)

        it("should return false for Hyjal Chapter 2 when 25272 is complete", function()
            Questie.db.char.complete[25272] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.HYJAL_CHAPTER_2))
            assert.is_true(Phasing.IsSpawnVisible(phases.HYJAL_IAN_AND_TARIK_NOT_IN_CAGE))
        end)

        it("should return false for Hyjal Chapter 2 when 25273 is complete", function()
            Questie.db.char.complete[25273] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.HYJAL_CHAPTER_2))
            assert.is_true(Phasing.IsSpawnVisible(phases.HYJAL_IAN_AND_TARIK_NOT_IN_CAGE))
        end)

        it("should handle Hyjal Hamuul Runetotem positioning when 25520 and 25502 are complete", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.HYJAL_HAMUUL_RUNETOTEM_AT_SANCTUARY))
            assert.is_false(Phasing.IsSpawnVisible(phases.HYJAL_HAMUUL_RUNETOTEM_AT_GROVE))

            Questie.db.char.complete[25520] = true
            assert.is_true(Phasing.IsSpawnVisible(phases.HYJAL_HAMUUL_RUNETOTEM_AT_SANCTUARY))
            assert.is_false(Phasing.IsSpawnVisible(phases.HYJAL_HAMUUL_RUNETOTEM_AT_GROVE))

            Questie.db.char.complete[25502] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.HYJAL_HAMUUL_RUNETOTEM_AT_SANCTUARY))
            assert.is_true(Phasing.IsSpawnVisible(phases.HYJAL_HAMUUL_RUNETOTEM_AT_GROVE))
        end)

        it("should handle Thisalee Crow positioning", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.HYJAL_THISALEE_AT_SHRINE))
            assert.is_false(Phasing.IsSpawnVisible(phases.HYJAL_THISALEE_AT_SETHRIAS_ROOST))

            QuestLogCache.questLog_DO_NOT_MODIFY = {[25740]={}}
            assert.is_false(Phasing.IsSpawnVisible(phases.HYJAL_THISALEE_AT_SHRINE))
            assert.is_true(Phasing.IsSpawnVisible(phases.HYJAL_THISALEE_AT_SETHRIAS_ROOST))

            QuestLogCache.questLog_DO_NOT_MODIFY = {}
            Questie.db.char.complete[25740] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.HYJAL_THISALEE_AT_SHRINE))
            assert.is_true(Phasing.IsSpawnVisible(phases.HYJAL_THISALEE_AT_SETHRIAS_ROOST))

            Questie.db.char.complete[25807] = true
            assert.is_true(Phasing.IsSpawnVisible(phases.HYJAL_THISALEE_AT_SHRINE))
            assert.is_false(Phasing.IsSpawnVisible(phases.HYJAL_THISALEE_AT_SETHRIAS_ROOST))
        end)

        it("should return true for Hyjal Daily when 25560 is active", function()
            QuestLogCache.questLog_DO_NOT_MODIFY = {[25560]={}}

            assert.is_true(Phasing.IsSpawnVisible(phases.HYJAL_DAILY))
        end)

        it("should return true for Hyjal Twilight chapter when 25274 is active", function()
            QuestLogCache.questLog_DO_NOT_MODIFY = {[25274]={}}

            assert.is_true(Phasing.IsSpawnVisible(phases.HYJAL_TWILIGHT_CHAPTER))
        end)

        it("should return true for Hyjal Twilight chapter when 25274 is complete", function()
            Questie.db.char.complete[25274] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.HYJAL_TWILIGHT_CHAPTER))
        end)

        it("should return false for Hyjal Twilight chapter when 25531 is complete", function()
            Questie.db.char.complete[25531] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.HYJAL_TWILIGHT_CHAPTER))
        end)

        it("should correctly position Commander Jarod Shadowsong", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.JAROD_NEAR_PORTAL))
            assert.is_false(Phasing.IsSpawnVisible(phases.JAROD_MIDDLE_ISLAND))

            Questie.db.char.complete[25608] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.JAROD_NEAR_PORTAL))
            assert.is_true(Phasing.IsSpawnVisible(phases.JAROD_MIDDLE_ISLAND))
        end)
    end)

    describe("Vash'jir", function()
        it("should return true for Legions Rest till 25958 or 25747 is accepted", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_LEGIONS_REST))
        end)

        it("should return true for Northern Garden when 25958 or 25747 is accepted or complete", function()
            QuestLogCache.questLog_DO_NOT_MODIFY = {[25958]={}}
            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_NORTHERN_GARDEN))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_LEGIONS_REST))

            QuestLogCache.questLog_DO_NOT_MODIFY = {[25747]={}}
            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_NORTHERN_GARDEN))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_LEGIONS_REST))

            QuestLogCache.questLog_DO_NOT_MODIFY = {}
            Questie.db.char.complete[25958] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_NORTHERN_GARDEN))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_LEGIONS_REST))

            Questie.db.char.complete[25958] = false
            Questie.db.char.complete[25747] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_NORTHERN_GARDEN))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_LEGIONS_REST))
        end)

        it("should return true for Legions Rest when 25966 is complete", function()
            Questie.db.char.complete[25958] = true
            Questie.db.char.complete[25959] = true
            Questie.db.char.complete[25960] = true
            Questie.db.char.complete[25962] = true
            Questie.db.char.complete[25966] = true
            Questie.db.char.complete[26191] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_LEGIONS_REST))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_NORTHERN_GARDEN))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_NAR_SHOLA_TERRACE))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_NAR_SHOLA_TERRACE_WEST))
        end)

        it("should return true for Legions Rest when 25755 is complete", function()
            Questie.db.char.complete[25747] = true
            Questie.db.char.complete[25748] = true
            Questie.db.char.complete[25749] = true
            Questie.db.char.complete[25751] = true
            Questie.db.char.complete[25755] = true
            Questie.db.char.complete[26191] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_LEGIONS_REST))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_NORTHERN_GARDEN))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_NAR_SHOLA_TERRACE))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_NAR_SHOLA_TERRACE_WEST))
        end)

        it("should return true for Nar'Shola Terrace and Northern Garden when 25959, 25960 and 25962 are complete", function()
            Questie.db.char.complete[25958] = true
            Questie.db.char.complete[25959] = true
            Questie.db.char.complete[25960] = true
            Questie.db.char.complete[25962] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_NAR_SHOLA_TERRACE))
            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_NORTHERN_GARDEN))
        end)

        it("should return true for Nar'Shola Terrace and Northern Garden when 25748, 25749 and 25751 are complete", function()
            Questie.db.char.complete[25747] = true
            Questie.db.char.complete[25748] = true
            Questie.db.char.complete[25749] = true
            Questie.db.char.complete[25751] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_NAR_SHOLA_TERRACE))
            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_NORTHERN_GARDEN))
        end)

        it("should return true for Nar'Shola Terrace West when 26191 is complete", function()
            Questie.db.char.complete[26191] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_NAR_SHOLA_TERRACE_WEST))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_NORTHERN_GARDEN))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_NAR_SHOLA_TERRACE))
        end)

        it("should return true for Lady Naz'jar at temple before 25629 and 25896 are complete", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_LADY_NAZ_JAR_AT_TEMPLE))
        end)

        it("should return true for Lady Naz'jar at bridge when 25629 and 25896 are complete", function()
            Questie.db.char.complete[25629] = true
            Questie.db.char.complete[25896] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_LADY_NAZ_JAR_AT_BRIDGE))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_LADY_NAZ_JAR_AT_TEMPLE))
        end)

        it("should return true for Erunak Stonespeaker at Cavern before 25988 is complete or after 26143 is complete", function()
            Questie.db.char.complete[25988] = false

            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_ERANUK_AT_CAVERN))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_ERANUK_AT_PROMONTORY_POINT))

            Questie.db.char.complete[26143] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_ERANUK_AT_CAVERN))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_ERANUK_AT_PROMONTORY_POINT))
        end)

        it("should return true for Erunak Stonespeaker at Promontory Point when 25988 is complete and 26143 is not", function()
            Questie.db.char.complete[25988] = true
            Questie.db.char.complete[26143] = false

            assert.is_true(Phasing.IsSpawnVisible(phases.VASHJIR_ERANUK_AT_PROMONTORY_POINT))
            assert.is_false(Phasing.IsSpawnVisible(phases.VASHJIR_ERANUK_AT_CAVERN))
        end)

        it("should return true for Sira'kess Tide Priestess at Garden when 25658 is not complete", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.SIRA_KESS_AT_GARDEN))
            assert.is_false(Phasing.IsSpawnVisible(phases.SIRA_KESS_AT_NAR_SHOLA_TERRACE))
        end)

        it("should return true for Sira'kess Tide Priestess at Northern Terrace when 25658 is complete", function()
            QuestLogCache.questLog_DO_NOT_MODIFY = {[25658]={}}

            assert.is_false(Phasing.IsSpawnVisible(phases.SIRA_KESS_AT_GARDEN))
            assert.is_true(Phasing.IsSpawnVisible(phases.SIRA_KESS_AT_NAR_SHOLA_TERRACE))

            QuestLogCache.questLog_DO_NOT_MODIFY = {}
            Questie.db.char.complete[25658] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.SIRA_KESS_AT_GARDEN))
            assert.is_true(Phasing.IsSpawnVisible(phases.SIRA_KESS_AT_NAR_SHOLA_TERRACE))
        end)

        it("should return true for Wavespeaker Tulra at Ruins when 25957 or 25760 is in the quest log and complete", function()
            QuestLogCache.questLog_DO_NOT_MODIFY = {}
            assert.is_false(Phasing.IsSpawnVisible(phases.WAVESPEAKER_AT_RUINS))

            QuestLogCache.questLog_DO_NOT_MODIFY = {[25957]={isComplete=0}}
            assert.is_false(Phasing.IsSpawnVisible(phases.WAVESPEAKER_AT_RUINS))

            QuestLogCache.questLog_DO_NOT_MODIFY = {[25957]={isComplete=1}}
            assert.is_true(Phasing.IsSpawnVisible(phases.WAVESPEAKER_AT_RUINS))

            QuestLogCache.questLog_DO_NOT_MODIFY = {[25760]={isComplete=0}}
            assert.is_false(Phasing.IsSpawnVisible(phases.WAVESPEAKER_AT_RUINS))

            QuestLogCache.questLog_DO_NOT_MODIFY = {[25760]={isComplete=1}}
            assert.is_true(Phasing.IsSpawnVisible(phases.WAVESPEAKER_AT_RUINS))
        end)
    end)

    describe("Deepholm", function()
        it("should return true for The Stone March when 26827 is complete", function()
            Questie.db.char.complete[26827] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.THE_STONE_MARCH))
        end)

        it("should return true for chapter 1 when The Stone March quests are complete", function()
            Questie.db.char.complete[26829] = true
            Questie.db.char.complete[26831] = true
            Questie.db.char.complete[26832] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.TEMPLE_OF_EARTH_CHAPTER_1))
            assert.is_false(Phasing.IsSpawnVisible(phases.THE_STONE_MARCH))
        end)

        it("should return true for chapter 2 when 26875 is complete", function()
            Questie.db.char.complete[26875] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.TEMPLE_OF_EARTH_CHAPTER_2))
            assert.is_false(Phasing.IsSpawnVisible(phases.THE_STONE_MARCH))
        end)

        it("should return true for chapter 3 when 26971 is complete", function()
            Questie.db.char.complete[26971] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.TEMPLE_OF_EARTH_CHAPTER_3))
            assert.is_false(Phasing.IsSpawnVisible(phases.THE_STONE_MARCH))
            assert.is_false(Phasing.IsSpawnVisible(phases.TEMPLE_OF_EARTH_CHAPTER_1))
            assert.is_false(Phasing.IsSpawnVisible(phases.TEMPLE_OF_EARTH_CHAPTER_2))
        end)

        it("should return false for chapter 3 when 26709 is complete", function()
            Questie.db.char.complete[26709] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.TEMPLE_OF_EARTH_CHAPTER_3))
            assert.is_false(Phasing.IsSpawnVisible(phases.THE_STONE_MARCH))
            assert.is_false(Phasing.IsSpawnVisible(phases.TEMPLE_OF_EARTH_CHAPTER_1))
            assert.is_false(Phasing.IsSpawnVisible(phases.TEMPLE_OF_EARTH_CHAPTER_2))
        end)

        it("should show the NPCs at Therazane's Throne after quests 26584 26585 26659 are completed", function()
            Questie.db.char.complete[26584] = true
            Questie.db.char.complete[26585] = true
            Questie.db.char.complete[26659] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.NPCS_AT_THERAZANES_THRONE))

        end)
    end)

    describe("Teldrassil", function()
        it("should handle Corithras Moonrage positioning", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.CORITHRAS_AT_DOLANAAR))
            assert.is_false(Phasing.IsSpawnVisible(phases.CORITHRAS_AT_CROSSROAD))

            QuestLogCache.questLog_DO_NOT_MODIFY = {[7383]={}}
            assert.is_false(Phasing.IsSpawnVisible(phases.CORITHRAS_AT_DOLANAAR))
            assert.is_true(Phasing.IsSpawnVisible(phases.CORITHRAS_AT_CROSSROAD))

            QuestLogCache.questLog_DO_NOT_MODIFY = {}
            Questie.db.char.complete[7383] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.CORITHRAS_AT_DOLANAAR))
            assert.is_true(Phasing.IsSpawnVisible(phases.CORITHRAS_AT_CROSSROAD))
        end)

        it("should handle Ilthalaine positioning", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.ILTHALAINE_AT_BENCH))
            assert.is_false(Phasing.IsSpawnVisible(phases.ILTHALAINE_AT_ROAD))

            QuestLogCache.questLog_DO_NOT_MODIFY = {[28715]={}}
            assert.is_false(Phasing.IsSpawnVisible(phases.ILTHALAINE_AT_BENCH))
            assert.is_true(Phasing.IsSpawnVisible(phases.ILTHALAINE_AT_ROAD))

            QuestLogCache.questLog_DO_NOT_MODIFY = {}
            Questie.db.char.complete[28715] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.ILTHALAINE_AT_BENCH))
            assert.is_true(Phasing.IsSpawnVisible(phases.ILTHALAINE_AT_ROAD))
        end)
    end)

    describe("Darkshore", function()
        it("should handle Cerellean Whiteclaw positioning", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.CERELLEAN_NEAR_EDGE))
            assert.is_false(Phasing.IsSpawnVisible(phases.CERELLEAN_NEAR_TREE))

            QuestLogCache.questLog_DO_NOT_MODIFY = {}
            Questie.db.char.complete[13515] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.CERELLEAN_NEAR_EDGE))
            assert.is_true(Phasing.IsSpawnVisible(phases.CERELLEAN_NEAR_TREE))
        end)
    end)

    describe("Azshara", function()
        it("should handle Ag'tor Bloodfist and Labor Captain Grabbit positioning", function()
            Questie.db.char.complete[14135] = false

            assert.is_true(Phasing.IsSpawnVisible(phases.AGTOR_GRABBIT_OUTSIDE_ATTACK))
            assert.is_false(Phasing.IsSpawnVisible(phases.AGTOR_GRABBIT_DURING_ATTACK))

            Questie.db.char.complete[14135] = true
            QuestLogCache.questLog_DO_NOT_MODIFY = {[14155]={isComplete=0}}

            assert.is_true(Phasing.IsSpawnVisible(phases.AGTOR_GRABBIT_DURING_ATTACK))
            assert.is_false(Phasing.IsSpawnVisible(phases.AGTOR_GRABBIT_OUTSIDE_ATTACK))

            QuestLogCache.questLog_DO_NOT_MODIFY = {[14155]={isComplete=1}}

            assert.is_true(Phasing.IsSpawnVisible(phases.AGTOR_GRABBIT_OUTSIDE_ATTACK))
            assert.is_false(Phasing.IsSpawnVisible(phases.AGTOR_GRABBIT_DURING_ATTACK))

            QuestLogCache.questLog_DO_NOT_MODIFY = {}
            Questie.db.char.complete[14155] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.AGTOR_GRABBIT_OUTSIDE_ATTACK))
            assert.is_false(Phasing.IsSpawnVisible(phases.AGTOR_GRABBIT_DURING_ATTACK))
        end)

        it("should handle Commander Molotov positioning", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.MOLOTOV_AT_RUINS))
            assert.is_false(Phasing.IsSpawnVisible(phases.MOLOTOV_AT_HARBOR))

            QuestLogCache.questLog_DO_NOT_MODIFY = {}
            Questie.db.char.complete[24453] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.MOLOTOV_AT_RUINS))
            assert.is_true(Phasing.IsSpawnVisible(phases.MOLOTOV_AT_HARBOR))
        end)

        it("should handle Sorata Firespinner positioning", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.SORATA_AT_EXCHANGE))
            assert.is_false(Phasing.IsSpawnVisible(phases.SORATA_AT_HARBOR))

            QuestLogCache.questLog_DO_NOT_MODIFY = {}
            Questie.db.char.complete[14340] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.SORATA_AT_EXCHANGE))
            assert.is_true(Phasing.IsSpawnVisible(phases.SORATA_AT_HARBOR))
        end)
    end)

    describe("Eastern Plague Lands", function()
        it("should handle The Scarlet Enclave positioning", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.SCARLET_ENCLAVE_ENTRACE))
            assert.is_false(Phasing.IsSpawnVisible(phases.SCARLET_ENCLAVE))

            Questie.db.char.complete[27460] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.SCARLET_ENCLAVE_ENTRACE))
            assert.is_true(Phasing.IsSpawnVisible(phases.SCARLET_ENCLAVE))
        end)
    end)

    describe("Zul Drak", function()
        it("should correctly position Har'koa", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.HAR_KOA_AT_ALTAR))
            assert.is_false(Phasing.IsSpawnVisible(phases.HAR_KOA_AT_ZIM_TORGA))

            Questie.db.char.complete[12684] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.HAR_KOA_AT_ALTAR))
            assert.is_true(Phasing.IsSpawnVisible(phases.HAR_KOA_AT_ZIM_TORGA))
        end)
    end)

    describe("Ashenvale", function()
        it("should correctly position Earthen Ring Guide for the holiday event", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.EARTHEN_GUIDE_BFD))
            assert.is_false(Phasing.IsSpawnVisible(phases.EARTHEN_GUIDE_SHORE))

            QuestLogCache.questLog_DO_NOT_MODIFY = {[11891]={}}
            assert.is_false(Phasing.IsSpawnVisible(phases.EARTHEN_GUIDE_BFD))
            assert.is_true(Phasing.IsSpawnVisible(phases.EARTHEN_GUIDE_SHORE))

            QuestLogCache.questLog_DO_NOT_MODIFY = {}
            Questie.db.char.complete[11891] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.EARTHEN_GUIDE_BFD))
            assert.is_true(Phasing.IsSpawnVisible(phases.EARTHEN_GUIDE_SHORE))
        end)
    end)

    describe("Stormwind City", function()
        it("should correctly position Fargo Flintlocke during the Twilight Highlands quest chain", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.FARGO_AT_CATAPULTS))
            assert.is_false(Phasing.IsSpawnVisible(phases.FARGO_AT_DOCKS))

            Questie.db.char.complete[27106] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.FARGO_AT_CATAPULTS))
            assert.is_true(Phasing.IsSpawnVisible(phases.FARGO_AT_DOCKS))
        end)
    end)

    describe("Twilight Highlands", function()
        it("should return true for chapter 1 Dragonmaw Port", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.DRAGONMAW_PORT_CHAPTER_1))
        end)

        it("should return true for chapter 2 when 26608 is complete Dragonmaw Port", function()
            Questie.db.char.complete[26608] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.DRAGONMAW_PORT_CHAPTER_2))
            assert.is_false(Phasing.IsSpawnVisible(phases.DRAGONMAW_PORT_CHAPTER_1))
        end)

        it("should return true for chapter 3 when 26622 is complete Dragonmaw Port", function()
            Questie.db.char.complete[26622] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.DRAGONMAW_PORT_CHAPTER_3))
            assert.is_false(Phasing.IsSpawnVisible(phases.DRAGONMAW_PORT_CHAPTER_2))
        end)

        it("should return false for chapter 3 when 26830 is complete Dragonmaw Port", function()
            Questie.db.char.complete[26830] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.DRAGONMAW_PORT_CHAPTER_3))
        end)

        it("should return true for Isorath Nightmare when 27303 is complete", function()
            Questie.db.char.complete[27303] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.ISORATH_NIGHTMARE))
        end)

        it("should return false for Isorath Nightmare when 27303 is not complete", function()
            assert.is_false(Phasing.IsSpawnVisible(phases.ISORATH_NIGHTMARE))
        end)

        it("should return true for Twilight Gate Pre Invasion when 28249 is complete", function()
            Questie.db.char.complete[28249] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.TWILIGHT_GATE_PRE_INVASION))
        end)

        it("should return false for Twilight Gate when 28249 is not complete", function()
            assert.is_false(Phasing.IsSpawnVisible(phases.TWILIGHT_GATE_PRE_INVASION))
        end)

        it("should return false for Twilight Gate when 27301 is complete", function()
            Questie.db.char.complete[27301] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.TWILIGHT_GATE_PRE_INVASION))
        end)

        it("should return true for Twilight Gate when 27301 is complete", function()
            Questie.db.char.complete[27301] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.TWILIGHT_GATE))
        end)

        it("should return false for Twilight Gate when 27301 is not complete", function()
            assert.is_false(Phasing.IsSpawnVisible(phases.TWILIGHT_GATE))
        end)

        it("should return true for Twilight Ambush Horde & Alliance when 27509 is complete", function()
            Questie.db.char.complete[27509] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.TWILIGHT_CARAVAN_AMBUSH_HORDE))
            assert.is_true(Phasing.IsSpawnVisible(phases.TWILIGHT_CARAVAN_AMBUSH_ALLIANCE))
        end)

        it("should return false for Twilight Ambush Horde & Alliance when 27509 is not complete", function()
            assert.is_false(Phasing.IsSpawnVisible(phases.TWILIGHT_CARAVAN_AMBUSH_HORDE))
            assert.is_false(Phasing.IsSpawnVisible(phases.TWILIGHT_CARAVAN_AMBUSH_ALLIANCE))
        end)

        it("should return false for Twilight Ambush Horde when 27576 is complete", function()
            Questie.db.char.complete[27576] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.TWILIGHT_CARAVAN_AMBUSH_HORDE))
        end)

        it("should return false for Twilight Ambush Alliance when 28101 is complete", function()
            Questie.db.char.complete[28101] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.TWILIGHT_CARAVAN_AMBUSH_ALLIANCE))
        end)

        it("should return true for Grim Batol Attack Horde when any objective of 28090 or 28091 is complete or one of the quests", function()
            Questie.db.char.complete[28090] = false
            Questie.db.char.complete[28091] = false
            assert.is_false(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_HORDE))

            Questie.db.char.complete[28090] = true
            Questie.db.char.complete[28091] = false
            assert.is_true(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_HORDE))

            Questie.db.char.complete[28090] = false
            Questie.db.char.complete[28091] = true
            assert.is_true(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_HORDE))

            Questie.db.char.complete[28090] = true
            Questie.db.char.complete[28091] = true
            assert.is_true(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_HORDE))

            Questie.db.char.complete[28090] = false
            Questie.db.char.complete[28091] = false
            QuestLogCache.questLog_DO_NOT_MODIFY = {[28090]={isComplete=0}}
            QuestLogCache.questLog_DO_NOT_MODIFY = {[28091]={isComplete=0}}
            assert.is_false(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_HORDE))

            QuestLogCache.questLog_DO_NOT_MODIFY = {[28090]={isComplete=1}}
            assert.is_true(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_HORDE))

            QuestLogCache.questLog_DO_NOT_MODIFY = {[28091]={isComplete=1}}
            assert.is_true(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_HORDE))
        end)

        it("should return true for Grim Batol Attack Alliance when any objective of 28103 or 28104 is complete or one of the quests", function()
            Questie.db.char.complete[28103] = false
            Questie.db.char.complete[28104] = false
            assert.is_false(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_ALLIANCE))

            Questie.db.char.complete[28103] = true
            Questie.db.char.complete[28104] = false
            assert.is_true(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_ALLIANCE))

            Questie.db.char.complete[28103] = false
            Questie.db.char.complete[28104] = true
            assert.is_true(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_ALLIANCE))

            Questie.db.char.complete[28103] = true
            Questie.db.char.complete[28104] = true
            assert.is_true(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_ALLIANCE))

            Questie.db.char.complete[28103] = false
            Questie.db.char.complete[28104] = false
            QuestLogCache.questLog_DO_NOT_MODIFY = {[28103]={isComplete=0}}
            QuestLogCache.questLog_DO_NOT_MODIFY = {[28104]={isComplete=0}}
            assert.is_false(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_ALLIANCE))

            QuestLogCache.questLog_DO_NOT_MODIFY = {[28103]={isComplete=1}}
            assert.is_true(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_ALLIANCE))

            QuestLogCache.questLog_DO_NOT_MODIFY = {[28104]={isComplete=1}}
            assert.is_true(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_ALLIANCE))
        end)

        it("should correctly position Thordun Hammerblow", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.THORDUN_AT_TREE))
            assert.is_false(Phasing.IsSpawnVisible(phases.THORDUN_IN_KEEP))

            Questie.db.char.complete[27516] = true
            assert.is_false(Phasing.IsSpawnVisible(phases.THORDUN_AT_TREE))
            assert.is_true(Phasing.IsSpawnVisible(phases.THORDUN_IN_KEEP))
        end)
    end)
end)
