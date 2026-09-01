dofile("setupTests.lua")

describe("QuestieQuest", function()
    ---@type QuestieQuest
    local QuestieQuest
    ---@type AvailableQuests
    local AvailableQuests
    ---@type ZoneDB
    local ZoneDB
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieMap
    local QuestieMap
    ---@type QuestLogCache
    local QuestLogCache
    ---@type QuestieCombatQueue
    local QuestieCombatQueue
    ---@type CommsVisibility
    local CommsVisibility
    ---@type ThreadLib
    local ThreadLib
    ---@type l10n
    local l10n

    local function _CreateQuestIcon(miniMapIcon, hidden, shouldBeHidden)
        local icon = {
            data = {
                ObjectiveIndex = 1,
                QuestData = {FadeIcons = false},
                Type = "available",
            },
            hidden = hidden,
            miniMapIcon = miniMapIcon,
        }
        icon.ShouldBeHidden = spy.new(function() return shouldBeHidden end)
        icon.FakeShow = spy.new(function(self) self.hidden = false end)
        icon.FakeHide = spy.new(function(self) self.hidden = true end)
        icon.FadeIn = spy.new(function() end)
        icon.FadeOut = spy.new(function() end)
        return icon
    end

    before_each(function()
        Questie.db.char = {}
        ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.GetDungeons = function() return {} end
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuest = spy.new(function() return {} end)
        AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
        AvailableQuests.CalculateAndDrawAll = spy.new(function() end)
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.currentQuestlog = {}
        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
        QuestieCombatQueue.Queue = function() end
        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        CommsVisibility.ScheduleSnapshot = spy.new(function() end)
        ThreadLib = QuestieLoader:ImportModule("ThreadLib")
        ThreadLib.ThreadInstant = function(callback) callback() end
        l10n = QuestieLoader:ImportModule("l10n")
        setmetatable(l10n, {__call = function(_, key, ...) return key end})

        dofile("Modules/Quest/QuestieQuest.lua")
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
    end)

    after_each(function()
        _G.QuestieTestMapQuestIcon = nil
        _G.QuestieTestMinimapQuestIcon = nil
    end)

    describe("UnhideQuest", function()
        it("should unhide a quest", function()
            local questId = 123
            Questie.db.char = {hidden = {[questId] = true}}
            QuestieQuest.PopulateObjectiveNotes = spy.new(function() end)

            QuestieQuest:UnhideQuest(questId)

            assert.is_nil(Questie.db.char.hidden[questId])
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called()
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.called()
            assert.spy(QuestieDB.GetQuest).was.not_called()
            assert.spy(QuestieQuest.PopulateObjectiveNotes).was.not_called()
        end)

        it("should unhide a quest that is in the quest log", function()
            local questId = 123
            Questie.db.char = {hidden = {[questId] = true}}
            QuestiePlayer.currentQuestlog[questId] = true
            QuestieQuest.PopulateObjectiveNotes = spy.new(function() end)

            QuestieQuest:UnhideQuest(questId)

            assert.is_nil(Questie.db.char.hidden[questId])
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called()
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.not_called()
            assert.spy(QuestieDB.GetQuest).was.called_with(123)
            assert.spy(QuestieQuest.PopulateObjectiveNotes).was.called_with(QuestieQuest, {})
        end)
    end)

    describe("ShowQuestIcons", function()
        it("should not throw an error when called from a coroutine", function()
            QuestieMap.questIdFrames = {}

            local co = coroutine.create(function()
                QuestieQuest:ShowQuestIcons()
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieQuest:ShowQuestIcons()
            end, "ShowQuestIcons must be called from a coroutine")
        end)

        it("should show only quest icons on the selected map surface", function()
            local mapIcon = _CreateQuestIcon(false, true, false)
            local minimapIcon = _CreateQuestIcon(true, true, false)
            _G.QuestieTestMapQuestIcon = mapIcon
            _G.QuestieTestMinimapQuestIcon = minimapIcon
            QuestieMap.questIdFrames = {
                [123] = {"QuestieTestMapQuestIcon", "QuestieTestMinimapQuestIcon"},
            }

            local co = coroutine.create(function()
                QuestieQuest:ShowQuestIcons(false)
            end)

            assert.is_true(coroutine.resume(co))
            assert.spy(mapIcon.FakeShow).was.called()
            assert.spy(mapIcon.FadeIn).was.called()
            assert.spy(minimapIcon.ShouldBeHidden).was.not_called()
            assert.spy(minimapIcon.FakeShow).was.not_called()
            assert.spy(minimapIcon.FadeIn).was.not_called()
        end)
    end)

    describe("HideQuestIcons", function()
        it("should not throw an error when called from a coroutine", function()
            QuestieMap.questIdFrames = {}

            local co = coroutine.create(function()
                QuestieQuest:HideQuestIcons()
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieQuest:HideQuestIcons()
            end, "HideQuestIcons must be called from a coroutine")
        end)

        it("should hide only quest icons on the selected map surface", function()
            local mapIcon = _CreateQuestIcon(false, false, true)
            local minimapIcon = _CreateQuestIcon(true, false, true)
            _G.QuestieTestMapQuestIcon = mapIcon
            _G.QuestieTestMinimapQuestIcon = minimapIcon
            QuestieMap.questIdFrames = {
                [123] = {"QuestieTestMapQuestIcon", "QuestieTestMinimapQuestIcon"},
            }

            local co = coroutine.create(function()
                QuestieQuest:HideQuestIcons(true)
            end)

            assert.is_true(coroutine.resume(co))
            assert.spy(mapIcon.ShouldBeHidden).was.not_called()
            assert.spy(mapIcon.FakeHide).was.not_called()
            assert.spy(mapIcon.FadeIn).was.not_called()
            assert.spy(minimapIcon.FakeHide).was.called()
            assert.spy(minimapIcon.FadeIn).was.called()
        end)
    end)

    describe("manual icon visibility", function()
        local mapIcon
        local minimapIcon

        before_each(function()
            Questie.db.profile = {
                enabled = true,
                enableMapIcons = true,
                enableMiniMapIcons = false,
            }

            mapIcon = {
                hidden = false,
                miniMapIcon = false,
            }
            mapIcon.FakeShow = spy.new(function(self) self.hidden = false end)
            mapIcon.FakeHide = spy.new(function(self) self.hidden = true end)

            minimapIcon = {
                hidden = false,
                miniMapIcon = true,
            }
            minimapIcon.FakeShow = spy.new(function(self) self.hidden = false end)
            minimapIcon.FakeHide = spy.new(function(self) self.hidden = true end)

            _G.QuestieTestMapIcon = mapIcon
            _G.QuestieTestMinimapIcon = minimapIcon
            QuestieMap.manualFrames = {
                any = {
                    [1] = {"QuestieTestMapIcon", "QuestieTestMinimapIcon"},
                },
            }
        end)

        after_each(function()
            _G.QuestieTestMapIcon = nil
            _G.QuestieTestMinimapIcon = nil
        end)

        it("should show manual icons only on enabled map surfaces", function()
            mapIcon.hidden = true
            minimapIcon.hidden = true

            QuestieQuest.private:ShowManualIcons(false)

            assert.spy(mapIcon.FakeShow).was.called()
            assert.spy(minimapIcon.FakeShow).was.not_called()
        end)

        it("should hide manual icons only on disabled map surfaces", function()
            QuestieQuest.private:HideManualIcons(true)

            assert.spy(mapIcon.FakeHide).was.not_called()
            assert.spy(minimapIcon.FakeHide).was.called()
        end)

        it("should hide manual icons on both surfaces without a surface filter", function()
            QuestieQuest.private:HideManualIcons()

            assert.spy(mapIcon.FakeHide).was.called()
            assert.spy(minimapIcon.FakeHide).was.called()
        end)

        it("should restore only enabled manual icon surfaces without a surface filter", function()
            mapIcon.hidden = true
            minimapIcon.hidden = true

            QuestieQuest.private:ShowManualIcons()

            assert.spy(mapIcon.FakeShow).was.called()
            assert.spy(minimapIcon.FakeShow).was.not_called()
        end)

        it("should not restore manual icons while Questie icons are disabled globally", function()
            Questie.db.profile.enabled = false
            mapIcon.hidden = true
            minimapIcon.hidden = true

            QuestieQuest.private:ShowManualIcons()

            assert.spy(mapIcon.FakeShow).was.not_called()
            assert.spy(minimapIcon.FakeShow).was.not_called()
        end)

        it("should show minimap manual icons without showing world map manual icons", function()
            Questie.db.profile.enableMapIcons = false
            Questie.db.profile.enableMiniMapIcons = true
            mapIcon.hidden = true
            minimapIcon.hidden = true

            QuestieQuest.private:ShowManualIcons(true)

            assert.spy(mapIcon.FakeShow).was.not_called()
            assert.spy(minimapIcon.FakeShow).was.called()
        end)

        it("should hide world map manual icons without hiding minimap manual icons", function()
            Questie.db.profile.enableMapIcons = false
            Questie.db.profile.enableMiniMapIcons = true

            QuestieQuest.private:HideManualIcons(false)

            assert.spy(mapIcon.FakeHide).was.called()
            assert.spy(minimapIcon.FakeHide).was.not_called()
        end)
    end)

    describe("ToggleNotes", function()
        before_each(function()
            QuestieQuest.GetAllQuestIds = spy.new(function() end)
            QuestieQuest.ShowQuestIcons = spy.new(function() end)
            QuestieQuest.HideQuestIcons = spy.new(function() end)
            QuestieQuest.private.ShowManualIcons = spy.new(function() end)
            QuestieQuest.private.HideManualIcons = spy.new(function() end)
        end)

        it("should forward the minimap filter when showing notes", function()
            QuestieQuest:ToggleNotes(true, true)

            assert.spy(QuestieQuest.ShowQuestIcons).was.called_with(QuestieQuest, true)
            assert.spy(QuestieQuest.private.ShowManualIcons).was.called_with(QuestieQuest.private, true)
            assert.spy(QuestieQuest.HideQuestIcons).was.not_called()
            assert.spy(QuestieQuest.private.HideManualIcons).was.not_called()
        end)

        it("should forward the world map filter when hiding notes", function()
            QuestieQuest:ToggleNotes(false, false)

            assert.spy(QuestieQuest.HideQuestIcons).was.called_with(QuestieQuest, false)
            assert.spy(QuestieQuest.private.HideManualIcons).was.called_with(QuestieQuest.private, false)
            assert.spy(QuestieQuest.ShowQuestIcons).was.not_called()
            assert.spy(QuestieQuest.private.ShowManualIcons).was.not_called()
        end)
    end)

    describe("GetAllQuestIds", function()
        it("should not throw an error when called from a coroutine", function()
            QuestLogCache.questLog_DO_NOT_MODIFY = {}

            local co = coroutine.create(function()
                QuestieQuest:GetAllQuestIds()
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieQuest:GetAllQuestIds()
            end, "GetAllQuestIds must be called from a coroutine")
        end)
    end)

    describe("PopulateObjective", function()
        it("should not throw an error when called from a coroutine", function()
            local quest = {ObjectiveData = {}}
            local objective = {Description = "test"}

            local co = coroutine.create(function()
                QuestieQuest:PopulateObjective(quest, 1, objective, false)
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieQuest:PopulateObjective({}, 1, {Description = "test"}, false)
            end, "PopulateObjective must be called from a coroutine")
        end)
    end)

    describe("RegisterObjectiveTooltips", function()
        before_each(function()
            QuestieQuest.private.objectiveSpawnListCallTable = {}
        end)

        it("should not crash when objectives have nil spawnList (guard against nil in next())", function()
            -- The bug was that RegisterObjectiveTooltips called next(objective.spawnList) without checking if spawnList was nil first
            -- This should complete without error (not crash on "bad argument #1 to next")
            local quest = {
                Id = 123,
                Objectives = {},
                SpecialObjectives = {},
                ObjectiveData = {}
            }

            -- Should not throw an error
            QuestieQuest.RegisterObjectiveTooltips(quest)
            assert.is_true(true)
        end)

        it("should not crash when special objectives have nil spawnList", function()
            -- Same check for SpecialObjectives path
            local quest = {
                Id = 123,
                Objectives = {},
                SpecialObjectives = {},
                ObjectiveData = {}
            }

            -- Should not throw an error
            QuestieQuest.RegisterObjectiveTooltips(quest)
            assert.is_true(true)
        end)

        it("should assign Index to regular objectives if not already set", function()
            local quest = {
                Id = 123,
                Objectives = {
                    [1] = {Description = "Objective 1", spawnList = {}},
                    [5] = {Description = "Objective 5", spawnList = {}},
                },
                SpecialObjectives = {},
                ObjectiveData = {}
            }

            assert.is_nil(quest.Objectives[1].Index)
            assert.is_nil(quest.Objectives[5].Index)

            QuestieQuest.RegisterObjectiveTooltips(quest)

            assert.are_equal(1, quest.Objectives[1].Index)
            assert.are_equal(5, quest.Objectives[5].Index)
        end)

        it("should assign Index to special objectives (64 + loop index) before processing", function()
            local quest = {
                Id = 123,
                Objectives = {},
                SpecialObjectives = {
                    {Description = "Special 1", spawnList = {}},
                    {Description = "Special 2", spawnList = {}},
                },
                ObjectiveData = {}
            }

            assert.is_nil(quest.SpecialObjectives[1].Index)
            assert.is_nil(quest.SpecialObjectives[2].Index)

            QuestieQuest.RegisterObjectiveTooltips(quest)

            assert.are_equal(65, quest.SpecialObjectives[1].Index) -- 64 + 1
            assert.are_equal(66, quest.SpecialObjectives[2].Index) -- 64 + 2
        end)
    end)
end)
