dofile("setupTests.lua")
local match = require("luassert.match")

describe("TrackerQuestTooltip", function()
    local TrackerQuestTooltip, QuestieTooltips
    local saved, quests, tooltip, tickers, nativeAvailable, nativeProgress
    local setNativeProgress, getNativeProgress

    local function _Line(mode, id)
        local quest = {Id = id or 783}
        quests[quest.Id] = quest
        return {
            mode = mode or "quest", Quest = quest, visible = true, mouseOver = true,
            IsVisible = function(self) return self.visible end,
            IsMouseOver = function(self) return self.mouseOver end,
        }
    end

    before_each(function()
        saved = {
            CreateFrame = _G.CreateFrame, C_TooltipInfo = _G.C_TooltipInfo, C_Timer = _G.C_Timer,
            GameTooltip = _G.GameTooltip, IsInGroup = _G.IsInGroup, IsForever = Questie.IsForever,
            enableTooltips = Questie.db.profile.enableTooltips, trackerEnabled = Questie.db.profile.trackerEnabled,
        }
        Questie.db.profile.enableTooltips, Questie.db.profile.trackerEnabled = true, true
        quests, tickers = {}, {}
        nativeAvailable, nativeProgress = true, {completed = false}
        setNativeProgress = spy.new(function(self)
            self.visible, self.progress = nativeAvailable, nativeProgress
            return nativeAvailable
        end)
        getNativeProgress = spy.new(function() error("must use the secure tooltip accessor") end)
        tooltip = {
            SetOwner = spy.new(function() end),
            Hide = spy.new(function(self) self.visible = false end),
            SetQuestPartyProgress = function(...) return setNativeProgress(...) end,
            GetPrimaryTooltipData = function() error("must not inspect native progress") end,
        }
        _G.CreateFrame = spy.new(function() return tooltip end)
        _G.GameTooltip = {Hide = spy.new(function() end), SetOwner = spy.new(function() end)}
        _G.C_TooltipInfo = {
            GetQuestPartyProgress = function(...) return getNativeProgress(...) end,
        }
        _G.C_Timer = {NewTicker = spy.new(function(interval, callback)
            local ticker = {interval = interval, callback = callback}
            ticker.Cancel = spy.new(function(self) self.cancelled = true end)
            tickers[#tickers + 1] = ticker
            return ticker
        end)}
        QuestieLoader:ImportModule("TrackerData").GetQuest = function(id) return quests[id] end
        QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
        QuestieTooltips.RegisterNativeQuestTooltip = spy.new(function() end)
        dofile("Modules/Tracker/TrackerQuestTooltip.lua")
        TrackerQuestTooltip = QuestieLoader:ImportModule("TrackerQuestTooltip")
    end)

    after_each(function()
        TrackerQuestTooltip.Hide()
        _G.CreateFrame, _G.C_TooltipInfo, _G.C_Timer = saved.CreateFrame, saved.C_TooltipInfo, saved.C_Timer
        _G.GameTooltip, _G.IsInGroup, Questie.IsForever = saved.GameTooltip, saved.IsInGroup, saved.IsForever
        Questie.db.profile.enableTooltips, Questie.db.profile.trackerEnabled = saved.enableTooltips, saved.trackerEnabled
    end)

    it("does nothing without the native API namespace or function", function()
        local line = _Line()
        _G.C_TooltipInfo = nil
        TrackerQuestTooltip.Show(line)
        _G.C_TooltipInfo = {}
        TrackerQuestTooltip.Show(line)
        assert.spy(CreateFrame).was.not_called()
        assert.spy(C_Timer.NewTicker).was.not_called()
    end)

    it("does nothing when the tooltip template lacks the native accessor", function()
        tooltip.SetQuestPartyProgress = nil
        TrackerQuestTooltip.Show(_Line())
        assert.spy(C_Timer.NewTicker).was.not_called()
        assert.is_false(tooltip.visible)
    end)

    it("respects disabled tooltips and a disabled tracker", function()
        local line = _Line()
        Questie.db.profile.enableTooltips = false
        TrackerQuestTooltip.Show(line)
        Questie.db.profile.enableTooltips, Questie.db.profile.trackerEnabled = true, false
        TrackerQuestTooltip.Show(line)
        assert.spy(CreateFrame).was.not_called()
    end)

    it("includes the title and active player for title and objective hovers, solo or grouped", function()
        for _, grouped in ipairs({false, true}) do
            _G.IsInGroup = function() return grouped end
            for _, mode in ipairs({"quest", "objective"}) do
                local line = _Line(mode)
                TrackerQuestTooltip.Show(line)
                assert.spy(tooltip.SetOwner).was.called_with(match.is_ref(tooltip), match.is_ref(line), "ANCHOR_CURSOR")
            end
        end
        assert.spy(setNativeProgress).was.called(4)
        assert.spy(setNativeProgress).was.called_with(match.is_ref(tooltip), 783, false, false)
        assert.spy(getNativeProgress).was.not_called()
    end)

    it("uses capabilities rather than an expansion flag", function()
        Questie.IsForever = false
        TrackerQuestTooltip.Show(_Line())
        assert.spy(setNativeProgress).was.called(1)
    end)

    it("reuses one dedicated tooltip without changing the global item tooltip", function()
        TrackerQuestTooltip.Show(_Line())
        TrackerQuestTooltip.Hide()
        TrackerQuestTooltip.Show(_Line("objective", 784))
        assert.spy(CreateFrame).was.called(1)
        assert.spy(CreateFrame).was.called_with("GameTooltip", "QuestieTrackerQuestTooltip", UIParent, "GameTooltipTemplate")
        assert.spy(QuestieTooltips.RegisterNativeQuestTooltip).was.called_with(match.is_ref(tooltip))
        assert.spy(QuestieTooltips.RegisterNativeQuestTooltip).was.called(1)
        assert.spy(GameTooltip.Hide).was.not_called()
        assert.spy(GameTooltip.SetOwner).was.not_called()
    end)

    it("refreshes native progress and completion every half second while hovered", function()
        TrackerQuestTooltip.Show(_Line())
        assert.are.equal(0.5, tickers[1].interval)
        nativeProgress = {completed = true, text = "Ready for turn-in"}
        tickers[1].callback()
        assert.spy(setNativeProgress).was.called(2)
        assert.are.equal(nativeProgress, tooltip.progress)
    end)

    it("hides missing native data and retries rather than leaving stale progress", function()
        TrackerQuestTooltip.Show(_Line())
        nativeAvailable = false
        tickers[1].callback()
        assert.is_false(tooltip.visible)
        assert.is_nil(tickers[1].cancelled)
        nativeAvailable = true
        tickers[1].callback()
        assert.is_true(tooltip.visible)
    end)

    it("also recovers when data is absent on the first hover", function()
        nativeAvailable = false
        TrackerQuestTooltip.Show(_Line())
        assert.is_false(tooltip.visible)
        nativeAvailable = true
        tickers[1].callback()
        assert.is_true(tooltip.visible)
    end)

    it("excludes headers, scenarios, recipes and achievement ID collisions", function()
        for _, mode in ipairs({"zone", "achieve", "scenario"}) do
            TrackerQuestTooltip.Show(_Line(mode))
        end
        local recipe = _Line()
        recipe.Quest, recipe.Recipe = nil, {Id = 783}
        TrackerQuestTooltip.Show(recipe)
        local achievement = _Line("objective")
        achievement.Quest = {Id = 783}
        TrackerQuestTooltip.Show(achievement)
        assert.spy(CreateFrame).was.not_called()
    end)

    it("stops when the quest is removed or its display record is replaced", function()
        local line = _Line()
        TrackerQuestTooltip.Show(line)
        quests[783] = {Id = 783}
        tickers[1].callback()
        assert.is_true(tickers[1].cancelled)
        assert.is_false(tooltip.visible)
        assert.spy(setNativeProgress).was.called(1)
        line = _Line()
        TrackerQuestTooltip.Show(line)
        quests[783] = nil
        tickers[2].callback()
        assert.is_true(tickers[2].cancelled)
        assert.is_false(tooltip.visible)
    end)

    it("follows a recycled row's current quest instead of capturing the old ID", function()
        local line = _Line()
        TrackerQuestTooltip.Show(line)
        line.Quest = {Id = 784}
        quests[784] = line.Quest
        tickers[1].callback()
        assert.spy(setNativeProgress).was.called_with(match.is_ref(tooltip), 784, false, false)
        line.mode = "zone"
        tickers[1].callback()
        assert.is_true(tickers[1].cancelled)
        assert.is_false(tooltip.visible)
    end)

    it("stops refreshing when the mouse leaves, the row hides or tooltips are disabled", function()
        for _, change in ipairs({
            function(line) line.mouseOver = false end,
            function(line) line.visible = false end,
            function() Questie.db.profile.enableTooltips = false end,
            function() _G.C_TooltipInfo = nil end,
        }) do
            Questie.db.profile.enableTooltips = true
            _G.C_TooltipInfo = {GetQuestPartyProgress = function() end}
            local line = _Line()
            TrackerQuestTooltip.Show(line)
            local ticker = tickers[#tickers]
            change(line)
            ticker.callback()
            assert.is_true(ticker.cancelled)
            assert.is_false(tooltip.visible)
        end
    end)

    it("does not start a refresh loop for a hidden or unhovered row", function()
        local line = _Line()
        line.visible = false
        TrackerQuestTooltip.Show(line)
        line.visible, line.mouseOver = true, false
        TrackerQuestTooltip.Show(line)
        assert.spy(C_Timer.NewTicker).was.not_called()
    end)

    it("cancels the old hover and ignores a late leave from another line", function()
        local first, second = _Line(), _Line("objective", 784)
        TrackerQuestTooltip.Show(first)
        TrackerQuestTooltip.Show(second)
        assert.is_true(tickers[1].cancelled)
        TrackerQuestTooltip.Hide(first)
        assert.is_nil(tickers[2].cancelled)
        assert.is_true(tooltip.visible)
        TrackerQuestTooltip.Hide(second)
        assert.is_true(tickers[2].cancelled)
        assert.is_false(tooltip.visible)
    end)
end)
