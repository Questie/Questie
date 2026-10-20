---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine");
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker");
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieOptionsEngine.tabs.auto = {...}

local _GetShortcuts

function QuestieOptionsEngine.tabs.auto:Initialize()
    return {
        title = "Auto",
        subtitle = "Auto",
        order = 3,
        icon = 133736,
        items = {
            autoModifier = {
                type = "select",
                order = 0,
                values = _GetShortcuts,
                style = "dropdown",
                name = function() return l10n("Auto Modifier") end,
                desc = "The modifier to NOT auto-accept/-complete quests when either option is enabled and you interact with a quest NPC.",
                width = 0.65,
                --disabled = function() return (not Questie.db.profile.autocomplete) and (not Questie.db.profile.autoAccept.enabled) end,
                get = function() return Questie.db.profile.autoModifier; end,
                set = function(input, key)
                    Questie.db.profile.autoModifier = key
                end,
            },
            autocomplete_options = {
                type = "header",
                order = 1,
                name = "Auto Complete",
            },
            autocomplete = {
                type = "toggle",
                order = 1.1,
                name = "Auto Complete Quests",
                desc = "If checked, Questie will automatically hand in finished quests when talking to NPCs.",
                get = function () return Questie.db.profile.autocomplete; end,
                set = function (info, value)
                    Questie.db.profile.autocomplete = value
                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Complete toggled to:", value)
                end,
            },
            autocomplete_spacer = QuestieOptionsUtils:Spacer(1.2),
            autoaccept_options = {
                type = "header",
                order = 2,
                name = "Auto Accept",
            },
            autoaccept = {
                type = "toggle",
                order = 2.1,
                name = "Auto Accept Quests",
                desc = "If checked, Questie will automatically accept quest dialogs when they appear, depending on the rules below.",
                get = function () return Questie.db.profile.autoAccept.enabled; end,
                set = function (info, value)
                    Questie.db.profile.autoAccept.enabled = value
                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept toggled to:", value)
                end,
            },
            npcrules_group = {
                type = "group",
                order = 2.2,
                inline = true,
                width = 0.5,
                name = "Rules for NPCs",
                disabled = function() return not Questie.db.profile.autoAccept.enabled end,
                args = {
                    npc_normalquests = {
                        type = "toggle",
                        order = 1,
                        name = "Normal Quests",
                        desc = "Automatically accept normal quests from NPCs.",
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_npc_normal; end,
                        -- END
                        set = function (info, value)
                            Questie.db.profile.autoaccept_npc_normal = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC Normal toggled to:", value)
                        end,
                    },
                    npc_repeatablequests = {
                        type = "toggle",
                        order = 2,
                        name = "Repeatable Quests",
                        desc = "Automatically accept repeatable quests (including dailies) from NPCs.",
                        width = 1,
                        get = function () return Questie.db.profile.autoAccept.repeatable; end,
                        set = function (_, value)
                            Questie.db.profile.autoAccept.repeatable = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC Repeatable toggled to:", value)
                        end,
                    },
                    npc_dungeonquests = {
                        type = "toggle",
                        order = 3,
                        name = "Dungeon/Raid Quests",
                        desc = "Automatically accept dungeon and raid quests from NPCs.",
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_npc_dungeon; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_npc_dungeon = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC Dungeon toggled to:", value)
                        end,
                    },
                    npc_pvpquests = {
                        type = "toggle",
                        order = 4,
                        name = "PvP Quests",
                        desc = "Automatically accept PvP quests from NPCs.",
                        width = 1,
                        get = function () return Questie.db.profile.autoAccept.pvp; end,
                        set = function (info, value)
                            Questie.db.profile.autoAccept.pvp = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC PvP toggled to:", value)
                        end,
                    },
                    npc_eventquests = {
                        type = "toggle",
                        order = 5,
                        name = "Event Quests",
                        desc = "Automatically accept event quests (including event dailies) from NPCs.",
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_npc_event; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_npc_event = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC Event toggled to:", value)
                        end,
                    },
                    npc_trivialquests = {
                        type = "toggle",
                        order = 6,
                        name = "Trivial Quests",
                        desc = "Automatically accept trivial (low-level) quests from NPCs.",
                        width = 1,
                        -- AUTO 1.0
                        get = function() return Questie.db.profile.autoAccept.trivial; end,
                        set = function(_, value)
                            Questie.db.profile.autoAccept.trivial = value
                        end,
                        -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_npc_trivial; end,
                        -- set = function (info, value)
                        --     Questie.db.profile.autoaccept_npc_trivial = value
                        --     Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept NPC Trivial toggled to:", value)
                        -- end,
                    },
                },
            },
            playerrules_group = {
                type = "group",
                order = 2.3,
                inline = true,
                width = 0.5,
                disabled = function() return not Questie.db.profile.autoAccept.enabled end,
                name = "Rules for players",
                args = {
                    player_normalquests = {
                        type = "toggle",
                        order = 1,
                        name = "Normal Quests",
                        desc = "Automatically accept normal quests from players.",
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_player_normal; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_player_normal = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player Normal toggled to:", value)
                        end,
                    },
                    player_repeatablequests = {
                        type = "toggle",
                        order = 2,
                        name = "Repeatable Quests",
                        desc = "Automatically accept repeatable quests (including dailies) from players.",
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_player_repeatable; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_player_repeatable = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player Repeatable toggled to:", value)
                        end,
                    },
                    player_dungeonquests = {
                        type = "toggle",
                        order = 3,
                        name = "Dungeon/Raid Quests",
                        desc = "Automatically accept dungeon and raid quests from players.",
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_player_dungeon; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_player_dungeon = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player Dungeon toggled to:", value)
                        end,
                    },
                    player_pvpquests = {
                        type = "toggle",
                        order = 4,
                        name = "PvP Quests",
                        desc = "Automatically accept PvP quests from players.",
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_player_pvp; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_player_pvp = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player PvP toggled to:", value)
                        end,
                    },
                    player_eventquests = {
                        type = "toggle",
                        order = 5,
                        name = "Event Quests",
                        desc = "Automatically accept event quests (including event dailies) from players.",
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_player_event; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_player_event = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player Event toggled to:", value)
                        end,
                    },
                    player_trivialquests = {
                        type = "toggle",
                        order = 6,
                        name = "Trivial Quests",
                        desc = "Automatically accept trivial (low-level) quests from players.",
                        width = 1,
                        -- AUTO 1.0
                        disabled = true,
                        get = function () return true; end,
                        -- -- AUTO 2.0
                        -- get = function () return Questie.db.profile.autoaccept_player_trivial; end,
                        set = function (info, value)
                            Questie.db.profile.autoaccept_player_trivial = value
                            Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Accept Player Trivial toggled to:", value)
                        end,
                    },
                },
            },
            autoaccept_spacer = QuestieOptionsUtils:Spacer(2.4),
            --Spacer_H = QuestieOptionsUtils:HorizontalSpacer(7, 1),
            --acceptTrivial = {
            --    type = "toggle",
            --    order = 8,
            --    name = "Accept trivial (low level) quests",
            --    desc = "If checked, trivial (gray) quests will be auto accepted as well.",
            --    disabled = function() return (not Questie.db.profile.autoAccept.enabled) end,
            --    width = 1.5,
            --    get = function () return Questie.db.profile.autoAccept.trivial; end,
            --    set = function (info, value)
            --        Questie.db.profile.autoAccept.trivial = value
            --    end,
            --},
            autoreject_options = {
                type = "header",
                order = 3,
                name = "Auto Reject",
            },
            autoreject_battlegrounds = {
                type = "toggle",
                order = 3.1,
                name = "Reject quests shared in battlegrounds",
                desc = "Automatically reject quests shared by players while in a battleground instance. This feature overrides autoaccept behavior.",
                width = 1.6,
                get = function () return Questie.db.profile.autoAccept.rejectSharedInBattleground; end,
                set = function (_, value)
                    Questie.db.profile.autoAccept.rejectSharedInBattleground = value
                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Reject Battleground toggled to:", value)
                end,
            },
            autoreject_randoms = {
                type = "toggle",
                order = 3.2,
                name = "Reject quests shared by non-friends",
                desc = "Automatically reject quests shared by players that aren't on your friends list. This feature overrides autoaccept behavior.",
                width = 1.6,
                -- AUTO 1.0
                disabled = true,
                get = function () return false; end,
                -- -- AUTO 2.0
                -- get = function () return Questie.db.profile.autoreject_nonfriend; end,
                set = function (info, value)
                    Questie.db.profile.autoreject_nonfriend = value
                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Reject Nonfriend toggled to:", value)
                end,
            },
            autoreject_breadcrumb = {
                type = "toggle",
                order = 3.3,
                name = "Abandon quest if breadcrumb is not completed",
                desc = "Automatically abandon a quest if you accept it before completing its breadcrumb quest.",
                width = 2.0,
                get = function () return Questie.db.profile.autoAccept.abandonBreadcrumbFollowup; end,
                set = function (_, value)
                    Questie.db.profile.autoAccept.abandonBreadcrumbFollowup = value
                    Questie.Debug(Questie.DEBUG_DEVELOP, "Auto Reject Breadcrumb toggled to:", value)
                end,
            },
            wip_spacer = QuestieOptionsUtils:Spacer(4),
            wip_text = {
                type = "description",
                order = 5,
                name = "Further Auto customization is coming in a future Questie update.",
                fontSize = "medium",
            },
        }
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
