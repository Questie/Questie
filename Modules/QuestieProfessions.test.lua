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
        QuestieQuest = QuestieLoader:CreateModule("QuestieQuest")
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

    describe("AbandonSkill", function()
        local AvailableQuests
        local abandonSkillCallback

        before_each(function()
            _G.AbandonSkill = function() end
            _G.hooksecurefunc = function(name, callback)
                if name == "AbandonSkill" then
                    abandonSkillCallback = callback
                end
            end

            AvailableQuests = QuestieLoader:CreateModule("AvailableQuests")
            AvailableQuests.CalculateAndDrawAll = spy.new(function() end)

            -- Force a fresh load so the hooksecurefunc("AbandonSkill", ...) registration re-runs and is captured
            package.loaded["Modules.QuestieProfessions"] = nil
            QuestieProfessions = require("Modules.QuestieProfessions")
            QuestieProfessions:Init()

            -- Register the profession so the abandon hook acts on it
            QuestieProfessions:Update()
        end)

        it("should reset the skill blacklist and recalculate available quests when a profession is abandoned", function()
            abandonSkillCallback(1)

            assert.spy(QuestieQuest.ResetAutoblacklistCategory).was.called_with("skill")
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.called()
        end)
    end)
end)
