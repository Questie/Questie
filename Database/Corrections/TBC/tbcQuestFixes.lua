---@class QuestieTBCQuestFixes
local QuestieTBCQuestFixes = QuestieLoader:CreateModule("QuestieTBCQuestFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function QuestieTBCQuestFixes:Load()
    table.insert(QuestieDB.questData, 63866, {}) -- Claiming the Light
    -- Alliance boosted quests
    table.insert(QuestieDB.questData, 64028, {}) -- A New Beginning
    table.insert(QuestieDB.questData, 64031, {}) -- Tools for Survival
    table.insert(QuestieDB.questData, 64034, {}) -- Combat Training
    table.insert(QuestieDB.questData, 64035, {}) -- Talented
    table.insert(QuestieDB.questData, 64037, {}) -- Eastern Plaguelands
    table.insert(QuestieDB.questData, 64038, {}) -- The Dark Portal
    -- Horde boosted quests
    table.insert(QuestieDB.questData, 64046, {}) -- A New Beginning
    table.insert(QuestieDB.questData, 64047, {}) -- A New Beginning
    table.insert(QuestieDB.questData, 64048, {}) -- Tools for Survival
    table.insert(QuestieDB.questData, 64049, {}) -- Tools for Survival
    table.insert(QuestieDB.questData, 64050, {}) -- Combat Training
    table.insert(QuestieDB.questData, 64051, {}) -- Combat Training
    table.insert(QuestieDB.questData, 64052, {}) -- Talented
    table.insert(QuestieDB.questData, 64053, {}) -- Talented
    table.insert(QuestieDB.questData, 64063, {}) -- The Dark Portal
    table.insert(QuestieDB.questData, 64217, {}) -- The Dark Portal
    table.insert(QuestieDB.questData, 64064, {}) -- Eastern Plaguelands


    local questKeys = QuestieDB.questKeys
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
        [62] = {
            [questKeys.triggerEnd] = {"Scout through the Fargodeep Mine", {[zoneIDs.ELWYNN_FOREST]={{40.01,81.42},},}},
        },
        [76] = {
            [questKeys.triggerEnd] = {"Scout through the Jasperlode Mine", {[zoneIDs.ELWYNN_FOREST]={{60.53,50.18},},}},
        },
        [155] = {
            [questKeys.triggerEnd] = {"Escort The Defias Traitor to discover where VanCleef is hiding", {[zoneIDs.WESTFALL]={{42.55,71.53},},}},
        },
        [201] = {
            [questKeys.triggerEnd] = {"Locate the hunters' camp", {[zoneIDs.STRANGLETHORN_VALE]={{35.73,10.82},},}},
        },
        [287] = {
            [questKeys.triggerEnd] = {"Fully explore Frostmane Hold", {[zoneIDs.DUN_MOROGH]={{21.47,52.2},},}},
        },
        [455] = {
            [questKeys.triggerEnd] = {"Traverse Dun Algaz", {[zoneIDs.WETLANDS]={{53.49,70.36},},}},
        },
        [460] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [503] = {
            [questKeys.triggerEnd] = {"Find where Gol'dir is being held", {[zoneIDs.ALTERAC_VALLEY]={{60.58,43.86},},}},
        },
        [578] = {
            [questKeys.triggerEnd] = {"Locate the haunted island", {[zoneIDs.STRANGLETHORN_VALE]={{21.56,21.98},},}},
        },
        [663] = {
            [questKeys.requiredLevel] = 35,
        },
        [748] = {
            [questKeys.requiredRaces] = raceIDs.TAUREN,
        },
        [870] = {
            [questKeys.triggerEnd] = {"Explore the waters of the Forgotten Pools", {[zoneIDs.THE_BARRENS]={{45.06,22.56},},}},
        },
        [927] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [968] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [1448] = {
            [questKeys.triggerEnd] = {"Search for the Temple of Atal'Hakkar", {[zoneIDs.SWAMP_OF_SORROWS]={{64.67,48.82},{64.36,56.12},{64.09,51.95},{69.6,44.18},{73.97,46.36},},}},
        },
        [1699] = {
            [questKeys.triggerEnd] = {"Enter the Rethban Caverns", {[zoneIDs.REDRIDGE_MOUNTAINS]={{19.22,25.25},},}},
        },
        [1719] = {
            [questKeys.triggerEnd] = {"Step on the grate to begin the Affray", {[zoneIDs.THE_BARRENS]={{68.61,48.72},},}},
        },
        [2240] = {
            [questKeys.triggerEnd] = {"Explore the Hidden Chamber", {[zoneIDs.BADLANDS]={{35.22,10.32},},}},
        },
        [2842] = {
            [questKeys.requiredLevel] = 20,
        },
        [2989] = {
            [questKeys.triggerEnd] = {"Search the Altar of Zul", {[zoneIDs.THE_HINTERLANDS]={{48.86,68.42},},}},
        },
        [3117] = {
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [3505] = {
            [questKeys.triggerEnd] = {"Find Magus Rimtori's camp", {[zoneIDs.AZSHARA]={{59.29,31.21},},}},
        },
        [4740] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [4842] = {
            [questKeys.triggerEnd] = {"Discover Darkwhisper Gorge", {[zoneIDs.WINTERSPRING]={{60.1,73.44},},}},
        },
        [5401] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [5405] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [6025] = {
            [questKeys.triggerEnd] = {"Overlook Hearthglen from a high vantage point", {[zoneIDs.WESTERN_PLAGUELANDS]={{45.7,18.5},},}},
        },
        [6185] = {
            [questKeys.triggerEnd] = {"The Blightcaller Uncovered", {[zoneIDs.EASTERN_PLAGUELANDS]={{27.4,75.14},},}},
        },
        [6341] = {
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [6342] = {
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [6343] = {
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [6344] = {
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [6421] = {
            [questKeys.triggerEnd] = {"Investigate Cave in Boulderslide Ravine", {[zoneIDs.STONETALON_MOUNTAINS]={{58.96,90.16},},}},
        },
        [6761] = {
            [questKeys.preQuestSingle] = {1015,1019,1047,},
        },
        [7863] = {
            [questKeys.requiredMinRep] = {890,3000}
        },
        [7864] = {
            [questKeys.requiredMinRep] = {890,9000}
        },
        [7865] = {
            [questKeys.requiredMinRep] = {890,21000}
        },
        [7866] = {
            [questKeys.requiredMinRep] = {889,3000}
        },
        [7867] = {
            [questKeys.requiredMinRep] = {889,9000}
        },
        [7868] = {
            [questKeys.requiredMinRep] = {889,21000}
        },
        [8151] = {
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [8325] = {
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8326] = {
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8327] = {
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8328] = {
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8330] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8334] = {
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8335] = {
             [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8336] = {
             [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8338] = {
            [questKeys.startedBy] = {{15298},nil,{20483,},},
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8344] = {
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8345] = {
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8346] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{15294,15274,},15274,"Mana Tap creature"}},
        },
        [8347] = {
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8367] = {
            [questKeys.requiredLevel] = 61,
        },
        [8371] = {
            [questKeys.requiredLevel] = 61,
        },
        [8473] = {
            [questKeys.preQuestSingle] = {},
        },
        [8476] = {
            [questKeys.preQuestSingle] = {},
        },
        [8482] = {
            [questKeys.startedBy] = {{15968},nil,{20765,},},
        },
        [8487] = {
            [questKeys.preQuestSingle] = {},
        },
        [8488] = {
            [questKeys.triggerEnd] = {"Protect Apprentice Mirveda", {[zoneIDs.EVERSONG_WOODS]={{54.3,71.02},},}},
        },
        [8490] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Place the Infused Crystal and protect it from the Scourge for 1 minute", 0, {{"object", 181164}}}}
        },
        [8548] = {
            [questKeys.specialFlags] = 1,
        },
        [8572] = {
            [questKeys.specialFlags] = 1,
        },
        [8573] = {
            [questKeys.specialFlags] = 1,
        },
        [8574] = {
            [questKeys.specialFlags] = 1,
        },
        [8894] = {
            [questKeys.preQuestSingle] = {},
        },
        [9144] = {
            [questKeys.requiredLevel] = 10,
        },
        [9149] = {
            [questKeys.preQuestSingle] = {9327},
        },
        [8474] = {
            [questKeys.startedBy] = {{15409},nil,{23228,},},
        },
        [8484] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [9130] = {
            [questKeys.requiredMinRep] = {},
        },
        [9152] = {
            [questKeys.preQuestSingle] = {9327,9329},
        },
        [9160] = {
            [questKeys.triggerEnd] = {"Investigate An'daroth", {[zoneIDs.GHOSTLANDS]={{37.13,16.15},},}},
        },
        [9161] = {
            [questKeys.preQuestSingle] = {},
        },
        [9174] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, "Use the Bundle of Medallions", 0, {{"object", 181157}}}},
        },
        [9193] = {
            [questKeys.triggerEnd] = {"Investigate the Amani Catacombs", {[zoneIDs.GHOSTLANDS]={{62.91,30.98},},}},
        },
        [9212] = {
            [questKeys.triggerEnd] = {"Escort Ranger Lilatha back to the Farstrider Enclave", {[zoneIDs.GHOSTLANDS]={{72.24,30.21},},}},
        },
        [9280] = {
            [questKeys.preQuestSingle] = {},
        },
        [9288] = {
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [9303] = {
            [questKeys.objectives] = {{{16518,"Nestlewood Owlkin inoculated"}},nil,nil,nil},
        },
        [9355] = {
            [questKeys.preQuestSingle] = {10143,10483,},
        },
        [9360] = {
            [questKeys.startedBy] = {{15407},nil,{23249,},},
        },
        [9375] = {
            [questKeys.triggerEnd] = {"Escort Wounded Blood Elf Pilgrim to Falcon Watch", {[zoneIDs.HELLFIRE_PENINSULA]={{27.09,61.92},},}},
        },
        [9400] = {
            [questKeys.triggerEnd] = {"Find Krun Spinebreaker", {[zoneIDs.HELLFIRE_PENINSULA]={{33.59,43.62},},}},
        },
        [9410] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Use the Wolf Totem at the location where you found Krun Spinebreaker's body and follow the Ancestral Spirit Wolf.", 0, {{"object", 181630}}}},
        },
        [9417] = {
            [questKeys.preQuestSingle] = {},
        },
        [9418] = {
            [questKeys.startedBy] = {{17084},nil,{23580,},},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, "Take Avruu's Orb to the Haal'eshi Altar", 0, {{"object", 181606}}}},
        },
        [9421] = {
            [questKeys.preQuestSingle] = {9280,9369},
        },
        [9428] = {
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9429] = {
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [9433] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Use the Robotron Control and navigate it to Thalanaar", 0, {{"object", 181631}}}},
        },
        [9446] = {
            [questKeys.triggerEnd] = {"Escort Anchorite Truuen to Uther's Tomb", {[zoneIDs.WESTERN_PLAGUELANDS]={{52.06,83.26},},}},
        },
        [9449] = {
            [questKeys.questLevel] = 4,
        },
        [9450] = {
            [questKeys.questLevel] = 4,
        },
        [9451] = {
            [questKeys.questLevel] = 4,
        },
        [9454] = {
            [questKeys.preQuestSingle] = {},
        },
        [9457] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Use the Gift of Naias near the Altar of Naias", 0, {{"object", 181636}}}}
        },
        [9461] = {
            [questKeys.questLevel] = 10,
        },
        [9462] = {
            [questKeys.questLevel] = 10,
        },
        [9464] = {
            [questKeys.questLevel] = 10,
        },
        [9465] = {
            [questKeys.questLevel] = 10,
        },
        [9467] = {
            [questKeys.questLevel] = 10,
        },
        [9468] = {
            [questKeys.questLevel] = 10,
        },
        [9472] = {
            [questKeys.requiredSourceItems] = {29112},
        },
        [9484] = {
            [questKeys.triggerEnd] = {"Tame a Crazed Dragonhawk", {[zoneIDs.EVERSONG_WOODS]={{60.39,59.09},{61.23,65.08},},}},
        },
        [9485] = {
            [questKeys.triggerEnd] = {"Tame a Mistbat", {[zoneIDs.GHOSTLANDS]={{48.29,13.42},{55.22,11.22},{50.59,15.86},},}},
        },
        [9486] = {
            [questKeys.triggerEnd] = {"Tame an Elder Springpaw", {[zoneIDs.EVERSONG_WOODS]={{61.95,64.61},{64.77,59.93},},}},
        },
        [9489] = {
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9500] = {
            [questKeys.questLevel] = 20,
        },
        [9501] = {
            [questKeys.questLevel] = 20,
        },
        [9502] = {
            [questKeys.questLevel] = 20,
        },
        [9503] = {
            [questKeys.questLevel] = 20,
        },
        [9504] = {
            [questKeys.questLevel] = 20,
        },
        [9508] = {
            [questKeys.questLevel] = 20,
        },
        [9509] = {
            [questKeys.questLevel] = 20,
        },
        [9527] = {
            [questKeys.preQuestSingle] = {},
        },
        [9528] = {
            [questKeys.triggerEnd] = {"Magwin Escorted to Safety", {[zoneIDs.AZUREMYST_ISLE]={{16.38,94.14},},}},
        },
        [9531] = {
            [questKeys.objectives] = {{{17318,"The Traitor Uncovered"},},nil,nil,},
        },
        [9538] = {
            [questKeys.triggerEnd] = {"Stillpine Furbolg Language Primer Read", {[zoneIDs.AZUREMYST_ISLE]={{49.29,51.07},},}},
        },
        [9544] = {
            [questKeys.requiredSourceItems] = {23801},
        },
        [9545] = {
            [questKeys.objectives] = {{{16852,"Vision Granted"},},nil,nil,nil,},
        },
        [9547] = {
            [questKeys.questLevel] = 30,
        },
        [9549] = {
            [questKeys.preQuestSingle] = {},
        },
        [9551] = {
            [questKeys.questLevel] = 30,
        },
        [9552] = {
            [questKeys.questLevel] = 30,
        },
        [9553] = {
            [questKeys.questLevel] = 30,
        },
        [9554] = {
            [questKeys.questLevel] = 30,
        },
        [9555] = {
            [questKeys.questLevel] = 10,
        },
        [9558] = {
            [questKeys.preQuestSingle] = {10143,10483},
        },
        [9560] = {
            [questKeys.preQuestSingle] = {9544},
        },
        [9562] = {
            [questKeys.preQuestSingle] = {9544},
        },
        [9564] = {
            [questKeys.startedBy] = {{17475},nil,{23850,},},
            [questKeys.preQuestSingle] = {9559},
        },
        [9565] = {
            [questKeys.preQuestGroup] = {},
            [questKeys.preQuestSingle] = {9562},
        },
        [9575] = {
            [questKeys.preQuestSingle] = {10143,10483,},
        },
        [9576] = {
            [questKeys.startedBy] = {{17496},nil,{23870,},},
        },
        [9591] = {
            [questKeys.triggerEnd] = {"Tame a Barbed Crawler", {[zoneIDs.AZUREMYST_ISLE]={{20.29,64.87},{22.04,72.29},{20.57,68.9},},}},
        },
        [9592] = {
            [questKeys.triggerEnd] = {"Tame a Greater Timberstrider", {[zoneIDs.AZUREMYST_ISLE]={{36.46,35.49},{35.16,30.99},{40.27,37.65},{40.25,32.31},},}},
        },
        [9593] = {
            [questKeys.triggerEnd] = {"Tame a Nightstalker", {[zoneIDs.AZUREMYST_ISLE]={{36.41,40.24},{35.82,37.14},},}},
        },
        [9594] = {
            [questKeys.startedBy] = {{17528},nil,{23900,},},
        },
        [9607] = {
            [questKeys.triggerEnd] = {"Fully Investigate The Blood Furnace", {[zoneIDs.HELLFIRE_PENINSULA]={{45.89,51.93},},}},
        },
        [9608] = {
            [questKeys.triggerEnd] = {"Fully Investigate The Blood Furnace", {[zoneIDs.HELLFIRE_PENINSULA]={{45.89,51.93},},}},
        },
        [9635] = {
            [questKeys.requiredSkill] = {202,305},
        },
        [9636] = {
            [questKeys.requiredSkill] = {202,305},
        },
        [9645] = {
            [questKeys.triggerEnd] = {"Journal Entry Read", {[zoneIDs.DEADWIND_PASS]={{46.57,70.49},{46.77,74.5},},}},
        },
        [9663] = {
            [questKeys.objectives] = {{{17440,"High Chief Stillpine Warned"},{40000,"Exarch Menelaous Warned"},{40001,"Admiral Odesyus Warned"},},nil,nil,nil,},
        },
        [9666] = {
            [questKeys.triggerEnd] = {"Declaration of Power", {[zoneIDs.BLOODMYST_ISLE]={{68.52,67.88},},}},
        },
        [9667] = {
            [questKeys.objectives] = {{{17682,"Princess Stillpine Saved"},},nil,nil,nil,},
            [questKeys.requiredSourceItems] = {24099,40001},
            [questKeys.preQuestSingle] = {9559},
        },
        [9669] = {
            [questKeys.requiredLevel] = 16,
        },
        [9670] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{17681,17680},17681,"Expedition Researcher Freed"},},
        },
        [9671] = {
            [questKeys.requiredLevel] = 15,
        },
        [9672] = {
            [questKeys.startedBy] = {nil,{400000},nil},
        },
        [9678] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, "Light the brazier", 0, {{"object", 181956}}}},
        },
        [9686] = {
            [questKeys.triggerEnd] = {"Complete the Second Trial", {[zoneIDs.EVERSONG_WOODS]={{43.34,28.7},},}},
        },
        [9697] = {
            [questKeys.requiredMinRep] = {942,3000},
        },
        [9700] = {
            [questKeys.triggerEnd] = {"Sun Portal Site Confirmed", {[zoneIDs.BLOODMYST_ISLE]={{52.92,22.32},},}},
        },
        [9701] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.triggerEnd] = {"Investigate the Spawning Glen", {[zoneIDs.ZANGARMARSH]={{15.1,61.21},},}},
            [questKeys.requiredLevel] = 61,
        },
        [9704] = {
            [questKeys.preQuestSingle] = {},
        },
        [9711] = {
            [questKeys.triggerEnd] = {"Matis the Cruel Captured", {[zoneIDs.BLOODMYST_ISLE]={{-1,-1},},}}, -- We don't want to use the objective data, since the fake item has waypoints
            [questKeys.requiredSourceItems] = {40002},
        },
        [9716] = {
            [questKeys.triggerEnd] = {"Umbrafen Lake Investigated", {[zoneIDs.ZANGARMARSH]={{70.89,80.51},},}},
        },
        [9718] = {
            [questKeys.triggerEnd] = {"Use the Stormcrow Amulet and explore the lakes of Zangarmarsh", {[zoneIDs.ZANGARMARSH]={{78.4,62.02},},}},
        },
        [9728] = {
            [questKeys.preQuestSingle] = {},
        },
        [9729] = {
            [questKeys.triggerEnd] = {"Ark of Ssslith safely returned to Sporeggar", {[zoneIDs.ZANGARMARSH]={{19.71,50.72},},}},
        },
        [9731] = {
            [questKeys.triggerEnd] = {"Drain Located", {[zoneIDs.ZANGARMARSH]={{50.44,40.91},},}},
        },
        [9738] = {
            [questKeys.preQuestSingle] = {},
        },
        [9739] = {
            [questKeys.requiredMinRep] = {},
            [questKeys.requiredMaxRep] = {},
        },
        [9740] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, "Destroy all 4 Sunhawk Portal Controller", 0, {{"object", 184850}}}},
        },
        [9743] = {
            [questKeys.requiredMinRep] = {},
            [questKeys.requiredMaxRep] = {},
        },
        [9752] = {
            [questKeys.triggerEnd] = {"Escort Kayra Longmane to safety", {[zoneIDs.ZANGARMARSH]={{79.76,71.09},},}},
        },
        [9753] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [9756] = {
            [questKeys.objectives] = {{{17824,"Sunhawk Information Recovered"},},nil,nil,nil,},
        },
        [9757] = {
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [9759] = {
            [questKeys.preQuestSingle] = {9756},
            [questKeys.triggerEnd] = {"Vector Coil Destroyed and Sironas Slain", {[zoneIDs.BLOODMYST_ISLE]={{14.86,54.84},},}},
        },
        [9760] = {
            [questKeys.exclusiveTo] = {9759},
        },
        [9786] = {
            [questKeys.triggerEnd] = {"Explore the Boha'mu Ruins", {[zoneIDs.ZANGARMARSH]={{44.13,68.97},},}},
        },
        [9796] = {
            [questKeys.requiredLevel] = 62,
            [questKeys.exclusiveTo] = {10105},
        },
        [9798] = {
            [questKeys.startedBy] = {{16522},nil,{24414}},
        },
        [9802] = {
            [questKeys.requiredMaxRep] = {},
        },
        [9808] = {
            [questKeys.requiredMinRep] = {970,0},
        },
        [9830] = {
            [questKeys.requiredMinRep] = {978,0},
        },
        [9833] = {
            [questKeys.requiredMinRep] = {978,0},
        },
        [9834] = {
            [questKeys.requiredMinRep] = {978,0},
        },
        [9836] = {
            [questKeys.triggerEnd] = {"Master's Touch", {[zoneIDs.TANARIS]={{57.21,62.95},},}},
        },
        [9847] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Plant the Feralfen Totem on the ground", 0, {{"object", 182176}}}}
        },
        [9849] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Use Gordawg's Boulder to shatter Shattered Rumblers into Minions of Gurok", 0, {{"monster", 17157}}}}
        },
        [9853] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Use 7 Warmaul Skulls to summon Gurok the Usurper", 0, {{"object", 182182}}}},
        },
        [9863] = {
            [questKeys.requiredMinRep] = {941,0},
        },
        [9864] = {
            [questKeys.requiredMinRep] = {941,0},
        },
        [9867] = {
            [questKeys.requiredMinRep] = {941,0},
        },
        [9868] = {
            [questKeys.triggerEnd] = {"Free the Mag'har Captive", {[zoneIDs.NAGRAND]={{31.77,38.78},},}},
            [questKeys.requiredMinRep] = {941,0},
        },
        [9869] = {
            [questKeys.requiredMinRep] = {978,0},
        },
        [9871] = {
            [questKeys.startedBy] = {{18238},nil,{24559,},},
        },
        [9872] = {
            [questKeys.startedBy] = {{18238},nil,{24558,},},
        },
        [9874] = {
            [questKeys.requiredMinRep] = {978,0},
        },
        [9878] = {
            [questKeys.requiredMinRep] = {978,0},
        },
        [9879] = {
            [questKeys.requiredMinRep] = {978,0},
            [questKeys.triggerEnd] = {"Free the Kurenai Captive", {[zoneIDs.NAGRAND]={{31.59,38.78},},}},
        },
        [9889] = {
            [questKeys.triggerEnd] = {"Unkor Submits", {[zoneIDs.TEROKKAR_FOREST]={{20.02,63.05},},}},
        },
        [9902] = {
            [questKeys.requiredMinRep] = {978,0},
        },
        [9905] = {
            [questKeys.requiredMinRep] = {978,0},
        },
        [9911] = {
            [questKeys.startedBy] = {{18285},nil,{25459,},},
        },
        [9913] = {
            [questKeys.exclusiveTo] = {9882},
        },
        [9923] = {
            [questKeys.requiredMinRep] = {978,0},
            [questKeys.requiredSourceItems] = {25490},
        },
        [9924] = {
            [questKeys.requiredSourceItems] = {25509},
        },
        [9927] = {
            [questKeys.preQuestSingle] = {10107,10108},
        },
        [9928] = {
            [questKeys.preQuestSingle] = {10107,10108},
        },
        [9931] = {
            [questKeys.preQuestGroup] = {9927,9928,},
        },
        [9932] = {
            [questKeys.preQuestGroup] = {9927,9928,},
        },
        [9933] = {
            [questKeys.preQuestGroup] = {9931,9932,},
        },
        [9934] = {
            [questKeys.preQuestGroup] = {9931,9932,},
        },
        [9935] = {
            [questKeys.requiredMinRep] = {941,0},
        },
        [9936] = {
            [questKeys.requiredMinRep] = {978,0},
        },
        [9939] = {
            [questKeys.requiredMinRep] = {941,0},
        },
        [9940] = {
            [questKeys.requiredMinRep] = {978,0},
        },
        [9944] = {
            [questKeys.requiredMinRep] = {941,0},
        },
        [9948] = {
            [questKeys.requiredMinRep] = {941,0},
        },
        [9955] = {
            [questKeys.requiredSourceItems] = {25648},
        },
        [9956] = {
            [questKeys.requiredMinRep] = {978,0},
        },
        [9957] = {
            [questKeys.requiredMinRep] = {942,3000},
        },
        [9962] = {
            [questKeys.triggerEnd] = {"Brokentoe Defeated", {[zoneIDs.NAGRAND]={{43.32,20.72},},}},
        },
        [9967] = {
            [questKeys.triggerEnd] = {"The Blue Brothers Defeated", {[zoneIDs.NAGRAND]={{43.26,20.76},},}},
        },
        [9970] = {
            [questKeys.triggerEnd] = {"Rokdar the Sundered Lord Defeated", {[zoneIDs.NAGRAND]={{43.34,20.71},},}},
        },
        [9972] = {
            [questKeys.triggerEnd] = {"Skra'gath Defeated", {[zoneIDs.NAGRAND]={{43.26,20.77},},}},
        },
        [9973] = {
            [questKeys.triggerEnd] = {"The Warmaul Champion Defeated", {[zoneIDs.NAGRAND]={{43.37,20.69},},}},
        },
        [9977] = {
            [questKeys.triggerEnd] = {"Mogor, Hero of the Warmaul Defeated", {[zoneIDs.NAGRAND]={{43.31,20.72},},}},
        },
        [9982] = {
            [questKeys.requiredMinRep] = {978,0},
            [questKeys.exclusiveTo] = {9991},
        },
        [9983] = {
            [questKeys.exclusiveTo] = {9991},
        },
        [9991] = {
            [questKeys.triggerEnd] = {"Forge Camps Surveyed", {[zoneIDs.NAGRAND]={{27.22,43.05},},}},
            [questKeys.preQuestSingle] = {},
        },
        [10000] = {
            [questKeys.requiredLevel] = 62,
        },
        [10004] = {
            [questKeys.triggerEnd] = {"Sal'salabim Persuaded", {[zoneIDs.SHATTRATH_CITY]={{76.68,33.96},},}},
        },
        [10012] = {
            [questKeys.preQuestSingle] = {9998,10000},
        },
        [10013] = {
            [questKeys.preQuestSingle] = {9998,10000},
        },
        [10017] = {
            [questKeys.preQuestSingle] = {10211},
            [questKeys.requiredMaxRep]= {932,0},
        },
        [10019] = {
            [questKeys.preQuestSingle] = {10211},
            [questKeys.requiredMaxRep]= {932,0},
        },
        [10024] = {
            [questKeys.preQuestSingle] = {10211},
            [questKeys.requiredMaxRep]= {934,0},
        },
        [10025] = {
            [questKeys.preQuestSingle] = {10211},
            [questKeys.requiredMaxRep]= {934,0},
        },
        [10039] = {
            [questKeys.requiredLevel] = 62,
        },
        [10040] = {
            [questKeys.objectives] = {{{18716,"Shadowy Initiate Spoken To"},{18717,"Shadowy Laborer Spoken To"},{18719,"Shadowy Advisor Spoken To"},},nil,nil,nil,},
        },
        [10041] = {
            [questKeys.objectives] = {{{18716,"Shadowy Initiate Spoken To"},{18717,"Shadowy Laborer Spoken To"},{18719,"Shadowy Advisor Spoken To"},},nil,nil,nil,},
        },
        [10044] = {
            [questKeys.triggerEnd] = {"Listen to Greatmother Geyah", {[zoneIDs.NAGRAND]={{56.66,34.31},},}},
        },
        [10047] = {
            [questKeys.preQuestSingle] = {10143,10483,},
        },
        [10050] = {
            [questKeys.preQuestSingle] = {10143,10483,},
        },
        [10051] = {
            [questKeys.triggerEnd] = {"Escort Isla Starmane to safety", {[zoneIDs.TEROKKAR_FOREST]={{67.51,37.28},},}},
        },
        [10052] = {
            [questKeys.triggerEnd] = {"Escort Isla Starmane to safety", {[zoneIDs.TEROKKAR_FOREST]={{67.51,37.28},},}},
        },
        [10058] = {
            [questKeys.preQuestSingle] = {10143,10483,},
        },
        [10063] = {
            [questKeys.exclusiveTo] = {9549},
        },
        [10066] = {
            [questKeys.startedBy] = {{17986,18020},nil,nil,},
        },
        [10067] = {
            [questKeys.startedBy] = {{17986,18020},nil,nil,},
        },
        [10068] = {
            [questKeys.startedBy] = {{15279,},nil,nil,},
            [questKeys.exclusiveTo] = {8330},
            [questKeys.preQuestSingle] = {8328},
        },
        [10069] = {
            [questKeys.startedBy] = {{15280,},nil,nil,},
            [questKeys.exclusiveTo] = {8330},
            [questKeys.preQuestSingle] = {9676},
        },
        [10070] = {
            [questKeys.exclusiveTo] = {8330},
        },
        [10071] = {
            [questKeys.exclusiveTo] = {8330},
        },
        [10072] = {
            [questKeys.exclusiveTo] = {8330},
        },
        [10073] = {
            [questKeys.exclusiveTo] = {8330},
        },
        [10079] = {
            [questKeys.preQuestSingle] = {10143,10483,},
        },
        [10094] = {
            [questKeys.preQuestSingle] = {10211},
            [questKeys.requiredMaxRep]= {934,0},
        },
        [10095] = {
            [questKeys.preQuestSingle] = {10211},
            [questKeys.requiredMaxRep]= {934,0},
        },
        [10097] = {
            [questKeys.requiredMaxRep]= {934,0},
        },
        [10226] = {
            [questKeys.objectives] = {nil,nil,{{28548,"Zap Sundered Rumblers and Warp Aberrations before killing them"},},nil,},
        },
        [10256] = {
            [questKeys.objectives] = {{{19938, "Use the Apex's Crystal Focus near Archmage Vargoth's Orb"},},nil,nil,nil,nil},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, "Use the Apex's Crystal Focus near Archmage Vargoth's Orb", 0, {{"object", 183507}}}},
        },
        [10105] = {
            [questKeys.exclusiveTo] = {9796},
        },
        [10106] = {
            [questKeys.preQuestSingle] = {10143,10483,},
            [questKeys.requiredMaxRep] = {946,41999},
        },
        [10107] = {
            [questKeys.triggerEnd] = {"Hear the Tale of the Blademaster", {[zoneIDs.NAGRAND]={{73.82,62.59},},}},
        },
        [10108] = {
            [questKeys.triggerEnd] = {"Hear the Tale of the Blademaster", {[zoneIDs.NAGRAND]={{73.82,62.59},},}},
        },
        [10190] = {
            [questKeys.objectives] = {{{18879,"Battery Charge Level"},},nil,nil,nil,},
        },
        [10110] = {
            [questKeys.preQuestSingle] = {10124},
        },
        [10113] = {
            [questKeys.exclusiveTo] = {9854,9857,9789},
            [questKeys.requiredLevel] = 64,
        },
        [10114] = {
            [questKeys.exclusiveTo] = {9854,9857,9789},
        },
        [10129] = {
            [questKeys.requiredSourceItems] = {40000},
        },
        [10146] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Speak with Wing Commander Dabir'ee", 0, {{"monster", 19409}}}},
        },
        [10162] = {
            [questKeys.requiredSourceItems] = {40000},
        },
        [10163] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Speak with Wing Commander Gryphongar", 0, {{"monster", 20232}}}},
        },
        [10172] = {
            [questKeys.triggerEnd] = {"Speak to Greatmother Geyah", {[zoneIDs.NAGRAND]={{56.66,34.31},},}},
        },
        [10183] = {
            [questKeys.exclusiveTo] = {11036,11037,11038,11039,11040,11042,},
        },
        [10191] = {
            [questKeys.triggerEnd] = {"Escort the Maxx A. Million Mk. V safely through the Ruins of Enkaat", {[zoneIDs.NETHERSTORM]={{31.54,56.47},},}},
        },
        [10198] = {
            [questKeys.triggerEnd] = {"Information Gathering", {[zoneIDs.NETHERSTORM]={{48.18,84.08},},}},
        },
        [10204] = {
            [questKeys.triggerEnd] = {"Siphon Bloodgem Crystal", {[zoneIDs.NETHERSTORM]={{25.42,66.51},{22.37,65.73},},}},
            [questKeys.requiredSourceItems] = {28452},
        },
        [10211] = {
            [questKeys.triggerEnd] = {"City of Light", {[zoneIDs.SHATTRATH_CITY]={{50.45,42.93},},}},
        },
        [10218] = {
            [questKeys.triggerEnd] = {"Escort Cryo-Engineer Sha'heen", {[zoneIDs.TEROKKAR_FOREST]={{39.62,57.57},},}},
        },
        [10120] = {
            [questKeys.preQuestSingle] = {},
        },
        [10222] = {
            [questKeys.preQuestSingle] = {10188},
        },
        [10274] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Use the Challenge of the Blue Fight to challenge Veraku", 0, {{"object", 184108}}}},
        },
        [10288] = {
            [questKeys.preQuestSingle] = {},
        },
        [10231] = {
            [questKeys.triggerEnd] = {"Beat Down \"Dirty\" Larry and Get Information", {[zoneIDs.SHATTRATH_CITY]={{43.86,27.97},},}},
        },
        [10243] = {
            [questKeys.preQuestSingle] = {10241},
        },
        [10246] = {
            [questKeys.preQuestSingle] = {10299},
        },
        [10250] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Blow the Unyielding Battle Horn near the Alliance Banner", 0, {{"object", 184002 }}}},
        },
        [10255] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Use the Cenarion Antidote on a Hulking Helboar and observe the results", 0, {{"monster", 16880}}}},
        },
        [10263] = {
            [questKeys.preQuestGroup] = {10551,10186},
            [questKeys.requiredMinRep] = {932,3000},
        },
        [10264] = {
            [questKeys.preQuestGroup] = {10552,10186},
            [questKeys.requiredMinRep] = {934,3000},
        },
        [10265] = {
            [questKeys.preQuestSingle] = {},
        },
        [10269] = {
            [questKeys.triggerEnd] = {"First triangulation point discovered", {[zoneIDs.NETHERSTORM]={{66.67,33.85},},}},
        },
        [10275] = {
            [questKeys.triggerEnd] = {"Second triangulation point discovered", {[zoneIDs.NETHERSTORM]={{28.92,41.25},},}},
        },
        [10277] = {
            [questKeys.triggerEnd] = {"Caverns of Time Explained", {[zoneIDs.TANARIS]={{58.87,54.3},},}},
        },
        [10297] = {
            [questKeys.triggerEnd] = {"The Dark Portal Opened", {[zoneIDs.TANARIS]={{57.21,62.92},},}},
        },
        [10302] = {
            [questKeys.preQuestSingle] = {},
        },
        [10310] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.triggerEnd] = {"Burning Legion warp-gate sabotaged", {[zoneIDs.NETHERSTORM]={{48.14,63.38},},}},
        },
        [10325] = {
            [questKeys.preQuestSingle] = {10211},
        },
        [10337] = {
            [questKeys.triggerEnd] = {"Escort Bessy on her way home.", {[zoneIDs.NETHERSTORM]={{57.71,84.97},},}},
        },
        [10340] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Speak with Wing Commander Dabir'ee", 0, {{"monster", 19409}}}},
        },
        [10367] = {
            [questKeys.preQuestSingle] = {},
        },
        [10382] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Speak with Gryphoneer Windbellow", 0, {{"monster", 20235}}}},
        },
        [10388] = {
            [questKeys.startedBy] = {{16576,19273,},nil,nil,},
            [questKeys.preQuestSingle] = {10129},
        },
        [10389] = {
            [questKeys.preQuestSingle] = {10392},
        },
        [10403] = {
            [questKeys.startedBy] = {{20677,20678,20679},nil,nil,},
        },
        [10406] = {
            [questKeys.triggerEnd] = {"Ethereum Conduit Sabotaged", {[zoneIDs.NETHERSTORM]={{56.42,42.66},},}},
        },
        [10409] = {
            [questKeys.triggerEnd] = {"Deathblow to the Legion", {[zoneIDs.NETHERSTORM]={{29.56,14.29},},}},
        },
        [10411] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_SLAY, "Use Navuud's Concoction before attacking the Void Wastes", 0, {{"monster", 20778}}}},
        },
        [10412] = {
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestSingle] = {10211},
        },
        [10422] = {
            [questKeys.requiredSourceItems] = {29742},
        },
        [10424] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Use the Diagnostic Device while standing near the Eco-Dome Sutheron Generator", 0, {{"object", 184609}}}}
        },
        [10425] = {
            [questKeys.triggerEnd] = {"Captured Protectorate Vanguard Escorted", {[zoneIDs.NETHERSTORM]={{58.9,32.43},},}},
        },
        [10426] = {
            [questKeys.objectives] = {{{20774,"Test Energy Modulator"},},nil,nil,nil,},
        },
        [10427] = {
            [questKeys.objectives] = {{{20610,"Talbuk Tagged"},{20777,"Talbuk Tagged"},},nil,nil,nil,},
        },
        [10451] = {
            [questKeys.triggerEnd] = {"Earthmender Wilda Escorted to Safety", {[zoneIDs.SHADOWMOON_VALLEY]={{53.14,25.18},},}},
        },
        [10458] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Use the Totem of Spirits on Enraged Earth and Fiery Spirits", 0, {{"monster", 21050}, {"monster", 21061}}}}
        },
        [10476] = {
            [questKeys.requiredMinRep] = {978,0},
        },
        [10479] = {
            [questKeys.requiredMinRep] = {941,0},
        },
        [10480] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Use the Totem of Spirits on Enraged Water Spirits", 0, {{"monster", 21059}}}},
        },
        [10481] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Use the Totem of Spirits on Enraged Air Spirits", 0, {{"monster", 21060}}}}
        },
        [10488] = {
            [questKeys.objectives] = {{{20748,"Use Gor'drek's Ointment to strengthen the Thunderlord Dire Wolves"},},nil,nil,nil,nil},
        },
        [10490] = {
            [questKeys.questLevel] = 20,
        },
        [10491] = {
            [questKeys.questLevel] = 30,
        },
        [10506] = {
            [questKeys.objectives] = {{{20058,"Apply the Diminution Powder on the Bloodmaul Dire Wolves"},},nil,nil,nil,nil},
        },
        [10512] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{19998,20334,20723,20726,20730,20731,20732,21296,21975,19995,},19995,"Bladespire Ogres drunken"}},
        },
        [10514] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Use Oronok's Boar Whistle to dig up a Shadowmoon Tuber", 0, {{"object", 184701}}}},
        },
        [10518] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Place the Bladespire Banner atop the Northmaul Tower", 0, {{"object", 184704}}}}
        },
        [10519] = {
            [questKeys.triggerEnd] = {"The Cipher of Damnation - History and Truth", {[zoneIDs.SHADOWMOON_VALLEY]={{53.9,23.48},},}},
        },
        [10525] = {
            [questKeys.triggerEnd] = {"Final Thunderlord artifact discovered", {[zoneIDs.BLADES_EDGE_MOUNTAINS]={{52.76,58.89},},}},
        },
        [10540] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.SHADOWMOON_VALLEY]={{30,57}}}, ICON_TYPE_EVENT, "Walk with your Spirit Hunter",}},
        },
        [10545] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{19998,20334,20723,20726,20730,20731,20732,21296,21975,19995,},19995,"Bladespire Ogres drunken"}},
        },
        [10556] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Use the Fistful of Feathers on the Lashh'an Spell Circle and get back to Daranelle", 0, {{"object", 184826}, {"monster", 21469}}}},
        },
        [10557] = {
            -- Since you don't just have to reach the position this triggerEnd does not make much sense as is empty on purpose!
            [questKeys.triggerEnd] = {"Test Tally's Experiment", {}},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Speak with Rally Zapnabber and use the Zephyrium Capacitorium", 0, {{"monster", 21461}}}},
        },
        [10563] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Use the Box o'Tricks while standing near the communication device", 0, {{"object", 184833}}}},
        },
        [10570] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Place the Bundle of Bloodthistle at the end of the bridge", 0, {{"object", 184841}}}},
        },
        [10577] = {
            [questKeys.triggerEnd] = {"Illidan's Message Delivered", {[zoneIDs.SHADOWMOON_VALLEY]={{46.46,71.86},},}},
        },
        [10580] = {
            [questKeys.exclusiveTo] = {10584},
        },
        [10581] = {
            [questKeys.exclusiveTo] = {10584},
        },
        [10584] = {
            [questKeys.objectives] = {{{21729,"Electromentals collected"},{21731,"Electromentals collected"},},nil,nil,nil,},
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, "Open the Power Converters and encase what is inside with the Protovoltaic Magneto Collector", 0, {{"object", 184906}}}}
        },
        [10585] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.SHADOWMOON_VALLEY]={{37,38}}}, ICON_TYPE_EVENT, "Use the Elemental Displacer to disrupt the ritual in the summoning chamber", 0}},
        },
        [10594] = {
            [questKeys.triggerEnd] = {"Singing crystal resonant frequency gauged", {[zoneIDs.BLADES_EDGE_MOUNTAINS]={{59.77,73.83},},}},
        },
        [10606] = {
            [questKeys.requiredSourceItems] = {30712},
        },
        [10609] = {
            -- TODO: Change the ICON_TYPE_OBJECT in the database references, once that is supported. {"monster", 20021} -> {"monster", 20021, ICON_TYPE_SLAY}
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, "Open Nether Drake Eggs and use the Temporal Phase Modulator on whatever hatches", 0, {{"object", 184867}, {"monster", 20021}}}},
        },
        [10629] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Use the Felhound Whistle and kill some Deranged Helboars", 0, {{"monster", 16915}}}},
        },
        [10634] = {
            [questKeys.preQuestSingle] = {10633,10644,},
        },
        [10635] = {
            [questKeys.preQuestSingle] = {10633,10644,},
        },
        [10636] = {
            [questKeys.preQuestSingle] = {10633,10644,},
        },
        [10639] = {
            [questKeys.preQuestGroup] = {10634,10635,10636,},
        },
        [10641] = {
            [questKeys.preQuestSingle] = {10640,10689,}
        },
        [10645] = {
            [questKeys.preQuestGroup] = {10634,10635,10636,},
        },
        [10646] = {
            [questKeys.triggerEnd] = {"Illidan's Pupil", {[zoneIDs.NAGRAND]={{27.36,43.07},},}},
        },
        [10653] = {
            [questKeys.preQuestSingle] = {10211},
        },
        [10656] = {
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestSingle] = {10211},
        },
        [10657] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_SLAY, "Use the Repolarized Magneto Sphere to absorb 25 lightning strikes from the Scalewing Serpents", 0, {{"monster", 20749}}}},
        },
        [10668] = {
            [questKeys.preQuestSingle] = {10640,10689,}
        },
        [10669] = {
            [questKeys.preQuestSingle] = {10640,10689,},
            [questKeys.extraObjectives] = {{{[zoneIDs.ZANGARMARSH]={{15,41}}}, ICON_TYPE_EVENT, "Use the Imbued Silver Spear at Portal Clearing near Marshlight Lake to awake Xeleth"}}
        },
        [10674] = {
            [questKeys.objectives] = {{{20635,"Razaani Light Orbs trapped"},},nil,nil,nil,},
        },
        [10675] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_SLAY, "Kill Razaani ethereals to lure Nexus-Prince Razaan out", 0, {{"monster", 20601}, {"monster", 20609}, {"monster", 20614}}}},
        },
        [10682] = {
            [questKeys.triggerEnd] = {"Negotiations with Overseer Nuaar complete", {[zoneIDs.BLADES_EDGE_MOUNTAINS]={{62.22,31.78},{59.86,40.22},{59.46,35.84},},}},
        },
        [10683] = {
            [questKeys.preQuestSingle] = {10552},
        },
        [10687] = {
            [questKeys.preQuestSingle] = {10552},
        },
        [10710] = {
            -- Since you don't just have to reach the position this triggerEnd does not make much sense as is empty on purpose!
            [questKeys.triggerEnd] = {"Throw caution to the wind.", {}},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Sign Tally's Waiver, then speak with Rally Zapnabber to use the Zephyrium Capacitorium", 0, {{"monster", 21461}}}},
        },
        [10711] = {
            -- Since you don't just have to reach the position this triggerEnd does not make much sense as is empty on purpose!
            [questKeys.triggerEnd] = {"Reach the Sky's Limit.", {}},
            [questKeys.preQuestGroup] = {10710, 10657},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Speak with Rally Zapnabber to use the Zephyrium Capacitorium", 0, {{"monster", 21461}}}},
        },
        [10712] = {
            -- Since you don't just have to reach the position this triggerEnd does not make much sense as is empty on purpose!
            [questKeys.triggerEnd] = {"Launch to Ruuan Weald.", {}},
            [questKeys.preQuestGroup] = {10711, 10675},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Speak with Rally Zapnabber to use the Zephyrium Capacitorium and spin the Nether-weather Vane while flying", 0, {{"monster", 21461}}}},
        },
        [10722] = {
            [questKeys.triggerEnd] = {"Meeting with Kolphis Darkscale attended", {[zoneIDs.BLADES_EDGE_MOUNTAINS]={{32.61,37.45},},}},
        },
        [10750] = {
            [questKeys.triggerEnd] = {"The Path of Conquest Discovered", {[zoneIDs.SHADOWMOON_VALLEY]={{51.23,62.75},{52.45,59.19},},}},
        },
        [10772] = {
            [questKeys.triggerEnd] = {"The Path of Conquest Discovered", {[zoneIDs.SHADOWMOON_VALLEY]={{51.23,62.75},{52.45,59.19},},}},
        },
        [10781] = {
            [questKeys.triggerEnd] = {"Crimson Sigil Forces Annihilated", {[zoneIDs.SHADOWMOON_VALLEY]={{51.75,72.79},},}},
        },
        [10788] = {
            [questKeys.startedBy] = {{5675,5875,},nil,nil,},
        },
        [10807] = {
            [questKeys.preQuestSingle] = {10552},
        },
        [10813] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{19440,22177,},22177,"Eye of Grillok Returned"}},
        },
        [10814] = {
            [questKeys.triggerEnd] = {"The Tale of Neltharaku", {[zoneIDs.SHADOWMOON_VALLEY]={{63.48,60.71},{59.4,58.67},{66.89,59.79},{63.21,55.88},{59.88,54.21},},}},
        },
        [10824] = {
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestSingle] = {10552},
        },
        [10826] = {
            [questKeys.preQuestSingle] = {10551},
        },
        [10830] = {
            [questKeys.requiredSourceItems] = {31517,31495},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_SLAY, "Use Exorcism Feathers to summon Koi-Koi Spirits", 0, {{"monster", 21326}}}},
        },
        [10838] = {
            [questKeys.extraObjectives] = {{{[3483]={{44,51}}}, ICON_TYPE_EVENT, "Use the Demoniac Scryer"}},
        },
        [10839] = {
            [questKeys.triggerEnd] = {"Attempt to purify the Darkstone of Terrok", {[zoneIDs.TEROKKAR_FOREST]={{30.84,42.03},},}},
        },
        [10840] = {
            [questKeys.preQuestSingle] = {10852},
        },
        [10842] = {
            [questKeys.objectives] = {{{21638, "Vengeful Harbinger defeated"}}},
            [questKeys.preQuestSingle] = {10852},
        },
        [10859] = {
            [questKeys.objectives] = {{{20635,"Razaani Light Orb collected"},},nil,nil,nil,},
        },
        [10861] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, "Collect Cursed Eggs to spawn Malevolent Hatchling", 0, {{"object", 185210}}}},
        },
        [10862] = {
            [questKeys.exclusiveTo] = {10908},
        },
        [10863] = {
            [questKeys.exclusiveTo] = {10908},
        },
        [10873] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{22459,22355},22459,"Sha'tar Warrior Freed"}},
        },
        [10876] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_SLAY, "Kill Force Commander Gorax and place the Challenge From the Horde upon his corpse", 0, {{"monster", 19264}}}},
        },
        [10879] = {
            [questKeys.triggerEnd] = {"Attack thwarted", {[zoneIDs.SHATTRATH_CITY]={{51.62,20.69},},}},
        },
        [10886] = {
            [questKeys.triggerEnd] = {"Millhouse Manastorm Rescued", {[zoneIDs.NETHERSTORM]={{74.5,57.67},},}},
        },
        [10896] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_SLAY, "Kill Rotting Forest-Ragers and Infested Root-Walkers to spawn Wood Mited", 0, {{"monster", 22307}, {"monster", 22095}}}},
        },
        [10898] = {
            [questKeys.triggerEnd] = {"Escort Skywing", {[zoneIDs.TEROKKAR_FOREST]={{55.71,69.68},},}},
        },
        [10908] = {
            [questKeys.exclusiveTo] = {10862,10863},
        },
        [10909] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.HELLFIRE_PENINSULA]={{45,74.4}}}, ICON_TYPE_EVENT, "Place the Achorite Relic and slay Shattered Hand Berserkers near it"}},
        },
        [10915] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, "Use the coffin and kill its content", 0, {{"object", 184999}}}},
        },
        [10922] = {
            [questKeys.triggerEnd] = {"Protect the Explorers", {[zoneIDs.TEROKKAR_FOREST]={{30.12,70.9},},}},
        },
        [10929] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.TEROKKAR_FOREST]={{31.5,75.7}}}, ICON_TYPE_EVENT, "Use the Fumper to lure Mature Bone Sifter", 0}},
        },
        [10930] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_SLAY, "Kill Decrepit Clefthoofs and use the Fumper on their corpses", 0, {{"monster", 22105}}}},
        },
        [10945] = {
            [questKeys.triggerEnd] = {"Salandria taken to Sporeggar", {[zoneIDs.ZANGARMARSH]={{19.22,51.23},},}},
        },
        [10946] = {
            [questKeys.triggerEnd] = {"Ruse of the Ashtongue", {[zoneIDs.NETHERSTORM]={{73.88,63.76},},}},
        },
        [10950] = {
            [questKeys.triggerEnd] = {"Dornaa taken to the Ring of Observance", {[zoneIDs.TEROKKAR_FOREST]={{39.71,64.6},},}},
        },
        [10951] = {
            [questKeys.triggerEnd] = {"Salandria taken to the Dark Portal", {[zoneIDs.HELLFIRE_PENINSULA]={{88.33,50.19},},}},
        },
        [10952] = {
            [questKeys.triggerEnd] = {"Dornaa taken to the Dark Portal", {[zoneIDs.HELLFIRE_PENINSULA]={{88.26,50.32},},}},
        },
        [10953] = {
            [questKeys.triggerEnd] = {"Salandria taken to the Throne of the Elements", {[zoneIDs.NAGRAND]={{60.5,22.7},},}},
        },
        [10954] = {
            [questKeys.triggerEnd] = {"Dornaa taken to Aeris Landing", {[zoneIDs.NAGRAND]={{31.47,57.45},},}},
        },
        [10956] = {
            [questKeys.triggerEnd] = {"Dornaa taken to the Seat of the Naaru", {[zoneIDs.THE_EXODAR]={{56.65,40.73},},}},
        },
        [10962] = {
            [questKeys.triggerEnd] = {"Dornaa taken to the Caverns of Time", {[zoneIDs.TANARIS]={{60.52,57.74},},}},
        },
        [10963] = {
            [questKeys.triggerEnd] = {"Salandria taken to the Caverns of Time", {[zoneIDs.TANARIS]={{60.53,57.72},},}},
        },
        [10968] = {
            [questKeys.triggerEnd] = {"Dornaa taken to Farseer Nobundo", {[zoneIDs.THE_EXODAR]={{30.8,29.88},},}},
        },
        [10977] = {
            [questKeys.triggerEnd] = {"Mana-Tombs Stasis Chamber Investigated", {[zoneIDs.TEROKKAR_FOREST]={{39.63,57.54},},}},
        },
        [10985] = {
            [questKeys.triggerEnd] = {"Help Akama and Maiev enter the Black Temple.", {[zoneIDs.SHADOWMOON_VALLEY]={{71.05,46.11},{66.29,44.06},},}},
        },
        [11023] = {
            [questKeys.requiredLevel] = 70,
            [questKeys.preQuestSingle] = {11010},
        },
        [11036] = {
            [questKeys.exclusiveTo] = {10183,11037,11038,11039,11040,11042,},
        },
        [11037] = {
            [questKeys.exclusiveTo] = {10183,11036,11038,11039,11040,11042,},
            [questKeys.requiredMinRep] = {941,0},
        },
        [11038] = {
            [questKeys.startedBy] = {{23270,23271},nil,nil,},
            [questKeys.exclusiveTo] = {10183,11036,11037,11039,11040,11042,},
        },
        [11039] = {
            [questKeys.exclusiveTo] = {10183,11036,11037,11038,11040,11042,},
            [questKeys.requiredMinRep] = {934,3000},
        },
        [11040] = {
            [questKeys.requiredLevel] = 67,
            [questKeys.exclusiveTo] = {10183,11036,11037,11038,11039,11042,},
        },
        [11042] = {
            [questKeys.requiredLevel] = 67,
            [questKeys.exclusiveTo] = {10183,11036,11037,11038,11039,11040,},
            [questKeys.requiredMinRep] = {978,0},
        },
        [11043] = {
            [questKeys.requiredLevel] = 67,
            [questKeys.exclusiveTo] = {11044,11045},
        },
        [11044] = {
            [questKeys.requiredLevel] = 67,
            [questKeys.exclusiveTo] = {11043,11045},
            [questKeys.requiredMinRep] = {978,0},
        },
        [11045] = {
            [questKeys.exclusiveTo] = {11043,11044,10642},
        },
        [11057] = {
            [questKeys.requiredLevel] = 70,
        },
        [11058] = {
            [questKeys.triggerEnd] = {"Apexis Vibrations attained", {[zoneIDs.BLADES_EDGE_MOUNTAINS]={{33.46,51.84},{28.79,46.68},{31.82,64.05},{27.39,68.4},},}},
        },
        [11064] = {
            [questKeys.triggerEnd] = {"Murg \"Oldie\" Muckjaw Defeated", {[zoneIDs.SHADOWMOON_VALLEY]={{64.76,85.05},},}},
        },
        [11065] = {
            [questKeys.requiredLevel] = 70,
            [questKeys.preQuestSingle] = {11010},
        },
        [11067] = {
            [questKeys.triggerEnd] = {"Trope the Filth-Belcher Defeated", {[zoneIDs.SHADOWMOON_VALLEY]={{64.75,85},},}},
        },
        [11068] = {
            [questKeys.triggerEnd] = {"Corlok the Vet Defeated", {[zoneIDs.SHADOWMOON_VALLEY]={{64.72,84.75},},}},
        },
        [11069] = {
            [questKeys.triggerEnd] = {"Wing Commander Ichman Defeated", {[zoneIDs.SHADOWMOON_VALLEY]={{64.77,85.09},},}},
        },
        [11070] = {
            [questKeys.triggerEnd] = {"Wing Commander Mulverick Defeated", {[zoneIDs.SHADOWMOON_VALLEY]={{64.77,84.36},},}},
        },
        [11071] = {
            [questKeys.triggerEnd] = {"Captain Skyshatter Defeated", {[zoneIDs.SHADOWMOON_VALLEY]={{64.71,85.05},},}},
        },
        [11080] = {
            [questKeys.triggerEnd] = {"Apexis Emanations attained", {[zoneIDs.BLADES_EDGE_MOUNTAINS]={{28.7,46.64},{27.3,68.39},{31.82,63.62},{33.42,51.9},},}},
        },
        [11082] = {
            [questKeys.triggerEnd] = {"Murkblood Information Gathered", {[zoneIDs.SHADOWMOON_VALLEY]={{73.06,82.26},{68.63,79.81},},}},
        },
        [11085] = {
            [questKeys.triggerEnd] = {"Rescue the Skyguard Prisoner.", {[zoneIDs.TEROKKAR_FOREST]={{69.77,75.98},{62.41,73.85},{73.94,88.3},},}},
        },
        [11090] = {
            [questKeys.triggerEnd] = {"Subdue Reth'hedron the Subduer", {[zoneIDs.NAGRAND]={{8.7,42.79},},}},
        },
        [11097] = {
            [questKeys.triggerEnd] = {"Dragonmaw Forces Defeated", {[zoneIDs.SHADOWMOON_VALLEY]={{56.87,58.18},{64.27,31.01},},}},
        },
        [11099] = {
            [questKeys.preQuestSingle] = {10211},
            [questKeys.requiredMaxRep]= {932,0},
        },
        [11100] = {
            [questKeys.preQuestSingle] = {10211},
            [questKeys.requiredMaxRep]= {932,0},
        },
        [11101] = {
            [questKeys.preQuestSingle] = {10211},
            [questKeys.requiredMaxRep]= {932,0},
            [questKeys.triggerEnd] = {"Dragonmaw Forces Defeated", {[zoneIDs.SHADOWMOON_VALLEY]={{56.87,58.18},{64.27,31.01},},}},
        },
        [11108] = {
            [questKeys.triggerEnd] = {"Meeting with Illidan Stormrage", {[zoneIDs.SHADOWMOON_VALLEY]={{65.93,86.15},},}},
        },
        [11119] = {
            [questKeys.requiredLevel] = 70,
        },
        [11142] = {
            [questKeys.triggerEnd] = {"Survey Alcaz Island", {[zoneIDs.DUSTWALLOW_MARSH]={{69.96,19.55},{67.36,50.87},},}},
        },
        [11152] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Lay the Wreath at the Hyal Family Monument", 0, {{"object", 186322}}}},
        },
        [11159] = {
            [questKeys.preQuestSingle] = {11161},
        },
        [11162] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Plant the Stonemaul Banner", 0, {{"object", 186336}}}},
        },
        [11169] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{4344,4345,},4344,"Totem Tests Performed"}},
        },
        [11174] = {
            [questKeys.preQuestSingle] = {},
        },
        [11198] = {
            [questKeys.triggerEnd] = {"Defend Theramore Docks from Tethyr", {[zoneIDs.DUSTWALLOW_MARSH]={{70.01,51.88},},}},
        },
        [11208] = {
            [questKeys.exclusiveTo] = {11158},
        },
        [11209] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.DUSTWALLOW_MARSH]={{57,62}}}, ICON_TYPE_EVENT, "Smear the Fish Paste on yourself and swim to the ship wreck"}},
        },
        [11211] = {
            [questKeys.exclusiveTo] = {11158},
        },
        [11214] = {
            [questKeys.exclusiveTo] = {11158},
        },
        [11215] = {
            [questKeys.exclusiveTo] = {11158},
        },
        [11335] = {
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [zoneIDs.SHATTRATH_CITY]={{67.38,33.8},{66.58,56.23},},
                [zoneIDs.STORMWIND_CITY]={{82.45,12.92},},
                [zoneIDs.ORGRIMMAR]={{79.39,30.08},},
                [zoneIDs.IRONFORGE]={{70.12,89.41},},
            }},
        },
        [11336] = {
            [questKeys.triggerEnd] = {"Victory in Alterac Valley", {
                [zoneIDs.SHATTRATH_CITY]={{66.85,57.04},{67.49,34.31},},
                [zoneIDs.STORMWIND_CITY]={{82.12,12.83},},
                [zoneIDs.ORGRIMMAR]={{79.09,31.1},},
                [zoneIDs.IRONFORGE]={{70.09,90.26},},
            }},
        },
        [11337] = {
            [questKeys.triggerEnd] = {"Victory in the Eye of the Storm", {
                [zoneIDs.SHATTRATH_CITY]={{67.4,34.08},},
                [zoneIDs.STORMWIND_CITY]={{82.51,13.69},},
                [zoneIDs.IRONFORGE]={{70.04,89.98},},
            }},
        },
        [11338] = {
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.SHATTRATH_CITY]={{67.4,34.64},{66.62,57.45},},
                [zoneIDs.STORMWIND_CITY]={{82.5,13.26},},
                [zoneIDs.ORGRIMMAR]={{79.03,30.65},},
                [zoneIDs.IRONFORGE]={{70.5,89.56},},
            }},
        },
        [11339] = {
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [zoneIDs.SHATTRATH_CITY]={{67.38,33.8},{66.58,56.23},},
                [zoneIDs.STORMWIND_CITY]={{82.45,12.92},},
                [zoneIDs.ORGRIMMAR]={{79.39,30.08},},
                [zoneIDs.IRONFORGE]={{70.12,89.41},},
            }},
        },
        [11340] = {
            [questKeys.triggerEnd] = {"Victory in Alterac Valley", {
                [zoneIDs.SHATTRATH_CITY]={{66.85,57.04},{67.49,34.31},},
                [zoneIDs.STORMWIND_CITY]={{82.12,12.83},},
                [zoneIDs.ORGRIMMAR]={{79.09,31.1},},
                [zoneIDs.IRONFORGE]={{70.09,90.26},},
            }},
        },
        [11341] = {
            [questKeys.triggerEnd] = {"Victory in Eye of the Storm", {
                [zoneIDs.SHATTRATH_CITY]={{67.02,56.14},{63.9,58.34},},
                [zoneIDs.ORGRIMMAR]={{79.21,30.08},},
            }},
        },
        [11342] = {
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.SHATTRATH_CITY]={{67.4,34.64},{66.62,57.45},},
                [zoneIDs.STORMWIND_CITY]={{82.5,13.26},},
                [zoneIDs.ORGRIMMAR]={{79.03,30.65},},
                [zoneIDs.IRONFORGE]={{70.5,89.56},},
            }},
        },
        [11383] = {
            [questKeys.objectives] = {{{17839},},nil,nil,nil,nil,},
        },
        [11496] = {
            [questKeys.triggerEnd] = {"Energize a Crystal Ward", {[zoneIDs.SUNWELL_PLATEAU]={{47.7,34.52},{48.43,31.21},},}},
        },
        [11502] = {
            [questKeys.requiredMinRep] = {978,0},
        },
        [11503] = {
            [questKeys.requiredMinRep] = {941,0},
        },
        [11505] = {
            [questKeys.triggerEnd] = {"Secure a Spirit Tower", {[zoneIDs.TEROKKAR_FOREST]={{42.49,54},{32.47,57.86},{48.98,60.29},{47.2,72.29},{40.48,77.99},},}},
        },
        [11506] = {
            [questKeys.triggerEnd] = {"Secure a Spirit Tower", {[zoneIDs.TEROKKAR_FOREST]={{42.49,54},{32.47,57.86},{48.98,60.29},{47.2,72.29},{40.48,77.99},},}},
        },
        [11516] = {
            [questKeys.triggerEnd] = {"Legion Gateway Destroyed", {[zoneIDs.HELLFIRE_PENINSULA]={{58.51,18.5},},}},
        },
        [11523] = {
            [questKeys.triggerEnd] = {"Energize a Crystal Ward", {[zoneIDs.SUNWELL_PLATEAU]={{47.7,34.52},{48.43,31.21},},}},
        },
        [11657] = {
            [questKeys.triggerEnd] = {"Catch 4 torches in a row.", {
                [zoneIDs.ORGRIMMAR]={{47.02,36.83},},
                [zoneIDs.THUNDER_BLUFF]={{21.95,26.74},},
                [zoneIDs.STORMWIND_CITY]={{37.65,59.98},},
                [zoneIDs.IRONFORGE]={{62.15,27.58},},
                [zoneIDs.UNDERCITY]={{64.58,8.08},},
            }},
        },
        [11667] = {
            [questKeys.extraObjectives] = {{{[3518]={{62,35}}}, ICON_TYPE_EVENT, "Fish Here for World's Largest Mudfish"}},
        },
        [11731] = {
            [questKeys.triggerEnd] = {"Hit 8 braziers.", {
                [zoneIDs.TELDRASSIL]={{56.59,92.06},},
                [zoneIDs.ORGRIMMAR]={{46.65,38.17},},
                [zoneIDs.STORMWIND_CITY]={{39.21,61.71},},
                [zoneIDs.IRONFORGE]={{65,23.73},},
                [zoneIDs.UNDERCITY]={{68.58,7.88},},
            }},
        },
        [11885] = {
            [questKeys.requiredSourceItems] = {32620},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, "Summon and defeat each of the descendants by using 10 Time-Lost Scrolls at the Skull Piles", 0, {{"object", 185913}}}},
        },
        [11891] = {
            [questKeys.triggerEnd] = {"Listen to the plan of the Twilight Cultists", {[zoneIDs.ASHENVALE]={{9.15,12.41},},}},
        },
        [11922] = {
            [questKeys.triggerEnd] = {"Hit 8 braziers.", {
                [zoneIDs.TELDRASSIL]={{56.59,92.06},},
                [zoneIDs.ORGRIMMAR]={{46.65,38.17},},
                [zoneIDs.STORMWIND_CITY]={{39.21,61.71},},
                [zoneIDs.IRONFORGE]={{65,23.73},},
                [zoneIDs.UNDERCITY]={{68.58,7.88},},
            }},
        },
        [11921] = {
            [questKeys.triggerEnd] = {"Hit 20 braziers.", {
                [zoneIDs.ORGRIMMAR]={{46.67,38.13},},
                [zoneIDs.THUNDER_BLUFF]={{20.99,26.46},},
                [zoneIDs.STORMWIND_CITY]={{39.2,61.72},},
                [zoneIDs.IRONFORGE]={{65,23.68},},
                [zoneIDs.UNDERCITY]={{68.62,8.01},},
            }},
        },
        [11923] = {
            [questKeys.triggerEnd] = {"Catch 4 torches in a row.", {
                [zoneIDs.ORGRIMMAR]={{47.02,36.83},},
                [zoneIDs.THUNDER_BLUFF]={{21.95,26.74},},
                [zoneIDs.STORMWIND_CITY]={{37.65,59.98},},
                [zoneIDs.IRONFORGE]={{62.15,27.58},},
                [zoneIDs.UNDERCITY]={{64.58,8.08},},
            }},
        },
        [11924] = {
            [questKeys.triggerEnd] = {"Catch 10 torches in a row.", {
                [zoneIDs.ORGRIMMAR]={{47.11,36.69},},
                [zoneIDs.THE_EXODAR]={{41.63,22.55},},
                [zoneIDs.STORMWIND_CITY]={{37.5,59.8},},
                [zoneIDs.IRONFORGE]={{62.04,27.83},},
                [zoneIDs.THUNDER_BLUFF]={{22.17,26.94},},
            }},
        },
        [11925] = {
            [questKeys.triggerEnd] = {"Catch 10 torches in a row.", {
                [zoneIDs.ORGRIMMAR]={{47.11,36.69},},
                [zoneIDs.THE_EXODAR]={{41.63,22.55},},
                [zoneIDs.STORMWIND_CITY]={{37.5,59.8},},
                [zoneIDs.IRONFORGE]={{62.04,27.83},},
                [zoneIDs.THUNDER_BLUFF]={{22.17,26.94},},
            }},
        },
        [11926] = {
            [questKeys.triggerEnd] = {"Hit 20 braziers.", {
                [zoneIDs.ORGRIMMAR]={{46.67,38.13},},
                [zoneIDs.THUNDER_BLUFF]={{20.99,26.46},},
                [zoneIDs.STORMWIND_CITY]={{39.2,61.72},},
                [zoneIDs.IRONFORGE]={{65,23.68},},
                [zoneIDs.UNDERCITY]={{68.62,8.01},},
            }},
        },

        -- Below are quests that were not originally in TBC or in a different form

        [63866] = {
            [questKeys.name] = "Claiming the Light",
            [questKeys.startedBy] = {{17718},nil,nil},
            [questKeys.finishedBy] = {{17717},nil,nil},
            [questKeys.requiredLevel] = 12,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {"Use the Shimmering Vessel on M'uru to fill it and return to Knight-Lord Bloodvalor in Silvermoon City."},
            [questKeys.objectives] = {nil,nil,{{24156},},nil,},
            [questKeys.sourceItemId] = 24157,
            [questKeys.preQuestSingle] = {9681},
            [questKeys.zoneOrSort] = -141,
            [questKeys.nextQuestInChain] = 9685,
            [questKeys.questFlags] = 128,
        },

        ----- Boosted character quests -----
        [64037] = {
            [questKeys.name] = "Eastern Plaguelands",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283},nil,nil},
            [questKeys.finishedBy] = {{11036},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Travel to the Eastern Plaguelands and find Leonid Barthalomew. He awaits your arrival at Light's Hope Chapel. "},
            [questKeys.objectives] = {{{352, "Speak to Dungar Longdrink, the Gryphon Master"},},nil,nil,nil,nil},
            [questKeys.preQuestSingle] = {64035},
            [questKeys.exclusiveTo] = {64038},
            [questKeys.zoneOrSort] = zoneIDs.STORMWIND_CITY,
        },
        [64028] = {
            [questKeys.name] = "A New Beginning",
            [questKeys.startedBy] = {}, -- This quest is auto accept
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Meet with your class trainer in Stormwind."},
            [questKeys.zoneOrSort] = zoneIDs.STORMWIND_CITY,
        },
        [64031] = {
            [questKeys.name] = "Tools for Survival",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283},nil,nil},
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Open the survival kit and equip a weapon."},
            [questKeys.objectives] = {nil,{{400009, "Open the Survival Kit"}, {400010, "Equip a Weapon"}},nil,nil,nil},
            [questKeys.preQuestSingle] = {64028},
            [questKeys.zoneOrSort] = zoneIDs.STORMWIND_CITY,
        },
        [64034] = {
            [questKeys.name] = "Combat Training",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283},nil,nil},
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Train a spell by speaking to your class trainer."},
            [questKeys.objectives] = {nil,{{400011, "Train a Spell"}},nil,nil,nil},
            [questKeys.preQuestSingle] = {64031},
            [questKeys.zoneOrSort] = zoneIDs.STORMWIND_CITY,
        },
        [64035] = {
            [questKeys.name] = "Talented",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283},nil,nil},
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Activate the Talents interface and allocate a Talent Point."},
            [questKeys.objectives] = {nil,{{400012, "Train a Spell"}},nil,nil,nil},
            [questKeys.preQuestSingle] = {64034},
            [questKeys.zoneOrSort] = zoneIDs.STORMWIND_CITY,
        },
        [64038] = {
            [questKeys.name] = "The Dark Portal",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283},nil,nil},
            [questKeys.finishedBy] = {{16841},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Find Watch Commander Relthorn Netherwane at the Blasted Lands. He awaits your arrival before the Dark Portal."},
            [questKeys.objectives] = {{{352, "Speak to Dungar Longdrink, the Gryphon Master"}},nil,nil,nil,nil},
            [questKeys.preQuestSingle] = {64035},
            [questKeys.zoneOrSort] = zoneIDs.STORMWIND_CITY,
        },
        [64046] = {
            [questKeys.name] = "A New Beginning",
            [questKeys.startedBy] = {}, -- This quest is auto accept
            [questKeys.finishedBy] = {{3324,3328,3344,3353,3406,5885,5994},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Meet with your class trainer in Orgrimmar."},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [64047] = {
            [questKeys.name] = "A New Beginning",
            [questKeys.startedBy] = {}, -- This quest is auto accept
            [questKeys.finishedBy] = {{3036},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {"Meet with your Druid trainer in Thunderbluff."},
            [questKeys.zoneOrSort] = zoneIDs.THUNDER_BLUFF,
        },
        [64048] = {
            [questKeys.name] = "Tools for Survival",
            [questKeys.startedBy] = {{3324,3328,3344,3353,3406,5885,5994},nil,nil},
            [questKeys.finishedBy] = {{3324,3328,3344,3353,3406,5885,5994},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Open the survival kit and equip a weapon."},
            [questKeys.objectives] = {nil,{{400001, "Open the Survival Kit"}, {400002, "Equip a Weapon"}},nil,nil,nil},
            [questKeys.preQuestSingle] = {64046},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [64049] = {
            [questKeys.name] = "Tools for Survival",
            [questKeys.startedBy] = {{3036},nil,nil},
            [questKeys.finishedBy] = {{3036},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {"Open the survival kit and equip a weapon."},
            [questKeys.objectives] = {nil,{{400003, "Open the Survival Kit"}, {400004, "Equip a Weapon"}},nil,nil,nil},
            [questKeys.preQuestSingle] = {64047},
            [questKeys.zoneOrSort] = zoneIDs.THUNDER_BLUFF,
        },
        [64050] = {
            [questKeys.name] = "Combat Training",
            [questKeys.startedBy] = {{3324,3328,3344,3353,3406,5885,5994},nil,nil},
            [questKeys.finishedBy] = {{3324,3328,3344,3353,3406,5885,5994},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Train a spell by speaking to your class trainer."},
            [questKeys.objectives] = {nil,{{400005, "Train a Spell"}},nil,nil,nil},
            [questKeys.preQuestSingle] = {64048},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [64051] = {
            [questKeys.name] = "Combat Training",
            [questKeys.startedBy] = {{3036},nil,nil},
            [questKeys.finishedBy] = {{3036},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {"Train a spell by speaking to your Druid trainer."},
            [questKeys.objectives] = {nil,{{400006, "Train a Spell"}},nil,nil,nil},
            [questKeys.preQuestSingle] = {64049},
            [questKeys.zoneOrSort] = zoneIDs.THUNDER_BLUFF,
        },
        [64052] = {
            [questKeys.name] = "Talented",
            [questKeys.startedBy] = {{3324,3328,3344,3353,3406,5885,5994},nil,nil},
            [questKeys.finishedBy] = {{3324,3328,3344,3353,3406,5885,5994},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Activate the Talents interface and allocate five Talent Points."},
            [questKeys.objectives] = {nil,{{400007, "Train a Spell"}},nil,nil,nil},
            [questKeys.preQuestSingle] = {64050},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [64053] = {
            [questKeys.name] = "Talented",
            [questKeys.startedBy] = {{3036},nil,nil},
            [questKeys.finishedBy] = {{3036},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {"Activate the Talents interface and allocate five Talent Points."},
            [questKeys.objectives] = {nil,{{400008, "Train a Spell"}},nil,nil,nil},
            [questKeys.preQuestSingle] = {64051},
            [questKeys.zoneOrSort] = zoneIDs.THUNDER_BLUFF,
        },
        [64063] = {
            [questKeys.name] = "The Dark Portal",
            [questKeys.startedBy] = {{3324,3328,3344,3353,3406,5885,5994},nil,nil},
            [questKeys.finishedBy] = {{19254},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Find Watch Warlord Dar'toon at the Blasted Lands. He awaits your arrival before the Dark Portal."},
            [questKeys.objectives] = {{{12136, "Visit Snurk Bucksqick by the Zepplin Master"},{1387, "Speak to Thysta at Grom'Gol Base Camp"}},nil,nil,nil,nil},
            [questKeys.preQuestSingle] = {64052},
            [questKeys.exclusiveTo] = {64217},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [64064] = {
            [questKeys.name] = "Eastern Plaguelands",
            [questKeys.startedBy] = {{3324,3328,3344,3353,3406,5885,5994,3036},nil,nil},
            [questKeys.finishedBy] = {{11036},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Travel to the Eastern Plaguelands and find Leonid Barthalomew. He awaits your arrival at Light's Hope Chapel. "},
            [questKeys.objectives] = {{{9564, "Visit Zeppelin Master Frezza"},},nil,nil,nil,nil},
            [questKeys.preQuestSingle] = {64052,64053,},
            [questKeys.exclusiveTo] = {64063,64217},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [64217] = {
            [questKeys.name] = "The Dark Portal",
            [questKeys.startedBy] = {{3036},nil,nil},
            [questKeys.finishedBy] = {{19254},nil,nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.objectivesText] = {"Find Watch Warlord Dar'toon at the Blasted Lands. He awaits your arrival before the Dark Portal."},
            [questKeys.objectives] = {{{12136, "Visit Snurk Bucksqick by the Zepplin Master"},{1387, "Speak to Thysta at Grom'Gol Base Camp"}},nil,nil,nil,nil},
            [questKeys.preQuestSingle] = {64053},
            [questKeys.exclusiveTo] = {64063},
            [questKeys.zoneOrSort] = zoneIDs.THUNDER_BLUFF,
        },
    }
end
