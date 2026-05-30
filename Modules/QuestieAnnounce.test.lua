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
    end)
end)
