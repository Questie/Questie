dofile("setupTests.lua")
local stub = require("luassert.stub")

describe("QuestieAnnounce", function()
    ---@type QuestieAnnounce
    local QuestieAnnounce

    ---@type QuestieLink
    local QuestieLink
    local getItemInfoMock, addFilterMock

    before_each(function()
        _G.SendChatMessage = spy.new(function() end)
        _G.IsInRaid = function() return false end
        _G.IsInGroup = function() return false end
        _G.LE_PARTY_CATEGORY_INSTANCE = nil

        Questie.db.profile = {
            questAnnounceObjectives = true,
            questAnnounceLocally = false,
            questAnnounceChannel = "party",
            questieShutUp = false,
        }

        QuestieLink = QuestieLoader:ImportModule("QuestieLink")
        addFilterMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "AddMessageEventFilter")
        getItemInfoMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "GetItemInfo")

        dofile("Localization/l10n.lua")
        dofile("Modules/QuestieAnnounce.lua")
        QuestieAnnounce = QuestieLoader:ImportModule("QuestieAnnounce")
    end)

    after_each(function()
        getItemInfoMock:revert()
        addFilterMock:revert()
    end)

    it("registers the logo filter for group chat", function()
        QuestieAnnounce:InitializeLogoFilter()

        assert.spy(addFilterMock).was.called(6)
        assert.spy(addFilterMock).was.called_with("CHAT_MSG_PARTY", QuestieAnnounce.LogoFilter)
        assert.spy(addFilterMock).was.called_with("CHAT_MSG_INSTANCE_CHAT_LEADER", QuestieAnnounce.LogoFilter)
    end)

    it("should announce a quest-starting item using its item hyperlink", function()
        _G.IsInGroup = function() return true end
        Questie.db.profile.questAnnounceItems = true
        QuestieLink.GetNativeQuestLinkStringById = function() return "[The Quest]" end
        getItemInfoMock.returns("A Letter", "|Hitem:123|h[A Letter]|h")

        local announced = QuestieAnnounce:AnnounceQuestItemLootedToChannel(1, 123)

        assert.is_true(announced)
        assert.spy(getItemInfoMock).was.called_with(123)
        assert.spy(_G.SendChatMessage).was.called_with(
            "{rt1} Questie: Picked up |Hitem:123|h[A Letter]|h which starts [The Quest]!", "INSTANCE_CHAT")
    end)

    describe("ObjectiveChanged", function()
        it("announces completion when native progress text changes", function()
            _G.IsInGroup = function() return true end
            QuestieLink.GetNativeQuestLinkStringById = function() return "[The Quest]" end

            QuestieAnnounce:ObjectiveChanged(1, 3, "2/5 Windstone Cluster", 2, 5)
            assert.spy(_G.SendChatMessage).was.not_called()
            QuestieAnnounce:ObjectiveChanged(1, 3, "5/5 Windstone Cluster", 5, 5)

            assert.spy(_G.SendChatMessage).was.called(1)
            assert.spy(_G.SendChatMessage).was.called_with(
                "{rt1} Questie: 5/5 Windstone Cluster for [The Quest]!", "INSTANCE_CHAT")
        end)

        it("tracks identical wording independently across quests and native indices", function()
            QuestieAnnounce.AnnounceObjectiveToChannel = spy.new(function() end)
            QuestieAnnounce:ObjectiveChanged(1, 1, "Target: 0/1", 0, 1)
            QuestieAnnounce:ObjectiveChanged(1, 3, "Target: 0/1", 0, 1)
            QuestieAnnounce:ObjectiveChanged(2, 1, "Target: 0/1", 0, 1)

            QuestieAnnounce:ObjectiveChanged(1, 1, "Target: 1/1", 1, 1)
            QuestieAnnounce:ObjectiveChanged(1, 3, "Target: 1/1", 1, 1)
            QuestieAnnounce:ObjectiveChanged(2, 1, "Target: 1/1", 1, 1)

            assert.spy(QuestieAnnounce.AnnounceObjectiveToChannel).was.called(3)
            assert.spy(QuestieAnnounce.AnnounceObjectiveToChannel).was.called_with(QuestieAnnounce, 1, "Target: 1/1")
            assert.spy(QuestieAnnounce.AnnounceObjectiveToChannel).was.called_with(QuestieAnnounce, 2, "Target: 1/1")
        end)

        it("does not announce an objective first observed complete", function()
            QuestieAnnounce.AnnounceObjectiveToChannel = spy.new(function() end)

            QuestieAnnounce:ObjectiveChanged(1, 1, "Target: 1/1", 1, 1)

            assert.spy(QuestieAnnounce.AnnounceObjectiveToChannel).was.not_called()
        end)

        it("retains the once-announced policy even if wording or counts change again", function()
            QuestieAnnounce.AnnounceObjectiveToChannel = spy.new(function() end)
            QuestieAnnounce:ObjectiveChanged(1, 1, "Target: 0/1", 0, 1)
            QuestieAnnounce:ObjectiveChanged(1, 1, "Target: 1/1", 1, 1)

            QuestieAnnounce:ObjectiveChanged(1, 1, "Target: 1/1", 1, 1)
            QuestieAnnounce:ObjectiveChanged(1, 1, "Updated instruction: 0/1", 0, 1)
            QuestieAnnounce:ObjectiveChanged(1, 1, "Updated instruction: 1/1", 1, 1)

            assert.spy(QuestieAnnounce.AnnounceObjectiveToChannel).was.called(1)
        end)
    end)

    describe("AnnounceObjectiveToChannel", function()
        local nativeTexts = {
            {name = "Classic counter placement", text = "Wolf slain: 5/5"},
            {name = "localized wording and punctuation", text = "5/5 烈风已摧毁。"},
            {name = "instructions without a counter", text = "Use Walk on Air"},
        }
        for _, case in ipairs(nativeTexts) do
            it("preserves " .. case.name .. " in native announcement text", function()
                _G.IsInGroup = function() return true end
                QuestieLink.GetNativeQuestLinkStringById = function() return "[The Quest]" end

                QuestieAnnounce:AnnounceObjectiveToChannel(1, case.text)

                assert.spy(_G.SendChatMessage).was.called_with(
                    "{rt1} Questie: " .. case.text .. " for [The Quest]!", "INSTANCE_CHAT")
            end)
        end

        it("should not announce when questAnnounceObjectives is disabled", function()
            Questie.db.profile.questAnnounceObjectives = false

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "1/10 Kill goblins")

            assert.spy(_G.SendChatMessage).was.not_called()
        end)

        it("should not announce when not in the correct channel", function()
            QuestieAnnounce:AnnounceObjectiveToChannel(1, "1/10 Kill ogres")

            assert.spy(_G.SendChatMessage).was.not_called()
        end)

        it("should announce to party chat when not in an instance group", function()
            _G.LE_PARTY_CATEGORY_INSTANCE = 0
            _G.IsInGroup = function(groupType)
                if groupType == LE_PARTY_CATEGORY_INSTANCE then
                    return false
                end
                return true
            end
            QuestieLink.GetNativeQuestLinkStringById = function() return "|cff...questLink|r" end

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "1/10 Kill wolves")

            assert.spy(_G.SendChatMessage).was.called_with("{rt1} Questie: 1/10 Kill wolves for |cff...questLink|r!", "PARTY")
        end)

        it("should announce to instance chat when in an instance group", function()
            _G.IsInGroup = function() return true end
            QuestieLink.GetNativeQuestLinkStringById = function() return "|cff...questLink|r" end

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "2/10 Kill wolves")

            assert.spy(_G.SendChatMessage).was.called_with("{rt1} Questie: 2/10 Kill wolves for |cff...questLink|r!", "INSTANCE_CHAT")
        end)

        it("should print locally when questAnnounceLocally is true and channel is disabled even when in a party", function()
            _G.LE_PARTY_CATEGORY_INSTANCE = 0
            _G.IsInGroup = function(groupType)
                if groupType == LE_PARTY_CATEGORY_INSTANCE then
                    return false
                end
                return true
            end
            Questie.db.profile.questAnnounceLocally = true
            Questie.db.profile.questAnnounceChannel = "disabled"
            QuestieLink.GetNativeQuestLinkStringById = function() return "|cff...questLink|r" end
            QuestieLink.GetQuestHyperLink = function() return "|Hquestie:1:guid|h[Quest Name]|h" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "3/10 Kill wolves")

            assert.spy(_G.SendChatMessage).was.not_called()
            assert.spy(Questie.Print).was.called_with(Questie, "3/10 Kill wolves for |Hquestie:1:guid|h[Quest Name]|h!")
        end)

        it("should print locally when questAnnounceLocally is true and channel is disabled and not in a group", function()
            Questie.db.profile.questAnnounceLocally = true
            Questie.db.profile.questAnnounceChannel = "disabled"
            QuestieLink.GetNativeQuestLinkStringById = function() return "|cff...questLink|r" end
            QuestieLink.GetQuestHyperLink = function() return "|Hquestie:1:guid|h[Quest Name]|h" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "4/10 Kill wolves")

            assert.spy(_G.SendChatMessage).was.not_called()
            assert.spy(Questie.Print).was.called_with(Questie, "4/10 Kill wolves for |Hquestie:1:guid|h[Quest Name]|h!")
        end)

        it("should print locally and to group when questAnnounceLocally is true and channel is not disabled when in a party", function()
            _G.LE_PARTY_CATEGORY_INSTANCE = 0
            _G.IsInGroup = function(groupType)
                if groupType == LE_PARTY_CATEGORY_INSTANCE then
                    return false
                end
                return true
            end
            Questie.db.profile.questAnnounceLocally = true
            Questie.db.profile.questAnnounceChannel = "party"
            QuestieLink.GetNativeQuestLinkStringById = function() return "|cff...questLink|r" end
            QuestieLink.GetQuestHyperLink = function() return "|Hquestie:1:guid|h[Quest Name]|h" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "5/10 Kill wolves")

            assert.spy(_G.SendChatMessage).was.called_with("{rt1} Questie: 5/10 Kill wolves for |cff...questLink|r!", "PARTY")
            assert.spy(Questie.Print).was.called_with(Questie, "5/10 Kill wolves for |Hquestie:1:guid|h[Quest Name]|h!")
        end)

        it("should not announce at all when questAnnounceLocally is false and channel is disabled", function()
            _G.LE_PARTY_CATEGORY_INSTANCE = 0
            _G.IsInGroup = function(groupType)
                if groupType == LE_PARTY_CATEGORY_INSTANCE then
                    return false
                end
                return true
            end
            Questie.db.profile.questAnnounceLocally = false
            Questie.db.profile.questAnnounceChannel = "disabled"
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "6/10 Kill wolves")

            assert.spy(_G.SendChatMessage).was.not_called()
            assert.spy(Questie.Print).was.not_called()
        end)

        it("should not announce at all when questieShutUp is active", function()
            _G.IsInGroup = function() return true end
            Questie.db.profile.questAnnounceLocally = true
            Questie.db.profile.questAnnounceChannel = "party"
            Questie.db.profile.questieShutUp = true
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "7/10 Kill wolves")

            assert.spy(_G.SendChatMessage).was.not_called()
            assert.spy(Questie.Print).was.not_called()
        end)

        it("should print locally only when questAnnounceLocally is true and channel is raid but player is in party", function()
            _G.LE_PARTY_CATEGORY_INSTANCE = 0
            _G.IsInRaid = function() return false end
            _G.IsInGroup = function(groupType)
                if groupType == LE_PARTY_CATEGORY_INSTANCE then
                    return false
                end
                return true
            end
            Questie.db.profile.questAnnounceLocally = true
            Questie.db.profile.questAnnounceChannel = "raid"
            QuestieLink.GetNativeQuestLinkStringById = function() return "|cff...questLink|r" end
            QuestieLink.GetQuestHyperLink = function() return "|Hquestie:1:guid|h[Quest Name]|h" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "8/10 Kill wolves")

            assert.spy(_G.SendChatMessage).was.not_called()
            assert.spy(Questie.Print).was.called_with(Questie, "8/10 Kill wolves for |Hquestie:1:guid|h[Quest Name]|h!")
        end)

        it("should print locally only when questAnnounceLocally is true and channel is party but player is in raid", function()
            _G.IsInRaid = function() return true end
            _G.IsInGroup = function() return true end
            Questie.db.profile.questAnnounceLocally = true
            Questie.db.profile.questAnnounceChannel = "party"
            QuestieLink.GetNativeQuestLinkStringById = function() return "|cff...questLink|r" end
            QuestieLink.GetQuestHyperLink = function() return "|Hquestie:1:guid|h[Quest Name]|h" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "9/10 Kill wolves")

            assert.spy(_G.SendChatMessage).was.not_called()
            assert.spy(Questie.Print).was.called_with(Questie, "9/10 Kill wolves for |Hquestie:1:guid|h[Quest Name]|h!")
        end)

        it("should not announce when questAnnounceLocally is false and channel is party but player is in raid", function()
            _G.IsInRaid = function() return true end
            _G.IsInGroup = function() return true end
            Questie.db.profile.questAnnounceLocally = false
            Questie.db.profile.questAnnounceChannel = "party"
            QuestieLink.GetNativeQuestLinkStringById = function() return "|cff...questLink|r" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "10/10 Kill wolves")

            assert.spy(_G.SendChatMessage).was.not_called()
            assert.spy(Questie.Print).was.not_called()
        end)

        it("should not announce when questAnnounceLocally is false and channel is raid but player is in party", function()
            _G.LE_PARTY_CATEGORY_INSTANCE = 0
            _G.IsInRaid = function() return false end
            _G.IsInGroup = function(groupType)
                if groupType == LE_PARTY_CATEGORY_INSTANCE then
                    return false
                end
                return true
            end
            Questie.db.profile.questAnnounceLocally = false
            Questie.db.profile.questAnnounceChannel = "raid"
            QuestieLink.GetNativeQuestLinkStringById = function() return "|cff...questLink|r" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "11/10 Kill wolves")

            assert.spy(_G.SendChatMessage).was.not_called()
            assert.spy(Questie.Print).was.not_called()
        end)

        it("should print locally and announce to raid chat when questAnnounceLocally is true and channel is raid and player is in raid", function()
            _G.IsInRaid = function() return true end
            _G.IsInGroup = function() return true end
            Questie.db.profile.questAnnounceLocally = true
            Questie.db.profile.questAnnounceChannel = "raid"
            QuestieLink.GetNativeQuestLinkStringById = function() return "|cff...questLink|r" end
            QuestieLink.GetQuestHyperLink = function() return "|Hquestie:1:guid|h[Quest Name]|h" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "12/10 Kill wolves")

            assert.spy(_G.SendChatMessage).was.called_with("{rt1} Questie: 12/10 Kill wolves for |cff...questLink|r!", "RAID")
            assert.spy(Questie.Print).was.called_with(Questie, "12/10 Kill wolves for |Hquestie:1:guid|h[Quest Name]|h!")
        end)

        it("should not include announce marker in local print when questAnnounceLocally is true and in a party", function()
            _G.LE_PARTY_CATEGORY_INSTANCE = 0
            _G.IsInGroup = function(groupType)
                if groupType == LE_PARTY_CATEGORY_INSTANCE then
                    return false
                end
                return true
            end
            Questie.db.profile.questAnnounceLocally = true
            Questie.db.profile.questAnnounceChannel = "party"
            QuestieLink.GetNativeQuestLinkStringById = function() return "|cff...questLink|r" end
            QuestieLink.GetQuestHyperLink = function() return "|Hquestie:1:guid|h[Quest Name]|h" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "13/10 Kill wolves")

            assert.spy(_G.SendChatMessage).was.called_with("{rt1} Questie: 13/10 Kill wolves for |cff...questLink|r!", "PARTY")
            assert.spy(Questie.Print).was.called_with(Questie, "13/10 Kill wolves for |Hquestie:1:guid|h[Quest Name]|h!")
        end)

        it("should use quest hyperlink in local print when questAnnounceLocally is true", function()
            _G.LE_PARTY_CATEGORY_INSTANCE = 0
            _G.IsInGroup = function(groupType)
                if groupType == LE_PARTY_CATEGORY_INSTANCE then
                    return false
                end
                return true
            end
            Questie.db.profile.questAnnounceLocally = true
            Questie.db.profile.questAnnounceChannel = "party"
            QuestieLink.GetNativeQuestLinkStringById = function() return "plain quest link" end
            QuestieLink.GetQuestHyperLink = function() return "|Hquestie:1:guid|h[Quest Name]|h" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "14/10 Kill wolves")

            assert.spy(_G.SendChatMessage).was.called_with("{rt1} Questie: 14/10 Kill wolves for plain quest link!", "PARTY")
            assert.spy(Questie.Print).was.called_with(Questie, "14/10 Kill wolves for |Hquestie:1:guid|h[Quest Name]|h!")
        end)
    end)
end)
