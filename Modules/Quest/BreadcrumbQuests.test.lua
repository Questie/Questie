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
end)