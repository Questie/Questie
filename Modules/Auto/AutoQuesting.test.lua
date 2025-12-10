dofile("setupTests.lua")

_G.QuestieCompat = {}

---@param override GossipQuestUIInfo
local function getAvailableTestQuest(override)
    return {
        title = override.title or "Test Quest",
        questLevel = override.questLevel or 1,
        isTrivial = override.isTrivial or false,
        frequency = override.frequency or 1,
        repeatable = override.repeatable or false,
        isLegendary = override.isLegendary or false,
        isIgnored = override.isIgnored or false,
        isImportant = override.isImportant or false,
        isMeta = override.isMeta or false,
        questID = override.questID or 0,
    }
end

describe("AutoQuesting", function()
    ---@type AutoQuesting
    local AutoQuesting
    ---@type QuestieDB
    local QuestieDB

    before_each(function()
        Questie.db.profile.autocomplete = true
        Questie.db.profile.autoAccept = {
            enabled = true,
            trivial = false,
            repeatable = true,
            pvp = true,
            rejectSharedInBattleground = false
        }
        Questie.db.profile.autoModifier = "disabled"
        Questie.Print = spy.new(function() end)
        _G.QuestieCompat.GetAvailableQuests = spy.new(function() return {} end)
        _G.QuestieCompat.SelectAvailableQuest = spy.new(function() end)
        _G.QuestieCompat.GetActiveQuests = spy.new(function() end)
        _G.QuestieCompat.SelectActiveQuest = spy.new(function() end)

        _G.GossipFrame = nil
        _G.GossipFrameGreetingPanel = nil
        _G.QuestFrameGreetingPanel = nil
        _G.QuestFrameDetailPanel = nil
        _G.QuestFrameProgressPanel = nil
        _G.QuestFrameRewardPanel = nil
        _G.ImmersionFrame = nil
        _G.ImmersionContentFrame = nil

        _G.AcceptQuest = spy.new(function() end)
        _G.DeclineQuest = spy.new(function() end)
        _G.ConfirmAcceptQuest = spy.new(function() end)
        _G.SelectAvailableQuest = spy.new(function() end)
        _G.CompleteQuest = spy.new(function() end)
        _G.GetQuestID = function() return 0 end
        _G.IsQuestCompletable = spy.new(function() return true end)
        _G.GetNumQuestChoices = function() return 1 end
        _G.GetQuestReward = spy.new(function() end)
        _G.IsShiftKeyDown = function() return false end
        _G.UnitGUID = spy.new(function() end)
        _G.print = function()  end -- TODO: Remove this line when print is removed from the module

        _G.C_Timer = {
            After = function(_, callback)
                callback()
            end
        }

        QuestieDB = require("Database.QuestieDB")
        require("Localization.l10n") -- We don't need the return value

        AutoQuesting = require("Modules/Auto/AutoQuesting")
        AutoQuesting.private.disallowedNPCs = {}
        AutoQuesting.private.disallowedQuests = {
            accept = {},
            turnIn = {},
        }
        AutoQuesting.Reset()
    end)

    describe("OnQuestDetail", function()
        it("should accept quest", function()
            _G.UnitGUID = function() return "0-0-0-0-0-123" end
            _G.GetQuestID = function() return 123 end
            QuestieDB.QueryQuestSingle = spy.new(function() return 10 end)
            QuestieDB.IsTrivial = spy.new(function() return false end)

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was.called()
        end)

        it("should not accept quest when auto accept is disabled", function()
            Questie.db.profile.autoAccept.enabled = false

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was_not.called()
        end)

        it("should not accept quest when auto modifier is held", function()
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was_not.called()
        end)

        it("should not accept quest when NPC is not allowed to accept quests from", function()
            _G.UnitGUID = function() return "0-0-0-0-0-123" end
            AutoQuesting.private.disallowedNPCs[123] = true

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was_not.called()
        end)

        it("should not accept quest when quest is not allowed to accept", function()
            _G.GetQuestID = function() return 123 end
            AutoQuesting.private.disallowedQuests.accept[123] = true

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was_not.called()
        end)

        it("should not accept quest when questId is 0 - happens when some other addon is faster", function()
            _G.GetQuestID = function() return 0 end
            QuestieDB.QueryQuestSingle = spy.new()
            QuestieDB.IsRepeatable = spy.new()
            QuestieDB.IsPvPQuest = spy.new()

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was_not.called()
            assert.spy(QuestieDB.IsRepeatable).was_not.called()
            assert.spy(QuestieDB.IsRepeatable).was_not.called()
            assert.spy(QuestieDB.IsPvPQuest).was_not.called()
        end)

        it("should accept trivial quest when setting is enabled", function()
            Questie.db.profile.autoAccept.trivial = true
            _G.GetQuestID = function() return 123 end

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was.called()
        end)

        it("should not accept trivial quest when setting is disabled", function()
            _G.GetQuestID = function() return 123 end
            QuestieDB.QueryQuestSingle = spy.new(function() return 10 end)
            QuestieDB.IsTrivial = spy.new(function() return true end)

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was_not.called()
        end)

        it("should accept repeatable quest when setting is enabled", function()
            Questie.db.profile.autoAccept.trivial = true
            Questie.db.profile.autoAccept.repeatable = true
            _G.GetQuestID = function() return 123 end
            QuestieDB.IsRepeatable = spy.new()

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was.called()
            assert.spy(QuestieDB.IsRepeatable).was_not.called()
        end)

        it("should not accept repeatable quest when setting is disabled", function()
            Questie.db.profile.autoAccept.repeatable = false
            _G.GetQuestID = function() return 123 end
            QuestieDB.IsRepeatable = spy.new(function() return true end)

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was_not.called()
            assert.spy(QuestieDB.IsRepeatable).was.called_with(123)
        end)

        it("should accept PvP quest when setting is enabled", function()
            Questie.db.profile.autoAccept.trivial = true
            Questie.db.profile.autoAccept.pvp = true
            _G.GetQuestID = function() return 123 end
            QuestieDB.IsPvPQuest = spy.new()

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was.called()
            assert.spy(QuestieDB.IsPvPQuest).was_not.called()
        end)

        it("should not accept PvP quest when setting is disabled", function()
            Questie.db.profile.autoAccept.pvp = false
            _G.GetQuestID = function() return 123 end
            QuestieDB.IsPvPQuest = spy.new(function() return true end)

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was_not.called()
            assert.spy(QuestieDB.IsPvPQuest).was.called_with(123)
        end)

        it("should not accept PvP quests when setting is enabled but questId is 0 - happens when some other addon is faster", function()
            Questie.db.profile.autoAccept.pvp = false
            _G.GetQuestID = function() return 0 end
            QuestieDB.IsPvPQuest = spy.new()

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was_not.called()
            assert.spy(QuestieDB.IsPvPQuest).was_not.called()
        end)

        it("should decline quest if player is in battleground and quest was shared by another player when setting is enabled", function()
            _G.GetQuestID = function() return 123 end
            _G.UnitInBattleground = spy.new(function() return true end)
            _G.UnitGUID = spy.new(function() return "Player-0-0-0-0-0-0" end)
            Questie.db.profile.autoAccept.rejectSharedInBattleground = true

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.DeclineQuest).was.called()
            assert.spy(Questie.Print).was.called()
            assert.spy(_G.AcceptQuest).was_not.called()
            assert.spy(_G.UnitGUID).was.called_with("questnpc")
            assert.spy(_G.UnitInBattleground).was.called_with("player")
        end)

        it("should accept quest if player is in battleground and quest was shared by another player when setting is not enabled", function()
            _G.GetQuestID = function() return 123 end
            _G.UnitInBattleground = spy.new(function() return true end)
            _G.UnitGUID = spy.new(function() return "Player-0-0-0-0-0-0" end)
            QuestieDB.QueryQuestSingle = spy.new(function() return 10 end)
            QuestieDB.IsTrivial = spy.new(function() return false end)
            Questie.db.profile.autoAccept.rejectSharedInBattleground = false

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was.called()
            assert.spy(_G.DeclineQuest).was_not.called()
            assert.spy(Questie.Print).was_not.called()
            assert.spy(_G.UnitGUID).was_not.called_with("questnpc")
            assert.spy(_G.UnitInBattleground).was_not.called()
        end)

        it("should accept quest if player is in battleground and quest was not shared by another player when setting is enabled", function()
            _G.GetQuestID = function() return 123 end
            _G.UnitInBattleground = spy.new(function() return true end)
            _G.UnitGUID = spy.new(function() return "Creature-0-0-0-0-0-0" end)
            Questie.db.profile.autoAccept.rejectSharedInBattleground = true

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was.called()
            assert.spy(_G.DeclineQuest).was_not.called()
            assert.spy(Questie.Print).was_not.called()
            assert.spy(_G.UnitGUID).was.called_with("questnpc")
            assert.spy(_G.UnitInBattleground).was.called_with("player")
        end)

        it("should accept quest if player is not in battleground and quest was shared by another player when setting is enabled", function()
            _G.GetQuestID = function() return 123 end
            _G.UnitInBattleground = spy.new(function() return nil end)
            _G.UnitGUID = spy.new(function() return "Player-0-0-0-0-0-0" end)
            Questie.db.profile.autoAccept.rejectSharedInBattleground = true

            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was.called()
            assert.spy(_G.DeclineQuest).was_not.called()
            assert.spy(Questie.Print).was_not.called()
            assert.spy(_G.UnitGUID).was_not.called_with("questnpc")
            assert.spy(_G.UnitInBattleground).was.called_with("player")
        end)
    end)

    describe("OnQuestGreeting", function()
        it("should accept quests", function()
            _G.GetNumAvailableQuests = function() return 2 end
            Questie.db.profile.autocomplete = false

            AutoQuesting.OnQuestGreeting()

            assert.spy(_G.SelectAvailableQuest).was.called_with(1)
        end)

        it("should not accept quest when auto accept is disabled", function()
            _G.GetNumAvailableQuests = function() return 2 end
            Questie.db.profile.autoAccept.enabled = false
            Questie.db.profile.autocomplete = false

            AutoQuesting.OnQuestGreeting()

            assert.spy(_G.SelectAvailableQuest).was_not.called()
        end)

        it("should not accept quest when auto modifier is held", function()
            _G.GetNumAvailableQuests = function() return 2 end
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnQuestGreeting()

            assert.spy(_G.SelectAvailableQuest).was_not.called()
        end)

        it("should not accept quest when NPC not allowed", function()
            _G.UnitGUID = function() return "0-0-0-0-0-123" end
            AutoQuesting.private.disallowedNPCs[123] = true
            _G.SelectAvailableQuest = spy.new()
            Questie.db.profile.autoAccept.enabled = true
            Questie.db.profile.autocomplete = false

            AutoQuesting.OnQuestGreeting()

            assert.spy(_G.SelectAvailableQuest).was_not.called()
        end)

        it("should turn in quest", function()
            _G.GetNumActiveQuests = function() return 2 end
            _G.GetActiveTitle = function() return "Test Quest", true end
            _G.SelectActiveQuest = spy.new()
            _G.GetNumAvailableQuests = spy.new()

            AutoQuesting.OnQuestGreeting()

            assert.spy(_G.SelectActiveQuest).was.called_with(1)
            assert.spy(_G.GetNumAvailableQuests).was_not.called()
        end)

        it("should turn in second quest when first is not complete", function()
            local isFirst = true
            _G.GetActiveTitle = function()
                if isFirst then
                    isFirst = false
                    return "Incomplete Quest", false
                else
                    return "Complete Quest", true
                end
            end
            _G.SelectActiveQuest = spy.new()

            AutoQuesting.OnQuestGreeting()

            assert.spy(_G.SelectActiveQuest).was.called_with(2)
        end)

        it("should not turn in quest when auto turn in is disabled", function()
            _G.GetNumActiveQuests = function() return 2 end
            _G.SelectActiveQuest = spy.new()
            Questie.db.profile.autoAccept.enabled = false
            Questie.db.profile.autocomplete = false

            AutoQuesting.OnQuestGreeting()

            assert.spy(_G.SelectActiveQuest).was_not.called()
        end)

        it("should not turn in quest when NPC not allowed", function()
            _G.UnitGUID = function() return "0-0-0-0-0-123" end
            AutoQuesting.private.disallowedNPCs[123] = true
            _G.SelectAvailableQuest = spy.new()
            Questie.db.profile.autoAccept.enabled = false
            Questie.db.profile.autocomplete = true

            AutoQuesting.OnQuestGreeting()

            assert.spy(_G.SelectActiveQuest).was_not.called()
        end)
    end)

    describe("OnGossipShow", function()
        it("should accept available quest", function()
            _G.UnitGUID = function() return "0-0-0-0-0-123" end
            _G.QuestieCompat.GetAvailableQuests = function()
                return {getAvailableTestQuest({})}
            end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was.called_with(1)
        end)

        it("should accept available quest when active quests are not complete", function()
            _G.UnitGUID = function() return "0-0-0-0-0-123" end
            _G.QuestieCompat.GetAvailableQuests = function()
                return {getAvailableTestQuest({})}
            end
            _G.QuestieCompat.GetActiveQuests = function()
                return "Test Quest", 1, false, false, false, false
            end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was.called_with(1)
            assert.spy(_G.QuestieCompat.SelectActiveQuest).was_not.called()
        end)

        it("should not accept available quest when auto accept is disabled", function()
            _G.QuestieCompat.GetAvailableQuests = function()
                return {getAvailableTestQuest({})}
            end
            Questie.db.profile.autoAccept.enabled = false

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
        end)

        it("should not accept available quest when auto modifier is held", function()
            _G.QuestieCompat.GetAvailableQuests = function()
                return {getAvailableTestQuest({})}
            end
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
        end)

        it("should not accept available quest when NPC is not allowed to accept quests from", function()
            _G.UnitGUID = function() return "0-0-0-0-0-123" end
            AutoQuesting.private.disallowedNPCs[123] = true
            _G.QuestieCompat.GetAvailableQuests = function()
                return {getAvailableTestQuest({})}
            end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
        end)

        it("should accept trivial quest when setting is enabled", function()
            Questie.db.profile.autoAccept.trivial = true
            _G.QuestieCompat.GetAvailableQuests = function()
                return {getAvailableTestQuest({isTrivial = true})}
            end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was.called_with(1)
        end)

        it("should not accept trivial quest when setting is disabled", function()
            _G.QuestieCompat.GetAvailableQuests = function()
                return {getAvailableTestQuest({isTrivial = true})}
            end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
        end)

        it("should skip trivial quest when setting is disabled and accept non-trivial", function()
            _G.QuestieCompat.GetAvailableQuests = function()
                return {getAvailableTestQuest({isTrivial = true}), getAvailableTestQuest({})}
            end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was.called_with(2)
        end)

        it("should accept repeatable quest when setting is enabled", function()
            Questie.db.profile.autoAccept.repeatable = true
            _G.QuestieCompat.GetAvailableQuests = function()
                return {getAvailableTestQuest({repeatable = true})}
            end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was.called_with(1)
        end)

        it("should not accept repeatable quest when setting is disabled", function()
            Questie.db.profile.autoAccept.repeatable = false
            _G.QuestieCompat.GetAvailableQuests = function()
                return {getAvailableTestQuest({repeatable = true})}
            end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
        end)

        it("should skip repeatable quest when setting is disabled and accept non-repeatable", function()
            Questie.db.profile.autoAccept.repeatable = false
            _G.QuestieCompat.GetAvailableQuests = function()
                return {getAvailableTestQuest({repeatable = true}), getAvailableTestQuest({})}
            end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was.called_with(2)
        end)

        it("should accept PvP quest when setting is enabled", function()
            Questie.db.profile.autoAccept.pvp = true
            _G.QuestieCompat.GetAvailableQuests = function()
                return {getAvailableTestQuest({})}
            end
            QuestieDB.IsPvPQuest = spy.new(function() return true end)

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was.called_with(1)
        end)

        it("should not accept PvP quest when setting is disabled", function()
            Questie.db.profile.autoAccept.pvp = false
            _G.QuestieCompat.GetAvailableQuests = function()
                return {getAvailableTestQuest({})}
            end
            QuestieDB.IsPvPQuest = spy.new(function() return true end)

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
        end)

        it("should skip PvP quest when setting is disabled and accept non-PvP", function()
            Questie.db.profile.autoAccept.pvp = false
            _G.QuestieCompat.GetAvailableQuests = function()
                return {getAvailableTestQuest({questID = 1}),getAvailableTestQuest({questID = 2})}
            end
            QuestieDB.IsPvPQuest = spy.new(function(questId) return questId == 1 end)

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was.called_with(2)
        end)

        it("should not turn in quest when no quest is complete", function()
            _G.QuestieCompat.GetActiveQuests = function()
                return "Test Quest", 1, false, false, false, false
            end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.SelectActiveQuest).was_not.called()
        end)

        it("should not turn in quest when auto turn in is disabled", function()
            Questie.db.profile.autocomplete = false

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.GetActiveQuests).was_not.called()
            assert.spy(_G.QuestieCompat.SelectActiveQuest).was_not.called()
        end)

        it("should not turn in quest when auto modifier is held", function()
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.GetActiveQuests).was_not.called()
            assert.spy(_G.QuestieCompat.GetAvailableQuests).was_not.called()
            assert.spy(_G.QuestieCompat.SelectActiveQuest).was_not.called()
        end)

        it("should not turn in or accept quest when auto accept and turn in are disabled", function()
            Questie.db.profile.autoAccept.enabled = false
            Questie.db.profile.autocomplete = false

            AutoQuesting.OnGossipShow()

            assert.spy(_G.QuestieCompat.GetActiveQuests).was_not.called()
            assert.spy(_G.QuestieCompat.SelectActiveQuest).was_not.called()
            assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
        end)
    end)

    describe("OnQuestProgress", function()
        it("should not complete quest when manual mode is active", function()
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

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

        it("should not complete quest when NPC is not allowed for quest completion", function()
            _G.UnitGUID = function() return "0-0-0-0-0-123" end
            AutoQuesting.private.disallowedNPCs[123] = true

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

            AutoQuesting.OnQuestComplete()

            assert.spy(_G.GetQuestReward).was_not.called()
        end)

        it("should not complete quest when manual mode is active and coming from gossip", function()
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnGossipShow()
            _G.IsShiftKeyDown = function() return false end

            AutoQuesting.OnQuestComplete()

            assert.spy(_G.GetQuestReward).was_not.called()
        end)

        it("should not complete quest when auto turn in is disabled", function()
            Questie.db.profile.autocomplete = false

            AutoQuesting.OnQuestComplete()

            assert.spy(_G.GetQuestReward).was_not.called()
        end)

        it("should not complete quest when NPC is not allowed for quest completion", function()
            _G.UnitGUID = function() return "0-0-0-0-0-123" end
            AutoQuesting.private.disallowedNPCs[123] = true

            AutoQuesting.OnQuestComplete()

            assert.spy(_G.GetQuestReward).was_not.called()
        end)

        it("should not complete quest when quest is not allowed", function()
            _G.GetQuestID = function() return 123 end
            AutoQuesting.private.disallowedQuests.turnIn[123] = true

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
            Questie.db.profile.autoAccept.enabled = false

            AutoQuesting.OnQuestAcceptConfirm()

            assert.spy(_G.ConfirmAcceptQuest).was_not.called()
        end)
    end)

    describe("OnQuestFinished", function()
        it("should reset when no frame exists", function()
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end
            local resetSpy = spy.on(AutoQuesting, "Reset")

            AutoQuesting.OnGossipShow()
            AutoQuesting.OnQuestFinished()

            assert.spy(resetSpy).was.called()
        end)

        it("should not reset when auto run is active", function()
            local resetSpy = spy.on(AutoQuesting, "Reset")

            AutoQuesting.OnQuestFinished()

            assert.spy(resetSpy).was_not.called()
        end)

        it("should not reset when GossipFrame is visible", function()
            _G.GossipFrame = {
                IsVisible = function() return true end
            }
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end
            local resetSpy = spy.on(AutoQuesting, "Reset")

            AutoQuesting.OnGossipShow()
            AutoQuesting.OnQuestFinished()

            assert.spy(resetSpy).was_not.called()
        end)

        it("should not reset when GossipFrameGreetingPanel is visible", function()
            _G.GossipFrameGreetingPanel = {
                IsVisible = function() return true end
            }
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end
            local resetSpy = spy.on(AutoQuesting, "Reset")

            AutoQuesting.OnGossipShow()
            AutoQuesting.OnQuestFinished()

            assert.spy(resetSpy).was_not.called()
        end)

        it("should not reset when QuestFrameGreetingPanel is visible", function()
            _G.QuestFrameGreetingPanel = {
                IsVisible = function() return true end
            }
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end
            local resetSpy = spy.on(AutoQuesting, "Reset")

            AutoQuesting.OnGossipShow()
            AutoQuesting.OnQuestFinished()

            assert.spy(resetSpy).was_not.called()
        end)

        it("should not reset when QuestFrameDetailPanel is visible", function()
            _G.QuestFrameDetailPanel = {
                IsVisible = function() return true end
            }
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end
            local resetSpy = spy.on(AutoQuesting, "Reset")

            AutoQuesting.OnGossipShow()
            AutoQuesting.OnQuestFinished()

            assert.spy(resetSpy).was_not.called()
        end)

        it("should not reset when QuestFrameProgressPanel is visible", function()
            _G.QuestFrameProgressPanel = {
                IsVisible = function() return true end
            }
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end
            local resetSpy = spy.on(AutoQuesting, "Reset")

            AutoQuesting.OnGossipShow()
            AutoQuesting.OnQuestFinished()

            assert.spy(resetSpy).was_not.called()
        end)

        it("should not reset when QuestFrameRewardPanel is visible", function()
            _G.QuestFrameRewardPanel = {
                IsVisible = function() return true end
            }
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end
            local resetSpy = spy.on(AutoQuesting, "Reset")

            AutoQuesting.OnGossipShow()
            AutoQuesting.OnQuestFinished()

            assert.spy(resetSpy).was_not.called()
        end)

        it("should not reset when ImmersionFrame.TitleButtons is visible", function()
            _G.ImmersionFrame = {
                TitleButtons = {
                    IsVisible = function() return true end
                }
            }
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end
            local resetSpy = spy.on(AutoQuesting, "Reset")

            AutoQuesting.OnGossipShow()
            AutoQuesting.OnQuestFinished()

            assert.spy(resetSpy).was_not.called()
        end)

        it("should not reset when ImmersionContentFrame is visible", function()
            _G.ImmersionContentFrame = {
                IsVisible = function() return true end
            }
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end
            local resetSpy = spy.on(AutoQuesting, "Reset")

            AutoQuesting.OnGossipShow()
            AutoQuesting.OnQuestFinished()

            assert.spy(resetSpy).was_not.called()
        end)
    end)

    describe("OnGossipClosed", function()
        it("should reset when no frame exists", function()
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end
            local resetSpy = spy.on(AutoQuesting, "Reset")

            AutoQuesting.OnGossipShow()
            AutoQuesting.OnGossipClosed()

            assert.spy(resetSpy).was.called()
        end)

        it("should not reset when auto run is active", function()
            local resetSpy = spy.on(AutoQuesting, "Reset")

            AutoQuesting.OnGossipClosed()

            assert.spy(resetSpy).was_not.called()
        end)
    end)

    describe("IsModifierHeld", function()
        it("should return true when auto modifier is shift and held", function()
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            assert.is_true(AutoQuesting.IsModifierHeld())
        end)

        it("should return true when auto modifier is ctrl and held", function()
            Questie.db.profile.autoModifier = "ctrl"
            _G.IsControlKeyDown = function() return true end

            assert.is_true(AutoQuesting.IsModifierHeld())
        end)

        it("should return true when auto modifier is alt and held", function()
            Questie.db.profile.autoModifier = "alt"
            _G.IsAltKeyDown = function() return true end

            assert.is_true(AutoQuesting.IsModifierHeld())
        end)

        it("should return false when auto modifier is disabled", function()
            Questie.db.profile.autoModifier = "disabled"

            assert.is_false(AutoQuesting.IsModifierHeld())
        end)

        it("should return false when auto modifier is nil", function()
            Questie.db.profile.autoModifier = nil

            assert.is_false(AutoQuesting.IsModifierHeld())
        end)
    end)

    describe("Accept Flow", function()
        it("should not accept quest from details when coming from greetings and auto modifier was held", function()
            _G.GetNumAvailableQuests = function() return 2 end
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnQuestGreeting()
            assert.spy(_G.SelectAvailableQuest).was_not.called()

            _G.IsShiftKeyDown = function() return false end
            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was_not.called()
        end)

        it("should not accept quest from greetings when auto modifier was held and manually accepting a quest", function()
            _G.C_Timer.After = function() end
            _G.GetNumAvailableQuests = function() return 2 end
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnQuestGreeting()
            assert.spy(_G.SelectAvailableQuest).was_not.called()

            _G.IsShiftKeyDown = function() return false end
            AutoQuesting.OnQuestDetail()
            AutoQuesting.OnQuestFinished()

            AutoQuesting.OnQuestGreeting()

            assert.spy(_G.SelectAvailableQuest).was_not.called()
        end)

        it("should not select available quest from greetings when coming from details and auto modifier was held", function()
            _G.GetNumAvailableQuests = function() return 2 end
            Questie.db.profile.autoModifier = "shift"
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnQuestGreeting()
            assert.spy(_G.SelectAvailableQuest).was_not.called()

            _G.IsShiftKeyDown = function() return false end
            AutoQuesting.OnQuestDetail()

            assert.spy(_G.AcceptQuest).was_not.called()

            AutoQuesting.OnQuestGreeting()
            assert.spy(_G.SelectAvailableQuest).was_not.called()
        end)

        it("should select available quest from greetings when re-talking to an NPC after auto modifier was held", function()
            _G.GetNumAvailableQuests = function() return 2 end
            Questie.db.profile.autoModifier = "shift"
            Questie.db.profile.autocomplete = false
            _G.IsShiftKeyDown = function() return true end

            AutoQuesting.OnQuestGreeting()
            assert.spy(_G.SelectAvailableQuest).was_not.called()

            AutoQuesting.OnQuestFinished()

            _G.IsShiftKeyDown = function() return false end
            AutoQuesting.OnQuestGreeting()
            assert.spy(_G.SelectAvailableQuest).was.called_with(1)
        end)

        it("should not accept available quest from gossip when coming from progress and auto modifier was held", function()
            _G.QuestieCompat.GetAvailableQuests = function()
                return {getAvailableTestQuest({})}
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
    end)

    describe("Turn-in Flow", function()
        it("should turn in quest from gossip show", function()
            _G.QuestieCompat.GetActiveQuests = function()
                return "Test Quest", 1, false, true, false, false
            end

            AutoQuesting.OnGossipShow()
            assert.spy(_G.QuestieCompat.SelectActiveQuest).was.called_with(1)
            assert.spy(_G.QuestieCompat.GetAvailableQuests).was_not.called()

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
            assert.spy(_G.QuestieCompat.SelectActiveQuest).was.called_with(2)

            AutoQuesting.OnQuestProgress()
            assert.spy(_G.CompleteQuest).was.called()

            AutoQuesting.OnQuestComplete()
            assert.spy(_G.GetQuestReward).was.called()
        end)
    end)
end)
