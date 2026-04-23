---@class QuestieProfessions
local QuestieProfessions = QuestieLoader:CreateModule("QuestieProfessions");
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local playerProfessions = {}
local professionTable = {}
local professionNames = {}
local specializationNames
local alternativeProfessionNames = {}

-- Fast local references
local ExpandSkillHeader, GetNumSkillLines, GetSkillLineInfo, IsSpellKnown = ExpandSkillHeader, GetNumSkillLines, GetSkillLineInfo, QuestieCompat.IsSpellKnown

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

    -- Since MoP introduced "Ways of Cooking" those show up as separate skills and we need to check more lines
    local maxSkillLineToCheck = Expansions.Current >= Expansions.MoP and 20 or 14
    for i=1, GetNumSkillLines() do
        if i > maxSkillLineToCheck then break; end -- We don't have to go through all the weapon skills

        local skillName, isHeader, _, skillRank, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(i)
        if (not isHeader) and professionTable[skillName] then
            temporaryPlayerProfessions[professionTable[skillName]] = {skillName, skillRank}
        end
    end

    for professionId, _ in pairs(temporaryPlayerProfessions) do
        if not playerProfessions[professionId] then
            Questie:Debug(Questie.DEBUG_DEVELOP, "New profession: " .. temporaryPlayerProfessions[professionId][1])
            hasProfessionUpdate = true
            hasNewProfession = true

            --? Reset all autoBlacklisted quests if a new skill is learned
            QuestieQuest.ResetAutoblacklistCategory("skill")
        else
            local oldRank = playerProfessions[professionId][2]
            local newRank = temporaryPlayerProfessions[professionId][2]
            if newRank > oldRank and (math.floor(oldRank / 5) ~= math.floor(newRank / 5)) then
                -- We only want to update every 5 skill levels because all other progressions won't unlock new quests
                Questie:Debug(Questie.DEBUG_DEVELOP, "Profession update: " .. temporaryPlayerProfessions[professionId][1] .. " " .. oldRank .. " -> " .. newRank)
                hasProfessionUpdate = true
            end
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

local function _HasRankLevel(profession, rankLevel)
    if not rankLevel then
        --? We return true here because otherwise we would have to check for nil everywhere
        return true
    end
    local professionRanks = QuestieProfessions.rankKeys[profession]
    local HasProfessionAndRankOrHigher = false
    for rankIndex = rankLevel, #professionRanks do
        local spellId = professionRanks[rankIndex]
        if IsSpellKnown(spellId) then
            HasProfessionAndRankOrHigher = true
        end
    end
    return (not rankLevel) or HasProfessionAndRankOrHigher
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

---@param requiredRanks { [1]: number, [2]: number }[]? List of {professionId, rankLevel} pairs (nil returns true, true)
---@return boolean HasProfession
---@return boolean HasRankLevel
function QuestieProfessions:HasProfessionAndRankLevel(requiredRanks)
    if not requiredRanks then
        --? We return true here because otherwise we would have to check for nil everywhere
        return true, true
    end

    local hasProfession = false
    for i=1,#requiredRanks do
        local profession = requiredRanks[i][1]
        local rankLevel = requiredRanks[i][2]
        if _HasProfession(profession) then
            if _HasRankLevel(profession, rankLevel) then
                return true, true
            end
            hasProfession = true
        end
    end
    return hasProfession, false
end

---@param requiredSpecialization { [1]: number } [1] = professionId
---@return boolean HasSpecialization
function QuestieProfessions.HasSpecialization(requiredSpecialization)
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
    ARCHAEOLOGY = 794,
}

---@enum RankEnum
QuestieProfessions.rankNames = {
    APPRENTICE = 1,
    JOURNEYMAN = 2,
    EXPERT = 3,
    ARTISAN = 4,
    MASTER = 5,
    GRAND_MASTER = 6,
    ILLUSTRIOUS_GRAND_MASTER = 7,
    ZEN_MASTER = 8,
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
    [QuestieProfessions.professionKeys.ARCHAEOLOGY] = "Archaeology",
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
    [QuestieProfessions.professionKeys.ARCHAEOLOGY] = -377,
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

local trainerNames = {
    [QuestieProfessions.professionKeys.FIRST_AID] = "First Aid Trainer",
    [QuestieProfessions.professionKeys.BLACKSMITHING] = "Blacksmithing Trainer",
    [QuestieProfessions.professionKeys.LEATHERWORKING] = "Leatherworking Trainer",
    [QuestieProfessions.professionKeys.ALCHEMY] = "Alchemy Trainer",
    [QuestieProfessions.professionKeys.HERBALISM] = "Herbalism Trainer",
    [QuestieProfessions.professionKeys.COOKING] = "Cooking Trainer",
    [QuestieProfessions.professionKeys.MINING] = "Mining Trainer",
    [QuestieProfessions.professionKeys.TAILORING] = "Tailoring Trainer",
    [QuestieProfessions.professionKeys.ENGINEERING] = "Engineering Trainer",
    [QuestieProfessions.professionKeys.ENCHANTING] = "Enchanting Trainer",
    [QuestieProfessions.professionKeys.FISHING] = "Fishing Trainer",
    [QuestieProfessions.professionKeys.SKINNING] = "Skinning Trainer",
    [QuestieProfessions.professionKeys.JEWELCRAFTING] = "Jewelcrafting Trainer",
    [QuestieProfessions.professionKeys.ARCHAEOLOGY] = "Archaeology Trainer",
    [QuestieProfessions.professionKeys.INSCRIPTION] = "Inscription Trainer",
    [QuestieProfessions.professionKeys.RIDING] = "Riding Trainer",
}

---@return string
function QuestieProfessions.GetTrainerName(professionKey)
    return trainerNames[professionKey]
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

---@class ProfessionMetaDB
QuestieProfessions.rankKeys = {
    [129] = { -- First Aid
      [1] = 3273, -- 1-75
      [2] = 3274, -- 75-150
      [3] = 7924, -- 150-225
      [4] = 10846, -- 225-300
      [5] = 27028, -- 300-375
      [6] = 45542, -- 375-450
      [7] = 74559, -- 450-525
      [8] = 110406, -- 525-600
    },
    [164] = { -- Blacksmithing
      [1] = 2018, -- 1-75
      [2] = 3100, -- 75-150
      [3] = 3538, -- 150-225
      [4] = 9785, -- 225-300
      [5] = 29844, -- 300-375
      [6] = 51300, -- 375-450
      [7] = 76666, -- 450-525
      [8] = 110396, -- 525-600
    },
    [165] = { -- Leatherworking
      [1] = 2108, -- 1-75
      [2] = 3104, -- 75-150
      [3] = 3811, -- 150-225
      [4] = 10662, -- 225-300
      [5] = 32549, -- 300-375
      [6] = 51302, -- 375-450
      [7] = 81199, -- 450-525
      [8] = 110423, -- 525-600
    },
    [171] = { -- Alchemy
      [1] = 2259, -- 1-75
      [2] = 3101, -- 75-150
      [3] = 3464, -- 150-225
      [4] = 11611, -- 225-300
      [5] = 28596, -- 300-375
      [6] = 51304, -- 375-450
      [7] = 80731, -- 450-525
      [8] = 105206, -- 525-600
    },
    [182] = { -- Herbalism
      [1] = 2366, -- 1-75
      [2] = 2368, -- 75-150
      [3] = 3570, -- 150-225
      [4] = 11993, -- 225-300
      [5] = 28695, -- 300-375
      [6] = 50300, -- 375-450
      [7] = 74519, -- 450-525
      [8] = 110413, -- 525-600
    },
    [185] = { -- Cooking
      [1] = 2550, -- 1-75
      [2] = 3102, -- 75-150
      [3] = 3413, -- 150-225
      [4] = 18260, -- 225-300
      [5] = 33359, -- 300-375
      [6] = 51296, -- 375-450
      [7] = 88053, -- 450-525
      [8] = 104381, -- 525-600
    },
    [186] = { -- Mining
      [1] = 2575, -- 1-75
      [2] = 2576, -- 75-150
      [3] = 3564, -- 150-225
      [4] = 10248, -- 225-300
      [5] = 29354, -- 300-375
      [6] = 50310, -- 375-450
      [7] = 74517, -- 450-525
      [8] = 102161, -- 525-600
    },
    [197] = { -- Tailoring
      [1] = 3908, -- 1-75
      [2] = 3909, -- 75-150
      [3] = 3910, -- 150-225
      [4] = 12180, -- 225-300
      [5] = 26790, -- 300-375
      [6] = 51309, -- 375-450
      [7] = 75156, -- 450-525
      [8] = 110426, -- 525-600
    },
    [202] = { -- Engineering
      [1] = 4036, -- 1-75
      [2] = 4037, -- 75-150
      [3] = 4038, -- 150-225
      [4] = 12656, -- 225-300
      [5] = 30350, -- 300-375
      [6] = 51306, -- 375-450
      [7] = 82774, -- 450-525
      [8] = 110403, -- 525-600
    },
    [333] = { -- Enchanting
      [1] = 7411, -- 1-75
      [2] = 7412, -- 75-150
      [3] = 7413, -- 150-225
      [4] = 13920, -- 225-300
      [5] = 28029, -- 300-375
      [6] = 51313, -- 375-450
      [7] = 74258, -- 450-525
      [8] = 110400, -- 525-600
    },
    [356] = { -- Fishing
      [1] = 7620, -- 1-75
      [2] = 7731, -- 75-150
      [3] = 7732, -- 150-225
      [4] = 18248, -- 225-300
      [5] = 33095, -- 300-375
      [6] = 51294, -- 375-450
      [7] = 88868, -- 450-525
      [8] = 110410, -- 525-600
    },
    [393] = { -- Skinning
      [1] = 8613, -- 1-75
      [2] = 8617, -- 75-150
      [3] = 8618, -- 150-225
      [4] = 10768, -- 225-300
      [5] = 32678, -- 300-375
      [6] = 50305, -- 375-450
      [7] = 74522, -- 450-525
      [8] = 102216, -- 525-600
    },
    [755] = { -- Jewelcrafting
      [1] = 25229, -- 1-75
      [2] = 25230, -- 75-150
      [3] = 28894, -- 150-225
      [4] = 28895, -- 225-300
      [5] = 28897, -- 300-375
      [6] = 51311, -- 375-450
      [7] = 73318, -- 450-525
      [8] = 110420, -- 525-600
    },
    [773] = { -- Inscription
      [1] = 45357, -- 1-75
      [2] = 45358, -- 75-150
      [3] = 45359, -- 150-225
      [4] = 45360, -- 225-300
      [5] = 45361, -- 300-375
      [6] = 45363, -- 375-450
      [7] = 86008, -- 450-525
      [8] = 110417, -- 525-600
    },
    [794] = { -- Archaeology
      [1] = 78670, -- 1-75
      [2] = 88961, -- 75-150
      [3] = 89718, -- 150-225
      [4] = 89719, -- 225-300
      [5] = 89720, -- 300-375
      [6] = 89721, -- 375-450
      [7] = 89722, -- 450-525
      [8] = 110393, -- 525-600
    },
}

return QuestieProfessions
