dofile("setupTests.lua")

describe("QuestieReputation", function()
    ---@type QuestieReputation
    local QuestieReputation
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestieDB
    local QuestieDB
    ---@type Expansions
    local Expansions

    before_each(function()
        _G.GetNumFactions = spy.new(function()
            return 1
        end)
        _G.GetFactionInfo = spy.new(function()
            return "Wintersaber Trainer", "They are a faction in Winterspring", 5, nil, nil, 4500, nil, nil, false, nil, nil, nil, nil, 589, nil, nil
        end)
        _G.IsSpellKnown = spy.new(function()
            return false
        end)
        _G.UnitAura = spy.new(function()
            return nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
        end)

        Expansions = require("Modules.Expansions")
        QuestiePlayer = require("Modules.QuestiePlayer")
        QuestiePlayer.HasRequiredRace = spy.new(function() return false end)
        QuestieQuest = require("Modules.Quest.QuestieQuest")
        QuestieQuest.ResetAutoblacklistCategory = spy.new(function() end)

        QuestieDB = require("Database.QuestieDB")

        QuestieReputation = require("Modules.QuestieReputation")
    end)

    describe("HasFactionAndReputationLevel", function()
        it("should detect if the player has reached the min required reputation value", function()
            QuestieReputation:Update()

            local requiredMinRep = { 589, 4500 }

            local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, nil)

            assert.is_true(aboveMinRep)
            assert.is_true(hasMinFaction)
            assert.is_true(belowMaxRep)
            assert.is_true(hasMaxFaction)
        end)

        it("should detect if the player has not reached the min required reputation value", function()
            QuestieReputation:Update()

            local requiredMinRep = { 589, 5000 }

            local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, nil)

            assert.is_false(aboveMinRep)
            assert.is_true(hasMinFaction)
            assert.is_true(belowMaxRep)
            assert.is_true(hasMaxFaction)
        end)

        it("should detect if the player exceeds the max required reputation value", function()
            QuestieReputation:Update()

            local requiredMaxRep = { 589, 4500 }

            local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(nil, requiredMaxRep)

            assert.is_true(aboveMinRep)
            assert.is_true(hasMinFaction)
            assert.is_false(belowMaxRep)
            assert.is_true(hasMaxFaction)
        end)

        it("should detect if the player has not reached the max required reputation value", function()
            QuestieReputation:Update()

            local requiredMaxRep = { 589, 5000 }

            local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(nil, requiredMaxRep)

            assert.is_true(aboveMinRep)
            assert.is_true(hasMinFaction)
            assert.is_true(belowMaxRep)
            assert.is_true(hasMaxFaction)
        end)

        it("should detect if the player has reached the min required reputation value and not the max required reputation value", function()
            QuestieReputation:Update()

            local requiredMinRep = { 589, 4500 }
            local requiredMaxRep = { 589, 5000 }

            local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, requiredMaxRep)

            assert.is_true(aboveMinRep)
            assert.is_true(hasMinFaction)
            assert.is_true(belowMaxRep)
            assert.is_true(hasMaxFaction)
        end)

        it("should detect if the player has not reached the min required reputation value and has not reached the max required reputation value", function()
            QuestieReputation:Update()

            local requiredMinRep = { 589, 5000 }
            local requiredMaxRep = { 589, 6000 }

            local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, requiredMaxRep)

            assert.is_false(aboveMinRep)
            assert.is_true(hasMinFaction)
            assert.is_true(belowMaxRep)
            assert.is_true(hasMaxFaction)
        end)

        it("should detect if the player does not know the faction", function()
            QuestieReputation:Update()

            local requiredMinRep = { 1, 4500 }
            local requiredMaxRep = { 1, 5000 }

            local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, requiredMaxRep)

            assert.is_false(aboveMinRep)
            assert.is_false(hasMinFaction)
            assert.is_false(belowMaxRep)
            assert.is_false(hasMaxFaction)
        end)

        it("should detect if the player does not know the Darkmoon Faire faction", function()
            QuestieReputation:Update()

            local requiredMaxRep = { 909, 5000 }

            local _, _, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(nil, requiredMaxRep)

            assert.is_true(belowMaxRep)
            assert.is_true(hasMaxFaction)
        end)
    end)

    describe("GetReputationReward", function()
        it("should return the reputation reward for a quest", function()
            Questie.IsCata = false
            Expansions.Current = Expansions.Wotlk
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, 250}}
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.spy(QuestieDB.QueryQuestSingle).was_called_with(1, "reputationReward")
            assert.are.same({{909, 250}}, reputationReward)
        end)

        it("should return an empty table when a quest has no reputation reward", function()
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata
            QuestieDB.QueryQuestSingle = spy.new(function()
                return nil
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.spy(QuestieDB.QueryQuestSingle).was_called_with(1, "reputationReward")
            assert.are.same({}, reputationReward)
        end)

        it("should return 10 as reward value for difficulty 1 when Questie.IsCata is true", function()
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, 1}}
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.are.same({{909, 10}}, reputationReward)
        end)

        it("should return 25 as reward value for difficulty 2 when Questie.IsCata is true", function()
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, 2}}
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.are.same({{909, 25}}, reputationReward)
        end)

        it("should return 75 as reward value for difficulty 3 when Questie.IsCata is true", function()
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, 3}}
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.are.same({{909, 75}}, reputationReward)
        end)

        it("should return 150 as reward value for difficulty 4 when Questie.IsCata is true", function()
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, 4}}
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.are.same({{909, 150}}, reputationReward)
        end)

        it("should return 250 as reward value for difficulty 5 when Questie.IsCata is true", function()
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, 5}}
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.are.same({{909, 250}}, reputationReward)
        end)

        it("should return 350 as reward value for difficulty 6 when Questie.IsCata is true", function()
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, 6}}
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.are.same({{909, 350}}, reputationReward)
        end)

        it("should return 500 as reward value for difficulty 7 when Questie.IsCata is true", function()
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, 7}}
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.are.same({{909, 500}}, reputationReward)
        end)

        it("should return 1000 as reward value for difficulty 8 when Questie.IsCata is true", function()
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, 8}}
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.are.same({{909, 1000}}, reputationReward)
        end)

        it("should return 5 as reward value for difficulty 9 when Questie.IsCata is true", function()
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, 9}}
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.are.same({{909, 5}}, reputationReward)
        end)

        it("should return DB value for unknown difficulty when Questie.IsCata is true", function()
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, 99}}
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.are.same({{909, 99}}, reputationReward)
        end)

        it("should return -10 as reward value for difficulty -1 when Questie.IsCata is true", function()
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, -1}}
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.are.same({{909, -10}}, reputationReward)
        end)

        it("should respect diplomacy bonus", function()
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, 3}}
            end)
            QuestiePlayer.HasRequiredRace = spy.new(function() return true end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.are.same({{909, 82.5}}, reputationReward)
            assert.spy(QuestiePlayer.HasRequiredRace).was_called_with(QuestieDB.raceKeys.HUMAN)
        end)

        it("should respect Mr. Popularity rank 1 guild perk", function()
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, 3}}
            end)
            _G.IsSpellKnown = spy.new(function(spellId)
                return spellId == 78634
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.are.same({{909, 78.75}}, reputationReward)
            assert.spy(_G.IsSpellKnown).was_called_with(78634)
        end)

        it("should respect Mr. Popularity rank 2 guild perk", function()
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, 3}}
            end)
            _G.IsSpellKnown = spy.new(function(spellId)
                return spellId == 78635
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.are.same({{909, 82.5}}, reputationReward)
            assert.spy(_G.IsSpellKnown).was_called_with(78635)
        end)

        it("should respect DMF buff bonus", function()
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{909, 3}}
            end)
            _G.UnitAura = spy.new(function(_, i, _)
                return nil, nil, nil, nil, nil, nil, nil, nil, nil, 46668, nil
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)

            assert.are.same({{909, 82.5}}, reputationReward)
            assert.spy(UnitAura).was_called_with("player", 1, "HELPFUL")
        end)

        it("should show Sha'tar reputation on Aldor quests when player is below honored reputation with Sha'tar", function()
            QuestieReputation.HasReputation = spy.new(function()
                return false
            end)
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {
                    {QuestieDB.factionIDs.THE_ALDOR, 8},
                    {QuestieDB.factionIDs.THE_SHA_TAR, 8},
                }
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)
            assert.are.same({
                {QuestieDB.factionIDs.THE_ALDOR, 1000},
                {QuestieDB.factionIDs.THE_SHA_TAR, 1000},
            }, reputationReward)
            assert.spy(QuestieReputation.HasReputation).was_called_with({QuestieDB.factionIDs.THE_SHA_TAR, 9000}, nil)
        end)

        it("should show Sha'tar reputation on Scryers quests when player is below honored reputation with Sha'tar", function()
            QuestieReputation.HasReputation = spy.new(function()
                return false
            end)
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {
                    {QuestieDB.factionIDs.THE_SCRYERS, 8},
                    {QuestieDB.factionIDs.THE_SHA_TAR, 8},
                }
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)
            assert.are.same({
                {QuestieDB.factionIDs.THE_SCRYERS, 1000},
                {QuestieDB.factionIDs.THE_SHA_TAR, 1000},
            }, reputationReward)
            assert.spy(QuestieReputation.HasReputation).was_called_with({QuestieDB.factionIDs.THE_SHA_TAR, 9000}, nil)
        end)

        it("should not show Sha'tar reputation on Aldor quests when player is already honored with Sha'tar", function()
            QuestieReputation.HasReputation = spy.new(function()
                return true
            end)
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {
                    {QuestieDB.factionIDs.THE_ALDOR, 8},
                    {QuestieDB.factionIDs.THE_SHA_TAR, 8},
                }
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)
            assert.are.same({
                {QuestieDB.factionIDs.THE_ALDOR, 1000},
            }, reputationReward)
            assert.spy(QuestieReputation.HasReputation).was_called_with({QuestieDB.factionIDs.THE_SHA_TAR, 9000}, nil)
        end)

        it("should not show Sha'tar reputation on Scryers quests when player is already honored with Sha'tar", function()
            QuestieReputation.HasReputation = spy.new(function()
                return true
            end)
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {
                    {QuestieDB.factionIDs.THE_SCRYERS, 8},
                    {QuestieDB.factionIDs.THE_SHA_TAR, 8},
                }
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)
            assert.are.same({
                {QuestieDB.factionIDs.THE_SCRYERS, 1000},
            }, reputationReward)
            assert.spy(QuestieReputation.HasReputation).was_called_with({QuestieDB.factionIDs.THE_SHA_TAR, 9000}, nil)
        end)

        it("should show Scryers reputation penalty on Aldor quests for WotLK and before", function()
            Expansions.Current = Expansions.Wotlk
            QuestieReputation.HasReputation = spy.new(function()
                return false
            end)
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{QuestieDB.factionIDs.THE_ALDOR, 1000}}
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)
            assert.are.same({
                {QuestieDB.factionIDs.THE_ALDOR, 1000},
                {QuestieDB.factionIDs.THE_SCRYERS, -1100},
            }, reputationReward)
            assert.spy(QuestieReputation.HasReputation).was_called_with({QuestieDB.factionIDs.THE_SHA_TAR, 9000}, nil)
        end)

        it("should show Aldor reputation penalty on Scryers quests for WotLK and before", function()
            Expansions.Current = Expansions.Wotlk
            QuestieReputation.HasReputation = spy.new(function()
                return false
            end)
            QuestieDB.QueryQuestSingle = spy.new(function()
                return {{QuestieDB.factionIDs.THE_SCRYERS, 1000}}
            end)

            local reputationReward = QuestieReputation.GetReputationReward(1)
            assert.are.same({
                {QuestieDB.factionIDs.THE_SCRYERS, 1000},
                {QuestieDB.factionIDs.THE_ALDOR, -1100},
            }, reputationReward)
            assert.spy(QuestieReputation.HasReputation).was_called_with({QuestieDB.factionIDs.THE_SHA_TAR, 9000}, nil)
        end)
    end)

    describe("GetFactionName", function()
        it("should return friend name when found", function()
            _G.C_GossipInfo = {
                GetFriendshipReputation = spy.new(function()
                    return {name = "Jogu the Drunk"}
                end)
            }
            _G.GetFactionInfoByID = spy.new(function() end)

            local factionName = QuestieReputation.GetFactionName(1273)

            assert.are.equal("Jogu the Drunk", factionName)
            assert.spy(_G.C_GossipInfo.GetFriendshipReputation).was_called_with(1273)
            assert.spy(_G.GetFactionInfoByID).was_not_called()
        end)

        it("should return faction name when not a friend", function()
            _G.C_GossipInfo = {
                GetFriendshipReputation = spy.new(function()
                    return {}
                end)
            }
            _G.GetFactionInfoByID = spy.new(function()
                return "Wintersaber Trainers", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
            end)

            local factionName = QuestieReputation.GetFactionName(589)

            assert.are.equal("Wintersaber Trainers", factionName)
            assert.spy(_G.C_GossipInfo.GetFriendshipReputation).was_called_with(589)
            assert.spy(_G.GetFactionInfoByID).was_called_with(589)
        end)

        it("should return nil when factionId is unknown", function()
            _G.C_GossipInfo = {
                GetFriendshipReputation = spy.new(function()
                    return {}
                end)
            }
            _G.GetFactionInfoByID = spy.new(function()
                return nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
            end)

            local factionName = QuestieReputation.GetFactionName(1)

            assert.is_nil(factionName)
            assert.spy(_G.C_GossipInfo.GetFriendshipReputation).was_called_with(1)
            assert.spy(_G.GetFactionInfoByID).was_called_with(1)
        end)
    end)
end)
