dofile("setupTests.lua")
dofile("Localization/l10n.lua")

describe("WeaponMasterSkills", function()
    local WeaponMasterSkills

    before_each(function()
        dofile("Modules/Map/WeaponMasterSkills.lua")
        WeaponMasterSkills = QuestieLoader:ImportModule("WeaponMasterSkills")
    end)

    it("adds a weapon icon to every listed skill", function()
        local title = WeaponMasterSkills.AppendSkillsToTitle("Weapon Master", 11865)

        assert.matches("Weapon Master\n %- |TInterface\\Icons\\INV_Weapon_Hand_01:16|t Fist Weapons", title)
        assert.matches("\n %- |TInterface\\Icons\\INV_Weapon_Rifle_01:16|t Guns", title)
        assert.matches("\n %- |TInterface\\Icons\\INV_Weapon_Axe_01:16|t One%-Handed Axes", title)
        assert.matches("\n %- |TInterface\\Icons\\INV_Hammer_04:16|t Two%-Handed Maces", title)
    end)

    it("does not change titles for NPCs without weapon skills", function()
        assert.are.equal("Innkeeper", WeaponMasterSkills.AppendSkillsToTitle("Innkeeper", 1))
    end)
end)
