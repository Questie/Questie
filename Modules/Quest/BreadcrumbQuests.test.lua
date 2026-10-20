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
        Questie.db.profile.autoAccept = {enabled = false, abandonBreadcrumbFollowup = false}
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

    it("should do nothing when all breadcrumbs are completed", function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = true
        Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = true
        Questie.db.char.complete = {[101] = true, [102] = true}
        QuestiePlayer.currentQuestlog = {[QUEST_ID] = {}}

        QuestieDB.QueryQuestSingle = spy.new(function(questId, key)
            if questId == QUEST_ID and key == "breadcrumbs" then
                return {101, 102}
            end
            return nil
        end)
        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.HasRequiredClass = function() return true end
        QuestieAnnounce.IncompleteBreadcrumbQuest = spy.new(function() end)

        local abandonCalls = 0
        _G.GetQuestLogIndexByID = function() return 1 end
        _G.SelectQuestLogEntry = function() end
        _G.SetAbandonQuest = function() end
        _G.AbandonQuest = function() abandonCalls = abandonCalls + 1 end

        BreadcrumbQuests.CheckQuestBreadcrumbs(QUEST_ID)

        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.not_called()
        assert.are.equal(0, abandonCalls)
    end)

    it("should announce every incomplete breadcrumb when quest is newly accepted", function()
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

        BreadcrumbQuests.CheckQuestBreadcrumbs(QUEST_ID)

        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.called(3)
        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.called_with(QUEST_ID, 101)
        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.called_with(QUEST_ID, 102)
        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.called_with(QUEST_ID, 103)
    end)

    it("should NOT announce when questAnnounceIncompleteBreadcrumb is disabled", function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = false
        Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = false
        Questie.db.char.complete = {}
        QuestiePlayer.currentQuestlog = {[QUEST_ID] = {}}

        QuestieDB.QueryQuestSingle = spy.new(function(questId, key)
            if questId == QUEST_ID and key == "breadcrumbs" then
                return {101, 102}
            end
            return nil
        end)
        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.HasRequiredClass = function() return true end
        QuestieAnnounce.IncompleteBreadcrumbQuest = spy.new(function() end)

        BreadcrumbQuests.CheckQuestBreadcrumbs(QUEST_ID)

        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.not_called()
    end)

    it("should abandon the quest using the last incomplete breadcrumb", function()
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

        BreadcrumbQuests.CheckQuestBreadcrumbs(QUEST_ID)

        assert.are.equal(1, abandonCalls)
        assert.are.same({QUEST_ID, 103}, linkedQuestIds)
    end)

    it("should not abandon when autoAccept.abandonBreadcrumbFollowup is disabled", function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = false
        Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = false
        Questie.db.char.complete = {}
        QuestiePlayer.currentQuestlog = {[QUEST_ID] = {}}

        QuestieDB.QueryQuestSingle = spy.new(function(questId, key)
            if questId == QUEST_ID and key == "breadcrumbs" then
                return {101, 102}
            end
            return nil
        end)
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

    it("should skip breadcrumb for wrong race", function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = true
        Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = false
        Questie.db.char.complete = {}
        QuestiePlayer.currentQuestlog = {[QUEST_ID] = {}}

        QuestieDB.QueryQuestSingle = spy.new(function(questId, key)
            if questId == QUEST_ID and key == "breadcrumbs" then
                return {101}
            elseif questId == 101 and key == "requiredRaces" then
                return 1 -- Human only (numeric race mask)
            end
            return nil
        end)
        QuestiePlayer.HasRequiredRace = spy.new(function(_requiredRaces)
            -- Player is Orc (race 2), breadcrumb requires Human (race 1)
            return false
        end)
        QuestiePlayer.HasRequiredClass = function() return true end
        QuestieAnnounce.IncompleteBreadcrumbQuest = spy.new(function() end)

        BreadcrumbQuests.CheckQuestBreadcrumbs(QUEST_ID)

        assert.spy(QuestiePlayer.HasRequiredRace).was.called_with(1)
        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.not_called()
    end)

    it("should skip breadcrumb for wrong class", function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = true
        Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = false
        Questie.db.char.complete = {}
        QuestiePlayer.currentQuestlog = {[QUEST_ID] = {}}

        QuestieDB.QueryQuestSingle = spy.new(function(questId, key)
            if questId == QUEST_ID and key == "breadcrumbs" then
                return {101}
            elseif questId == 101 and key == "requiredClasses" then
                return 1 -- Warrior only (numeric class mask)
            end
            return nil
        end)
        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.HasRequiredClass = spy.new(function(_requiredClasses)
            -- Player is Mage (class 8), breadcrumb requires Warrior (class 1)
            return false
        end)
        QuestieAnnounce.IncompleteBreadcrumbQuest = spy.new(function() end)

        BreadcrumbQuests.CheckQuestBreadcrumbs(QUEST_ID)

        assert.spy(QuestiePlayer.HasRequiredClass).was.called_with(1)
        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.not_called()
    end)

    it("should skip breadcrumb when exclusive quest is completed", function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = true
        Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = false
        Questie.db.char.complete = {[201] = true} -- Exclusive quest completed
        QuestiePlayer.currentQuestlog = {[QUEST_ID] = {}}

        QuestieDB.QueryQuestSingle = spy.new(function(questId, key)
            if questId == QUEST_ID and key == "breadcrumbs" then
                return {101}
            elseif questId == 101 and key == "exclusiveTo" then
                return {201}
            end
            return nil
        end)
        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.HasRequiredClass = function() return true end
        QuestieAnnounce.IncompleteBreadcrumbQuest = spy.new(function() end)

        BreadcrumbQuests.CheckQuestBreadcrumbs(QUEST_ID)

        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.not_called()
    end)

    it("should skip breadcrumb when exclusive quest is in current questlog", function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = true
        Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = false
        Questie.db.char.complete = {}
        QuestiePlayer.currentQuestlog = {[QUEST_ID] = {}, [201] = {}} -- Exclusive quest in log

        QuestieDB.QueryQuestSingle = spy.new(function(questId, key)
            if questId == QUEST_ID and key == "breadcrumbs" then
                return {101}
            elseif questId == 101 and key == "exclusiveTo" then
                return {201}
            end
            return nil
        end)
        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.HasRequiredClass = function() return true end
        QuestieAnnounce.IncompleteBreadcrumbQuest = spy.new(function() end)

        BreadcrumbQuests.CheckQuestBreadcrumbs(QUEST_ID)

        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.not_called()
    end)

    it("should skip breadcrumb when availableUntilCompleted quest is completed", function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = true
        Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = false
        Questie.db.char.complete = {[301] = true} -- availableUntilCompleted quest completed
        QuestiePlayer.currentQuestlog = {[QUEST_ID] = {}}

        QuestieDB.QueryQuestSingle = spy.new(function(questId, key)
            if questId == QUEST_ID and key == "breadcrumbs" then
                return {101}
            elseif questId == 101 and key == "availableUntilCompleted" then
                return 301
            end
            return nil
        end)
        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.HasRequiredClass = function() return true end
        QuestieAnnounce.IncompleteBreadcrumbQuest = spy.new(function() end)

        BreadcrumbQuests.CheckQuestBreadcrumbs(QUEST_ID)

        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.not_called()
    end)

    it("should announce breadcrumb when availableUntilCompleted quest is NOT completed", function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = true
        Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = false
        Questie.db.char.complete = {} -- availableUntilCompleted quest NOT completed
        QuestiePlayer.currentQuestlog = {[QUEST_ID] = {}}

        QuestieDB.QueryQuestSingle = spy.new(function(questId, key)
            if questId == QUEST_ID and key == "breadcrumbs" then
                return {101}
            elseif questId == 101 and key == "availableUntilCompleted" then
                return 301
            end
            return nil
        end)
        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.HasRequiredClass = function() return true end
        QuestieAnnounce.IncompleteBreadcrumbQuest = spy.new(function() end)

        BreadcrumbQuests.CheckQuestBreadcrumbs(QUEST_ID)

        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.called(1)
        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.called_with(QUEST_ID, 101)
    end)

    it("should skip breadcrumb when breadcrumb quest is already in currentQuestlog", function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = true
        Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = false
        Questie.db.char.complete = {}
        QuestiePlayer.currentQuestlog = {[QUEST_ID] = {}, [101] = {}} -- Breadcrumb quest in log

        QuestieDB.QueryQuestSingle = spy.new(function(questId, key)
            if questId == QUEST_ID and key == "breadcrumbs" then
                return {101}
            end
            return nil
        end)
        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.HasRequiredClass = function() return true end
        QuestieAnnounce.IncompleteBreadcrumbQuest = spy.new(function() end)

        BreadcrumbQuests.CheckQuestBreadcrumbs(QUEST_ID)

        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.not_called()
    end)

    it("should announce and abandon when both options enabled", function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = true
        Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = true
        Questie.db.char.complete = {}
        QuestiePlayer.currentQuestlog = {[QUEST_ID] = {}}

        QuestieDB.QueryQuestSingle = spy.new(function(questId, key)
            if questId == QUEST_ID and key == "breadcrumbs" then
                return {101, 102}
            end
            return nil
        end)
        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.HasRequiredClass = function() return true end
        QuestieAnnounce.IncompleteBreadcrumbQuest = spy.new(function() end)

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

        BreadcrumbQuests.CheckQuestBreadcrumbs(QUEST_ID)

        assert.spy(QuestieAnnounce.IncompleteBreadcrumbQuest).was.called(2)
        assert.are.equal(1, abandonCalls)
        assert.are.same({QUEST_ID, 102}, linkedQuestIds)
    end)
end)