dofile("setupTests.lua")

describe("QuestChain", function()
    ---@type QuestChain
    local QuestChain
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieCorrections
    local QuestieCorrections

    ---@type QuestXP
    local QuestXP
    ---@type QuestieLib
    local QuestieLib

    ---@type QuestieEvent
    local QuestieEvent
    ---@type QuestLockReasons
    local QuestLockReasons

    local nextQuestInChain
    local doableStates
    local activeQuests
    local savedGlobals

    before_each(function()
        nextQuestInChain = {}
        doableStates = {}
        activeQuests = {}

        savedGlobals = {
            C_CurrencyInfo = _G.C_CurrencyInfo,
            FormatLargeNumber = _G.FormatLargeNumber,
            Colorize = Questie.Colorize,
            profile = Questie.db.profile,
            char = Questie.db.char,
        }
        _G.C_CurrencyInfo = {GetCoinTextureString = function(copper) return copper .. "c" end}
        _G.FormatLargeNumber = function(number) return number == 1150 and "1,150" or tostring(number) end
        Questie.Colorize = function(_, text, color) return "[" .. color .. "]" .. text end
        Questie.db.profile = {showQuestXpAtMaxLevel = false}
        Questie.db.char = {complete = {}}

        dofile("Localization/l10n.lua")

        QuestXP = QuestieLoader:ImportModule("QuestXP")
        QuestXP.GetQuestLogRewardXP = function() return 0 end
        QuestXP.GetQuestRewardMoney = function() return 0 end

        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetEffectiveQuestLevel = function() return 20 end
        QuestieLib.PrintDifficultyColor = function(_, level, text) return "<" .. level .. ">" .. text end

        QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
        QuestieEvent.IsEventQuest = function() return false end

        QuestieLoader:ImportModule("QuestieQuestBlacklist").HIDE_ON_MAP = "HIDE_ON_MAP"
        QuestieLoader:ImportModule("ActiveQuests").Get = function(questId) return activeQuests[questId] end

        QuestLockReasons = QuestieLoader:ImportModule("QuestLockReasons")
        QuestLockReasons.GetReasons = function() return {} end

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.DoableStates = {
            AVAILABLE = 0,
            WRONG_RACE = 6,
            WRONG_CLASS = 8,
            EXCLUSIVE_COMPLETED = 14,
            EXCLUSIVE_IN_QUEST_LOG = 15,
            PROFESSION_SPECIALIZATION = 17,
            LEVEL_TOO_LOW = 26,
            DISABLING_QUEST_COMPLETED = 27,
            PROFESSION_MISSING = 29,
        }
        QuestieDB.QueryQuestSingle = function(questId, key)
            if key == "nextQuestInChain" then
                return nextQuestInChain[questId]
            end
        end
        QuestieDB.IsDoableVerbose = function(questId)
            return "", false, doableStates[questId] or QuestieDB.DoableStates.AVAILABLE
        end
        QuestieDB.IsRepeatable = function() return false end
        QuestieDB.IsPvPQuest = function() return false end
        QuestieDB.QuestPointers = {[1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1}

        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.hiddenQuests = {}

        dofile("Modules/Quest/QuestChain.lua")
        QuestChain = QuestieLoader:ImportModule("QuestChain")
    end)

    after_each(function()
        _G.C_CurrencyInfo = savedGlobals.C_CurrencyInfo
        _G.FormatLargeNumber = savedGlobals.FormatLargeNumber
        Questie.Colorize = savedGlobals.Colorize
        Questie.db.profile = savedGlobals.profile
        Questie.db.char = savedGlobals.char
    end)

    describe("GetNextQuests", function()
        it("should return an empty list when the quest has no follow-up", function()
            nextQuestInChain[1] = 0

            assert.are_same({}, QuestChain.GetNextQuests(1))
            assert.are_same({}, QuestChain.GetNextQuests(2))
        end)

        it("should list the whole chain in order", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 3
            nextQuestInChain[3] = 4
            nextQuestInChain[4] = 0

            assert.are_same({2, 3, 4}, QuestChain.GetNextQuests(1))
        end)

        it("should start after the given quest when it is in the middle of a chain", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 3
            nextQuestInChain[3] = 0

            assert.are_same({3}, QuestChain.GetNextQuests(2))
        end)

        it("should stop before a quest missing from the database", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 3
            nextQuestInChain[3] = 4
            QuestieDB.QuestPointers[3] = nil

            assert.are_same({2}, QuestChain.GetNextQuests(1))
        end)

        it("should stop before a quest hidden by Questie", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 3
            nextQuestInChain[3] = 4
            QuestieCorrections.hiddenQuests[3] = true

            assert.are_same({2}, QuestChain.GetNextQuests(1))
        end)

        for _, stateName in ipairs({"WRONG_RACE", "WRONG_CLASS", "PROFESSION_MISSING", "PROFESSION_SPECIALIZATION",
                                    "EXCLUSIVE_COMPLETED", "DISABLING_QUEST_COMPLETED"}) do
            it("should stop before a quest the player cannot take because of " .. stateName, function()
                nextQuestInChain[1] = 2
                nextQuestInChain[2] = 3
                nextQuestInChain[3] = 4
                doableStates[3] = QuestieDB.DoableStates[stateName]

                assert.are_same({2}, QuestChain.GetNextQuests(1))
            end)
        end

        it("should keep quests the player can take later", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 3
            nextQuestInChain[3] = 0
            doableStates[2] = QuestieDB.DoableStates.LEVEL_TOO_LOW
            doableStates[3] = QuestieDB.DoableStates.LEVEL_TOO_LOW

            assert.are_same({2, 3}, QuestChain.GetNextQuests(1))
        end)

        it("should keep a quest that an exclusive quest in the quest log blocks", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 3
            nextQuestInChain[3] = 0
            doableStates[3] = QuestieDB.DoableStates.EXCLUSIVE_IN_QUEST_LOG

            assert.are_same({2, 3}, QuestChain.GetNextQuests(1))
        end)

        it("should end a chain that loops back to a quest it already listed", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 3
            nextQuestInChain[3] = 2

            assert.are_same({2, 3}, QuestChain.GetNextQuests(1))
        end)

        it("should end a chain that loops back to the given quest", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 1

            assert.are_same({2}, QuestChain.GetNextQuests(1))
        end)
    end)

    describe("GetFollowUpQuests", function()
        it("should list the quests the player cannot take", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 3
            nextQuestInChain[3] = 0
            doableStates[2] = QuestieDB.DoableStates.WRONG_CLASS
            doableStates[3] = QuestieDB.DoableStates.EXCLUSIVE_COMPLETED

            assert.are_same({2, 3}, QuestChain.GetFollowUpQuests(1))
        end)

        it("should stop before a quest missing from the database or hidden by Questie for good", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 3
            nextQuestInChain[3] = 4
            QuestieDB.QuestPointers[4] = nil
            assert.are_same({2, 3}, QuestChain.GetFollowUpQuests(1))

            QuestieCorrections.hiddenQuests[3] = true
            assert.are_same({2}, QuestChain.GetFollowUpQuests(1))
        end)

        it("should keep a quest hidden only on the map and a world event quest", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 3
            nextQuestInChain[3] = 0
            QuestieCorrections.hiddenQuests[2] = "HIDE_ON_MAP"
            QuestieCorrections.hiddenQuests[3] = true
            QuestieEvent.IsEventQuest = function(questId) return questId == 3 end

            assert.are_same({2, 3}, QuestChain.GetFollowUpQuests(1))
        end)

        it("should end a chain that loops back", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 1

            assert.are_same({2}, QuestChain.GetFollowUpQuests(1))
        end)
    end)

    describe("GetLockReasons", function()
        local ownReasons

        before_each(function()
            ownReasons = {}
            QuestLockReasons.GetReasons = function(questId) return ownReasons[questId] or {} end
        end)

        it("should list each quest's own reasons", function()
            ownReasons[3] = {"Warrior only", "Requires level 20"}

            assert.are_same({[2] = {}, [3] = {"Warrior only", "Requires level 20"}}, QuestChain.GetLockReasons(1, {2, 3}))
        end)

        it("should give a quest without reasons the reasons of the last quest before it that has some", function()
            ownReasons[2] = {"Warrior only"}
            ownReasons[4] = {"Requires level 20"}

            assert.are_same({[2] = {"Warrior only"}, [3] = {"Warrior only"}, [4] = {"Requires level 20"}, [5] = {"Requires level 20"}},
                QuestChain.GetLockReasons(1, {2, 3, 4, 5}))
        end)

        it("should give no reasons to a quest turned in or in the quest log, nor to the quests after it", function()
            ownReasons[2] = {"Warrior only"}
            ownReasons[3] = {"Requires level 20"}
            Questie.db.char.complete[3] = true
            activeQuests[5] = {}
            ownReasons[5] = {"Requires level 30"}

            assert.are_same({[2] = {"Warrior only"}, [3] = {}, [4] = {}, [5] = {}}, QuestChain.GetLockReasons(1, {2, 3, 4, 5}))
        end)

        it("should treat the given quest and the quests before each one as part of the chain", function()
            local chainQuestIdsByQuest = {}
            QuestLockReasons.GetReasons = function(questId, chainQuestIds)
                local copy = {}
                for chainQuestId in pairs(chainQuestIds) do
                    copy[chainQuestId] = true
                end
                chainQuestIdsByQuest[questId] = copy
                return {}
            end

            QuestChain.GetLockReasons(1, {2, 3})

            assert.are_same({[2] = {[1] = true}, [3] = {[1] = true, [2] = true}}, chainQuestIdsByQuest)
        end)
    end)

    describe("GetRewardText", function()
        it("should show the XP in the quest's difficulty color followed by the money", function()
            QuestXP.GetQuestLogRewardXP = function() return 1150 end
            QuestXP.GetQuestRewardMoney = function() return 250 end

            assert.are_equal("<20>(1,150xp) [white](250c) ", QuestChain.GetRewardText(5))
        end)

        it("should color the XP by the quest's level and kind", function()
            QuestXP.GetQuestLogRewardXP = function() return 1150 end
            QuestieDB.IsRepeatable = function() return true end
            QuestieDB.IsPvPQuest = function() return true end
            QuestieLib.PrintDifficultyColor = spy.new(function() return "" end)

            QuestChain.GetRewardText(5)

            assert.spy(QuestieLib.PrintDifficultyColor).was.called_with(QuestieLib, 20, "(1,150xp) ", true, false, true, 5)
        end)

        it("should leave out a reward that is zero", function()
            QuestXP.GetQuestRewardMoney = function() return 250 end
            assert.are_equal("[white](250c) ", QuestChain.GetRewardText(5))

            QuestXP.GetQuestLogRewardXP = function() return 1150 end
            QuestXP.GetQuestRewardMoney = function() return 0 end
            assert.are_equal("<20>(1,150xp) ", QuestChain.GetRewardText(5))

            QuestXP.GetQuestLogRewardXP = function() return 0 end
            assert.are_equal("", QuestChain.GetRewardText(5))
        end)

        it("should ask for the XP at max level when the option is enabled", function()
            Questie.db.profile.showQuestXpAtMaxLevel = true
            QuestXP.GetQuestLogRewardXP = spy.new(function() return 0 end)

            QuestChain.GetRewardText(5)

            assert.spy(QuestXP.GetQuestLogRewardXP).was.called_with(QuestXP, 5, true)
        end)
    end)
end)
