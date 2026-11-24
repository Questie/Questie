dofile("setupTests.lua")
dofile("Localization/l10n.lua")

describe("WeaponMasterSkills", function()
    local WeaponMasterSkills
    local originalCSpell, originalGetSpellTexture

    before_each(function()
        originalCSpell, originalGetSpellTexture = _G.C_Spell, _G.GetSpellTexture
        _G.C_Spell = {GetSpellTexture = function(spellId) return "icon:" .. tostring(spellId) end}
        _G.GetSpellTexture = nil
        dofile("Modules/Map/WeaponMasterSkills.lua")
        WeaponMasterSkills = QuestieLoader:ImportModule("WeaponMasterSkills")
    end)

    after_each(function()
        _G.C_Spell, _G.GetSpellTexture = originalCSpell, originalGetSpellTexture
    end)

    it("adds a weapon icon to every listed skill", function()
        local title = WeaponMasterSkills.AppendSkillsToTitle("Weapon Master", 11865)

        assert.matches("Weapon Master\n\n %- |Ticon:15590:16|t Fist Weapons", title)
        assert.matches("\n %- |Ticon:266:16|t Guns", title)
        assert.matches("\n %- |Ticon:196:16|t One%-Handed Axes", title)
        assert.matches("\n %- |Ticon:199:16|t Two%-Handed Maces", title)
    end)

    it("does not change titles for NPCs without weapon skills", function()
        assert.are.equal("Innkeeper", WeaponMasterSkills.AppendSkillsToTitle("Innkeeper", 1))
    end)
end)
