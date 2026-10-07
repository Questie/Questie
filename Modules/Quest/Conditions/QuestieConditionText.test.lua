dofile("setupTests.lua")

describe("QuestieConditionText", function()
    ---@type QuestieConditionText
    local QuestieConditionText
    local originalColorize

    local function leaf(call, result, ...)
        return {call = call, args = {...}, result = result}
    end

    before_each(function()
        dofile("Localization/l10n.lua")
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QueryQuestSingle = function(questId) return "Quest " .. questId end
        originalColorize = Questie.Colorize
        Questie.Colorize = function(_, text, color) return "<" .. color .. ">" .. text end
        QuestieConditionText = dofile("Modules/Quest/Conditions/QuestieConditionText.lua")
    end)

    after_each(function()
        Questie.Colorize = originalColorize
    end)

    describe("BlockingParts", function()
        it("names the false operands of a false and", function()
            local tree = {op = "and", result = false, children = {
                leaf("QuestRewarded", true, 1), leaf("QuestRewarded", false, 2), leaf("QuestInLog", false, 3),
            }}

            assert.are_same({"Turned in: Quest 2 (2)", "In quest log: Quest 3 (3)"}, QuestieConditionText.BlockingParts(tree))
        end)

        it("names every operand of a false or", function()
            local tree = {op = "or", result = false, children = {leaf("QuestRewarded", false, 1), leaf("QuestInLog", false, 2)}}

            assert.are_same({"Turned in: Quest 1 (1)", "In quest log: Quest 2 (2)"}, QuestieConditionText.BlockingParts(tree))
        end)

        it("names the holding parts under a false not, applying De Morgan to compounds", function()
            -- not (A and B) fails only because both hold; not (A or B) fails because of the one that holds.
            local notAll = {op = "not", result = false, children = {
                {op = "and", result = true, children = {leaf("QuestRewarded", true, 1), leaf("QuestInLog", true, 2)}},
            }}
            local notAny = {op = "not", result = false, children = {
                {op = "or", result = true, children = {leaf("QuestRewarded", false, 1), leaf("QuestInLog", true, 2)}},
            }}

            assert.are_same({"Not: Turned in: Quest 1 (1)", "Not: In quest log: Quest 2 (2)"}, QuestieConditionText.BlockingParts(notAll))
            assert.are_same({"Not: In quest log: Quest 2 (2)"}, QuestieConditionText.BlockingParts(notAny))
        end)

        it("names nothing for a condition that holds or is unknown", function()
            assert.are_same({}, QuestieConditionText.BlockingParts(leaf("QuestRewarded", true, 1)))
            assert.are_same({}, QuestieConditionText.BlockingParts({op = "and", result = nil, children = {
                leaf("HasAura", nil, 5), leaf("QuestRewarded", true, 1),
            }}))
        end)
    end)

    describe("RenderTree", function()
        it("indents operands and colors each part by its result", function()
            local tree = {op = "and", result = false, children = {
                leaf("IsTeam", true, "Alliance"),
                {op = "not", result = false, children = {leaf("QuestRewarded", true, 1518)}},
                {op = "or", result = nil, children = {leaf("HasAura", nil, 5), leaf("NewFunction", false, 7, 8)}},
            }}

            assert.are_same(table.concat({
                "<red>All of: ",
                "    <green>Faction: Alliance",
                "    <red>Not: Turned in: Quest 1518 (1518)",
                "    <yellow>Any of: ",
                "        <yellow>HasAura(5)",
                "        <red>NewFunction(7, 8)",
            }, "\n"), QuestieConditionText.RenderTree(tree))
        end)

        it("shows a negated group through De Morgan's laws", function()
            -- not (A and B) is any of "Not: A", "Not: B"; a double negation cancels out.
            local tree = {op = "not", result = true, children = {
                {op = "and", result = false, children = {
                    leaf("QuestRewarded", true, 1),
                    {op = "not", result = false, children = {leaf("QuestInLog", true, 2)}},
                }},
            }}

            assert.are_same(table.concat({
                "<green>Any of: ",
                "    <red>Not: Turned in: Quest 1 (1)",
                "    <green>In quest log: Quest 2 (2)",
            }, "\n"), QuestieConditionText.RenderTree(tree))
        end)
    end)
end)
