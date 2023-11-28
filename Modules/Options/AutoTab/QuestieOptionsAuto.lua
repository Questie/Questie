---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker");
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieOptions.tabs.auto = {...}

local _GetShortcuts

function QuestieOptions.tabs.auto:Initialize()
    return {
        name = function() return l10n('Auto'); end,
        type = "group",
        order = 4,
        childGroups = "tab",
        args = {
            autoModifier = {
                type = "select",
                order = 0,
                values = _GetShortcuts(),
                style = 'dropdown',
                name = function() return l10n('Auto Modifier') end,
                desc = function() return l10n('The modifier to NOT auto-accept/-complete quests when either option is enabled and you interact with a quest NPC.'); end,
                width = 0.65,
                --disabled = function() return (not Questie.db.profile.autocomplete) and (not Questie.db.profile.autoaccept) end,
                get = function() return Questie.db.profile.autoModifier; end,
                set = function(input, key)
                    Questie.db.profile.autoModifier = key
                end,
            },
            autocomplete_options = {
                type = "header",
                order = 1,
                name = function() return l10n('Auto Complete'); end,
            },
            autocomplete = {
                type = "toggle",
                order = 1.1,
                name = function() return l10n('Auto Complete Quests'); end,
                desc = function() return l10n('When enabled, Questie will automatically hand in finished quests when talking to NPCs.'); end,
                get = function () return Questie.db.profile.autocomplete; end,
                set = function (info, value)
                    Questie.db.profile.autocomplete = value
                    Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Complete toggled to:", value)
                end,
            },
            autocomplete_spacer = QuestieOptionsUtils:Spacer(1.2),
            autoaccept_options = {
                type = "header",
                order = 2,
                name = function() return l10n('Auto Accept'); end,
            },
            autoaccept = {
                type = "toggle",
                order = 2.1,
                name = function() return l10n('Auto Accept Quests'); end,
                desc = function() return l10n('When enabled, Questie will automatically accept quest dialogs when they appear, depending on the rules below.'); end,
                get = function () return Questie.db.profile.autoaccept; end,
                set = function (info, value)
                    Questie.db.profile.autoaccept = value
                    Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Accept toggled to:", value)
                end,
            },
            npcrules_group = {
                type = "group",
                order = 2.2,
                inline = true,
                width = 0.5,
                name = function() return l10n('Rules for NPCs'); end,
                disabled = function() return not Questie.db.profile.autoaccept end,
                args = {
                    npc_normalquests = {
                        type = "toggle",
                        order = 1,
                        name = function() return l10n('Normal Quests'); end,
                        desc = function() return l10n('Automatically accept normal quests from NPCs.'); end,
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_npc_normal; end,
                        -- END
                        set = function (info, value)
                            Questie.db.profile.autoaccept_npc_normal = value
                            Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC Normal toggled to:", value)
                        end,
                    },
                    npc_repeatablequests = {
                        type = "toggle",
                        order = 2,
                        name = function() return l10n('Repeatable Quests'); end,
                        desc = function() return l10n('Automatically accept repeatable quests (including dailies) from NPCs.'); end,
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_npc_repeatable; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_npc_repeatable = value
                            Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC Repeatable toggled to:", value)
                        end,
                    },
                    npc_dungeonquests = {
                        type = "toggle",
                        order = 3,
                        name = function() return l10n('Dungeon/Raid Quests'); end,
                        desc = function() return l10n('Automatically accept dungeon and raid quests from NPCs.'); end,
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_npc_dungeon; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_npc_dungeon = value
                            Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC Dungeon toggled to:", value)
                        end,
                    },
                    npc_pvpquests = {
                        type = "toggle",
                        order = 4,
                        name = function() return l10n('PvP Quests'); end,
                        desc = function() return l10n('Automatically accept PvP quests from NPCs.'); end,
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_npc_pvp; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_npc_pvp = value
                            Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC PvP toggled to:", value)
                        end,
                    },
                    npc_eventquests = {
                        type = "toggle",
                        order = 5,
                        name = function() return l10n('Event Quests'); end,
                        desc = function() return l10n('Automatically accept event quests (including event dailies) from NPCs.'); end,
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_npc_event; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_npc_event = value
                            Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC Event toggled to:", value)
                        end,
                    },
                    npc_trivialquests = {
                        type = "toggle",
                        order = 6,
                        name = function() return l10n('Trivial Quests'); end,
                        desc = function() return l10n('Automatically accept trivial (low-level) quests from NPCs.'); end,
                        width = 1,
                        -- AUTO 1.0
                        get = function() return Questie.db.profile.acceptTrivial; end,
                        set = function(_, value)
                            Questie.db.profile.acceptTrivial = value
                        end,
                        -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_npc_trivial; end,
                        -- set = function (info, value)
                        --     Questie.db.profile.autoaccept_npc_trivial = value
                        --     Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC Trivial toggled to:", value)
                        -- end,
                    },
                },
            },
            playerrules_group = {
                type = "group",
                order = 2.3,
                inline = true,
                width = 0.5,
                disabled = function() return not Questie.db.profile.autoaccept end,
                name = function() return l10n('Rules for players'); end,
                args = {
                    player_normalquests = {
                        type = "toggle",
                        order = 1,
                        name = function() return l10n('Normal Quests'); end,
                        desc = function() return l10n('Automatically accept normal quests from players.'); end,
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_player_normal; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_player_normal = value
                            Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player Normal toggled to:", value)
                        end,
                    },
                    player_repeatablequests = {
                        type = "toggle",
                        order = 2,
                        name = function() return l10n('Repeatable Quests'); end,
                        desc = function() return l10n('Automatically accept repeatable quests (including dailies) from players.'); end,
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_player_repeatable; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_player_repeatable = value
                            Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player Repeatable toggled to:", value)
                        end,
                    },
                    player_dungeonquests = {
                        type = "toggle",
                        order = 3,
                        name = function() return l10n('Dungeon/Raid Quests'); end,
                        desc = function() return l10n('Automatically accept dungeon and raid quests from players.'); end,
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_player_dungeon; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_player_dungeon = value
                            Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player Dungeon toggled to:", value)
                        end,
                    },
                    player_pvpquests = {
                        type = "toggle",
                        order = 4,
                        name = function() return l10n('PvP Quests'); end,
                        desc = function() return l10n('Automatically accept PvP quests from players.'); end,
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_player_pvp; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_player_pvp = value
                            Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player PvP toggled to:", value)
                        end,
                    },
                    player_eventquests = {
                        type = "toggle",
                        order = 5,
                        name = function() return l10n('Event Quests'); end,
                        desc = function() return l10n('Automatically accept event quests (including event dailies) from players.'); end,
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_player_event; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_player_event = value
                            Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player Event toggled to:", value)
                        end,
                    },
                    player_trivialquests = {
                        type = "toggle",
                        order = 6,
                        name = function() return l10n('Trivial Quests'); end,
                        desc = function() return l10n('Automatically accept trivial (low-level) quests from players.'); end,
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_player_trivial; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_player_trivial = value
                            Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player Trivial toggled to:", value)
                        end,
                    },
                },
            },
            autoaccept_spacer = QuestieOptionsUtils:Spacer(2.4),
            --Spacer_H = QuestieOptionsUtils:HorizontalSpacer(7, 1),
            --acceptTrivial = {
            --    type = "toggle",
            --    order = 8,
            --    name = function() return l10n('Accept trivial (low level) quests'); end,
            --    desc = function() return l10n('When this is enabled trivial (gray) quests will be auto accepted as well.'); end,
            --    disabled = function() return (not Questie.db.profile.autoaccept) end,
            --    width = 1.5,
            --    get = function () return Questie.db.profile.acceptTrivial; end,
            --    set = function (info, value)
            --        Questie.db.profile.acceptTrivial = value
            --    end,
            --},
            autoreject_options = {
                type = "header",
                order = 3,
                name = function() return l10n('Auto Reject'); end,
            },
            autoreject_battlegrounds = {
                type = "toggle",
                order = 3.1,
                name = function() return l10n('Reject quests shared in battlegrounds'); end,
                desc = function() return l10n('Automatically reject quests shared by players while in a battleground instance. This feature overrides autoaccept behavior.'); end,
                width = 1.6,
                -- AUTO 1.0
                disabled = true,
                get = function () return false; end,
                -- -- AUTO 2.0
                -- get = function () return Questie.db.profile.autoreject_battleground; end,
                set = function (info, value)
                    Questie.db.profile.autoreject_battleground = value
                    Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Reject Battleground toggled to:", value)
                end,
            },
            autoreject_randoms = {
                type = "toggle",
                order = 3.2,
                name = function() return l10n('Reject quests shared by non-friends'); end,
                desc = function() return l10n('Automatically reject quests shared by players that aren\'t on your friends list. This feature overrides autoaccept behavior.'); end,
                width = 1.6,
                -- AUTO 1.0
                disabled = true,
                get = function () return false; end,
                -- -- AUTO 2.0
                -- get = function () return Questie.db.profile.autoreject_nonfriend; end,
                set = function (info, value)
                    Questie.db.profile.autoreject_nonfriend = value
                    Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Reject Nonfriend toggled to:", value)
                end,
            },
            wip_spacer = QuestieOptionsUtils:Spacer(4),
            wip_text = {
                type = "description",
                order = 5,
                name = function() return l10n('Further Auto customization is coming in a future Questie update.'); end,
                fontSize = "medium",
            },
        }
    }
end

_GetShortcuts = function()
    return {
        ['shift'] = l10n('Shift'),
        ['ctrl'] = l10n('Control'),
        ['alt'] = l10n('Alt'),
        ['disabled'] = l10n('Disabled'),
    }
end