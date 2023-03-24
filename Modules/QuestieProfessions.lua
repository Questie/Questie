---@class QuestieProfessions
local QuestieProfessions = QuestieLoader:CreateModule("QuestieProfessions");
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local playerProfessions = {}
local professionTable = {}
local professionNames = {}
local specializationNames
local alternativeProfessionNames = {}

-- Fast local references
local ExpandSkillHeader, GetNumSkillLines, GetSkillLineInfo, IsSpellKnown = ExpandSkillHeader, GetNumSkillLines, GetSkillLineInfo, IsSpellKnown

hooksecurefunc("AbandonSkill", function(skillIndex)
    local skillName = GetSkillLineInfo(skillIndex)
    if skillName and professionTable[skillName] then
        if playerProfessions[professionTable[skillName]] then
            Questie:Debug(Questie.DEBUG_DEVELOP, "Unlearned profession: " .. skillName .. "(" .. professionTable[skillName] .. ")")
            playerProfessions[professionTable[skillName]] = nil
            --? Reset all autoBlacklisted quests if a skill is abandoned
            QuestieQuest.ResetAutoblacklistCategory("skill")
        end
    end
end)

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

--- Returns if a skill increased and learning a new profession, does not however return if a skill is unlearned
---@return boolean HasProfessionUpdate @Returns true if the players profession skill has increased
---@return boolean HasNewProfession @Returns true if the player has learned a new profession
function QuestieProfessions:Update()
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieProfession: Update")
    ExpandSkillHeader(0)
    local hasProfessionUpdate = false
    local hasNewProfession = false

    --- Used to compare to be able to detect if a profession has been learned
    local temporaryPlayerProfessions = {}

    for i=1, GetNumSkillLines() do
        if i > 14 then break; end -- We don't have to go through all the weapon skills

        local skillName, isHeader, _, skillRank, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(i)
        if (not isHeader) and professionTable[skillName] then
            temporaryPlayerProfessions[professionTable[skillName]] = {skillName, skillRank}
        end
    end

    for professionId, _ in pairs(temporaryPlayerProfessions) do
        if not playerProfessions[professionId] then
            Questie:Debug(Questie.DEBUG_DEVELOP, "New profession: " .. temporaryPlayerProfessions[professionId][1])
            -- This is kept here for legacy support, even though it's not really true...
            hasProfessionUpdate = true
            -- A new profession was learned
            hasNewProfession = true

            --? Reset all autoBlacklisted quests if a new skill is learned
            QuestieQuest.ResetAutoblacklistCategory("skill")
        elseif temporaryPlayerProfessions[professionId][2] > playerProfessions[professionId][2] then
            Questie:Debug(Questie.DEBUG_DEVELOP, "Profession update: " .. temporaryPlayerProfessions[professionId][1] .. " " .. playerProfessions[professionId][2] .. " -> " .. temporaryPlayerProfessions[professionId][2])
            hasProfessionUpdate = true -- A profession leveled up, not something like "Defense"
        end
    end
    playerProfessions = temporaryPlayerProfessions
    return hasProfessionUpdate, hasNewProfession
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
    return (not profession) or playerProfessions[profession] ~= nil
end

local function _HasSkillLevel(profession, skillLevel)
    return (not skillLevel) or (playerProfessions[profession] and playerProfessions[profession][2] >= skillLevel)
end

---@param requiredSkill { [1]: number, [2]: number } [1] = professionId, [2] = skillLevel
---@return boolean HasProfession
---@return boolean HasSkillLevel
function QuestieProfessions:HasProfessionAndSkillLevel(requiredSkill)
    if not requiredSkill then
        --? We return true here because otherwise we would have to check for nil everywhere
        return true, true
    end

    local profession = requiredSkill[1]
    local skillLevel = requiredSkill[2]
    return _HasProfession(profession), _HasSkillLevel(profession, skillLevel)
end

---@param requiredSpecialization { [1]: number } [1] = professionId
---@return boolean HasSpecialization
function QuestieProfessions:HasSpecialization(requiredSpecialization)
    if not requiredSpecialization then
        --? We return true here because otherwise we would have to check for nil everywhere
        return true
    end
    local professionKeys = QuestieProfessions.professionKeys
    local specializationKeys = QuestieProfessions.specializationKeys
    for _, value in pairs(QuestieProfessions.professionKeys) do
        if value == requiredSpecialization then -- if we determine input is a profession
            if requiredSpecialization == professionKeys.ALCHEMY then
                return not (IsSpellKnown(specializationKeys.ALCHEMY_ELIXIR)
                or IsSpellKnown(specializationKeys.ALCHEMY_POTION)
                or IsSpellKnown(specializationKeys.ALCHEMY_TRANSMUTATION))
                -- if the profession is alchemy, we only return true if the player does NOT know
                -- the spells for elixir, potion, or transmutation master; otherwise return false
            elseif requiredSpecialization == professionKeys.BLACKSMITHING then
                return not (IsSpellKnown(specializationKeys.BLACKSMITHING_ARMOR)
                or IsSpellKnown(specializationKeys.BLACKSMITHING_WEAPON))

            elseif requiredSpecialization == professionKeys.ENGINEERING then
                return not (IsSpellKnown(specializationKeys.ENGINEERING_GNOMISH)
                or IsSpellKnown(specializationKeys.ENGINEERING_GOBLIN))

            elseif requiredSpecialization == professionKeys.LEATHERWORKING then
                return not (IsSpellKnown(specializationKeys.LEATHERWORKING_DRAGONSCALE)
                or IsSpellKnown(specializationKeys.LEATHERWORKING_ELEMENTAL)
                or IsSpellKnown(specializationKeys.LEATHERWORKING_TRIBAL))

            elseif requiredSpecialization == professionKeys.TAILORING then
                return not (IsSpellKnown(specializationKeys.TAILORING_MOONCLOTH)
                or IsSpellKnown(specializationKeys.TAILORING_SHADOWEAVE)
                or IsSpellKnown(specializationKeys.TAILORING_SPELLFIRE))

            end
            return _HasProfession(requiredSpecialization)
            -- if the profession is not one with known specs, return true if the player has that profession
        end
    end
    for _, value in pairs(specializationKeys) do
        if value == requiredSpecialization then -- if we determine input is a specialization
            return IsSpellKnown(requiredSpecialization) -- return true if the spell is known, false if not
        end
    end
    return true
end

---@enum ProfessionEnum
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
    INSCRIPTION = 773,
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
    [QuestieProfessions.professionKeys.INSCRIPTION] = "Inscription",
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
    [QuestieProfessions.professionKeys.INSCRIPTION] = -371,
    [QuestieProfessions.professionKeys.JEWELCRAFTING] = -373,
    --[QuestieProfessions.professionKeys.RIDING] = ,
}

QuestieProfessions.specializationKeys = { -- specializations use spellID, professions use skillID
    ALCHEMY = QuestieProfessions.professionKeys.ALCHEMY,
    ALCHEMY_ELIXIR = 28677,
    ALCHEMY_POTION = 28675,
    ALCHEMY_TRANSMUTATION = 28672,
    BLACKSMITHING = QuestieProfessions.professionKeys.BLACKSMITHING,
    BLACKSMITHING_ARMOR = 9788,
    BLACKSMITHING_WEAPON = 9787,
    BLACKSMITHING_WEAPON_AXE = 17041,
    BLACKSMITHING_WEAPON_HAMMER = 17040,
    BLACKSMITHING_WEAPON_SWORD = 17039,
    ENGINEERING = QuestieProfessions.professionKeys.ENGINEERING,
    ENGINEERING_GNOMISH = 20219,
    ENGINEERING_GOBLIN = 20222,
    LEATHERWORKING = QuestieProfessions.professionKeys.LEATHERWORKING,
    LEATHERWORKING_DRAGONSCALE = 10656,
    LEATHERWORKING_ELEMENTAL = 10658,
    LEATHERWORKING_TRIBAL = 10660,
    TAILORING = QuestieProfessions.professionKeys.TAILORING,
    TAILORING_MOONCLOTH = 26798,
    TAILORING_SHADOWEAVE = 26801,
    TAILORING_SPELLFIRE = 26797,
}

specializationNames = {
    [QuestieProfessions.specializationKeys.ALCHEMY_ELIXIR] = "Elixir Master",
    [QuestieProfessions.specializationKeys.ALCHEMY_POTION] = "Potion Master",
    [QuestieProfessions.specializationKeys.ALCHEMY_TRANSMUTATION] = "Transmutation Master",
    [QuestieProfessions.specializationKeys.BLACKSMITHING_ARMOR] = "Armorsmith",
    [QuestieProfessions.specializationKeys.BLACKSMITHING_WEAPON] = "Weaponsmith",
    [QuestieProfessions.specializationKeys.BLACKSMITHING_WEAPON_AXE] = "Master Axesmith",
    [QuestieProfessions.specializationKeys.BLACKSMITHING_WEAPON_HAMMER] = "Master Hammersmith",
    [QuestieProfessions.specializationKeys.BLACKSMITHING_WEAPON_SWORD] = "Master Swordsmith",
    [QuestieProfessions.specializationKeys.ENGINEERING_GNOMISH] = "Gnomish Engineer",
    [QuestieProfessions.specializationKeys.ENGINEERING_GOBLIN] = "Goblin Engineer",
    [QuestieProfessions.specializationKeys.LEATHERWORKING_DRAGONSCALE] = "Dragonscale Leatherworking",
    [QuestieProfessions.specializationKeys.LEATHERWORKING_ELEMENTAL] = "Elemental Leatherworking",
    [QuestieProfessions.specializationKeys.LEATHERWORKING_TRIBAL] = "Tribal Leatherworking",
    [QuestieProfessions.specializationKeys.TAILORING_MOONCLOTH] = "Mooncloth Tailoring",
    [QuestieProfessions.specializationKeys.TAILORING_SHADOWEAVE] = "Shadoweave Tailoring",
    [QuestieProfessions.specializationKeys.TAILORING_SPELLFIRE] = "Spellfire Tailoring",
}

---@return string
function QuestieProfessions:GetProfessionName(professionKey)
    return professionNames[professionKey]
end

---@return string
function QuestieProfessions:GetSpecializationName(specializationKey)
    -- TODO: this function is as of yet unused, if you plan on using it add translations for the specializationNames table
    return specializationNames[specializationKey]
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