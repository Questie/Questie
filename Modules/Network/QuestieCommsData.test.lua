dofile("setupTests.lua")

describe("QuestieCommsData", function()
    ---@type QuestieComms
    local QuestieComms

    ---@type QuestieDB
    local QuestieDB

    before_each(function()
        QuestieComms = require("Modules.Network.QuestieComms")

        QuestieDB = require("Database.QuestieDB")
        QuestieDB.GetItem = function() return nil end

        require("Modules.Network.QuestieCommsData")
        QuestieComms.data:ResetAll()
    end)

    describe("RegisterTooltip", function()
        it("should register direct item key and skip source expansion when item data is missing", function()
            local questId = 42
            local playerName = "OtherPlayer"
            local objectives = {
                [1] = {
                    type = "i",
                    id = 1001,
                    fulfilled = 0,
                    required = 1,
                },
                [2] = {
                    type = "m",
                    id = 2002,
                    fulfilled = 0,
                    required = 1,
                },
            }

            QuestieComms.data:RegisterTooltip(questId, playerName, objectives)

            assert.is_true(QuestieComms.data:KeyExists("i_1001"))
            assert.is_true(QuestieComms.data:KeyExists("m_2002"))
        end)

        it("should register direct item key and skip source expansion when item is hidden", function()
            QuestieDB.GetItem = function(_, itemId)
                if itemId == 1002 then
                    return {
                        Hidden = true,
                        Sources = {
                            {
                                Type = "monster",
                                Id = 3003,
                            },
                        },
                    }
                end
                return nil
            end

            local questId = 42
            local playerName = "OtherPlayer"
            local objectives = {
                [1] = {
                    type = "i",
                    id = 1002,
                    fulfilled = 0,
                    required = 1,
                },
                [2] = {
                    type = "m",
                    id = 2003,
                    fulfilled = 0,
                    required = 1,
                },
            }

            QuestieComms.data:RegisterTooltip(questId, playerName, objectives)

            assert.is_true(QuestieComms.data:KeyExists("i_1002"))
            assert.is_false(QuestieComms.data:KeyExists("m_3003"))
            assert.is_true(QuestieComms.data:KeyExists("m_2003"))
        end)
    end)
end)
