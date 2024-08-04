dofile("setupTests.lua")

_G.QuestieCompat = {}
_G.C_Timer = {
    After = function(_, callback)
        callback()
    end
}

describe("AutoQuesting", function()
    ---@type AutoQuesting
    local AutoQuesting

    before_each(function()
        Questie.db.profile.autoaccept = true
        Questie.db.profile.autocomplete = true
        Questie.db.profile.autoModifier = "disabled"
        _G.QuestieCompat.GetAvailableQuests = spy.new(function() end)
        _G.QuestieCompat.SelectAvailableQuest = spy.new(function() end)
        _G.QuestieCompat.GetActiveQuests = spy.new(function() end)
        _G.QuestieCompat.SelectActiveQuest = spy.new(function() end)

        _G.AcceptQuest = spy.new(function() end)
        _G.ConfirmAcceptQuest = spy.new(function() end)
        _G.CompleteQuest = spy.new(function() end)
        _G.GetQuestID = function() return 0 end
        _G.IsQuestCompletable = spy.new(function() return true end)
        _G.GetNumQuestChoices = function() return 1 end
        _G.GetQuestReward = spy.new(function() end)
        _G.print = function()  end -- TODO: Remove this line when print is removed from the module

        AutoQuesting = require("Modules/Auto/AutoQuesting")
        AutoQuesting.private.disallowedNPCs = {
            accept = {}
        }
        AutoQuesting.Reset()
    end)

    describe("accept", function()
        it("should accept quest from quest detail", function()
            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was.called()
        end)

        it("should not accept quest from quest detail when auto accept is disabled", function()
            Questie.db.profile.autoaccept = false

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was_not.called()
        end)

        it("should not accept quest from detail when auto modifier is held", function()
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was_not.called()
        end)

        it("should accept quests from quest greetings", function()
            _G.GetNumAvailableQuests = function() return 2 end

            AutoQuesting.OnQuestGreetings()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was.called_with(1)
        end)

        it("should not accept quest from quest greetings when auto accept is disabled", function()
            _G.GetNumAvailableQuests = function() return 2 end
            Questie.db.profile.autoaccept = false

            AutoQuesting.OnQuestGreetings()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
        end)

        it("should not accept quest from greetings when auto modifier is held", function()
            _G.GetNumAvailableQuests = function() return 2 end
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnQuestGreetings()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
        end)

        it("should not accept quest from details when coming from greetings and auto modifier was held", function()
            _G.GetNumAvailableQuests = function() return 2 end
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnQuestGreetings()
            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()

            _G.IsShiftKeyDown = function() return false end
            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was_not.called()
        end)

        it("should not select available quest from greetings when coming from details and auto modifier was held", function()
            _G.GetNumAvailableQuests = function() return 2 end
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnQuestGreetings()
            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()

            _G.IsShiftKeyDown = function() return false end
            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was_not.called()

            AutoQuesting.OnQuestGreetings()
            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
        end)

        it("should select available quest from greetings when re-talking to an NPC after auto modifier was held", function()
            _G.GetNumAvailableQuests = function() return 2 end
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnQuestGreetings()
            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()

            AutoQuesting.OnQuestFinished()

            _G.IsShiftKeyDown = function() return false end
            AutoQuesting.OnQuestGreetings()
            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was.called_with(1)
        end)

        it("should accept available quest from gossip", function()
            _G.UnitGUID = function() return "0-0-0-0-0-123" end
            _G.QuestieCompat.GetAvailableQuests = function()
                return "Test Quest", 1, false, 1, false, false, false
            end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was.called_with(1)
        end)

        it("should not accept available quest from gossip when auto accept is disabled", function()
            _G.QuestieCompat.GetAvailableQuests = function()
                return "Test Quest", 1, false, 1, false, false, false
            end
            Questie.db.profile.autoaccept = false

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
        end)

        it("should not accept available quest from gossip when auto modifier is held", function()
            _G.QuestieCompat.GetAvailableQuests = function()
                return "Test Quest", 1, false, 1, false, false, false
            end
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
        end)

        it("should not accept available quest from gossip when coming from progress and auto modifier was held", function()
            _G.QuestieCompat.GetAvailableQuests = function()
                return "Test Quest", 1, false, 1, false, false, false
            end
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnGossipShow()
            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()

            _G.IsShiftKeyDown = function() return false end
            AutoQuesting.OnQuestProgress()

            AutoQuesting.OnGossipShow()
            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
        end)

        it("should not accept available quest from gossip when NPC is not allowed to accept quests from", function()
            _G.UnitGUID = function() return "0-0-0-0-0-123" end
            AutoQuesting.private.disallowedNPCs.accept[123] = true
            _G.QuestieCompat.GetAvailableQuests = function()
                return "Test Quest", 1, false, 1, false, false, false
            end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
        end)
    end)

    describe("turn in", function()
        it("should turn in quest from gossip show", function()
            _G.QuestieCompat.GetActiveQuests = function()
                return "Test Quest", 1, false, true, false, false
            end

            AutoQuesting.OnGossipShow()
            assert.spy(_G.QuestieCompat.SelectActiveQuest).was_called_with(1)

            AutoQuesting.OnQuestProgress()
            assert.spy(_G.CompleteQuest).was.called()

            AutoQuesting.OnQuestComplete()
            assert.spy(_G.GetQuestReward).was.called()
        end)

        it("should turn in second quest from gossip show when first is not complete", function()
            _G.QuestieCompat.GetActiveQuests = function()
                return "Incomplete Quest", 1, false, false, false, false, "Complete Quest", 1, false, true, false, false
            end

            AutoQuesting.OnGossipShow()
            assert.spy(_G.QuestieCompat.SelectActiveQuest).was_called_with(2)

            AutoQuesting.OnQuestProgress()
            assert.spy(_G.CompleteQuest).was.called()

            AutoQuesting.OnQuestComplete()
            assert.spy(_G.GetQuestReward).was.called()
        end)

        it("should not turn in quest from gossip show when no quest is complete", function()
            _G.QuestieCompat.GetActiveQuests = function()
                return "Test Quest", 1, false, false, false, false
            end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectActiveQuest).was_not.called()
        end)

        it("should not turn in quest from gossip when auto turn in is disabled", function()
            Questie.db.profile.autocomplete = false

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.GetActiveQuests).was_not.called()
            assert.spy(_G.QuestieCompat.SelectActiveQuest).was_not.called()
        end)

        it("should not turn in quest from gossip when auto modifier is held", function()
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.GetActiveQuests).was_not.called()
            assert.spy(_G.QuestieCompat.GetAvailableQuests).was_not.called()
            assert.spy(_G.QuestieCompat.SelectActiveQuest).was_not.called()
        end)
    end)

    describe("OnQuestProgress", function()
        it("should not complete quest when manual mode is active", function()
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnGossipShow()

            AutoQuesting.OnQuestProgress()

            assert.spy(_G.CompleteQuest).was_not.called()
        end)

        it("should not complete quest when auto turn in is disabled", function()
            Questie.db.profile.autocomplete = false

            AutoQuesting.OnQuestProgress()

            assert.spy(_G.CompleteQuest).was_not.called()
        end)

        it("should not complete quest when quest is not completable", function()
            _G.IsQuestCompletable = function() return false end

            AutoQuesting.OnQuestProgress()

            assert.spy(_G.CompleteQuest).was_not.called()
        end)

        it("should not complete quest when quest is not allowed", function()
            _G.GetQuestID = function() return 123 end
            AutoQuesting.private.disallowedQuests.turnIn[123] = true

            AutoQuesting.OnQuestProgress()

            assert.spy(_G.CompleteQuest).was_not.called()
        end)
    end)

    describe("OnQuestComplete", function()
        it("should not complete quest when manual mode is active", function()
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnGossipShow()

            AutoQuesting.OnQuestComplete()

            assert.spy(_G.GetQuestReward).was_not.called()
        end)

        it("should not complete quest when auto turn in is disabled", function()
            Questie.db.profile.autocomplete = false

            AutoQuesting.OnQuestComplete()

            assert.spy(_G.GetQuestReward).was_not.called()
        end)

        it("should not complete quest when quest has multiple rewards", function()
            _G.GetNumQuestChoices = function() return 2 end

            AutoQuesting.OnQuestComplete()

            assert.spy(_G.GetQuestReward).was_not.called()
        end)
    end)

    describe("OnQuestAcceptConfirm", function()
        it("should confirm quest accept", function()
            AutoQuesting.OnQuestAcceptConfirm()

            assert.spy(_G.ConfirmAcceptQuest).was.called()
        end)

        it("should not confirm quest accept when auto accept is disabled", function()
            Questie.db.profile.autoaccept = false

            AutoQuesting.OnQuestAcceptConfirm()

            assert.spy(_G.ConfirmAcceptQuest).was_not.called()
        end)
    end)

    it("should not turn in or accept quest from gossip when auto accept and turn in are disabled", function()
        Questie.db.profile.autoaccept = false
        Questie.db.profile.autocomplete = false

        AutoQuesting.OnGossipShow()

        assert.spy(_G.QuestieCompat.GetActiveQuests).was_not.called()
        assert.spy(_G.QuestieCompat.SelectActiveQuest).was_not.called()
        assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
    end)
end)
