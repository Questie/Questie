dofile("setupTests.lua")

describe("TrackerAchievements", function()
    ---@type TrackerAchievements
    local TrackerAchievements

    local achievements, linkedQuestIds, originals

    local globalNames = {"GetAchievementInfo", "GetAchievementNumCriteria", "GetAchievementCriteriaInfo"}

    local function _Criteria(text, completed, progress, needed, refId, quantityString)
        return {text = text, completed = completed, progress = progress, needed = needed, refId = refId, quantityString = quantityString}
    end

    before_each(function()
        achievements = {}
        linkedQuestIds = {}
        originals = {}
        for _, name in ipairs(globalNames) do originals[name] = _G[name] end

        _G.GetAchievementInfo = function(id)
            local achievement = achievements[id]
            if not achievement then
                return nil
            end
            return id, achievement.name, nil, nil, nil, nil, nil, achievement.description, nil, nil, nil, nil, achievement.complete
        end
        _G.GetAchievementNumCriteria = function(id) return #achievements[id].criteria end
        _G.GetAchievementCriteriaInfo = function(id, index)
            local criteria = achievements[id].criteria[index]
            return criteria.text, nil, criteria.completed, criteria.progress, criteria.needed, nil, nil, criteria.refId or 0,
                criteria.quantityString or (criteria.progress .. "/" .. criteria.needed)
        end

        Questie.db.profile.hideCompletedAchieveObjectives = false
        QuestieLoader:ImportModule("QuestieDB").GetQuest = function(id) return linkedQuestIds[id] end

        dofile("Modules/Tracker/TrackerAchievements.lua")
        TrackerAchievements = QuestieLoader:ImportModule("TrackerAchievements")
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do _G[name] = originals[name] end
    end)

    it("should return nothing when no achievement is tracked", function()
        assert.are_same({}, TrackerAchievements.GetAchievements({}))
    end)

    it("should return the achievement with its criteria in the order of the ids", function()
        achievements[1] = {name = "Explorer", description = "Explore.", criteria = {
            _Criteria("Elwynn Forest", true, 1, 1),
            _Criteria("Westfall", false, 0, 1),
        }}
        achievements[2] = {name = "Fisher", description = "Fish.", criteria = {_Criteria("Fish", false, 0, 1)}}

        local result = TrackerAchievements.GetAchievements({2, 1})

        assert.are_same({2, 1}, {result[1].Id, result[2].Id})
        assert.are_same("Explorer", result[2].Name)
        assert.are_same("Explore.", result[2].Description)
        assert.are_same(2, #result[2].Criteria)
    end)

    it("should skip unknown and completed achievements", function()
        achievements[1] = {name = "Done", description = "Done.", complete = true, criteria = {}}

        assert.are_same({}, TrackerAchievements.GetAchievements({1, 99}))
    end)

    describe("criteria", function()
        it("should use the completion state for the color of a single criteria", function()
            achievements[1] = {name = "Explorer", description = "Explore.", criteria = {
                _Criteria("Elwynn Forest", true, 1, 1),
                _Criteria("Westfall", false, 0, 1),
            }}

            local criteria = TrackerAchievements.GetAchievements({1})[1].Criteria

            assert.are_same({Text = "Elwynn Forest", Completed = true, Collected = 1, Needed = 1, IsDescription = false}, criteria[1])
            assert.are_same({Text = "Westfall", Completed = false, Collected = 0, Needed = 1, IsDescription = false}, criteria[2])
        end)

        it("should remove the trailing dot of the criteria text", function()
            achievements[1] = {name = "Explorer", description = "Explore.", criteria = {_Criteria("Westfall.", false, 0, 1)}}

            assert.are_same("Westfall", TrackerAchievements.GetAchievements({1})[1].Criteria[1].Text)
        end)

        it("should fall back to the description when the criteria text is empty", function()
            achievements[1] = {name = "Explorer", description = "Explore the world.", criteria = {_Criteria("", false, 0, 1)}}

            assert.are_same("Explore the world", TrackerAchievements.GetAchievements({1})[1].Criteria[1].Text)
        end)

        it("should hide completed criteria when configured", function()
            Questie.db.profile.hideCompletedAchieveObjectives = true
            achievements[1] = {name = "Explorer", description = "Explore.", criteria = {
                _Criteria("Elwynn Forest", true, 1, 1),
                _Criteria("Westfall", false, 0, 1),
            }}

            local criteria = TrackerAchievements.GetAchievements({1})[1].Criteria

            assert.are_same(1, #criteria)
            assert.are_same("Westfall", criteria[1].Text)
        end)

        it("should return no criteria when all are completed and hidden", function()
            Questie.db.profile.hideCompletedAchieveObjectives = true
            achievements[1] = {name = "Explorer", description = "Explore.", criteria = {_Criteria("Elwynn Forest", true, 1, 1)}}

            assert.are_same({}, TrackerAchievements.GetAchievements({1})[1].Criteria)
        end)

        it("should show the progress of unfinished criteria with more than one required quantity", function()
            achievements[1] = {name = "Fisher", description = "Fish.", criteria = {_Criteria("Fish caught", false, 3, 10)}}

            local criteria = TrackerAchievements.GetAchievements({1})[1].Criteria[1]

            assert.are_same("3/10", criteria.Progress)
            assert.are_same(3, criteria.Collected)
            assert.are_same(10, criteria.Needed)
        end)

        it("should not show progress for finished criteria", function()
            achievements[1] = {name = "Fisher", description = "Fish.", criteria = {_Criteria("Fish caught", true, 10, 10)}}

            assert.is_nil(TrackerAchievements.GetAchievements({1})[1].Criteria[1].Progress)
        end)

        it("should use the quantity string of the game when it contains an escape sequence", function()
            achievements[1] = {name = "Rich", description = "Money.", criteria = {
                _Criteria("Gold", false, 5, 10, nil, "5/ 10|TInterface\\Icons\\Coin:0|t"),
            }}

            assert.are_same("5/10|TInterface\\Icons\\Coin:0|t", TrackerAchievements.GetAchievements({1})[1].Criteria[1].Progress)
        end)

        it("should link criteria that are achievements of their own", function()
            achievements[1] = {name = "Champion", description = "Win.", criteria = {_Criteria("Darnassus", false, 0, 1, 2)}}
            achievements[2] = {name = "Darnassus", description = "Win in Darnassus.", criteria = {}}

            assert.are_same(2, TrackerAchievements.GetAchievements({1})[1].Criteria[1].LinkedAchievementId)
        end)

        it("should not link criteria that only share the id of a quest", function()
            linkedQuestIds[2] = {}
            achievements[1] = {name = "Questing", description = "Quest.", criteria = {_Criteria("Darnassus", false, 0, 1, 2)}}

            assert.is_nil(TrackerAchievements.GetAchievements({1})[1].Criteria[1].LinkedAchievementId)
        end)

        it("should not link criteria whose text differs from the achievement name", function()
            achievements[1] = {name = "Champion", description = "Win.", criteria = {_Criteria("Something else", false, 0, 1, 2)}}
            achievements[2] = {name = "Darnassus", description = "Win in Darnassus.", criteria = {}}

            assert.is_nil(TrackerAchievements.GetAchievements({1})[1].Criteria[1].LinkedAchievementId)
        end)
    end)

    describe("achievements without criteria", function()
        it("should show the description without its trailing dot", function()
            achievements[1] = {name = "Level 10", description = "Reach level 10.", criteria = {}}

            local criteria = TrackerAchievements.GetAchievements({1})[1].Criteria

            assert.are_same({{Text = "Reach level 10", Completed = false, Collected = 0, Needed = 1, IsDescription = true}}, criteria)
        end)

        it("should show the description even when completed criteria are hidden", function()
            Questie.db.profile.hideCompletedAchieveObjectives = true
            achievements[1] = {name = "Level 10", description = "Reach level 10.", criteria = {}}

            assert.are_same(1, #TrackerAchievements.GetAchievements({1})[1].Criteria)
        end)
    end)
end)
