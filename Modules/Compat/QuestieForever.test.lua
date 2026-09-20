dofile("setupTests.lua")

describe("Forever API translations", function()
    local QuestieCompat
    local aliases = {
        "GetQuestGreenRange", "GetQuestsCompleted", "GetQuestLogTitle", "GetNumQuestLogEntries",
        "GetQuestLogIndexByID", "GetQuestIDFromLogIndex", "SelectQuestLogEntry", "GetQuestLogSelection",
        "GetQuestIndexForWatch", "IsQuestWatched", "AddQuestWatch", "RemoveQuestWatch", "GetQuestTagInfo",
        "GetNumQuestWatches", "GetFactionInfo", "GetFactionInfoByID", "GetNumFactions", "ExpandFactionHeader",
        "GetSpellInfo", "GetAddOnMetadata", "SetDesaturation", "UnitAura", "MouseIsOver", "GetQuestTimers",
    }
    local dependencies = {
        "QuestieLoader", "QuestieCompat", "C_QuestLog", "C_Reputation", "C_Spell", "Enum", "CreateFrame",
        "ObjectiveTrackerFrame", "InCombatLockdown",
    }
    local savedGlobals
    local questInfo
    local visibilityFrame
    local onRegen

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(aliases) do
            savedGlobals[name] = _G[name]
            _G[name] = nil
        end
        for _, name in ipairs(dependencies) do
            savedGlobals[name] = _G[name]
        end
        dofile("Modules/Libs/QuestieLoader.lua")
        QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        _G.C_Reputation = {}
        _G.C_Spell = {}
        _G.Enum = {QuestWatchType = {Manual = 1}}
        visibilityFrame = {
            RegisterEvent = spy.new(function() end),
            UnregisterEvent = spy.new(function() end),
            SetScript = function(_, _, callback) onRegen = callback end,
        }
        _G.CreateFrame = function() return visibilityFrame end
        _G.InCombatLockdown = function() return false end
        _G.ObjectiveTrackerFrame = {
            HookScript = function() end,
            Hide = spy.new(function() end),
            Update = spy.new(function() end),
        }
        questInfo = {title = "A Threat Within", level = 1, suggestedGroup = 0, questID = 783, isHeader = false}
        _G.C_QuestLog = {
            GetInfo = spy.new(function() return questInfo end),
            GetQuestTagInfo = function() return {tagName = "Group"} end,
            IsFailed = spy.new(function() return false end),
            IsComplete = spy.new(function() return false end),
            GetNumQuestWatches = function() return 1 end,
        }
        dofile("Modules/Compat/QuestieForever.lua")
    end)

    after_each(function()
        for _, name in ipairs(aliases) do
            _G[name] = savedGlobals[name]
        end
        for _, name in ipairs(dependencies) do
            _G[name] = savedGlobals[name]
        end
    end)

    it("uses frame mouse-over even when the broken legacy global is present", function()
        _G.MouseIsOver = function() error("removed legacy dependency") end
        local frame = {IsMouseOver = spy.new(function() return true end)}
        assert.is_true(QuestieCompat.MouseIsOver(frame, 1, 2, 3, 4))
        assert.spy(frame.IsMouseOver).was.called_with(frame, 1, 2, 3, 4)
        assert.has_error(function() MouseIsOver(frame) end, "removed legacy dependency")
    end)

    it("leaves Blizzard quest and watch globals untouched", function()
        assert.is_nil(_G.GetQuestLogTitle)
        assert.is_nil(_G.GetQuestTimers)
        assert.is_nil(_G.AddQuestWatch)
        assert.is_nil(_G.GetNumQuestWatches)
        assert.are.equal(1, QuestieCompat.GetNumQuestWatches())
    end)

    it("does not take ownership of Blizzard visibility when the tracker was never hidden", function()
        QuestieCompat.ShowWatchFrame()

        assert.spy(visibilityFrame.RegisterEvent).was.not_called()
        assert.spy(ObjectiveTrackerFrame.Hide).was.not_called()
        assert.spy(ObjectiveTrackerFrame.Update).was.not_called()
    end)

    it("defers a combat-time release then returns visibility to Blizzard's own policy", function()
        QuestieCompat.HideWatchFrame()
        assert.spy(ObjectiveTrackerFrame.Hide).was.called(1)

        _G.InCombatLockdown = function() return true end
        QuestieCompat.ShowWatchFrame()
        assert.spy(visibilityFrame.RegisterEvent).was.called_with(visibilityFrame, "PLAYER_REGEN_ENABLED")
        assert.spy(ObjectiveTrackerFrame.Update).was.not_called()

        _G.InCombatLockdown = function() return false end
        onRegen()
        assert.spy(ObjectiveTrackerFrame.Update).was.called(1)
        assert.spy(visibilityFrame.UnregisterEvent).was.called_with(visibilityFrame, "PLAYER_REGEN_ENABLED")
    end)

    it("keeps the legacy tuple positions and nil completion for an incomplete quest", function()
        local title, level, group, header, _, complete, _, questID = QuestieCompat.GetQuestLogTitle(2)

        assert.are.equal("A Threat Within", title)
        assert.are.equal(1, level)
        assert.are.equal("Group", group)
        assert.is_false(header)
        assert.is_nil(complete)
        assert.are.equal(783, questID)
        assert.spy(C_QuestLog.GetInfo).was.called_with(2)
        assert.spy(C_QuestLog.IsComplete).was.called_with(783)
        assert.spy(C_QuestLog.IsFailed).was.called_with(783)
    end)

    it("translates completed and failed states to the legacy numeric values", function()
        C_QuestLog.IsComplete = function() return true end
        assert.are.equal(1, select(6, QuestieCompat.GetQuestLogTitle(2)))

        C_QuestLog.IsFailed = function() return true end
        assert.are.equal(-1, select(6, QuestieCompat.GetQuestLogTitle(2)))
    end)

    it("does not query completion for headers or missing entries", function()
        questInfo = {title = "Elwynn Forest", isHeader = true, questID = 0}
        assert.is_nil(select(6, QuestieCompat.GetQuestLogTitle(1)))

        questInfo = nil
        assert.is_nil(QuestieCompat.GetQuestLogTitle(99))
        assert.spy(C_QuestLog.IsComplete).was.not_called()
        assert.spy(C_QuestLog.IsFailed).was.not_called()
    end)

    it("translates watch indices and log indices without confusing them with quest IDs", function()
        C_QuestLog.GetQuestIDForQuestWatchIndex = spy.new(function() return 783 end)
        C_QuestLog.GetLogIndexForQuestID = spy.new(function() return 2 end)
        C_QuestLog.GetQuestWatchType = spy.new(function() return 0 end)
        C_QuestLog.AddQuestWatch = spy.new(function() return true end)
        C_QuestLog.RemoveQuestWatch = spy.new(function() return true end)

        assert.are.equal(2, QuestieCompat.GetQuestIndexForWatch(1))
        assert.is_true(QuestieCompat.IsQuestWatched(2))
        assert.is_true(QuestieCompat.AddQuestWatch(2))
        assert.is_true(QuestieCompat.RemoveQuestWatch(2))

        assert.spy(C_QuestLog.GetQuestIDForQuestWatchIndex).was.called_with(1)
        assert.spy(C_QuestLog.GetLogIndexForQuestID).was.called_with(783)
        assert.spy(C_QuestLog.GetQuestWatchType).was.called_with(783)
        assert.spy(C_QuestLog.AddQuestWatch).was.called_with(783, 1)
        assert.spy(C_QuestLog.RemoveQuestWatch).was.called_with(783)
    end)

    it("translates selection to quest IDs and absent log entries back to zero", function()
        C_QuestLog.SetSelectedQuest = spy.new(function() end)
        C_QuestLog.GetSelectedQuest = function() return 783 end
        C_QuestLog.GetLogIndexForQuestID = spy.new(function() return nil end)

        QuestieCompat.SelectQuestLogEntry(2)
        assert.spy(C_QuestLog.SetSelectedQuest).was.called_with(783)
        assert.are.equal(0, QuestieCompat.GetQuestLogSelection())
        assert.are.equal(0, QuestieCompat.GetQuestLogIndexByID(999))
        assert.spy(C_QuestLog.GetLogIndexForQuestID).was.called_with(783)
        assert.spy(C_QuestLog.GetLogIndexForQuestID).was.called_with(999)
    end)

    it("returns legacy timer varargs rather than modern timer records", function()
        C_QuestLog.GetQuestTimers = function()
            return {{questID = 33, questTimer = 81}, {questID = 783, questTimer = 120}}
        end
        assert.are.same({81, 120}, {QuestieCompat.GetQuestTimers()})

        C_QuestLog.GetQuestTimers = function() return {} end
        assert.is_nil(QuestieCompat.GetQuestTimers())
    end)

    it("converts completed IDs into a set and populates a caller-provided table", function()
        C_QuestLog.GetAllCompletedQuestIDs = function() return {783, 7} end
        local completed = {[42] = true}

        assert.are.same({[783] = true, [7] = true}, QuestieCompat.GetQuestsCompleted())
        assert.are.equal(completed, QuestieCompat.GetQuestsCompleted(completed))
        assert.are.same({[42] = true, [783] = true, [7] = true}, completed)
    end)

    it("preserves the faction tuple including header reputation and bonus flags", function()
        local faction = {
            name = "Alliance", description = "Alliance reputation", reaction = 5,
            currentReactionThreshold = 3000, nextReactionThreshold = 9000, currentStanding = 3300,
            atWarWith = false, canToggleAtWar = true, isHeader = true, isCollapsed = false,
            isHeaderWithRep = true, isWatched = false, isChild = false, factionID = 469,
            hasBonusRepGain = true, canSetInactive = false,
        }
        C_Reputation.GetFactionDataByIndex = spy.new(function() return faction end)
        C_Reputation.GetFactionDataByID = spy.new(function() return faction end)
        local expected = {
            "Alliance", "Alliance reputation", 5, 3000, 9000, 3300,
            false, true, true, false, true, false, false, 469, true, false,
        }

        assert.are.same(expected, {QuestieCompat.GetFactionInfo(1)})
        assert.are.same(expected, {QuestieCompat.GetFactionInfoByID(469)})
        assert.spy(C_Reputation.GetFactionDataByIndex).was.called_with(1)
        assert.spy(C_Reputation.GetFactionDataByID).was.called_with(469)
    end)
end)
