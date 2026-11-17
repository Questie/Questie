dofile("setupTests.lua")
dofile("Database/Corrections/ContentPhases/ContentPhases.lua")

describe("native advanced options", function()
    local ContentPhases, QuestieQuest
    local originalTbcPhase, originalIsTBC
    local originalDb
    local phaseSelector, reminderToggle

    before_each(function()
        originalDb = Questie.db
        originalIsTBC = Questie.IsTBC
        ContentPhases = QuestieLoader:ImportModule("ContentPhases")
        originalTbcPhase = ContentPhases.activePhases.TBC
        Questie.IsTBC = true
        Questie.db = {profile = {}, char = {}, global = {}}
        QuestieLoader:ImportModule("QuestiePopup").Dialogs = {}
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.SmoothReset = spy.new(function() end)
        local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
        QuestieOptionsEngine.tabs = {}
        dofile("Modules/Options/QuestieOptionsDefaults.lua")
        dofile("Modules/Options/NativeOptions/NativeOptionsAdvanced.lua")
        local items = QuestieOptionsEngine.tabs.advanced:Initialize().items
        phaseSelector = items.npcrules_group.items.isleOfQuelDanasPhase
        reminderToggle = items.npcrules_group.items.isleOfQuelDanasPhaseReminder
    end)

    after_each(function()
        ContentPhases.activePhases.TBC = originalTbcPhase
        Questie.IsTBC = originalIsTBC
        Questie.db = originalDb
    end)

    describe("Isle of Quel'Danas phase selector", function()
        it("is unavailable before TBC content phase 5", function()
            ContentPhases.activePhases.TBC = 4

            assert.is_false(phaseSelector.enabled())
        end)

        it("is available from TBC content phase 5 onward", function()
            ContentPhases.activePhases.TBC = 5
            assert.is_true(phaseSelector.enabled())

            ContentPhases.activePhases.TBC = 6
            assert.is_true(phaseSelector.enabled())
        end)

        it("reads the global phase and ignores a stale profile value", function()
            Questie.db.profile.isleOfQuelDanasPhase = 1
            Questie.db.global.isleOfQuelDanasPhase = 6

            assert.are_equal(6, phaseSelector.get())
        end)

        it("stores the selected phase in the global scope and redraws the quests", function()
            Questie.db.global.isleOfQuelDanasPhase = 1

            phaseSelector.set(7)

            assert.are_equal(7, Questie.db.global.isleOfQuelDanasPhase)
            assert.is_nil(Questie.db.profile.isleOfQuelDanasPhase)
            assert.spy(QuestieQuest.SmoothReset).was.called(1)
        end)

        it("does not define a profile default for the phase", function()
            local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults")

            assert.is_nil(QuestieOptionsDefaults:Load().profile.isleOfQuelDanasPhase)
        end)
    end)

    describe("Disable Phase reminder toggle", function()
        it("is enabled on TBC", function()
            local Expansions = QuestieLoader:ImportModule("Expansions")
            local originalCurrent = Expansions.Current
            Expansions.Current = Expansions.Tbc

            local isEnabled = reminderToggle.enabled == nil or reminderToggle.enabled()
            Expansions.Current = originalCurrent

            assert.is_true(isEnabled)
        end)
    end)
end)
