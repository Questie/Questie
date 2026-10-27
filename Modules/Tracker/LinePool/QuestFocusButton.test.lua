dofile("setupTests.lua")

describe("QuestFocusButton", function()
    ---@type QuestFocusButton
    local QuestFocusButton
    ---@type TrackerUtils
    local TrackerUtils
    ---@type TrackerMapEligibility
    local TrackerMapEligibility
    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestieTracker
    local QuestieTracker
    ---@type QuestieCombatQueue
    local QuestieCombatQueue

    local canFocusQuest
    local enrichedQuest
    local quest
    local QuestieCompat
    local superTrackingSupported
    local superTrackedQuestId

    before_each(function()
        Questie.db.profile.trackerShowQuestFocusButtons = true
        Questie.db.profile.trackerFontSizeQuest = 12
        Questie.db.char.TrackerFocus = nil

        canFocusQuest = true
        enrichedQuest = {Id = 123}
        quest = {Id = 123, enrichment = enrichedQuest}

        TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        TrackerUtils.FocusQuest = spy.new(function() return true end)
        TrackerUtils.UnFocus = spy.new(function() end)
        TrackerMapEligibility = QuestieLoader:ImportModule("TrackerMapEligibility")
        TrackerMapEligibility.GetCapabilities = function() return {canFocusQuest = canFocusQuest} end
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.ToggleNotes = spy.new(function() end)
        QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
        QuestieTracker.Update = spy.new(function() end)
        QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
        QuestieCombatQueue.Queue = function(_, callback) callback() end
        superTrackingSupported = false
        superTrackedQuestId = nil
        QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        QuestieCompat.IsSuperTrackingSupported = function() return superTrackingSupported end
        QuestieCompat.GetSuperTrackedQuestID = function() return superTrackedQuestId end
        QuestieCompat.SetSuperTrackedQuestID = spy.new(function() end)
        QuestieCompat.ClearSuperTrackedQuest = spy.new(function() end)

        dofile("Modules/Tracker/LinePool/QuestFocusButton.lua")
        QuestFocusButton = QuestieLoader:ImportModule("QuestFocusButton")
    end)

    describe("GetColumnWidth", function()
        it("should reserve the quest font size plus spacing when enabled", function()
            assert.are_same(17, QuestFocusButton.GetColumnWidth())
        end)

        it("should reserve no space when disabled", function()
            Questie.db.profile.trackerShowQuestFocusButtons = false

            assert.are_same(0, QuestFocusButton.GetColumnWidth())
        end)
    end)

    describe("New", function()
        it("should start faded when the fade setting is enabled", function()
            Questie.db.profile.trackerFadeQuestFocusButtons = true

            local button = QuestFocusButton.New(1, CreateFrame("Button"))

            assert.are_same(0, button:GetAlpha())
        end)

        it("should start visible when the fade setting is disabled", function()
            Questie.db.profile.trackerFadeQuestFocusButtons = false

            local button = QuestFocusButton.New(1, CreateFrame("Button"))

            assert.are_same(1, button:GetAlpha())
        end)
    end)

    describe("SetQuest", function()
        it("should show the incomplete icon for an unfocused quest in progress", function()
            local button = QuestFocusButton.New(1, CreateFrame("Button"))

            button:SetQuest(quest, false)

            assert.is_true(button:IsVisible())
            assert.are_same(QuestFocusButton.TEXTURES.incomplete, button:GetNormalTexture():GetTexture())
        end)

        it("should be as big as the expand quest button", function()
            local button = QuestFocusButton.New(1, CreateFrame("Button"))

            button:SetQuest(quest, false)

            assert.are_same(15, button:GetWidth())
            assert.are_same(15, button:GetHeight())
        end)

        it("should show the complete icon for a completed quest", function()
            local button = QuestFocusButton.New(1, CreateFrame("Button"))

            button:SetQuest(quest, true)

            assert.are_same(QuestFocusButton.TEXTURES.complete, button:GetNormalTexture():GetTexture())
        end)

        it("should show the focused icon when the quest is focused", function()
            Questie.db.char.TrackerFocus = 123
            local button = QuestFocusButton.New(1, CreateFrame("Button"))

            button:SetQuest(quest, true)

            assert.are_same(QuestFocusButton.TEXTURES.completeFocused, button:GetNormalTexture():GetTexture())
        end)

        it("should hide when the setting is disabled", function()
            Questie.db.profile.trackerShowQuestFocusButtons = false
            local button = QuestFocusButton.New(1, CreateFrame("Button"))

            button:SetQuest(quest, false)

            assert.is_false(button:IsVisible())
        end)

        it("should hide when the quest can not be focused", function()
            canFocusQuest = false
            local button = QuestFocusButton.New(1, CreateFrame("Button"))

            button:SetQuest(quest, false)

            assert.is_false(button:IsVisible())
        end)

        it("should stay visible for a focused quest that can no longer be focused, so it can be unfocused", function()
            canFocusQuest = false
            Questie.db.char.TrackerFocus = 123
            local button = QuestFocusButton.New(1, CreateFrame("Button"))

            button:SetQuest(quest, false)

            assert.is_true(button:IsVisible())
        end)

        it("should show for a quest Questie can not focus when the client supports super tracking", function()
            canFocusQuest = false
            superTrackingSupported = true
            local button = QuestFocusButton.New(1, CreateFrame("Button"))

            button:SetQuest(quest, false)

            assert.is_true(button:IsVisible())
            assert.are_same(QuestFocusButton.TEXTURES.incomplete, button:GetNormalTexture():GetTexture())
        end)

        it("should show the focused icon for the super tracked quest", function()
            canFocusQuest = false
            superTrackingSupported = true
            superTrackedQuestId = 123
            local button = QuestFocusButton.New(1, CreateFrame("Button"))

            button:SetQuest(quest, false)

            assert.are_same(QuestFocusButton.TEXTURES.incompleteFocused, button:GetNormalTexture():GetTexture())
        end)
    end)

    describe("OnClick", function()
        it("should super track a quest Questie can not focus", function()
            canFocusQuest = false
            superTrackingSupported = true
            TrackerUtils.FocusQuest = spy.new(function() return false end)
            local button = QuestFocusButton.New(1, CreateFrame("Button"))
            button:SetQuest(quest, false)

            button.scripts.OnClick(button)

            assert.spy(QuestieCompat.SetSuperTrackedQuestID).was.called_with(123)
            assert.spy(QuestieQuest.ToggleNotes).was.not_called()
            assert.spy(QuestieTracker.Update).was.called()
        end)

        it("should clear super tracking of a super tracked quest Questie has not focused", function()
            canFocusQuest = false
            superTrackingSupported = true
            superTrackedQuestId = 123
            local button = QuestFocusButton.New(1, CreateFrame("Button"))
            button:SetQuest(quest, false)

            button.scripts.OnClick(button)

            assert.spy(QuestieCompat.ClearSuperTrackedQuest).was.called()
            assert.spy(TrackerUtils.UnFocus).was.not_called()
            assert.spy(TrackerUtils.FocusQuest).was.not_called()
            assert.spy(QuestieTracker.Update).was.called()
        end)

        it("should focus an unfocused quest", function()
            local button = QuestFocusButton.New(1, CreateFrame("Button"))
            button:SetQuest(quest, false)

            button.scripts.OnClick(button)

            assert.spy(TrackerUtils.FocusQuest).was.called_with(TrackerUtils, 123, enrichedQuest)
            assert.spy(QuestieQuest.ToggleNotes).was.called_with(QuestieQuest, false)
            assert.spy(QuestieTracker.Update).was.called()
        end)

        it("should not hide other quests when focusing fails", function()
            TrackerUtils.FocusQuest = spy.new(function() return false end)
            local button = QuestFocusButton.New(1, CreateFrame("Button"))
            button:SetQuest(quest, false)

            button.scripts.OnClick(button)

            assert.spy(QuestieQuest.ToggleNotes).was.not_called()
        end)

        it("should unfocus a focused quest", function()
            Questie.db.char.TrackerFocus = 123
            local button = QuestFocusButton.New(1, CreateFrame("Button"))
            button:SetQuest(quest, false)

            button.scripts.OnClick(button)

            assert.spy(TrackerUtils.UnFocus).was.called()
            assert.spy(TrackerUtils.FocusQuest).was.not_called()
            assert.spy(QuestieQuest.ToggleNotes).was.called_with(QuestieQuest, true)
            assert.spy(QuestieTracker.Update).was.called()
        end)
    end)
end)
