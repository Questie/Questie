---@class WeaponMasterSkills
local WeaponMasterSkills = QuestieLoader:CreateModule("WeaponMasterSkills")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local weaponSkillKeys = QuestieDB.weaponSkillKeys
local weaponMasterService = QuestieDB.ServiceSet(QuestieDB.serviceKeys.WEAPON_MASTER)

-- QuestieDB states which skills a weapon master teaches as skill line IDs in `trainerSkills`.
-- These are the English skill names Questie's localization is keyed by.
---@type table<integer, string>
local skillNames = {
    [weaponSkillKeys.AXES] = "One-Handed Axes",
    [weaponSkillKeys.BOWS] = "Bows",
    [weaponSkillKeys.CROSSBOWS] = "Crossbows",
    [weaponSkillKeys.DAGGERS] = "Daggers",
    [weaponSkillKeys.FIST_WEAPONS] = "Fist Weapons",
    [weaponSkillKeys.GUNS] = "Guns",
    [weaponSkillKeys.MACES] = "One-Handed Maces",
    [weaponSkillKeys.POLEARMS] = "Polearms",
    [weaponSkillKeys.STAVES] = "Staves",
    [weaponSkillKeys.SWORDS] = "One-Handed Swords",
    [weaponSkillKeys.THROWN] = "Thrown",
    [weaponSkillKeys.TWO_HANDED_AXES] = "Two-Handed Axes",
    [weaponSkillKeys.TWO_HANDED_MACES] = "Two-Handed Maces",
    [weaponSkillKeys.TWO_HANDED_SWORDS] = "Two-Handed Swords",
}

---Appends the weapon skills an NPC teaches to a tooltip title. Any other NPC keeps its title,
---including profession trainers, whose `trainerSkills` are not weapon skills.
---@param title string
---@param npcId NpcId
---@return string
function WeaponMasterSkills.AppendSkillsToTitle(title, npcId)
    if not QuestieDB.NpcHasServices(npcId, weaponMasterService) then
        return title
    end
    local skills = QuestieDB.QueryNPCSingle(npcId, "trainerSkills")
    if (not skills) then
        return title
    end

    local names = {}
    for _, skillId in ipairs(skills) do
        local name = skillNames[skillId]
        if name then
            names[#names + 1] = name
        end
    end
    -- Listed by English name, as the weapon master lists always were.
    table.sort(names)
    for _, name in ipairs(names) do
        title = title .. "\n - " .. l10n(name)
    end
    return title
end
