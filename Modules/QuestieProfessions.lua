---@class QuestieProfessions
local QuestieProfessions = QuestieLoader:CreateModule("QuestieProfessions");

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local playerProfessions = {}
local professionTable = {}
local professionNames = {}
local alternativeProfessionNames = {}

function QuestieProfessions:Init()

    -- Generate professionTable with translations for all available locals.
    -- We need the translated values because the API returns localized profession names
    for professionId, professionName in pairs(professionNames) do
        for _, translation in pairs(l10n.translations[professionName]) do
            if translation == true then
                professionTable[professionName] = professionId
            else
                professionTable[translation] = professionId
            end
        end
    end

    for professionName, professionId in pairs(alternativeProfessionNames) do
        professionTable[professionName] = professionId
    end

    QuestieProfessions.professionTable = professionTable
end

function QuestieProfessions:Update()
    Questie:Debug(DEBUG_DEVELOP, "QuestieProfession: Update")
    ExpandSkillHeader(0)
    local isProfessionUpdate = false

    for i=1, GetNumSkillLines() do
        if i > 14 then break; end -- We don't have to go through all the weapon skills

        local skillName, isHeader, _, skillRank, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(i)
        if isHeader == nil and professionTable[skillName] then
            isProfessionUpdate = true -- A profession leveled up, not something like "Defense"
            playerProfessions[professionTable[skillName]] = {skillName, skillRank}
        end
    end
    return isProfessionUpdate
end

-- This function is just for debugging purpose
-- There is no need to access the playerProfessions table somewhere else
function QuestieProfessions:GetPlayerProfessions()
    return playerProfessions
end

function QuestieProfessions:GetPlayerProfessionNames()
    local playerProfessionNames = {}
    for _, data in pairs(playerProfessions) do
        table.insert(playerProfessionNames, data[1])
    end

    return playerProfessionNames
end

local function _HasProfession(profession)
    return profession == nil or playerProfessions[profession] ~= nil
end

local function _HasSkillLevel(profession, skillLevel)
    return skillLevel == nil or playerProfessions[profession][2] >= skillLevel
end

function QuestieProfessions:HasProfessionAndSkillLevel(requiredSkill)
    if requiredSkill == nil then
        return true
    end

    local profession = requiredSkill[1]
    local skillLevel = requiredSkill[2]
    return _HasProfession(profession) and _HasSkillLevel(profession, skillLevel)
end

QuestieProfessions.professionKeys = {
    FIRST_AID = 129,
    BLACKSMITHING = 164,
    LEATHERWORKING = 165,
    ALCHEMY = 171,
    HERBALISM = 182,
    COOKING = 185,
    MINING = 186,
    TAILORING = 197,
    ENGINEERING = 202,
    ENCHANTING = 333,
    FISHING = 356,
    SKINNING = 393,
    JEWELCRAFTING = 755,
    RIDING = 762,
}

professionNames = {
    [QuestieProfessions.professionKeys.FIRST_AID] = "First Aid",
    [QuestieProfessions.professionKeys.BLACKSMITHING] = "Blacksmithing",
    [QuestieProfessions.professionKeys.LEATHERWORKING] = "Leatherworking",
    [QuestieProfessions.professionKeys.ALCHEMY] = "Alchemy",
    [QuestieProfessions.professionKeys.HERBALISM] = "Herbalism",
    [QuestieProfessions.professionKeys.COOKING] = "Cooking",
    [QuestieProfessions.professionKeys.MINING] = "Mining",
    [QuestieProfessions.professionKeys.TAILORING] = "Tailoring",
    [QuestieProfessions.professionKeys.ENGINEERING] = "Engineering",
    [QuestieProfessions.professionKeys.ENCHANTING] = "Enchanting",
    [QuestieProfessions.professionKeys.FISHING] = "Fishing",
    [QuestieProfessions.professionKeys.SKINNING] = "Skinning",
    [QuestieProfessions.professionKeys.JEWELCRAFTING] = "Jewelcrafting",
    [QuestieProfessions.professionKeys.RIDING] = "Riding",
}

local sortIds = {
    [QuestieProfessions.professionKeys.FIRST_AID] = -324,
    [QuestieProfessions.professionKeys.BLACKSMITHING] = -121,
    [QuestieProfessions.professionKeys.LEATHERWORKING] = -182,
    [QuestieProfessions.professionKeys.ALCHEMY] = -181,
    [QuestieProfessions.professionKeys.HERBALISM] = -24,
    [QuestieProfessions.professionKeys.COOKING] = -304,
    [QuestieProfessions.professionKeys.MINING] = -667, -- Dummy Id
    [QuestieProfessions.professionKeys.TAILORING] = -264,
    [QuestieProfessions.professionKeys.ENGINEERING] = -201,
    [QuestieProfessions.professionKeys.ENCHANTING] = -668, -- Dummy Id
    [QuestieProfessions.professionKeys.FISHING] = -101,
    [QuestieProfessions.professionKeys.SKINNING] = -666, -- Dummy Id
    --[QuestieProfessions.professionKeys.JEWELCRAFTING] = ,
    --[QuestieProfessions.professionKeys.RIDING] = ,
}

---@return string
function QuestieProfessions:GetProfessionName(professionKey)
    return professionNames[professionKey]
end

---@return number
function QuestieProfessions:GetSortIdByProfessionId(professionId)
    return sortIds[professionId]
end

-- alternate naming scheme (used by DB)
alternativeProfessionNames = {
    ["Enchanter"] = 333,
    ["Tailor"] = 197,
    ["Leatherworker"] = 165,
    ["Engineer"] = 202,
    ["Blacksmith"] = 164,
    ["Herbalist"] = 182,
    ["Fisherman"] = 356,
    ["Fishmonger"] = 356,
    ["Skinner"] = 393,
    ["Alchemist"] = 171,
    ["Miner"] = 186,
    ["Cook"] = 185,
    ["Chef"] = 185,
    ["Butcher"] = 185,
    ["Physician"] = 129,
    ["Weapon Crafter"] = 164,
    ["Leathercrafter"] = 165,
    ["Armorsmith"] = 164,
    ["Weaponsmith"] = 164,
    ["Surgeon"] = 129,
    ["Trauma Surgeon"] = 129,
}
