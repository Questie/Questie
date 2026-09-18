dofile("setupTests.lua")

describe("QuestieProfessions", function()

    ---@type l10n
    local l10n
    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestieProfessions
    local QuestieProfessions

    local mockedProfessionSkill
    local savedGlobals
    local globalNames = {
        "ExpandSkillHeader", "GetNumSkillLines", "GetSkillLineInfo", "GetProfessions", "GetProfessionInfo",
        "AbandonSkill", "hooksecurefunc",
    }

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(globalNames) do
            savedGlobals[name] = _G[name]
        end
        _G.ExpandSkillHeader = function() end
        _G.GetNumSkillLines = function()
            return 1
        end

        mockedProfessionSkill = 1
        _G.GetSkillLineInfo = function()
            return "Cooking", nil, nil, mockedProfessionSkill
        end

        dofile("Localization/l10n.lua")
        l10n = QuestieLoader:ImportModule("l10n")
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
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.ResetAutoblacklistCategory = spy.new(function()  end)

        dofile("Modules/QuestieProfessions.lua")
        QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
        QuestieProfessions:Init()
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do
            _G[name] = savedGlobals[name]
        end
    end)

    describe("Update", function()
        it("keeps secondary professions when modern primary-profession slots are empty", function()
            _G.GetSkillLineInfo = nil
            _G.AbandonSkill = nil
            _G.GetProfessions = function() return nil, nil, nil, 4, 5 end
            local professions = {
                [4] = {name = "Fishing", rank = 25, id = 356},
                [5] = {name = "Cooking", rank = 50, id = 185},
            }
            _G.GetProfessionInfo = function(index)
                local profession = professions[index]
                return profession.name, nil, profession.rank, nil, nil, nil, profession.id
            end
            dofile("Modules/QuestieProfessions.lua")

            local updated, learned = QuestieProfessions:Update()

            assert.is_true(updated)
            assert.is_true(learned)
            assert.are.same({[356] = {"Fishing", 25}, [185] = {"Cooking", 50}}, QuestieProfessions:GetPlayerProfessions())
        end)

        it("reports modern profession removal and resets skill-gated quest availability", function()
            _G.GetSkillLineInfo = nil
            _G.AbandonSkill = nil
            _G.GetProfessions = function() return nil, nil, nil, nil, 5 end
            _G.GetProfessionInfo = function() return "Cooking", nil, 50, nil, nil, nil, 185 end
            dofile("Modules/QuestieProfessions.lua")
            QuestieProfessions:Update()
            QuestieQuest.ResetAutoblacklistCategory = spy.new(function() end)
            _G.GetProfessions = function() end

            local updated, learned = QuestieProfessions:Update()

            assert.is_true(updated)
            assert.is_false(learned)
            assert.are.same({}, QuestieProfessions:GetPlayerProfessions())
            assert.spy(QuestieQuest.ResetAutoblacklistCategory).was.called(1)
            assert.spy(QuestieQuest.ResetAutoblacklistCategory).was.called_with("skill")
        end)

        it("should detect when a player learned a new profession", function()

            local hasProfessionUpdate, hasNewProfession = QuestieProfessions:Update()

            assert.is_true(hasProfessionUpdate)
            assert.is_true(hasNewProfession)
            assert.spy(QuestieQuest.ResetAutoblacklistCategory).was.called_with("skill")
        end)

        it("should detect skill updates that reach the 5 level threshold", function()
            QuestieProfessions:Update()
            QuestieQuest.ResetAutoblacklistCategory = spy.new(function()  end)
            mockedProfessionSkill = 5

            local hasProfessionUpdate, hasNewProfession = QuestieProfessions:Update()

            assert.is_true(hasProfessionUpdate)
            assert.is_false(hasNewProfession)
            assert.spy(QuestieQuest.ResetAutoblacklistCategory).was.not_called()
        end)

        it("should detect skill updates that cross a 5 level threshold", function()
            QuestieProfessions:Update()
            QuestieQuest.ResetAutoblacklistCategory = spy.new(function()  end)
            mockedProfessionSkill = 6

            local hasProfessionUpdate, hasNewProfession = QuestieProfessions:Update()

            assert.is_true(hasProfessionUpdate)
            assert.is_false(hasNewProfession)
            assert.spy(QuestieQuest.ResetAutoblacklistCategory).was.not_called()
        end)

        it("should ignore skill updates that do not cross a 5 level threshold", function()
            QuestieProfessions:Update()
            QuestieQuest.ResetAutoblacklistCategory = spy.new(function()  end)
            mockedProfessionSkill = 2

            local hasProfessionUpdate, hasNewProfession = QuestieProfessions:Update()

            assert.is_false(hasProfessionUpdate)
            assert.is_false(hasNewProfession)
            assert.spy(QuestieQuest.ResetAutoblacklistCategory).was.not_called()
        end)
    end)

    describe("AbandonSkill", function()
        it("should reset the skill blacklist and recalculate available quests when a profession is abandoned", function()
            _G.AbandonSkill = function() end
            local abandonSkillCallback
            _G.hooksecurefunc = function(name, callback)
                if name == "AbandonSkill" then
                    abandonSkillCallback = callback
                end
            end

            local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
            AvailableQuests.CalculateAndDrawAll = spy.new(function() end)

            -- Force a fresh load so the hooksecurefunc("AbandonSkill", ...) registration re-runs and is captured
            dofile("Modules/QuestieProfessions.lua")
            QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
            QuestieProfessions:Init()

            -- Register the profession so the abandon hook acts on it
            QuestieProfessions:Update()

            abandonSkillCallback(1)

            assert.spy(QuestieQuest.ResetAutoblacklistCategory).was.called_with("skill")
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.called()
        end)
    end)
end)
