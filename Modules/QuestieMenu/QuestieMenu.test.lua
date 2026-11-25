dofile("setupTests.lua")

describe("QuestieMenu", function()
    ---@type QuestieMenu
    local QuestieMenu
    local Townsfolk, QuestieMap
    local originals

    ---Icons currently on the map: townsfolk key -> NPC ID -> number of icons
    local drawn
    ---Tickers that have not been cancelled, in creation order
    local pendingTickers
    ---The lists the next Townsfolk:UpdatePlayerVendors builds
    local nextVendorList

    ---@return table<NpcId, number> iconsPerNpc Over all keys, so an NPC drawn twice shows up as 2
    local function _IconsOnMap()
        local icons = {}
        for _, npcs in pairs(drawn) do
            for id, count in pairs(npcs) do
                icons[id] = (icons[id] or 0) + count
            end
        end
        return icons
    end

    ---Lets every pending ticker run until it cancels itself.
    local function _FinishDrawing()
        while pendingTickers[1] do
            pendingTickers[1].callback()
        end
    end

    before_each(function()
        originals = {
            C_Timer = _G.C_Timer, tinsert = _G.tinsert, strlower = _G.strlower, UnitFactionGroup = _G.UnitFactionGroup,
            db = Questie.db, Colorize = Questie.Colorize,
        }
        _G.tinsert = table.insert
        _G.strlower = string.lower
        _G.UnitFactionGroup = function() return "Horde" end
        Questie.Colorize = function(_, text) return text end
        drawn, pendingTickers = {}, {}
        _G.C_Timer = {
            NewTicker = function(_, callback)
                local ticker = {callback = callback}
                function ticker.Cancel()
                    for index, pending in ipairs(pendingTickers) do
                        if pending == ticker then table.remove(pendingTickers, index) end
                    end
                end
                table.insert(pendingTickers, ticker)
                return ticker
            end,
        }

        dofile("Localization/l10n.lua")
        QuestieLoader:ImportModule("QuestieLib").AddonPath = ""
        dofile("Modules/QuestieProfessions.lua")
        QuestieLoader:ImportModule("ProfessionStations").stations = {}
        QuestieLoader:ImportModule("QuestieCorrections").questNPCBlacklist = {}
        QuestieLoader:ImportModule("QuestieDB").QueryNPCSingle = function(_, field)
            if field == "friendlyToFaction" then return "AH" end
            return "Npc"
        end
        local QuestiePopup = QuestieLoader:ImportModule("QuestiePopup")
        QuestiePopup.Dialogs = QuestiePopup.Dialogs or {}

        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.manualFrames = {}
        QuestieMap.ShowNPC = function(_, id, _, _, _, _, _, key)
            drawn[key] = drawn[key] or {}
            drawn[key][id] = (drawn[key][id] or 0) + 1
        end
        QuestieMap.ResetManualFrames = function(_, key) drawn[key] = nil end
        QuestieMap.UnloadManualFrames = function(_, id, key)
            if drawn[key] then drawn[key][id] = nil end
        end

        Townsfolk = QuestieLoader:ImportModule("Townsfolk")
        Townsfolk.townsfolk = {["Innkeeper"] = {10}}
        Townsfolk.professionTrainers = {}
        Townsfolk.UpdatePlayerVendors = function()
            local changedKeys = {}
            for key, ids in pairs(nextVendorList) do
                Questie.db.char.vendorList[key] = ids
                table.insert(changedKeys, key)
            end
            nextVendorList = {}
            return changedKeys
        end

        Questie.db = {
            char = {townsfolk = {}, vendorList = {}},
            profile = {townsfolkConfig = {}},
        }
        dofile("Modules/QuestieMenu/QuestieMenu.lua")
        QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
    end)

    after_each(function()
        _G.C_Timer = originals.C_Timer
        _G.tinsert = originals.tinsert
        _G.strlower = originals.strlower
        _G.UnitFactionGroup = originals.UnitFactionGroup
        Questie.db = originals.db
        Questie.Colorize = originals.Colorize
    end)

    ---@param tracked string[]
    ---@param vendorList table<string, NpcId[]>
    local function _LogIn(tracked, vendorList)
        for _, key in ipairs(tracked) do
            Questie.db.profile.townsfolkConfig[key] = true
        end
        nextVendorList = vendorList
        QuestieMenu:OnLogin()
        _FinishDrawing()
    end

    describe("RefreshPlayerVendors", function()
        it("should replace the icons of a tracked list with those of its new vendors", function()
            _LogIn({"Food"}, {Food = {1, 2}})
            assert.are_same({[1] = 1, [2] = 1}, _IconsOnMap())

            nextVendorList = {Food = {2, 3}}
            QuestieMenu.RefreshPlayerVendors()
            _FinishDrawing()

            assert.are_same({[2] = 1, [3] = 1}, _IconsOnMap())
        end)

        it("should replace every tracked list that changed", function()
            _LogIn({"Food", "Drink", "Pet Food"}, {Food = {1}, Drink = {2}, ["Pet Food"] = {3}})

            nextVendorList = {Food = {4}, Drink = {5}, ["Pet Food"] = {6}}
            QuestieMenu.RefreshPlayerVendors()
            _FinishDrawing()

            assert.are_same({[4] = 1, [5] = 1, [6] = 1}, _IconsOnMap())
        end)

        it("should skip a tracked list this character does not have, like a hunter's in a shared profile", function()
            _LogIn({"Food", "Pet Food"}, {Food = {1}})

            nextVendorList = {Food = {2}}
            QuestieMenu.RefreshPlayerVendors()
            _FinishDrawing()

            assert.are_same({[2] = 1}, _IconsOnMap())
        end)

        it("should not draw lists that are not tracked", function()
            _LogIn({"Food"}, {Food = {1}, Drink = {5}})

            nextVendorList = {Drink = {6}}
            QuestieMenu.RefreshPlayerVendors()
            assert.are_same({}, pendingTickers)

            assert.are_same({[1] = 1}, _IconsOnMap())
        end)

        it("should keep drawing an NPC that leaves one tracked list but stays on another", function()
            _LogIn({"Food", "Pet Food"}, {Food = {1}, ["Pet Food"] = {1}})
            assert.are_same({[1] = 1}, _IconsOnMap())

            nextVendorList = {Food = {}}
            QuestieMenu.RefreshPlayerVendors()
            _FinishDrawing()
            assert.are_same({[1] = 1}, _IconsOnMap())

            nextVendorList = {Food = {1}, ["Pet Food"] = {}}
            QuestieMenu.RefreshPlayerVendors()
            _FinishDrawing()
            assert.are_same({[1] = 1}, _IconsOnMap())
        end)

        it("should not draw an NPC twice that another townsfolk category already shows", function()
            _LogIn({"Innkeeper"}, {Food = {10}})
            Questie.db.profile.townsfolkConfig["Food"] = true

            for _ = 1, 2 do
                nextVendorList = {Food = {10}}
                QuestieMenu.RefreshPlayerVendors()
                _FinishDrawing()
                assert.are_same({[10] = 1}, _IconsOnMap())
            end
        end)

        it("should keep an NPC on the map that leaves the list that drew it but is in another townsfolk category", function()
            _LogIn({"Pet Food"}, {["Pet Food"] = {10}})
            Questie.db.profile.townsfolkConfig["Innkeeper"] = true

            nextVendorList = {["Pet Food"] = {}}
            QuestieMenu.RefreshPlayerVendors()
            _FinishDrawing()

            assert.are_same({[10] = 1}, _IconsOnMap())
        end)

        it("should keep the trainer of a known profession on the map that leaves the list that drew it", function()
            local COOKING = QuestieLoader:ImportModule("QuestieProfessions").professionKeys.COOKING
            QuestieLoader:ImportModule("QuestieProfessions").GetPlayerProfessions = function() return {[COOKING] = {}} end
            Townsfolk.professionTrainers = {[COOKING] = {11}}
            _LogIn({"Pet Food"}, {["Pet Food"] = {11}})
            Questie.db.profile.townsfolkKnownProfessions = true

            nextVendorList = {["Pet Food"] = {}}
            QuestieMenu.RefreshPlayerVendors()
            _FinishDrawing()

            assert.are_same({[11] = 1}, _IconsOnMap())
        end)

        it("should not redraw anything when no list changed", function()
            _LogIn({"Food"}, {Food = {1}})
            local draws = 0
            QuestieMap.ShowNPC = function() draws = draws + 1 end
            QuestieMap.ResetManualFrames = function() draws = draws + 1 end

            QuestieMenu.RefreshPlayerVendors()
            assert.are_same({}, pendingTickers)

            assert.are_equal(0, draws)
        end)

        it("should not draw mailboxes and profession stations a second time", function()
            local shown = 0
            QuestieMap.ShowObject = function() shown = shown + 1 end
            QuestieLoader:ImportModule("ProfessionStations").stations = {["Anvil"] = {}}
            QuestieLoader:ImportModule("ProfessionStations").IsStationAvailable = function() return true end
            QuestieLoader:ImportModule("ProfessionStations").ShowAll = function() shown = shown + 1 end
            QuestieLoader:ImportModule("MeetingStones").GetLocalizedDungeonNameAndLevelRangeByObjectId = function() return "Dungeon", "10-20" end
            Questie.db.char.townsfolk["Mailbox"] = {20}
            Townsfolk.townsfolk["Meeting Stones"] = {21}
            _LogIn({"Mailbox", "Meeting Stones", "Anvil", "Food"}, {Food = {1}})
            assert.are_equal(3, shown)
            assert.are_same({[1] = 1}, _IconsOnMap())

            nextVendorList = {Food = {2}}
            QuestieMenu.RefreshPlayerVendors()
            _FinishDrawing()

            assert.are_equal(3, shown)
            assert.are_same({[2] = 1}, _IconsOnMap())
        end)

        it("should abandon a list that is still being drawn", function()
            Questie.db.profile.townsfolkConfig["Food"] = true
            nextVendorList = {Food = {1, 2}}
            QuestieMenu:OnLogin()

            nextVendorList = {Food = {3}}
            QuestieMenu.RefreshPlayerVendors()
            _FinishDrawing()

            assert.are_same({[3] = 1}, _IconsOnMap())
        end)
    end)

    describe("buildVendorMenu", function()
        ---Clicks an entry of the vendor menu and lets the icons appear.
        ---@param key string
        local function _Click(key)
            for _, entry in ipairs(QuestieMenu.buildVendorMenu()) do
                if entry.text == key then
                    entry.func()
                end
            end
            _FinishDrawing()
        end

        it("should keep an NPC on the map that another ticked list needs when its own list is unticked", function()
            _LogIn({}, {Food = {1, 2}, ["Pet Food"] = {1, 3}})
            _Click("Food")
            _Click("Pet Food")
            assert.are_same({[1] = 1, [2] = 1, [3] = 1}, _IconsOnMap())

            _Click("Food")
            assert.are_same({[1] = 1, [3] = 1}, _IconsOnMap())

            _Click("Pet Food")
            assert.are_same({}, _IconsOnMap())
        end)

        it("should keep an NPC on the map that another townsfolk category needs", function()
            _LogIn({}, {Food = {10}})
            _Click("Food")
            Questie.db.profile.townsfolkConfig["Innkeeper"] = true

            _Click("Food")

            assert.are_same({[10] = 1}, _IconsOnMap())
        end)

        it("should not redraw the other lists when nothing was removed", function()
            _LogIn({"Food"}, {Food = {1}, Drink = {}})
            Questie.db.profile.townsfolkConfig["Drink"] = true

            for _, entry in ipairs(QuestieMenu.buildVendorMenu()) do
                if entry.text == "Drink" then entry.func() end
            end

            assert.are_same({}, pendingTickers)
        end)

        it("should stop drawing a list that is unticked after a refresh started to draw it again", function()
            Questie.db.profile.townsfolkConfig["Food"] = true
            Questie.db.profile.townsfolkConfig["Drink"] = true
            nextVendorList = {Food = {1, 2}, Drink = {3}}
            QuestieMenu:OnLogin()
            nextVendorList = {Drink = {4}}
            QuestieMenu.RefreshPlayerVendors()

            _Click("Food")

            assert.are_same({[4] = 1}, _IconsOnMap())
        end)

        it("should stop drawing a list that is unticked while it is still being drawn", function()
            Questie.db.profile.townsfolkConfig["Food"] = true
            nextVendorList = {Food = {1, 2}}
            QuestieMenu:OnLogin()

            QuestieMenu.buildVendorMenu()[1].func()
            _FinishDrawing()

            assert.are_same({}, _IconsOnMap())
        end)
    end)

    describe("OnLogin", function()
        it("should remove icons of vendors that are no longer listed when it resets the map", function()
            _LogIn({"Food"}, {Food = {1, 2}})

            nextVendorList = {Food = {3}}
            QuestieMenu:OnLogin(true)
            _FinishDrawing()

            assert.are_same({[3] = 1}, _IconsOnMap())
        end)

        it("should remove icons of vendors that left a list between the two steps of a map reset", function()
            _LogIn({"Food"}, {Food = {1}})
            QuestieMenu:OnLogin(true)
            _FinishDrawing()

            nextVendorList = {Food = {2}}
            QuestieMenu:OnLogin()
            _FinishDrawing()

            assert.are_same({[2] = 1}, _IconsOnMap())
        end)
    end)
end)
