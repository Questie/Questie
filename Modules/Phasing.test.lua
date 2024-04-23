dofile("Modules/Libs/QuestieLoader.lua")

---@type Phasing
local Phasing = require("Modules.Phasing")

local phases = Phasing.phases

describe("Phasing", function()
    before_each(function()
        -- Accessing _G["Questie"] is required
        _G["Questie"] = {db = {char = {complete = {}}}}
        Questie = _G["Questie"]
    end)

    it("should return true for phase nil", function()
        assert.is_true(Phasing.IsSpawnVisible(nil))
    end)

    it("should return true for UNKNOWN", function()
        assert.is_true(Phasing.IsSpawnVisible(phases.UNKNOWN))
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

    describe("Twilight Highlands", function()
        it("should return true for chapter 1", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.TWILIGHT_HIGHLANDS_CHAPTER_1))
        end)

        it("should return false for chapter 1 when 26608 is complete", function()
            Questie.db.char.complete[26608] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.TWILIGHT_HIGHLANDS_CHAPTER_1))
        end)

        it("should return true for chapter 2 when 26608 is complete", function()
            Questie.db.char.complete[26608] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.TWILIGHT_HIGHLANDS_CHAPTER_2))
        end)

        it("should return false for chapter 2 when 26622 is complete", function()
            Questie.db.char.complete[26622] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.TWILIGHT_HIGHLANDS_CHAPTER_2))
        end)

        it("should return true for chapter 3 when 26622 is complete", function()
            Questie.db.char.complete[26622] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.TWILIGHT_HIGHLANDS_CHAPTER_3))
        end)

        it("should return false for chapter 3 when 26830 is complete", function()
            Questie.db.char.complete[26622] = true
            Questie.db.char.complete[26830] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.TWILIGHT_HIGHLANDS_CHAPTER_3))
        end)
    end)
end)
