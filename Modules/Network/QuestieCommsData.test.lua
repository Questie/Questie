dofile("setupTests.lua")

describe("QuestieCommsData", function()
    ---@type QuestieComms
    local QuestieComms

    ---@type QuestieDB
    local QuestieDB

    ---@type QuestieLib
    local QuestieLib

    local originalData
    local originalGetItem
    local originalGetNpc
    local originalGetObject
    local originalGetQuestObjectives
    local originalHaveQuestData
    local originalTrimObjectiveText

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

    before_each(function()
        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")

        originalData = QuestieComms.data
        originalGetItem = QuestieDB.GetItem
        originalGetNpc = QuestieDB.GetNPC
        originalGetObject = QuestieDB.GetObject
        originalGetQuestObjectives = C_QuestLog.GetQuestObjectives
        originalHaveQuestData = HaveQuestData
        originalTrimObjectiveText = QuestieLib.TrimObjectiveText

        QuestieComms.data = {}
        mockItemDb({})
        _G.HaveQuestData = function() return true end
        C_QuestLog.GetQuestObjectives = function() return nil end
        QuestieLib.TrimObjectiveText = function(text)
            return text:match("^(.*):%s*%d+/%d+$") or text
        end

        -- Loading the file gives it fresh lookup tables, so each test starts with empty tooltip data
        dofile("Modules/Network/QuestieCommsData.lua")
    end)

    after_each(function()
        QuestieComms.data = originalData
        QuestieDB.GetItem = originalGetItem
        QuestieDB.GetNPC = originalGetNpc
        QuestieDB.GetObject = originalGetObject
        C_QuestLog.GetQuestObjectives = originalGetQuestObjectives
        _G.HaveQuestData = originalHaveQuestData
        QuestieLib.TrimObjectiveText = originalTrimObjectiveText
    end)

    describe("GetTooltip", function()
        it("should prefer the Blizzard API objective text", function()
            QuestieDB.GetNPC = spy.new(function()
                return {name = "Goliathon"}
            end)
            C_QuestLog.GetQuestObjectives = spy.new(function(requestedQuestId)
                assert.equals(questId, requestedQuestId)
                return {{text = "Fallen Sky Ridge Revitalized: 1/1", type = "monster"}}
            end)

            QuestieComms.data:RegisterTooltip(questId, playerName, {objective("m", 19305)})
            QuestieComms.data:RegisterTooltip(questId, "AnotherPlayer", {objective("m", 19305)})

            local result = QuestieComms.data:GetTooltip("m_19305")

            assert.equals("Fallen Sky Ridge Revitalized", result[questId][playerName][1].text)
            assert.equals("Fallen Sky Ridge Revitalized", result[questId]["AnotherPlayer"][1].text)
            assert.spy(C_QuestLog.GetQuestObjectives).was.called(1)
            assert.spy(QuestieDB.GetNPC).was.not_called()
        end)

        it("should request uncached quest data and fall back to the entity name", function()
            _G.HaveQuestData = function() return false end
            C_QuestLog.GetQuestObjectives = spy.new(function() return nil end)
            QuestieDB.GetNPC = function()
                return {name = "Goliathon"}
            end

            QuestieComms.data:RegisterTooltip(questId, playerName, {objective("m", 19305)})

            local result = QuestieComms.data:GetTooltip("m_19305")

            assert.equals("Goliathon", result[questId][playerName][1].text)
            assert.spy(C_QuestLog.GetQuestObjectives).was.called_with(questId)
        end)

        it("should safely fall back when API and entity data are unavailable", function()
            C_QuestLog.GetQuestObjectives = function()
                return {
                    {text = " ", type = "monster"},
                    {text = "Activate the object: 0/1"},
                }
            end
            QuestieDB.GetNPC = function() return nil end
            QuestieDB.GetObject = function() return nil end

            QuestieComms.data:RegisterTooltip(questId, playerName, {
                objective("m", 19305),
                objective("o", 12345),
            })

            local monsterResult = QuestieComms.data:GetTooltip("m_19305")
            local objectResult = QuestieComms.data:GetTooltip("o_12345")

            assert.equals("", monsterResult[questId][playerName][1].text)
            assert.equals("", objectResult[questId][playerName][2].text)
        end)
    end)

    describe("RegisterTooltip", function()
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
