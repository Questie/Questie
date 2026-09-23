dofile("setupTests.lua")
local stub = require("luassert.stub")

local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---@param index number
---@param isActive number
---@return table button
local function GreetingButton(index, isActive)
    return {
        Icon = {SetTexture = spy.new(function() end)},
        IsShown = function() return true end,
        GetID = function() return index end,
        isActive = isActive,
    }
end

describe("QuestgiverFrame greeting icons", function()
    local QuestgiverFrame
    local originals, mocks, rebuildGreeting
    local originalIcons, originalStarted, originalEnabled
    local globals = {
        "QuestFrameGreetingPanel", "QuestFrameGreetingPanel_OnShow", "hooksecurefunc",
        "GossipAvailableQuestButtonMixin", "UnitGUID", "GetActiveQuestID", "GetAvailableQuestInfo",
        "GetActiveTitle", "GetAvailableTitle", "GetNumActiveQuests", "GetNumAvailableQuests",
        "QuestTitleButton1", "QuestTitleButton2", "QuestTitleButton1QuestIcon",
    }
    local npcGuid = "Creature-0-0-0-0-123-0"

    before_each(function()
        originals = {}
        for _, name in ipairs(globals) do
            originals[name] = _G[name]
            _G[name] = nil
        end
        originalIcons = Questie.icons
        originalStarted = Questie.started
        originalEnabled = Questie.db.profile.enableQuestFrameIcons
        Questie.icons = {available = "available", incomplete = "incomplete", complete = "complete"}
        Questie.started = true
        Questie.db.profile.enableQuestFrameIcons = true
        mocks = {
            stub(QuestieDB, "IsComplete", function() return 1 end),
            stub(QuestieDB, "IsPvPQuest", function() return false end),
            stub(QuestieDB, "IsActiveEventQuest", function() return false end),
            stub(QuestieDB, "IsRepeatable", function() return false end),
            stub(QuestieDB, "GetQuestIDFromName", function() return 33 end),
            stub(Questie, "Error"),
        }
        _G.UnitGUID = spy.new(function() return npcGuid end)
        _G.GetNumActiveQuests = function() return 2 end
        _G.GetNumAvailableQuests = function() return 3 end
        _G.GetActiveQuestID = spy.new(function() return 783 end)
        _G.GetAvailableQuestInfo = spy.new(function() return false, 0, false, false, 33 end)
        rebuildGreeting = function() end
        _G.QuestFrameGreetingPanel_OnShow = function() rebuildGreeting() end

        -- XML binds OnShow before Questie loads. Replacing the global must not replace that saved script.
        local nativeOnShow = _G.QuestFrameGreetingPanel_OnShow
        local scripts = {}
        _G.QuestFrameGreetingPanel = {
            HookScript = function(_, name, callback) scripts[name] = callback end,
            Show = function()
                nativeOnShow()
                if scripts.OnShow then scripts.OnShow() end
            end,
        }
        _G.hooksecurefunc = function(name, callback)
            local original = _G[name]
            _G[name] = function(...)
                original(...)
                callback(...)
            end
        end
        dofile("Modules/Quest/QuestgiverFrame.lua")
        QuestgiverFrame = QuestieLoader:ImportModule("QuestgiverFrame")
    end)

    after_each(function()
        for _, mock in ipairs(mocks) do
            mock:revert()
        end
        for _, name in ipairs(globals) do
            _G[name] = originals[name]
        end
        Questie.icons = originalIcons
        Questie.started = originalStarted
        Questie.db.profile.enableQuestFrameIcons = originalEnabled
    end)

    it("decorates the XML-bound OnShow after Blizzard populates native pooled buttons", function()
        -- Questie's event may arrive before Blizzard has built the greeting.
        QuestgiverFrame.GreetingMark()
        assert.spy(Questie.Error).was.not_called()
        local active = GreetingButton(2, 1)
        local available = GreetingButton(3, 0)
        local buttons = {[active] = true, [available] = true}
        rebuildGreeting = function()
            QuestFrameGreetingPanel.titleButtonPool = {EnumerateActive = function() return next, buttons end}
            active.Icon:SetTexture("blizzard")
            available.Icon:SetTexture("blizzard")
        end

        QuestFrameGreetingPanel:Show()

        assert.spy(active.Icon.SetTexture).was.called(2)
        assert.are.equal("complete", active.Icon.SetTexture.calls[2].vals[2])
        assert.are.equal("available", available.Icon.SetTexture.calls[2].vals[2])
        assert.spy(_G.GetActiveQuestID).was.called_with(2)
        assert.spy(_G.GetAvailableQuestInfo).was.called_with(3)
        assert.spy(QuestieDB.GetQuestIDFromName).was.not_called()
        assert.spy(UnitGUID).was.called_with("npc")
    end)

    it("decorates explicit rebuilds and uses a pooled button's current list identity", function()
        local button = GreetingButton(1, 1)
        local buttons = {[button] = true}
        QuestFrameGreetingPanel.titleButtonPool = {EnumerateActive = function() return next, buttons end}
        rebuildGreeting = function() button.Icon:SetTexture("blizzard") end
        _G.QuestFrameGreetingPanel_OnShow()
        assert.are.equal("complete", button.Icon.SetTexture.calls[2].vals[2])
        button.Icon.SetTexture:clear()

        button.isActive = 0
        _G.QuestFrameGreetingPanel_OnShow()

        assert.spy(button.Icon.SetTexture).was.called(2)
        assert.are.equal("available", button.Icon.SetTexture.calls[2].vals[2])
        assert.spy(_G.GetAvailableQuestInfo).was.called_with(1)
    end)

    it("refreshes completion icons when the quest log changes", function()
        local button = GreetingButton(1, 1)
        local buttons = {[button] = true}
        QuestFrameGreetingPanel.titleButtonPool = {EnumerateActive = function() return next, buttons end}
        _G.GetActiveTitle = function() return "Accepted Quest" end
        _G.GetAvailableTitle = function() return nil end
        mocks[1].returns(0)
        QuestgiverFrame.RecheckGreeting()
        assert.spy(button.Icon.SetTexture).was.called_with(button.Icon, "incomplete")
        button.Icon.SetTexture:clear()

        mocks[1].returns(1)
        QuestgiverFrame.RecheckGreeting()

        assert.spy(button.Icon.SetTexture).was.called_with(button.Icon, "complete")
    end)

    it("ignores stale buttons until Blizzard rebuilds a shorter greeting list", function()
        local button = GreetingButton(3, 0)
        local buttons = {[button] = true}
        QuestFrameGreetingPanel.titleButtonPool = {EnumerateActive = function() return next, buttons end}
        _G.GetNumAvailableQuests = function() return 1 end

        QuestgiverFrame.GreetingMark()

        assert.spy(_G.GetAvailableQuestInfo).was.not_called()
        assert.spy(button.Icon.SetTexture).was.not_called()
    end)

    it("keeps Classic numbered-button icons and title-based resolution", function()
        _G.GetActiveQuestID = nil
        _G.GetAvailableQuestInfo = function() return false, false, false, false end
        _G.GetAvailableTitle = function() return "Offered Quest" end
        local button = GreetingButton(2, 0)
        local icon = button.Icon
        button.Icon = nil
        _G.QuestTitleButton1 = button
        _G.QuestTitleButton1QuestIcon = icon

        QuestgiverFrame.GreetingMark()

        assert.spy(QuestieDB.GetQuestIDFromName).was.called_with("Offered Quest", npcGuid, true)
        assert.spy(icon.SetTexture).was.called_with(icon, "available")
        assert.spy(Questie.Error).was.not_called()
    end)

    it("leaves native icons alone when the option is disabled", function()
        local button = GreetingButton(1, 0)
        local buttons = {[button] = true}
        QuestFrameGreetingPanel.titleButtonPool = {EnumerateActive = function() return next, buttons end}
        Questie.db.profile.enableQuestFrameIcons = false

        QuestgiverFrame.GreetingMark()
        QuestFrameGreetingPanel:Show()
        _G.QuestFrameGreetingPanel_OnShow()

        assert.spy(button.Icon.SetTexture).was.not_called()
    end)

    it("does not decorate Blizzard's greeting before Questie has started", function()
        Questie.started = false

        QuestFrameGreetingPanel:Show()
        _G.QuestFrameGreetingPanel_OnShow()

        assert.spy(UnitGUID).was.not_called()
    end)

end)
