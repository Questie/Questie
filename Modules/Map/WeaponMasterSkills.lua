---@class WeaponMasterSkills
local WeaponMasterSkills = QuestieLoader:CreateModule("WeaponMasterSkills")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

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
        title = title .. "\n - " .. l10n(skill)
    end
    return title
end