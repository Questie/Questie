dofile("setupTests.lua")
dofile("Localization/l10n.lua")

describe("ProfessionStations", function()

    ---@type ProfessionStations
    local ProfessionStations

    ---@type QuestieMap
    local QuestieMap

    ---@type Expansions
    local Expansions

    ---@type QuestieDB
    local QuestieDB

    local categories = {
        {key = "moonwell", icon = "Interface\\Icons\\inv_fabric_moonrag_01.blp", title = "Moonwell"},
        {key = "anvil", icon = "Interface\\Icons\\inv_hammer_20.blp", title = "Anvil"},
        {key = "forge", icon = "Interface\\Icons\\spell_fire_flameblades.blp", title = "Forge"},
        {key = "alchemyLab", icon = "Interface\\Icons\\inv_alchemy_endlessflask_03.blp", title = "Alchemy Lab"},
    }

    local function collectShown(spy)
        local shown = {}
        for _, call in ipairs(spy.calls) do
            table.insert(shown, call.vals[2])
        end
        table.sort(shown)
        return shown
    end

    local function getExpectedIds(category)
        if category == "moonwell" then
            local ids = {}
            for id in pairs(ProfessionStations.dataClassic) do
                table.insert(ids, id)
            end
            if Expansions.Current >= Expansions.Tbc then
                for id in pairs(ProfessionStations.dataTBC) do
                    table.insert(ids, id)
                end
            end
            table.sort(ids)
            return ids
        end
        local ids = {}
        for _, id in ipairs(ProfessionStations.data[category]) do
            table.insert(ids, id)
        end
        table.sort(ids)
        return ids
    end

    before_each(function()
        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.ShowObject = spy.new(function() end)
        QuestieMap.UnloadManualFrames = spy.new(function() end)
        _G["Questie"].Colorize = function(_, text) return text end

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetObject = function(_, id) return {id = id, name = "Object name " .. id} end

        Expansions = QuestieLoader:ImportModule("Expansions")
        Expansions.Era = 1
        Expansions.Tbc = 2
        Expansions.Current = Expansions.Era

        dofile("Modules/Map/ProfessionStations.lua")
        ProfessionStations = QuestieLoader:ImportModule("ProfessionStations")
    end)

    for _, category in ipairs(categories) do
        describe("ShowAll " .. category.key, function()
            it("should call ShowObject for every object ID of the category", function()
                ProfessionStations.ShowAll(category.key)

                assert.are_same(getExpectedIds(category.key), collectShown(QuestieMap.ShowObject))
            end)

            it("should pass the correct icon, scale, title and type", function()
                ProfessionStations.ShowAll(category.key)

                for _, call in ipairs(QuestieMap.ShowObject.calls) do
                    assert.are_same(category.icon, call.vals[3])
                    assert.are_same(1.2, call.vals[4])
                    assert.are_same("Object name " .. call.vals[2], call.vals[5])
                    assert.is_nil(call.vals[6])
                    assert.is_true(call.vals[7])
                    assert.are_same(category.key, call.vals[8])
                end
            end)
        end)

        describe("HideAll " .. category.key, function()
            it("should call UnloadManualFrames for every object ID of the category", function()
                ProfessionStations.HideAll(category.key)

                assert.are_same(getExpectedIds(category.key), collectShown(QuestieMap.UnloadManualFrames))
            end)

            it("should pass the category as type", function()
                ProfessionStations.HideAll(category.key)

                for _, call in ipairs(QuestieMap.UnloadManualFrames.calls) do
                    assert.are_same(category.key, call.vals[3])
                end
            end)
        end)
    end

    describe("ShowAll moonwell", function()
        it("should also show TBC moonwells when TBC+", function()
            Expansions.Current = Expansions.Tbc

            ProfessionStations.ShowAll("moonwell")

            local expected = {}
            for id in pairs(ProfessionStations.dataClassic) do
                table.insert(expected, id)
            end
            for id in pairs(ProfessionStations.dataTBC) do
                table.insert(expected, id)
            end
            table.sort(expected)
            assert.are_same(expected, collectShown(QuestieMap.ShowObject))
        end)
    end)

    describe("ShowAll title fallback", function()
        it("should use the translated title when the object name is generic", function()
            QuestieDB.GetObject = function(_, id) return {id = id, name = "Anvil"} end

            ProfessionStations.ShowAll("anvil")

            for _, call in ipairs(QuestieMap.ShowObject.calls) do
                assert.are_same("Anvil", call.vals[5])
            end
        end)

        it("should use the object name when it is not generic", function()
            QuestieDB.GetObject = function(_, id) return {id = id, name = "The Great Anvil"} end

            ProfessionStations.ShowAll("anvil")

            for _, call in ipairs(QuestieMap.ShowObject.calls) do
                assert.are_same("The Great Anvil", call.vals[5])
            end
        end)

        it("should use the translated title when the object is missing", function()
            QuestieDB.GetObject = function() return nil end

            ProfessionStations.ShowAll("anvil")

            for _, call in ipairs(QuestieMap.ShowObject.calls) do
                assert.are_same("Anvil", call.vals[5])
            end
        end)

        it("should use the translated generic name on esMX", function()
            dofile("Localization/Translations/ProfessionStations.lua")
            QuestieLoader:ImportModule("l10n"):SetUILocale("esMX")
            QuestieDB.GetObject = function(_, id) return {id = id, name = "Anvil"} end

            ProfessionStations.ShowAll("anvil")

            for _, call in ipairs(QuestieMap.ShowObject.calls) do
                assert.are_same("Yunque", call.vals[5])
            end
            QuestieLoader:ImportModule("l10n"):SetUILocale("enUS")
        end)
    end)
end)
