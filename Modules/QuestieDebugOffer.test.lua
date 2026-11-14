dofile("setupTests.lua")

describe("QuestieDebugOffer quest dialogs", function()
    ---@type QuestieDebugOffer
    local QuestieDebugOffer
    ---@type QuestieDB
    local QuestieDB
    local savedGlobals, savedPrint, displayedFrame, secretGuid
    local publicGuid = "Creature-0-0-0-0-456-00000001"
    local globalNames = {
        "C_Map", "UnitRace", "UnitLevel", "UnitGUID", "GetUnitName", "GetQuestID", "GetTitleText",
        "GetQuestText", "GetObjectiveText", "GetRewardText", "GetRewardXP", "GetLocale", "format",
        "issecretvalue", "CreateFrame",
    }

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(globalNames) do
            savedGlobals[name] = _G[name]
        end
        savedPrint = Questie.Print
        displayedFrame = nil
        -- This sentinel rejects conversion; it does not emulate the client's secret-value implementation.
        secretGuid = setmetatable({}, {__tostring = function() error("Restricted GUID must not be converted") end})
        _G.issecretvalue = function(value) return value == secretGuid end
        _G.UnitGUID = spy.new(function() return publicGuid end)
        _G.UnitRace = function() return "Human", "Human" end
        _G.UnitLevel = function() return 20 end
        _G.GetUnitName = function() return "TestPlayer" end
        _G.GetQuestID = function() return 123 end
        _G.GetTitleText = function() return "Missing quest" end
        _G.GetQuestText = function() return "Help us, TestPlayer." end
        _G.GetObjectiveText = function() return "Find the item, TestPlayer." end
        _G.GetRewardText = function() return "Thank you, TestPlayer." end
        _G.GetRewardXP = function() return 100 end
        _G.GetLocale = function() return "enUS" end
        _G.format = string.format
        _G.C_Map = {
            GetBestMapForUnit = function() return 1 end,
            GetPlayerMapPosition = function() return {x = 0.25, y = 0.5} end,
        }

        -- Extend the shared frame fixture just enough to read the report through the public ShowOffer path.
        local createFrame = savedGlobals.CreateFrame
        _G.CreateFrame = function(frameType, name, ...)
            local frame = createFrame(frameType, name, ...)
            for _, method in ipairs({
                "SetMovable", "EnableMouse", "RegisterForDrag", "SetFontObject", "SetMultiLine",
                "SetJustifyH", "SetJustifyV", "SetFocus", "SetAutoFocus",
            }) do
                frame[method] = function() end
            end
            frame.SetText = function(self, text) self.text = text end
            if name == "QuestieDebugOfferFrame" then
                displayedFrame = frame
            end
            return frame
        end

        dofile("Localization/l10n.lua")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QueryQuestSingle = function() return nil end
        QuestieLoader:ImportModule("QuestLogCache").questLog_DO_NOT_MODIFY = {[789] = {}}
        QuestieLoader:ImportModule("QuestieLib").GetAddonVersionString = function() return "test-version" end
        Questie.Print = spy.new(function() end)
        dofile("Modules/QuestieDebugOffer.lua")
        QuestieDebugOffer = QuestieLoader:ImportModule("QuestieDebugOffer")
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do
            _G[name] = savedGlobals[name]
        end
        Questie.Print = savedPrint
    end)

    local function _ReadOffer(index)
        QuestieDebugOffer.ShowOffer("addon:questie:offer:" .. index)
        return displayedFrame.dataEditBox.text
    end

    it("preserves the report and subsequent offers when the giver's identity is restricted", function()
        _G.UnitGUID = spy.new(function() return secretGuid end)

        QuestieDebugOffer.QuestDialog()

        assert.spy(Questie.Print).was.called(1)
        assert.spy(_G.UnitGUID).was.called_with("questnpc")
        local report = _ReadOffer(1)
        assert.is_truthy(report:find("Questgiver:|r <restricted>", 1, true))
        assert.is_truthy(report:find("Quest ID:|r 123", 1, true))
        assert.is_truthy(report:find("Quest Name:|r Missing quest", 1, true))
        assert.is_truthy(report:find("Quest Text:|r Help us, <playername>.", 1, true))
        assert.is_truthy(report:find("Objective Text:|r Find the item, <playername>.", 1, true))
        assert.is_truthy(report:find("Reward Text:|r Thank you, <playername>.", 1, true))
        assert.is_truthy(report:find("Reward XP:|r 100", 1, true))
        assert.is_truthy(report:find("QuestLog:|r 789", 1, true))
        assert.is_truthy(report:find("Questie:|r test-version", 1, true))
        assert.is_nil(report:find("TestPlayer", 1, true))

        _G.UnitGUID = function() return publicGuid end
        QuestieDebugOffer.QuestDialog()

        assert.spy(Questie.Print).was.called(2)
        assert.is_truthy(_ReadOffer(2):find("Questgiver:|r " .. publicGuid, 1, true))
    end)

    it("preserves readable giver GUIDs on clients without the secret-value API", function()
        _G.issecretvalue = nil

        QuestieDebugOffer.QuestDialog()

        assert.spy(Questie.Print).was.called(1)
        assert.is_truthy(_ReadOffer(1):find("Questgiver:|r " .. publicGuid, 1, true))
    end)

    it("preserves an item-started quest report when there is no giver GUID", function()
        _G.UnitGUID = function() return nil end

        QuestieDebugOffer.QuestDialog()

        assert.spy(Questie.Print).was.called(1)
        assert.is_truthy(_ReadOffer(1):find("Questgiver:|r nil", 1, true))
    end)

    it("does not offer a report for a known quest even if the giver is restricted", function()
        QuestieDB.QueryQuestSingle = function() return "Known quest" end
        _G.UnitGUID = spy.new(function() return secretGuid end)

        QuestieDebugOffer.QuestDialog()

        assert.spy(Questie.Print).was.not_called()
        assert.spy(_G.UnitGUID).was.not_called()
    end)
end)
