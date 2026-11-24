---@class WeaponMasterSkills
local WeaponMasterSkills = QuestieLoader:CreateModule("WeaponMasterSkills")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local WEAPON_SKILL_SPELL_IDS = {
    ["Bows"] = 264,
    ["Crossbows"] = 5011,
    ["Daggers"] = 1180,
    ["Fist Weapons"] = 15590,
    ["Guns"] = 266,
    ["One-Handed Axes"] = 196,
    ["One-Handed Maces"] = 198,
    ["One-Handed Swords"] = 201,
    ["Polearms"] = 200,
    ["Staves"] = 227,
    ["Thrown"] = 2567,
    ["Two-Handed Axes"] = 197,
    ["Two-Handed Maces"] = 199,
    ["Two-Handed Swords"] = 202,
}

WeaponMasterSkills.data = {
    -- Alliance Weapon Trainers
    [11865] = {"Fist Weapons", "Guns", "One-Handed Axes", "One-Handed Maces", "Two-Handed Axes", "Two-Handed Maces"},
    [11866] = {"Bows", "Daggers", "Fist Weapons", "Staves", "Thrown"},
    [11867] = {"Crossbows", "Daggers", "One-Handed Swords", "Polearms", "Staves", "Two-Handed Swords"},
    [13084] = {"Crossbows", "Daggers", "Thrown"},
    -- Horde Weapon Trainers
    [2704] = {"Bows", "One-Handed Axes", "Staves", "Thrown", "Two-Handed Axes"},
    [11868] = {"Bows", "Daggers", "Fist Weapons", "One-Handed Axes", "Thrown", "Two-Handed Axes"},
    [11869] = {"Guns", "One-Handed Maces", "Staves", "Two-Handed Maces"},
    [11870] = {"Crossbows", "Daggers", "One-Handed Swords", "Polearms", "Two-Handed Swords"},
}

if Questie.IsTBC or Questie.IsWotlk then
    -- Blood Elf Starting Area Weapon Trainers
    WeaponMasterSkills.data[16621] = {"Bows", "Daggers", "One-Handed Swords", "Polearms", "Thrown", "Two-Handed Swords"}
    WeaponMasterSkills.data[17005] = {"Bows", "Daggers", "One-Handed Swords", "Polearms", "Thrown", "Two-Handed Swords"}
    -- Draenei Starting Area Weapon Trainers
    WeaponMasterSkills.data[16773] = {"Crossbows", "Daggers", "One-Handed Maces", "One-Handed Swords", "Two-Handed Maces", "Two-Handed Swords"}
end

local function GetWeaponSkillIcon(spellId)
    local cSpell = _G["C_Spell"]
    local getSpellTexture = cSpell and cSpell["GetSpellTexture"]
    if getSpellTexture then
        return getSpellTexture(spellId)
    elseif GetSpellTexture then
        return GetSpellTexture(spellId)
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

function WeaponMasterSkills.AppendSkillsToTitle(title, npcId)
    local skills = WeaponMasterSkills.data[npcId]
    if (not skills) then
        return title
    end

    for index, skill in ipairs(skills) do
        local icon = GetWeaponSkillIcon(WEAPON_SKILL_SPELL_IDS[skill])
        local separator = index == 1 and "\n\n - " or "\n - "
        title = title .. separator .. "|T" .. icon .. ":16|t " .. l10n(skill)
    end
    return title
end
