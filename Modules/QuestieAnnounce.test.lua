dofile("setupTests.lua")

describe("QuestieAnnounce", function()
    ---@type QuestieAnnounce
    local QuestieAnnounce

    ---@type QuestieLink
    local QuestieLink

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

        QuestieLink = require("Modules.QuestLinks.Link")

        require("Localization.l10n")
        QuestieAnnounce = require("Modules.QuestieAnnounce")
    end)

    describe("AnnounceObjectiveToChannel", function()
        it("should not announce when questAnnounceObjectives is disabled", function()
            Questie.db.profile.questAnnounceObjectives = false

            QuestieAnnounce:AnnounceObjectiveToChannel(1, nil, "Kill goblins", "1/10")

            assert.spy(_G.SendChatMessage).was_not_called()
        end)

        it("should not announce when not in the correct channel", function()
            QuestieAnnounce:AnnounceObjectiveToChannel(1, nil, "Kill ogres", "1/10")

            assert.spy(_G.SendChatMessage).was_not_called()
        end)

        it("should announce to party chat when not in an instance group", function()
            _G.LE_PARTY_CATEGORY_INSTANCE = 0
            _G.IsInGroup = function(groupType)
                if groupType == LE_PARTY_CATEGORY_INSTANCE then
                    return false
                end
                return true
            end
            QuestieLink.GetQuestLinkStringById = function() return "|cff...questLink|r" end

            QuestieAnnounce:AnnounceObjectiveToChannel(1, nil, "Kill wolves", "1/10")

            assert.spy(_G.SendChatMessage).was_called_with("{rt1} Questie: 1/10 Kill wolves for |cff...questLink|r!", "PARTY")
        end)

        it("should announce to instance chat when in an instance group", function()
            _G.IsInGroup = function() return true end
            QuestieLink.GetQuestLinkStringById = function() return "|cff...questLink|r" end

            QuestieAnnounce:AnnounceObjectiveToChannel(1, nil, "Kill wolves", "2/10")

            assert.spy(_G.SendChatMessage).was_called_with("{rt1} Questie: 2/10 Kill wolves for |cff...questLink|r!", "INSTANCE_CHAT")
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
            QuestieLink.GetQuestLinkStringById = function() return "|cff...questLink|r" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, nil, "Kill wolves", "3/10")

            assert.spy(_G.SendChatMessage).was_not_called()
            assert.spy(Questie.Print).was_called_with(Questie, "{rt1} Questie: 3/10 Kill wolves for |cff...questLink|r!")
        end)

        it("should print locally when questAnnounceLocally is true and channel is disabled and not in a group", function()
            Questie.db.profile.questAnnounceLocally = true
            Questie.db.profile.questAnnounceChannel = "disabled"
            QuestieLink.GetQuestLinkStringById = function() return "|cff...questLink|r" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, nil, "Kill wolves", "4/10")

            assert.spy(_G.SendChatMessage).was_not_called()
            assert.spy(Questie.Print).was_called_with(Questie, "4/10 Kill wolves for |cff...questLink|r!")
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
            QuestieLink.GetQuestLinkStringById = function() return "|cff...questLink|r" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, nil, "Kill wolves", "5/10")

            assert.spy(_G.SendChatMessage).was_called_with("{rt1} Questie: 5/10 Kill wolves for |cff...questLink|r!", "PARTY")
            assert.spy(Questie.Print).was_called_with(Questie, "{rt1} Questie: 5/10 Kill wolves for |cff...questLink|r!")
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

            QuestieAnnounce:AnnounceObjectiveToChannel(1, nil, "Kill wolves", "6/10")

            assert.spy(_G.SendChatMessage).was_not_called()
            assert.spy(Questie.Print).was_not_called()
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
            QuestieLink.GetQuestLinkStringById = function() return "|cff...questLink|r" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "Kill wolves", "8/10")

            assert.spy(_G.SendChatMessage).was_not_called()
            assert.spy(Questie.Print).was_called_with(Questie, "{rt1} Questie: 8/10 Kill wolves for |cff...questLink|r!")
        end)

        it("should print locally only when questAnnounceLocally is true and channel is party but player is in raid", function()
            _G.IsInRaid = function() return true end
            _G.IsInGroup = function() return true end
            Questie.db.profile.questAnnounceLocally = true
            Questie.db.profile.questAnnounceChannel = "party"
            QuestieLink.GetQuestLinkStringById = function() return "|cff...questLink|r" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "Kill wolves", "9/10")

            assert.spy(_G.SendChatMessage).was_not_called()
            assert.spy(Questie.Print).was_called_with(Questie, "{rt1} Questie: 9/10 Kill wolves for |cff...questLink|r!")
        end)

        it("should not announce when questAnnounceLocally is false and channel is party but player is in raid", function()
            _G.IsInRaid = function() return true end
            _G.IsInGroup = function() return true end
            Questie.db.profile.questAnnounceLocally = false
            Questie.db.profile.questAnnounceChannel = "party"
            QuestieLink.GetQuestLinkStringById = function() return "|cff...questLink|r" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "Kill wolves", "10/10")

            assert.spy(_G.SendChatMessage).was_not_called()
            assert.spy(Questie.Print).was_not_called()
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
            QuestieLink.GetQuestLinkStringById = function() return "|cff...questLink|r" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "Kill wolves", "11/10")

            assert.spy(_G.SendChatMessage).was_not_called()
            assert.spy(Questie.Print).was_not_called()
        end)

        it("should print locally and announce to raid chat when questAnnounceLocally is true and channel is raid and player is in raid", function()
            _G.IsInRaid = function() return true end
            _G.IsInGroup = function() return true end
            Questie.db.profile.questAnnounceLocally = true
            Questie.db.profile.questAnnounceChannel = "raid"
            QuestieLink.GetQuestLinkStringById = function() return "|cff...questLink|r" end
            Questie.Print = spy.new(function() end)

            QuestieAnnounce:AnnounceObjectiveToChannel(1, "Kill wolves", "12/10")

            assert.spy(_G.SendChatMessage).was_called_with("{rt1} Questie: 12/10 Kill wolves for |cff...questLink|r!", "RAID")
            assert.spy(Questie.Print).was_called_with(Questie, "{rt1} Questie: 12/10 Kill wolves for |cff...questLink|r!")
        end)
    end)
end)
