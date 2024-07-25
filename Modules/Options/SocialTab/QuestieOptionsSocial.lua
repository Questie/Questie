---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
---@type QuestieShutUp
local QuestieShutUp = QuestieLoader:ImportModule("QuestieShutUp")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieOptions.tabs.social = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()

local _GetAnnounceChannels
local _IsAnnounceDisabled

function QuestieOptions.tabs.social:Initialize()
    return {
        name = function() return l10n("Social"); end,
        type = "group",
        order = 10,
        args = {
            social_header = {
                type = "header",
                order = 1,
                name = function() return l10n("Social Options"); end,
            },
            questAnnounceEvents = {
                type = "group",
                order = 2,
                inline = true,
                name = function() return l10n('Announce quest updates via chat') end,
                args = {
                    filterQuestieAnnounce = {
                        type = "toggle",
                        order = 1,
                        name = function() return l10n('Questie ShutUp!'); end,
                        desc = function() return l10n('Remove all Questie chat messages coming from other players and disable sending your own.'); end,
                        disabled = function() return false end,
                        width = 1.7,
                        get = function () return Questie.db.profile.questieShutUp end,
                        set = function (_, value)
                            Questie.db.profile.questieShutUp = value
                            QuestieShutUp:ToggleFilters(value)
                        end,
                    },
                    questAnnounceChannel = {
                        type = "select",
                        order = 2,
                        values = _GetAnnounceChannels(),
                        style = 'dropdown',
                        disabled = function() return Questie.db.profile.questieShutUp end,
                        name = function() return l10n('Channels to announce in') end,
                        desc = function() return l10n('Announce quest updates to other players in your group'); end,
                        get = function() return Questie.db.profile.questAnnounceChannel; end,
                        set = function(_, key)
                            Questie.db.profile.questAnnounceChannel = key
                            Questie:Debug(Questie.DEBUG_DEVELOP, "Channels to announce changed to:", key)
                        end,
                    },
                    questAnnounceTypes = {
                        type = "group",
                        order = 3,
                        inline = true,
                        name = function() return l10n('Types of updates to announce in chat'); end,
                        args = {
                            questAnnounceItems = {
                                type = "toggle",
                                order = 1,
                                name = function() return l10n('Items starting a quest'); end,
                                desc = function() return l10n('Announce looted items that start a quest to other players'); end,
                                width = 1.5,
                                disabled = function() return _IsAnnounceDisabled(); end,
                                get = function () return Questie.db.profile.questAnnounceItems; end,
                                set = function (_, value)
                                    Questie.db.profile.questAnnounceItems = value
                                    Questie:Debug(Questie.DEBUG_DEVELOP, "Items starting a quest changed to:", value)
                                end,
                            },
                            questAnnounceAccepted = {
                                type = "toggle",
                                order = 2,
                                name = function() return l10n('Quest accepted'); end,
                                desc = function() return l10n('Announce quest acceptance to other players'); end,
                                width = 1.5,
                                disabled = function() return _IsAnnounceDisabled() or Questie.db.profile.questieShutUp; end,
                                get = function () return Questie.db.profile.questAnnounceAccepted; end,
                                set = function (_, value)
                                    Questie.db.profile.questAnnounceAccepted = value
                                    Questie:Debug(Questie.DEBUG_DEVELOP, "Quest accepted announce changed to:", value)
                                end,
                            },
                            questAnnounceAbandoned = {
                                type = "toggle",
                                order = 3,
                                name = function() return l10n('Quest abandoned'); end,
                                desc = function() return l10n('Announce quest abortion to other players'); end,
                                width = 1.5,
                                disabled = function() return _IsAnnounceDisabled() or Questie.db.profile.questieShutUp; end,
                                get = function () return Questie.db.profile.questAnnounceAbandoned; end,
                                set = function (_, value)
                                    Questie.db.profile.questAnnounceAbandoned = value
                                    Questie:Debug(Questie.DEBUG_DEVELOP, "Quest abandoned announce changed to:", value)
                                end,
                            },
                            questAnnounceObjectives = {
                                type = "toggle",
                                order = 4,
                                name = function() return l10n('Objective completed'); end,
                                desc = function() return l10n('Announce completed objectives to other players'); end,
                                width = 1.5,
                                disabled = function() return _IsAnnounceDisabled() or Questie.db.profile.questieShutUp; end,
                                get = function () return Questie.db.profile.questAnnounceObjectives; end,
                                set = function (_, value)
                                    Questie.db.profile.questAnnounceObjectives = value
                                    Questie:Debug(Questie.DEBUG_DEVELOP, "Objective completed announce changed to:", value)
                                end,
                            },
                            questAnnounceCompleted = {
                                type = "toggle",
                                order = 5,
                                name = function() return l10n('Quest completed'); end,
                                desc = function() return l10n('Announce quest completion to other players'); end,
                                width = 1.5,
                                disabled = function() return _IsAnnounceDisabled() or Questie.db.profile.questieShutUp; end,
                                get = function () return Questie.db.profile.questAnnounceCompleted; end,
                                set = function (_, value)
                                    Questie.db.profile.questAnnounceCompleted = value
                                    Questie:Debug(Questie.DEBUG_DEVELOP, "Quest completed announce changed to:", value)
                                end,
                            },
                        },
                    },
                    shareQuestsNearby = {
                        type = "toggle",
                        order = 4,
                        name = function() return l10n('Share quest progress with nearby players'); end,
                        desc = function() return l10n("Your quest progress will be periodically sent to nearby players. Disabling this doesn't affect sharing progress with party members."); end,
                        disabled = function() return false end,
                        width = 1.7,
                        get = function () return not Questie.db.profile.disableYellComms end,
                        set = function (info, value)
                            Questie.db.profile.disableYellComms = not value
                            if not value then
                                QuestieLoader:ImportModule("QuestieComms"):RemoveAllRemotePlayers()
                            end
                        end,
                    },
                    printLocalMessages = {
                        type = "toggle",
                        order = 5,
                        name = function() return l10n('Display announcements locally when outside of a group'); end,
                        desc = function() return l10n("Questie will print your progress messages to chat when not in a group. Other players will NOT be able to see this."); end,
                        disabled = function() return Questie.db.profile.questieShutUp end,
                        width = 2.5,
                        get = function () return Questie.db.profile.questAnnounceLocally end,
                        set = function (_, value)
                            Questie.db.profile.questAnnounceLocally = value
                            Questie:Debug(Questie.DEBUG_DEVELOP, "Quest announce locally changed to:", value)
                        end,
                    },
                },
            },
        }
    }
end

_GetAnnounceChannels = function()
    return {
        ['disabled'] = l10n('Disabled'),
        ['party'] = l10n('Party'),
        ['raid'] = l10n('Raid'),
        ['both'] = l10n('Both'),
    }
end

---@return boolean
_IsAnnounceDisabled = function()
    return (not Questie.db.profile.questAnnounceChannel) or (Questie.db.profile.questAnnounceChannel == "disabled")
end
