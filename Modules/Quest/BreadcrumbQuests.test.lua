dofile("setupTests.lua")
dofile("Localization/l10n.lua")

local QUEST_ID = 123

describe("BreadcrumbQuests", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieAnnounce
    local QuestieAnnounce
    ---@type BreadcrumbQuests
    local BreadcrumbQuests

    before_each(function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = false
        Questie.db.profile.autoAccept = {enabled = false}
        Questie.db.char.complete = {}

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QueryQuestSingle = function() return nil end
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.currentQuestlog = {}
        QuestieAnnounce = QuestieLoader:ImportModule("QuestieAnnounce")

        dofile("Modules/Quest/BreadcrumbQuests.lua")
        BreadcrumbQuests = QuestieLoader:ImportModule("BreadcrumbQuests")
    end)

    it("should do nothing for quests without breadcrumbs", function()
        Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = true
        QuestiePlayer.currentQuestlog = {[QUEST_ID] = {}}

        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.HasRequiredClass = function() return true end

        local abandonCalls = 0
        _G.GetQuestLogIndexByID = function() return 1 end
        _G.SelectQuestLogEntry = function() end
        _G.SetAbandonQuest = function() end
        _G.AbandonQuest = function() abandonCalls = abandonCalls + 1 end

        BreadcrumbQuests.CheckQuestBreadcrumbs(QUEST_ID)

        assert.are.equal(0, abandonCalls)
    end)

    it("should abandon the quest only once using the last incomplete breadcrumb when it has multiple", function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = false
        Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = true
        Questie.db.char.complete = {}
        QuestiePlayer.currentQuestlog = {[QUEST_ID] = {}}

        QuestieDB.QueryQuestSingle = spy.new(function(questId, key)
            if questId == QUEST_ID and key == "breadcrumbs" then
                return {101, 102, 103}
            end
            return nil
        end)
        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.HasRequiredClass = function() return true end

        local linkedQuestIds = {}
        QuestieLoader:ImportModule("QuestieLink").GetQuestHyperLink = function(...)
            for i = 1, select("#", ...) do
                local arg = select(i, ...)
                if type(arg) ~= "table" then
                    table.insert(linkedQuestIds, arg)
                end
            end
            return "link"
        end

        local abandonCalls = 0
        _G.GetQuestLogIndexByID = function(questId) return questId == QUEST_ID and 1 or 0 end
        _G.SelectQuestLogEntry = function() end
        _G.SetAbandonQuest = function() end
        _G.AbandonQuest = function() abandonCalls = abandonCalls + 1 end

        BreadcrumbQuests.CheckAllQuestBreadcrumbs()

        assert.are.equal(1, abandonCalls)
        assert.are.same({QUEST_ID, 103}, linkedQuestIds)
    end)

    it("should announce every incomplete breadcrumb", function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = true
        Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = false
        Questie.db.char.complete = {}
        QuestiePlayer.currentQuestlog = {[QUEST_ID] = {}}

        QuestieDB.QueryQuestSingle = spy.new(function(questId, key)
            if questId == QUEST_ID and key == "breadcrumbs" then
                return {101, 102, 103}
            end
            return nil
        end)
        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.HasRequiredClass = function() return true end
        QuestieAnnounce.IncompleteBreadcrumbQuest = spy.new(function() end)

        BreadcrumbQuests.CheckAllQuestBreadcrumbs()

        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.called(3)
        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.called_with(QUEST_ID, 101)
        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.called_with(QUEST_ID, 102)
        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.called_with(QUEST_ID, 103)
    end)
end)