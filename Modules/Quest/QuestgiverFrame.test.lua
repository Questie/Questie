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

describe("QuestgiverFrame gossip icons", function()
    local globals = {
        "GossipAvailableQuestButtonMixin", "GossipActiveQuestButtonMixin", "hooksecurefunc",
        "QuestFrameGreetingPanel", "QuestFrameGreetingPanel_OnShow", "UnitGUID", "GetBuildInfo", "GossipFrame", "C_Timer",
    }
    local originals, mocks, mixins, nativeSetups, hooks
    local originalIcons, originalStarted, originalEnabled, originalForever
    local buttons, shown
    ---@type QuestgiverFrame
    local QuestgiverFrame
    ---@type QuestieLib
    local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

    ---@return table button
    local function _GossipButton()
        local button = {Icon = {SetTexture = spy.new(function() end)}}
        button.GetElementData = function() return button.elementData end
        return button
    end

    before_each(function()
        originals = {}
        for _, name in ipairs(globals) do
            originals[name] = _G[name]
            _G[name] = nil
        end
        originalIcons = Questie.icons
        originalStarted = Questie.started
        originalEnabled = Questie.db.profile.enableQuestFrameIcons
        originalForever = Questie.IsForever
        Questie.icons = {available = "available", incomplete = "incomplete", complete = "complete"}
        Questie.started = true
        Questie.IsForever = true
        Questie.db.profile.enableQuestFrameIcons = true
        mocks = {
            stub(QuestieDB, "IsComplete", function() return 1 end),
            stub(QuestieDB, "IsPvPQuest", function() return false end),
            stub(QuestieDB, "IsActiveEventQuest", function() return false end),
            stub(QuestieDB, "IsRepeatable", function() return false end),
            stub(QuestieLib, "GetAddonVersionString", function() return "test-addon" end),
            stub(Questie, "Error"),
        }
        _G.UnitGUID = function() return "test-npc" end
        _G.GetBuildInfo = function() return "test-client" end
        mixins, nativeSetups, hooks = {}, {}, {}
        for _, kind in ipairs({"available", "active"}) do
            nativeSetups[kind] = spy.new(function(button, questInfo)
                button.elementData = {info = questInfo}
                button.Icon:SetTexture("blizzard")
            end)
            mixins[kind] = {Setup = nativeSetups[kind]}
        end
        _G.GossipAvailableQuestButtonMixin = mixins.available
        _G.GossipActiveQuestButtonMixin = mixins.active
        buttons, shown = {}, true
        _G.GossipFrame = {
            IsShown = function() return shown end,
            GreetingPanel = {ScrollBox = {ForEachFrame = function(_, callback)
                for _, button in ipairs(buttons) do
                    callback(button)
                end
            end}},
        }
        _G.C_Timer = {After = spy.new(function() end)}
        -- Record the API contract only; this fixture does not simulate WoW's taint behavior.
        _G.hooksecurefunc = function(target, method, callback)
            assert.are.equal("Setup", method)
            hooks[target] = callback
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
        Questie.IsForever = originalForever
    end)

    it("registers both secure posthooks wherever modern gossip mixins are present", function()
        for _, isForever in ipairs({true, false}) do
            Questie.IsForever = isForever
            hooks = {}
            dofile("Modules/Quest/QuestgiverFrame.lua")
            for _, kind in ipairs({"available", "active"}) do
                assert.are.equal(nativeSetups[kind], mixins[kind].Setup)
                assert.is_function(hooks[mixins[kind]])
                assert.spy(nativeSetups[kind]).was.not_called()
            end
            QuestgiverFrame.GossipMark()
        end
        assert.spy(C_Timer.After).was.not_called()
    end)

    it("decorates after native setup and reads a reused button's current quest", function()
        for _, kind in ipairs({"available", "active"}) do
            local button = _GossipButton()
            local posthook = hooks[mixins[kind]]
            assert.is_function(posthook)
            for _, questID in ipairs({33, 34}) do
                local info = {questID = questID}
                QuestieDB.IsPvPQuest:clear()
                -- Drive the documented native-then-posthook order explicitly.
                mixins[kind].Setup(button, info)
                assert.are.equal("blizzard", button.Icon.SetTexture.calls[1].vals[2])
                posthook(button, info)
                assert.spy(button.Icon.SetTexture).was.called(2)
                assert.are.equal(kind == "available" and "available" or "complete", button.Icon.SetTexture.calls[2].vals[2])
                assert.spy(QuestieDB.IsPvPQuest).was.called_with(questID)
                button.Icon.SetTexture:clear()
            end
            assert.spy(nativeSetups[kind]).was.called(2)
        end
    end)

    it("skips decoration under its existing guards without affecting native setup", function()
        for _, guard in ipairs({"not started", "icons disabled", "no element data getter"}) do
            Questie.started = guard ~= "not started"
            Questie.db.profile.enableQuestFrameIcons = guard ~= "icons disabled"
            for _, kind in ipairs({"available", "active"}) do
                local button = _GossipButton()
                if guard == "no element data getter" then
                    button.GetElementData = nil
                end
                local posthook = hooks[mixins[kind]]
                assert.is_function(posthook)
                mixins[kind].Setup(button, {questID = 33})
                posthook(button, {questID = 33})
                assert.spy(button.Icon.SetTexture).was.called_with(button.Icon, "blizzard")
                assert.spy(button.Icon.SetTexture).was.called(1)
            end
        end
        assert.spy(nativeSetups.available).was.called(3)
        assert.spy(nativeSetups.active).was.called(3)
        assert.spy(QuestieDB.IsPvPQuest).was.not_called()
        assert.spy(Questie.Error).was.not_called()
    end)

    it("retains the missing quest ID errors for both button types", function()
        for _, kind in ipairs({"available", "active"}) do
            local button = _GossipButton()
            local posthook = hooks[mixins[kind]]
            assert.is_function(posthook)
            Questie.Error:clear()
            mixins[kind].Setup(button, {})
            posthook(button, {})
            assert.spy(button.Icon.SetTexture).was.called(1)
            assert.spy(Questie.Error).was.called_with(
                "Frame error! Missing Gossip line item quest ID. Please report this on Github or Discord!")
            assert.spy(Questie.Error).was.called_with("Questgiver for " .. kind .. " quest is: test-npc")
            assert.spy(Questie.Error).was.called_with("Client info is: test-client; test-addon")
            assert.spy(Questie.Error).was.called(3)
        end
    end)

    for _, nativeFirst in ipairs({true, false}) do
        it("refreshes completion icons when " .. (nativeFirst and "Blizzard" or "Questie") .. " handles the quest update first", function()
            local available, active = _GossipButton(), _GossipButton()
            local function _RebuildGossipButtons()
                for kind, button in pairs({available = available, active = active}) do
                    mixins[kind].Setup(button, {questID = 33})
                    button.elementData[kind .. "QuestButton"] = true
                    hooks[mixins[kind]](button)
                end
            end
            local greeting = _GossipButton()
            greeting.elementData = {greetingTextFrame = {}}
            buttons = {available, active, greeting}
            QuestieDB.IsComplete.returns(0)
            _RebuildGossipButtons()
            assert.are.equal("incomplete", active.Icon.SetTexture.calls[2].vals[2])
            available.Icon.SetTexture:clear()
            active.Icon.SetTexture:clear()

            if nativeFirst then
                _RebuildGossipButtons()
            end
            QuestieDB.IsComplete.returns(1) -- Questie's synchronous quest-cache refresh precedes RecheckGossip.
            QuestgiverFrame.RecheckGossip()
            assert.are.equal("complete", active.Icon.SetTexture.calls[#active.Icon.SetTexture.calls].vals[2])
            if not nativeFirst then
                _RebuildGossipButtons()
            end

            assert.are.equal("complete", active.Icon.SetTexture.calls[#active.Icon.SetTexture.calls].vals[2])
            assert.are.equal("available", available.Icon.SetTexture.calls[#available.Icon.SetTexture.calls].vals[2])
            assert.spy(greeting.Icon.SetTexture).was.not_called()
            assert.spy(C_Timer.After).was.not_called()
        end)
    end

    it("skips gossip refresh when icons are disabled, the dialog is hidden, or the flavor is not Forever", function()
        local button = _GossipButton()
        button.elementData = {activeQuestButton = true, info = {questID = 33}}
        buttons = {button}
        for _, guard in ipairs({"icons disabled", "dialog hidden", "other flavor"}) do
            Questie.db.profile.enableQuestFrameIcons = guard ~= "icons disabled"
            shown = guard ~= "dialog hidden"
            Questie.IsForever = guard ~= "other flavor"
            QuestgiverFrame.RecheckGossip()
        end
        assert.spy(button.Icon.SetTexture).was.not_called()
        assert.spy(QuestieDB.IsComplete).was.not_called()
        assert.spy(C_Timer.After).was.not_called()
    end)
end)
