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
        "ExpandSkillHeader", "GetNumSkillLines", "GetSkillLineInfo", "C_SkillInfo",
    }

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(globalNames) do
            savedGlobals[name] = _G[name]
        end
        _G.C_SkillInfo = nil
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

        dofile("Modules/QuestieCompat.lua")
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
        describe("with C_SkillInfo", function()
            local skillLines

            before_each(function()
                _G.GetSkillLineInfo, _G.GetNumSkillLines, _G.ExpandSkillHeader = nil, nil, nil
                skillLines = {
                    {skillID = 0, name = "Secondary Skills", isHeader = true, isCollapsed = false, rank = 0},
                    {skillID = 185, name = "Kochkunst", isHeader = false, isCollapsed = false, rank = 50},
                    {skillID = 762, name = "Reiten", isHeader = false, isCollapsed = false, rank = 75},
                }
                _G.C_SkillInfo = {
                    GetNumSkillLines = function() return #skillLines end,
                    GetSkillLineInfo = function(index) return skillLines[index] end,
                    ExpandSkillHeader = function() end,
                }
                dofile("Modules/QuestieProfessions.lua")
                QuestieProfessions:Init()
            end)

            it("should find professions and Riding by their skill line ID without a translated name", function()
                local updated, learned = QuestieProfessions:Update()

                assert.is_true(updated)
                assert.is_true(learned)
                assert.are.same({[185] = {"Kochkunst", 50}, [762] = {"Reiten", 75}}, QuestieProfessions:GetPlayerProfessions())
            end)

            it("should report an unlearned profession and reset skill-gated quest availability", function()
                QuestieProfessions:Update()
                QuestieQuest.ResetAutoblacklistCategory = spy.new(function() end)
                table.remove(skillLines, 2)

                local updated, learned = QuestieProfessions:Update()

                assert.is_true(updated)
                assert.is_false(learned)
                assert.are.same({[762] = {"Reiten", 75}}, QuestieProfessions:GetPlayerProfessions())
                assert.spy(QuestieQuest.ResetAutoblacklistCategory).was.called_with("skill")
            end)

            it("should find professions after the first skill lines", function()
                for _ = 1, 20 do
                    table.insert(skillLines, 2, {skillID = 95, name = "Defense", isHeader = false, isCollapsed = false, rank = 1})
                end

                QuestieProfessions:Update()

                assert.is_not_nil(QuestieProfessions:GetPlayerProfessions()[762])
            end)
        end)

        it("should report an unlearned profession and reset skill-gated quest availability on Classic", function()
            QuestieProfessions:Update()
            QuestieQuest.ResetAutoblacklistCategory = spy.new(function() end)
            _G.GetNumSkillLines = function() return 0 end

            local updated, learned = QuestieProfessions:Update()

            assert.is_true(updated)
            assert.is_false(learned)
            assert.are.same({}, QuestieProfessions:GetPlayerProfessions())
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
end)
