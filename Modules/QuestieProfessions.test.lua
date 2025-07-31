dofile("setupTests.lua")

describe("QuestieProfessions", function()

    ---@type l10n
    local l10n
    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestieProfessions
    local QuestieProfessions

    local mockedProfessionSkill

    before_each(function()
        _G.ExpandSkillHeader = function() end
        _G.GetNumSkillLines = function()
            return 1
        end

        mockedProfessionSkill = 1
        _G.GetSkillLineInfo = function()
            return "Cooking", nil, nil, mockedProfessionSkill
        end

        l10n = require("Localization.l10n")
        l10n.translations = {
            ["First Aid"] = {["enUS"] = true},
            ["Blacksmithing"] = {["enUS"] = true},
            ["Leatherworking"] = {["enUS"] = true},
            ["Alchemy"] = {["enUS"] = true},
            ["Herbalism"] = {["enUS"] = true},
            ["Cooking"] = {["enUS"] = true},
            ["Mining"] = {["enUS"] = true},
            ["Tailoring"] = {["enUS"] = true},
            ["Engineering"] = {["enUS"] = true},
            ["Enchanting"] = {["enUS"] = true},
            ["Fishing"] = {["enUS"] = true},
            ["Skinning"] = {["enUS"] = true},
            ["Jewelcrafting"] = {["enUS"] = true},
            ["Archaeology"] = {["enUS"] = true},
            ["Inscription"] = {["enUS"] = true},
            ["Riding"] = {["enUS"] = true},
        }
        QuestieQuest = require("Modules.Quest.QuestieQuest")
        QuestieQuest.ResetAutoblacklistCategory = spy.new(function()  end)
        QuestieProfessions = require("Modules.QuestieProfessions")
        QuestieProfessions:Init()
    end)

    describe("Update", function()
        it("should detect when a player learned a new profession", function()

            local hasProfessionUpdate, hasNewProfession = QuestieProfessions:Update()

            assert.is_true(hasProfessionUpdate)
            assert.is_true(hasNewProfession)
            assert.spy(QuestieQuest.ResetAutoblacklistCategory).was.called_with("skill")
        end)

        it("should detect skill updates that reach the 5 level threshold", function()
            QuestieProfessions:Update()
            mockedProfessionSkill = 5

            local hasProfessionUpdate, hasNewProfession = QuestieProfessions:Update()

            assert.is_true(hasProfessionUpdate)
            assert.is_false(hasNewProfession)
            assert.spy(QuestieQuest.ResetAutoblacklistCategory).was_not.called()
        end)

        it("should detect skill updates that cross a 5 level threshold", function()
            QuestieProfessions:Update()
            mockedProfessionSkill = 6

            local hasProfessionUpdate, hasNewProfession = QuestieProfessions:Update()

            assert.is_true(hasProfessionUpdate)
            assert.is_false(hasNewProfession)
            assert.spy(QuestieQuest.ResetAutoblacklistCategory).was_not.called()
        end)

        it("should ignore skill updates that do not cross a 5 level threshold", function()
            QuestieProfessions:Update()
            mockedProfessionSkill = 2

            local hasProfessionUpdate, hasNewProfession = QuestieProfessions:Update()

            assert.is_false(hasProfessionUpdate)
            assert.is_false(hasNewProfession)
            assert.spy(QuestieQuest.ResetAutoblacklistCategory).was_not.called()
        end)
    end)
end)
