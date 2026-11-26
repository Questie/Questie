dofile("setupTests.lua")
local match = require("luassert.match")

describe("TrackerQuestTooltip", function()
    local TrackerQuestTooltip, QuestieTooltips
    local saved, quests, tooltip, tickers, nativeAvailable, nativeProgress
    local setNativeProgress, getNativeProgress, pool, canShare

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
        _G.IsInGroup = function() return true end
        pool = {}
        local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
        saved.GetHighestIndex, saved.GetLine = TrackerLinePool.GetHighestIndex, TrackerLinePool.GetLine
        TrackerLinePool.GetHighestIndex = function() return #pool end
        TrackerLinePool.GetLine = function(i) return pool[i] end
        nativeAvailable, nativeProgress = true, {completed = false}
        setNativeProgress = spy.new(function(self)
            self.visible, self.progress = nativeAvailable, nativeProgress
            return nativeAvailable
        end)
        getNativeProgress = spy.new(function() return nil end)
        canShare = false
        saved.Colorize = Questie.Colorize
        Questie.Colorize = function(_, text, color) return color .. ":" .. text end
        local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        saved.CanShareQuest = TrackerUtils.CanShareQuest
        TrackerUtils.CanShareQuest = function() return canShare end
        Questie.db.profile.trackerbindShareQuest = "shiftleft"
        tooltip = {
            SetOwner = spy.new(function() end),
            SetPoint = spy.new(function() end),
            SetText = spy.new(function(self) self.visible = true end),
            AddLine = spy.new(function() end),
            Show = spy.new(function(self) self.visible = true end),
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
        local TrackerData = QuestieLoader:ImportModule("TrackerData")
        TrackerData.GetQuest = function(id) return quests[id] end
        saved.GetColoredQuestName = TrackerData.GetColoredQuestName
        TrackerData.GetColoredQuestName = function(quest) return "Quest " .. quest.Id end
        dofile("Localization/l10n.lua")
        QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
        QuestieTooltips.RegisterNativeQuestTooltip = spy.new(function() end)
        dofile("Modules/Tooltips/Forever.lua")
        dofile("Modules/Tracker/TrackerQuestTooltip.lua")
        TrackerQuestTooltip = QuestieLoader:ImportModule("TrackerQuestTooltip")
    end)

    after_each(function()
        TrackerQuestTooltip.Hide()
        local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
        TrackerLinePool.GetHighestIndex, TrackerLinePool.GetLine = saved.GetHighestIndex, saved.GetLine
        QuestieLoader:ImportModule("TrackerUtils").CanShareQuest = saved.CanShareQuest
        Questie.Colorize = saved.Colorize
        QuestieLoader:ImportModule("TrackerData").GetColoredQuestName = saved.GetColoredQuestName
        _G.CreateFrame, _G.C_TooltipInfo, _G.C_Timer = saved.CreateFrame, saved.C_TooltipInfo, saved.C_Timer
        _G.GameTooltip, _G.IsInGroup, Questie.IsForever = saved.GameTooltip, saved.IsInGroup, saved.IsForever
        Questie.db.profile.enableTooltips, Questie.db.profile.trackerEnabled = saved.enableTooltips, saved.trackerEnabled
    end)

    it("should do nothing without the native API namespace or function when the quest can not be shared", function()
        local line = _Line()
        _G.C_TooltipInfo = nil
        TrackerQuestTooltip.Show(line)
        _G.C_TooltipInfo = {}
        TrackerQuestTooltip.Show(line)
        assert.spy(CreateFrame).was.not_called()
        assert.spy(C_Timer.NewTicker).was.not_called()
    end)

    it("should do nothing when the tooltip template lacks the native accessor and the quest can not be shared", function()
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

    it("should not show when not in a party", function()
        _G.IsInGroup = function() return false end
        TrackerQuestTooltip.Show(_Line())
        assert.spy(CreateFrame).was.not_called()
        assert.spy(C_Timer.NewTicker).was.not_called()
    end)

    it("should anchor above the quest title line when hovering an objective", function()
        local objective = _Line("objective")
        local otherTitle = _Line("quest", 999)
        local titleLine = _Line("quest")
        titleLine.Quest = objective.Quest
        quests[783] = objective.Quest
        pool = {otherTitle, objective, titleLine}
        TrackerQuestTooltip.Show(objective)
        assert.spy(tooltip.SetOwner).was.called(1)
        assert.spy(tooltip.SetOwner).was.called_with(match.is_ref(tooltip), match.is_ref(titleLine), "ANCHOR_NONE")
        assert.spy(tooltip.SetPoint).was.called_with(match.is_ref(tooltip), "BOTTOMLEFT", match.is_ref(titleLine), "TOPLEFT")
        assert.spy(setNativeProgress).was.called_with(match.is_ref(tooltip), 783, false, false)
    end)

    it("should anchor above the hovered title line", function()
        local line = _Line("quest")
        pool = {line}
        TrackerQuestTooltip.Show(line)
        assert.spy(tooltip.SetPoint).was.called_with(match.is_ref(tooltip), "BOTTOMLEFT", match.is_ref(line), "TOPLEFT")
    end)

    it("should fall back to the hovered line when no title line is visible", function()
        local objective = _Line("objective")
        pool = {objective}
        TrackerQuestTooltip.Show(objective)
        assert.spy(tooltip.SetOwner).was.called_with(match.is_ref(tooltip), match.is_ref(objective), "ANCHOR_NONE")
    end)

    it("should hide the tooltip on refresh after leaving the party", function()
        TrackerQuestTooltip.Show(_Line())
        _G.IsInGroup = function() return false end
        tickers[1].callback()
        assert.is_false(tooltip.visible)
        assert.is_true(tickers[1].cancelled)
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

    it("should add the share hint below the party progress when the quest can be shared", function()
        canShare = true

        TrackerQuestTooltip.Show(_Line())

        assert.spy(setNativeProgress).was.called(1)
        assert.spy(tooltip.AddLine).was.called_with(match.is_ref(tooltip), "gray:(Shift + Left Click: Share Quest)")
        assert.spy(tooltip.Show).was.called(1)
    end)

    it("should resize the tooltip after rendering the party progress without a share hint", function()
        TrackerQuestTooltip.Show(_Line())

        assert.spy(tooltip.Show).was.called(1)
    end)

    it("should show a grey note instead of the share hint when the quest can not be shared", function()
        TrackerQuestTooltip.Show(_Line())

        assert.spy(tooltip.AddLine).was.called(1)
        assert.spy(tooltip.AddLine).was.called_with(match.is_ref(tooltip), "gray:(Quest can't be shared)")
    end)


    it("should not add the share hint when the share shortcut is disabled", function()
        canShare = true
        Questie.db.profile.trackerbindShareQuest = "disabled"

        TrackerQuestTooltip.Show(_Line())

        assert.spy(tooltip.AddLine).was.not_called()
    end)

    it("should show the share hint with the configured shortcut", function()
        canShare = true
        Questie.db.profile.trackerbindShareQuest = "altright"

        TrackerQuestTooltip.Show(_Line())

        assert.spy(tooltip.AddLine).was.called_with(match.is_ref(tooltip), "gray:(Alt + Right Click: Share Quest)")
    end)

    it("should show the quest title with the share hint without the native party progress", function()
        _G.C_TooltipInfo = nil
        canShare = true
        local line = _Line()

        TrackerQuestTooltip.Show(line)

        assert.spy(tooltip.SetPoint).was.called_with(match.is_ref(tooltip), "BOTTOMLEFT", match.is_ref(line), "TOPLEFT")
        assert.spy(tooltip.SetText).was.called_with(match.is_ref(tooltip), "Quest 783")
        assert.spy(tooltip.AddLine).was.called_with(match.is_ref(tooltip), "gray:(Shift + Left Click: Share Quest)")
        assert.is_true(tooltip.visible)
        assert.spy(setNativeProgress).was.not_called()
    end)

    it("should hide the share-only tooltip when the quest can no longer be shared", function()
        _G.C_TooltipInfo = nil
        canShare = true
        TrackerQuestTooltip.Show(_Line())

        canShare = false
        tickers[1].callback()

        assert.is_false(tooltip.visible)
        assert.is_true(tickers[1].cancelled)
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

    describe("party rows", function()
        local saved2

        local function _Rows(members)
            local lines = {}
            for _, member in ipairs(members) do
                lines[#lines + 1] = {type = 18, leftText = member.name, guid = member.guid or member.name}
                for _, objective in ipairs(member.rows) do
                    lines[#lines + 1] = {
                        type = 8, leftText = objective.text, numFulfilled = objective.fulfilled,
                        numRequired = objective.required, completed = objective.completed,
                    }
                end
            end
            return {lines = lines}
        end

        local function _Added()
            local added = {}
            for _, call in ipairs(tooltip.AddLine.calls) do
                added[#added + 1] = call.vals[2]
            end
            return added
        end

        before_each(function()
            saved2 = {
                Enum = _G.Enum, GetPlayerInfoByGUID = _G.GetPlayerInfoByGUID, UnitGUID = _G.UnitGUID,
                OnQuest = _G.QUEST_PROGRESS_TOOLTIP_QUEST_ON_QUEST, GetClassColor = Questie.GetClassColor,
                GetRGBForObjective = QuestieLoader:ImportModule("QuestieLib").GetRGBForObjective,
            }
            _G.Enum = {TooltipDataLineType = {QuestPlayer = 18, QuestObjective = 8}}
            _G.GetPlayerInfoByGUID = function(guid) return "Class", guid == "Crux" and "MAGE" or "ROGUE" end
            _G.UnitGUID = function() return "Crux" end
            _G.QUEST_PROGRESS_TOOLTIP_QUEST_ON_QUEST = "On quest"
            Questie.GetClassColor = function(_, class) return class == "MAGE" and "|cM" or "|cR" end
            QuestieLoader:ImportModule("QuestieLib").GetRGBForObjective = function(_, counters)
                return counters.fulfilled == counters.required and "|cG" or "|cO"
            end
            canShare = true
            quests[783] = {Id = 783, IsComplete = function() return 0 end}
        end)

        after_each(function()
            _G.Enum, _G.GetPlayerInfoByGUID, _G.UnitGUID = saved2.Enum, saved2.GetPlayerInfoByGUID, saved2.UnitGUID
            _G.QUEST_PROGRESS_TOOLTIP_QUEST_ON_QUEST, Questie.GetClassColor = saved2.OnQuest, saved2.GetClassColor
            QuestieLoader:ImportModule("QuestieLib").GetRGBForObjective = saved2.GetRGBForObjective
        end)

        local function _Show(data)
            getNativeProgress = spy.new(function() return data end)
            local line = _Line()
            quests[783] = {Id = 783, IsComplete = function() return 0 end}
            line.Quest = quests[783]
            TrackerQuestTooltip.Show(line)
        end

        it("should list the objectives of all members grouped by objective, the player first", function()
            _Show(_Rows({
                {name = "Crux", guid = "Crux", rows = {{text = "8/8 A", fulfilled = 8, required = 8}, {text = "1/4 B", fulfilled = 1, required = 4}}},
                {name = "Cheeq", rows = {{text = "3/8 A", fulfilled = 3, required = 8}, {text = "2/4 B", fulfilled = 2, required = 4}}},
            }))

            assert.spy(tooltip.SetText).was.called_with(match.is_ref(tooltip), "Quest 783")
            assert.are.same({
                "   |cG8/8 A|r (|cMCrux|r)",
                "   |cO3/8 A|r (|cRCheeq|r)",
                "   |cO1/4 B|r (|cMCrux|r)",
                "   |cO2/4 B|r (|cRCheeq|r)",
                "gray:(Shift + Left Click: Share Quest)",
            }, _Added())
            assert.spy(setNativeProgress).was.not_called()
        end)

        it("should show one complete row for members on the quest without objectives or ready to turn in", function()
            _Show(_Rows({
                {name = "Crux", guid = "Crux", rows = {{text = "Ready for turn-in", completed = true}}},
                {name = "Cheeq", rows = {{text = "3/8 A", fulfilled = 3, required = 8}}},
                {name = "Kiyoko", rows = {{text = "On quest"}}},
            }))

            assert.are.same({
                "   28FF28:Quest Complete! (|cMCrux|r)",
                "   28FF28:Quest Complete! (|cRKiyoko|r)",
                "   |cO3/8 A|r (|cRCheeq|r)",
                "gray:(Shift + Left Click: Share Quest)",
            }, _Added())
        end)

        it("should treat the player as complete when Questie says so", function()
            local data = _Rows({{name = "Crux", guid = "Crux", rows = {{text = "3/8 A", fulfilled = 3, required = 8}}}})
            getNativeProgress = spy.new(function() return data end)
            local line = _Line()
            quests[783].IsComplete = function() return 1 end
            line.Quest = quests[783]

            TrackerQuestTooltip.Show(line)

            assert.are.same({
                "   28FF28:Quest Complete! (|cMCrux|r)",
                "gray:(Shift + Left Click: Share Quest)",
            }, _Added())
        end)

        it("should fall back to the native rendering when the client has no On quest string", function()
            _G.QUEST_PROGRESS_TOOLTIP_QUEST_ON_QUEST = nil
            _Show(_Rows({{name = "Crux", guid = "Crux", rows = {{text = "On quest"}}}}))

            assert.spy(setNativeProgress).was.called(1)
        end)

        it("should fall back to the native rendering when the party data is not readable", function()
            _Show(nil)

            assert.spy(setNativeProgress).was.called(1)
        end)
    end)
end)
