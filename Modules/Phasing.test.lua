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

        it("should return false for Hyjal Chapter 1 when 25520 is complete", function()
            Questie.db.char.complete[25520] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.HYJAL_CHAPTER_1))
        end)

        it("should return false for Hyjal Chapter 2 when 25272 is complete", function()
            Questie.db.char.complete[25272] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.HYJAL_CHAPTER_2))
        end)

        it("should return false for Hyjal Chapter 2 when 25273 is complete", function()
            Questie.db.char.complete[25273] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.HYJAL_CHAPTER_2))
        end)

        it("should return true for Hyjal Daily when 25560 is active", function()
            QuestLogCache.questLog_DO_NOT_MODIFY = {[25560]={}}

            assert.is_true(Phasing.IsSpawnVisible(phases.HYJAL_DAILY))
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
    end)

    describe("Dragonmaw Port", function()
        it("should return true for chapter 1", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.DRAGONMAW_PORT_CHAPTER_1))
        end)

        it("should return true for chapter 2 when 26608 is complete", function()
            Questie.db.char.complete[26608] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.DRAGONMAW_PORT_CHAPTER_2))
            assert.is_false(Phasing.IsSpawnVisible(phases.DRAGONMAW_PORT_CHAPTER_1))
        end)

        it("should return true for chapter 3 when 26622 is complete", function()
            Questie.db.char.complete[26622] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.DRAGONMAW_PORT_CHAPTER_3))
            assert.is_false(Phasing.IsSpawnVisible(phases.DRAGONMAW_PORT_CHAPTER_2))
        end)

        it("should return false for chapter 3 when 26830 is complete", function()
            Questie.db.char.complete[26830] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.DRAGONMAW_PORT_CHAPTER_3))
        end)
    end)

    describe("Isorath Nightmare", function()
        it("should return true for Isorath Nightmare when 27303 is complete", function()
            Questie.db.char.complete[27303] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.ISORATH_NIGHTMARE))
        end)

        it("should return false for Isorath Nightmare when 27303 is not complete", function()
            assert.is_false(Phasing.IsSpawnVisible(phases.ISORATH_NIGHTMARE))
        end)
    end)

    describe("Grim Batol attack", function()
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

        it("should return true for Grim Batol Attack Horde when 28090 and 28091 are complete", function()
            Questie.db.char.complete[28090] = true
            Questie.db.char.complete[28091] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_HORDE))
        end)

        it("should return true for Grim Batol Attack Alliance when 28103 and 28104 are complete", function()
            Questie.db.char.complete[28103] = true
            Questie.db.char.complete[28104] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.GRIM_BATOL_ATTACK_ALLIANCE))
        end)
    end)
end)
