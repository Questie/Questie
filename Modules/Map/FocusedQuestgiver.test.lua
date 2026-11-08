dofile("setupTests.lua")
dofile("Localization/l10n.lua")

describe("FocusedQuestgiver", function()
    ---@type FocusedQuestgiver
    local FocusedQuestgiver
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieMap
    local QuestieMap

    local MANUAL_TYPE = "questgiver"

    before_each(function()
        Questie.db.profile.trackerShowQuestGiverOnFocus = true
        Questie.db.profile.availableScale = 1.2
        Questie.icons = {available = "available-icon"}
        Questie.Colorize = function(_, str) return str end

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuest = function() return nil end

        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.ShowNPC = spy.new(function() end)
        QuestieMap.ShowObject = spy.new(function() end)
        QuestieMap.UnloadManualFrames = spy.new(function() end)

        dofile("Modules/Map/FocusedQuestgiver.lua")
        FocusedQuestgiver = QuestieLoader:ImportModule("FocusedQuestgiver")
    end)

    describe("Show", function()
        it("should draw the quest giver NPCs of the quest on the map", function()
            QuestieDB.GetQuest = function()
                return {Id = 42, name = "Test Quest", Starts = {NPC = {100, 101}}}
            end

            FocusedQuestgiver.Show(42)

            assert.spy(QuestieMap.ShowNPC).was.called(2)
            assert.spy(QuestieMap.ShowNPC).was.called_with(QuestieMap, 100, "available-icon", 1.2, "Test Quest\nQuest Giver", nil, true, MANUAL_TYPE)
            assert.spy(QuestieMap.ShowNPC).was.called_with(QuestieMap, 101, "available-icon", 1.2, "Test Quest\nQuest Giver", nil, true, MANUAL_TYPE)
            assert.spy(QuestieMap.ShowObject).was.not_called()
        end)

        it("should draw quest giver game objects of the quest on the map", function()
            QuestieDB.GetQuest = function()
                return {Id = 42, name = "Test Quest", Starts = {GameObject = {200}}}
            end

            FocusedQuestgiver.Show(42)

            assert.spy(QuestieMap.ShowObject).was.called(1)
            assert.spy(QuestieMap.ShowObject).was.called_with(QuestieMap, 200, "available-icon", 1.2, "Test Quest\nQuest Giver", nil, true, MANUAL_TYPE)
            assert.spy(QuestieMap.ShowNPC).was.not_called()
        end)

        it("should not draw anything when the setting is disabled", function()
            Questie.db.profile.trackerShowQuestGiverOnFocus = false
            QuestieDB.GetQuest = function()
                return {Id = 42, name = "Test Quest", Starts = {NPC = {100}}}
            end

            FocusedQuestgiver.Show(42)

            assert.spy(QuestieMap.ShowNPC).was.not_called()
            assert.spy(QuestieMap.ShowObject).was.not_called()
        end)

        it("should do nothing when the quest is not in the database", function()
            QuestieDB.GetQuest = function() return nil end

            FocusedQuestgiver.Show(42)

            assert.spy(QuestieMap.ShowNPC).was.not_called()
            assert.spy(QuestieMap.ShowObject).was.not_called()
        end)

        it("should not draw starters for a quest without a Starts table", function()
            QuestieDB.GetQuest = function()
                return {Id = 42, name = "Test Quest"}
            end

            FocusedQuestgiver.Show(42)

            assert.spy(QuestieMap.ShowNPC).was.not_called()
            assert.spy(QuestieMap.ShowObject).was.not_called()
        end)

        it("should clear the previously shown quest giver before drawing a new one", function()
            QuestieDB.GetQuest = function()
                return {Id = 1, name = "First", Starts = {NPC = {100}}}
            end
            FocusedQuestgiver.Show(1)

            QuestieDB.GetQuest = function()
                return {Id = 2, name = "Second", Starts = {NPC = {200}}}
            end
            FocusedQuestgiver.Show(2)

            -- The NPC from the first quest must be unloaded when the second quest is focused.
            assert.spy(QuestieMap.UnloadManualFrames).was.called_with(QuestieMap, 100, MANUAL_TYPE)
        end)
    end)

    describe("Hide", function()
        it("should unload all starters drawn by the previous Show call", function()
            QuestieDB.GetQuest = function()
                return {Id = 42, name = "Test Quest", Starts = {NPC = {100}, GameObject = {200}}}
            end
            FocusedQuestgiver.Show(42)

            FocusedQuestgiver.Hide()

            assert.spy(QuestieMap.UnloadManualFrames).was.called_with(QuestieMap, 100, MANUAL_TYPE)
            assert.spy(QuestieMap.UnloadManualFrames).was.called_with(QuestieMap, 200, MANUAL_TYPE)
        end)

        it("should not unload anything when nothing was shown", function()
            FocusedQuestgiver.Hide()

            assert.spy(QuestieMap.UnloadManualFrames).was.not_called()
        end)

        it("should not unload the same starters twice on repeated Hide calls", function()
            QuestieDB.GetQuest = function()
                return {Id = 42, name = "Test Quest", Starts = {NPC = {100}}}
            end
            FocusedQuestgiver.Show(42)

            FocusedQuestgiver.Hide()
            FocusedQuestgiver.Hide()

            assert.spy(QuestieMap.UnloadManualFrames).was.called(1)
        end)
    end)
end)
