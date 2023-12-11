---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type Sounds
local Sounds = QuestieLoader:ImportModule("Sounds")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local _GetQuestSoundChoices
local _GetQuestSoundChoicesSort
local _GetObjectiveSoundChoices
local _GetObjectiveSoundChoicesSort
local _GetObjectiveProgressSoundChoices
local _GetObjectiveProgressSoundChoicesSort

QuestieOptions.tabs.sounds = {...}

function QuestieOptions.tabs.sounds:Initialize()

    return {
        name = function()
            return l10n('Sounds');
        end,
        type = "group",
        order = 17,
        args = {
            questCompleteSound = {
                type = "toggle",
                order = 2.11,
                name = function() return l10n('Quest completed'); end,
                desc = function() return l10n('Play a short sound when completing a quest when it is ready to turn in.'); end,
                width = 1.2,
                get = function() return Questie.db.profile.soundOnQuestComplete; end,
                set = function(_, value)
                    Questie.db.profile.soundOnQuestComplete = value
                end,
            },
            questCompleteSoundButton = {
                type = "execute",
                order = 2.12,
                name = "",
                width = 0.5,
                image = function()
                    return "Interface\\OptionsFrame\\VoiceChat-Play", 15, 15
                end,
                func = function()
                    PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.questCompleteSoundChoiceName), "Master")
                end
            },
            questCompleteSoundChoice = {
                type = "select",
                order = 2.13,
                values = _GetQuestSoundChoices(),
                sorting = _GetQuestSoundChoicesSort(),
                style = 'dropdown',
                name = function() return l10n('Quest Complete Sound Selection') end,
                desc = function() return l10n('The sound you hear when a quest is completed'); end,
                get = function() return Questie.db.profile.questCompleteSoundChoiceName or "None"; end,
                disabled = function() return (not Questie.db.profile.soundOnQuestComplete); end,
                set = function(_, value)
                    Questie.db.profile.questCompleteSoundChoiceName = value
                end,
            },
            soundLineBreak = {
                type = "description",
                name = " ",
                width = 0.1,
                order = 2.135,
            },
            objectiveCompleteSound = {
                type = "toggle",
                order = 2.14,
                name = function() return l10n('Quest objective completed'); end,
                desc = function() return l10n('Play a short sound when completing a quest objective.'); end,
                width = 1.2,
                get = function() return Questie.db.profile.soundOnObjectiveComplete; end,
                set = function(_, value)
                    Questie.db.profile.soundOnObjectiveComplete = value
                end,
            },
            objectiveCompleteSoundButton = {
                type = "execute",
                order = 2.15,
                name = "",
                width = 0.5,
                image = function()
                    return "Interface\\OptionsFrame\\VoiceChat-Play", 15, 15
                end,
                func = function()
                    PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.objectiveCompleteSoundChoiceName), "Master")
                end
            },
            objectiveCompleteSoundChoice = {
                type = "select",
                order = 2.16,
                values = _GetObjectiveSoundChoices(),
                sorting = _GetObjectiveSoundChoicesSort(),
                style = 'dropdown',
                name = function() return l10n('Objective Complete Sound Selection') end,
                desc = function() return l10n('The sound you hear when an objective is completed'); end,
                get = function() return  Questie.db.profile.objectiveCompleteSoundChoiceName; end,
                disabled = function() return (not Questie.db.profile.soundOnObjectiveComplete); end,
                set = function(_, value)
                    Questie.db.profile.objectiveCompleteSoundChoiceName = value
                end,
            },
            objectiveProgressSound = {
                type = "toggle",
                order = 2.17,
                name = function() return l10n('Quest objective progress'); end,
                desc = function() return l10n('Play a short sound when making progress on a quest objective.'); end,
                width = 1.2,
                get = function() return Questie.db.profile.soundOnObjectiveProgress; end,
                set = function(_, value)
                    Questie.db.profile.soundOnObjectiveProgress = value
                end,
            },
            objectiveProgressSoundButton = {
                type = "execute",
                order = 2.18,
                name = "",
                width = 0.5,
                image = function()
                    return "Interface\\OptionsFrame\\VoiceChat-Play", 15, 15
                end,
                func = function()
                    PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.objectiveProgressSoundChoiceName), "Master")
                end
            },
            objectiveProgressSoundChoice = {
                type = "select",
                order = 2.19,
                values = _GetObjectiveProgressSoundChoices(),
                sorting = _GetObjectiveProgressSoundChoicesSort(),
                style = 'dropdown',
                name = function() return l10n('Objective Progress Sound Selection') end,
                desc = function() return l10n('The sound you hear when you make progress on a quest objective'); end,
                get = function() return  Questie.db.profile.objectiveProgressSoundChoiceName; end,
                disabled = function() return (not Questie.db.profile.soundOnObjectiveProgress); end,
                set = function(_, value)
                    Questie.db.profile.objectiveProgressSoundChoiceName = value
                end,
            },
        }
    }
end

_GetQuestSoundChoices = function()
    return {
        ["QuestDefault"]     = "Default",
        ["GameDefault"]      = "Game Default",
        ["Troll Male"]       = "Troll Male",
        ["Troll Female"]     = "Troll Female",
        ["Tauren Male"]      = "Tauren Male",
        ["Tauren Female"]    = "Tauren Female",
        ["Undead Male"]      = "Undead Male",
        ["Undead Female"]    = "Undead Female",
        ["Orc Male"]         = "Orc Male",
        ["Orc Female"]       = "Orc Female",
        ["Night Elf Female"] = "Night Elf Female",
        ["Night Elf Male"]   = "Night Elf Male",
        ["Human Female"]     = "Human Female",
        ["Human Male"]       = "Human Male",
        ["Gnome Male"]       = "Gnome Male",
        ["Gnome Female"]     = "Gnome Female",
        ["Dwarf Male"]       = "Dwarf Male",
        ["Dwarf Female"]     = "Dwarf Female",
        ["Draenei Male"]     = "Draenei Male",
        ["Draenei Female"]   = "Draenei Female",
        ["Blood Elf Female"] = "Blood Elf Female",
        ["Blood Elf Male"]   = "Blood Elf Male",
    }
end


_GetQuestSoundChoicesSort = function()
    return {
        "QuestDefault",
        "GameDefault",
        "Troll Male",
        "Troll Female",
        "Tauren Male",
        "Tauren Female",
        "Undead Male",
        "Undead Female",
        "Orc Male",
        "Orc Female",
        "Night Elf Female",
        "Night Elf Male",
        "Human Female",
        "Human Male",
        "Gnome Male",
        "Gnome Female",
        "Dwarf Male",
        "Dwarf Female",
        "Draenei Male",
        "Draenei Female",
        "Blood Elf Female",
        "Blood Elf Male",
    }
end

_GetObjectiveSoundChoices = function()
    return {
        ["ObjectiveDefault"]   = "Default",
        ["Map Ping"]           = "Map Ping",
        ["Window Close"]       = "Window Close",
        ["Window Open"]        = "Window Open",
        ["Boat Docked"]        = "Boat Docked",
        ["Bell Toll Alliance"] = "Bell Toll Alliance",
        ["Bell Toll Horde"]    = "Bell Toll Horde",
        ["Explosion"]          = "Explosion",
        ["Shing!"]             = "Shing!",
        ["Wham!"]              = "Wham!",
        ["Simon Chime"]        = "Simon Chime",
        ["War Drums"]          = "War Drums",
        ["Humm"]               = "Humm",
        ["Short Circuit"]      = "Short Circuit",
    }
end

_GetObjectiveSoundChoicesSort = function()
    return {
        "ObjectiveDefault",
        "Map Ping",
        "Window Close",
        "Window Open",
        "Boat Docked",
        "Bell Toll Alliance",
        "Bell Toll Horde",
        "Explosion",
        "Shing!",
        "Wham!",
        "Simon Chime",
        "War Drums",
        "Humm",
        "Short Circuit",
    }
end

_GetObjectiveProgressSoundChoices = function()
    return {
        ["ObjectiveProgress"]  = "Default",
        ["ObjectiveDefault"]   = "Objective Complete",
        ["Map Ping"]           = "Map Ping",
        ["Window Close"]       = "Window Close",
        ["Window Open"]        = "Window Open",
        ["Boat Docked"]        = "Boat Docked",
        ["Bell Toll Alliance"] = "Bell Toll Alliance",
        ["Bell Toll Horde"]    = "Bell Toll Horde",
        ["Explosion"]          = "Explosion",
        ["Shing!"]             = "Shing!",
        ["Wham!"]              = "Wham!",
        ["Simon Chime"]        = "Simon Chime",
        ["War Drums"]          = "War Drums",
        ["Humm"]               = "Humm",
        ["Short Circuit"]      = "Short Circuit",
    }
end

_GetObjectiveProgressSoundChoicesSort = function()
    return {
        "ObjectiveProgress",
        "ObjectiveDefault",
        "Map Ping",
        "Window Close",
        "Window Open",
        "Boat Docked",
        "Bell Toll Alliance",
        "Bell Toll Horde",
        "Explosion",
        "Shing!",
        "Wham!",
        "Simon Chime",
        "War Drums",
        "Humm",
        "Short Circuit",
    }
end

