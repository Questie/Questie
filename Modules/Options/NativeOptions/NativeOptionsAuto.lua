-------------------------
--Import modules.
-------------------------
---@type QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieOptionsEngine.tabs.auto = { ... }

local _GetShortcuts

function QuestieOptionsEngine.tabs.auto:Initialize()
    return {
        title = "Auto",
        subtitle = "Auto Settings",
        order = 3,
        icon = 237293,
        items = {
            autoModifier = {
                type = "dropdown",
                order = 0,
                options = _GetShortcuts,
                title = "Auto Modifier",
                tooltip = "The modifier to NOT auto-accept/-complete quests when either option is enabled and you interact with a quest NPC.",
                width = "third",
                get = function() return Questie.db.profile.autoModifier end,
                set = function(key)
                    Questie.db.profile.autoModifier = key
                end,
            },
            autocomplete_group = {
                type = "container",
                order = 1,
                title = "Auto Complete",
                items = {
                    autocomplete = {
                        type = "checkbox",
                        order = 1.1,
                        title = "Auto Complete Quests",
                        tooltip = "If checked, Questie will automatically hand in finished quests when talking to NPCs.",
                        width = "full",
                        get = function() return Questie.db.profile.autocomplete end,
                        set = function(_, value)
                            Questie.db.profile.autocomplete = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Complete toggled to:", value)
                        end,
                    },
                },
            },
            autoaccept_group = {
                type = "container",
                order = 2,
                title = "Auto Accept",
                items = {
                    autoaccept = {
                        type = "checkbox",
                        order = 2.1,
                        title = "Auto Accept Quests",
                        tooltip = "If checked, Questie will automatically accept quest dialogs when they appear, depending on the rules below.",
                        width = "full",
                        get = function() return Questie.db.profile.autoAccept.enabled end,
                        set = function(_, value)
                            Questie.db.profile.autoAccept.enabled = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept toggled to:", value)
                        end,
                    },
                    npcrules_group = {
                        type = "container",
                        order = 2.2,
                        title = "Rules for NPCs",
                        enabled = function() return Questie.db.profile.autoAccept.enabled end,
                        items = {
                            npc_normalquests = {
                                type = "checkbox",
                                order = 1,
                                title = "Normal Quests",
                                tooltip = "Automatically accept normal quests from NPCs.",
                                width = "half",
                                enabled = false,
                                get = function() return true end,
                                set = function(_, value)
                                    Questie.db.profile.autoaccept_npc_normal = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC Normal toggled to:", value)
                                end,
                            },
                            npc_repeatablequests = {
                                type = "checkbox",
                                order = 2,
                                title = "Repeatable Quests",
                                tooltip = "Automatically accept repeatable quests (including dailies) from NPCs.",
                                width = "half",
                                enabled = function() return Questie.db.profile.autoAccept.enabled end,
                                get = function() return Questie.db.profile.autoAccept.repeatable end,
                                set = function(_, value)
                                    Questie.db.profile.autoAccept.repeatable = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC Repeatable toggled to:", value)
                                end,
                            },
                            npc_dungeonquests = {
                                type = "checkbox",
                                order = 3,
                                title = "Dungeon/Raid Quests",
                                tooltip = "Automatically accept dungeon and raid quests from NPCs.",
                                width = "half",
                                enabled = false,
                                get = function() return true end,
                                set = function(_, value)
                                    Questie.db.profile.autoaccept_npc_dungeon = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC Dungeon toggled to:", value)
                                end,
                            },
                            npc_pvpquests = {
                                type = "checkbox",
                                order = 4,
                                title = "PvP Quests",
                                tooltip = "Automatically accept PvP quests from NPCs.",
                                width = "half",
                                enabled = function() return Questie.db.profile.autoAccept.enabled end,
                                get = function() return Questie.db.profile.autoAccept.pvp end,
                                set = function(_, value)
                                    Questie.db.profile.autoAccept.pvp = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC PvP toggled to:", value)
                                end,
                            },
                            npc_eventquests = {
                                type = "checkbox",
                                order = 5,
                                title = "Event Quests",
                                tooltip = "Automatically accept event quests (including event dailies) from NPCs.",
                                width = "half",
                                enabled = false,
                                get = function() return true end,
                                set = function(_, value)
                                    Questie.db.profile.autoaccept_npc_event = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC Event toggled to:", value)
                                end,
                            },
                            npc_trivialquests = {
                                type = "checkbox",
                                order = 6,
                                title = "Trivial Quests",
                                tooltip = "Automatically accept trivial (low-level) quests from NPCs.",
                                width = "half",
                                enabled = function() return Questie.db.profile.autoAccept.enabled end,
                                get = function() return Questie.db.profile.autoAccept.trivial end,
                                set = function(_, value)
                                    Questie.db.profile.autoAccept.trivial = value
                                end,
                            },
                        },
                    },
                    playerrules_group = {
                        type = "container",
                        order = 2.3,
                        title = "Rules for players",
                        enabled = function() return Questie.db.profile.autoAccept.enabled end,
                        items = {
                            player_normalquests = {
                                type = "checkbox",
                                order = 1,
                                title = "Normal Quests",
                                tooltip = "Automatically accept normal quests from players.",
                                width = "half",
                                enabled = false,
                                get = function() return true end,
                                set = function(_, value)
                                    Questie.db.profile.autoaccept_player_normal = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player Normal toggled to:", value)
                                end,
                            },
                            player_repeatablequests = {
                                type = "checkbox",
                                order = 2,
                                title = "Repeatable Quests",
                                tooltip = "Automatically accept repeatable quests (including dailies) from players.",
                                width = "half",
                                enabled = false,
                                get = function() return true end,
                                set = function(_, value)
                                    Questie.db.profile.autoaccept_player_repeatable = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player Repeatable toggled to:", value)
                                end,
                            },
                            player_dungeonquests = {
                                type = "checkbox",
                                order = 3,
                                title = "Dungeon/Raid Quests",
                                tooltip = "Automatically accept dungeon and raid quests from players.",
                                width = "half",
                                enabled = false,
                                get = function() return true end,
                                set = function(_, value)
                                    Questie.db.profile.autoaccept_player_dungeon = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player Dungeon toggled to:", value)
                                end,
                            },
                            player_pvpquests = {
                                type = "checkbox",
                                order = 4,
                                title = "PvP Quests",
                                tooltip = "Automatically accept PvP quests from players.",
                                width = "half",
                                enabled = false,
                                get = function() return true end,
                                set = function(_, value)
                                    Questie.db.profile.autoaccept_player_pvp = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player PvP toggled to:", value)
                                end,
                            },
                            player_eventquests = {
                                type = "checkbox",
                                order = 5,
                                title = "Event Quests",
                                tooltip = "Automatically accept event quests (including event dailies) from players.",
                                width = "half",
                                enabled = false,
                                get = function() return true end,
                                set = function(_, value)
                                    Questie.db.profile.autoaccept_player_event = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player Event toggled to:", value)
                                end,
                            },
                            player_trivialquests = {
                                type = "checkbox",
                                order = 6,
                                title = "Trivial Quests",
                                tooltip = "Automatically accept trivial (low-level) quests from players.",
                                width = "half",
                                enabled = false,
                                get = function() return true end,
                                set = function(_, value)
                                    Questie.db.profile.autoaccept_player_trivial = value
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player Trivial toggled to:", value)
                                end,
                            },
                        },
                    },
                },
            },
            autoreject_group = {
                type = "container",
                order = 3,
                title = "Auto Reject",
                items = {
                    autoreject_battlegrounds = {
                        type = "checkbox",
                        order = 3.1,
                        title = "Reject quests shared in battlegrounds",
                        tooltip = "Automatically reject quests shared by players while in a battleground instance. This feature overrides autoaccept behavior.",
                        width = "full",
                        get = function() return Questie.db.profile.autoAccept.rejectSharedInBattleground end,
                        set = function(_, value)
                            Questie.db.profile.autoAccept.rejectSharedInBattleground = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Reject Battleground toggled to:", value)
                        end,
                    },
                    autoreject_randoms = {
                        type = "checkbox",
                        order = 3.2,
                        title = "Reject quests shared by non-friends",
                        tooltip = "Automatically reject quests shared by players that aren't on your friends list. This feature overrides autoaccept behavior.",
                        width = "full",
                        enabled = false,
                        get = function() return false end,
                        set = function(_, value)
                            Questie.db.profile.autoreject_nonfriend = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Reject Nonfriend toggled to:", value)
                        end,
                    },
                    autoreject_breadcrumb = {
                        type = "checkbox",
                        order = 3.3,
                        title = "Abandon quest if breadcrumb is not completed",
                        tooltip = "Automatically abandon a quest if you accept it before completing its breadcrumb quest.",
                        width = "full",
                        get = function() return Questie.db.profile.autoAccept.abandonBreadcrumbFollowup end,
                        set = function(_, value)
                            Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Reject Breadcrumb toggled to:", value)
                        end,
                    },
                },
            },
            wip_text = {
                type = "text",
                order = 4,
                title = "",
                description = "Further Auto customization is coming in a future Questie update.",
                width = "full",
                descriptionAlign = "CENTER",
            },
        },
    }
end

_GetShortcuts = function()
    return {
        ["shift"] = l10n("Shift"),
        ["ctrl"] = l10n("Control"),
        ["alt"] = l10n("Alt"),
        ["disabled"] = l10n("Disabled"),
    }
end