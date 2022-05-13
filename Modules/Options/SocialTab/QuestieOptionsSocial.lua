
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
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
                    questAnnounceChannel = {
                        type = "select",
                        order = 1,
                        values = _GetAnnounceChannels(),
                        style = 'dropdown',
                        name = function() return l10n('Channels to announce in') end,
                        desc = function() return l10n('Announce quest updates to other players in your group or raid'); end,
                        get = function() return Questie.db.char.questAnnounceChannel; end,
                        set = function(_, key)
                            Questie.db.char.questAnnounceChannel = key
                        end,
                    },
                    questAnnounceTypes = {
                        type = "group",
                        order = 2,
                        inline = true,
                        name = function() return l10n('Types of updates to announce in chat'); end,
                        args = {
                            questAnnounceAccepted = {
                                type = "toggle",
                                order = 1,
                                name = function() return l10n('Quest accepted'); end,
                                desc = function() return l10n('Announce quest acceptance to other players'); end,
                                width = 1.5,
                                disabled = function() return _IsAnnounceDisabled(); end,
                                get = function () return Questie.db.char.questAnnounceAccepted; end,
                                set = function (_, value)
                                    Questie.db.char.questAnnounceAccepted = value
                                end,
                            },
                            questAnnounceAbandoned = {
                                type = "toggle",
                                order = 2,
                                name = function() return l10n('Quest abandoned'); end,
                                desc = function() return l10n('Announce quest abortion to other players'); end,
                                width = 1.5,
                                disabled = function() return _IsAnnounceDisabled(); end,
                                get = function () return Questie.db.char.questAnnounceAbandoned; end,
                                set = function (_, value)
                                    Questie.db.char.questAnnounceAbandoned = value
                                end,
                            },
                            questAnnounceObjectives = {
                                type = "toggle",
                                order = 3,
                                name = function() return l10n('Objective completed'); end,
                                desc = function() return l10n('Announce completed objectives to other players'); end,
                                width = 1.5,
                                disabled = function() return _IsAnnounceDisabled(); end,
                                get = function () return Questie.db.char.questAnnounceObjectives; end,
                                set = function (_, value)
                                    Questie.db.char.questAnnounceObjectives = value
                                end,
                            },
                            questAnnounceCompleted = {
                                type = "toggle",
                                order = 4,
                                name = function() return l10n('Quest completed'); end,
                                desc = function() return l10n('Announce quest completion to other players'); end,
                                width = 1.5,
                                disabled = function() return _IsAnnounceDisabled(); end,
                                get = function () return Questie.db.char.questAnnounceCompleted; end,
                                set = function (_, value)
                                    Questie.db.char.questAnnounceCompleted = value
                                end,
                            },
                        },
                    },
                    shareQuestsNearby = {
                        type = "toggle",
                        order = 3,
                        name = function() return l10n('Share quest progress with nearby players'); end,
                        desc = function() return l10n("Your quest progress will be periodically sent to nearby players. Disabling this doesn't affect sharing progress with party members."); end,
                        disabled = function() return false end,
                        width = 1.7,
                        get = function () return not Questie.db.global.disableYellComms end,
                        set = function (info, value)
                            Questie.db.global.disableYellComms = not value
                            if not value then
                                QuestieLoader:ImportModule("QuestieComms"):RemoveAllRemotePlayers()
                            end
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
        ['group'] = l10n('Group'),
        ['raid'] = l10n('Raid'),
        ['both'] = l10n('Both'),
    }
end

---@return boolean
_IsAnnounceDisabled = function()
    return Questie.db.char.questAnnounceChannel == nil or Questie.db.char.questAnnounceChannel == "disabled";
end
