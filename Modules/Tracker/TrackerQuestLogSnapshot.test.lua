dofile("setupTests.lua")
local stub = require("luassert.stub")

describe("TrackerQuestLogSnapshot", function()
    local Snapshot, TrackerData, TrackerUtils, entries, cached, completion, completionText
    local titleMock, indexMock, countMock, itemCountMock, itemSpellMock, equippableMock, addonMock
    local instanceMock, specialItemMock, completionTextMock, colorizeMock, originalQuestLog

    before_each(function()
        Questie.db.profile = {trackerSortObjectives = "byZone", autoTrackQuests = true}
        Questie.db.char = {AutoUntrackedQuests = {}, TrackedQuests = {}, collapsedQuests = {}, collapsedZones = {}}
        entries = {
            {title = "Northshire Abbey", isHeader = true},
            {title = "Nibbled-On Book", id = 91741, level = 2},
        }
        cached = {[91741] = {objectives = {
            {text = "Wolves slain: 0/3", type = "monster", numFulfilled = 0, numRequired = 3, finished = false},
        }}}
        completion, completionText = 0, nil
        colorizeMock = stub(Questie, "Colorize", function(_, text) return text end)
        local compat = QuestieLoader:ImportModule("QuestieCompat")
        titleMock = stub(compat, "GetQuestLogTitle", function(index)
            local entry = entries[index]
            if entry then
                return entry.title, entry.level, nil, entry.isHeader, nil, entry.complete, nil, entry.id
            end
        end)
        indexMock = stub(compat, "GetQuestLogIndexByID", function(id)
            for index, entry in ipairs(entries) do
                if entry.id == id then return index end
            end
        end)
        countMock = stub(compat, "GetNumQuestLogEntries", function() return #entries, #entries - 1 end)
        itemCountMock = stub(compat, "GetItemCount", function() return 0 end)
        itemSpellMock = stub(compat, "GetItemSpell", function() return nil end)
        equippableMock = stub(compat, "IsEquippableItem", function() return false end)
        addonMock = stub(compat, "IsAddOnLoaded", function() return false end)
        instanceMock = stub(_G, "GetInstanceInfo", function() return "Outside", "none" end)
        specialItemMock = stub(_G, "GetQuestLogSpecialItemInfo", function() return nil end)
        completionTextMock = stub(_G, "GetQuestLogCompletionText", function() return completionText end)
        originalQuestLog = _G.C_QuestLog
        _G.C_QuestLog = {GetInfo = function() end}
        QuestieLoader:ImportModule("QuestLogCache").TryGetQuest = function(id) return cached[id] end
        QuestieLoader:ImportModule("QuestiePlayer").currentQuestlog = {}
        QuestieLoader:ImportModule("QuestieDB").IsComplete = function() return completion end
        local lib = QuestieLoader:ImportModule("QuestieLib")
        lib.PrintDifficultyColor = function(_, _, name) return name end
        lib.GetLevelString = function() return "[2] " end
        lib.GetQuestTypeSuffixPriority = function() return 1 end
        dofile("Localization/l10n.lua")
        dofile("Modules/Tracker/TrackerQuestieBehavior.lua")
        dofile("Modules/Tracker/TrackerData.lua")
        dofile("Modules/Tracker/TrackerUtils.lua")
        dofile("Modules/Tracker/TrackerQuestLogSnapshot.lua")
        TrackerData = QuestieLoader:ImportModule("TrackerData")
        TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        QuestieLoader:ImportModule("TrackerQuestTimers").GetRemainingTimeByQuestId = function() return nil end
        Snapshot = QuestieLoader:ImportModule("TrackerQuestLogSnapshot")
        TrackerData.Refresh()
    end)

    after_each(function()
        titleMock:revert()
        indexMock:revert()
        countMock:revert()
        itemCountMock:revert()
        itemSpellMock:revert()
        equippableMock:revert()
        addonMock:revert()
        instanceMock:revert()
        specialItemMock:revert()
        completionTextMock:revert()
        colorizeMock:revert()
        _G.C_QuestLog = originalQuestLog
    end)

    it("recognizes unchanged native quests without database enrichment", function()
        local rendered = Snapshot.Capture()
        TrackerData.Refresh()
        local current = Snapshot.Capture()

        assert.is_table(rendered)
        assert.are_not.equal(rendered, current)
        assert.is_true(Snapshot.IsUnchanged(current, rendered))
        assert.is_nil(TrackerData.GetQuest(91741).enrichment)
    end)

    it("retains rendered values when an incremental refresh mutates the same objective row", function()
        local rendered = Snapshot.Capture()
        local row = TrackerData.GetQuest(91741).Objectives[1]
        cached[91741].objectives[1].text = "Wolves slain: 1/3"
        cached[91741].objectives[1].numFulfilled = 1
        TrackerData.RefreshQuest(91741)
        TrackerData.Refresh()

        assert.are.equal(row, TrackerData.GetQuest(91741).Objectives[1])
        assert.are.equal("Wolves slain: 0/3", rendered.quests[91741].objectives[1].description)
        assert.is_false(Snapshot.IsUnchanged(Snapshot.Capture(), rendered))
    end)

    local metadataCases = {
        {name = "late title", field = "title", value = "The Book's True Name"},
        {name = "effective level", field = "level", value = 3},
    }
    for _, case in ipairs(metadataCases) do
        it("detects a changed " .. case.name .. " without objective changes", function()
            local rendered = Snapshot.Capture()
            entries[2][case.field] = case.value
            TrackerData.Refresh()

            assert.is_false(Snapshot.IsUnchanged(Snapshot.Capture(), rendered))
        end)
    end

    it("detects a late sorting tag even when titles hide quest levels", function()
        Questie.db.profile.trackerShowQuestLevel = false
        Questie.db.profile.trackerSortObjectives = "byLevel"
        entries[3] = {title = "A Second Book", id = 91742, level = 2}
        cached[91742] = cached[91741]
        TrackerData.Refresh()
        dofile("Modules/Tracker/Sorter/byLevel.lua")
        local rendered = Snapshot.Capture()
        local ids = TrackerUtils:GetSortedQuestIds()
        assert.are.same({91741, 91742}, ids)

        QuestieLoader:ImportModule("QuestieLib").GetQuestTypeSuffixPriority = function(id)
            return id == 91741 and 2 or 1 -- The first quest's elite tag finished loading.
        end
        local current = Snapshot.Capture()
        ids = TrackerUtils:GetSortedQuestIds()

        assert.are.same({91742, 91741}, ids)
        assert.are.equal(rendered.quests[91741].title, current.quests[91741].title)
        assert.is_false(Snapshot.IsUnchanged(current, rendered))
    end)

    it("detects a changed native header", function()
        local rendered = Snapshot.Capture()
        entries[1].title = "Elwynn Forest"
        TrackerData.Refresh()

        assert.is_false(Snapshot.IsUnchanged(Snapshot.Capture(), rendered))
    end)

    it("detects replaced membership even when the quest count stays the same", function()
        local rendered = Snapshot.Capture()
        entries[2].id = 91742
        cached[91742] = cached[91741]
        TrackerData.Refresh()

        assert.is_false(Snapshot.IsUnchanged(Snapshot.Capture(), rendered))
    end)

    it("detects removal of the last quest", function()
        local rendered = Snapshot.Capture()
        entries[2] = nil
        TrackerData.Refresh()
        local current = Snapshot.Capture()

        assert.are.same({}, current.quests)
        assert.is_false(Snapshot.IsUnchanged(current, rendered))
        assert.is_true(Snapshot.IsUnchanged(Snapshot.Capture(), current))
    end)

    it("detects objectives becoming available after a title-only layout", function()
        local loaded = cached[91741]
        cached[91741] = nil
        TrackerData.Refresh()
        local rendered = Snapshot.Capture()
        cached[91741] = loaded
        TrackerData.Refresh()

        assert.is_false(rendered.quests[91741].objectivesLoaded)
        assert.is_false(Snapshot.IsUnchanged(Snapshot.Capture(), rendered))
    end)

    it("detects completion without changed objective text", function()
        local rendered = Snapshot.Capture()
        completion = 1
        TrackerData.Refresh()

        assert.is_false(Snapshot.IsUnchanged(Snapshot.Capture(), rendered))
    end)

    it("detects completion instructions arriving separately", function()
        local rendered = Snapshot.Capture()
        completionText = "Return to the abbey."

        assert.is_false(Snapshot.IsUnchanged(Snapshot.Capture(), rendered))
    end)

    it("detects tracking and collapsed-zone changes", function()
        local rendered = Snapshot.Capture()
        Questie.db.char.AutoUntrackedQuests[91741] = true
        assert.is_false(Snapshot.IsUnchanged(Snapshot.Capture(), rendered))

        Questie.db.char.AutoUntrackedQuests[91741] = nil
        Questie.db.char.collapsedZones["Northshire Abbey"] = true
        assert.is_false(Snapshot.IsUnchanged(Snapshot.Capture(), rendered))
    end)

    it("keeps full rebuilds when a native quest-item button becomes available", function()
        local rendered = Snapshot.Capture()
        specialItemMock.returns("|Hitem:90001|h[Book]|h", nil, 1, false)
        itemCountMock.returns(1)

        assert.is_nil(Snapshot.Capture())
        assert.is_false(Snapshot.IsUnchanged(nil, rendered))
        assert.is_false(Snapshot.IsUnchanged(nil, nil))
    end)

    it("does not exclude ordinary non-usable item objectives", function()
        TrackerData.GetQuest(91741).ObjectiveData = {{Type = "item", Id = 123}}
        itemCountMock.returns(2)

        assert.is_table(Snapshot.Capture())
    end)

    it("keeps full rebuilds while a quest timer is active", function()
        QuestieLoader:ImportModule("TrackerQuestTimers").GetRemainingTimeByQuestId = function() return "5 Minutes", 300 end

        assert.is_nil(Snapshot.Capture())
    end)

    it("keeps full rebuilds for proximity sorting", function()
        Questie.db.profile.trackerSortObjectives = "byZonePlayerProximity"

        assert.is_nil(Snapshot.Capture())
    end)

    it("keeps full rebuilds for tracked achievements", function()
        Questie.db.char.trackedAchievementIds = {[123] = true}

        assert.is_nil(Snapshot.Capture())
    end)

    it("keeps full rebuilds for scenarios", function()
        instanceMock.returns("Scenario", "scenario")

        assert.is_nil(Snapshot.Capture())
    end)

    it("keeps full rebuilds for VoiceOver integration", function()
        TrackerUtils.IsVoiceOverLoaded = function() return true end

        assert.is_nil(Snapshot.Capture())
    end)
end)
