dofile("setupTests.lua")

describe("TrackerLine untrack click", function()
    local originals
    local tracker, compat, TrackerLine

    local function _HookableButton()
        local button = {hooks = {}}
        function button:HookScript(name, callback)
            self.hooks[name] = callback
        end
        return button
    end

    before_each(function()
        originals = {
            CreateFrame = _G.CreateFrame,
            QuestLogExFrame = _G.QuestLogExFrame,
            ClassicQuestLog = _G.ClassicQuestLog,
            QuestLogFrame = _G.QuestLogFrame,
            QuestMapFrame = _G.QuestMapFrame,
            ChatEdit_GetActiveWindow = _G.ChatEdit_GetActiveWindow,
            ChatEdit_InsertLink = _G.ChatEdit_InsertLink,
            IsShiftKeyDown = _G.IsShiftKeyDown,
            IsControlKeyDown = _G.IsControlKeyDown,
            IsAltKeyDown = _G.IsAltKeyDown,
        }
        _G.QuestLogExFrame = nil
        _G.ClassicQuestLog = nil
        _G.QuestLogFrame = nil
        _G.QuestMapFrame = {IsShown = function() return true end}
        _G.ChatEdit_GetActiveWindow = function() return nil end
        _G.CreateFrame = function(...)
            local frame = originals.CreateFrame(...)
            frame.EnableMouse = function() end
            frame.RegisterForDrag = function() end
            local createFontString = frame.CreateFontString
            frame.CreateFontString = function(...)
                local font = createFontString(...)
                font.SetJustifyH = function() end
                font.SetJustifyV = function() end
                return font
            end
            return frame
        end
        Questie.db = {profile = {trackerbindUntrack = "left"}}
        QuestieLoader:ImportModule("TrackerMenu").menuFrame = {IsShown = function() return false end}
        QuestieLoader:ImportModule("AchievementCriteriaCheckmark").New = function() return {} end
        QuestieLoader:ImportModule("ExpandZoneButton").New = function() return {} end
        QuestieLoader:ImportModule("VoiceOverPlayButton").New = _HookableButton
        QuestieLoader:ImportModule("SpokenPlayButton").New = _HookableButton
        QuestieLoader:ImportModule("TrackerUtils").IsSpokenLoaded = function() return false end
        QuestieLoader:ImportModule("ExpandQuestButton").New = _HookableButton
        QuestieLoader:ImportModule("QuestFocusButton").New = _HookableButton
        local tooltip = QuestieLoader:ImportModule("TrackerQuestTooltip")
        tooltip.Show, tooltip.Hide = spy.new(function() end), spy.new(function() end)
        local fade = QuestieLoader:ImportModule("TrackerFadeTicker")
        fade.Unfade, fade.Fade = spy.new(function() end), spy.new(function() end)
        tracker = QuestieLoader:ImportModule("QuestieTracker")
        tracker.UntrackQuestId = spy.new(function() end)
        compat = QuestieLoader:ImportModule("QuestieCompat")
        compat.QuestLog_Update = spy.new(function() end)
        QuestieLoader:ImportModule("TrackerUtils").IsTomTomAvailable = function() return false end
        dofile("Modules/Tracker/TrackerShortcuts.lua")
        dofile("Modules/Tracker/LinePool/TrackerLine.lua")
        TrackerLine = QuestieLoader:ImportModule("TrackerLine")
    end)

    after_each(function()
        _G.CreateFrame = originals.CreateFrame
        _G.QuestLogExFrame = originals.QuestLogExFrame
        _G.ClassicQuestLog = originals.ClassicQuestLog
        _G.QuestLogFrame = originals.QuestLogFrame
        _G.QuestMapFrame = originals.QuestMapFrame
        _G.ChatEdit_GetActiveWindow = originals.ChatEdit_GetActiveWindow
        _G.ChatEdit_InsertLink = originals.ChatEdit_InsertLink
        _G.IsShiftKeyDown = originals.IsShiftKeyDown
        _G.IsControlKeyDown = originals.IsControlKeyDown
        _G.IsAltKeyDown = originals.IsAltKeyDown
    end)

    local function _HoldControl()
        _G.IsControlKeyDown = function() return true end
    end

    local function _HoldShift()
        _G.IsShiftKeyDown = function() return true end
    end

    it("should highlight the quest while hovering a button in front of the title", function()
        local onEnter, onLeave = spy.new(function() end), spy.new(function() end)
        local line = TrackerLine.New(1, {}, nil, onEnter, onLeave, function() end)

        for count, button in ipairs({line.questFocus, line.playButton, line.expandQuest}) do
            button.hooks.OnEnter()
            button.hooks.OnLeave()

            assert.spy(onEnter).was.called(count)
            assert.spy(onLeave).was.called(count)
        end
        assert.spy(onEnter).was.called_with(line)
        assert.spy(onLeave).was.called_with(line)
        assert.spy(QuestieLoader:ImportModule("TrackerQuestTooltip").Show).was.not_called()
    end)

    it("shows and hides the quest tooltip without replacing hover or fade callbacks", function()
        local onEnter, onLeave = spy.new(function() end), spy.new(function() end)
        local line = TrackerLine.New(1, {}, nil, onEnter, onLeave, function() end)
        local tooltip = QuestieLoader:ImportModule("TrackerQuestTooltip")
        local fade = QuestieLoader:ImportModule("TrackerFadeTicker")

        line.scripts.OnEnter(line)
        assert.spy(onEnter).was.called_with(line)
        assert.spy(fade.Unfade).was.called(1)
        assert.spy(tooltip.Show).was.called_with(line)
        line.scripts.OnLeave(line)
        assert.spy(onLeave).was.called_with(line)
        assert.spy(fade.Fade).was.called(1)
        assert.spy(tooltip.Hide).was.called_with(line)
        line.scripts.OnHide(line)
        assert.spy(tooltip.Hide).was.called(2)
    end)

    it("links a Blizzard-only quest through its display data on Shift + Left Click while the chat input is open, over that click's shortcut", function()
        Questie.db.profile.trackerbindUntrack = "shiftleft"
        local quest = {Id = 91741, name = "Nibbled-On Book"}
        local data = QuestieLoader:ImportModule("TrackerData")
        data.GetQuestLink = spy.new(function() return "[Nibbled-On Book]" end)
        _G.ChatEdit_GetActiveWindow = function() return {} end
        _G.ChatEdit_InsertLink = spy.new(function() end)
        local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
        line:SetQuest(quest)
        line:SetOnClick("quest")
        _HoldShift()
        line.scripts.OnClick(line, "LeftButton")
        assert.spy(data.GetQuestLink).was.called_with(quest)
        assert.spy(ChatEdit_InsertLink).was.called_with("[Nibbled-On Book]")
        assert.spy(tracker.UntrackQuestId).was.not_called()
    end)

    it("untracks with the untrack shortcut instead of linking while the chat input is open", function()
        _G.ChatEdit_GetActiveWindow = function() return {} end
        _G.ChatEdit_InsertLink = spy.new(function() end)
        local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
        line:SetQuest({Id = 783})
        line:SetOnClick("quest")

        line.scripts.OnClick(line, "LeftButton")

        assert.spy(tracker.UntrackQuestId).was.called_with(tracker, 783)
        assert.spy(ChatEdit_InsertLink).was.not_called()
    end)

    it("routes ctrl-click navigation through the current-eligibility command", function()
        local utils = QuestieLoader:ImportModule("TrackerUtils")
        utils.IsTomTomAvailable = function() return true end
        Questie.db.profile.trackerbindSetTomTom = "ctrlleft"
        utils.SetQuestTomTomTarget = spy.new(function() return false end)
        local original = {Id = 100}
        local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
        line:SetQuest({Id = 100, enrichment = original})
        line:SetOnClick("quest")

        _HoldControl()
        line.scripts.OnClick(line, "LeftButton")

        assert.spy(utils.SetQuestTomTomTarget).was.called_with(100, original)
        assert.spy(tracker.UntrackQuestId).was.not_called()
    end)

    it("lets another shortcut on the TomTom click run while TomTom is not loaded", function()
        local utils = QuestieLoader:ImportModule("TrackerUtils")
        Questie.db.profile.trackerbindSetTomTom = "ctrlleft"
        Questie.db.profile.trackerbindUntrack = "ctrlleft"
        utils.SetQuestTomTomTarget = spy.new(function() return false end)
        local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
        line:SetQuest({Id = 783})
        line:SetOnClick("quest")

        _HoldControl()
        line.scripts.OnClick(line, "LeftButton")

        assert.spy(tracker.UntrackQuestId).was.called_with(tracker, 783)
        assert.spy(utils.SetQuestTomTomTarget).was.not_called()
    end)

    describe("plain and modified clicks", function()
        local utils

        before_each(function()
            utils = QuestieLoader:ImportModule("TrackerUtils")
            utils.ShowQuestLog = spy.new(function() end)
            Questie.db.profile.trackerbindUntrack = "left"
            Questie.db.profile.trackerbindOpenQuestLog = "ctrlleft"
        end)

        it("should run only the Left Click shortcut on a Left Click", function()
            local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
            line:SetQuest({Id = 783})
            line:SetOnClick("quest")

            line.scripts.OnClick(line, "LeftButton")

            assert.spy(tracker.UntrackQuestId).was.called_with(tracker, 783)
            assert.spy(utils.ShowQuestLog).was.not_called()
        end)

        it("should run only the Ctrl + Left Click shortcut on a Ctrl + Left Click, although Left Click is checked first", function()
            local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
            line:SetQuest({Id = 783})
            line:SetOnClick("quest")

            _HoldControl()
            line.scripts.OnClick(line, "LeftButton")

            assert.spy(utils.ShowQuestLog).was.called(1)
            assert.spy(tracker.UntrackQuestId).was.not_called()
        end)
    end)

    it("untracks without a legacy quest-log frame", function()
        local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
        line:SetQuest({Id = 783})
        line:SetOnClick("quest")
        line.scripts.OnClick(line, "LeftButton")
        assert.spy(tracker.UntrackQuestId).was.called_with(tracker, 783)
        assert.spy(compat.QuestLog_Update).was.not_called()
    end)

    describe("share click", function()
        local utils

        before_each(function()
            Questie.db.profile.trackerbindShareQuest = "shiftleft"
            _G.IsShiftKeyDown = function() return true end
            utils = QuestieLoader:ImportModule("TrackerUtils")
            utils.CanShareQuest = function() return true end
            utils.ShareQuest = spy.new(function() end)
            _G.ChatEdit_GetActiveWindow = function() return nil end
        end)

        it("should share the quest", function()
            local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
            line:SetQuest({Id = 783})
            line:SetOnClick("quest")

            line.scripts.OnClick(line, "LeftButton")

            assert.spy(utils.ShareQuest).was.called_with(783)
            assert.spy(tracker.UntrackQuestId).was.not_called()
        end)

        it("should do nothing when the quest can not be shared", function()
            utils.CanShareQuest = function() return false end
            local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
            line:SetQuest({Id = 783})
            line:SetOnClick("quest")

            line.scripts.OnClick(line, "LeftButton")

            assert.spy(utils.ShareQuest).was.not_called()
            assert.spy(tracker.UntrackQuestId).was.not_called()
        end)

        it("should link the quest to chat while the chat input is open", function()
            local data = QuestieLoader:ImportModule("TrackerData")
            data.GetQuestLink = function() return "[A Threat Within]" end
            _G.ChatEdit_GetActiveWindow = function() return {} end
            _G.ChatEdit_InsertLink = spy.new(function() end)
            local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
            line:SetQuest({Id = 783})
            line:SetOnClick("quest")

            line.scripts.OnClick(line, "LeftButton")

            assert.spy(ChatEdit_InsertLink).was.called_with("[A Threat Within]")
            assert.spy(utils.ShareQuest).was.not_called()
        end)
    end)

    it("should share the quest with a share shortcut without Shift, even while the chat input is open", function()
        Questie.db.profile.trackerbindShareQuest = "altleft"
        _G.IsAltKeyDown = function() return true end
        local utils = QuestieLoader:ImportModule("TrackerUtils")
        utils.CanShareQuest = function() return true end
        utils.ShareQuest = spy.new(function() end)
        _G.ChatEdit_GetActiveWindow = function() return {} end
        _G.ChatEdit_InsertLink = spy.new(function() end)
        local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
        line:SetQuest({Id = 783})
        line:SetOnClick("quest")

        line.scripts.OnClick(line, "LeftButton")

        assert.spy(utils.ShareQuest).was.called_with(783)
        assert.spy(ChatEdit_InsertLink).was.not_called()
    end)

    describe("achievement click", function()
        local achievements, originalGetAchievementLink

        before_each(function()
            achievements = QuestieLoader:ImportModule("AchievementTracking")
            achievements.IsTracked = function() return true end
            achievements.Untrack = spy.new(function() end)
            originalGetAchievementLink = _G.GetAchievementLink
            _G.GetAchievementLink = function(id) return "[Achievement " .. id .. "]" end
        end)

        after_each(function()
            _G.GetAchievementLink = originalGetAchievementLink
        end)

        it("should link the achievement on Shift + Left Click while the chat input is open, although no shortcut has that click", function()
            _G.ChatEdit_GetActiveWindow = function() return {} end
            _G.ChatEdit_InsertLink = spy.new(function() end)
            local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
            line:SetQuest({Id = 42})
            line:SetOnClick("achieve")

            _HoldShift()
            line.scripts.OnClick(line, "LeftButton")

            assert.spy(ChatEdit_InsertLink).was.called_with("[Achievement 42]")
            assert.spy(achievements.Untrack).was.not_called()
        end)
    end)

    describe("recipe click", function()
        local recipes

        before_each(function()
            recipes = QuestieLoader:ImportModule("TrackerRecipes")
            recipes.Untrack = spy.new(function() end)
            recipes.OpenRecipe = spy.new(function() end)
            recipes.GetLink = spy.new(function() return "[Charred Wolf Meat]" end)
        end)

        it("should untrack the recipe", function()
            local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
            line:SetRecipe({Id = 2538})
            line:SetOnClick("recipe")

            line.scripts.OnClick(line, "LeftButton")

            assert.spy(recipes.Untrack).was.called_with(2538)
            assert.spy(tracker.UntrackQuestId).was.not_called()
        end)

        it("should insert the recipe link into the chat on Shift + Left Click while the chat input is open", function()
            _G.ChatEdit_GetActiveWindow = function() return {} end
            _G.ChatEdit_InsertLink = spy.new(function() end)
            local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
            line:SetRecipe({Id = 2538})
            line:SetOnClick("recipe")

            _HoldShift()
            line.scripts.OnClick(line, "LeftButton")

            assert.spy(ChatEdit_InsertLink).was.called_with("[Charred Wolf Meat]")
            assert.spy(recipes.Untrack).was.not_called()
        end)

        it("should open the recipe", function()
            Questie.db.profile.trackerbindOpenQuestLog = "ctrlleft"
            local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
            line:SetRecipe({Id = 2538})
            line:SetOnClick("recipe")

            _HoldControl()
            line.scripts.OnClick(line, "LeftButton")

            assert.spy(recipes.OpenRecipe).was.called_with(2538)
            assert.spy(recipes.Untrack).was.not_called()
        end)

        it("should clear quest data when a recipe is set", function()
            local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
            line:SetQuest({Id = 783})

            line:SetRecipe({Id = 2538})

            assert.is_nil(line.Quest)
            assert.are_same({Id = 2538}, line.Recipe)
        end)

        it("should clear recipe data when a quest is set", function()
            local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
            line:SetRecipe({Id = 2538})

            line:SetQuest({Id = 783})

            assert.is_nil(line.Recipe)
        end)
    end)
end)
