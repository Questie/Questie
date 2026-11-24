dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("QuestieSlash", function()
    ---@type QuestieSlash
    local QuestieSlash
    local ui
    local originalQuestie, originalTrim, originalUnitName
    local notes, QuestieSearch

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie, originalTrim, originalUnitName = _G.Questie, string.trim, _G.UnitName
        string.trim = function(text) return (text:gsub("^%s+", ""):gsub("%s+$", "")) end
        _G.UnitName = function() return nil end
        _G.Questie = {
            started = true,
            db = {profile = {}},
            Colorize = function(_, text) return text end,
            Error = function(_, message) error(message) end,
        }
        notes = {}

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/ThreadLib.lua")
        QuestieLoader:ImportModule("QuestiePopup").Dialogs = {}
        dofile("Modules/Journey/JourneyThread.lua")
        QuestieSearch = QuestieLoader:ImportModule("QuestieSearch")
        QuestieSearch.Search = function(kind, query)
            for _ = 1, 5 do coroutine.yield() end
            return query == "young wolf" and kind == "npc" and {299, 705} or {}
        end
        QuestieSearch.GetName = function(kind, id)
            return id == 299 and kind == "npc" and "Young Wolf" or id == 55 and kind == "object" and "Half-eaten body" or nil
        end
        local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.manualFrames = {any = notes}
        QuestieMap.ShowNPC = function(_, id) notes[id] = {} end
        QuestieMap.ShowObject = function(_, id) notes[-id] = {} end
        QuestieMap.ResetManualFrames = function() for id in pairs(notes) do notes[id] = nil end end
        dofile("Modules/Journey/ManualNotes.lua")

        dofile("Modules/QuestieSlash.lua")
        QuestieSlash = QuestieLoader:ImportModule("QuestieSlash")
    end)

    after_each(function()
        _G.Questie, string.trim, _G.UnitName = originalQuestie, originalTrim, originalUnitName
        ui.Restore()
    end)

    ---@return number[] spawnIds What is on the map, objects are negative
    local function Shown()
        local ids = {}
        for id in pairs(notes) do table.insert(ids, id) end
        table.sort(ids)
        return ids
    end

    ---@param command string
    local function Run(command)
        QuestieSlash.HandleCommands(command)
        ui.RunUntilIdle()
    end

    describe("tomap", function()
        it("should show everything with a name on the map", function()
            Run("tomap npc young wolf")

            assert.are_same({299, 705}, Shown())
            assert.are_same({"/questie tomap npc young wolf: 2 matches found and added to map."}, ui.printed)
        end)

        it("should spread a search over several frames, instead of freezing the game", function()
            QuestieSlash.HandleCommands("search npc young wolf")
            ui.RunFrame()
            assert.are_same({}, Shown())

            ui.RunUntilIdle()
            assert.are_same({299, 705}, Shown())
        end)

        it("should say so when nothing has the name", function()
            Run("tomap object young wolf")

            assert.are_same({}, Shown())
            assert.are_same({"/questie tomap object young wolf: No match found, nothing added to map."}, ui.printed)
        end)

        it("should show an ID, of which there is only one", function()
            Run("tomap npc 299")
            Run("tomap object 55")

            assert.are_same({-55, 299}, Shown())
            assert.are.equal("/questie tomap npc 299: Exact match found, added Young Wolf to map.", ui.printed[1])
        end)

        it("should say so when an ID doesn't exist", function()
            Run("tomap npc 404")

            assert.are_same({}, Shown())
            assert.are_same({"/questie tomap npc 404: No match found, nothing added to map."}, ui.printed)
        end)

        it("should show the target when nothing else is asked for", function()
            QuestieSearch.Search = function(_, query) return query == "Young Wolf" and {299} or {} end
            _G.UnitName = function(unit) return unit == "target" and "Young Wolf" or nil end

            Run("tomap")

            assert.are_same({299}, Shown())
        end)

        it("should need a target or something to search for", function()
            Run("tomap")
            Run("tomap npc")

            assert.are_same({}, Shown())
            assert.are_same({
                "/questie tomap: An active target or search parameters are required.",
                "/questie tomap npc: Search term required.",
            }, ui.printed)
        end)

        it("should remove everything", function()
            Run("tomap npc 299")

            Run("tomap reset")

            assert.are_same({}, Shown())
            assert.are.equal("/questie tomap reset: All map markers cleared.", ui.printed[2])
        end)

        it("should remove what is still being searched for", function()
            QuestieSlash.HandleCommands("tomap npc young wolf")
            ui.RunFrame()

            Run("tomap reset")

            assert.are_same({}, Shown())
            assert.are_same({"/questie tomap reset: All map markers cleared."}, ui.printed)
        end)

        it("should only do what was asked for last", function()
            QuestieSlash.HandleCommands("tomap npc young wolf")
            ui.RunFrame()

            Run("tomap object young wolf")

            assert.are_same({"/questie tomap object young wolf: No match found, nothing added to map."}, ui.printed)
        end)

        it("should treat a number with more words as a name", function()
            Run("tomap npc 299 wolves")

            assert.are_same({}, Shown())
            assert.are_same({"/questie tomap npc 299 wolves: No match found, nothing added to map."}, ui.printed)
        end)
    end)
end)
