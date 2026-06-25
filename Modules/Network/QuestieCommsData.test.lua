dofile("setupTests.lua")

describe("QuestieCommsData", function()
    ---@type QuestieComms
    local QuestieComms

    ---@type QuestieDB
    local QuestieDB

    before_each(function()
        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        QuestieComms.data = {}

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetItem = function(_, itemId)
            if itemId == 1001 then
                return nil
            elseif itemId == 1002 then
                return { Hidden = true }
            end
        end

        dofile("Modules/Network/QuestieCommsData.lua")
        QuestieComms.data:ResetAll()
    end)

    describe("RegisterTooltip", function()
        local cases = {
            {
                name = "missing item data",
                itemId = 1001,
                monsterId = 2002,
            },
            {
                name = "hidden item data",
                itemId = 1002,
                monsterId = 2003,
            },
        }

        for _, case in ipairs(cases) do
            it("continues registering later objectives after skipping " .. case.name, function()
                local questId = 42
                local playerName = "OtherPlayer"
                local objectives = {
                    [1] = {
                        type = "i",
                        id = case.itemId,
                        fulfilled = 0,
                        required = 1,
                    },
                    [2] = {
                        type = "m",
                        id = case.monsterId,
                        fulfilled = 0,
                        required = 1,
                    },
                }

                QuestieComms.data:RegisterTooltip(questId, playerName, objectives)

                assert.is_false(QuestieComms.data:KeyExists("i_" .. case.itemId))
                assert.is_true(QuestieComms.data:KeyExists("m_" .. case.monsterId))
            end)
        end
    end)
end)
