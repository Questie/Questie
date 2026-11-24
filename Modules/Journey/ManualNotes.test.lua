dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("ManualNotes", function()
    ---@type ManualNotes
    local ManualNotes
    local ui
    local originalQuestie
    local notes, openedMap, canOpenMap, messages

    local ELWYNN, DEADMINES, WESTFALL = 12, 1581, 40
    local ELWYNN_MAP, WESTFALL_MAP = 1429, 1436

    ---@return number[] spawnIds What is on the map, objects are negative
    local function ShownNotes()
        local ids = {}
        for id in pairs(notes) do table.insert(ids, id) end
        table.sort(ids)
        return ids
    end

    ---@param count number
    ---@return number[]
    local function CreateIds(count)
        local ids = {}
        for id = 1, count do ids[id] = id end
        return ids
    end

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie, messages = _G.Questie, {}
        _G.Questie = {Print = function(_, message) table.insert(messages, message) end, db = {profile = {}}}

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Modules/Libs/ThreadLib.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Journey/JourneyThread.lua")

        local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        notes = {}
        QuestieMap.manualFrames = {}
        QuestieMap.ShowNPC = function(_, id)
            assert(not notes[id], "there are two notes for " .. id)
            notes[id] = {}
            QuestieMap.manualFrames.any = notes
        end
        QuestieMap.ShowObject = function(_, id) QuestieMap:ShowNPC(-id) end
        QuestieMap.UnloadManualFrames = function(_, id) notes[id] = nil end
        QuestieMap.ResetManualFrames = function() for id in pairs(notes) do notes[id] = nil end end

        local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.GetDungeonLocation = function(_, zoneId)
            return zoneId == DEADMINES and {{WESTFALL, 42.5, 71.7}} or nil
        end
        ZoneDB.GetUiMapIdByAreaId = function(_, zoneId)
            return ({[ELWYNN] = ELWYNN_MAP, [WESTFALL] = WESTFALL_MAP})[zoneId]
        end
        openedMap, canOpenMap = nil, true
        QuestieLoader:ImportModule("QuestieCompat").OpenWorldMap = function(uiMapId)
            if canOpenMap then openedMap = uiMapId end
            return canOpenMap
        end

        dofile("Modules/Journey/ManualNotes.lua")
        ManualNotes = QuestieLoader:ImportModule("ManualNotes")
    end)

    after_each(function()
        _G.Questie = originalQuestie
        ui.Restore()
    end)

    it("should show and hide an NPC", function()
        assert.is_false(ManualNotes.IsShown("npc", 197))

        ManualNotes.Show("npc", 197)
        assert.is_true(ManualNotes.IsShown("npc", 197))

        ManualNotes.Hide("npc", 197)
        assert.is_false(ManualNotes.IsShown("npc", 197))
    end)

    it("should not confuse an object with the NPC of the same ID", function()
        ManualNotes.Show("object", 55)

        assert.are_same({-55}, ShownNotes())
        assert.is_true(ManualNotes.IsShown("object", 55))
        assert.is_false(ManualNotes.IsShown("npc", 55))

        ManualNotes.Hide("object", 55)
        assert.are_same({}, ShownNotes())
    end)

    it("should notice a note that was removed on the map", function()
        ManualNotes.Show("npc", 197)

        notes[197] = nil

        assert.is_false(ManualNotes.IsShown("npc", 197))
    end)

    it("should not show something twice", function()
        ManualNotes.Show("npc", 197)
        ManualNotes.Show("npc", 197)

        assert.are_same({197}, ShownNotes())
    end)

    describe("a group", function()
        it("should be shown and hidden together", function()
            ManualNotes.ShowGroup("item 725", "object", {55, 56})
            ui.RunUntilIdle()
            assert.are_same({-56, -55}, ShownNotes())
            assert.is_true(ManualNotes.IsGroupShown("item 725"))

            ManualNotes.HideGroup("item 725", "object", {55, 56})
            ui.RunUntilIdle()
            assert.are_same({}, ShownNotes())
            assert.is_false(ManualNotes.IsGroupShown("item 725"))
        end)

        it("should be told apart from other groups", function()
            ManualNotes.ShowGroup("item 725", "npc", {98})

            assert.is_false(ManualNotes.IsGroupShown("item 726"))
        end)

        it("should not stop another group from being shown", function()
            ui.clockStep = 0.003
            ManualNotes.ShowGroup("item 725", "npc", CreateIds(20))
            ManualNotes.ShowGroup("item 726", "object", CreateIds(20))

            ui.RunUntilIdle()

            assert.are.equal(40, #ShownNotes())
        end)

        it("should not be added in a single frame when that is too much", function()
            ui.clockStep = 0.003

            ManualNotes.ShowGroup("item 725", "npc", CreateIds(50))
            ui.RunFrame()
            assert.is_true(#ShownNotes() > 0 and #ShownNotes() < 10)

            ui.RunUntilIdle()
            assert.are.equal(50, #ShownNotes())
        end)

        for order, runsLatestTimersFirst in pairs({["the older one first"] = false, ["the newer one first"] = true}) do
            describe("with two changes at once, " .. order, function()
                before_each(function()
                    ui.clockStep = 0.003
                    ui.runsLatestTimersFirst = runsLatestTimersFirst
                end)

                it("should be gone when it is hidden while it is still being added", function()
                    ManualNotes.ShowGroup("item 725", "npc", CreateIds(50))
                    ui.RunFrame()
                    ui.RunFrame()

                    ManualNotes.HideGroup("item 725", "npc", CreateIds(50))
                    ui.RunUntilIdle()

                    assert.are_same({}, ShownNotes())
                end)

                it("should be complete when it is shown while it is still being removed", function()
                    ManualNotes.ShowGroup("item 725", "npc", CreateIds(50))
                    ui.RunUntilIdle()
                    ManualNotes.HideGroup("item 725", "npc", CreateIds(50))
                    ui.RunFrame()
                    ui.RunFrame()

                    ManualNotes.ShowGroup("item 725", "npc", CreateIds(50))
                    ui.RunUntilIdle()

                    assert.are.equal(50, #ShownNotes())
                end)
            end)
        end
    end)

    describe("HideAll", function()
        it("should remove everything and forget what was shown", function()
            ManualNotes.Show("npc", 197)
            ManualNotes.ShowGroup("item 725", "object", {55, 56})
            ui.RunUntilIdle()

            ManualNotes.HideAll()

            assert.are_same({}, ShownNotes())
            assert.is_false(ManualNotes.IsGroupShown("item 725"))
        end)

        it("should stop what is still being added", function()
            ui.clockStep = 0.003
            ManualNotes.ShowGroup("item 725", "npc", CreateIds(50))
            ui.RunFrame()
            ui.RunFrame()

            ManualNotes.HideAll()
            ui.RunUntilIdle()

            assert.are_same({}, ShownNotes())
        end)
    end)

    describe("the map", function()
        it("should be the one of a zone, or where the entrance of an instance is", function()
            assert.are.equal(ELWYNN_MAP, ManualNotes.GetMap(ELWYNN))
            assert.are.equal(WESTFALL_MAP, ManualNotes.GetMap(DEADMINES))
            assert.is_nil(ManualNotes.GetMap(9999))
        end)

        it("should be opened with a note for what is looked for", function()
            assert.is_true(ManualNotes.OpenMap("npc", 197, ELWYNN_MAP))

            assert.are_same({197}, ShownNotes())
            assert.are.equal(ELWYNN_MAP, openedMap)
        end)

        it("should say so when combat prevents it", function()
            canOpenMap = false

            assert.is_false(ManualNotes.OpenMap("npc", 197, ELWYNN_MAP))

            assert.are_same({"Can't open the map while in combat. Open it manually."}, messages)
            assert.are_same({197}, ShownNotes())
        end)
    end)
end)
