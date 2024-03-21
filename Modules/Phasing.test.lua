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

    describe("IsSpawnVisible", function()
        it("should return true for KEZAN_CHAPTER_1", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_1))
        end)

        it("should return false for KEZAN_CHAPTER_1 when quest 14125 is complete", function()
            Questie.db.char.complete[14125] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_1))
        end)

        it("should return false for KEZAN_CHAPTER_1 when quest 14126 is complete", function()
            Questie.db.char.complete[14126] = true

            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_1))
        end)

        it("should return true for KEZAN_CHAPTER_6 when quest 14125 is complete", function()
            Questie.db.char.complete[14125] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_6))
        end)

        it("should return true for KEZAN_CHAPTER_7 when quest 14126 is complete", function()
            Questie.db.char.complete[14126] = true

            assert.is_true(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_7))
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
end)
