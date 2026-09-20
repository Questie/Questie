dofile("setupTests.lua")

describe("QuestieCompat", function()
    ---@type QuestieDB
    local QuestieDB

    ---@type QuestieCompat
    local QuestieCompat

    before_each(function()
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")

        _G.C_GossipInfo = nil
        _G.GetGossipAvailableQuests = nil
        _G.GetGossipActiveQuests = nil

        dofile("Modules/QuestieCompat.lua")
        QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
    end)

    describe("GetAvailableQuests", function()
        it("should error when no function is available", function()
            _G.C_GossipInfo = nil
            _G.GetGossipAvailableQuests = nil

            assert.has_error(function()
                QuestieCompat.GetAvailableQuests()
            end)
        end)

        it("should return an empty table when C_GossipInfo.GetAvailableQuests returns an empty table", function()
            _G.C_GossipInfo = {
                GetAvailableQuests = spy.new(function() return {} end)
            }

            local availableQuests = QuestieCompat.GetAvailableQuests()

            assert.are_same({}, availableQuests)
        end)

        it("should return values from C_GossipInfo.GetAvailableQuests", function()
            local expected = {
                {
                    title = "Test Quest",
                    questLevel = 1,
                    questID = 0,
                    isTrivial = false,
                    frequency = 1,
                    repeatable = false,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                },
                {
                    title = "Test Quest 2",
                    questLevel = 2,
                    questID = 0,
                    isTrivial = true,
                    frequency = 1,
                    repeatable = true,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                },
            }
            _G.C_GossipInfo = {
                GetAvailableQuests = spy.new(function() return expected end)
            }

            local availableQuests = QuestieCompat.GetAvailableQuests()

            assert.are_same(expected, availableQuests)
        end)

        it("should return an empty table when GetGossipAvailableQuests returns nil", function()
            _G.GetGossipAvailableQuests = spy.new(function() return nil end)

            local availableQuests = QuestieCompat.GetAvailableQuests()

            assert.are_same({}, availableQuests)
        end)

        it("should map return values from GetGossipAvailableQuests", function()
            _G.GetGossipAvailableQuests = spy.new(function() return
                "Test Quest", 1, false, 1, false, false, false, "Test Quest 2", 2, true, 1, true, false, false
            end)

            local availableQuests = QuestieCompat.GetAvailableQuests()

            assert.are_same({
                {
                    title = "Test Quest",
                    questLevel = 1,
                    questID = 0,
                    isTrivial = false,
                    frequency = 1,
                    repeatable = false,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                },
                {
                    title = "Test Quest 2",
                    questLevel = 2,
                    questID = 0,
                    isTrivial = true,
                    frequency = 1,
                    repeatable = true,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                },
            }, availableQuests)
        end)
    end)

    describe("GetActiveQuests", function()
        it("should error when no function is available", function()
            _G.C_GossipInfo = nil
            _G.GetGossipActiveQuests = nil

            assert.has_error(function()
                QuestieCompat.GetActiveQuests()
            end)
        end)

        it("should return an empty table when C_GossipInfo.GetActiveQuests returns an empty table", function()
            _G.C_GossipInfo = {
                GetActiveQuests = spy.new(function() return {} end)
            }

            local activeQuests = QuestieCompat.GetActiveQuests()

            assert.are_same({}, activeQuests)
        end)

        it("should return values from C_GossipInfo.GetActiveQuests", function()
            QuestieDB.IsComplete = spy.new(function() return 0 end)
            local expected = {
                {
                    title = "Test Quest",
                    questLevel = 1,
                    isTrivial = true,
                    frequency = 1,
                    repeatable = false,
                    isComplete = false,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                    questID = 123,
                },
                {
                    title = "Test Quest",
                    questLevel = 1,
                    isTrivial = false,
                    frequency = 1,
                    repeatable = true,
                    isComplete = true,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                    questID = 456,
                },
            }
            _G.C_GossipInfo = {
                GetActiveQuests = spy.new(function() return expected end)
            }

            local activeQuests = QuestieCompat.GetActiveQuests()

            assert.are_same(expected, activeQuests)
            assert.spy(QuestieDB.IsComplete).was.called_with(123)
            assert.spy(QuestieDB.IsComplete).was.not_called_with(456)
        end)

        it("should override isComplete with QuestieDB.IsComplete for C_GossipInfo.GetActiveQuests", function()
            QuestieDB.IsComplete = spy.new(function() return 1 end)
            local expected = {
                {
                    title = "Test Quest",
                    questLevel = 1,
                    isTrivial = false,
                    frequency = 1,
                    repeatable = false,
                    isComplete = false,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                    questID = 123,
                },
            }
            _G.C_GossipInfo = {
                GetActiveQuests = spy.new(function() return expected end)
            }

            local activeQuests = QuestieCompat.GetActiveQuests()

            assert.is_true(activeQuests[1].isComplete)
            assert.spy(QuestieDB.IsComplete).was.called_with(123)
        end)

        it("should map return values from GetGossipActiveQuests", function()
            _G.GetGossipActiveQuests = spy.new(function()
                return "Test Quest 1", 1, false, false, false, true, "Test Quest 2", 2, true, false, false, false
            end)

            local activeQuests = QuestieCompat.GetActiveQuests()

            assert.are_same({
                {
                    title = "Test Quest 1",
                    questLevel = 1,
                    isTrivial = false,
                    frequency = nil,
                    repeatable = false,
                    isComplete = false,
                    isLegendary = false,
                    isIgnored = true,
                    isImportant = false,
                    isMeta = false,
                    questID = 0,
                },
                {
                    title = "Test Quest 2",
                    questLevel = 2,
                    isTrivial = true,
                    frequency = nil,
                    repeatable = false,
                    isComplete = false,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                    questID = 0,
                },
            }, activeQuests)
        end)
    end)

    describe("GetCurrentCalendarTime", function()
        it("should error when no known function is available", function()
            _G.C_DateAndTime = {}

            assert.has_error(function()
                QuestieCompat.GetCurrentCalendarTime()
            end)
        end)

        it("should return values from C_DateAndTime.GetCurrentCalendarTime", function()
            local expected = {
                monthDay = 2,
                month = 12,
                year = 2025,
                weekday = 3,
                hour = 8,
                minute = 47,
            }
            _G.C_DateAndTime = {
                GetCurrentCalendarTime = function() return expected end
            }

            local currentTime = QuestieCompat.GetCurrentCalendarTime()

            assert.are_same(expected, currentTime)
        end)

        it("should map values from C_DateAndTime.GetTodaysDate", function()
            _G.C_DateAndTime = {
                GetTodaysDate = function()
                    return {
                        weekDay = 3,
                        day = 2,
                        month = 12,
                        year = 2025,
                    }
                end
            }

            local currentTime = QuestieCompat.GetCurrentCalendarTime()

            assert.are_same({
                monthDay = 2,
                month = 12,
                year = 2025,
                weekday = 3,
                hour = 0,
                minute = 0,
            }, currentTime)
        end)
    end)
end)

describe("QuestieCompat modern quest log boundary", function()
    local QuestieCompat
    local originalQuestLog

    before_each(function()
        originalQuestLog = _G.C_QuestLog
        dofile("Modules/QuestieCompat.lua")
        QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        _G.C_QuestLog = {
            GetInfo = spy.new(function() return {questID = 783, title = "A Threat Within"} end),
            GetQuestTagInfo = spy.new(function() return {tagName = "Group"} end),
            IsComplete = spy.new(function() return false end),
            IsFailed = spy.new(function() return true end),
            SetSelectedQuest = spy.new(function() end),
            AddQuestWatch = spy.new(function() end),
            RemoveQuestWatch = spy.new(function() end),
            GetLogIndexForQuestID = function() return nil end,
            GetSelectedQuest = function() return 783 end,
        }
    end)

    after_each(function()
        _G.C_QuestLog = originalQuestLog
    end)

    it("registers through the loader without publishing a global", function()
        assert.is_nil(_G.QuestieCompat)
        assert.are.equal(QuestieLoader:ImportModule("QuestieCompat"), QuestieCompat)
    end)

    it("keeps the quest tag and failed status in the legacy tuple", function()
        local _, _, tag, _, _, complete, _, questID = QuestieCompat.GetQuestLogTitle(2)
        assert.are.equal("Group", tag)
        assert.are.equal(-1, complete)
        assert.are.equal(783, questID)
        assert.spy(C_QuestLog.IsComplete).was.not_called()
    end)

    it("does not query quest-only fields or select and watch a header", function()
        C_QuestLog.GetInfo = function() return {title = "Elwynn", isHeader = true, questID = 0} end
        local _, _, tag, _, _, complete = QuestieCompat.GetQuestLogTitle(1)
        assert.is_nil(tag)
        assert.is_nil(complete)
        QuestieCompat.SelectQuestLogEntry(1)
        QuestieCompat.AddQuestWatch(1)
        QuestieCompat.RemoveQuestWatch(1)
        assert.spy(C_QuestLog.GetQuestTagInfo).was.not_called()
        assert.spy(C_QuestLog.IsFailed).was.not_called()
        assert.spy(C_QuestLog.SetSelectedQuest).was.not_called()
        assert.spy(C_QuestLog.AddQuestWatch).was.not_called()
        assert.spy(C_QuestLog.RemoveQuestWatch).was.not_called()
    end)

    it("preserves zero for an absent log index and refuses invalid indices", function()
        assert.are.equal(0, QuestieCompat.GetQuestLogIndexByID(999))
        assert.are.equal(0, QuestieCompat.GetQuestLogSelection())
        assert.is_nil(QuestieCompat.GetQuestLogTitle(nil))
        QuestieCompat.SelectQuestLogEntry(0)
        QuestieCompat.AddQuestWatch(nil)
        QuestieCompat.RemoveQuestWatch(0)
        assert.spy(C_QuestLog.GetInfo).was.not_called()
    end)
end)

describe("QuestieCompat legacy return shapes", function()
    local QuestieCompat
    local originals

    before_each(function()
        originals = {
            C_QuestLog = _G.C_QuestLog,
            C_StableInfo = _G.C_StableInfo,
            C_Item = _G.C_Item,
            GetAbandonQuestItems = _G.GetAbandonQuestItems,
            GetStablePetFoodTypes = _G.GetStablePetFoodTypes,
        }
        _G.GetAbandonQuestItems = nil
        _G.GetStablePetFoodTypes = nil
        _G.C_QuestLog = {GetAbandonQuestItems = function() return {} end}
        _G.C_StableInfo = {GetStablePetFoodTypes = function() return {} end}
        _G.C_Item = {GetItemInfo = function(id) return ({[10] = "Letter", [20] = "Key"})[id] end}
        dofile("Modules/QuestieCompat.lua")
        QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
    end)

    after_each(function()
        _G.C_QuestLog = originals.C_QuestLog
        _G.C_StableInfo = originals.C_StableInfo
        _G.C_Item = originals.C_Item
        _G.GetAbandonQuestItems = originals.GetAbandonQuestItems
        _G.GetStablePetFoodTypes = originals.GetStablePetFoodTypes
    end)

    it("returns nil for no abandonment items so the ordinary popup is selected", function()
        assert.is_nil(QuestieCompat.GetAbandonQuestItems())
    end)

    it("formats modern item IDs as names for the destruction warning", function()
        C_QuestLog.GetAbandonQuestItems = function() return {10, 20} end
        assert.are.equal("Letter, Key", QuestieCompat.GetAbandonQuestItems())
    end)

    it("omits uncached item names as Blizzard's abandonment dialog does", function()
        C_QuestLog.GetAbandonQuestItems = function() return {10, 99, 20} end
        assert.are.equal("Letter, Key", QuestieCompat.GetAbandonQuestItems())
    end)

    it("retains the legacy abandonment string unchanged", function()
        _G.GetAbandonQuestItems = function() return "Legacy letter" end
        assert.are.equal("Legacy letter", QuestieCompat.GetAbandonQuestItems())
    end)

    it("returns food types as varargs for the townsfolk menu", function()
        C_StableInfo.GetStablePetFoodTypes = spy.new(function() return {"Meat", "Fish"} end)
        assert.are.same({"Meat", "Fish"}, {QuestieCompat.GetStablePetFoodTypes(2)})
        assert.spy(C_StableInfo.GetStablePetFoodTypes).was.called_with(2)
    end)

    it("returns no food types for an empty modern array", function()
        assert.are.equal(0, select("#", QuestieCompat.GetStablePetFoodTypes(2)))
    end)
end)
