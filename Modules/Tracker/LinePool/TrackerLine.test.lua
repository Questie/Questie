dofile("setupTests.lua")

describe("TrackerLine untrack click", function()
    local originals
    local tracker, compat, TrackerLine

    before_each(function()
        originals = {
            CreateFrame = _G.CreateFrame,
            IsModifiedClick = _G.IsModifiedClick,
            QuestLogExFrame = _G.QuestLogExFrame,
            ClassicQuestLog = _G.ClassicQuestLog,
            QuestLogFrame = _G.QuestLogFrame,
            QuestMapFrame = _G.QuestMapFrame,
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
        QuestieLoader:ImportModule("VoiceOverPlayButton").New = function() return {} end
        QuestieLoader:ImportModule("ExpandQuestButton").New = function() return {} end
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
    end)

    it("untracks without a legacy quest-log frame", function()
        local line = TrackerLine.New(1, {}, nil, function() end, function() end, function() end)
        line:SetQuest({Id = 783})
        line:SetOnClick("quest")
        line.scripts.OnClick(line, "LeftButton")
        assert.spy(tracker.UntrackQuestId).was.called_with(tracker, 783)
        assert.spy(compat.QuestLog_Update).was.not_called()
    end)
end)
