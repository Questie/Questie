---@class MeetingStones
local MeetingStones = QuestieLoader:CreateModule("MeetingStones")
local _MeetingStones = {}

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")


---@param objectId number
---@return table<string, string>
function MeetingStones:GetLocalizedDungeonNameAndLevelRangeByObjectId(objectId)
    local tableEntry = _MeetingStones.levelRanges[objectId]

    if (not tableEntry) then
        print("Missing entry for", objectId)
        return nil, nil
    end

    local zoneLookup = l10n.zoneCategoryLookup[GetLocale()]

    if zoneLookup[3][tableEntry.areaId] then
        return zoneLookup[3][tableEntry.areaId], tableEntry.range;
    else
        return zoneLookup[8][tableEntry.areaId], tableEntry.range;
    end
end

_MeetingStones.levelRanges = {
    [178824] = {
        areaId = 722, --Razorfen Downs
        range = "(33-41)"
    },
    [178825] = {
        areaId = 491, --Razorfen Kraul
        range = "(23-31)"
    },
    [178826] = {
        areaId = 2557, --Dire Maul
        range = "(54-61)"
    },
    [178827] = {
        areaId = 2100, --Maraudon
        range = "(40-52)"
    },
    [178828] = {
        areaId = 719, --Blackfathom Deeps
        range = "(20-28)"
    },
    [178829] = {
        areaId = 1176, --Zul'Farrak
        range = "(42-50)"
    },
    [178831] = {
        areaId = 2017, --Stratholme
        range = "(56-61)"
    },
    [178832] = {
        areaId = 2057, --Scholomance
        range = "(56-61)"
    },
    [178833] = {
        areaId = 1337, --Uldaman
        range = "(36-44)"
    },
    [178834] = {
        areaId = 1581, --The Deadmines
        range = "(16-24)"
    },
    [178844] = {
        areaId = 796, --Scarlet Monastery
        range = "(28-44)"
    },
    [178845] = {
        areaId = 209, --Shadowfang Keep
        range = "(17-25)"
    },
    [178884] = {
        areaId = 718, --Wailing Caverns
        range = "(16-24)"
    },
    [179554] = {
        areaId = 1477, --The Temple of Atal'Hakkar
        range = "(45-54)"
    },
    [179555] = {
        areaId = 721, --Gnomeregan
        range = "(24-32)"
    },
    [179585] = {
        areaId = 1445, --Blackrock Mountain
        range = "(48-61)"
    },
    [179595] = {
        areaId = 717, --The Stockade
        range = "(21-29)"
    },
    [179596] = {
        areaId = 2437, --Ragefire Chasm
        range = "(14-20)"
    },
    [182558] = {
        areaId = 3905, --Coilfang Reservoir
        range = "(61-70)"
    },
    [182559] = {
        areaId = 3842, --Tempest Keep
        range = "(69-70)"
    },
    [182560] = {
        areaId = 1941, --Caverns of Time
        range = "(66-70)"
    },
    [184455] = {
        areaId = 3545, --Hellfire Citadel
        range = "(58-70)"
    },
    [184456] = {
        areaId = 3836, --Magtheridon's Lair
        range = "(70)"
    },
    [184458] = {
        areaId = 3688, --Auchindoun
        range = "(63-70)"
    },
    [184462] = {
        areaId = 3618, --Gruul's Lair
        range = "(70)"
    },
    [184463] = {
        areaId = 2562, --Karazhan
        range = "(70)"
    },
    [185321] = {
        areaId = 2159, --Onyxia's Lair
        range = "(60-70)"
    },
    [185322] = {
        areaId = 3428, --Ahn'Qiraj
        range = "(60-70)"
    },
    [185433] = {
        areaId = 1977, --Zul'Gurub
        range = "(60-70)"
    },
    [185550] = {
        areaId = 3840, --The Black Temple
        range = "(70)"
    },
    [186251] = {
        areaId = 3805, --Zul'Aman
        range = "(70)"
    },
    [188171] = {
        areaId = 4095, --Magisters' Terrace
        range = "(70)"
    },
    [188172] = {
        areaId = 4075, --Sunwell Plateau
        range = "(70)"
    },
}
