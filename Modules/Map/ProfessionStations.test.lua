dofile("setupTests.lua")
dofile("Localization/l10n.lua")
dofile("Modules/Libs/QuestieLib.lua")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

describe("ProfessionStations", function()

    ---@type ProfessionStations
    local ProfessionStations

    ---@type QuestieMap
    local QuestieMap

    ---@type Expansions
    local Expansions

    ---@type QuestieDB
    local QuestieDB

    ---@type QuestieProfessions
    local QuestieProfessions

    local playerProfessions = {}

    local function setPlayerProfessions(professionIds)
        playerProfessions = {}
        for _, professionId in ipairs(professionIds or {}) do
            playerProfessions[professionId] = true
        end
    end

    local categories = {
        {key = "moonwell", icon = "Interface\\Icons\\inv_fabric_moonrag_01.blp", title = "Moonwell"},
        {key = "anvil", icon = QuestieLib.AddonPath.."Icons\\inv_hammer_20.png", title = "Anvil"},
        {key = "forge", icon = QuestieLib.AddonPath.."Icons\\spell_fire_flameblades.png", title = "Forge"},
        {key = "alchemyLab", icon = QuestieLib.AddonPath.."Icons\\ui_profession_alchemy.png", title = "Alchemy Lab"},
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
        local ids = {}
        for _, id in ipairs(ProfessionStations.data[category]) do
            ids[#ids + 1] = id
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
        QuestieDB.GetObject = function(_, id) return {id = id, name = "Object name " .. id, spawns = {[1] = {{50, 50}}}} end

        QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
        dofile("Modules/QuestieProfessions.lua")
        QuestieProfessions.HasProfessionAndSkillLevel = function(_, requiredSkill)
            return playerProfessions[requiredSkill[1]] == true, true
        end

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
                    assert.are_same({}, call.vals[6])
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

    describe("ShowAll title fallback", function()
        it("should use the translated title when the object has no name", function()
            QuestieDB.GetObject = function(_, id) return {id = id, spawns = {[1] = {{50, 50}}}} end

            ProfessionStations.ShowAll("anvil")

            assert.is_true(#QuestieMap.ShowObject.calls > 0)
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

    describe("IsStationAvailable", function()
        local keys

        before_each(function()
            keys = QuestieProfessions.professionKeys
        end)

        local function assertStation(key, expected, professionIds, expansion)
            setPlayerProfessions(professionIds)
            Expansions.Current = expansion
            if expected then
                assert.is_true(ProfessionStations.IsStationAvailable(key))
            else
                assert.is_false(ProfessionStations.IsStationAvailable(key))
            end
        end

        it("should show the moonwell for tailors regardless of expansion", function()
            assertStation("Moonwell", true, {keys.TAILORING}, Expansions.MoP)
        end)

        it("should hide the moonwell without tailoring", function()
            assertStation("Moonwell", false, {}, Expansions.Era)
        end)

        it("should show the anvil for blacksmiths in every expansion", function()
            assertStation("Anvil", true, {keys.BLACKSMITHING}, Expansions.MoP)
        end)

        it("should show the anvil for engineers in every expansion", function()
            assertStation("Anvil", true, {keys.ENGINEERING}, Expansions.Tbc)
        end)

        it("should hide the anvil for jewelcrafters before Cataclysm", function()
            assertStation("Anvil", false, {keys.JEWELCRAFTING}, Expansions.Era)
            assertStation("Anvil", false, {keys.JEWELCRAFTING}, Expansions.Wotlk)
        end)

        it("should show the anvil for jewelcrafters starting with Cataclysm", function()
            assertStation("Anvil", true, {keys.JEWELCRAFTING}, Expansions.Cata)
        end)

        it("should hide the anvil without a matching profession", function()
            assertStation("Anvil", false, {}, Expansions.Cata)
        end)

        it("should show the forge for miners in every expansion", function()
            assertStation("Forge", true, {keys.MINING}, Expansions.Cata)
        end)

        it("should hide the forge for engineers before TBC", function()
            assertStation("Forge", false, {keys.ENGINEERING}, Expansions.Era)
        end)

        it("should show the forge for engineers starting with TBC", function()
            assertStation("Forge", true, {keys.ENGINEERING}, Expansions.Tbc)
        end)

        it("should show the forge for jewelcrafters starting with TBC", function()
            assertStation("Forge", true, {keys.JEWELCRAFTING}, Expansions.Tbc)
        end)

        it("should hide the forge for jewelcrafters before TBC", function()
            assertStation("Forge", false, {keys.JEWELCRAFTING}, Expansions.Era)
        end)

        it("should hide the alchemy lab without alchemy", function()
            assertStation("Alchemy Lab", false, {}, Expansions.Era)
        end)

        it("should show the alchemy lab for alchemists up to and including TBC", function()
            assertStation("Alchemy Lab", true, {keys.ALCHEMY}, Expansions.Era)
            assertStation("Alchemy Lab", true, {keys.ALCHEMY}, Expansions.Tbc)
        end)

        it("should hide the alchemy lab from WotLK on even for alchemists", function()
            assertStation("Alchemy Lab", false, {keys.ALCHEMY}, Expansions.Wotlk)
            assertStation("Alchemy Lab", false, {keys.ALCHEMY}, Expansions.MoP)
        end)

        it("should hide unknown stations", function()
            assertStation("Innkeeper", false, {}, Expansions.Era)
        end)
    end)

    describe("GetAvailableStationKeys", function()
        local keys

        before_each(function()
            keys = QuestieProfessions.professionKeys
        end)

        it("should only return stations the player qualifies for", function()
            setPlayerProfessions({keys.MINING})

            assert.are_same({"Forge"}, ProfessionStations.GetAvailableStationKeys())
        end)

        it("should return an empty list without matching professions", function()
            setPlayerProfessions({})

            assert.are_same({}, ProfessionStations.GetAvailableStationKeys())
        end)

        it("should exclude stations that are not required in the current expansion", function()
            setPlayerProfessions({keys.BLACKSMITHING, keys.TAILORING, keys.MINING, keys.ALCHEMY})
            Expansions.Current = Expansions.Wotlk

            assert.are_same({"Anvil", "Forge", "Moonwell"}, ProfessionStations.GetAvailableStationKeys())
        end)

        it("should sort the stations alphabetically by their localized titles", function()
            dofile("Localization/Translations/ProfessionStations.lua")
            setPlayerProfessions({keys.BLACKSMITHING, keys.TAILORING, keys.MINING, keys.ALCHEMY})
            Expansions.Current = Expansions.Era

            assert.are_same({"Alchemy Lab", "Anvil", "Forge", "Moonwell"}, ProfessionStations.GetAvailableStationKeys())

            QuestieLoader:ImportModule("l10n"):SetUILocale("esMX")

            assert.are_same({"Forge", "Alchemy Lab", "Moonwell", "Anvil"}, ProfessionStations.GetAvailableStationKeys())

            QuestieLoader:ImportModule("l10n"):SetUILocale("enUS")
        end)
    end)

    describe("HideUnlearned", function()
        local keys

        before_each(function()
            keys = QuestieProfessions.professionKeys
            _G["Questie"].db.profile.townsfolkConfig = {}
        end)

        it("should hide enabled stations whose profession was unlearned", function()
            _G["Questie"].db.profile.townsfolkConfig["Anvil"] = true
            setPlayerProfessions({})

            assert.is_true(ProfessionStations.HideUnlearned())
            assert.are_same(getExpectedIds("anvil"), collectShown(QuestieMap.UnloadManualFrames))
            for _, call in ipairs(QuestieMap.UnloadManualFrames.calls) do
                assert.are_same("anvil", call.vals[3])
            end
            assert.is_false(_G["Questie"].db.profile.townsfolkConfig["Anvil"])
        end)

        it("should keep enabled stations the player still qualifies for", function()
            _G["Questie"].db.profile.townsfolkConfig["Anvil"] = true
            setPlayerProfessions({keys.BLACKSMITHING})

            assert.is_false(ProfessionStations.HideUnlearned())
            assert.is_true(#QuestieMap.UnloadManualFrames.calls == 0)
            assert.is_true(_G["Questie"].db.profile.townsfolkConfig["Anvil"])
        end)

        it("should ignore stations that are disabled", function()
            _G["Questie"].db.profile.townsfolkConfig["Anvil"] = false
            setPlayerProfessions({})

            assert.is_false(ProfessionStations.HideUnlearned())
            assert.is_true(#QuestieMap.UnloadManualFrames.calls == 0)
        end)

        it("should only hide the stations that lost their requirement", function()
            _G["Questie"].db.profile.townsfolkConfig["Anvil"] = true
            _G["Questie"].db.profile.townsfolkConfig["Moonwell"] = true
            setPlayerProfessions({keys.TAILORING})

            assert.is_true(ProfessionStations.HideUnlearned())

            local unloadedTypes = {}
            for _, call in ipairs(QuestieMap.UnloadManualFrames.calls) do
                unloadedTypes[call.vals[3]] = true
            end
            assert.is_true(unloadedTypes["anvil"])
            assert.is_nil(unloadedTypes["moonwell"])
            assert.is_false(_G["Questie"].db.profile.townsfolkConfig["Anvil"])
            assert.is_true(_G["Questie"].db.profile.townsfolkConfig["Moonwell"])
        end)
    end)
end)
