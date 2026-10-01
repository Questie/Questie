dofile("setupTests.lua")
local stub = require("luassert.stub")
local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

describe("QuestieLib", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type l10n
    local l10n
    ---@type QuestieLib
    local QuestieLib

    local QUEST_ID = 12345

    before_each(function()
        -- QuestieDB binds the provider schema and queries at file load.
        LoadQuestieDBMock()
        dofile("Database/QuestieDB.lua")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuestTagInfo = function() end
        dofile("Localization/l10n.lua")
        l10n = QuestieLoader:ImportModule("l10n")
        l10n.GetUILocale = function() return "enUS" end

        dofile("Modules/Libs/QuestieLib.lua")
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
    end)

    describe("addon version", function()
        local getMetadataMock

        before_each(function()
            getMetadataMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "GetAddOnMetadata",
                function() return "11.2.3" end)
            dofile("Modules/Libs/QuestieLib.lua")
        end)

        after_each(function()
            getMetadataMock:revert()
        end)

        it("shares cached metadata between the displayed version and numeric version", function()
            assert.are.equal("v11.2.3", QuestieLib:GetAddonVersionString())
            assert.are.same({11, 2, 3}, {QuestieLib:GetAddonVersionInfo()})
            assert.spy(getMetadataMock).was.called_with("Questie", "Version")
            assert.spy(getMetadataMock).was.called(1)
        end)
    end)

    describe("GetLevelString", function()
        it("should handle regular quests", function()
            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60] ", levelString)
        end)

        it("should handle Elite quests", function()
            QuestieDB.GetQuestTagInfo = function() return 1, "Elite" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60+] ", levelString)
        end)

        it("should handle Dungeon quests", function()
            QuestieDB.GetQuestTagInfo = function() return 81, "Dungeon" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60D] ", levelString)
        end)

        it("should handle Dungeon quests for zhCN", function()
            l10n.GetUILocale = function() return "zhCN" end
            QuestieDB.GetQuestTagInfo = function() return 81, "地下城" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60D] ", levelString)
        end)

        it("should handle Dungeon quests for zhTW", function()
            l10n.GetUILocale = function() return "zhTW" end
            QuestieDB.GetQuestTagInfo = function() return 81, "地城" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60D] ", levelString)
        end)

        it("should handle Dungeon quests for koKR", function()
            l10n.GetUILocale = function() return "koKR" end
            QuestieDB.GetQuestTagInfo = function() return 81, "던전" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60D] ", levelString)
        end)

        it("should handle Dungeon quests for ruRU", function()
            l10n.GetUILocale = function() return "ruRU" end
            QuestieDB.GetQuestTagInfo = function() return 81, "Подземелье" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60D] ", levelString)
        end)

        it("should handle Raid quests", function()
            QuestieDB.GetQuestTagInfo = function() return 62, "Raid" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60R] ", levelString)
        end)

        it("should handle Raid quests for zhCN", function()
            l10n.GetUILocale = function() return "zhCN" end
            QuestieDB.GetQuestTagInfo = function() return 62, "团队" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60R] ", levelString)
        end)

        it("should handle Raid quests for zhTW", function()
            l10n.GetUILocale = function() return "zhTW" end
            QuestieDB.GetQuestTagInfo = function() return 62, "團隊" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60R] ", levelString)
        end)

        it("should handle Raid quests for koKR", function()
            l10n.GetUILocale = function() return "koKR" end
            QuestieDB.GetQuestTagInfo = function() return 62, "레이드" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60R] ", levelString)
        end)

        it("should handle Raid quests for ruRU", function()
            l10n.GetUILocale = function() return "ruRU" end
            QuestieDB.GetQuestTagInfo = function() return 62, "Рейд" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60R] ", levelString)
        end)

        it("should handle PvP quests", function()
            QuestieDB.GetQuestTagInfo = function() return 41, "PvP" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60] ", levelString)
        end)

        it("should handle Legendary quests", function()
            QuestieDB.GetQuestTagInfo = function() return 83, "Legendary" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60++] ", levelString)
        end)

        it("should handle Scenario quests", function()
            QuestieDB.GetQuestTagInfo = function() return 98, "Scenario" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60S] ", levelString)
        end)

        it("should handle Scenario quests for zhCN", function()
            l10n.GetUILocale = function() return "zhCN" end
            QuestieDB.GetQuestTagInfo = function() return 98, "场景战役" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60S] ", levelString)
        end)

        it("should handle Scenario quests for zhTW", function()
            l10n.GetUILocale = function() return "zhTW" end
            QuestieDB.GetQuestTagInfo = function() return 98, "事件" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60S] ", levelString)
        end)

        it("should handle Scenario quests for koKR", function()
            l10n.GetUILocale = function() return "koKR" end
            QuestieDB.GetQuestTagInfo = function() return 98, "시나리오" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60S] ", levelString)
        end)

        it("should handle Scenario quests for ruRU", function()
            l10n.GetUILocale = function() return "ruRU" end
            QuestieDB.GetQuestTagInfo = function() return 98, "Сценарий" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60S] ", levelString)
        end)

        it("should handle Account quests", function()
            QuestieDB.GetQuestTagInfo = function() return 102, "Account" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60A] ", levelString)
        end)

        it("should handle Account quests for zhCN", function()
            l10n.GetUILocale = function() return "zhCN" end
            QuestieDB.GetQuestTagInfo = function() return 102, "账号" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60A] ", levelString)
        end)

        it("should handle Account quests for zhTW", function()
            l10n.GetUILocale = function() return "zhTW" end
            QuestieDB.GetQuestTagInfo = function() return 102, "帳號" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60A] ", levelString)
        end)

        it("should handle Account quests for koKR", function()
            l10n.GetUILocale = function() return "koKR" end
            QuestieDB.GetQuestTagInfo = function() return 102, "레이드" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60A] ", levelString)
        end)

        it("should handle Account quests for ruRU", function()
            l10n.GetUILocale = function() return "ruRU" end
            QuestieDB.GetQuestTagInfo = function() return 102, "Аккаунт" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60A] ", levelString)
        end)

        it("should handle Celestial quests", function()
            QuestieDB.GetQuestTagInfo = function() return 294, "Celestial" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60C] ", levelString)
        end)

        it("should handle Celestial quests for zhCN", function()
            l10n.GetUILocale = function() return "zhCN" end
            QuestieDB.GetQuestTagInfo = function() return 294, "天神" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60C] ", levelString)
        end)

        it("should handle Celestial quests for zhTW", function()
            l10n.GetUILocale = function() return "zhTW" end
            QuestieDB.GetQuestTagInfo = function() return 294, "天尊" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60C] ", levelString)
        end)

        it("should handle Celestial quests for koKR", function()
            l10n.GetUILocale = function() return "koKR" end
            QuestieDB.GetQuestTagInfo = function() return 294, "천신" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60C] ", levelString)
        end)

        it("should handle Celestial quests for ruRU", function()
            l10n.GetUILocale = function() return "ruRU" end
            QuestieDB.GetQuestTagInfo = function() return 294, "Небожители" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60C] ", levelString)
        end)

        it("should handle unknown quests", function()
            QuestieDB.GetQuestTagInfo = function() return 999, "Unknown" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60U] ", levelString)
        end)
    end)

    describe("IsObjectiveDataLoaded", function()
        local originalMonstersKilled

        before_each(function()
            originalMonstersKilled = _G.QUEST_MONSTERS_KILLED
            _G.QUEST_MONSTERS_KILLED = "%2$d/%3$d %1$s slain"
            dofile("Modules/Libs/QuestieLib.lua")
        end)

        after_each(function()
            _G.QUEST_MONSTERS_KILLED = originalMonstersKilled
        end)

        local cases = {
            {name = "missing text", type = "monster", loaded = false},
            {name = "missing type", text = "Read the book.", loaded = false},
            {name = "empty placeholder without a type", text = "", loaded = true},
            {name = "leading-space placeholder", text = " : 0/1", type = "item", loaded = false},
            {name = "trailing-space placeholder", text = "0/1  ", type = "item", loaded = false},
            {name = "empty parsed name without triple spaces", text = "0/6 \t slain", type = "monster", loaded = false},
            {name = "unknown English suffix", text = "0/6   destroyed", type = "monster", loaded = false},
            {name = "unknown UTF-8 suffix", text = "0/6   已摧毁", type = "monster", loaded = false},
            {name = "triple spaces without a counter", text = "Destroy   objects", type = "event", loaded = false},
            {name = "loaded English wording", text = "4/6 Roiling Winds destroyed", type = "monster", loaded = true},
            {name = "loaded UTF-8 wording", text = "4/6 烈风已摧毁", type = "monster", loaded = true},
            {name = "double interior spaces", text = "4/6 Roiling  Winds destroyed", type = "monster", loaded = true},
            {name = "unknown objective type", text = "Read the book.", type = "futureType", loaded = true},
        }
        for _, case in ipairs(cases) do
            it("validates " .. case.name .. " without modifying the row", function()
                local objective = {text = case.text, type = case.type}

                assert.are.equal(case.loaded, QuestieLib.IsObjectiveDataLoaded(objective))
                assert.are.same({text = case.text, type = case.type}, objective)
            end)
        end
    end)

    describe("GetLoadedQuestObjectives", function()
        local originalHaveQuestData
        local originalGetQuestObjectives
        local objectives

        before_each(function()
            originalHaveQuestData = _G.HaveQuestData
            originalGetQuestObjectives = C_QuestLog.GetQuestObjectives
            objectives = {{text = "Wolf slain: 0/1", type = "monster"}}
            _G.HaveQuestData = function() return true end
            C_QuestLog.GetQuestObjectives = spy.new(function() return objectives end)
        end)

        after_each(function()
            _G.HaveQuestData = originalHaveQuestData
            C_QuestLog.GetQuestObjectives = originalGetQuestObjectives
        end)

        it("should return loaded rows in a new table without modifying Blizzard's table", function()
            local result = QuestieLib.GetLoadedQuestObjectives(QUEST_ID)

            assert.are_not.equal(objectives, result)
            assert.equals(objectives[1], result[1])
            assert.same({{text = "Wolf slain: 0/1", type = "monster"}}, objectives)
            assert.spy(C_QuestLog.GetQuestObjectives).was.called_with(QUEST_ID)
        end)

        it("skips empty text regardless of type or counts and preserves the remaining indices", function()
            objectives = {
                {text = "", type = "event", numFulfilled = 0, numRequired = 0, finished = false},
                {text = "Wolf slain: 0/1", type = "monster"},
                {text = "", type = "item", numFulfilled = 3, numRequired = 5, finished = false},
                {text = "Follow the apparition.", type = "futureType"},
            }

            local result = QuestieLib.GetLoadedQuestObjectives(QUEST_ID)

            assert.same({
                [2] = {text = "Wolf slain: 0/1", type = "monster"},
                [4] = {text = "Follow the apparition.", type = "futureType"},
            }, result)
            assert.equals(objectives[2], result[2])
            assert.equals(objectives[4], result[4])
            assert.same({text = "", type = "event", numFulfilled = 0, numRequired = 0, finished = false}, objectives[1])
            assert.same({text = "", type = "item", numFulfilled = 3, numRequired = 5, finished = false}, objectives[3])
        end)

        it("returns a loaded empty result when every row has empty text, even without a type", function()
            objectives = {{text = "", type = "event", finished = false}, {text = ""}}

            assert.same({}, QuestieLib.GetLoadedQuestObjectives(QUEST_ID))
        end)

        it("should prime missing quest data and return nil", function()
            _G.HaveQuestData = function() return false end

            assert.is_nil(QuestieLib.GetLoadedQuestObjectives(QUEST_ID))
            assert.spy(C_QuestLog.GetQuestObjectives).was.called_with(QUEST_ID)
        end)

        it("should return nil when the objective array is unavailable", function()
            objectives = nil

            assert.is_nil(QuestieLib.GetLoadedQuestObjectives(QUEST_ID))
        end)

        it("should return nil rather than a partially loaded array", function()
            objectives[2] = {text = " : 0/1", type = "item"}

            assert.is_nil(QuestieLib.GetLoadedQuestObjectives(QUEST_ID))
        end)

        it("should reject a Forever objective with a missing name after the counter", function()
            objectives[2] = {text = "0/8  ", type = "item", objectiveType = 1}

            assert.is_nil(QuestieLib.GetLoadedQuestObjectives(QUEST_ID))
        end)

        local unknownSuffixes = {
            {name = "English", missing = "0/6   destroyed", loaded = "4/6 Roiling Winds destroyed"},
            {name = "UTF-8", missing = "0/6   已摧毁", loaded = "4/6 烈风已摧毁"},
        }
        for _, case in ipairs(unknownSuffixes) do
            it("rejects triple-space placeholders with an unknown " .. case.name .. " suffix until the name loads", function()
                objectives = {{text = case.missing, type = "monster"}}

                assert.is_nil(QuestieLib.GetLoadedQuestObjectives(QUEST_ID))
                assert.are.equal(case.missing, objectives[1].text)

                objectives[1].text = case.loaded
                local result = QuestieLib.GetLoadedQuestObjectives(QUEST_ID)

                assert.are.equal(objectives[1], result[1])
                assert.are.equal(case.loaded, result[1].text)
            end)
        end

        it("preserves single and double spaces in loaded text", function()
            objectives = {{text = "4/6 Roiling  Winds destroyed", type = "monster"}}

            local result = QuestieLib.GetLoadedQuestObjectives(QUEST_ID)

            assert.are.equal("4/6 Roiling  Winds destroyed", result[1].text)
        end)

        it("should preserve loaded Forever text and numeric objective types", function()
            objectives = {
                {text = "0/10 Kobold Vermin slain", type = "monster", objectiveType = 0},
                {text = "0/1 Garrick's Head", type = "item", objectiveType = 1},
                {text = "0/1 Shut off Main Control Valve", type = "object", objectiveType = 2},
                {text = "Scout through the Jasperlode Mine", type = "event", objectiveType = 10},
                {text = "Return the book to Brother Paxton.", type = "log"},
            }

            local result = QuestieLib.GetLoadedQuestObjectives(QUEST_ID)

            assert.are_not.equal(objectives, result)
            assert.same({
                {text = "0/10 Kobold Vermin slain", type = "monster", objectiveType = 0},
                {text = "0/1 Garrick's Head", type = "item", objectiveType = 1},
                {text = "0/1 Shut off Main Control Valve", type = "object", objectiveType = 2},
                {text = "Scout through the Jasperlode Mine", type = "event", objectiveType = 10},
                {text = "Return the book to Brother Paxton.", type = "log"},
            }, result)
        end)

        it("should accept a loaded quest with no objectives", function()
            objectives = {}

            assert.same({}, QuestieLib.GetLoadedQuestObjectives(QUEST_ID))
        end)
    end)

    describe("client objective wording", function()
        local originalHaveQuestData, originalGetQuestObjectives, originalItemsNeeded, originalMonstersKilled
        local objectives
        local cases = {
            {name = "Classic item", itemFormat = "%s: %d/%d", monsterFormat = "%s slain: %d/%d",
                type = "item", missing = " : 0/8", loaded = "item: 0/8", expected = "item"},
            {name = "Forever item", itemFormat = "%2$d/%3$d %1$s", monsterFormat = "%2$d/%3$d %1$s slain",
                type = "item", missing = "0/8  ", loaded = "0/8 item", expected = "item"},
            {name = "Forever monster", itemFormat = "%2$d/%3$d %1$s", monsterFormat = "%2$d/%3$d %1$s slain",
                type = "monster", missing = "0/8   slain", loaded = "0/8 Wolf slain", expected = "Wolf"},
        }

        before_each(function()
            originalHaveQuestData = _G.HaveQuestData
            originalGetQuestObjectives = C_QuestLog.GetQuestObjectives
            originalItemsNeeded, originalMonstersKilled = _G.QUEST_ITEMS_NEEDED, _G.QUEST_MONSTERS_KILLED
            _G.HaveQuestData = function() return true end
            C_QuestLog.GetQuestObjectives = function() return objectives end
        end)

        after_each(function()
            _G.HaveQuestData = originalHaveQuestData
            C_QuestLog.GetQuestObjectives = originalGetQuestObjectives
            _G.QUEST_ITEMS_NEEDED, _G.QUEST_MONSTERS_KILLED = originalItemsNeeded, originalMonstersKilled
        end)

        for _, case in ipairs(cases) do
            it("waits for the missing name in " .. case.name .. " wording and extracts it once loaded", function()
                _G.QUEST_ITEMS_NEEDED, _G.QUEST_MONSTERS_KILLED = case.itemFormat, case.monsterFormat
                dofile("Modules/Libs/QuestieLib.lua")
                -- These are literal client responses. Do not trim the placeholder whitespace in the fixture.
                objectives = {{text = case.missing, type = case.type, numFulfilled = 0, numRequired = 8, finished = false}}
                assert.are.equal("", QuestieLib.TrimObjectiveText(case.missing, case.type))
                assert.is_nil(QuestieLib.GetLoadedQuestObjectives(QUEST_ID))

                objectives[1].text = case.loaded
                assert.are.same(objectives, QuestieLib.GetLoadedQuestObjectives(QUEST_ID))
                assert.are.equal(case.expected, QuestieLib.TrimObjectiveText(case.loaded, case.type))
            end)
        end
    end)

    describe("ContinueOnQuestObjectivesLoad", function()
        local ThreadLib
        local originalThread
        local originalHaveQuestData
        local originalGetQuestObjectives
        local originalQuestMonstersKilled
        local thread
        local timer
        local callback
        local objectives

        local function Tick()
            local success, err = coroutine.resume(thread)
            assert.is_true(success, err)
        end

        before_each(function()
            ThreadLib = QuestieLoader:ImportModule("ThreadLib")
            originalThread = ThreadLib.Thread
            originalHaveQuestData = _G.HaveQuestData
            originalGetQuestObjectives = _G.C_QuestLog.GetQuestObjectives
            originalQuestMonstersKilled = _G.QUEST_MONSTERS_KILLED
            timer = {}
            ThreadLib.Thread = spy.new(function(body, delay)
                assert.are_same(0.2, delay)
                thread = coroutine.create(body)
                return timer, thread
            end)
            objectives = {{text = "Wolf slain: 0/1", type = "monster"}}
            _G.HaveQuestData = function() return true end
            _G.C_QuestLog.GetQuestObjectives = spy.new(function() return objectives end)
            callback = spy.new(function() end)
        end)

        after_each(function()
            ThreadLib.Thread = originalThread
            _G.HaveQuestData = originalHaveQuestData
            _G.C_QuestLog.GetQuestObjectives = originalGetQuestObjectives
            _G.QUEST_MONSTERS_KILLED = originalQuestMonstersKilled
        end)

        it("should deliver ready data on the first tick, not synchronously", function()
            local returnedTimer, returnedThread = QuestieLib.ContinueOnQuestObjectivesLoad(QUEST_ID, callback)

            assert.equals(timer, returnedTimer)
            assert.equals(thread, returnedThread)
            assert.spy(callback).was.not_called()
            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.not_called()

            Tick()

            assert.spy(callback).was.called(1)
            assert.spy(callback).was.called_with(objectives)
            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.called_with(QUEST_ID)
            assert.equals("dead", coroutine.status(thread))
        end)

        it("should return cancellation handles while loading and deliver the result once ready", function()
            objectives = nil
            local returnedTimer, returnedThread = QuestieLib.ContinueOnQuestObjectivesLoad(QUEST_ID, callback)

            assert.are.equal(timer, returnedTimer)
            assert.are.equal(thread, returnedThread)
            Tick()
            assert.spy(callback).was.not_called()

            objectives = {{text = "Wolf slain: 0/1", type = "monster"}}
            Tick()

            assert.spy(callback).was.called(1)
            assert.spy(callback).was.called_with(objectives)
            assert.are_same("dead", coroutine.status(thread))
        end)

        local incompleteObjectives = {
            {name = "missing text", objective = {type = "item"}},
            {name = "leading-space text", objective = {text = " : 0/1", type = "item"}},
            {name = "missing type", objective = {text = "Item: 0/1"}},
            {name = "triple-space text with an unknown suffix", objective = {text = "0/6   destroyed", type = "monster"}},
        }
        for _, case in ipairs(incompleteObjectives) do
            it("should refetch all objectives when a later objective has " .. case.name, function()
                objectives[2] = {text = "", type = "event", finished = false}
                objectives[3] = case.objective
                QuestieLib.ContinueOnQuestObjectivesLoad(QUEST_ID, callback)
                Tick()
                assert.spy(callback).was.not_called()

                objectives = {
                    {text = "Wolf slain: 1/1", type = "monster"},
                    {text = "Item: 0/1", type = "item"},
                }
                Tick()

                assert.spy(callback).was.called(1)
                assert.spy(callback).was.called_with(objectives)
                assert.spy(_G.C_QuestLog.GetQuestObjectives).was.called(2)
                assert.are_same("dead", coroutine.status(thread))
            end)
        end

        it("should wait for a Forever objective name before calling back", function()
            objectives = {{text = "0/1  ", type = "item", objectiveType = 1}}
            QuestieLib.ContinueOnQuestObjectivesLoad(QUEST_ID, callback)
            Tick()
            assert.spy(callback).was.not_called()

            objectives = {{text = "0/1 Garrick's Head", type = "item", objectiveType = 1}}
            Tick()

            assert.spy(callback).was.called(1)
            assert.spy(callback).was.called_with({{text = "0/1 Garrick's Head", type = "item", objectiveType = 1}})
            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.called(2)
            assert.are_same("dead", coroutine.status(thread))
        end)

        it("should wait for a Forever monster name even when the slain suffix is loaded", function()
            _G.QUEST_MONSTERS_KILLED = "%2$d/%3$d %1$s slain"
            dofile("Modules/Libs/QuestieLib.lua")
            objectives = {{text = "0/15   slain", type = "monster", objectiveType = 0}}
            QuestieLib.ContinueOnQuestObjectivesLoad(QUEST_ID, callback)
            Tick()
            assert.spy(callback).was.not_called()

            objectives = {{text = "0/15 Defias Trapper slain", type = "monster", objectiveType = 0}}
            Tick()

            assert.spy(callback).was.called(1)
            assert.spy(callback).was.called_with({{text = "0/15 Defias Trapper slain", type = "monster", objectiveType = 0}})
            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.called(2)
            assert.are_same("dead", coroutine.status(thread))
        end)

        it("succeeds on the first tick with empty rows filtered out and original indices intact", function()
            objectives = {
                {text = "", type = "event", numFulfilled = 0, numRequired = 0, finished = false},
                {text = "Wolf slain: 0/1", type = "monster"},
            }
            local onFailure = spy.new(function() end)
            QuestieLib.ContinueOnQuestObjectivesLoad(QUEST_ID, callback, onFailure)
            assert.spy(callback).was.not_called()

            Tick()

            assert.spy(callback).was.called(1)
            assert.spy(callback).was.called_with({[2] = {text = "Wolf slain: 0/1", type = "monster"}})
            assert.spy(onFailure).was.not_called()
            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.called(1)
            assert.equals("dead", coroutine.status(thread))
        end)

        it("calls onSuccess with an empty result rather than timing out on permanently empty rows", function()
            objectives = {{text = "", type = "event", numFulfilled = 0, numRequired = 0, finished = false}}
            local onFailure = spy.new(function() end)
            QuestieLib.ContinueOnQuestObjectivesLoad(QUEST_ID, callback, onFailure)

            Tick()

            assert.spy(callback).was.called_with({})
            assert.spy(onFailure).was.not_called()
            assert.equals("dead", coroutine.status(thread))
        end)

        it("should retry nil API results", function()
            objectives = nil
            QuestieLib.ContinueOnQuestObjectivesLoad(QUEST_ID, callback)
            Tick()
            assert.spy(callback).was.not_called()

            objectives = {{text = "Wolf slain: 0/1", type = "monster"}}
            Tick()
            assert.spy(callback).was.called_with(objectives)
        end)

        it("should prime objectives while quest data is missing and accept a loaded quest with no objectives", function()
            objectives = {}
            _G.HaveQuestData = function() return false end
            QuestieLib.ContinueOnQuestObjectivesLoad(QUEST_ID, callback)
            Tick()
            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.called_with(QUEST_ID)
            assert.spy(callback).was.not_called()

            _G.HaveQuestData = function() return true end
            Tick()
            assert.spy(callback).was.called_with({})
            assert.are_same("dead", coroutine.status(thread))
        end)

        it("should stop after 20 unsuccessful attempts without calling back", function()
            objectives = {{type = "event"}}
            QuestieLib.ContinueOnQuestObjectivesLoad(QUEST_ID, callback)
            for _ = 1, 20 do
                Tick()
            end

            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.called(20)
            assert.spy(callback).was.not_called()
            assert.are_same("dead", coroutine.status(thread))
        end)

        it("should call onFailure when a non-empty row stays unloaded even alongside ignored empty rows", function()
            objectives = {{text = "", type = "event"}, {type = "event"}}
            local onFailure = spy.new(function() end)
            QuestieLib.ContinueOnQuestObjectivesLoad(QUEST_ID, callback, onFailure)
            for _ = 1, 20 do
                Tick()
            end

            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.called(20)
            assert.spy(callback).was.not_called()
            assert.spy(onFailure).was.called(1)
            assert.are_same("dead", coroutine.status(thread))
        end)

        it("should still call back if objectives load on the twentieth attempt", function()
            objectives = nil
            QuestieLib.ContinueOnQuestObjectivesLoad(QUEST_ID, callback)
            for _ = 1, 19 do
                Tick()
            end
            assert.spy(callback).was.not_called()

            objectives = {{text = "Wolf slain: 0/1", type = "monster"}}
            Tick()

            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.called(20)
            assert.spy(callback).was.called_with(objectives)
            assert.are_same("dead", coroutine.status(thread))
        end)
    end)

    describe("RepairMissingItemNames", function()
        ---@type QuestieCorrections
        local QuestieCorrections
        local loadCallbacks
        -- Deferred publishes captured from C_Timer.After; the test decides when the frame ends.
        local scheduledPublishes
        -- Rows of each SetCorrection call, copied at call time: the module publishes one live
        -- table, so a reference would show the final content for every call.
        local publishedRows

        ---Runs and clears every captured deferred publish, as the next frame would.
        local function _NextFrame()
            local publishes = scheduledPublishes
            scheduledPublishes = {}
            for _, publish in ipairs(publishes) do
                publish()
            end
        end

        before_each(function()
            loadCallbacks = {}
            scheduledPublishes = {}
            publishedRows = {}
            _G.C_Timer = {
                After = function(_, callback)
                    table.insert(scheduledPublishes, callback)
                end,
            }
            QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
            QuestieCorrections.SetCorrection = spy.new(function(_, _, rows)
                local snapshot = {}
                for itemId, row in pairs(rows) do
                    snapshot[itemId] = {[1] = row[1]}
                end
                table.insert(publishedRows, snapshot)
            end)
            QuestieDB.itemKeys = {name = 1}
            QuestieDB.ItemPointers = {[5] = true}
            QuestieDB.GetQuest = function()
                return {
                    ObjectiveData = {
                        {Type = "item", Id = 5},
                        {Type = "item", Id = 999},
                        {Type = "monster", Id = 30},
                    },
                }
            end
            _G.Item = {
                CreateFromItemID = spy.new(function(_, itemId)
                    return {
                        ContinueOnItemLoad = function(_, callback)
                            loadCallbacks[itemId] = callback
                        end,
                        GetItemName = function()
                            return "Loaded " .. itemId
                        end,
                    }
                end),
            }
        end)

        after_each(function()
            _G.Item = nil
            _G.C_Timer = nil
        end)

        it("requests only the objective Items missing from the composed database", function()
            QuestieLib.RepairMissingItemNames(QUEST_ID)

            assert.spy(Item.CreateFromItemID).was.called(1)
            assert.spy(Item.CreateFromItemID).was.called_with(Item, 999)
            assert.spy(QuestieCorrections.SetCorrection).was.not_called()
        end)

        it("publishes the RuntimeItemRepair slot with a name-only row on the frame after the client load completes", function()
            QuestieLib.RepairMissingItemNames(QUEST_ID)

            loadCallbacks[999]()
            assert.spy(QuestieCorrections.SetCorrection).was.not_called()

            _NextFrame()

            assert.spy(QuestieCorrections.SetCorrection).was.called_with("Item", "RuntimeItemRepair", {[999] = {[1] = "Loaded 999"}})
        end)

        it("coalesces every Item loaded in one frame into a single publish of the whole slot", function()
            QuestieDB.GetQuest = function()
                return {
                    ObjectiveData = {
                        {Type = "item", Id = 999},
                        {Type = "item", Id = 1000},
                        {Type = "item", Id = 1001},
                    },
                }
            end

            QuestieLib.RepairMissingItemNames(QUEST_ID)
            loadCallbacks[999]()
            loadCallbacks[1000]()
            loadCallbacks[1001]()
            _NextFrame()

            assert.spy(QuestieCorrections.SetCorrection).was.called(1)
            assert.spy(QuestieCorrections.SetCorrection).was.called_with("Item", "RuntimeItemRepair",
                {[999] = {[1] = "Loaded 999"}, [1000] = {[1] = "Loaded 1000"}, [1001] = {[1] = "Loaded 1001"}})
        end)

        it("publishes again, with every repair so far, for an Item loaded after the frame ended", function()
            QuestieDB.GetQuest = function()
                return {
                    ObjectiveData = {
                        {Type = "item", Id = 999},
                        {Type = "item", Id = 1000},
                    },
                }
            end

            QuestieLib.RepairMissingItemNames(QUEST_ID)
            loadCallbacks[999]()
            _NextFrame()
            loadCallbacks[1000]()
            _NextFrame()

            assert.are_same({
                {[999] = {[1] = "Loaded 999"}},
                {[999] = {[1] = "Loaded 999"}, [1000] = {[1] = "Loaded 1000"}},
            }, publishedRows)
        end)

        it("treats a repeated client callback with an unchanged name as a no-op and schedules nothing", function()
            QuestieLib.RepairMissingItemNames(QUEST_ID)
            loadCallbacks[999]()
            _NextFrame()

            QuestieLib.RepairMissingItemNames(QUEST_ID)
            loadCallbacks[999]()

            assert.are_same(0, #scheduledPublishes)
            assert.spy(QuestieCorrections.SetCorrection).was.called(1)
        end)

        it("ignores a nil Item name from the client", function()
            _G.Item.CreateFromItemID = spy.new(function(_, itemId)
                return {
                    ContinueOnItemLoad = function(_, callback)
                        loadCallbacks[itemId] = callback
                    end,
                    GetItemName = function()
                        return nil
                    end,
                }
            end)

            QuestieLib.RepairMissingItemNames(QUEST_ID)
            loadCallbacks[999]()
            _NextFrame()

            assert.spy(QuestieCorrections.SetCorrection).was.not_called()
        end)

        it("does nothing for a quest without objective data", function()
            QuestieDB.GetQuest = function() return nil end

            QuestieLib.RepairMissingItemNames(QUEST_ID)

            assert.spy(Item.CreateFromItemID).was.not_called()
        end)
    end)

    describe("DidDailyResetHappenSinceLastLogin", function()
        it("should return true when last login is not set", function()
            _G.GetRealmName = function() return "Ook Ook" end
            Questie.db.global.lastKnownDailyReset = {}

            local result = QuestieLib.DidDailyResetHappenSinceLastLogin()

            assert.is_true(result)
        end)

        it("should return true when the server time exceeds the last know daily reset", function()
            _G.GetRealmName = function() return "Ook Ook" end
            Questie.db.global.lastKnownDailyReset = {["Ook Ook"] = 1765833265}

            _G.GetServerTime = function() return 2000000000 end

            local result = QuestieLib.DidDailyResetHappenSinceLastLogin()

            assert.is_true(result)
        end)

        it("should return false when the server time did not exceed the last know daily reset", function()
            _G.GetRealmName = function() return "Ook Ook" end
            Questie.db.global.lastKnownDailyReset = {["Ook Ook"] = 1765833265}

            _G.GetServerTime = function() return 1500000000 end

            local result = QuestieLib.DidDailyResetHappenSinceLastLogin()

            assert.is_false(result)
        end)
    end)

    describe("FormatDate", function()
        it("should format date for enUS", function()
            l10n.GetUILocale = function() return "enUS" end
            _G.CALENDAR_WEEKDAY_NAMES = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"January","February","March","April","May","June","July","August","September","October","November","December"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("Wednesday, February 18, 2026 at 19:35", formattedDate)
        end)

        it("should format date for deDE", function()
            l10n.GetUILocale = function() return "deDE" end
            _G.CALENDAR_WEEKDAY_NAMES = {"Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("Mittwoch, 18. Februar 2026 um 19:35", formattedDate)
        end)

        it("should format date for esES", function()
            l10n.GetUILocale = function() return "esES" end
            _G.CALENDAR_WEEKDAY_NAMES = {"Domingo","Lunes","Martes","Miércoles","Jueves","Viernes","Sábado"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("Miércoles, 18 de Febrero de 2026 a las 19:35", formattedDate)
        end)

        it("should format date for esMX", function()
            l10n.GetUILocale = function() return "esMX" end
            _G.CALENDAR_WEEKDAY_NAMES = {"Domingo","Lunes","Martes","Miércoles","Jueves","Viernes","Sábado"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("Miércoles, 18 de Febrero de 2026 a las 19:35", formattedDate)
        end)

        it("should format date for frFR", function()
            l10n.GetUILocale = function() return "frFR" end
            _G.CALENDAR_WEEKDAY_NAMES = {"Dimanche","Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("Mercredi 18 Février 2026 à 19:35", formattedDate)
        end)

        it("should format date for koKR", function()
            l10n.GetUILocale = function() return "koKR" end
            _G.CALENDAR_WEEKDAY_NAMES = {"일요일","월요일","화요일","수요일","목요일","금요일","토요일"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"1월","2월","3월","4월","5월","6월","7월","8월","9월","10월","11월","12월"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("2026년 2월 18일 수요일 19:35", formattedDate)
        end)

        it("should format date for ptBR", function()
            l10n.GetUILocale = function() return "ptBR" end
            _G.CALENDAR_WEEKDAY_NAMES = {"Domingo","Segunda-feira","Terça-feira","Quarta-feira","Quinta-feira","Sexta-feira","Sábado"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            -- Match the exact output produced by the current formatter (keeps same assert style as other locale tests)
            assert.are_same("Quarta-feira, 18 de Fevereiro de 2026 às 19:35", formattedDate)
        end)

        it("should format date for ruRU", function()
            l10n.GetUILocale = function() return "ruRU" end
            _G.CALENDAR_WEEKDAY_NAMES = {"Воскресенье","Понедельник","Вторник","Среда","Четверг","Пятница","Суббота"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"января","февраля","марта","апреля","мая","июня","июля","августа","сентября","октября","ноября","декабря"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("Среда, 18 февраля 2026, 19:35", formattedDate)
        end)

        it("should format date for zhCN", function()
            l10n.GetUILocale = function() return "zhCN" end
            _G.CALENDAR_WEEKDAY_NAMES = {"星期日","星期一","星期二","星期三","星期四","星期五","星期六"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("2026年2月18日 星期三 19:35", formattedDate)
        end)

        it("should format date for zhTW", function()
            l10n.GetUILocale = function() return "zhTW" end
            _G.CALENDAR_WEEKDAY_NAMES = {"星期日","星期一","星期二","星期三","星期四","星期五","星期六"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("2026年2月18日 星期三 19:35", formattedDate)
        end)
    end)

    describe("GetFullObjectiveText", function()
        local originalTrimObjectiveText

        before_each(function()
            originalTrimObjectiveText = Questie.db.profile.trimObjectiveText
        end)

        after_each(function()
            Questie.db.profile.trimObjectiveText = originalTrimObjectiveText
        end)

        it("should return the full objective description if trimObjectiveText is disabled", function()
            Questie.db.profile.trimObjectiveText = false
            local rawObjectiveText = "Defeat Hogger: 0/1"

            local result = QuestieLib.GetFullObjectiveText(rawObjectiveText)

            assert.are_same("Defeat Hogger", result)
        end)

        it("should return the full objective description for Chinese clients if trimObjectiveText is disabled", function()
            Questie.db.profile.trimObjectiveText = false
            local rawObjectiveText = "击败霍格：0/1"

            local result = QuestieLib.GetFullObjectiveText(rawObjectiveText)

            assert.are_same("击败霍格", result)
        end)

        it("should still return full wording when trimObjectiveText is enabled", function()
            Questie.db.profile.trimObjectiveText = true

            assert.equals("Wolf slain", QuestieLib.GetFullObjectiveText("Wolf slain: 0/1"))
        end)

        it("should retain the nil result for text without a trailing counter", function()
            assert.is_nil(QuestieLib.GetFullObjectiveText("Speak to: Thrall"))
        end)
    end)

    describe("GetClassString", function()
        local originalRaidClassColors

        local function stubColor(colorStr)
            return {colorStr = colorStr}
        end

        before_each(function()
            originalRaidClassColors = _G.RAID_CLASS_COLORS
            _G.RAID_CLASS_COLORS = {
                WARRIOR = stubColor("ffff7d0a"),
                PALADIN = stubColor("fff58cba"),
                HUNTER = stubColor("ffaad372"),
                ROGUE = stubColor("fffff468"),
                PRIEST = stubColor("ffffffff"),
                DEATHKNIGHT = stubColor("ffc41e3a"),
                SHAMAN = stubColor("ff0070dd"),
                MAGE = stubColor("ff3fc7eb"),
                WARLOCK = stubColor("ff8788ee"),
                MONK = stubColor("ff00ff98"),
                DRUID = stubColor("ffff7c0a"),
            }
        end)

        after_each(function()
            _G.RAID_CLASS_COLORS = originalRaidClassColors
        end)

        it("should return an empty string for a nil classMask", function()
            assert.are_same("", QuestieLib:GetClassString(nil))
        end)

        it("should return an empty string for classKeys.NONE", function()
            assert.are_same("", QuestieLib:GetClassString(QuestieDB.classKeys.NONE))
        end)

        it("should return an empty string for classKeys.ALL_CLASSES", function()
            assert.are_same("", QuestieLib:GetClassString(QuestieDB.classKeys.ALL_CLASSES))
        end)

        it("should return a colored string for Death Knight", function()
            local result = QuestieLib:GetClassString(QuestieDB.classKeys.DEATH_KNIGHT)

            assert.are_same("|cffc41e3aDeath Knight|r", result)
        end)

        it("should return a colored string for Monk", function()
            local result = QuestieLib:GetClassString(QuestieDB.classKeys.MONK)

            assert.are_same("|cff00ff98Monk|r", result)
        end)

        it("should combine multiple classes including Death Knight and Monk", function()
            local classMask = QuestieDB.classKeys.WARRIOR + QuestieDB.classKeys.DEATH_KNIGHT + QuestieDB.classKeys.MONK

            local result = QuestieLib:GetClassString(classMask)

            assert.are_same("|cffff7d0aWarrior|r, |cffc41e3aDeath Knight|r, |cff00ff98Monk|r", result)
        end)

        -- WoW Forever's RAID_CLASS_COLORS is missing DEATHKNIGHT and MONK entries.
        -- These document the fallback GetClassString should have instead of erroring.
        it("should return an empty string for Death Knight when RAID_CLASS_COLORS has no DEATHKNIGHT entry", function()
            _G.RAID_CLASS_COLORS.DEATHKNIGHT = nil

            local result = QuestieLib:GetClassString(QuestieDB.classKeys.DEATH_KNIGHT)

            assert.are_same("", result)
        end)

        it("should return an empty string for Monk when RAID_CLASS_COLORS has no MONK entry", function()
            _G.RAID_CLASS_COLORS.MONK = nil

            local result = QuestieLib:GetClassString(QuestieDB.classKeys.MONK)

            assert.are_same("", result)
        end)
    end)

    describe("GetFullObjectiveTextConditional", function()
        local originalTrimObjectiveText

        before_each(function()
            originalTrimObjectiveText = Questie.db.profile.trimObjectiveText
        end)

        after_each(function()
            Questie.db.profile.trimObjectiveText = originalTrimObjectiveText
        end)

        it("should return full wording when trimObjectiveText is disabled", function()
            Questie.db.profile.trimObjectiveText = false

            assert.equals("Wolf slain", QuestieLib.GetFullObjectiveTextConditional("Wolf slain: 0/1"))
        end)

        it("should return nil when trimObjectiveText is enabled", function()
            Questie.db.profile.trimObjectiveText = true

            assert.is_nil(QuestieLib.GetFullObjectiveTextConditional("Wolf slain: 0/1"))
        end)
    end)
end)
