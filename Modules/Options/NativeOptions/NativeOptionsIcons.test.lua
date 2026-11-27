dofile("setupTests.lua")

describe("native icon options", function()
    local QuestieQuest, QuestieTooltips, ActiveQuests
    local option, replacements

    local function replace(owner, key, value)
        replacements[#replacements + 1] = {owner, key, owner[key]}
        owner[key] = value
    end

    ---@param questId number
    ---@param complete number @What IsComplete returns
    ---@param derived boolean? @Whether UpdateQuest set the completion from the objectives
    local function logQuest(questId, complete, derived)
        local quest = {Id = questId, IsComplete = function() return complete end, isComplete = derived}
        ActiveQuests.Restore(questId, quest)
        return quest
    end

    before_each(function()
        replacements = {}
        replace(Questie.db, "profile", {enabled = true, hideUntrackedQuestsMapIcons = true, showUntrackedTurnInIcons = true})
        dofile("Modules/Quest/ActiveQuests.lua")
        ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
        dofile("Modules/Quest/QuestieQuest.lua")
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.ShowQuestIcons = spy.new(function() end)
        QuestieQuest.HideQuestIcons = spy.new(function() end)
        QuestieQuest.PopulateObjectiveNotes = spy.new(function() end)
        QuestieQuest.ShouldShowQuestNotes = function() return false end
        QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
        replace(QuestieTooltips, "RemoveQuest", spy.new(function() end))
        replace(QuestieLoader:ImportModule("ThreadLib"), "ThreadInstant", function(threadFunction) threadFunction() end)
        replace(QuestieLoader:ImportModule("QuestieDB"), "GetQuest", function(questId)
            local acceptance = ActiveQuests.Get(questId)
            return acceptance and acceptance.quest
        end)
        local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
        QuestieOptionsEngine.tabs = {}
        dofile("Modules/Options/QuestieOptionsDefaults.lua")
        dofile("Modules/Options/NativeOptions/NativeOptionsIcons.lua")
        option = QuestieOptionsEngine.tabs.icons:Initialize().items.icon_options_group.items.showUntrackedTurnInIconsToggle
    end)

    after_each(function()
        for index = #replacements, 1, -1 do
            local replacement = replacements[index]
            replacement[1][replacement[2]] = replacement[3]
        end
    end)

    describe("show completed turn-in icons", function()
        it("restores the notes of untracked completed quests, derived completion included", function()
            local complete = logQuest(1, 1)
            local derived = logQuest(2, 0, true)
            logQuest(3, 0)
            logQuest(4, -1, true)
            Questie.db.profile.showUntrackedTurnInIcons = false

            option.set(nil, true)

            assert.is_true(Questie.db.profile.showUntrackedTurnInIcons)
            assert.spy(QuestieQuest.ShowQuestIcons).was.called(1)
            assert.spy(QuestieQuest.PopulateObjectiveNotes).was.called(2)
            assert.spy(QuestieQuest.PopulateObjectiveNotes).was.called_with(QuestieQuest, complete)
            assert.spy(QuestieQuest.PopulateObjectiveNotes).was.called_with(QuestieQuest, derived)
        end)

        it("removes the tooltips of untracked completed quests, derived completion included", function()
            logQuest(1, 1)
            logQuest(2, 0, true)
            logQuest(3, 0)
            logQuest(4, -1, true)

            option.set(nil, false)

            assert.is_false(Questie.db.profile.showUntrackedTurnInIcons)
            assert.spy(QuestieQuest.HideQuestIcons).was.called(1)
            assert.spy(QuestieTooltips.RemoveQuest).was.called(2)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, 1)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, 2)
        end)

        it("keeps the tooltips of tracked completed quests when turned off", function()
            QuestieQuest.ShouldShowQuestNotes = function() return true end
            logQuest(1, 1)

            option.set(nil, false)

            assert.spy(QuestieTooltips.RemoveQuest).was.not_called()
        end)
    end)
end)
