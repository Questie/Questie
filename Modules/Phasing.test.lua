dofile("Modules/Libs/QuestieLoader.lua")

---@type Phasing
local Phasing = require("Modules.Phasing")

local phases = Phasing.phases

describe("Phasing", function()
    describe("IsSpawnVisible", function()
        it("should return true for KEZAN_CHAPTER_1", function()
            assert.is_true(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_1))
        end)

        it("should return false for other chapter", function()
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_2))
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_3))
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_4))
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_5))
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_6))
            assert.is_false(Phasing.IsSpawnVisible(phases.KEZAN_CHAPTER_7))
        end)
    end)
end)
