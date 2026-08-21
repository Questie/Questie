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

    local function getMoonwellIds()
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

    local function getExpectedIds(category)
        if category == "moonwell" then
            return getMoonwellIds()
        end
        return ProfessionStations.data[category]
    end

    before_each(function()
        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.ShowObject = spy.new(function() end)
        QuestieMap.UnloadManualFrames = spy.new(function() end)
        _G["Questie"].Colorize = function(_, text) return text end

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetObject = function(_, id) return {id = id, name = "Object name " .. id, spawns = {[1] = {{50, 50}}}} end

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

            assert.are_same(getMoonwellIds(), collectShown(QuestieMap.ShowObject))
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
            QuestieDB.GetObject = function(_, id) return {id = id, name = "The Great Anvil", spawns = {[1] = {{50, 50}}}} end

            ProfessionStations.ShowAll("anvil")

            for _, call in ipairs(QuestieMap.ShowObject.calls) do
                assert.are_same("The Great Anvil", call.vals[5])
            end
        end)

        it("should use the translated title when the object has no name", function()
            QuestieDB.GetObject = function(_, id) return {id = id, spawns = {[1] = {{50, 50}}}} end

            ProfessionStations.ShowAll("anvil")

            assert.is_true(#QuestieMap.ShowObject.calls > 0)
            for _, call in ipairs(QuestieMap.ShowObject.calls) do
                assert.are_same("Anvil", call.vals[5])
            end
        end)

        it("should skip generic stations whose spawns overlap a named station", function()
            ProfessionStations.dataClassic = {[100] = true, [101] = true}
            QuestieDB.GetObject = function(_, id)
                if id == 100 then
                    return {id = id, name = "Shadowglen Moonwell", spawns = {[1] = {{50, 50}}}}
                end
                return {id = id, name = "Moonwell", spawns = {[1] = {{50.02, 50.02}}}}
            end

            ProfessionStations.ShowAll("moonwell")

            assert.are_same({100}, collectShown(QuestieMap.ShowObject))
        end)

        it("should show generic stations whose spawns do not overlap a named station", function()
            ProfessionStations.dataClassic = {[100] = true, [101] = true}
            QuestieDB.GetObject = function(_, id)
                if id == 100 then
                    return {id = id, name = "Shadowglen Moonwell", spawns = {[1] = {{50, 50}}}}
                end
                return {id = id, name = "Moonwell", spawns = {[1] = {{20, 20}}}}
            end

            ProfessionStations.ShowAll("moonwell")

            assert.are_same({100, 101}, collectShown(QuestieMap.ShowObject))
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

        it("should dedupe generic stations even when their name is localized", function()
            dofile("Localization/Translations/ProfessionStations.lua")
            QuestieLoader:ImportModule("l10n"):SetUILocale("esMX")
            ProfessionStations.dataClassic = {[100] = true, [101] = true}
            QuestieDB.GetObject = function(_, id)
                if id == 100 then
                    return {id = id, name = "Poza de la Luna de Claro de Sombra", spawns = {[1] = {{50, 50}}}}
                end
                return {id = id, name = "Poza de la Luna", spawns = {[1] = {{50.02, 50.02}}}}
            end

            ProfessionStations.ShowAll("moonwell")

            assert.are_same({100}, collectShown(QuestieMap.ShowObject))
            for _, call in ipairs(QuestieMap.ShowObject.calls) do
                assert.are_same("Poza de la Luna de Claro de Sombra", call.vals[5])
            end
            QuestieLoader:ImportModule("l10n"):SetUILocale("enUS")
        end)
    end)
end)
