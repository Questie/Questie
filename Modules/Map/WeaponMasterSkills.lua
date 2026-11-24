---@class WeaponMasterSkills
local WeaponMasterSkills = QuestieLoader:CreateModule("WeaponMasterSkills")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local WEAPON_ICON_TEXTURES = {
    ["Bows"] = "Interface\\Icons\\INV_Weapon_Bow_07",
    ["Crossbows"] = "Interface\\Icons\\INV_Weapon_Crossbow_01",
    ["Daggers"] = "Interface\\Icons\\INV_Weapon_ShortBlade_05",
    ["Fist Weapons"] = "Interface\\Icons\\INV_Weapon_Hand_01",
    ["Guns"] = "Interface\\Icons\\INV_Weapon_Rifle_01",
    ["One-Handed Axes"] = "Interface\\Icons\\INV_Weapon_Axe_01",
    ["One-Handed Maces"] = "Interface\\Icons\\INV_Mace_01",
    ["One-Handed Swords"] = "Interface\\Icons\\INV_Sword_04",
    ["Polearms"] = "Interface\\Icons\\INV_Spear_07",
    ["Staves"] = "Interface\\Icons\\INV_Staff_08",
    ["Thrown"] = "Interface\\Icons\\INV_Weapon_Thrown_01",
    ["Two-Handed Axes"] = "Interface\\Icons\\INV_Axe_09",
    ["Two-Handed Maces"] = "Interface\\Icons\\INV_Hammer_04",
    ["Two-Handed Swords"] = "Interface\\Icons\\INV_Sword_07",
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

function WeaponMasterSkills.AppendSkillsToTitle(title, npcId)
    local skills = WeaponMasterSkills.data[npcId]
    if (not skills) then
        return title
    end

    for _, skill in ipairs(skills) do
        local icon = WEAPON_ICON_TEXTURES[skill]
        title = title .. "\n - " .. "|T" .. icon .. ":16|t " .. l10n(skill)
    end
    return title
end
