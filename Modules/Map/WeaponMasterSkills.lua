local WeaponMasterSkills = {}

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

function WeaponMasterSkills.appendSkillsToTitle(title, skills)
    for _, skill in ipairs(skills) do
        title = title .. "\n - " .. l10n(skill)
    end
    return title
end

return WeaponMasterSkills