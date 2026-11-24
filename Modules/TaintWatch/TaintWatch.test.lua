dofile("setupTests.lua")

describe("TaintWatch", function()
    ---@type TaintWatch
    local TaintWatch
    ---@type TaintWatchPrivate
    local _TaintWatch
    local now, taintedValues, errorHandler, eventScript, tickerCallback
    local originals = {}
    local originalDb
    local globalNames = {"issecurevariable", "geterrorhandler", "debugstack", "GetTime", "GetCVar", "C_Timer", "CreateFrame",
                         "hooksecurefunc", "WorldMapFrame", "ObjectiveTrackerFrame", "QuestFrameDetailPanel",
                         "QuestDetailScrollChildFrame", "C_AddOns", "InCombatLockdown", "ShowUIPanel", "HideUIPanel",
                         "CloseSpecialWindows"}

    before_each(function()
        for _, name in ipairs(globalNames) do
            originals[name] = _G[name]
        end
        originalDb = Questie.db
        Questie.db = {profile = {debugEnabled = true}}
        now = 100
        taintedValues = {}
        eventScript = nil
        tickerCallback = nil
        errorHandler = spy.new(function() end)

        _G.GetTime = function() return now end
        _G.GetCVar = function() return "1" end
        _G.debugstack = function() return "stack line" end
        _G.geterrorhandler = function() return errorHandler end
        _G.issecurevariable = function(tbl, key)
            local taintedBy = taintedValues[tbl] and taintedValues[tbl][key]
            return taintedBy == nil, taintedBy
        end
        _G.hooksecurefunc = function() end
        _G.C_Timer = {NewTicker = function(_, callback) tickerCallback = callback end}
        _G.CreateFrame = function()
            return {
                RegisterEvent = function() end,
                SetScript = function(_, _, script) eventScript = script end,
            }
        end
        _G.C_AddOns = {
            GetNumAddOns = function() return 2 end,
            GetAddOnInfo = function(index) return index == 1 and "Questie" or "OtherAddon" end,
            IsAddOnLoaded = function() return true end,
        }
        _G.WorldMapFrame = {ScrollContainer = {}, pinPools = {}, dataProviders = {}}
        _G.ObjectiveTrackerFrame = {}
        _G.QuestFrameDetailPanel = nil
        _G.QuestDetailScrollChildFrame = nil
        Questie.IsForever = true

        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetAddonVersionString = function() return "v1.0.0" end

        dofile("Modules/TaintWatch/TaintWatch.lua")
        TaintWatch = QuestieLoader:ImportModule("TaintWatch")
        _TaintWatch = TaintWatch.private
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do
            _G[name] = originals[name]
        end
        Questie.IsForever = nil
        Questie.db = originalDb
    end)

    describe("Note", function()
        before_each(function()
            _TaintWatch.active = true
        end)

        it("should count repeated notes within a second on one entry", function()
            TaintWatch.Note("HBD RemovePin")
            TaintWatch.Note("HBD AcquirePin")
            TaintWatch.Note("HBD RemovePin")
            TaintWatch.Note("HBD AcquirePin")

            assert.are.same(2, #_TaintWatch.notes)
            assert.are.same(2, _TaintWatch.notes[1].count)
            assert.are.same(2, _TaintWatch.notes[2].count)
        end)

        it("should add a new entry when the same note repeats after a second", function()
            TaintWatch.Note("OpenWorldMap", 1429)
            now = now + 2
            TaintWatch.Note("OpenWorldMap", 1429)

            assert.are.same(2, #_TaintWatch.notes)
        end)

        it("should add a new entry when the combat state changed", function()
            local inCombat = false
            _G.InCombatLockdown = function() return inCombat end
            TaintWatch.Note("ObjectiveTrackerFrame:Hide")
            inCombat = true
            TaintWatch.Note("ObjectiveTrackerFrame:Hide")

            assert.are.same(2, #_TaintWatch.notes)
            assert.is_false(_TaintWatch.notes[1].combat)
            assert.is_true(_TaintWatch.notes[2].combat)
        end)

        it("should keep only the last 40 notes", function()
            for i = 1, 45 do
                TaintWatch.Note("note", i)
            end

            assert.are.same(40, #_TaintWatch.notes)
            assert.are.same(6, _TaintWatch.notes[1].detail)
        end)

        it("should keep the first time of each Questie action after its notes dropped out", function()
            TaintWatch.Note("HideUIPanel WorldMapFrame")
            now = 200
            for i = 1, 45 do
                TaintWatch.Note("note", i)
            end

            local report = _TaintWatch.BuildReport("title")

            assert.truthy(report:find("First time of each Questie action this session:\n  -0.0s note 1\n  -100.0s HideUIPanel WorldMapFrame", 1, true))
        end)

        it("should not keep the first time of Blizzard events", function()
            TaintWatch.Note("[event] ShowUIPanel", "QuestFrame")

            assert.is_nil(_TaintWatch.firstActions["[event] ShowUIPanel"])
        end)
    end)

    describe("debug mode", function()
        it("should not start while debug is disabled", function()
            Questie.db.profile.debugEnabled = false

            TaintWatch.Initialize()

            assert.is_false(_TaintWatch.active)
            assert.is_nil(tickerCallback)
        end)

        it("should start when debug is enabled later", function()
            Questie.db.profile.debugEnabled = false
            TaintWatch.Initialize()
            Questie.db.profile.debugEnabled = true

            TaintWatch.Initialize()

            assert.is_true(_TaintWatch.active)
            assert.is_not_nil(tickerCallback)
        end)

        it("should not note, poll or report after debug is disabled", function()
            TaintWatch.Initialize()
            Questie.db.profile.debugEnabled = false
            taintedValues[WorldMapFrame.ScrollContainer] = {currentScale = "Questie"}

            TaintWatch.Note("OpenWorldMap", 1429)
            tickerCallback()
            eventScript(nil, "ADDON_ACTION_BLOCKED", "Questie", "Frame:SetPassThroughButtons()")

            assert.are.same(0, #_TaintWatch.notes)
            assert.are.same(0, #_TaintWatch.captures)
            assert.spy(errorHandler).was.not_called()
        end)

        it("should not note before the database exists", function()
            Questie.db = nil

            assert.has_no.errors(function() TaintWatch.Note("OpenWorldMap", 1429) end)
            assert.are.same(0, #_TaintWatch.notes)
        end)
    end)

    describe("Initialize", function()
        it("should not start outside of Forever", function()
            Questie.IsForever = false

            TaintWatch.Initialize()

            assert.is_false(_TaintWatch.active)
            assert.is_nil(tickerCallback)
        end)

        it("should report the first tainted Blizzard value with the preceding Questie actions", function()
            TaintWatch.Initialize()
            TaintWatch.Note("HBD AcquirePin")
            taintedValues[WorldMapFrame.ScrollContainer] = {currentScale = "Questie"}

            tickerCallback()

            assert.spy(errorHandler).was.called(1)
            local report = errorHandler.calls[1].vals[1]
            assert.truthy(report:find("Questie TaintWatch: ScrollContainer.currentScale was tainted by Questie", 1, true))
            assert.truthy(report:find("HBD AcquirePin", 1, true))
            assert.truthy(report:find("Other addons: OtherAddon", 1, true))
        end)

        it("should report each tainted value only once", function()
            TaintWatch.Initialize()
            taintedValues[WorldMapFrame.ScrollContainer] = {currentScale = "Questie"}

            tickerCallback()
            tickerCallback()

            assert.spy(errorHandler).was.called(1)
            assert.are.same(1, #_TaintWatch.captures)
        end)

        it("should not mention BugGrabber in the report, as BugGrabber would only print it to the chat", function()
            _G.C_AddOns.GetAddOnInfo = function(index) return index == 1 and "Questie" or "!BugGrabber" end
            TaintWatch.Initialize()
            taintedValues[WorldMapFrame.ScrollContainer] = {currentScale = "Questie"}

            tickerCallback()

            assert.spy(errorHandler).was.called(1)
            local report = errorHandler.calls[1].vals[1]
            assert.is_nil(report:find("BugGrabber", 1, true))
            assert.truthy(report:find("!Bug Grabber", 1, true))
        end)

        it("should not report secure values", function()
            TaintWatch.Initialize()

            tickerCallback()

            assert.spy(errorHandler).was.not_called()
        end)

        it("should keep Questie's taint when other addons tainted more values before", function()
            TaintWatch.Initialize()
            taintedValues[WorldMapFrame] = {}
            for _, key in ipairs({"mapID", "pinPools", "pinSuppressionDirty", "pinNudgingDirty", "pinPostProcessDirty", "pinsToNudge"}) do
                taintedValues[WorldMapFrame][key] = "OtherAddon"
            end
            tickerCallback()
            taintedValues[WorldMapFrame.ScrollContainer] = {currentScale = "Questie"}

            tickerCallback()

            assert.spy(errorHandler).was.called(1)
            assert.are.same(1, #_TaintWatch.captures)
            assert.are.same("ScrollContainer.currentScale", _TaintWatch.captures[1].label)
            local report = errorHandler.calls[1].vals[1]
            assert.truthy(report:find("Also tainted: -0.0s WorldMapFrame.mapID by OtherAddon", 1, true))
        end)

        it("should capture Questie's taint of a value that another addon tainted before", function()
            TaintWatch.Initialize()
            taintedValues[WorldMapFrame.ScrollContainer] = {currentScale = "OtherAddon"}
            tickerCallback()
            taintedValues[WorldMapFrame.ScrollContainer] = {currentScale = "Questie"}

            tickerCallback()

            assert.spy(errorHandler).was.called(1)
            assert.are.same(1, #_TaintWatch.captures)
        end)
    end)

    describe("events", function()
        before_each(function()
            TaintWatch.Initialize()
        end)

        it("should report a blocked action of Questie once", function()
            eventScript(nil, "ADDON_ACTION_BLOCKED", "Questie", "Frame:SetPassThroughButtons()")
            eventScript(nil, "ADDON_ACTION_BLOCKED", "Questie", "Frame:SetPassThroughButtons()")

            assert.spy(errorHandler).was.called(1)
            local report = errorHandler.calls[1].vals[1]
            assert.truthy(report:find("ADDON_ACTION_BLOCKED Frame:SetPassThroughButtons()", 1, true))
        end)

        it("should ignore blocked actions of other addons", function()
            eventScript(nil, "ADDON_ACTION_FORBIDDEN", "OtherAddon", "CopyToClipboard()")

            assert.spy(errorHandler).was.not_called()
        end)

        it("should report a Lua warning that mentions Questie once", function()
            eventScript(nil, "LUA_WARNING", 0, "GetAuraDataByIndex(): Auras cannot be accessed when secret while tainted by 'Questie'")
            eventScript(nil, "LUA_WARNING", 0, "GetAuraDataByIndex(): Auras cannot be accessed when secret while tainted by 'Questie'")

            assert.spy(errorHandler).was.called(1)
        end)

        it("should note Blizzard events as breadcrumbs", function()
            eventScript(nil, "PLAYER_REGEN_DISABLED")
            eventScript(nil, "QUEST_ACCEPTED", 6134)

            assert.are.same(2, #_TaintWatch.notes)
            assert.are.same("[event] PLAYER_REGEN_DISABLED", _TaintWatch.notes[1].label)
            assert.are.same("[event] QUEST_ACCEPTED", _TaintWatch.notes[2].label)
            assert.are.same(6134, _TaintWatch.notes[2].detail)
        end)

        it("should ignore Lua warnings of other addons", function()
            eventScript(nil, "LUA_WARNING", "script ran too long in OtherAddon")

            assert.spy(errorHandler).was.not_called()
        end)

        it("should report a Lua warning that only has the warning text", function()
            eventScript(nil, "LUA_WARNING", "LUA_WARNING: tainted by 'Questie'")

            assert.spy(errorHandler).was.called(1)
        end)
    end)

    describe("managed frame containers", function()
        it("should report a managed frame container that Questie tainted", function()
            _G.RightManagedFrameContainer = {showingFrames = {}}
            TaintWatch.Initialize()
            taintedValues[_G.RightManagedFrameContainer] = {showingFrames = "Questie"}

            tickerCallback()

            assert.spy(errorHandler).was.called(1)
            local report = errorHandler.calls[1].vals[1]
            assert.truthy(report:find("RightManagedFrameContainer.showingFrames was tainted by Questie", 1, true))
            _G.RightManagedFrameContainer = nil
        end)
    end)

    describe("quest details", function()
        it("should report a quest details value that Questie tainted", function()
            _G.QuestMapFrame = {DetailsFrame = {}}
            TaintWatch.Initialize()
            taintedValues[_G.QuestMapFrame.DetailsFrame] = {questID = "Questie"}

            tickerCallback()

            assert.spy(errorHandler).was.called(1)
            local report = errorHandler.calls[1].vals[1]
            assert.truthy(report:find("QuestMapFrame.DetailsFrame.questID was tainted by Questie", 1, true))
            _G.QuestMapFrame = nil
        end)

        it("should not fail when the quest map frame does not exist", function()
            _G.QuestMapFrame = nil
            TaintWatch.Initialize()

            assert.has_no.errors(function() tickerCallback() end)
        end)
    end)

    describe("hooks", function()
        it("should note when the world map is shown and hidden", function()
            local scripts = {}
            WorldMapFrame.HookScript = function(_, name, script) scripts[name] = script end
            TaintWatch.Initialize()

            scripts.OnShow()
            scripts.OnHide()

            assert.are.same("[event] WorldMap shown", _TaintWatch.notes[1].label)
            assert.are.same("[event] WorldMap hidden", _TaintWatch.notes[2].label)
        end)

        it("should note when Blizzard's panel manager shows or hides a panel, or Escape closes the open windows", function()
            local hooks = {}
            _G.hooksecurefunc = function(functionName, hook) hooks[functionName] = hook end
            _G.ShowUIPanel, _G.HideUIPanel, _G.CloseSpecialWindows = function() end, function() end, function() end
            TaintWatch.Initialize()
            local questFrame = {GetName = function() return "QuestFrame" end, IsForbidden = function() return false end}

            hooks.ShowUIPanel(questFrame)
            hooks.HideUIPanel(questFrame)
            hooks.CloseSpecialWindows()

            assert.are.same({"[event] ShowUIPanel", "QuestFrame"}, {_TaintWatch.notes[1].label, _TaintWatch.notes[1].detail})
            assert.are.same({"[event] HideUIPanel", "QuestFrame"}, {_TaintWatch.notes[2].label, _TaintWatch.notes[2].detail})
            assert.are.same("[event] CloseSpecialWindows", _TaintWatch.notes[3].label)
            assert.is_nil(_TaintWatch.notes[3].detail)
        end)

        it("should not read the name of a forbidden panel", function()
            local hooks = {}
            _G.hooksecurefunc = function(functionName, hook) hooks[functionName] = hook end
            _G.ShowUIPanel = function() end
            TaintWatch.Initialize()
            local forbiddenFrame = {GetName = spy.new(function() end), IsForbidden = function() return true end}

            hooks.ShowUIPanel(forbiddenFrame)

            assert.spy(forbiddenFrame.GetName).was.not_called()
            assert.is_nil(_TaintWatch.notes[1].detail)
        end)

        it("should not build a stack for a capture that would be discarded", function()
            local hooks = {}
            _G.hooksecurefunc = function(tbl, method, hook) hooks[method] = {tbl = tbl, hook = hook} end
            _G.debugstack = spy.new(function() return "stack line" end)
            WorldMapFrame.ScrollContainer.MarkCanvasDirty = function() end
            TaintWatch.Initialize()
            taintedValues[WorldMapFrame.ScrollContainer] = {currentScale = "Questie"}

            hooks.MarkCanvasDirty.hook(WorldMapFrame.ScrollContainer)
            hooks.MarkCanvasDirty.hook(WorldMapFrame.ScrollContainer)

            assert.spy(_G.debugstack).was.called(1)
        end)

        it("should not build a stack when the slots for other addons are full", function()
            local hooks = {}
            _G.hooksecurefunc = function(tbl, method, hook) hooks[method] = {tbl = tbl, hook = hook} end
            _G.debugstack = spy.new(function() return "stack line" end)
            WorldMapFrame.ScrollContainer.MarkCanvasDirty = function() end
            TaintWatch.Initialize()
            for i = 1, 5 do
                _TaintWatch.Capture("other" .. i, "OtherAddon", nil)
            end
            taintedValues[WorldMapFrame.ScrollContainer] = {currentScale = "OtherAddon"}

            hooks.MarkCanvasDirty.hook(WorldMapFrame.ScrollContainer)

            assert.spy(_G.debugstack).was.not_called()
        end)
        it("should report the stack when Blizzard code writes a tainted value", function()
            local hooks = {}
            _G.hooksecurefunc = function(tbl, method, hook) hooks[method] = {tbl = tbl, hook = hook} end
            WorldMapFrame.ScrollContainer.MarkCanvasDirty = function() end
            TaintWatch.Initialize()
            taintedValues[WorldMapFrame.ScrollContainer] = {currentScale = "Questie"}

            hooks.MarkCanvasDirty.hook(WorldMapFrame.ScrollContainer)

            assert.spy(errorHandler).was.called(1)
            local report = errorHandler.calls[1].vals[1]
            assert.truthy(report:find("ScrollContainer.currentScale was tainted by Questie", 1, true))
            assert.truthy(report:find("stack line", 1, true))
        end)
    end)
end)
