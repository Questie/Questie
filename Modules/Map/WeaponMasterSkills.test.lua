dofile("setupTests.lua")

local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

describe("WeaponMasterSkills", function()
    ---@type WeaponMasterSkills
    local WeaponMasterSkills
    ---@type QuestieDBMock
    local mock

    before_each(function()
        mock = LoadQuestieDBMock()
        local LibQuestieDB = mock.lib
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        local npcKeys = QuestieDB.npcKeys
        local services = LibQuestieDB.Enum.serviceKeys
        local weaponSkills = LibQuestieDB.Enum.weaponSkillKeys
        QuestieDB.serviceKeys = services
        QuestieDB.weaponSkillKeys = weaponSkills
        QuestieDB.ServiceSet = LibQuestieDB.Set
        QuestieDB.NpcHasServices = LibQuestieDB.Npc.HasServices
        QuestieDB.QueryNPCSingle = LibQuestieDB.Npc.Get

        -- Skills are stored in skill line ID order, which is not the order of their names.
        mock.SetBaseRow("Npc", 2704, {
            [npcKeys.name] = "Hanashi",
            [npcKeys.services] = {services.WEAPON_MASTER},
            [npcKeys.trainerSkills] = {weaponSkills.AXES, weaponSkills.BOWS, weaponSkills.STAVES, weaponSkills.TWO_HANDED_AXES, weaponSkills.THROWN},
        })
        mock.SetBaseRow("Npc", 1386, {
            [npcKeys.name] = "Rogvar",
            [npcKeys.services] = {services.TRAINER, services.PROFESSION_TRAINER},
            [npcKeys.trainerSkills] = {171},
        })
        mock.SetBaseRow("Npc", 30, {[npcKeys.name] = "Forest Spider"})
        mock.SetBaseRow("Npc", 9000, {
            [npcKeys.name] = "Master Of An Unnamed Skill",
            [npcKeys.services] = {services.WEAPON_MASTER},
            [npcKeys.trainerSkills] = {weaponSkills.DAGGERS, 99999},
        })
        mock.SetBaseRow("Npc", 9001, {[npcKeys.name] = "Master Without Skills", [npcKeys.services] = {services.WEAPON_MASTER}})

        QuestieLoader:ImportModule("l10n")
        dofile("Localization/l10n.lua")
        dofile("Modules/Map/WeaponMasterSkills.lua")
        WeaponMasterSkills = QuestieLoader:ImportModule("WeaponMasterSkills")
    end)

    it("appends a weapon master's skills ordered by name", function()
        assert.are_equal(
            "Hanashi\n - Bows\n - One-Handed Axes\n - Staves\n - Thrown\n - Two-Handed Axes",
            WeaponMasterSkills.AppendSkillsToTitle("Hanashi", 2704))
    end)

    it("leaves a profession trainer's title alone although it has trainer skills", function()
        assert.are_equal("Rogvar", WeaponMasterSkills.AppendSkillsToTitle("Rogvar", 1386))
    end)

    it("leaves the title of an NPC without services and of an unknown NPC alone", function()
        assert.are_equal("Forest Spider", WeaponMasterSkills.AppendSkillsToTitle("Forest Spider", 30))
        assert.are_equal("Nobody", WeaponMasterSkills.AppendSkillsToTitle("Nobody", 424242))
    end)

    it("skips a skill line it has no name for", function()
        assert.are_equal("Master\n - Daggers", WeaponMasterSkills.AppendSkillsToTitle("Master", 9000))
    end)

    it("leaves the title alone when a weapon master has no skills recorded", function()
        assert.are_equal("Master", WeaponMasterSkills.AppendSkillsToTitle("Master", 9001))
    end)
end)
