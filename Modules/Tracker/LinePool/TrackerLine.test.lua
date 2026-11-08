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
            IsModifiedClick = _G.IsModifiedClick,
            QuestLogExFrame = _G.QuestLogExFrame,
            ClassicQuestLog = _G.ClassicQuestLog,
            QuestLogFrame = _G.QuestLogFrame,
            QuestMapFrame = _G.QuestMapFrame,
            ChatEdit_InsertLink = _G.ChatEdit_InsertLink,
            ChatFrame_OpenChat = _G.ChatFrame_OpenChat,
            GetAchievementLink = _G.GetAchievementLink,
        }
        _G.QuestLogExFrame = nil
        _G.ClassicQuestLog = nil
        _G.QuestLogFrame = nil
        _G.QuestMapFrame = {IsShown = function() return true end}
        _G.IsModifiedClick = function() return false end
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
        Questie.db = {profile = {trackerbindUntrack = "untrack"}}
        QuestieLoader:ImportModule("TrackerMenu").menuFrame = {IsShown = function() return false end}
        QuestieLoader:ImportModule("TrackerUtils").IsBindTrue = function(_, binding)
            return binding == "untrack"
        end
        QuestieLoader:ImportModule("AchievementCriteriaCheckmark").New = function() return {} end
        QuestieLoader:ImportModule("ExpandZoneButton").New = function() return {} end
        QuestieLoader:ImportModule("VoiceOverPlayButton").New = _HookableButton
        QuestieLoader:ImportModule("SpokenPlayButton").New = _HookableButton
        QuestieLoader:ImportModule("TrackerUtils").IsSpokenLoaded = function() return false end
        QuestieLoader:ImportModule("ExpandQuestButton").New = _HookableButton
        QuestieLoader:ImportModule("QuestFocusButton").New = _HookableButton
        tracker = QuestieLoader:ImportModule("QuestieTracker")
        tracker.UntrackQuestId = spy.new(function() end)
        compat = QuestieLoader:ImportModule("QuestieCompat")
        compat.QuestLog_Update = spy.new(function() end)
        dofile("Modules/Tracker/LinePool/TrackerLine.lua")
        TrackerLine = QuestieLoader:ImportModule("TrackerLine")
    end)

    after_each(function()
        _G.CreateFrame = originals.CreateFrame
        _G.IsModifiedClick = originals.IsModifiedClick
        _G.QuestLogExFrame = originals.QuestLogExFrame
        _G.ClassicQuestLog = originals.ClassicQuestLog
        _G.QuestLogFrame = originals.QuestLogFrame
        _G.QuestMapFrame = originals.QuestMapFrame
        _G.ChatEdit_InsertLink = originals.ChatEdit_InsertLink
        _G.ChatFrame_OpenChat = originals.ChatFrame_OpenChat
        _G.GetAchievementLink = originals.GetAchievementLink
    end)

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
    end)

    it("links a Blizzard-only quest through its display data", function()
        local quest = {Id = 91741, name = "Nibbled-On Book"}
        local data = QuestieLoader:ImportModule("TrackerData")
        data.GetQuestLink = spy.new(function() return "[Nibbled-On Book]" end)
        _G.IsModifiedClick = function() return true end
        _G.ChatEdit_InsertLink = spy.new(function() return true end)
        _G.ChatFrame_OpenChat = spy.new(function() end)
        local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
        line:SetQuest(quest)
        line:SetOnClick("quest")
        line.scripts.OnClick(line, "LeftButton")
        assert.spy(data.GetQuestLink).was.called_with(quest)
        assert.spy(ChatEdit_InsertLink).was.called_with("[Nibbled-On Book]")
        assert.spy(ChatFrame_OpenChat).was.not_called()
        assert.spy(tracker.UntrackQuestId).was.not_called()
    end)

    it("opens the chat input box with the quest link when shift-clicking without an active chat input box", function()
        local data = QuestieLoader:ImportModule("TrackerData")
        data.GetQuestLink = function() return "[Nibbled-On Book]" end
        _G.IsModifiedClick = function(action) return action == "CHATLINK" end
        _G.ChatEdit_InsertLink = spy.new(function() return false end)
        _G.ChatFrame_OpenChat = spy.new(function() end)
        local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
        line:SetQuest({Id = 91741})
        line:SetOnClick("quest")

        line.scripts.OnClick(line, "LeftButton")

        assert.spy(ChatFrame_OpenChat).was.called_with("[Nibbled-On Book]")
        assert.spy(tracker.UntrackQuestId).was.not_called()
    end)

    it("links instead of running a shortcut that is also bound to shift-click", function()
        local utils = QuestieLoader:ImportModule("TrackerUtils")
        utils.IsBindTrue = function() return true end
        utils.SetQuestTomTomTarget = spy.new(function() end)
        local data = QuestieLoader:ImportModule("TrackerData")
        data.GetQuestLink = function() return "[Nibbled-On Book]" end
        _G.IsModifiedClick = function() return true end
        _G.ChatEdit_InsertLink = spy.new(function() return true end)
        local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
        line:SetQuest({Id = 91741})
        line:SetOnClick("quest")

        line.scripts.OnClick(line, "LeftButton")

        assert.spy(ChatEdit_InsertLink).was.called_with("[Nibbled-On Book]")
        assert.spy(utils.SetQuestTomTomTarget).was.not_called()
        assert.spy(tracker.UntrackQuestId).was.not_called()
    end)

    it("does not link on shift + right click", function()
        _G.IsModifiedClick = function() return true end
        _G.ChatEdit_InsertLink = spy.new(function() return true end)
        local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
        line:SetQuest({Id = 783})
        line:SetOnClick("quest")

        line.scripts.OnClick(line, "RightButton")

        assert.spy(ChatEdit_InsertLink).was.not_called()
    end)

    it("routes ctrl-click navigation through the current-eligibility command", function()
        local utils = QuestieLoader:ImportModule("TrackerUtils")
        Questie.db.profile.trackerbindSetTomTom = "tomtom"
        utils.IsBindTrue = function(_, binding) return binding == "tomtom" end
        utils.SetQuestTomTomTarget = spy.new(function() return false end)
        local original = {Id = 100}
        local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
        line:SetQuest({Id = 100, enrichment = original})
        line:SetOnClick("quest")

        line.scripts.OnClick(line, "LeftButton")

        assert.spy(utils.SetQuestTomTomTarget).was.called_with(100, original)
        assert.spy(tracker.UntrackQuestId).was.not_called()
    end)

    it("untracks without a legacy quest-log frame", function()
        local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
        line:SetQuest({Id = 783})
        line:SetOnClick("quest")
        line.scripts.OnClick(line, "LeftButton")
        assert.spy(tracker.UntrackQuestId).was.called_with(tracker, 783)
        assert.spy(compat.QuestLog_Update).was.not_called()
    end)

    it("inserts the achievement link into the active chat input box when shift-clicking", function()
        _G.IsModifiedClick = function(action) return action == "CHATLINK" end
        _G.GetAchievementLink = spy.new(function() return "[Explore Elwynn Forest]" end)
        _G.ChatEdit_InsertLink = spy.new(function() return true end)
        _G.ChatFrame_OpenChat = spy.new(function() end)
        local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
        line:SetQuest({Id = 776})
        line:SetOnClick("achieve")

        line.scripts.OnClick(line, "LeftButton")

        assert.spy(GetAchievementLink).was.called_with(776)
        assert.spy(ChatEdit_InsertLink).was.called_with("[Explore Elwynn Forest]")
        assert.spy(ChatFrame_OpenChat).was.not_called()
    end)

    it("opens the chat input box with the achievement link when shift-clicking without an active chat input box", function()
        _G.IsModifiedClick = function(action) return action == "CHATLINK" end
        _G.GetAchievementLink = spy.new(function() return "[Explore Elwynn Forest]" end)
        _G.ChatEdit_InsertLink = function() return false end
        _G.ChatFrame_OpenChat = spy.new(function() end)
        local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
        line:SetQuest({Id = 776})
        line:SetOnClick("achieve")

        line.scripts.OnClick(line, "LeftButton")

        assert.spy(GetAchievementLink).was.called_with(776)
        assert.spy(ChatFrame_OpenChat).was.called_with("[Explore Elwynn Forest]")
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

        it("should insert the recipe link into the chat", function()
            _G.IsModifiedClick = function() return true end
            _G.ChatEdit_InsertLink = spy.new(function() return true end)
            local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
            line:SetRecipe({Id = 2538})
            line:SetOnClick("recipe")

            line.scripts.OnClick(line, "LeftButton")

            assert.spy(ChatEdit_InsertLink).was.called_with("[Charred Wolf Meat]")
            assert.spy(recipes.Untrack).was.not_called()
        end)

        it("should open the chat input box with the recipe link when no chat input box is active", function()
            _G.IsModifiedClick = function() return true end
            _G.ChatEdit_InsertLink = function() return false end
            _G.ChatFrame_OpenChat = spy.new(function() end)
            local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
            line:SetRecipe({Id = 2538})
            line:SetOnClick("recipe")

            line.scripts.OnClick(line, "LeftButton")

            assert.spy(ChatFrame_OpenChat).was.called_with("[Charred Wolf Meat]")
            assert.spy(recipes.Untrack).was.not_called()
        end)

        it("should open the recipe", function()
            Questie.db.profile.trackerbindOpenQuestLog = "open"
            QuestieLoader:ImportModule("TrackerUtils").IsBindTrue = function(_, binding) return binding == "open" end
            local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
            line:SetRecipe({Id = 2538})
            line:SetOnClick("recipe")

            line.scripts.OnClick(line, "LeftButton")

            assert.spy(recipes.OpenRecipe).was.called_with(2538)
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
