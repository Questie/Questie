dofile("setupTests.lua")

describe("QuestAcceptOrder", function()
    ---@type QuestAcceptOrder
    local QuestAcceptOrder

    before_each(function()
        Questie.db.char = {journey = {}}

        dofile("Modules/Tracker/QuestAcceptOrder.lua")
        QuestAcceptOrder = QuestieLoader:ImportModule("QuestAcceptOrder")
    end)

    describe("Get", function()
        it("should return the journey position of each accepted quest", function()
            Questie.db.char.journey = {
                {Event = "Quest", SubType = "Accept", Quest = 10, Timestamp = 1},
                {Event = "Level", NewLevel = 2, Timestamp = 2},
                {Event = "Quest", SubType = "Accept", Quest = 20, Timestamp = 3},
                {Event = "Quest", SubType = "Complete", Quest = 10, Timestamp = 4},
                {Event = "Note", Title = "a note", Timestamp = 5},
            }

            assert.are_same({[10] = 1, [20] = 3}, QuestAcceptOrder.Get())
        end)

        it("should use the latest accept of a re-accepted quest", function()
            Questie.db.char.journey = {
                {Event = "Quest", SubType = "Accept", Quest = 10, Timestamp = 1},
                {Event = "Quest", SubType = "Accept", Quest = 20, Timestamp = 2},
                {Event = "Quest", SubType = "Abandon", Quest = 10, Timestamp = 3},
                {Event = "Quest", SubType = "Accept", Quest = 10, Timestamp = 4},
            }

            assert.are_same({[10] = 4, [20] = 2}, QuestAcceptOrder.Get())
        end)

        it("should return an empty table without a journey", function()
            Questie.db.char.journey = nil

            assert.are_same({}, QuestAcceptOrder.Get())
        end)

        it("should pick up quests accepted after the last call", function()
            Questie.db.char.journey = {
                {Event = "Quest", SubType = "Accept", Quest = 10, Timestamp = 1},
            }
            assert.are_same({[10] = 1}, QuestAcceptOrder.Get())

            table.insert(Questie.db.char.journey, {Event = "Quest", SubType = "Accept", Quest = 20, Timestamp = 2})

            assert.are_same({[10] = 1, [20] = 2}, QuestAcceptOrder.Get())
        end)

        it("should rebuild when an entry is replaced without changing the journey length", function()
            Questie.db.char.journey = {
                {Event = "Quest", SubType = "Accept", Quest = 10, Timestamp = 1},
                {Event = "Note", Title = "a note", Timestamp = 2},
            }
            assert.are_same({[10] = 1}, QuestAcceptOrder.Get())

            -- A note is deleted and a quest accepted afterwards
            table.remove(Questie.db.char.journey, 2)
            table.insert(Questie.db.char.journey, {Event = "Quest", SubType = "Accept", Quest = 20, Timestamp = 3})

            assert.are_same({[10] = 1, [20] = 2}, QuestAcceptOrder.Get())
        end)

        it("should rebuild when the journey is reset", function()
            Questie.db.char.journey = {
                {Event = "Quest", SubType = "Accept", Quest = 10, Timestamp = 1},
            }
            assert.are_same({[10] = 1}, QuestAcceptOrder.Get())

            Questie.db.char.journey = {
                {Event = "Quest", SubType = "Accept", Quest = 20, Timestamp = 2},
            }

            assert.are_same({[20] = 1}, QuestAcceptOrder.Get())
        end)

        it("should reuse the cached lookup while the journey is unchanged", function()
            Questie.db.char.journey = {
                {Event = "Quest", SubType = "Accept", Quest = 10, Timestamp = 1},
            }

            local first = QuestAcceptOrder.Get()

            assert.are.equal(first, QuestAcceptOrder.Get())
        end)
    end)
end)
