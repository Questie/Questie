dofile("setupTests.lua")

describe("QuestieConditionText", function()
    ---@type QuestieConditionText
    local QuestieConditionText
    local originalColorize, originalSpell

    local function leaf(call, result, ...)
        return {call = call, args = {...}, result = result}
    end

    before_each(function()
        dofile("Localization/l10n.lua")
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QueryQuestSingle = function(questId) return "Quest " .. questId end
        QuestieDB.QueryItemSingle = function(itemId) return "Item " .. itemId end
        originalSpell = _G.C_Spell
        _G.C_Spell = {GetSpellName = function(spellId) return "Spell " .. spellId end}
        originalColorize = Questie.Colorize
        Questie.Colorize = function(_, text, color) return "<" .. color .. ">" .. text end
        QuestieConditionText = dofile("Modules/Quest/Conditions/QuestieConditionText.lua")
    end)

    after_each(function()
        Questie.Colorize = originalColorize
        _G.C_Spell = originalSpell
        _G.FACTION_STANDING_LABEL1, _G.FACTION_STANDING_LABEL6 = nil, nil
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
                "        <yellow>Has aura: Spell 5 (5)",
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

        it("names reputation ranks by the client's labels and shows item counts above one", function()
            -- Condition rank 0 is the client's label 1, Hated; rank 5 is label 6, Honored.
            _G.FACTION_STANDING_LABEL1, _G.FACTION_STANDING_LABEL6 = "Hated", "Honored"
            QuestieLoader:ImportModule("QuestieReputation").GetFactionName = function(factionId) return "Faction " .. factionId end
            local tree = {op = "and", result = true, children = {
                leaf("HasRep", true, 1105, 5), leaf("RepBelow", true, 1105, 0),
                leaf("HasItem", true, 3, 2), leaf("HasItemOrBank", true, 4, 1),
            }}

            assert.are_same(table.concat({
                "<green>All of: ",
                "    <green>Reputation at least Honored: Faction 1105",
                "    <green>Reputation at most Hated: Faction 1105",
                "    <green>Has item: Item 3 (3) x2",
                "    <green>Has item, bank included: Item 4 (4)",
            }, "\n"), QuestieConditionText.RenderTree(tree))
        end)
    end)
end)
