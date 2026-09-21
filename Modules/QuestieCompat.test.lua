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

    describe("quest greeting", function()
        local originals
        local originalResolveName, originalButtonLimit
        local globalNames = {
            "GetActiveQuestID", "GetAvailableQuestInfo", "GetActiveTitle", "GetAvailableTitle",
            "QuestFrameGreetingPanel", "QuestTitleButton1", "QuestTitleButton2",
            "QuestTitleButton1QuestIcon", "QuestTitleButton2QuestIcon",
        }
        local npcGuid = "Creature-0-0-0-0-123-0"

        before_each(function()
            originals = {}
            for _, name in ipairs(globalNames) do
                originals[name] = _G[name]
                _G[name] = nil
            end
            originalResolveName = QuestieDB.GetQuestIDFromName
            originalButtonLimit = QuestieCompat.MAX_NUM_QUESTS
            QuestieCompat.MAX_NUM_QUESTS = 2
            QuestieDB.GetQuestIDFromName = spy.new(function() return 456 end)
            _G.GetActiveTitle = spy.new(function() return "Accepted Quest" end)
            _G.GetAvailableTitle = spy.new(function() return "Offered Quest" end)
        end)

        after_each(function()
            for _, name in ipairs(globalNames) do
                _G[name] = originals[name]
            end
            QuestieDB.GetQuestIDFromName = originalResolveName
            QuestieCompat.MAX_NUM_QUESTS = originalButtonLimit
        end)

        it("uses native IDs without depending on quest names or rendered buttons", function()
            _G.GetActiveQuestID = spy.new(function() return 783 end)
            _G.GetAvailableQuestInfo = spy.new(function() return false, 0, false, false, 33 end)

            assert.are.equal(783, QuestieCompat.GetQuestGreetingQuestID(2, true, npcGuid))
            assert.are.equal(33, QuestieCompat.GetQuestGreetingQuestID(3, false, npcGuid))
            assert.spy(_G.GetActiveQuestID).was.called_with(2)
            assert.spy(_G.GetAvailableQuestInfo).was.called_with(3)
            assert.spy(GetActiveTitle).was.not_called()
            assert.spy(GetAvailableTitle).was.not_called()
            assert.spy(QuestieDB.GetQuestIDFromName).was.not_called()
        end)

        it("resolves Classic available titles when the native tuple has no quest ID", function()
            _G.GetAvailableQuestInfo = function() return false, false, false, false end

            assert.are.equal(456, QuestieCompat.GetQuestGreetingQuestID(3, false, npcGuid))
            assert.spy(GetAvailableTitle).was.called_with(3)
            assert.spy(QuestieDB.GetQuestIDFromName).was.called_with("Offered Quest", npcGuid, true)
        end)

        it("resolves Classic active titles in the finisher context", function()
            assert.are.equal(456, QuestieCompat.GetQuestGreetingQuestID(2, true, npcGuid))
            assert.spy(GetActiveTitle).was.called_with(2)
            assert.spy(QuestieDB.GetQuestIDFromName).was.called_with("Accepted Quest", npcGuid, false)
        end)

        it("returns zero when neither a native ID nor a resolvable title is available", function()
            _G.GetActiveQuestID = function() return 0 end
            QuestieDB.GetQuestIDFromName = function() return 0 end

            assert.are.equal(0, QuestieCompat.GetQuestGreetingQuestID(1, true, npcGuid))
        end)

        it("does not resolve missing or empty titles", function()
            _G.GetActiveTitle = function() return nil end
            _G.GetAvailableTitle = function() return "" end

            assert.are.equal(0, QuestieCompat.GetQuestGreetingQuestID(1, true, npcGuid))
            assert.are.equal(0, QuestieCompat.GetQuestGreetingQuestID(1, false, npcGuid))
            assert.spy(QuestieDB.GetQuestIDFromName).was.not_called()
        end)

        it("visits unnamed pooled buttons without acquiring frames or using legacy globals", function()
            local button = {Icon = {}, IsShown = function() return true end}
            local hiddenButton = {Icon = {}, IsShown = function() return false end}
            local buttons = {[button] = true, [hiddenButton] = true}
            _G.QuestFrameGreetingPanel = {titleButtonPool = {
                EnumerateActive = function() return next, buttons end,
                Acquire = spy.new(function() error("Must not acquire native buttons") end),
            }}
            _G.QuestTitleButton1 = {IsShown = function() error("Must prefer the pool") end}
            local visit = spy.new(function() end)

            QuestieCompat.ForEachQuestGreetingButton(visit)

            assert.spy(visit).was.called(1)
            assert.spy(visit).was.called_with(button, button.Icon)
            assert.spy(QuestFrameGreetingPanel.titleButtonPool.Acquire).was.not_called()
        end)

        it("visits only shown Classic buttons with their named icon textures", function()
            _G.QuestTitleButton1 = {IsShown = function() return true end}
            _G.QuestTitleButton2 = {IsShown = function() return false end}
            _G.QuestTitleButton1QuestIcon = {}
            _G.QuestTitleButton2QuestIcon = {}
            local visit = spy.new(function() end)

            QuestieCompat.ForEachQuestGreetingButton(visit)

            assert.spy(visit).was.called(1)
            assert.spy(visit).was.called_with(_G.QuestTitleButton1, _G.QuestTitleButton1QuestIcon)
        end)

        it("does nothing when the greeting layout is unavailable", function()
            local visit = spy.new(function() end)

            QuestieCompat.ForEachQuestGreetingButton(visit)

            assert.spy(visit).was.not_called()
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
    local originalGetCVarBool

    before_each(function()
        originalQuestLog = _G.C_QuestLog
        originalGetCVarBool = _G.GetCVarBool
        _G.GetCVarBool = spy.new(function() return false end)
        dofile("Modules/QuestieCompat.lua")
        QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        _G.C_QuestLog = {
            GetInfo = spy.new(function() return {questID = 783, title = "A Threat Within"} end),
            GetQuestTagInfo = spy.new(function() return {tagName = "Group"} end),
            IsComplete = spy.new(function() return false end),
            IsFailed = spy.new(function() return true end),
            SetSelectedQuest = spy.new(function() end),
            RemoveQuestWatch = spy.new(function() end),
            GetLogIndexForQuestID = function() return nil end,
            GetSelectedQuest = function() return 783 end,
        }
    end)

    after_each(function()
        _G.C_QuestLog = originalQuestLog
        _G.GetCVarBool = originalGetCVarBool
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

    it("keeps the quest ID display flag false without shifting the other return values", function()
        C_QuestLog.GetInfo = function()
            return {
                title = "A Threat Within", level = 1, isHeader = false, isCollapsed = false,
                frequency = 1, questID = 783, startEvent = false, isOnMap = true,
                hasLocalPOI = false, isTask = true, isBounty = false, isStory = true,
                isHidden = false, isScaling = true,
            }
        end

        local info = {QuestieCompat.GetQuestLogTitle(2)}

        assert.are.same({
            "A Threat Within", 1, "Group", false, false, -1, 1, 783,
            false, false, true, false, true, false, true, false, true,
        }, info)
        assert.spy(GetCVarBool).was.called_with("displayQuestID")
    end)

    it("sets the quest ID display flag when the setting is enabled", function()
        _G.GetCVarBool = spy.new(function() return true end)

        local info = {QuestieCompat.GetQuestLogTitle(2)}

        assert.are.equal(783, info[8])
        assert.is_true(info[10])
        assert.spy(GetCVarBool).was.called_with("displayQuestID")
    end)

    it("does not query quest-only fields, select a header or remove its watch", function()
        C_QuestLog.GetInfo = function() return {title = "Elwynn", isHeader = true, questID = 0} end
        local _, _, tag, _, _, complete = QuestieCompat.GetQuestLogTitle(1)
        assert.is_nil(tag)
        assert.is_nil(complete)
        QuestieCompat.SelectQuestLogEntry(1)
        QuestieCompat.RemoveQuestWatch(1)
        assert.spy(C_QuestLog.GetQuestTagInfo).was.not_called()
        assert.spy(C_QuestLog.IsFailed).was.not_called()
        assert.spy(C_QuestLog.SetSelectedQuest).was.not_called()
        assert.spy(C_QuestLog.RemoveQuestWatch).was.not_called()
    end)

    it("preserves zero for an absent log index and refuses invalid indices", function()
        assert.are.equal(0, QuestieCompat.GetQuestLogIndexByID(999))
        assert.are.equal(0, QuestieCompat.GetQuestLogSelection())
        assert.is_nil(QuestieCompat.GetQuestLogTitle(nil))
        QuestieCompat.SelectQuestLogEntry(0)
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

describe("QuestieCompat Classic paths", function()
    local QuestieCompat
    local originals
    local names = {
        "GetBuildInfo", "Questie", "QuestWatchFrame", "WatchFrame", "CreateFrame",
        "GetSpellInfo", "SetDesaturation", "IsQuestWatched", "MouseIsOver", "GetQuestTimers", "GetQuestGreenRange",
    }
    local watchFrame

    before_each(function()
        originals = {}
        for _, name in ipairs(names) do originals[name] = _G[name] end
        _G.GetBuildInfo = function() return "1.15.9", "0", "", 11509 end
        _G.Questie = {IsTitanReforged = false}
        watchFrame = {
            Hide = spy.new(function() end),
            Show = spy.new(function() end),
            SetAlpha = spy.new(function() end),
            GetPoint = function() return "TOP", "parent", "BOTTOM", 1, 2 end,
        }
        _G.QuestWatchFrame = watchFrame
        _G.CreateFrame = spy.new(function() error("Classic must not allocate the Forever visibility frame") end)
        _G.GetSpellInfo = nil
        _G.SetDesaturation = nil
        dofile("Modules/QuestieCompat.lua")
        QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
    end)

    after_each(function()
        for _, name in ipairs(names) do _G[name] = originals[name] end
    end)

    it("retains direct legacy tracker visibility and anchors without installing Forever bridges", function()
        QuestieCompat.HideWatchFrame()
        QuestieCompat.ShowWatchFrame()
        assert.spy(watchFrame.Hide).was.called(1)
        assert.spy(watchFrame.Show).was.called(1)
        assert.are.same({"TOP", "parent", "BOTTOM", 1, 2}, {QuestieCompat.GetWatchFramePoint()})
        assert.spy(CreateFrame).was.not_called()
        assert.is_nil(GetSpellInfo)
        assert.is_nil(SetDesaturation)
    end)

    it("preserves Titan's alpha-based visibility workaround", function()
        Questie.IsTitanReforged = true
        QuestieCompat.HideWatchFrame()
        QuestieCompat.ShowWatchFrame()
        assert.spy(watchFrame.SetAlpha).was.called_with(watchFrame, 0)
        assert.spy(watchFrame.SetAlpha).was.called_with(watchFrame, 1)
        assert.spy(watchFrame.Hide).was.not_called()
        assert.spy(watchFrame.Show).was.not_called()
    end)

    it("preserves Classic's legacy watch, mouse, timer and trivial-range calls", function()
        _G.IsQuestWatched = spy.new(function() return true end)
        _G.MouseIsOver = spy.new(function() return true end)
        _G.GetQuestTimers = spy.new(function() return 80, 120 end)
        _G.GetQuestGreenRange = spy.new(function() return 5 end)
        local frame = {}
        assert.is_true(QuestieCompat.IsQuestWatched(2))
        assert.is_true(QuestieCompat.MouseIsOver(frame, 1, 2, 3, 4))
        assert.are.same({80, 120}, {QuestieCompat.GetQuestTimers(783)})
        assert.are.equal(5, QuestieCompat.GetQuestGreenRange())
        assert.spy(IsQuestWatched).was.called_with(2)
        assert.spy(MouseIsOver).was.called_with(frame, 1, 2, 3, 4)
        assert.spy(GetQuestTimers).was.called_with(783)
        assert.spy(GetQuestGreenRange).was.called_with("player")
    end)

    it("does not treat Retail's interface version as Forever", function()
        _G.GetBuildInfo = function() return "12.0.0", "0", "", 120000 end
        dofile("Modules/QuestieCompat.lua")
        assert.spy(CreateFrame).was.not_called()
        assert.is_nil(GetSpellInfo)
        assert.is_nil(SetDesaturation)
    end)
end)

describe("QuestieCompat Forever paths", function()
    local QuestieCompat
    local aliases = {
        "GetQuestGreenRange", "GetQuestsCompleted", "GetQuestLogTitle", "GetNumQuestLogEntries",
        "GetQuestLogIndexByID", "GetQuestIDFromLogIndex", "SelectQuestLogEntry", "GetQuestLogSelection",
        "GetQuestIndexForWatch", "IsQuestWatched", "AddQuestWatch", "RemoveQuestWatch", "GetQuestTagInfo",
        "GetNumQuestWatches", "GetFactionInfo", "GetFactionInfoByID", "GetNumFactions", "ExpandFactionHeader",
        "GetSpellInfo", "GetAddOnMetadata", "SetDesaturation", "UnitAura", "MouseIsOver", "GetQuestTimers",
    }
    local dependencies = {
        "QuestieLoader", "QuestieCompat", "C_QuestLog", "C_Reputation", "C_Spell", "Enum", "CreateFrame",
        "ObjectiveTrackerFrame", "InCombatLockdown", "GetBuildInfo", "Questie", "C_UnitAuras", "AuraUtil",
        "UnitQuestTrivialLevelRange", "GetCVarBool",
    }
    local savedGlobals
    local questInfo
    local visibilityFrame
    local onRegen

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(aliases) do
            savedGlobals[name] = _G[name]
            _G[name] = nil
        end
        for _, name in ipairs(dependencies) do
            savedGlobals[name] = _G[name]
        end
        -- Compatibility must work at TOC load, before Questie and VersionCheck exist.
        _G.Questie = nil
        _G.GetBuildInfo = function() return "1.60.1", "69913", "", 16001 end
        _G.GetCVarBool = function() return false end
        dofile("Modules/Libs/QuestieLoader.lua")
        _G.C_Reputation = {}
        _G.C_Spell = {}
        _G.Enum = {QuestWatchType = {Manual = 1}}
        visibilityFrame = {
            RegisterEvent = spy.new(function() end),
            UnregisterEvent = spy.new(function() end),
            SetScript = function(_, _, callback) onRegen = callback end,
        }
        _G.CreateFrame = function() return visibilityFrame end
        _G.InCombatLockdown = function() return false end
        _G.ObjectiveTrackerFrame = {
            HookScript = function() end,
            Hide = spy.new(function() end),
            Update = spy.new(function() end),
        }
        questInfo = {title = "A Threat Within", level = 1, suggestedGroup = 0, questID = 783, isHeader = false}
        _G.C_QuestLog = {
            GetInfo = spy.new(function() return questInfo end),
            GetQuestTagInfo = function() return {tagName = "Group"} end,
            IsFailed = spy.new(function() return false end),
            IsComplete = spy.new(function() return false end),
            GetNumQuestWatches = function() return 1 end,
        }
        dofile("Modules/QuestieCompat.lua")
        QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
    end)

    after_each(function()
        for _, name in ipairs(aliases) do
            _G[name] = savedGlobals[name]
        end
        for _, name in ipairs(dependencies) do
            _G[name] = savedGlobals[name]
        end
    end)

    it("installs only the missing AceGUI bridges before Questie exists", function()
        assert.is_nil(_G.Questie)
        assert.is_nil(_G.QuestieCompat)
        C_Spell.GetSpellInfo = function() return {name = "Fireball", spellID = 133, iconID = 1, castTime = 1500} end
        local name, rank, icon, castTime, _, _, spellID = GetSpellInfo(133)
        assert.are.equal("Fireball", name)
        assert.is_nil(rank)
        assert.are.equal(1, icon)
        assert.are.equal(1500, castTime)
        assert.are.equal(133, spellID)
        local texture = {SetDesaturated = spy.new(function() end)}
        SetDesaturation(texture, true)
        assert.spy(texture.SetDesaturated).was.called_with(texture, true)

        local spellBridge, textureBridge = GetSpellInfo, SetDesaturation
        dofile("Modules/QuestieCompat.lua")
        assert.are.equal(spellBridge, GetSpellInfo)
        assert.are.equal(textureBridge, SetDesaturation)
    end)

    it("does not recurse through its spell bridge when the native API is unavailable", function()
        assert.is_nil(C_Spell.GetSpellInfo)
        assert.is_nil(GetSpellInfo(133))
    end)

    it("uses the unit-based trivial range rather than an existing legacy helper", function()
        _G.UnitQuestTrivialLevelRange = spy.new(function() return 5 end)
        _G.GetQuestGreenRange = function() error("legacy helper") end
        assert.are.equal(5, QuestieCompat.GetQuestGreenRange())
        assert.spy(UnitQuestTrivialLevelRange).was.called_with("player")
    end)

    it("keeps the full Forever aura tuple without calling an existing legacy global", function()
        local aura = {spellId = 1126}
        _G.C_UnitAuras = {GetAuraDataByIndex = spy.new(function() return aura end)}
        _G.AuraUtil = {UnpackAuraData = spy.new(function()
            return "Mark", 136078, 0, "Magic", 3600, 5000, "player", false, false, 1126, false, false, true, false, 1
        end)}
        _G.UnitAura = function() error("broken legacy aura") end
        assert.are.same({"Mark", 136078, 0, "Magic", 3600, 5000, "player", false, false, 1126, false, false, true, false, 1},
            {QuestieCompat.UnitAura("player", 1, "HELPFUL")})
        assert.spy(C_UnitAuras.GetAuraDataByIndex).was.called_with("player", 1, "HELPFUL")
        assert.spy(AuraUtil.UnpackAuraData).was.called_with(aura)
    end)

    it("preserves optional quest-tag fields after the ID and name", function()
        C_QuestLog.GetQuestTagInfo = function()
            return {tagID = 1, tagName = "Group", worldQuestType = 2, quality = 3, isElite = false,
                tradeskillLineID = 171, displayExpiration = true}
        end
        assert.are.same({1, "Group", 2, 3, false, 171, true}, {QuestieCompat.GetQuestTagInfo(783)})
    end)

    it("uses frame mouse-over even when the broken legacy global is present", function()
        _G.MouseIsOver = function() error("removed legacy dependency") end
        local frame = {IsMouseOver = spy.new(function() return true end)}
        assert.is_true(QuestieCompat.MouseIsOver(frame, 1, 2, 3, 4))
        assert.spy(frame.IsMouseOver).was.called_with(frame, 1, 2, 3, 4)
        assert.has_error(function() MouseIsOver(frame) end, "removed legacy dependency")
    end)

    it("leaves Blizzard quest and watch globals untouched", function()
        assert.is_nil(_G.GetQuestLogTitle)
        assert.is_nil(_G.GetQuestTimers)
        assert.is_nil(_G.AddQuestWatch)
        assert.is_nil(_G.GetNumQuestWatches)
        assert.are.equal(1, QuestieCompat.GetNumQuestWatches())
    end)

    it("does not take ownership of Blizzard visibility when the tracker was never hidden", function()
        QuestieCompat.ShowWatchFrame()

        assert.spy(visibilityFrame.RegisterEvent).was.not_called()
        assert.spy(ObjectiveTrackerFrame.Hide).was.not_called()
        assert.spy(ObjectiveTrackerFrame.Update).was.not_called()
    end)

    it("defers a combat-time release then returns visibility to Blizzard's own policy", function()
        QuestieCompat.HideWatchFrame()
        assert.spy(ObjectiveTrackerFrame.Hide).was.called(1)

        _G.InCombatLockdown = function() return true end
        QuestieCompat.ShowWatchFrame()
        assert.spy(visibilityFrame.RegisterEvent).was.called_with(visibilityFrame, "PLAYER_REGEN_ENABLED")
        assert.spy(ObjectiveTrackerFrame.Update).was.not_called()

        _G.InCombatLockdown = function() return false end
        onRegen()
        assert.spy(ObjectiveTrackerFrame.Update).was.called(1)
        assert.spy(visibilityFrame.UnregisterEvent).was.called_with(visibilityFrame, "PLAYER_REGEN_ENABLED")
    end)

    it("defers combat-time hiding and reuses one OnShow hook", function()
        local onShow
        ObjectiveTrackerFrame.HookScript = spy.new(function(_, _, callback) onShow = callback end)
        _G.InCombatLockdown = function() return true end
        QuestieCompat.HideWatchFrame()
        assert.spy(ObjectiveTrackerFrame.Hide).was.not_called()
        assert.spy(visibilityFrame.RegisterEvent).was.called_with(visibilityFrame, "PLAYER_REGEN_ENABLED")
        onRegen()
        assert.spy(ObjectiveTrackerFrame.Hide).was.not_called()

        _G.InCombatLockdown = function() return false end
        onRegen()
        assert.spy(ObjectiveTrackerFrame.Hide).was.called(1)
        QuestieCompat.HideWatchFrame()
        assert.spy(ObjectiveTrackerFrame.HookScript).was.called(1)
        onShow()
        assert.spy(ObjectiveTrackerFrame.Hide).was.called(3)
        QuestieCompat.ShowWatchFrame()
        onShow()
        assert.spy(ObjectiveTrackerFrame.Hide).was.called(3)
    end)

    it("keeps the legacy tuple positions and nil completion for an incomplete quest", function()
        local title, level, group, header, _, complete, _, questID = QuestieCompat.GetQuestLogTitle(2)

        assert.are.equal("A Threat Within", title)
        assert.are.equal(1, level)
        assert.are.equal("Group", group)
        assert.is_false(header)
        assert.is_nil(complete)
        assert.are.equal(783, questID)
        assert.spy(C_QuestLog.GetInfo).was.called_with(2)
        assert.spy(C_QuestLog.IsComplete).was.called_with(783)
        assert.spy(C_QuestLog.IsFailed).was.called_with(783)
    end)

    it("translates completed and failed states to the legacy numeric values", function()
        C_QuestLog.IsComplete = function() return true end
        assert.are.equal(1, select(6, QuestieCompat.GetQuestLogTitle(2)))

        C_QuestLog.IsFailed = function() return true end
        assert.are.equal(-1, select(6, QuestieCompat.GetQuestLogTitle(2)))
    end)

    it("does not query completion for headers or missing entries", function()
        questInfo = {title = "Elwynn Forest", isHeader = true, questID = 0}
        assert.is_nil(select(6, QuestieCompat.GetQuestLogTitle(1)))

        questInfo = nil
        assert.is_nil(QuestieCompat.GetQuestLogTitle(99))
        assert.spy(C_QuestLog.IsComplete).was.not_called()
        assert.spy(C_QuestLog.IsFailed).was.not_called()
    end)

    it("translates watch indices and log indices without confusing them with quest IDs", function()
        C_QuestLog.GetQuestIDForQuestWatchIndex = spy.new(function() return 783 end)
        C_QuestLog.GetLogIndexForQuestID = spy.new(function() return 2 end)
        C_QuestLog.GetQuestWatchType = spy.new(function() return 0 end)
        _G.IsQuestWatched = function() error("synthetic legacy watch state must not be queried") end
        C_QuestLog.RemoveQuestWatch = spy.new(function() return true end)

        assert.are.equal(2, QuestieCompat.GetQuestIndexForWatch(1))
        assert.is_true(QuestieCompat.IsQuestWatched(2))
        assert.is_true(QuestieCompat.RemoveQuestWatch(2))

        assert.spy(C_QuestLog.GetQuestIDForQuestWatchIndex).was.called_with(1)
        assert.spy(C_QuestLog.GetLogIndexForQuestID).was.called_with(783)
        assert.spy(C_QuestLog.GetQuestWatchType).was.called_with(783)
        assert.spy(C_QuestLog.RemoveQuestWatch).was.called_with(783)
    end)

    it("translates selection to quest IDs and absent log entries back to zero", function()
        C_QuestLog.SetSelectedQuest = spy.new(function() end)
        C_QuestLog.GetSelectedQuest = function() return 783 end
        C_QuestLog.GetLogIndexForQuestID = spy.new(function() return nil end)

        QuestieCompat.SelectQuestLogEntry(2)
        assert.spy(C_QuestLog.SetSelectedQuest).was.called_with(783)
        assert.are.equal(0, QuestieCompat.GetQuestLogSelection())
        assert.are.equal(0, QuestieCompat.GetQuestLogIndexByID(999))
        assert.spy(C_QuestLog.GetLogIndexForQuestID).was.called_with(783)
        assert.spy(C_QuestLog.GetLogIndexForQuestID).was.called_with(999)
    end)

    it("returns legacy timer varargs rather than modern timer records", function()
        C_QuestLog.GetQuestTimers = function()
            return {{questID = 33, questTimer = 81}, {questID = 783, questTimer = 120}}
        end
        assert.are.same({81, 120}, {QuestieCompat.GetQuestTimers()})

        C_QuestLog.GetQuestTimers = function() return {} end
        assert.is_nil(QuestieCompat.GetQuestTimers())
    end)

    it("converts completed IDs into a set and populates a caller-provided table", function()
        C_QuestLog.GetAllCompletedQuestIDs = function() return {783, 7} end
        local completed = {[42] = true}

        assert.are.same({[783] = true, [7] = true}, QuestieCompat.GetQuestsCompleted())
        assert.are.equal(completed, QuestieCompat.GetQuestsCompleted(completed))
        assert.are.same({[42] = true, [783] = true, [7] = true}, completed)
    end)

    it("preserves the faction tuple including header reputation and bonus flags", function()
        local faction = {
            name = "Alliance", description = "Alliance reputation", reaction = 5,
            currentReactionThreshold = 3000, nextReactionThreshold = 9000, currentStanding = 3300,
            atWarWith = false, canToggleAtWar = true, isHeader = true, isCollapsed = false,
            isHeaderWithRep = true, isWatched = false, isChild = false, factionID = 469,
            hasBonusRepGain = true, canSetInactive = false,
        }
        C_Reputation.GetFactionDataByIndex = spy.new(function() return faction end)
        C_Reputation.GetFactionDataByID = spy.new(function() return faction end)
        local expected = {
            "Alliance", "Alliance reputation", 5, 3000, 9000, 3300,
            false, true, true, false, true, false, false, 469, true, false,
        }

        assert.are.same(expected, {QuestieCompat.GetFactionInfo(1)})
        assert.are.same(expected, {QuestieCompat.GetFactionInfoByID(469)})
        assert.spy(C_Reputation.GetFactionDataByIndex).was.called_with(1)
        assert.spy(C_Reputation.GetFactionDataByID).was.called_with(469)
    end)
end)
