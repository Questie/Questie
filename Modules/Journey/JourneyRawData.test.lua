dofile("setupTests.lua")

describe("JourneyRawData", function()
    ---@type JourneyRawData
    local JourneyRawData
    local originalQuestie

    before_each(function()
        originalQuestie = _G.Questie
        _G.Questie = {db = {profile = {debugEnabled = true}}, Colorize = function(_, text) return text end}
        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Modules/Journey/JourneyRawData.lua")
        JourneyRawData = QuestieLoader:ImportModule("JourneyRawData")
    end)

    after_each(function()
        _G.Questie = originalQuestie
    end)

    ---@return string
    local function GetText(data, keys)
        local rows, texts = {}, {}
        JourneyRawData.AddRows(rows, data, keys)
        for _, row in ipairs(rows) do
            table.insert(texts, row.text)
        end
        return table.concat(texts, "\n")
    end

    it("should only be shown while debugging", function()
        Questie.db.profile.debugEnabled = false

        assert.are.equal("", GetText({name = "Young Wolf"}, {name = 1}))
    end)

    it("should show nested tables, missing values and values that aren't text", function()
        local text = GetText({name = "Young Wolf", isElite = false, spawns = {[12] = {{48.9, 41.6}}}}, {
            name = 1, isElite = 2, spawns = 3, rank = 4,
        })

        assert.is_not_nil(text:find("name: Young Wolf", 1, true))
        assert.is_not_nil(text:find("isElite: false", 1, true))
        assert.is_not_nil(text:find("rank: nil", 1, true))
        assert.is_not_nil(text:find("spawns: {\n    [12]={\n        [1]={\n            [1]=48.9\n            [2]=41.6\n        }\n    }\n}", 1, true))
    end)

    it("should only show the fields that were asked for", function()
        assert.is_nil(GetText({name = "Young Wolf", secret = "hidden"}, {name = 1}):find("hidden", 1, true))
    end)
end)
