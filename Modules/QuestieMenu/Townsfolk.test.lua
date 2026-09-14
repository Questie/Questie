dofile("setupTests.lua")

local LoadQuestieTDBMock = dofile("test/QuestieTDBMock.lua")

describe("Townsfolk", function()
    ---@type Townsfolk
    local Townsfolk
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieProfessions
    local QuestieProfessions
    ---@type Expansions
    local Expansions
    ---@type QuestieTDBMock
    local mock
    local LibQuestieDB
    local npcKeys, itemKeys, objectKeys
    local professionKeys

    local originalExpansion
    local originalIsClassic
    local originalUnitLevel

    -- Classic-client NPC flag values, mirroring QuestieDB.npcFlags on Era.
    local NPC_FLAGS = {
        REPAIR = 16384,
        AUCTIONEER = 4096,
        BANKER = 256,
        BATTLEMASTER = 2048,
        FLIGHT_MASTER = 8,
        INNKEEPER = 128,
        STABLEMASTER = 8192,
        SPIRIT_HEALER = 32,
        VENDOR = 4,
    }

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

    ---Binds the composed ID maps and query functions the way QuestieDB.Initialize does.
    ---@return nil
    local function _BindComposedReads()
        QuestieDB.NPCPointers = LibQuestieDB.Npc.GetAllIds(true)
        QuestieDB.ItemPointers = LibQuestieDB.Item.GetAllIds(true)
        QuestieDB.ObjectPointers = LibQuestieDB.Object.GetAllIds(true)
        QuestieDB.QueryNPCSingle = LibQuestieDB.Npc.Get
        QuestieDB.QueryItemSingle = LibQuestieDB.Item.Get
        QuestieDB.QueryObjectSingle = LibQuestieDB.Object.Get
    end

    before_each(function()
        mock = LoadQuestieTDBMock()
        LibQuestieDB = mock.lib
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        npcKeys, itemKeys, objectKeys = QuestieDB.npcKeys, QuestieDB.itemKeys, QuestieDB.objectKeys
        QuestieDB.npcFlags = NPC_FLAGS
        QuestieDB.factionTemplate = {}

        Expansions = QuestieLoader:ImportModule("Expansions")
        originalExpansion = Expansions.Current
        originalIsClassic = Questie.IsClassic
        originalUnitLevel = _G.UnitLevel
        Expansions.Current = Expansions.Era
        Questie.IsClassic = true
        Questie.IsSoD = false
        Questie.db.global = {}
        Questie.db.char = {}
        _G.UnitLevel = function() return 60 end

        dofile("Modules/QuestieProfessions.lua")
        QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
        professionKeys = QuestieProfessions.professionKeys
        -- Init() builds this from translations; the sub-name match is all Townsfolk reads.
        QuestieProfessions.professionTable = {
            ["Blacksmithing"] = professionKeys.BLACKSMITHING,
            ["Riding"] = professionKeys.RIDING,
        }

        dofile("Modules/QuestieMenu/Townsfolk.lua")
        Townsfolk = QuestieLoader:ImportModule("Townsfolk")
        -- The curated ID lists live in sibling files; Townsfolk only filters them against the database.
        Townsfolk.GetProfessionTrainers = function() return {2001, 2002, 2003, 2999} end
        Townsfolk.GetClassTrainers = function()
            return {WARRIOR = {4001, 4999}, DRUID = {4002}, MAGE = {}, HUNTER = {}}
        end
        Townsfolk.GetMailboxes = function() return {6001, 6002} end
        Townsfolk.GetMeetingStones = function() return {} end

        -- NPCs
        mock.SetBaseRow("Npc", 1001, {[npcKeys.name] = "Repair Bot", [npcKeys.npcFlags] = NPC_FLAGS.REPAIR})
        mock.SetBaseRow("Npc", 1002, {[npcKeys.name] = "Banker Bob", [npcKeys.subName] = "Banker", [npcKeys.npcFlags] = NPC_FLAGS.BANKER})
        mock.SetBaseRow("Npc", 1003, {[npcKeys.name] = "Banker Without Title", [npcKeys.npcFlags] = NPC_FLAGS.BANKER})
        mock.SetBaseRow("Npc", 1004, {[npcKeys.name] = "[DND] Repair Tester", [npcKeys.npcFlags] = NPC_FLAGS.REPAIR})
        mock.SetBaseRow("Npc", 1005, {
            [npcKeys.name] = "Innkeeper Allison",
            [npcKeys.subName] = "Innkeeper",
            [npcKeys.npcFlags] = NPC_FLAGS.INNKEEPER + NPC_FLAGS.VENDOR,
            [npcKeys.friendlyToFaction] = "AH",
        })
        mock.SetBaseRow("Npc", 2001, {[npcKeys.name] = "Smith Argus", [npcKeys.subName] = "Blacksmithing Trainer"})
        mock.SetBaseRow("Npc", 2002, {[npcKeys.name] = "Riding Instructor", [npcKeys.subName] = "Riding Trainer"})
        mock.SetBaseRow("Npc", 2003, {[npcKeys.name] = "Woo Ping", [npcKeys.subName] = "Weapon Master"})
        mock.SetBaseRow("Npc", 4001, {[npcKeys.name] = "Warrior Trainer"})
        mock.SetBaseRow("Npc", 4002, {[npcKeys.name] = "Druid Trainer"})
        mock.SetBaseRow("Npc", 5001, {[npcKeys.name] = "Spirit Healer", [npcKeys.npcFlags] = NPC_FLAGS.SPIRIT_HEALER})
        mock.SetBaseRow("Npc", 8001, {[npcKeys.name] = "Neutral Vendor", [npcKeys.npcFlags] = NPC_FLAGS.VENDOR, [npcKeys.friendlyToFaction] = "AH"})
        mock.SetBaseRow("Npc", 8002, {[npcKeys.name] = "Alliance Vendor", [npcKeys.npcFlags] = NPC_FLAGS.VENDOR, [npcKeys.friendlyToFaction] = "A"})
        mock.SetBaseRow("Npc", 8003, {[npcKeys.name] = "Not A Vendor", [npcKeys.npcFlags] = 0, [npcKeys.friendlyToFaction] = "AH"})
        mock.SetBaseRow("Npc", 8004, {[npcKeys.name] = "High Level Vendor", [npcKeys.npcFlags] = NPC_FLAGS.VENDOR, [npcKeys.friendlyToFaction] = "H"})

        -- Items
        mock.SetBaseRow("Item", 7001, {[itemKeys.name] = "Haunch of Meat", [itemKeys.foodType] = 1})
        mock.SetBaseRow("Item", 7002, {[itemKeys.name] = "Raw Brilliant Smallfish", [itemKeys.foodType] = 2})
        mock.SetBaseRow("Item", 7003, {[itemKeys.name] = "Linen Cloth"})
        mock.SetBaseRow("Item", 17031, {[itemKeys.name] = "Rune of Teleportation", [itemKeys.vendors] = {8001, 8002, 8003}})
        mock.SetBaseRow("Item", 159, {[itemKeys.name] = "Refreshing Spring Water", [itemKeys.vendors] = {8001}, [itemKeys.requiredLevel] = 50})
        mock.SetBaseRow("Item", 9999, {[itemKeys.name] = "Future Water", [itemKeys.vendors] = {8004}, [itemKeys.requiredLevel] = 61})

        -- Objects
        mock.SetBaseRow("Object", 6001, {[objectKeys.name] = "Mailbox", [objectKeys.factionID] = 0})

        _BindComposedReads()
    end)

    after_each(function()
        Expansions.Current = originalExpansion
        Questie.IsClassic = originalIsClassic
        _G.UnitLevel = originalUnitLevel
    end)

    describe("Initialize", function()
        it("collects townsfolk by NPC flag, requiring a sub-name for bankers and skipping [DND] NPCs", function()
            _RunInitialize()

            local townsfolk = Townsfolk.townsfolk
            assert.are_same({1001}, townsfolk["Repair"])
            assert.are_same({1002}, townsfolk["Banker"])
            assert.are_same({1005}, townsfolk["Innkeeper"])
            assert.are_same({}, townsfolk["Auctioneer"])
            assert.is_nil(townsfolk["Barber"])
        end)

        it("collects profession trainers and weapon masters from the curated list present in the database", function()
            _RunInitialize()

            assert.are_same({2001}, Townsfolk.professionTrainers[professionKeys.BLACKSMITHING])
            assert.is_nil(Townsfolk.professionTrainers[professionKeys.RIDING])
            assert.are_same({2003}, Townsfolk.townsfolk["Weapon Master"])
        end)

        it("adds the hand-maintained trainer IDs for the flavor without checking the database", function()
            _RunInitialize()

            local professionTrainers = Townsfolk.professionTrainers
            assert.are_same({2805, 13476}, professionTrainers[professionKeys.FIRST_AID])
            assert.is_nil(professionTrainers[professionKeys.JEWELCRAFTING])
        end)

        it("keeps only class trainers present in the database and adds the class-specific extras", function()
            _RunInitialize()

            local classSpecific = Townsfolk.classSpecificTownsfolk
            assert.are_same({4001}, classSpecific.WARRIOR["Class Trainer"])
            assert.are_same({4002}, classSpecific.DRUID["Class Trainer"])
            assert.is_true(#classSpecific.MAGE["Portal Trainer"] > 0)
            assert.are_same({}, classSpecific.HUNTER["Stable Master"])
        end)

        it("assigns spirit healers and neutral mailboxes to both factions", function()
            _RunInitialize()

            local factionSpecific = Townsfolk.factionSpecificTownsfolk
            assert.are_same({5001}, factionSpecific.Horde["Spirit Healer"])
            assert.are_same({5001}, factionSpecific.Alliance["Spirit Healer"])
            assert.are_same({6001}, factionSpecific.Horde["Mailbox"])
            assert.are_same({6001}, factionSpecific.Alliance["Mailbox"])
        end)

        it("groups pet food Items by food type", function()
            _RunInitialize()

            local petFood = Townsfolk.petFoodVendorTypes
            assert.are_same({7001}, petFood["Meat"])
            assert.are_same({7002}, petFood["Fish"])
            assert.are_same({}, petFood["Cheese"])
        end)
    end)

    describe("BuildCharacterTownsfolk", function()
        it("copies the player's faction and class townsfolk into the character table", function()
            _RunInitialize()

            Townsfolk:BuildCharacterTownsfolk()

            assert.are_same("DRUID", Questie.db.char.townsfolkClass)
            assert.are_same({5001}, Questie.db.char.townsfolk["Spirit Healer"])
            assert.are_same({6001}, Questie.db.char.townsfolk["Mailbox"])
            assert.are_same({4002}, Questie.db.char.townsfolk["Class Trainer"])
            assert.are_same({}, Questie.db.char.vendorList)
        end)
    end)

    describe("PopulateVendors", function()
        it("keeps vendors that carry the vendor flag and are friendly to the player's faction", function()
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

    describe("GetFactionSpecificMailboxes", function()
        local factionIds = {
            InvalidFaction = 0,
            NeutralFaction1 = 1,
            NeutralFaction2 = 2,
            NeutralFaction3 = 3,
            HordeFaction1 = 4,
            HordeFaction2 = 5,
            NeutralFaction4 = 6,
            NeutralFaction5 = 7,
            AllianceFaction1 = 8,
            AllianceFaction2 = 9,
        }

        before_each(function()
            QuestieDB.factionTemplate = {
                [factionIds.NeutralFaction1] = 1,
                [factionIds.HordeFaction1] = 2,
                [factionIds.HordeFaction2] = 3,
                [factionIds.AllianceFaction1] = 4,
                [factionIds.AllianceFaction2] = 5,
                [factionIds.NeutralFaction4] = 6,
                [factionIds.NeutralFaction5] = 12,
                [factionIds.NeutralFaction3] = 16,
            }
            local objectFactions = {
                [1] = factionIds.NeutralFaction1,
                [2] = factionIds.NeutralFaction2,
                [3] = factionIds.NeutralFaction3,
                [4] = factionIds.HordeFaction1,
                [5] = factionIds.HordeFaction2,
                [6] = factionIds.NeutralFaction4,
                [7] = factionIds.NeutralFaction5,
                [8] = factionIds.AllianceFaction1,
                [9] = factionIds.AllianceFaction2,
            }
            for objectId, factionId in pairs(objectFactions) do
                mock.SetBaseRow("Object", objectId, {[objectKeys.name] = "Mailbox", [objectKeys.factionID] = factionId})
            end
            _BindComposedReads()
        end)

        it("should correctly filter mailboxes by faction", function()
            Townsfolk.GetMailboxes = function()
                return {1, 2, 3, 4, 5, 6, 7, 8, 9}
            end

            local allianceMailboxes, hordeMailboxes = Townsfolk.GetFactionSpecificMailboxes()

            assert.are_same({1, 2, 3, 6, 7, 8, 9}, allianceMailboxes)
            assert.are_same({1, 2, 3, 4, 5, 6, 7}, hordeMailboxes)
        end)

        it("should not add mailboxes missing from the composed database", function()
            Townsfolk.GetMailboxes = function()
                return {10, 11, 12}
            end

            local allianceMailboxes, hordeMailboxes = Townsfolk.GetFactionSpecificMailboxes()

            assert.are_same({}, allianceMailboxes)
            assert.are_same({}, hordeMailboxes)
        end)
    end)
end)
