dofile("setupTests.lua")

describe("QuestieSearchResults selection", function()
    local QuestieSearchResults, QuestDetailsFrame
    local widgets, quest
    local originals

    local function CreateWidget(_, widgetType)
        local widget = {
            type = widgetType,
            children = {},
            callbacks = {},
            treeframe = {SetWidth = function() end},
            SetLayout = function() end,
            SetFullWidth = function() end,
            SetFullHeight = function() end,
            SetRelativeWidth = function() end,
            SetDisabled = function() end,
            SetFocus = function() end,
            SetLabel = function() end,
            DisableButton = function() end,
            SetText = function(self, text) self.text = text end,
            GetText = function(self) return self.text end,
            SetTree = function(self, tree) self.tree = tree end,
            SetTabs = function(self, tabs) self.tabs = tabs end,
            AddChild = function(self, child) self.children[#self.children + 1] = child end,
            ReleaseChildren = function(self) self.children = {} end,
            SetCallback = function(self, event, callback) self.callbacks[event] = callback end,
            Fire = function(self, event, ...)
                if self.callbacks[event] then
                    self.callbacks[event](self, event, ...)
                end
            end,
            SelectTab = function(self, value)
                self:Fire("OnGroupSelected", value)
            end,
            SelectByValue = function(self, value)
                self.selected = value
                self:Fire("OnGroupSelected", value)
            end,
        }
        widget.frame = {obj = widget}
        widgets[widgetType] = widget
        return widget
    end

    before_each(function()
        originals = {
            Questie = _G.Questie, LibStub = _G.LibStub, CreateFrame = _G.CreateFrame,
            IsShiftKeyDown = _G.IsShiftKeyDown, ChatEdit_InsertLink = _G.ChatEdit_InsertLink,
        }
        _G.Questie = {db = {char = {complete = {}}, profile = {}}}
        _G.LibStub = function() return {Create = CreateWidget} end
        _G.CreateFrame = function() return {SetOwner = function() end} end
        _G.IsShiftKeyDown = function() return false end
        _G.ChatEdit_InsertLink = spy.new(function() end)
        widgets = {}
        quest = {Id = 92517, name = "The Criminal Element"}

        dofile("Localization/l10n.lua")
        QuestieLoader:ImportModule("QuestieJourneyUtils").Spacer = function() end
        QuestieLoader:ImportModule("QuestieLink").GetQuestLinkStringById = function(id)
            return "quest:" .. id
        end
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QueryQuestSingle = function() return quest.name end
        QuestieDB.QueryNPCSingle = function() return "Constable Aonda" end
        QuestieDB.GetQuest = function(id)
            assert.equals(92517, id)
            return quest
        end
        local QuestieSearch = QuestieLoader:ImportModule("QuestieSearch")
        QuestieSearch.LastResult = {query = "", quest = {}, npc = {}, object = {}, item = {}}
        QuestieSearch.ByID = function(_, id)
            QuestieSearch.LastResult = {query = id, quest = {[id] = true}, npc = {[id] = true}, object = {}, item = {}}
        end
        QuestDetailsFrame = QuestieLoader:ImportModule("QuestDetailsFrame")
        QuestDetailsFrame.Draw = spy.new(function() end)

        dofile("Modules/Journey/QuestieSearchResults.lua")
        QuestieSearchResults = QuestieLoader:ImportModule("QuestieSearchResults")
        QuestieSearchResults:DrawSearchTab(CreateWidget(nil, "SimpleGroup"))
    end)

    after_each(function()
        _G.Questie, _G.LibStub, _G.CreateFrame = originals.Questie, originals.LibStub, originals.CreateFrame
        _G.IsShiftKeyDown, _G.ChatEdit_InsertLink = originals.IsShiftKeyDown, originals.ChatEdit_InsertLink
    end)

    it("selects the linked quest and opens its details without a mouse click", function()
        _G.IsShiftKeyDown = function() return true end

        QuestieSearchResults:SetSearch("quest", 92517)

        assert.equals(92517, widgets.TreeGroup.selected)
        assert.spy(QuestDetailsFrame.Draw).was.called(1)
        assert.spy(QuestDetailsFrame.Draw).was.called_with(QuestDetailsFrame, widgets.ScrollFrame, quest)
        assert.spy(ChatEdit_InsertLink).was.not_called()
    end)

    it("opens the requested result type when the ID matches multiple types", function()
        QuestieSearchResults.SpawnDetailsFrame = spy.new(function() end)

        QuestieSearchResults:SetSearch("npc", 251523)

        assert.equals(251523, widgets.TreeGroup.selected)
        assert.spy(QuestieSearchResults.SpawnDetailsFrame).was.called_with(
            QuestieSearchResults, widgets.ScrollFrame, 251523, "npc")
        assert.spy(QuestDetailsFrame.Draw).was.not_called()
    end)

    it("opens details once when a mouse click selects a result", function()
        QuestieSearchResults:DrawSearchResultTab(widgets.SimpleGroup, 2, 92517, false)
        local tree = widgets.TreeGroup

        tree:Fire("OnClick", "92517", false)
        tree:SelectByValue("92517")

        assert.spy(QuestDetailsFrame.Draw).was.called(1)
        assert.spy(QuestDetailsFrame.Draw).was.called_with(QuestDetailsFrame, widgets.ScrollFrame, quest)
    end)

    it("still inserts a chat link when shift-clicking an already selected quest", function()
        QuestieSearchResults:SetSearch("quest", 92517)
        _G.IsShiftKeyDown = function() return true end

        widgets.TreeGroup:Fire("OnClick", "92517", true)

        assert.spy(ChatEdit_InsertLink).was.called_with("quest:92517")
        assert.spy(QuestDetailsFrame.Draw).was.called(1)
    end)
end)
