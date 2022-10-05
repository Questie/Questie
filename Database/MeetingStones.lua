---@class MeetingStones
local MeetingStones = QuestieLoader:CreateModule("MeetingStones")
local _MeetingStones = {}

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")


---@param objectId number
---@return string?, string?
function MeetingStones:GetLocalizedDungeonNameAndLevelRangeByObjectId(objectId)
    local tableEntry = _MeetingStones.levelRanges[objectId]

    if (not tableEntry) then
        return nil, nil
    end

    return l10n(tableEntry.name), tableEntry.range
end

_MeetingStones.levelRanges = {
    [178824] = {
        name = "Razorfen Downs",
        range = "(33-41)"
    },
    [178825] = {
        name = "Razorfen Kraul",
        range = "(23-31)"
    },
    [178826] = {
        name = "Dire Maul",
        range = "(54-61)"
    },
    [178827] = {
        name = "Maraudon",
        range = "(40-52)"
    },
    [178828] = {
        name = "Blackfathom Deeps",
        range = "(20-28)"
    },
    [178829] = {
        name = "Zul'Farrak",
        range = "(42-50)"
    },
    [178831] = {
        name = "Stratholme",
        range = "(56-61)"
    },
    [178832] = {
        name = "Scholomance",
        range = "(56-61)"
    },
    [178833] = {
        name = "Uldaman",
        range = "(36-44)"
    },
    [178834] = {
        name = "The Deadmines",
        range = "(16-24)"
    },
    [178844] = {
        name = "Scarlet Monastery",
        range = "(28-44)"
    },
    [178845] = {
        name = "Shadowfang Keep",
        range = "(17-25)"
    },
    [178884] = {
        name = "Wailing Caverns",
        range = "(16-24)"
    },
    [179554] = {
        name = "The Temple of Atal'Hakkar",
        range = "(45-54)"
    },
    [179555] = {
        name = "Gnomeregan",
        range = "(24-32)"
    },
    [179585] = {
        name = "Blackrock Mountain",
        range = "(48-61)"
    },
    [179595] = {
        name = "The Stockade",
        range = "(21-29)"
    },
    [179596] = {
        name = "Ragefire Chasm",
        range = "(14-20)"
    },
    [182558] = {
        name = "Coilfang Reservoir",
        range = "(61-70)"
    },
    [182559] = {
        name = "Tempest Keep",
        range = "(69-70)"
    },
    [182560] = {
        name = "Caverns of Time",
        range = "(66-70)"
    },
    [184455] = {
        name = "Hellfire Citadel",
        range = "(58-70)"
    },
    [184456] = {
        name = "Magtheridon's Lair",
        range = "(70)"
    },
    [184458] = {
        name = "Auchindoun",
        range = "(63-70)"
    },
    [184462] = {
        name = "Gruul's Lair",
        range = "(70)"
    },
    [184463] = {
        name = "Karazhan",
        range = "(70)"
    },
    [185321] = {
        name = "Onyxia's Lair",
        range = "(60-70)"
    },
    [185322] = {
        name = "Ahn'Qiraj",
        range = "(60-70)"
    },
    [185433] = {
        name = "Zul'Gurub",
        range = "(60-70)"
    },
    [185550] = {
        name = "The Black Temple",
        range = "(70)"
    },
    [186251] = {
        name = "Zul'Aman",
        range = "(70)"
    },
    [188171] = {
        name = "Magisters' Terrace",
        range = "(70)"
    },
    [188172] = {
        name = "Sunwell Plateau",
        range = "(70)"
    },
    [188488] = {
        name = "Utgarde Keep",
        range = "(68-80)"
    },
    [191227] = {
        name = "Azjol-Nerub",
        range = "(70-80)"
    },
    [191529] = {
        name = "Drak'Tharon Keep",
        range = "(72-80)"
    },
    [192017] = {
        name = "Ulduar",
        range = "(75-80)"
    },
    [192399] = {
        name = "Utgarde Pinnacle",
        range = "(78-80)"
    },
    [192557] = {
        name = "Gundrak",
        range = "(74-80)"
    },
    [192622] = {
        name = "Wyrmrest Temple",
        range = "(80)"
    },
    [193166] = {
        name = "Naxxramas",
        range = "(77-80)"
    },
    [193602] = {
        name = "The Nexus",
        range = "(70-80)"
    },
    [195013] = {
        name = "Vault of Archavon",
        range = "(80)"
    },
    [195498] = {
        name = "Argent Tournament",
        range = "(80)"
    },
    [195695] = {
        name = "Icecrown Citadel",
        range = "(80)"
    },
    [202184] = {
        name = "The Frozen Halls",
        range = "(80)"
    },
}
