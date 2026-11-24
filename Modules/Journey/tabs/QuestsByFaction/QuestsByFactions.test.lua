dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("The quests of a faction", function()
    local questsByFaction
    local ui
    local originalQuestie, originalTinsert, originalExpansionName
    local states

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie, originalTinsert, originalExpansionName = _G.Questie, _G.tinsert, _G.EXPANSION_NAME0
        _G.EXPANSION_NAME0 = "Classic"
        _G.Questie = {
            db = {char = {complete = {}, hidden = {}}, profile = {}},
            Colorize = function(_, text) return text end,
            Error = function(_, message) error(message) end,
        }
        states = {}

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/ThreadLib.lua")
        dofile("Modules/Journey/JourneyThread.lua")

        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.DoableStates = {AVAILABLE = 1, COMPLETED = 2}
        QuestieDB.QuestPointers = setmetatable({}, {__index = function(_, id) return id < 1000 or nil end})
        QuestieDB.IsDoableVerbose = function(id) return "", true, QuestieDB.DoableStates[states[id] or "AVAILABLE"] end
        QuestieDB.IsRepeatable = function() return false end
        QuestieDB.QueryQuest = function() return {0} end
        local Expansions = QuestieLoader:ImportModule("Expansions")
        Expansions.Era, Expansions.Tbc, Expansions.Wotlk, Expansions.Cata, Expansions.MoP, Expansions.Current = 1, 2, 3, 4, 5, 1
        QuestieLoader:ImportModule("ActiveQuests").Get = function() end
        local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
        QuestieReputation.GetReputationReward = function(id) return id == 7 and {{576, 150}} or {} end
        QuestieReputation.GetReputationRewardString = function(rewards) return "+" .. rewards[1][2] .. " Timbermaw Hold" end
        QuestieLoader:ImportModule("QuestieJourneyFactions").BuildFactionIntroductionOrder = function() return {} end
        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetColoredQuestName = function(_, id) return "Quest " .. id end
        QuestieLib.SortQuestIDsByLevel = function(_, quests, _, onQuestLookedUp)
            local sorted = {}
            for id in pairs(quests) do
                table.insert(sorted, {10, id})
                onQuestLookedUp()
            end
            table.sort(sorted, function(a, b) return a[2] < b[2] end)
            return sorted
        end

        local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
        dofile("Modules/Journey/tabs/QuestsByFaction/QuestsByFactions.lua")
        QuestieJourney.factionMap = {[576] = {[7] = true, [8] = true, [1234] = true}}
        questsByFaction = QuestieJourney.private.questsByFaction
    end)

    after_each(function()
        _G.Questie, _G.tinsert, _G.EXPANSION_NAME0 = originalQuestie, originalTinsert, originalExpansionName
        ui.Restore()
    end)

    ---@param factionId number
    ---@return JourneyTreeNode[]? nodes
    ---@return number frames
    local function Collect(factionId)
        local nodes
        QuestieLoader:ImportModule("JourneyThread").Start("Test", function()
            nodes = questsByFaction:CollectFactionQuests(factionId)
        end)
        local frames = ui.RunUntilIdle()
        return nodes, frames
    end

    it("should be in categories, with the reputation they give", function()
        states[8] = "COMPLETED"

        local nodes = Collect(576)

        local texts = {}
        for _, category in ipairs(nodes) do
            for _, quest in ipairs(category.children) do texts[category.value] = quest.text end
        end
        assert.are_same({a = "Quest 7 (+150 Timbermaw Hold)", c = "Quest 8"}, texts)
    end)

    it("should be nothing for a faction without quests", function()
        local nodes = Collect(404)

        assert.is_nil(nodes)
    end)

    describe("when there are many", function()
        local SortQuestIDsByLevel

        before_each(function()
            ui.clockStep = 0.003
            local quests = {}
            for id = 1, 100 do quests[id] = true end
            QuestieLoader:ImportModule("QuestieJourney").factionMap = {[576] = quests}
            SortQuestIDsByLevel = QuestieLoader:ImportModule("QuestieLib").SortQuestIDsByLevel
        end)

        it("should be sorted over several frames", function()
            QuestieLoader:ImportModule("QuestieLib").SortQuestIDsByLevel = function(...)
                SortQuestIDsByLevel(...)
                return {}
            end

            local _, frames = Collect(576)

            assert.is_true(frames > 20)
        end)

        it("should be put into categories over several frames", function()
            QuestieLoader:ImportModule("QuestieLib").SortQuestIDsByLevel = function(_, unsorted)
                return SortQuestIDsByLevel(_, unsorted, false, function() end)
            end

            local _, frames = Collect(576)

            assert.is_true(frames > 20)
        end)
    end)
end)
