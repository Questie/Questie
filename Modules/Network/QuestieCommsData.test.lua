dofile("setupTests.lua")

describe("QuestieCommsData", function()
    ---@type QuestieComms
    local QuestieComms

    ---@type QuestieDB
    local QuestieDB

    local originalData
    local originalGetItem
    local originalGetNpc
    local originalGetObject
    local originalHaveQuestData
    local originalGetQuestObjectives
    local originalTrimObjectiveText
    local originalThread
    local originalTimer
    local originalItem
    local originalGetItemInfo
    local itemCallback
    local itemCancel
    local loadedItemName
    local ThreadLib
    local loadThread
    local apiObjectives

    local questId = 42
    local playerName = "OtherPlayer"

    -- Objectives arrive over comms with single character types, see QuestieComms:InsertQuestDataPacket
    local function objective(objectiveType, id)
        return {
            type = objectiveType,
            id = id,
            fulfilled = 0,
            required = 1,
        }
    end

    ---@param itemsById table<number, table> @Item DB entries by item id, any other item counts as missing
    local function mockItemDb(itemsById)
        QuestieDB.GetItem = function(_, itemId)
            return itemsById[itemId]
        end
    end

    local function givenUncachedItem()
        local pending = true
        itemCancel = spy.new(function()
            local wasPending = pending
            pending = false
            return wasPending
        end)
        _G.Item = {
            CreateFromItemID = function()
                return {
                    GetItemName = function() return loadedItemName end,
                    ContinueWithCancelOnItemLoad = function(_, callback)
                        itemCallback = function()
                            if pending then
                                pending = false
                                callback()
                            end
                        end
                        return itemCancel
                    end,
                }
            end,
        }
    end

    before_each(function()
        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")

        originalData = QuestieComms.data
        originalGetItem = QuestieDB.GetItem
        originalGetNpc = QuestieDB.GetNPC
        originalGetObject = QuestieDB.GetObject
        originalHaveQuestData = _G.HaveQuestData
        originalGetQuestObjectives = C_QuestLog.GetQuestObjectives
        originalTrimObjectiveText = Questie.db.profile.trimObjectiveText
        originalTimer = _G.C_Timer
        originalItem = _G.Item
        originalGetItemInfo = C_Item.GetItemInfo
        _G.C_Timer = {After = function() end}
        C_Item.GetItemInfo = function() return nil end
        itemCallback = nil
        itemCancel = nil
        loadedItemName = "Server item name"
        QuestieDB.GetNPC = function() return nil end
        QuestieDB.GetObject = function() return nil end
        ThreadLib = QuestieLoader:ImportModule("ThreadLib")
        originalThread = ThreadLib.Thread
        loadThread = nil
        ThreadLib.Thread = function(body)
            loadThread = coroutine.create(body)
            return {}, loadThread
        end
        apiObjectives = nil
        Questie.db.profile.trimObjectiveText = false
        _G.HaveQuestData = function() return true end
        C_QuestLog.GetQuestObjectives = spy.new(function() return apiObjectives end)
        -- Use the real fetcher/formatter; tests control when the loading coroutine resumes.
        dofile("Modules/Libs/QuestieLib.lua")

        QuestieComms.data = {}
        mockItemDb({})

        -- Loading the file gives it fresh lookup tables, so each test starts with empty tooltip data
        dofile("Modules/Network/QuestieCommsData.lua")
    end)

    after_each(function()
        QuestieComms.data = originalData
        QuestieDB.GetItem = originalGetItem
        QuestieDB.GetNPC = originalGetNpc
        QuestieDB.GetObject = originalGetObject
        _G.HaveQuestData = originalHaveQuestData
        C_QuestLog.GetQuestObjectives = originalGetQuestObjectives
        ThreadLib.Thread = originalThread
        _G.C_Timer = originalTimer
        C_Item.GetItemInfo = originalGetItemInfo
        _G.Item = originalItem
        Questie.db.profile.trimObjectiveText = originalTrimObjectiveText
    end)

    describe("GetTooltip", function()
        it("should use ready API wording and keep each remote player's progress", function()
            apiObjectives = {{text = "Fallen Sky Ridge Revitalized: 1/1", type = "monster", numFulfilled = 1, numRequired = 1}}
            QuestieDB.GetNPC = spy.new(function() return {name = "Goliathon"} end)
            QuestieComms.data:RegisterTooltip(questId, playerName, {objective("m", 19305)})
            QuestieComms.data:RegisterTooltip(questId, "AnotherPlayer", {
                {type = "m", id = 19305, fulfilled = 2, required = 3},
            })

            C_QuestLog.GetQuestObjectives = spy.new(function() return apiObjectives end)
            local result = QuestieComms.data:GetTooltip("m_19305")

            assert.same({text = "Fallen Sky Ridge Revitalized", fulfilled = 0, required = 1}, result[questId][playerName][1])
            assert.same({text = "Fallen Sky Ridge Revitalized", fulfilled = 2, required = 3}, result[questId].AnotherPlayer[1])
            assert.spy(QuestieDB.GetNPC).was.not_called()
        end)

        it("should use API text for object and item keys too", function()
            mockItemDb({[200] = {name = "Supplies"}})
            apiObjectives = {
                {text = "Activate the beacon: 0/1", type = "object"},
                {text = "Collect the supplies: 0/1", type = "item"},
            }
            QuestieComms.data:RegisterTooltip(questId, playerName, {objective("o", 100), objective("i", 200)})

            local objectResult = QuestieComms.data:GetTooltip("o_100")
            local itemResult = QuestieComms.data:GetTooltip("i_200")

            assert.equals("Activate the beacon", objectResult[questId][playerName][1].text)
            assert.equals("Collect the supplies", itemResult[questId][playerName][2].text)
        end)

        it("should fall back on an early hover and use API wording once data arrives", function()
            _G.HaveQuestData = function() return false end
            QuestieDB.GetNPC = function() return {name = "Goliathon"} end
            QuestieComms.data:RegisterTooltip(questId, playerName, {objective("m", 19305)})

            local firstResult = QuestieComms.data:GetTooltip("m_19305")

            assert.equals("Goliathon", firstResult[questId][playerName][1].text)

            _G.HaveQuestData = function() return true end
            apiObjectives = {{text = "Fallen Sky Ridge Revitalized: 1/1", type = "monster"}}
            local ok, err = coroutine.resume(loadThread)
            assert.is_true(ok, err)
            local loadedResult = QuestieComms.data:GetTooltip("m_19305")

            assert.equals("Fallen Sky Ridge Revitalized", loadedResult[questId][playerName][1].text)
            assert.same({text = "Fallen Sky Ridge Revitalized", fulfilled = 0, required = 1}, firstResult[questId][playerName][1])
        end)

        it("should safely fall back when both API wording and entity data are missing", function()
            apiObjectives = {{text = " : 0/1", type = "monster"}, {text = "Activate the beacon: 0/1"}}
            QuestieDB.GetNPC = function() return nil end
            QuestieDB.GetObject = function() return nil end
            QuestieComms.data:RegisterTooltip(questId, playerName, {objective("m", 100), objective("o", 200)})

            local monsterResult = QuestieComms.data:GetTooltip("m_100")
            local objectResult = QuestieComms.data:GetTooltip("o_200")

            assert.equals("", monsterResult[questId][playerName][1].text)
            assert.equals("", objectResult[questId][playerName][2].text)
        end)

        it("should cancel a pending item fallback when delayed API text replaces it", function()
            givenUncachedItem()
            QuestieComms.data:RegisterTooltip(questId, playerName, {objective("i", 200)})
            local result = QuestieComms.data:GetTooltip("i_200")
            assert.spy(itemCancel).was.not_called()

            apiObjectives = {{text = "Deliver the supplies: 1/1", type = "item"}}
            local ok, err = coroutine.resume(loadThread)
            assert.is_true(ok, err)

            assert.equals("Deliver the supplies", result[questId][playerName][1].text)
            assert.spy(itemCancel).was.called(1)
            itemCallback()
            assert.equals("Deliver the supplies", result[questId][playerName][1].text)
        end)

        it("should replace an item fallback that loaded before the quest text", function()
            givenUncachedItem()
            QuestieComms.data:RegisterTooltip(questId, playerName, {objective("i", 200)})
            local result = QuestieComms.data:GetTooltip("i_200")
            itemCallback()
            assert.equals("Server item name", result[questId][playerName][1].text)

            apiObjectives = {{text = "Deliver the supplies: 1/1", type = "item", numFulfilled = 1, numRequired = 1}}
            local ok, err = coroutine.resume(loadThread)
            assert.is_true(ok, err)

            assert.same({text = "Deliver the supplies", fulfilled = 0, required = 1}, result[questId][playerName][1])
        end)

        local formattingCases = {
            {name = "local trimming disabled", trim = false, text = "Wolf slain: 1/1", type = "monster", expected = "Wolf slain"},
            {name = "local trimming enabled", trim = true, text = "Wolf slain: 1/1", type = "monster", expected = "Wolf slain"},
            {name = "event counters", trim = true, text = "Ritual completed: 1/1", type = "event", expected = "Ritual completed"},
            {name = "Chinese counters", trim = true, text = "仪式完成：1/1", type = "event", expected = "仪式完成"},
            {name = "no progress counter", trim = false, text = "Speak to: Thrall", type = "event", expected = "Speak to: Thrall"},
        }
        for _, case in ipairs(formattingCases) do
            it("should preserve full wording in ready and delayed results with " .. case.name, function()
                Questie.db.profile.trimObjectiveText = case.trim
                apiObjectives = {{text = case.text, type = case.type}}
                QuestieComms.data:RegisterTooltip(questId, playerName, {objective("m", 100)})
                local readyResult = QuestieComms.data:GetTooltip("m_100")

                apiObjectives = nil
                local delayedResult = QuestieComms.data:GetTooltip("m_100")
                apiObjectives = {{text = case.text, type = case.type}}
                local ok, err = coroutine.resume(loadThread)
                assert.is_true(ok, err)

                assert.equals(case.expected, readyResult[questId][playerName][1].text)
                assert.same(readyResult, delayedResult)
            end)
        end

        it("should keep fallback text if the item callback has no name", function()
            givenUncachedItem()
            QuestieComms.data:RegisterTooltip(questId, playerName, {objective("i", 200)})
            local result = QuestieComms.data:GetTooltip("i_200")

            loadedItemName = nil
            itemCallback()

            assert.equals("Item missing from DB, fetching from server!", result[questId][playerName][1].text)
        end)

        it("should retain the item callback when the API has no replacement for this index", function()
            givenUncachedItem()
            apiObjectives = {}
            QuestieComms.data:RegisterTooltip(questId, playerName, {objective("i", 200)})

            local result = QuestieComms.data:GetTooltip("i_200")
            local ok, err = coroutine.resume(loadThread)
            assert.is_true(ok, err)

            assert.spy(itemCancel).was.not_called()
            itemCallback()
            assert.equals("Server item name", result[questId][playerName][1].text)
        end)
    end)

    describe("RegisterTooltip", function()
        it("should prime quest data once per registration before any hover", function()
            _G.HaveQuestData = function() return false end
            QuestieComms.data:RegisterTooltip(questId, playerName, {objective("m", 19305), objective("o", 100)})

            assert.is_true(QuestieComms.data:KeyExists("m_19305"))
            assert.is_true(QuestieComms.data:KeyExists("o_100"))
            assert.spy(C_QuestLog.GetQuestObjectives).was.called(1)
            assert.spy(C_QuestLog.GetQuestObjectives).was.called_with(questId)

            _G.HaveQuestData = function() return true end
            apiObjectives = {{text = "Fallen Sky Ridge Revitalized: 1/1", type = "monster"}}
            local result = QuestieComms.data:GetTooltip("m_19305")

            assert.equals("Fallen Sky Ridge Revitalized", result[questId][playerName][1].text)
        end)

        it("should register an item objective on the item and on everything that provides it", function()
            mockItemDb({
                [1003] = {
                    Sources = {
                        {Type = "monster", Id = 3003},
                        {Type = "object", Id = 4004},
                    },
                },
            })

            QuestieComms.data:RegisterTooltip(questId, playerName, {objective("i", 1003)})

            assert.is_true(QuestieComms.data:KeyExists("i_1003"))
            assert.is_true(QuestieComms.data:KeyExists("m_3003"))
            assert.is_true(QuestieComms.data:KeyExists("o_4004"))
        end)

        it("should register an item objective when the item has no sources", function()
            mockItemDb({
                [1004] = {},
            })

            QuestieComms.data:RegisterTooltip(questId, playerName, {objective("i", 1004)})

            assert.is_true(QuestieComms.data:KeyExists("i_1004"))
        end)

        -- The two skip path tests below each contain two unresolvable item objectives on purpose.
        -- Bailing out of the loop instead of skipping the objective always leaves one of them
        -- unregistered, no matter which order the objectives end up being listed in.
        it("should register the direct item key and later objectives when item data is missing", function()
            local objectives = {
                objective("i", 1001),
                objective("m", 2002),
                objective("i", 1005),
            }

            QuestieComms.data:RegisterTooltip(questId, playerName, objectives)

            assert.is_true(QuestieComms.data:KeyExists("i_1001"))
            assert.is_true(QuestieComms.data:KeyExists("m_2002"))
            assert.is_true(QuestieComms.data:KeyExists("i_1005"))
        end)

        it("should skip source expansion but keep later objectives when the item is hidden", function()
            mockItemDb({
                [1002] = {
                    Hidden = true,
                    Sources = {
                        {Type = "monster", Id = 9009},
                    },
                },
                [1006] = {
                    Hidden = true,
                    Sources = {
                        {Type = "monster", Id = 9010},
                    },
                },
            })

            local objectives = {
                objective("i", 1002),
                objective("m", 2003),
                objective("i", 1006),
            }

            QuestieComms.data:RegisterTooltip(questId, playerName, objectives)

            assert.is_true(QuestieComms.data:KeyExists("i_1002"))
            assert.is_true(QuestieComms.data:KeyExists("i_1006"))
            assert.is_false(QuestieComms.data:KeyExists("m_9009"))
            assert.is_false(QuestieComms.data:KeyExists("m_9010"))
            assert.is_true(QuestieComms.data:KeyExists("m_2003"))
        end)

        it("should skip objectives that are missing a type or an id", function()
            local objectives = {
                {type = "i"},
                {id = 5005},
                objective("m", 2002),
            }

            QuestieComms.data:RegisterTooltip(questId, playerName, objectives)

            assert.is_true(QuestieComms.data:KeyExists("m_2002"))
        end)
    end)
end)
