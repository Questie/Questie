dofile("setupTests.lua")

describe("Darkmoon Faire quest data", function()
    ---@type QuestieEvent
    local QuestieEvent
    ---@type QuestieCorrections
    local QuestieCorrections
    ---@type ContentPhases
    local ContentPhases
    ---@type Expansions
    local Expansions
    local originalSoD, originalTitan, originalShowEvents
    local originalDecks = {7907, 7927, 7928, 7929}
    local sodDecks = {82055, 82056, 82057, 82058, 86760, 86761, 86762, 86763}

    before_each(function()
        originalSoD, originalTitan = Questie.IsSoD, Questie.IsTitanReforged
        originalShowEvents = Questie.db.profile.showEventQuests
        Questie.IsSoD, Questie.IsTitanReforged = false, false
        Questie.db.profile.showEventQuests = false
        Expansions = QuestieLoader:ImportModule("Expansions")
        Expansions.Current = Expansions.Era
        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.hiddenQuests = {}
        QuestieLoader:ImportModule("QuestieDB").npcDataOverrides = {}
        QuestieLoader:ImportModule("DarkmoonFaireFixes").GetNpcFixes = function() return {} end
        dofile("Localization/l10n.lua")
        dofile("Database/Corrections/ContentPhases/ContentPhases.lua")
        dofile("Database/Corrections/ContentPhases/SeasonOfDiscovery.lua")
        ContentPhases = QuestieLoader:ImportModule("ContentPhases")
    end)

    after_each(function()
        Questie.IsSoD, Questie.IsTitanReforged = originalSoD, originalTitan
        Questie.db.profile.showEventQuests = originalShowEvents
    end)

    ---Exercise quest registration and activation together, without testing calendar scheduling here.
    ---@param active boolean
    ---@return nil
    local function loadFaire(active)
        dofile("Database/Corrections/Holidays/QuestieEvent.lua")
        QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
        QuestieEvent.eventDates = {}
        QuestieEvent.lunarFestival = {DEFAULT = {}, TITAN = {}}
        QuestieEvent.eventDateCorrections = {CLASSIC = {}, TBC = {}}
        dofile("Database/Corrections/Holidays/quests/DarkmoonFaire.lua")
        local location = Expansions.Current >= Expansions.Cata and "DARKMOON_ISLAND" or "MULGORE"
        QuestieEvent:Load({status = active and "active" or "inactive", location = active and location or nil})
    end

    it("preserves the SoD phase blacklist for original decks while activating SoD quests", function()
        Questie.IsSoD = true
        -- Phase 8 is the actual data's 'never appearing in SoD' section, not a test-invented blacklist.
        ContentPhases.BlacklistSoDQuestsByPhase(QuestieCorrections.hiddenQuests, 7)
        for _, questId in ipairs(originalDecks) do
            assert.is_true(QuestieCorrections.hiddenQuests[questId])
        end

        loadFaire(true)

        for _, questId in ipairs(originalDecks) do
            assert.is_true(QuestieCorrections.hiddenQuests[questId], "Quest " .. questId)
            assert.is_nil(QuestieEvent.activeQuests[questId])
        end
        assert.is_true(QuestieEvent.activeQuests[79588])
        for _, questId in ipairs(sodDecks) do
            assert.equals("Darkmoon Faire", QuestieEvent.GetEventNameFor(questId))
            assert.is_true(QuestieEvent.IsEventActiveForQuest(questId), "Quest " .. questId)
            assert.is_nil(QuestieCorrections.hiddenQuests[questId])
        end
    end)

    it("keeps SoD decks subject to the event finisher gate outside the Faire", function()
        Questie.IsSoD = true
        ContentPhases.BlacklistSoDQuestsByPhase(QuestieCorrections.hiddenQuests, 7)

        loadFaire(false)

        for _, questId in ipairs(sodDecks) do
            -- QuestFinisher uses these three predicates to suppress unavailable event turn-ins.
            assert.is_true(QuestieEvent.IsEventQuest(questId), "Quest " .. questId)
            assert.is_false(QuestieEvent.IsEventActiveForQuest(questId))
            assert.is_false(QuestieEvent.CanQuestBeTurnedInOutsideOfEvent(questId))
        end
    end)

    it("retains the original deck quests outside SoD", function()
        for _, expansion in ipairs({Expansions.Era, Expansions.Tbc, Expansions.Wotlk, Expansions.Cata, Expansions.MoP}) do
            Expansions.Current = expansion
            for _, questId in ipairs(originalDecks) do
                QuestieCorrections.hiddenQuests[questId] = true
            end

            loadFaire(true)

            for _, questId in ipairs(originalDecks) do
                assert.is_nil(QuestieCorrections.hiddenQuests[questId])
                assert.is_true(QuestieEvent.activeQuests[questId])
            end
        end
    end)
end)
