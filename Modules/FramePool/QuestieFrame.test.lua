dofile("setupTests.lua")

describe("QuestieFrame", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieMap
    local QuestieMap
    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestieFrame
    local QuestieFrame

    ---@type IconFrame
    local QuestieFrameInstance

    before_each(function()
        Questie.db.profile = {
            enabled = true,
            enableMapIcons = true,
            enableMiniMapIcons = true,
            enableTurnins = true,
            enableObjectives = true,
            enableAvailable = true,
            showRepeatableQuests = true,
            showEventQuests = true,
            showDungeonQuests = true,
            showRaidQuests = true,
            showPvPQuests = true,
            enableAvailableItems = true,
            hideUnexploredMapIcons = false,
            hideUntrackedQuestsMapIcons = false,
        }

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.IsRepeatable = function() return false end
        QuestieDB.IsActiveEventQuest = function() return false end
        QuestieDB.IsDungeonQuest = function() return false end
        QuestieDB.IsRaidQuest = function() return false end
        QuestieDB.IsPvPQuest = function() return false end
        QuestieDB.IsRuneAndShouldBeHidden = function() return false end

        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.utils = {IsExplored = function() return true end}

        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.ShouldShowQuestNotes = function() return true end

        QuestieLoader:ImportModule("DailyQuests")

        dofile("Modules/FramePool/QuestieFrame.lua")
        QuestieFrame = QuestieLoader:ImportModule("QuestieFrame")
        QuestieFrameInstance = {
            data = {
                Type = "monster",
                Id = 123,
            }
        }
    end)

    describe("ShouldBeHidden", function()
        it("should return true when all icons are disabled", function()
            Questie.db.profile.enabled = false

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when frame is map icon and map icons are disabled", function()
            Questie.db.profile.enableMapIcons = false
            QuestieFrameInstance.miniMapIcon = false

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when frame is minimap icon and minimap icons are disabled", function()
            Questie.db.profile.enableMiniMapIcons = false
            QuestieFrameInstance.miniMapIcon = true

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when icon type is complete and turn in icons are disabled", function()
            Questie.db.profile.enableTurnins = false
            QuestieFrameInstance.data.Type = "complete"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when icon type is monster and objective icons are disabled", function()
            Questie.db.profile.enableObjectives = false
            QuestieFrameInstance.data.Type = "monster"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when icon type is object and objective icons are disabled", function()
            Questie.db.profile.enableObjectives = false
            QuestieFrameInstance.data.Type = "object"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when icon type is event and objective icons are disabled", function()
            Questie.db.profile.enableObjectives = false
            QuestieFrameInstance.data.Type = "event"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when icon type is item and objective icons are disabled", function()
            Questie.db.profile.enableObjectives = false
            QuestieFrameInstance.data.Type = "item"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when frame coords are unexplored and unexplored icons should be hidden", function()
            QuestieMap.utils.IsExplored = spy.new(function() return false end)
            Questie.db.profile.hideUnexploredMapIcons = true
            QuestieFrameInstance.UiMapID = 1
            QuestieFrameInstance.x = 50
            QuestieFrameInstance.y = 60

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
            assert.spy(QuestieMap.utils.IsExplored).was.called_with(QuestieMap.utils, 1, 50, 60)
        end)

        it("should return false when frame coords are explored and unexplored icons should be hidden", function()
            QuestieMap.utils.IsExplored = spy.new(function() return true end)
            Questie.db.profile.hideUnexploredMapIcons = true
            QuestieFrameInstance.UiMapID = 1
            QuestieFrameInstance.x = 50
            QuestieFrameInstance.y = 60

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
            assert.spy(QuestieMap.utils.IsExplored).was.called_with(QuestieMap.utils, 1, 50, 60)
        end)

        it("should return true when quest notes should not be shown and untracked icons should be hidden", function()
            QuestieQuest.ShouldShowQuestNotes = spy.new(function() return false end)
            Questie.db.profile.hideUntrackedQuestsMapIcons = true
            QuestieFrameInstance.data.Id = 123

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
            assert.spy(QuestieQuest.ShouldShowQuestNotes).was.called_with(QuestieQuest, 123)
        end)

        it("should return false when quest notes should be shown and untracked icons should be hidden", function()
            QuestieQuest.ShouldShowQuestNotes = spy.new(function() return true end)
            Questie.db.profile.hideUntrackedQuestsMapIcons = true
            QuestieFrameInstance.data.Id = 123

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
            assert.spy(QuestieQuest.ShouldShowQuestNotes).was.called_with(QuestieQuest, 123)
        end)

        it("should return false for available icons when untracked icons should be hidden", function()
            QuestieQuest.ShouldShowQuestNotes = spy.new(function() return false end)
            Questie.db.profile.hideUntrackedQuestsMapIcons = true
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
            assert.spy(QuestieQuest.ShouldShowQuestNotes).was.not_called()
        end)

        it("should return true when ObjectiveData is set and icons should be hidden", function()
            QuestieFrameInstance.data.ObjectiveData = {HideIcons = true}

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when QuestData is set and icons should be hidden for icons that are not complete", function()
            QuestieFrameInstance.data.Type = "monster"
            QuestieFrameInstance.data.QuestData = {HideIcons = true}

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false when QuestData is set and icons should be hidden for complete icons", function()
            QuestieFrameInstance.data.Type = "complete"
            QuestieFrameInstance.data.QuestData = {HideIcons = true}

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when available icons should be hidden", function()
            Questie.db.profile.enableAvailable = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when available icons should be hidden but quest is repeatable", function()
            QuestieDB.IsRepeatable = function() return true end
            Questie.db.profile.enableAvailable = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when repeatable icons should be hidden", function()
            QuestieDB.IsRepeatable = function() return true end
            Questie.db.profile.showRepeatableQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when repeatable icons should be hidden but quest is normal", function()
            Questie.db.profile.showRepeatableQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when event icons should be hidden", function()
            QuestieDB.IsActiveEventQuest = function() return true end
            Questie.db.profile.showEventQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when event icons should be hidden but quest is normal", function()
            Questie.db.profile.showEventQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when dungeon icons should be hidden", function()
            QuestieDB.IsDungeonQuest = function() return true end
            Questie.db.profile.showDungeonQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when dungeon icons should be hidden but quest is normal", function()
            Questie.db.profile.showDungeonQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when raid icons should be hidden", function()
            QuestieDB.IsRaidQuest = function() return true end
            Questie.db.profile.showRaidQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when raid icons should be hidden but quest is normal", function()
            Questie.db.profile.showRaidQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when PvP icons should be hidden", function()
            QuestieDB.IsPvPQuest = function() return true end
            Questie.db.profile.showPvPQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when PvP icons should be hidden but quest is normal", function()
            Questie.db.profile.showPvPQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when item drop icons should be hidden", function()
            Questie.db.profile.enableAvailableItems = false
            QuestieFrameInstance.data.Type = "available"
            QuestieFrameInstance.data.StarterType = "itemFromMonster"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when item drop icons should be hidden but quest is not started by a drop", function()
            Questie.db.profile.enableAvailableItems = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when quest is rune quest and should be hidden", function()
            Questie.IsSoD = true
            QuestieDB.IsRuneAndShouldBeHidden = function() return true end
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when not SoD", function()
            Questie.IsSoD = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)
    end)
end)
