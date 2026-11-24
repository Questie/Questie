dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyLinks", function()
    ---@type JourneyLinks
    local JourneyLinks
    local ui
    local originalQuestie, originalIsModifiedClick, originalGetActiveWindow, originalInsertLink
    local opened, insertedLinks

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie, originalIsModifiedClick = _G.Questie, _G.IsModifiedClick
        originalGetActiveWindow, originalInsertLink = _G.ChatEdit_GetActiveWindow, _G.ChatEdit_InsertLink
        _G.Questie = {db = {profile = {}}}
        opened, insertedLinks = {}, {}
        _G.ChatEdit_InsertLink = function(link) table.insert(insertedLinks, link) end

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QuestPointers = {[7] = true, [8] = true}
        QuestieDB.GetQuest = function(id)
            return {level = 5, name = "Wolves", Id = id, Description = {"Kill ten wolves."}}
        end
        QuestieDB.QueryNPCSingle = function(id, field)
            return id == 299 and ({name = "Young Wolf", maxLevel = 2})[field] or nil
        end
        QuestieDB.GetNPC = function() return {name = "Young Wolf", minLevel = 1, subName = "The Hungry"} end
        QuestieDB.QueryObjectSingle = function(id) return id == 55 and "Half-eaten body" or nil end
        QuestieDB.QueryItemSingle = function(id) return id == 725 and "Gnoll Paw" or nil end
        QuestieLoader:ImportModule("QuestieLib").GetColoredQuestName = function(_, id, showLevel, showState)
            return (showLevel and "[5] " or "") .. "Quest " .. id .. (showState and "" or " without its state")
        end
        QuestieLoader:ImportModule("QuestieLink").GetQuestLinkStringById = function(id) return "link to " .. id end
        QuestieLoader:ImportModule("WrappedText").TextWrap = function(_, line) return {line} end
        QuestieLoader:ImportModule("JourneyWindow").OpenLink = function(kind, id) table.insert(opened, {kind, id}) end

        dofile("Modules/Journey/QuestieSearch.lua")
        dofile("Modules/Journey/JourneyLinks.lua")
        JourneyLinks = QuestieLoader:ImportModule("JourneyLinks")
    end)

    after_each(function()
        _G.Questie, _G.IsModifiedClick = originalQuestie, originalIsModifiedClick
        _G.ChatEdit_GetActiveWindow, _G.ChatEdit_InsertLink = originalGetActiveWindow, originalInsertLink
        ui.Restore()
    end)

    ---@param kind JourneyKind
    ---@param id number
    ---@return string[] lines Of the tooltip of its link
    local function TooltipLines(kind, id)
        JourneyLinks.GetRows(kind, {id})[1].showTooltip()
        return GameTooltip.lines
    end

    for _, case in ipairs({
        {kind = "quest", id = 7, text = "[5] Quest 7"},
        {kind = "npc", id = 299, text = "[2] Young Wolf (299)"},
        {kind = "object", id = 55, text = "Half-eaten body (55)"},
        {kind = "item", id = 725, text = "Gnoll Paw (725)"},
    }) do
        it("should name and open the " .. case.kind .. " it leads to", function()
            local rows = JourneyLinks.GetRows(case.kind, {case.id})

            assert.are.equal(1, #rows)
            assert.are_same({"link", case.text}, {rows[1].type, rows[1].text})
            rows[1].onClick()
            assert.are_same({{case.kind, case.id}}, opened)
        end)

        it("should leave out a " .. case.kind .. " that isn't in the database", function()
            assert.are_same({}, JourneyLinks.GetRows(case.kind, {404}))
        end)
    end

    it("should understand negative IDs, which are used for some prerequisites", function()
        local rows = JourneyLinks.GetRows("quest", {-7, 8})

        assert.are_same({"[5] Quest 7", "[5] Quest 8"}, {rows[1].text, rows[2].text})
        rows[1].onClick()
        assert.are_same({{"quest", 7}}, opened)
    end)

    it("should leave out the quest that is shown already", function()
        local rows = JourneyLinks.GetRows("quest", {7, 8}, 7)

        assert.are.equal(1, #rows)
        assert.are.equal("[5] Quest 8", rows[1].text)
    end)

    it("should describe what it leads to in its tooltip", function()
        assert.are_same({"[5] Wolves (7)", "Kill ten wolves.", "\nClick to show"}, TooltipLines("quest", 7))
        GameTooltip.lines = nil
        assert.are_same({"[1] Young Wolf (299)", "    The Hungry", "\nClick to show"}, TooltipLines("npc", 299))
        GameTooltip.lines = nil
        assert.are_same({"Gnoll Paw (725)", "\nClick to show"}, TooltipLines("item", 725))
        GameTooltip.lines = nil
        assert.are_same({"Half-eaten body (55)", "\nClick to show"}, TooltipLines("object", 55))
    end)

    it("should understand NPCs and quests that lack some of their data", function()
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QueryNPCSingle = function(_, field) return field == "name" and "Young Wolf" or nil end
        QuestieDB.GetNPC = function() return {name = "Young Wolf", minLevel = 0} end
        QuestieDB.GetQuest = function(id) return {level = 5, name = "Wolves", Id = id} end

        assert.are.equal("[0] Young Wolf (299)", JourneyLinks.GetRows("npc", {299})[1].text)
        assert.are_same({"[0] Young Wolf (299)", "\nClick to show"}, TooltipLines("npc", 299))
        GameTooltip.lines = nil
        assert.are_same({"[5] Wolves (7)", "\nClick to show"}, TooltipLines("quest", 7))
    end)

    it("should be able to make any row lead somewhere", function()
        local row = JourneyLinks.Link({type = "entity", text = "NPC ID: 299"}, "npc", 299)

        row.onClick()
        row.showTooltip()

        assert.are_same({{"npc", 299}}, opened)
        assert.are.equal("[1] Young Wolf (299)", GameTooltip.lines[1])
        assert.are.equal("NPC ID: 299", row.text)
    end)

    describe("TryInsertIntoChat", function()
        ---@param isModified boolean
        ---@param isTyping boolean
        local function Click(isModified, isTyping)
            _G.IsModifiedClick = function(action) return action == "CHATLINK" and isModified end
            _G.ChatEdit_GetActiveWindow = function() return isTyping and {} or nil end
            JourneyLinks.TryInsertIntoChat(7)
        end

        it("should insert a link while the user is typing in the chat", function()
            Click(true, true)

            assert.are_same({"link to 7"}, insertedLinks)
        end)

        it("should do nothing otherwise", function()
            Click(true, false)
            Click(false, true)

            assert.are_same({}, insertedLinks)
        end)
    end)
end)
