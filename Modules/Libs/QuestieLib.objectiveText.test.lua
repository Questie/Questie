dofile("setupTests.lua")

local localeCases = dofile("test/fixtures/objectiveTextLocales.lua")

-- Use frozen, source-backed constants rather than loading the ignored GlobalStrings dumps.
-- Reload after installing each client locale: QuestieLib captures objective formats at file load.
describe("QuestieLib objective formats from Era and Forever GlobalStrings", function()
    for _, case in ipairs(localeCases) do
        describe(case.client .. " " .. case.locale, function()
            local QuestieLib
            local originalOptional, originalMonsters, originalItems, originalObjects

            before_each(function()
                originalOptional = _G.OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION
                originalMonsters = _G.QUEST_MONSTERS_KILLED
                originalItems = _G.QUEST_ITEMS_NEEDED
                originalObjects = _G.QUEST_OBJECTS_FOUND
                _G.OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION = case.globals.OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION
                _G.QUEST_MONSTERS_KILLED = case.globals.QUEST_MONSTERS_KILLED
                _G.QUEST_ITEMS_NEEDED = case.globals.QUEST_ITEMS_NEEDED
                _G.QUEST_OBJECTS_FOUND = case.globals.QUEST_OBJECTS_FOUND

                dofile("Modules/Libs/QuestieLib.lua")
                QuestieLib = QuestieLoader:ImportModule("QuestieLib")
            end)

            after_each(function()
                _G.OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION = originalOptional
                _G.QUEST_MONSTERS_KILLED = originalMonsters
                _G.QUEST_ITEMS_NEEDED = originalItems
                _G.QUEST_OBJECTS_FOUND = originalObjects
            end)

            for _, sample in ipairs(case.objectives) do
                it("preserves " .. sample.type .. " wording, remote progress and optional labels", function()
                    local objective = {text = sample.text, type = sample.type, numFulfilled = 2, numRequired = 5, finished = false}
                    local missing = {text = sample.missingName, type = sample.type, numFulfilled = 2, numRequired = 5, finished = false}

                    assert.are.equal(sample.remoteText, QuestieLib.ReplaceObjectiveTextProgress(sample.text, 3, 5))
                    assert.are.equal(sample.description, QuestieLib.GetFullObjectiveText(sample.text))
                    assert.are.equal(sample.optionalRemoteText, QuestieLib.ReplaceObjectiveTextProgress(sample.optionalText, 3, 5))
                    assert.are.equal(sample.optionalDescription, QuestieLib.GetFullObjectiveText(sample.optionalText))
                    assert.is_true(QuestieLib.IsObjectiveOptional(sample.optionalText))
                    assert.is_false(QuestieLib.IsObjectiveOptional(sample.text))
                    local optional = {text = sample.optionalText, type = sample.type}
                    assert.is_true(QuestieLib.IsObjectiveDataLoaded(optional))
                    assert.are.equal(sample.optionalText, optional.text)
                    assert.is_true(QuestieLib.IsObjectiveDataLoaded(objective))
                    assert.are.equal(sample.text, objective.text)
                    assert.is_false(QuestieLib.IsObjectiveDataLoaded(missing))
                    assert.are.equal(sample.missingName, missing.text)
                end)

                it("rejects an unloaded " .. sample.type .. " name hidden by the optional label", function()
                    -- Construct only the input; the expected readiness result is always false.
                    local text = string.format(case.globals.OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION, sample.missingName)
                    local objective = {text = text, type = sample.type}

                    assert.is_false(QuestieLib.IsObjectiveDataLoaded(objective))
                    assert.are.equal(text, objective.text)
                end)
            end
        end)
    end
end)
