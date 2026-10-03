dofile("setupTests.lua")

describe("QuestDetailsFrame prerequisite links", function()
    local QuestDetailsFrame
    local QuestieSearchResults
    local links
    local navigation
    local originalQuestie, originalLibStub, originalUnitLevel

    local function CreateWidget(_, widgetType)
        local widget = {
            callbacks = {},
            userdata = {},
            text = {SetFontObject = function() end},
            SetFullWidth = function() end,
            SetText = function() end,
            SetValue = function() end,
            SetLabel = function() end,
            SetDisabled = function() end,
            SetHeight = function() end,
            SetLayout = function() end,
            SetTitle = function() end,
            AddChild = function() end,
            SetUserData = function(self, key, value) self.userdata[key] = value end,
            SetCallback = function(self, event, callback) self.callbacks[event] = callback end,
        }
        if widgetType == "InteractiveLabel" then
            links[#links + 1] = widget
        end
        return widget
    end

    before_each(function()
        originalQuestie, originalLibStub, originalUnitLevel = _G.Questie, _G.LibStub, _G.UnitLevel
        _G.Questie = {
            db = {char = {complete = {}, hidden = {}}, profile = {}},
            Colorize = function(_, text) return text end,
        }
        _G.LibStub = function() return {Create = CreateWidget} end
        _G.UnitLevel = function() return 5 end
        links, navigation = {}, {}

        dofile("Localization/l10n.lua")
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        local fields = {requiredLevel = 5, questLevel = 8, name = "Prerequisite"}
        QuestieDB.QueryQuestSingle = function(_, field) return fields[field] end
        QuestieDB.IsRepeatable = function() return false end
        QuestieDB.IsDoableVerbose = function() return nil, false end
        QuestieLoader:ImportModule("QuestieCorrections").hiddenQuests = {}
        QuestieLoader:ImportModule("QuestieReputation").GetReputationReward = function() end

        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetEffectiveQuestLevel = function() return 8 end
        QuestieLib.GetRaceString = function() return "" end
        QuestieLib.GetClassString = function() return "" end
        QuestieLib.GetColoredQuestName = function(_, id) return "Prerequisite " .. id end

        local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
        QuestieJourneyUtils.Spacer = function() end
        QuestieJourneyUtils.CreateObjectiveText = function() return "Speak with Sania Silverstream." end
        QuestieJourneyUtils.HideJourneyTooltip = function()
            navigation[#navigation + 1] = "hide tooltip"
        end

        QuestieSearchResults = QuestieLoader:ImportModule("QuestieSearchResults")
        QuestieSearchResults.SetSearch = nil
        QuestieLoader:ImportModule("QuestieJourney").tabGroup = {
            SelectTab = function(_, tab)
                navigation[#navigation + 1] = tab
                -- Search controls do not exist until their tab has been drawn.
                QuestieSearchResults.SetSearch = spy.new(function() end)
            end,
        }

        dofile("Modules/Journey/QuestDetailsFrame.lua")
        QuestDetailsFrame = QuestieLoader:ImportModule("QuestDetailsFrame")
    end)

    after_each(function()
        _G.Questie, _G.LibStub, _G.UnitLevel = originalQuestie, originalLibStub, originalUnitLevel
    end)

    it("opens the search tab before navigating to a single prerequisite", function()
        QuestDetailsFrame:Draw({AddChild = function() end}, {
            Id = 93036,
            name = "Infiltrating the Cult",
            preQuestSingle = {92517},
            Finisher = {},
        })

        assert.equals(1, #links)
        links[1].callbacks.OnClick()

        assert.same({"hide tooltip", "search"}, navigation)
        assert.spy(QuestieSearchResults.SetSearch).was.called_with(QuestieSearchResults, "quest", 92517)
    end)

    it("navigates to each grouped prerequisite using its absolute quest ID", function()
        QuestDetailsFrame:Draw({AddChild = function() end}, {
            Id = 93036,
            name = "Infiltrating the Cult",
            preQuestGroup = {-92517, 94568},
            Finisher = {},
        })

        assert.equals(2, #links)
        links[1].callbacks.OnClick()
        assert.spy(QuestieSearchResults.SetSearch).was.called_with(QuestieSearchResults, "quest", 92517)

        links[2].callbacks.OnClick()
        assert.spy(QuestieSearchResults.SetSearch).was.called_with(QuestieSearchResults, "quest", 94568)
    end)
end)
