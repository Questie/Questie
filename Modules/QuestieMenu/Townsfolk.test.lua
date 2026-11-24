dofile("setupTests.lua")

local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

describe("Townsfolk", function()
    ---@type Townsfolk
    local Townsfolk
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieProfessions
    local QuestieProfessions
    ---@type Expansions
    local Expansions
    ---@type QuestieDBMock
    local mock
    local LibQuestieDB
    local npcKeys, itemKeys, objectKeys
    local professionKeys

    local originalExpansion
    local originalIsSoD
    local originalUnitLevel
    local originalUnitClassBase

    ---@type table<string, integer> The provider's service IDs.
    local services
    ---@type table<string, ObjectId[]>|nil What Townsfolk handed to ProfessionStations.
    local stationObjects

    ---Runs Townsfolk.Initialize to completion; it yields between database chunks.
    ---@return nil
    local function _RunInitialize()
        local initialize = coroutine.create(Townsfolk.Initialize)
        repeat
            local ok, err = coroutine.resume(initialize)
            if not ok then
                error(err, 0)
            end
        until coroutine.status(initialize) == "dead"
    end

    ---Binds the composed ID maps and query functions the way QuestieDB.lua does.
    ---@return nil
    local function _BindComposedReads()
        QuestieDB.NPCPointers = LibQuestieDB.Npc.GetAllIds(true)
        QuestieDB.ItemPointers = LibQuestieDB.Item.GetAllIds(true)
        QuestieDB.ObjectPointers = LibQuestieDB.Object.GetAllIds(true)
        QuestieDB.QueryNPCSingle = LibQuestieDB.Npc.Get
        QuestieDB.QueryItemSingle = LibQuestieDB.Item.Get
        QuestieDB.QueryObjectSingle = LibQuestieDB.Object.Get
    end

    ---Loads Townsfolk against the current mock; it reads the player's class and the service IDs at file load.
    ---@return nil
    local function _LoadTownsfolk()
        dofile("Modules/QuestieMenu/Townsfolk.lua")
        Townsfolk = QuestieLoader:ImportModule("Townsfolk")
    end

    before_each(function()
        mock = LoadQuestieDBMock()
        LibQuestieDB = mock.lib
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        npcKeys, itemKeys, objectKeys = QuestieDB.npcKeys, QuestieDB.itemKeys, QuestieDB.objectKeys
        services = LibQuestieDB.Enum.serviceKeys
        QuestieDB.serviceKeys = services
        QuestieDB.ServiceSet = LibQuestieDB.Set
        QuestieDB.NpcHasServices = LibQuestieDB.Npc.HasServices

        Expansions = QuestieLoader:ImportModule("Expansions")
        originalExpansion = Expansions.Current
        originalIsSoD = Questie.IsSoD
        originalUnitLevel = _G.UnitLevel
        originalUnitClassBase = _G.UnitClassBase
        Expansions.Current = Expansions.Era
        Questie.IsSoD = false
        Questie.db.global = {}
        Questie.db.char = {}
        _G.UnitLevel = function() return 60 end

        dofile("Modules/QuestieProfessions.lua")
        QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
        professionKeys = QuestieProfessions.professionKeys
        stationObjects = nil
        QuestieLoader:ImportModule("ProfessionStations").SetStationObjects = function(objectIdsByKey)
            stationObjects = objectIdsByKey
        end
        _LoadTownsfolk()

        -- NPCs
        mock.SetBaseRow("Npc", 1001, {[npcKeys.name] = "Repair Bot", [npcKeys.services] = {services.REPAIR}})
        mock.SetBaseRow("Npc", 1003, {[npcKeys.name] = "Banker Without Title", [npcKeys.services] = {services.BANKER}})
        mock.SetBaseRow("Npc", 1002, {[npcKeys.name] = "Banker Bob", [npcKeys.subName] = "Banker", [npcKeys.services] = {services.BANKER}})
        mock.SetBaseRow("Npc", 1004, {[npcKeys.name] = "[DND] Repair Tester", [npcKeys.services] = {services.REPAIR}})
        mock.SetBaseRow("Npc", 1005, {
            [npcKeys.name] = "Innkeeper Allison",
            [npcKeys.subName] = "Innkeeper",
            [npcKeys.services] = {services.VENDOR, services.INNKEEPER},
            [npcKeys.friendlyToFaction] = "AH",
        })
        -- Trainers carry a localized sub-name on purpose: nothing may depend on it.
        mock.SetBaseRow("Npc", 2001, {
            [npcKeys.name] = "Smith Argus", [npcKeys.subName] = "Maître forgeron",
            [npcKeys.services] = {services.TRAINER, services.PROFESSION_TRAINER},
            [npcKeys.trainerSkills] = {professionKeys.BLACKSMITHING, professionKeys.JEWELCRAFTING},
        })
        mock.SetBaseRow("Npc", 2002, {
            [npcKeys.name] = "Riding Instructor",
            [npcKeys.services] = {services.RIDING_TRAINER}, [npcKeys.trainerSkills] = {professionKeys.RIDING},
        })
        mock.SetBaseRow("Npc", 2003, {
            [npcKeys.name] = "Woo Ping", [npcKeys.subName] = "Maître d'armes",
            [npcKeys.services] = {services.WEAPON_MASTER}, [npcKeys.trainerSkills] = {43, 229},
        })
        mock.SetBaseRow("Npc", 4001, {[npcKeys.name] = "Warrior Trainer", [npcKeys.services] = {services.CLASS_TRAINER}, [npcKeys.trainerClass] = 1})
        mock.SetBaseRow("Npc", 4002, {[npcKeys.name] = "Druid Trainer", [npcKeys.services] = {services.CLASS_TRAINER}, [npcKeys.trainerClass] = 11})
        mock.SetBaseRow("Npc", 4003, {[npcKeys.name] = "Pet Trainer", [npcKeys.services] = {services.PET_TRAINER}, [npcKeys.trainerClass] = 3})
        mock.SetBaseRow("Npc", 4004, {[npcKeys.name] = "Portal Trainer", [npcKeys.services] = {services.PORTAL_TRAINER}, [npcKeys.trainerClass] = 8})
        mock.SetBaseRow("Npc", 4005, {[npcKeys.name] = "Trainer Of No Class", [npcKeys.services] = {services.CLASS_TRAINER}})
        mock.SetBaseRow("Npc", 5001, {[npcKeys.name] = "Spirit Healer", [npcKeys.services] = {services.SPIRIT_HEALER}})
        mock.SetBaseRow("Npc", 5002, {[npcKeys.name] = "Stable Master", [npcKeys.services] = {services.STABLE_MASTER}})
        mock.SetBaseRow("Npc", 8001, {[npcKeys.name] = "Neutral Vendor", [npcKeys.services] = {services.VENDOR}, [npcKeys.friendlyToFaction] = "AH"})
        mock.SetBaseRow("Npc", 8002, {[npcKeys.name] = "Alliance Vendor", [npcKeys.services] = {services.VENDOR}, [npcKeys.friendlyToFaction] = "A"})
        mock.SetBaseRow("Npc", 8003, {[npcKeys.name] = "Not A Vendor", [npcKeys.services] = {services.GOSSIP}, [npcKeys.friendlyToFaction] = "AH"})
        mock.SetBaseRow("Npc", 8004, {[npcKeys.name] = "High Level Vendor", [npcKeys.services] = {services.VENDOR}, [npcKeys.friendlyToFaction] = "H"})
        mock.SetBaseRow("Npc", 9001, {[npcKeys.name] = "Forest Spider"})

        -- Items
        mock.SetBaseRow("Item", 7001, {[itemKeys.name] = "Haunch of Meat", [itemKeys.foodType] = 1})
        mock.SetBaseRow("Item", 7002, {[itemKeys.name] = "Raw Brilliant Smallfish", [itemKeys.foodType] = 2})
        mock.SetBaseRow("Item", 7003, {[itemKeys.name] = "Linen Cloth"})
        mock.SetBaseRow("Item", 17031, {[itemKeys.name] = "Rune of Teleportation", [itemKeys.vendors] = {8001, 8002, 8003}})
        mock.SetBaseRow("Item", 159, {[itemKeys.name] = "Refreshing Spring Water", [itemKeys.vendors] = {8001}, [itemKeys.requiredLevel] = 50})
        mock.SetBaseRow("Item", 9999, {[itemKeys.name] = "Future Water", [itemKeys.vendors] = {8004}, [itemKeys.requiredLevel] = 61})

        -- Objects
        mock.SetBaseRow("Object", 6001, {[objectKeys.name] = "Mailbox", [objectKeys.services] = {services.MAILBOX}})
        mock.SetBaseRow("Object", 6002, {[objectKeys.name] = "Mailbox", [objectKeys.services] = {services.MAILBOX}, [objectKeys.requiredFaction] = "A"})
        mock.SetBaseRow("Object", 6003, {[objectKeys.name] = "Mailbox", [objectKeys.services] = {services.MAILBOX}, [objectKeys.requiredFaction] = "H"})
        mock.SetBaseRow("Object", 6005, {[objectKeys.name] = "Anvil", [objectKeys.services] = {services.ANVIL}})
        mock.SetBaseRow("Object", 6006, {[objectKeys.name] = "Smithy", [objectKeys.services] = {services.FORGE, services.ANVIL}})
        mock.SetBaseRow("Object", 6007, {[objectKeys.name] = "Old Lion Statue"})

        _BindComposedReads()
    end)

    after_each(function()
        Expansions.Current = originalExpansion
        Questie.IsSoD = originalIsSoD
        _G.UnitLevel = originalUnitLevel
        _G.UnitClassBase = originalUnitClassBase
    end)

    describe("Initialize", function()
        it("collects townsfolk by service in ascending ID order, skipping [DND] NPCs", function()
            _RunInitialize()

            local townsfolk = Townsfolk.townsfolk
            assert.are_same({1001}, townsfolk["Repair"])
            assert.are_same({1002, 1003}, townsfolk["Banker"])
            assert.are_same({1005}, townsfolk["Innkeeper"])
        end)

        it("keeps the always-shown categories when no NPC provides them and omits the optional ones", function()
            _RunInitialize()

            local townsfolk = Townsfolk.townsfolk
            assert.are_same({}, townsfolk["Auctioneer"])
            assert.are_same({}, townsfolk["Flight Master"])
            assert.is_nil(townsfolk["Barber"])
            assert.is_nil(townsfolk["Battle Pet Trainer"])
            assert.is_nil(townsfolk["Meeting Stones"])
        end)

        it("adds an optional category as soon as an NPC provides its service", function()
            mock.SetBaseRow("Npc", 1006, {[npcKeys.name] = "Barber", [npcKeys.services] = {services.BARBER}})
            _BindComposedReads()

            _RunInitialize()

            assert.are_same({1006}, Townsfolk.townsfolk["Barber"])
        end)

        it("collects profession and riding trainers by the skills they teach, and weapon masters by service", function()
            _RunInitialize()

            assert.are_same({2001}, Townsfolk.professionTrainers[professionKeys.BLACKSMITHING])
            assert.are_same({2002}, Townsfolk.professionTrainers[professionKeys.RIDING])
            assert.are_same({}, Townsfolk.professionTrainers[professionKeys.ALCHEMY])
            assert.are_same({2003}, Townsfolk.townsfolk["Weapon Master"])
        end)

        it("ignores a taught skill the current expansion has no profession for", function()
            _RunInitialize()

            assert.is_nil(Townsfolk.professionTrainers[professionKeys.JEWELCRAFTING])
        end)

        it("lists a taught skill once the expansion has the profession", function()
            Expansions.Current = Expansions.Tbc

            _RunInitialize()

            assert.are_same({2001}, Townsfolk.professionTrainers[professionKeys.JEWELCRAFTING])
        end)

        it("sorts class, pet and portal trainers under the class they serve", function()
            _RunInitialize()

            local classSpecific = Townsfolk.classSpecificTownsfolk
            assert.are_same({4001}, classSpecific.WARRIOR["Class Trainer"])
            assert.are_same({4002}, classSpecific.DRUID["Class Trainer"])
            assert.are_same({4003}, classSpecific.HUNTER["Class Trainer"])
            assert.are_same({4004}, classSpecific.MAGE["Portal Trainer"])
            assert.are_same({}, classSpecific.MAGE["Class Trainer"])
        end)

        it("gives every class a trainer list, so a class without trainers still builds", function()
            _RunInitialize()

            assert.are_same({}, Townsfolk.classSpecificTownsfolk.MONK["Class Trainer"])
            assert.are_same({}, Townsfolk.classSpecificTownsfolk.DEATHKNIGHT["Class Trainer"])
        end)

        it("shows stable masters to hunters only before MoP", function()
            _RunInitialize()

            assert.are_same({5002}, Townsfolk.classSpecificTownsfolk.HUNTER["Stable Master"])
            assert.is_nil(Townsfolk.townsfolk["Stable Master"])
        end)

        it("shows stable masters to every class from MoP", function()
            Expansions.Current = Expansions.MoP

            _RunInitialize()

            assert.are_same({5002}, Townsfolk.townsfolk["Stable Master"])
            assert.is_nil(Townsfolk.classSpecificTownsfolk.HUNTER["Stable Master"])
        end)

        it("assigns spirit healers to both factions and mailboxes by their faction restriction", function()
            _RunInitialize()

            local factionSpecific = Townsfolk.factionSpecificTownsfolk
            assert.are_same({5001}, factionSpecific.Horde["Spirit Healer"])
            assert.are_same({5001}, factionSpecific.Alliance["Spirit Healer"])
            assert.are_same({6001, 6002}, factionSpecific.Alliance["Mailbox"])
            assert.are_same({6001, 6003}, factionSpecific.Horde["Mailbox"])
        end)

        it("lists meeting stones once an object provides the service", function()
            mock.SetBaseRow("Object", 6004, {[objectKeys.name] = "Meeting Stone", [objectKeys.services] = {services.MEETING_STONE}})
            _BindComposedReads()

            _RunInitialize()

            assert.are_same({6004}, Townsfolk.townsfolk["Meeting Stones"])
        end)

        it("hands profession station objects to ProfessionStations, one object under each service it provides", function()
            _RunInitialize()

            assert.are_same({
                ["Anvil"] = {6005, 6006},
                ["Forge"] = {6006},
                ["Alchemy Lab"] = {},
                ["Moonwell"] = {},
            }, stationObjects)
        end)

        it("lists a portal trainer that also carries the class trainer service only under Portal Trainer", function()
            -- From WotLK the provider's portal trainers carry both services.
            mock.SetBaseRow("Npc", 4006, {
                [npcKeys.name] = "Portal And Class Trainer",
                [npcKeys.services] = {services.CLASS_TRAINER, services.PORTAL_TRAINER}, [npcKeys.trainerClass] = 8,
            })
            _BindComposedReads()

            _RunInitialize()

            assert.are_same({4004, 4006}, Townsfolk.classSpecificTownsfolk.MAGE["Portal Trainer"])
            assert.are_same({}, Townsfolk.classSpecificTownsfolk.MAGE["Class Trainer"])
        end)

        it("lists an NPC once when it carries two class trainer services", function()
            mock.SetBaseRow("Npc", 4007, {
                [npcKeys.name] = "Hunter And Pet Trainer",
                [npcKeys.services] = {services.CLASS_TRAINER, services.PET_TRAINER}, [npcKeys.trainerClass] = 3,
            })
            _BindComposedReads()

            _RunInitialize()

            assert.are_same({4003, 4007}, Townsfolk.classSpecificTownsfolk.HUNTER["Class Trainer"])
        end)

        it("orders each list by ID whatever order the provider's ID map iterates in", function()
            -- Hand the scan an ID map that iterates descending, which a plain table cannot promise.
            local ids = {}
            for id in pairs(QuestieDB.NPCPointers) do ids[#ids + 1] = id end
            table.sort(ids, function(a, b) return a > b end)
            local realPairs = _G.pairs
            local npcPointers = QuestieDB.NPCPointers
            _G.pairs = function(t)
                if t == npcPointers then
                    local index = 0
                    return function()
                        index = index + 1
                        if ids[index] then return ids[index], true end
                    end
                end
                return realPairs(t)
            end

            local ok, err = pcall(_RunInitialize)
            _G.pairs = realPairs
            assert(ok, err)

            assert.are_same({1002, 1003}, Townsfolk.townsfolk["Banker"])
        end)

        it("groups pet food Items by food type for hunters", function()
            -- Townsfolk reads the player's class when its file loads.
            _G.UnitClassBase = function() return "HUNTER", 3 end
            _LoadTownsfolk()

            _RunInitialize()

            local petFood = Townsfolk.petFoodVendorTypes
            assert.are_same({7001}, petFood["Meat"])
            assert.are_same({7002}, petFood["Fish"])
            assert.are_same({}, petFood["Cheese"])
        end)

        it("skips the pet food Item scan for other classes", function()
            local foodTypeReads = 0
            local queryItemSingle = QuestieDB.QueryItemSingle
            QuestieDB.QueryItemSingle = function(id, field)
                if field == "foodType" then
                    foodTypeReads = foodTypeReads + 1
                end
                return queryItemSingle(id, field)
            end

            _RunInitialize() -- as the druid from setupTests.lua

            assert.are_equal(0, foodTypeReads)
        end)
    end)

    describe("BuildCharacterTownsfolk", function()
        it("copies the player's faction and class townsfolk into the character table", function()
            _RunInitialize()

            Townsfolk:BuildCharacterTownsfolk()

            assert.are_same("DRUID", Questie.db.char.townsfolkClass)
            assert.are_same({5001}, Questie.db.char.townsfolk["Spirit Healer"])
            -- The test player is Horde: the shared mailbox and the Horde-only one.
            assert.are_same({6001, 6003}, Questie.db.char.townsfolk["Mailbox"])
            assert.are_same({4002}, Questie.db.char.townsfolk["Class Trainer"])
            assert.are_same({}, Questie.db.char.vendorList)
        end)
    end)

    describe("PopulateVendors", function()
        it("keeps vendors that provide the vendor service and are friendly to the player's faction", function()
            local vendors = Townsfolk:PopulateVendors({17031})

            assert.are_same({[8001] = true}, vendors)
        end)

        it("restricts Items to the player's level window when asked", function()
            local vendors = Townsfolk:PopulateVendors({159, 9999}, {}, true)

            assert.are_same({[8001] = true}, vendors)
        end)
    end)

    describe("PostBoot", function()
        it("fills the character vendor lists from composed Item vendors", function()
            _RunInitialize()
            Townsfolk:BuildCharacterTownsfolk()

            Townsfolk.PostBoot()

            local vendorList = Questie.db.char.vendorList
            assert.are_same({8001}, vendorList["Reagents"])
            assert.are_same({8001}, vendorList["Drink"])
            assert.are_same({}, vendorList["Ammo"])
        end)
    end)
end)
