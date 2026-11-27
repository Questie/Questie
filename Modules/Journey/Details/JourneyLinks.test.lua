dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyLinks", function()
    ---@type JourneyLinks
    local JourneyLinks
    local ui
    local originalQuestie, originalIsModifiedClick, originalGetActiveWindow, originalInsertLink
    local opened, insertedLinks
    local QuestieDB, JourneyQuestCategories

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie, originalIsModifiedClick = _G.Questie, _G.IsModifiedClick
        originalGetActiveWindow, originalInsertLink = _G.ChatEdit_GetActiveWindow, _G.ChatEdit_InsertLink
        _G.Questie = {db = {profile = {}}}
        opened, insertedLinks = {}, {}
        _G.ChatEdit_InsertLink = function(link) table.insert(insertedLinks, link) end

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QuestPointers = {[7] = true, [8] = true}
        QuestieDB.GetQuest = function(id)
            return {level = 5, name = "Wolves", Id = id, Description = {"Kill ten wolves."}}
        end
        QuestieDB.GetNPC = function() return {name = "Young Wolf", minLevel = 1, subName = "The Hungry"} end
        QuestieDB.QueryObjectSingle = function(id) return id == 55 and "Half-eaten body" or nil end
        QuestieLoader:ImportModule("QuestieLib").GetColoredQuestName = function(_, id, showLevel, showState)
            return (showLevel and "[5] " or "") .. "Quest " .. id .. (showState and "" or " without its state")
        end
        QuestieLoader:ImportModule("QuestieLink").GetQuestLinkStringById = function(id) return "link to " .. id end
        QuestieLoader:ImportModule("WrappedText").TextWrap = function(_, line) return {line} end
        QuestieLoader:ImportModule("JourneyWindow").OpenLink = function(kind, id) table.insert(opened, {kind, id}) end
        -- Which quests are listed, in what order and with what note, and their icons, are tested with JourneyQuestCategories
        JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
        JourneyQuestCategories.Arrange = function(questIds)
            local entries = {}
            for index = #questIds, 1, -1 do
                if questIds[index] ~= 404 then
                    table.insert(entries, {questId = questIds[index], category = "available", note = "note of " .. questIds[index]})
                end
            end
            return entries
        end
        JourneyQuestCategories.GetIcon = function(_, category) return "icon of " .. category end

        dofile("Modules/Journey/Data/QuestieSearch.lua")
        dofile("Modules/Journey/Details/JourneyLinks.lua")
        JourneyLinks = QuestieLoader:ImportModule("JourneyLinks")
    end)

    after_each(function()
        _G.Questie, _G.IsModifiedClick = originalQuestie, originalIsModifiedClick
        _G.ChatEdit_GetActiveWindow, _G.ChatEdit_InsertLink = originalGetActiveWindow, originalInsertLink
        ui.Restore()
    end)

    ---@param kind JourneyKind
    ---@param id number
    ---@return string[] lines Of the tooltip of a row that leads there
    local function TooltipLines(kind, id)
        GameTooltip.lines = nil
        JourneyLinks.Link({type = "step"}, kind, id).showTooltip()
        return GameTooltip.lines
    end

    describe("Link", function()
        it("should make any row lead somewhere, and keep what it shows", function()
            local row = JourneyLinks.Link({type = "entity", text = "Young Wolf"}, "npc", 299)

            row.onClick()

            assert.are_same({{"npc", 299}}, opened)
            assert.are.equal("Young Wolf", row.text)
        end)

        it("should describe what it leads to in its tooltip", function()
            assert.are_same({"[5] Quest 7 without its state", "Kill ten wolves.", "\nClick to show"}, TooltipLines("quest", 7))
            assert.are_same({"[1] Young Wolf", "    The Hungry", "\nClick to show"}, TooltipLines("npc", 299))
            assert.are_same({"Half-eaten body", "\nClick to show"}, TooltipLines("object", 55))
        end)

        it("should show the game's own tooltip of an item", function()
            local lines = TooltipLines("item", 725)

            assert.are.equal(725, GameTooltip.itemId)
            assert.are_same({"\nClick to show"}, lines)
        end)

        it("should show the ID of each kind only while its setting does", function()
            Questie.db.profile.enableTooltipsNPCID = true
            assert.are.equal("[1] Young Wolf (299)", TooltipLines("npc", 299)[1])
            assert.are.equal("Half-eaten body", TooltipLines("object", 55)[1])

            Questie.db.profile.enableTooltipsNPCID, Questie.db.profile.enableTooltipsObjectID = false, true
            assert.are.equal("[1] Young Wolf", TooltipLines("npc", 299)[1])
            assert.are.equal("Half-eaten body (55)", TooltipLines("object", 55)[1])
        end)

        it("should understand NPCs and quests that lack some of their data", function()
            QuestieDB.GetNPC = function() return {name = "Young Wolf"} end
            QuestieDB.GetQuest = function(id) return {level = 5, name = "Wolves", Id = id} end

            assert.are_same({"[0] Young Wolf", "\nClick to show"}, TooltipLines("npc", 299))
            assert.are_same({"[5] Quest 7 without its state", "\nClick to show"}, TooltipLines("quest", 7))
        end)
    end)

    describe("GetIdText", function()
        it("should only give the ID while the setting of its kind shows IDs", function()
            Questie.db.profile.enableTooltipsItemID = true

            assert.are_same({" (725)", "", ""}, {
                JourneyLinks.GetIdText("item", 725), JourneyLinks.GetIdText("npc", 299), JourneyLinks.GetIdText("object", 55),
            })
        end)
    end)

    describe("GetQuestSteps", function()
        it("should lead to the quests the list has, in its order, with what it says about them", function()
            local steps, entries = JourneyLinks.GetQuestSteps({7, 404, 8})

            assert.are_same({"[5] Quest 8 without its state", "[5] Quest 7 without its state"}, {steps[1].text, steps[2].text})
            assert.are_same({"note of 8", "icon of available"}, {steps[1].tag, steps[1].trailingIcon})
            assert.are_same({8, 7}, {entries[1].questId, entries[2].questId})
            steps[2].onClick()
            assert.are_same({{"quest", 7}}, opened)
        end)

        it("should give the icon of the category of each quest", function()
            JourneyQuestCategories.Arrange = function() return {{questId = 7, category = "log"}, {questId = 8, category = "later"}} end

            local steps = JourneyLinks.GetQuestSteps({7, 8})

            assert.are_same({"icon of log", "icon of later"}, {steps[1].trailingIcon, steps[2].trailingIcon})
        end)

        it("should give nothing without quests", function()
            assert.are_same({}, (JourneyLinks.GetQuestSteps(nil)))
        end)
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
