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

    local originalGlobals
    local questLogApis = {"GetQuestLogIndexByID", "SelectQuestLogEntry", "SetAbandonQuest", "AbandonQuest"}

    before_each(function()
        originalGlobals = {}
        for _, name in ipairs(questLogApis) do originalGlobals[name] = _G[name] end
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

    after_each(function()
        for _, name in ipairs(questLogApis) do _G[name] = originalGlobals[name] end
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

        local actions = {}
        local selectedIndex
        _G.GetQuestLogIndexByID = spy.new(function() return 7 end)
        _G.SelectQuestLogEntry = function(index)
            selectedIndex = index
            table.insert(actions, {"select", index})
        end
        _G.SetAbandonQuest = function() table.insert(actions, {"prepare", selectedIndex}) end
        _G.AbandonQuest = function() table.insert(actions, {"abandon", selectedIndex}) end

        BreadcrumbQuests.CheckAllQuestBreadcrumbs()

        assert.spy(_G.GetQuestLogIndexByID).was.called_with(QUEST_ID)
        assert.are_same({{"select", 7}, {"prepare", 7}, {"abandon", 7}}, actions)
        assert.are.same({QUEST_ID, 103}, linkedQuestIds)
    end)

    it("should ignore an incomplete breadcrumb whose exclusive quest is complete", function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = true
        Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = true
        Questie.db.char.complete[999] = true
        QuestieDB.QueryQuestSingle = function(id, key)
            if id == QUEST_ID and key == "breadcrumbs" then return {101} end
            if id == 101 and key == "exclusiveTo" then return {999} end
        end
        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.HasRequiredClass = function() return true end
        QuestieAnnounce.IncompleteBreadcrumbQuest = spy.new(function() end)
        _G.AbandonQuest = spy.new(function() end)

        BreadcrumbQuests.CheckQuestBreadcrumbs(QUEST_ID)

        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.not_called()
        assert.spy(_G.AbandonQuest).was.not_called()
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