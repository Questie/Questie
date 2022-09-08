---@class QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:CreateModule("QuestieQuestBlacklist")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")

function QuestieQuestBlacklist:Load()
    local questsToBlacklist = {
        [7462] = true, -- Duplicate of 7877. See #1583
        [5663] = true, -- Touch of Weakness of Dark Cleric Beryl - Fixing #730
        [5658] = true, -- Touch of Weakness of Father Lankester -- See #1603
        [2358] = true, -- Horns of Nez'ra is not in the game at this point. See #921
        [787] = true, -- The New Horde is not in the game. See #830
        [6606] = true, -- Quest is not in the game. See #1338
        [6072] = true, -- Ayanna Everstride doesn't start "Hunter's Path" (this quest is most likely simply not in the game) #700
        [614] = true, -- Duplicate of 8551
        [615] = true, -- Duplicate of 8553. See #2215
        [618] = true, -- Duplicate of 8554
        [934] = true, -- Duplicate of 7383. See #2386
        [960] = true, -- Duplicate of 961
        [9378] = true, -- Naxxramas quest which doesn't seem to be in the game
        [1318] = true, -- Duplicate of 7703 and not in the game
        [7704] = true, -- Not in the game
        [7668] = true, -- Not in the game (yet) Replaced with 8258 in Ph 4-- #1805
        [636] = true, -- Not in the game - #1900
        [6066] = true, -- Not in the game - #1957
        [4603] = true, -- Duplicate of 2953
        [4604] = true, -- Duplicate of 2953
        [8856] = true, -- Duplicate of 8497
        [64143] = true, -- Duplicate of 9735
        [13053] = true, -- Removed
        [11402] = true, -- GM Island quest
        [11189] = true, -- Removed
        [13417] = true, -- Duplicate of 12973
        [936] = QuestieCorrections.CLASSIC_ONLY,
        -- Welcome! quests (Collectors Edition)
        [5805] = true,
        [5841] = true,
        [5842] = true,
        [5843] = true,
        [5844] = true,
        [5847] = true,
        --Stray quests
        [3861] = true, --CLUCK!
        --World event quests
        --Fetched from https://classic.wowhead.com/world-event-quests
        [7904] = true,
        [8571] = true,
        [7930] = true,
        [7931] = true,
        [7935] = true,
        [7932] = true,
        [7933] = true,
        [7934] = true,
        [7936] = true,
        [7981] = true,
        [7940] = true,
        [8744] = true,
        [8803] = true,
        [8768] = true,
        [8788] = true,
        [8767] = true,
        [9319] = true,
        [9386] = true,
        [7045] = true,
        [6984] = true,
        [9365] = true,
        [9339] = true,
        [8769] = true,
        [171] = true,
        [5502] = true,
        [7885] = true,
        [8647] = true,
        [7892] = true,
        [8715] = true,
        [8719] = true,
        [8718] = true,
        [8673] = true,
        [8726] = true,
        [8866] = true,
        [925] = true,
        [7881] = true,
        [7882] = true,
        [8353] = true,
        [8354] = true,
        [172] = true,
        [1468] = true,
        [8882] = true,
        [8880] = true,
        [7889] = true,
        [7894] = true,
        [1658] = true,
        [7884] = true,
        [8357] = true,
        [8360] = true,
        [8648] = true,
        [8677] = true,
        [7907] = true,
        [7906] = true,
        [7929] = true,
        [7927] = true,
        [7928] = true,
        [8683] = true,
        [910] = true,
        [8684] = true,
        [8868] = true,
        [8862] = true,
        [7903] = true,
        [8727] = true,
        [8863] = true,
        [8864] = true,
        [8865] = true,
        [8878] = true,
        [8877] = true,
        [8356] = true,
        [8359] = true,
        [9388] = true,
        [9389] = true,
        [911] = true,
        [8222] = true,
        [8653] = true,
        [8652] = true,
        [6961] = true,
        [7021] = true,
        [7024] = true,
        [7022] = true,
        [7023] = true,
        [7896] = true,
        [7891] = true,
        [8679] = true,
        [8311] = true,
        [8312] = true,
        [8646] = true,
        [7890] = true,
        [8686] = true,
        [8643] = true,
        [8149] = true,
        [8150] = true,
        [8355] = true,
        [8358] = true,
        [8651] = true,
        [558] = true,
        [8881] = true,
        [8879] = true,
        [1800] = true,
        [8867] = true,
        [8722] = true,
        [7897] = true,
        [8762] = true,
        [8746] = true,
        [8685] = true,
        [8714] = true,
        [8717] = true,
        [7941] = true,
        [7943] = true,
        [7939] = true,
        [8223] = true,
        [7942] = true,
        [8619] = true,
        [8724] = true,
        [8861] = true,
        [8860] = true,
        [8723] = true,
        [8645] = true,
        [8654] = true,
        [8678] = true,
        [8671] = true,
        [7893] = true,
        [8725] = true,
        [8322] = true,
        [8409] = true,
        [8636] = true,
        [8670] = true,
        [8642] = true,
        [8675] = true,
        [8720] = true,
        [8682] = true,
        [7899] = true,
        [8876] = true,
        [8650] = true,
        [7901] = true,
        [7946] = true,
        [8635] = true,
        [1687] = true,
        [8716] = true,
        [8713] = true,
        [8721] = true,
        [9332] = true,
        [9331] = true,
        [9324] = true,
        [9330] = true,
        [9326] = true,
        [9325] = true,
        [1657] = true,
        [7042] = true,
        [6963] = true,
        [8644] = true,
        [8672] = true,
        [8649] = true,
        [1479] = true,
        [7063] = true,
        [7061] = true,
        [9368] = true,
        [9367] = true,
        [8763] = true,
        [8799] = true,
        [8873] = true,
        [8874] = true,
        [8875] = true,
        [8870] = true,
        [8871] = true,
        [8872] = true,
        [8373] = true,
        [7062] = true,
        [6964] = true,
        [1558] = true,
        [7883] = true,
        [7898] = true,
        [8681] = true,
        [7900] = true,
        [6962] = true,
        [7025] = true,
        [8883] = true,
        [7902] = true,
        [7895] = true,
        [9322] = true,
        [9323] = true,
        [8676] = true,
        [8688] = true,
        [8680] = true,
        [8828] = true,
        [8827] = true,
        [8674] = true,
        [915] = true,
        [4822] = true,
        [7043] = true,
        [6983] = true,
        [7937] = true,
        [7938] = true,
        [7944] = true,
        [7945] = true,
        [8857] = true,
        [8858] = true,
        [8859] = true,
        --Rocknot's Ale instance quest shown in SG/BS at lvl 1
        [4295] = true,
        --mount exchange/replacement
        [7678] = true,
        [7677] = true,
        [7673] = true,
        [7674] = true,
        [7671] = true,
        [7665] = true,
        [7675] = true,
        [7664] = true,
        [7672] = true,
        [7676] = true,
        --fishing tournament
        [8194] = true,
        [8221] = true,
        [8224] = true,
        [8225] = true,
        [8193] = true,
        [8226] = true,
        [8228] = true,
        [8229] = true,
        --love is in the air
        [8903] = true,
        [8904] = true,
        [8897] = true,
        [8898] = true,
        [8899] = true,
        [9029] = true,
        [8981] = true,
        [8993] = true,
        [8900] = true,
        [8901] = true,
        [8902] = true,
        [9024] = true,
        [9025] = true,
        [9026] = true,
        [9027] = true,
        [9028] = true,
        [8971] = true,
        [8972] = true,
        [8973] = true,
        [8974] = true,
        [8975] = true,
        [8976] = true,
        [8979] = true,
        [8980] = true,
        [8982] = true,
        [8983] = true,
        [8984] = true,
        -- TBC event quests
        [9249] = true,
        [10938] = true,
        [10939] = true,
        [10940] = true,
        [10941] = true,
        [10942] = true,
        [10943] = true,
        [10945] = true,
        [10950] = true,
        [10951] = true,
        [10952] = true,
        [10953] = true,
        [10954] = true,
        [10956] = true,
        [10960] = true,
        [10962] = true,
        [10963] = true,
        [10966] = true,
        [10967] = true,
        [10968] = true,
        [11117] = true,
        [11118] = true,
        [11120] = true,
        [11127] = true,
        [11131] = true,
        [11135] = true,
        [11219] = true,
        [11220] = true,
        [11242] = true,
        [11318] = true,
        [11320] = true,
        [11356] = true,
        [11357] = true,
        [11360] = true,
        [11361] = true,
        [11392] = true,
        [11400] = true,
        [11401] = true,
        [11403] = true,
        [11404] = true,
        [11405] = true,
        [11409] = true,
        [11437] = true,
        [11438] = true,
        [11439] = true,
        [11440] = true,
        [11441] = true,
        [11442] = true,
        [11446] = true,
        [11447] = true,
        [11449] = true,
        [11450] = true,
        [11454] = true,
        [11528] = true,
        [11580] = true,
        [11581] = true,
        [11583] = true,
        [11584] = true,
        [11657] = true,
        [11691] = true,
        [11696] = true,
        [11731] = true,
        [11732] = true,
        [11734] = true,
        [11735] = true,
        [11736] = true,
        [11737] = true,
        [11738] = true,
        [11739] = true,
        [11740] = true,
        [11741] = true,
        [11742] = true,
        [11743] = true,
        [11744] = true,
        [11745] = true,
        [11746] = true,
        [11747] = true,
        [11748] = true,
        [11749] = true,
        [11750] = true,
        [11751] = true,
        [11752] = true,
        [11753] = true,
        [11754] = true,
        [11755] = true,
        [11756] = true,
        [11757] = true,
        [11758] = true,
        [11759] = true,
        [11760] = true,
        [11761] = true,
        [11762] = true,
        [11763] = true,
        [11764] = true,
        [11765] = true,
        [11766] = true,
        [11767] = true,
        [11768] = true,
        [11769] = true,
        [11770] = true,
        [11771] = true,
        [11772] = true,
        [11773] = true,
        [11774] = true,
        [11775] = true,
        [11776] = true,
        [11777] = true,
        [11778] = true,
        [11779] = true,
        [11780] = true,
        [11781] = true,
        [11782] = true,
        [11783] = true,
        [11784] = true,
        [11785] = true,
        [11786] = true,
        [11787] = true,
        [11799] = true,
        [11800] = true,
        [11801] = true,
        [11802] = true,
        [11803] = true,
        [11804] = true,
        [11805] = true,
        [11806] = true,
        [11807] = true,
        [11808] = true,
        [11809] = true,
        [11810] = true,
        [11811] = true,
        [11812] = true,
        [11813] = true,
        [11814] = true,
        [11815] = true,
        [11816] = true,
        [11817] = true,
        [11818] = true,
        [11819] = true,
        [11820] = true,
        [11821] = true,
        [11822] = true,
        [11823] = true,
        [11824] = true,
        [11825] = true,
        [11826] = true,
        [11827] = true,
        [11828] = true,
        [11829] = true,
        [11830] = true,
        [11831] = true,
        [11832] = true,
        [11833] = true,
        [11834] = true,
        [11835] = true,
        [11836] = true,
        [11837] = true,
        [11838] = true,
        [11839] = true,
        [11840] = true,
        [11841] = true,
        [11842] = true,
        [11843] = true,
        [11844] = true,
        [11845] = true,
        [11846] = true,
        [11847] = true,
        [11848] = true,
        [11849] = true,
        [11850] = true,
        [11851] = true,
        [11852] = true,
        [11853] = true,
        [11854] = true,
        [11855] = true,
        [11856] = true,
        [11857] = true,
        [11858] = true,
        [11859] = true,
        [11860] = true,
        [11861] = true,
        [11862] = true,
        [11863] = true,
        [11882] = true,
        [11886] = true,
        [11915] = true,
        [11921] = true,
        [11922] = true,
        [11923] = true,
        [11924] = true,
        [11925] = true,
        [11926] = true,
        [11933] = true,
        [11935] = true,
        [11954] = true,
        [11955] = true,
        [11972] = true,
        [11975] = true,
        [11964] = true,
        [11966] = true,
        [11970] = true,
        [11971] = true,
        [12020] = true,
        [12192] = true,
        [11293] = true,
        [11294] = true,
        [11407] = true,
        [11408] = true,
        [11412] = true,
        [11122] = true,
        [12318] = true,
        [12022] = true,
        [12062] = true,
        [12133] = true,
        [12135] = true,
        [12139] = true,
        [12191] = true,
        [12194] = true,
        [12278] = true,
        [12155] = true,
        [12286] = true,
        [12331] = true,
        [12332] = true,
        [12333] = true,
        [12334] = true,
        [12335] = true,
        [12336] = true,
        [12337] = true,
        [12338] = true,
        [12339] = true,
        [12340] = true,
        [12341] = true,
        [12342] = true,
        [12343] = true,
        [12344] = true,
        [12345] = true,
        [12346] = true,
        [12347] = true,
        [12348] = true,
        [12349] = true,
        [12350] = true,
        [12351] = true,
        [12352] = true,
        [12353] = true,
        [12354] = true,
        [12355] = true,
        [12356] = true,
        [12357] = true,
        [12358] = true,
        [12359] = true,
        [12360] = true,
        [12361] = true,
        [12362] = true,
        [12363] = true,
        [12364] = true,
        [12365] = true,
        [12366] = true,
        [12367] = true,
        [12368] = true,
        [12369] = true,
        [12370] = true,
        [12371] = true,
        [12373] = true,
        [12374] = true,
        [12375] = true,
        [12376] = true,
        [12377] = true,
        [12378] = true,
        [12379] = true,
        [12380] = true,
        [12381] = true,
        [12382] = true,
        [12383] = true,
        [12384] = true,
        [12385] = true,
        [12386] = true,
        [12387] = true,
        [12388] = true,
        [12389] = true,
        [12390] = true,
        [12391] = true,
        [12392] = true,
        [12393] = true,
        [12394] = true,
        [12395] = true,
        [12396] = true,
        [12397] = true,
        [12398] = true,
        [12399] = true,
        [12400] = true,
        [12401] = true,
        [12402] = true,
        [12403] = true,
        [12404] = true,
        [12406] = true,
        [12407] = true,
        [12408] = true,
        [12409] = true,
        [12420] = true,
        [12421] = true,
        ----------------
        --- Wotlk event quests
        --- Noblegarden
        [13479] = true,
        [13480] = true,
        [13502] = true,
        [13503] = true,

        --- Love is in the Air
        [14488] = true,
        [24597] = true,
        [24609] = true,
        [24610] = true,
        [24611] = true,
        [24612] = true,
        [24613] = true,
        [24614] = true,
        [24615] = true,
        [24629] = true,
        [24635] = true,
        [24636] = true,
        [24655] = true,
        [24804] = true,

        --- Children's Week
        [13926] = true,
        [13927] = true,

        --- Hallow's End
        [13463] = true,
        [13472] = true,
        [13473] = true,

        --- Pilgrim's Bounty
        [12784] = true,
        [12808] = true,
        [13483] = true,
        [13484] = true,
        [14036] = true,
        [14022] = true,

        --- Brewfest
        [13931] = true,
        [13932] = true,
        -------------------

        --mount replacement
        [7662] = true,
        [7663] = true,
        [7660] = true,
        [7661] = true,

        -- PvP Quests which are not in the game anymore
        -----------------------------------------------
        -- Vanquish the Invaders
        [7788] = true,
        [7871] = true,
        [7872] = true,
        [7873] = true,
        [8290] = true,
        [8291] = true,
        -- Talisman of Merit
        [7886] = true,
        [7887] = true,
        [7888] = true,
        [7921] = true,
        [8567] = true,
        [8289] = true,
        [8292] = true,
        [8001] = true,
        -- Quell the Silverwing Usurpers
        [7789] = true,
        [7874] = true,
        [7875] = true,
        [7876] = true,
        [8294] = true,
        [8295] = true,
        -- Warsong Mark of Honor
        [7922] = true,
        [7923] = true,
        [7924] = true,
        [7925] = true,
        [8293] = true,
        [8296] = true,
        [8568] = true,
        [8002] = true,
        -- Arathi Basin
        [8081] = true,
        [8124] = true,
        [8157] = true,
        [8158] = true,
        [8159] = true,
        [8163] = true,
        [8164] = true,
        [8165] = true,
        [8298] = true,
        [8300] = true,
        [8565] = true,
        [8566] = true,
        [8123] = true,
        [8160] = true,
        [8161] = true,
        [8162] = true,
        [8299] = true,
        [8080] = true,
        [8154] = true,
        [8155] = true,
        [8156] = true,
        [8297] = true,
        -- Alterac Valley
        [6861] = QuestieCorrections.CLASSIC_ONLY,
        [6862] = QuestieCorrections.CLASSIC_ONLY,
        [6864] = QuestieCorrections.CLASSIC_ONLY,
        [6901] = QuestieCorrections.CLASSIC_ONLY,
        [7221] = true,
        [7222] = true,
        [7281] = QuestieCorrections.CLASSIC_ONLY,
        [7282] = QuestieCorrections.CLASSIC_ONLY,
        [7301] = QuestieCorrections.CLASSIC_ONLY,
        [7302] = QuestieCorrections.CLASSIC_ONLY,
        [7367] = true,
        [7368] = true,
        -- Master Ryson's All Seeing Eye
        [6847] = true,
        [6848] = true,
        -- WANTED: Orcs and WANTED: Dwarves
        [7402] = true,
        [7428] = true,
        [7401] = true,
        [7427] = true,
        -- Ribbons of Sacrifice
        [8266] = true,
        [8267] = true,
        [8268] = true,
        [8269] = true,
        [8569] = true,
        [8570] = true,
        -----------------------------------------------

        -- corrupted windblossom
        [2523] = true,
        [2878] = true,
        [3363] = true,
        [4113] = true,
        [4114] = true,
        [4116] = true,
        [4118] = true,
        [4401] = true,
        [4464] = true,
        [4465] = true,
        [996] = true,
        [998] = true,
        [1514] = true,
        [4115] = true,
        [4221] = true,
        [4222] = true,
        [4343] = true,
        [4403] = true,
        [4466] = true,
        [4467] = true,
        [4117] = true,
        [4443] = true,
        [4444] = true,
        [4445] = true,
        [4446] = true,
        [4461] = true,
        [4119] = true,
        [4447] = true,
        [4448] = true,
        [4462] = true,

        --Darkmoon Faire
        [7905] = true,
        [7926] = true,

        [8743] = true, -- Bang a Gong! (AQ40 opening quest)

        -- Classic Phase 6 Invasion quests
        -- Investigate the Scourge of X
        [9260] = true,
        [9261] = true,
        [9262] = true,
        [9263] = true,
        [9264] = true,
        [9265] = true,
        --
        [9085] = true,
        [9153] = true,
        [9154] = true,
        --

        ----- TBC -------------- TBC quests --------------- TBC -----
        ----- TBC ------------- starting here -------------- TBC -----

        -- [BETA] quests
        [402] = true, -- Sirra is Busy
        [785] = true, -- A Strategic Alliance
        [999] = true, -- When Dreams Turn to Nightmares
        [1005] = true, -- What Lurks Beyond
        [1006] = true, -- What Lies Beyond
        [1099] = true, -- Goblins Win!
        [1263] = true, -- The Burning Inn <CHANGE TO GOSSIP>
        [1272] = true, -- Finding Reethe <CHANGE INTO GOSSIP>
        [1281] = true, -- Jim's Song <CHANGE TO GOSSIP>
        [1289] = true, -- Vimes's Report
        [1500] = true, -- Waking Naralex
        [7961] = true, -- Waskily Wabbits!
        [8478] = true, -- Choose Your Weapon
        [8489] = true, -- An Intact Converter
        [8896] = true, -- The Dwarven Spy
        [9168] = true, -- Heart of Deatholme
        [9342] = true, -- Marauding Crust Bursters
        [9344] = true, -- A Hasty Departure
        [9346] = true, -- When Helboars Fly
        [9357] = true, -- Report to Aeldon Sunbrand
        [9382] = true, -- The Fate of the Clefthoof
        [9408] = true, -- Forgotten Heroes
        [9511] = true, -- Kargath's Battle Plans
        [9568] = true, -- On the Offensive
        [9749] = true, -- They're Alive! Maybe...
        [9929] = true, -- The Missing Merchant
        [9930] = true, -- The Missing Merchant
        [9941] = true, -- Tracking Down the Culprits
        [9942] = true, -- Tracking Down the Culprits
        [9943] = true, -- Return to Thander
        [9947] = true, -- Return to Rokag
        [9949] = true, -- A Bird's-Eye View
        [9950] = true, -- A Bird's-Eye View
        [9952] = true, -- Prospector Balmoral
        [9953] = true, -- Lookout Nodak
        [9958] = true, -- Scouting the Defenses
        [9959] = true, -- Scouting the Defenses
        [9963] = true, -- Seeking Help from the Source
        [9964] = true, -- Seeking Help from the Source
        [9965] = true, -- A Show of Good Faith
        [9966] = true, -- A Show of Good Faith
        [9969] = true, -- The Final Reagents
        [9974] = true, -- The Final Reagents
        [9975] = true, -- Primal Magic
        [9976] = true, -- Primal Magic
        [9980] = true, -- Rescue Deirom!
        [9981] = true, -- Rescue Dugar!
        [9984] = true, -- Host of the Hidden City
        [9985] = true, -- Host of the Hidden City
        [9988] = true, -- A Dandy's Best Friend
        [9989] = true, -- Alien Spirits
        [10014] = true, -- The Firewing Point Project
        [10015] = true, -- The Firewing Point Project
        [10029] = true, -- The Spirits Are Calling
        [10046] = true, -- Through the Dark Portal
        [10053] = true, -- Dealing with Zeth'Gor
        [10054] = true, -- Impending Doom
        [10056] = true, -- Bleeding Hollow Supplies
        [10059] = true, -- Dealing With Zeth'Gor
        [10060] = true, -- Impending Doom
        [10061] = true, -- The Unyielding
        [10062] = true, -- Looking to the Leadership
        [10084] = true, -- Assault on Mageddon
        [10088] = true, -- When This Mine's a-Rockin'
        [10089] = true, -- Forge Camps of the Legion
        [10092] = true, -- Assault on Mageddon
        [10100] = true, -- The Mastermind
        [10122] = true, -- The Citadel's Reach
        [10125] = true, -- Mission: Disrupt Communications
        [10126] = true, -- Warboss Nekrogg's Orders
        [10127] = true, -- Mission: Sever the Tie
        [10128] = true, -- Saving Private Imarion
        [10130] = true, -- The Western Flank
        [10131] = true, -- Planning the Escape
        [10133] = true, -- Mission: Kill the Messenger
        [10135] = true, -- Mission: Be the Messenger
        [10137] = true, -- Provoking the Warboss
        [10138] = true, -- Under Whose Orders?
        [10139] = true, -- Dispatching the Commander
        [10145] = true, -- Mission: Sever the Tie UNUSED
        [10147] = true, -- Mission: Kill the Messenger
        [10148] = true, -- Mission: Be the Messenger
        [10149] = true, -- Mission: End All, Be All
        [10150] = true, -- The Citadel's Reach
        [10151] = true, -- Warboss Nekrogg's Orders
        [10152] = true, -- The Western Flank
        [10153] = true, -- Saving Scout Makha
        [10154] = true, -- Planning the Escape
        [10155] = true, -- Provoking the Warboss
        [10156] = true, -- Under Whose Orders?
        [10157] = true, -- Dispatching the Commander
        [10158] = true, -- Bleeding Hollow Supplies
        [10179] = true, -- The Custodian of Kirin'Var
        [10187] = true, -- A Message for the Archmage
        [10195] = true, -- Mercenary See, Mercenary Do
        [10196] = true, -- More Arakkoa Feathers
        [10207] = true, -- Forward Base: Reaver's Fall REUSE
        [10214] = true, -- When This Mine's a-Rockin'
        [10244] = true, -- R.T.F.R.C.M.
        [10260] = true, -- Netherologist Coppernickels
        [10292] = true, -- More Power!
        [10370] = true, -- Nazgrel's Command <TXT>
        [10375] = true, -- Obsidian Warbeads
        [10386] = true, -- The Fel Reaver Slayer
        [10387] = true, -- The Fel Reaver Slayer
        [10398] = true, -- Return to Honor Hold
        [10401] = true, -- Mission: End All, Be All
        [10404] = true, -- Against the Legion
        [10441] = true, -- Peddling the Goods
        [10716] = true, -- Test Flight: Raven's Wood <needs reward>
        [10815] = true, -- The Journal of Val'zareq: Portends of War
        [10841] = true, -- The Vengeful Harbringer
        [10844] = true, -- Forge Camp: Anger
        [10871] = true, -- Ally of the Netherwing
        [10872] = true, -- Zuluhed the Whacked
        [10925] = true, -- Evil Draws Near

        -- <NYI> quests
        [3482] = true, -- <NYI> <TXT> The Pocked Black Box
        [7741] = true, -- Praise from the Emerald Circle <NYI> <TXT>
        [8339] = true, -- Royalty of the Council <NYI> <TXT> UNUSED
        [8340] = true, -- Twilight Signet Ring <NYI> <TXT>

        -- [Not Used] quests
        [620] = true, -- UNUSED The Monogrammed Sash
        [1390] = true, -- BETA Oops, We Killed Them Again.
        [2019] = true, -- Tools of the Trade
        [5383] = true, -- Krastinov's Bag of Horrors
        [8530] = true, -- The Alliance Needs Singed Corestones!
        [8618] = true, -- The Horde Needs More Singed Corestones!
        [9380] = true, -- BETA Hounded for More
        [9510] = true, -- BETA Bristlehide Clefthoof Hides
        [9599] = true, -- <UNUSED>
        [9750] = true, -- UNUSED Urgent Delivery
        [9767] = true, -- Know Your Enemy
        [9955] = true, -- A Show of Good Faith
        [10090] = true, -- BETA The Legion's Plans
        [11027] = true, -- NOT IN GAME: Yous Have Da Darkrune? , "replaced" by 11060 (A Crystalforged Darkrune)

        [1] = true, -- Unavailable quest "The "Chow" Quest (123)aa"
        [2881] = QuestieCorrections.TBC_ONLY, -- Wildhammer faction removed in TBC. Repeatable to gain rep
        [8329] = true, -- Warrior Training / Not in the game
        [8547] = true, -- Welcome!
        [9065] = true, -- Unavailable quest "The "Chow" Quest (123)aa"
        [9278] = true, -- Welcome!
        [9681] = true, -- Replaced with [A Study in Power (64319)]
        [9684] = true, -- Replaced with [Claiming the Light (63866)]
        [9721] = true, -- Replaced with [A Summons from Lady Liadrin (64139)]
        [9722] = true, -- Replaced with [The Master's Path (64140)]
        [9723] = true, -- Replaced with [A Gesture of Commitment (64141)]
        [9725] = true, -- Replaced with [A Demonstration of Loyalty (64142)]
        [9735] = true, -- Replaced with [True Masters of the Light (64143)]
        [9736] = true, -- Replaced with [True Masters of the Light (64144)]
        [9737] = true, -- Replaced with [True Masters of the Light  (64145)]
        [9926] = true, -- FLAG Shadow Council/Warmaul Questline
        [10048] = true, -- A Handful of Magic Dust BETA
        [10049] = true, -- A Handful of Magic Dust BETA
        [10169] = true, -- Losing Gracefully (removed with 2.4.0)
        [10259] = true, -- Into the Breach (TBC Pre patch event)
        [10364] = true, -- Caedmos (Unavailable Priest quest)
        [10379] = true, -- Touch of Weakness (Followup of NOT A QUEST)
        [10534] = true, -- Returning Home (Unavailable Priest quest)
        [10539] = true, -- Returning Home (Unavailable Priest quest)
        [10638] = true, -- NOT A QUEST (Unavailable Priest quest)
        [10779] = true, -- The Hunter's Path (Unused)
        [10931] = true, -- Level 0 Priest quest
        [10932] = true, -- Level 0 Priest quest
        [10933] = true, -- Level 0 Priest quest
        [10934] = true, -- Level 0 Priest quest
        [64028] = true, -- First quest for boosted characters. Blocked to not show for others
        [64037] = true, -- Boosted character quest
        [64038] = true, -- Boosted character quest
        [64046] = true, -- First quest for boosted characters. Blocked to not show for others
        [64047] = true, -- First quest for boosted characters. Blocked to not show for others
        [64063] = true, -- Boosted character quest
        [64064] = true, -- Boosted character quest
        [64128] = true, -- Boosted character quest
        [64217] = true, -- Boosted character quest

        -- Revered Among X quests
        [10459] = true,
        [10558] = true,
        [10559] = true,
        [10560] = true,
        [10561] = true,

        [11497] = true, -- Learning to Fly (requires NOT to have flying skill, which can't be handled atm)
        [11498] = true, -- Learning to Fly (requires NOT to have flying skill, which can't be handled atm)

        -- [OLD] quests. Classic quests deprecated in TBC
        [708] = true,
        [909] = true,
        [1288] = true,
        [1661] = true,
        [3366] = true,
        [3381] = true,
        [5627] = true,
        [5641] = true,
        [5645] = true,
        [5647] = true,
        [6131] = true,
        [6221] = true,
        [6241] = true,
        [7364] = true,
        [7365] = true,
        [7421] = true,
        [7422] = true,
        [7423] = true,
        [7425] = true,
        [7426] = true,
        [7521] = true,
        [8368] = true,
        [8383] = true,
        [8384] = true,
        [8386] = true,
        [8387] = true,
        [8390] = true,
        [8391] = true,
        [8392] = true,
        [8397] = true,
        [8398] = true,
        [8404] = true,
        [8405] = true,
        [8406] = true,
        [8407] = true,
        [8408] = true,
        [8411] = true,
        [8426] = true,
        [8427] = true,
        [8428] = true,
        [8429] = true,
        [8430] = true,
        [8440] = true,
        [8441] = true,
        [8442] = true,
        [8443] = true,
        [9712] = true,
        [10377] = true,
        [11052] = true,

        -- Classic only PvP quests
        [8369] = QuestieCorrections.TBC_ONLY,
        [8370] = QuestieCorrections.TBC_ONLY,
        [8372] = QuestieCorrections.TBC_ONLY,
        [8374] = QuestieCorrections.TBC_ONLY,
        [8375] = QuestieCorrections.TBC_ONLY,
        [8389] = QuestieCorrections.TBC_ONLY,
        [8393] = QuestieCorrections.TBC_ONLY,
        [8394] = QuestieCorrections.TBC_ONLY,
        [8395] = QuestieCorrections.TBC_ONLY,
        [8396] = QuestieCorrections.TBC_ONLY,
        [8399] = QuestieCorrections.TBC_ONLY,
        [8400] = QuestieCorrections.TBC_ONLY,
        [8401] = QuestieCorrections.TBC_ONLY,
        [8402] = QuestieCorrections.TBC_ONLY,
        [8403] = QuestieCorrections.TBC_ONLY,
        [8431] = QuestieCorrections.TBC_ONLY,
        [8432] = QuestieCorrections.TBC_ONLY,
        [8433] = QuestieCorrections.TBC_ONLY,
        [8434] = QuestieCorrections.TBC_ONLY,
        [8435] = QuestieCorrections.TBC_ONLY,
        [8436] = QuestieCorrections.TBC_ONLY,
        [8437] = QuestieCorrections.TBC_ONLY,
        [8438] = QuestieCorrections.TBC_ONLY,
        [8439] = QuestieCorrections.TBC_ONLY,

        -- Phase 4 Zul'Aman
        [11195] = true, -- Not in the game
        [11196] = true, -- Not in the game

        ----- Wotlk -------------- Wotlk quests --------------- Wotlk -----
        ----- Wotlk ------------- starting here -------------- Wotlk -----

        [10888] = true, -- Got replaced by 13430
        [10901] = true, -- Got replaced by 13431
        [11551] = true, -- Not in the game
        [11552] = true, -- Not in the game
        [11553] = true, -- Not in the game
        [25229] = true, -- Not in the game

        --- Phase 2 Ulduar / Argent Tournament
        [13633] = true,
        [13634] = true,
        [13667] = true,
        [13668] = true,
        [13682] = true,
        [13789] = true,
        [13790] = true,
        [13809] = true,
        [13810] = true,
        [13811] = true,
        [13846] = true,
        [13861] = true,
        [13862] = true,
        [14101] = true,
        [14102] = true,
        [14104] = true,
        [14105] = true,
        [14107] = true,
        [14108] = true,

        --- Phase 3 Trial of the Crusader
        [14199] = true, -- Proof of Demise: The Black Knight (Daily heroic)

        --- Phase 4 Icecrown Citadel
        [24506] = true, -- Inside the Frozen Citadel
        [26012] = true, -- Trouble at Wyrmrest

        -- new raid weekly quests
        [24579] = true,
        [24580] = true,
        [24581] = true,
        [24582] = true,
        [24583] = true,
        [24584] = true,
        [24585] = true,
        [24586] = true,
        [24587] = true,
        [24588] = true,
        [24589] = true,
        [24590] = true,
    }

    if Questie.IsSoM then
        Questie:Debug(Questie.DEBUG_DEVELOP, "Blacklisting SoM quests...")
        local questsByPhase = QuestieQuestBlacklist:GetSoMQuestsToBlacklist()
        for phase= 1, #questsByPhase do
            for questId, _ in pairs(questsByPhase[phase]) do
                questsToBlacklist[questId] = true
            end
        end
    end

    return questsToBlacklist
end

QuestieQuestBlacklist.AQWarEffortQuests = {
    -- Commendation Signet
    [8811] = true,
    [8812] = true,
    [8813] = true,
    [8814] = true,
    [8815] = true,
    [8816] = true,
    [8817] = true,
    [8818] = true,
    [8819] = true,
    [8820] = true,
    [8821] = true,
    [8822] = true,
    [8823] = true,
    [8824] = true,
    [8825] = true,
    [8826] = true,
    [8830] = true,
    [8831] = true,
    [8832] = true,
    [8833] = true,
    [8834] = true,
    [8835] = true,
    [8836] = true,
    [8837] = true,
    [8838] = true,
    [8839] = true,
    [8840] = true,
    [8841] = true,
    [8842] = true,
    [8843] = true,
    [8844] = true,
    [8845] = true,
    [8846] = true,
    [8847] = true,
    [8848] = true,
    [8849] = true,
    [8850] = true,
    [8851] = true,
    [8852] = true,
    [8853] = true,
    [8854] = true,
    [8855] = true,
    -- War Effort
    [8492] = true,
    [8493] = true,
    [8494] = true,
    [8495] = true,
    [8499] = true,
    [8500] = true,
    [8503] = true,
    [8504] = true,
    [8505] = true,
    [8506] = true,
    [8509] = true,
    [8510] = true,
    [8511] = true,
    [8512] = true,
    [8513] = true,
    [8514] = true,
    [8515] = true,
    [8516] = true,
    [8517] = true,
    [8518] = true,
    [8520] = true,
    [8521] = true,
    [8522] = true,
    [8523] = true,
    [8524] = true,
    [8525] = true,
    [8526] = true,
    [8527] = true,
    [8528] = true,
    [8529] = true,
    [8532] = true,
    [8533] = true,
    [8542] = true,
    [8543] = true,
    [8545] = true,
    [8546] = true,
    [8549] = true,
    [8550] = true,
    [8580] = true,
    [8581] = true,
    [8582] = true,
    [8583] = true,
    [8588] = true,
    [8589] = true,
    [8590] = true,
    [8591] = true,
    [8600] = true,
    [8601] = true,
    [8604] = true,
    [8605] = true,
    [8607] = true,
    [8608] = true,
    [8609] = true,
    [8610] = true,
    [8611] = true,
    [8612] = true,
    [8613] = true,
    [8614] = true,
    [8615] = true,
    [8616] = true,
    [8792] = true,
    [8793] = true,
    [8794] = true,
    [8795] = true,
    [8796] = true,
    [8797] = true,
    [10500] = true,
    [10501] = true,
}

function QuestieQuestBlacklist.LoadAutoBlacklistWotlk()
    return {
        [781] = true, --* Attack on Camp Narache (https://wotlk.wowhead.com/wotlk/quest=781)
        [1048] = true, --* Into The Scarlet Monastery (https://wotlk.wowhead.com/wotlk/quest=1048)
        [1132] = true, --* Fiora Longears (https://wotlk.wowhead.com/wotlk/quest=1132)
        [1133] = true, --* Journey to Astranaar (https://wotlk.wowhead.com/wotlk/quest=1133)
        [1289] = true, --* <nyi> Vimes's Report (https://wotlk.wowhead.com/wotlk/quest=1289)
        [1390] = true, --* <nyi> Oops, We Killed Them Again. (https://wotlk.wowhead.com/wotlk/quest=1390)
        [1470] = true, --* Piercing the Veil (https://wotlk.wowhead.com/wotlk/quest=1470)
        [1485] = true, --* Vile Familiars (https://wotlk.wowhead.com/wotlk/quest=1485)
        [1598] = true, --* The Stolen Tome (https://wotlk.wowhead.com/wotlk/quest=1598)
        [1599] = true, --* Beginnings (https://wotlk.wowhead.com/wotlk/quest=1599)
        [1978] = true, --* The Deathstalkers (https://wotlk.wowhead.com/wotlk/quest=1978)
        [2018] = true, --* Rokar's Test (https://wotlk.wowhead.com/wotlk/quest=2018)
        [2019] = true, --* Tools of the Trade (https://wotlk.wowhead.com/wotlk/quest=2019)
        [3638] = true, --* The Pledge of Secrecy (https://wotlk.wowhead.com/wotlk/quest=3638)
        [3640] = true, --* The Pledge of Secrecy (https://wotlk.wowhead.com/wotlk/quest=3640)
        [3642] = true, --* The Pledge of Secrecy (https://wotlk.wowhead.com/wotlk/quest=3642)
        [5725] = true, --* The Power to Destroy... (https://wotlk.wowhead.com/wotlk/quest=5725)
        [6843] = true, --* Da Foo (https://wotlk.wowhead.com/wotlk/quest=6843)
        [7361] = true, --* Favor Amongst the Darkspear (https://wotlk.wowhead.com/wotlk/quest=7361)
        [7362] = true, --* Ally of the Tauren (https://wotlk.wowhead.com/wotlk/quest=7362)
        [7363] = true, --* The Human Condition (https://wotlk.wowhead.com/wotlk/quest=7363)
        [7364] = true, --* Gnomeregan Bounty (https://wotlk.wowhead.com/wotlk/quest=7364)
        [7365] = true, --* Staghelm's Requiem (https://wotlk.wowhead.com/wotlk/quest=7365)
        [7366] = true, --* The Archbishop's Mercy (https://wotlk.wowhead.com/wotlk/quest=7366)
        [7381] = true, --* The Return of Korrak (https://wotlk.wowhead.com/wotlk/quest=7381)
        [7382] = true, --* Korrak the Everliving (https://wotlk.wowhead.com/wotlk/quest=7382)
        [7401] = true, --* Wanted: DWARVES! (https://wotlk.wowhead.com/wotlk/quest=7401)
        [7402] = true, --* Wanted: ORCS! (https://wotlk.wowhead.com/wotlk/quest=7402)
        [7421] = true, --* Darkspear Defense (https://wotlk.wowhead.com/wotlk/quest=7421)
        [7422] = true, --* Tuft it Out (https://wotlk.wowhead.com/wotlk/quest=7422)
        [7423] = true, --* I've Got A Fever For More Bone Chips (https://wotlk.wowhead.com/wotlk/quest=7423)
        [7424] = true, --* What the Hoof? (https://wotlk.wowhead.com/wotlk/quest=7424)
        [7425] = true, --* Staghelm's Mojo Jamboree (https://wotlk.wowhead.com/wotlk/quest=7425)
        [7426] = true, --* One Man's Love (https://wotlk.wowhead.com/wotlk/quest=7426)
        [7427] = true, --* Wanted: MORE DWARVES! (https://wotlk.wowhead.com/wotlk/quest=7427)
        [7428] = true, --* Wanted: MORE ORCS! (https://wotlk.wowhead.com/wotlk/quest=7428)
        [7507] = true, --* Foror's Compendium (https://wotlk.wowhead.com/wotlk/quest=7507)
        [7508] = true, --* The Forging of Quel'Serrar (https://wotlk.wowhead.com/wotlk/quest=7508)
        [7509] = true, --* The Forging of Quel'Serrar (https://wotlk.wowhead.com/wotlk/quest=7509)
        [7521] = true, --* Thunderaan the Windseeker (https://wotlk.wowhead.com/wotlk/quest=7521)
        [7522] = true, --* Examine the Vessel (https://wotlk.wowhead.com/wotlk/quest=7522)
        [7741] = true, --* Praise from the Emerald Circle <NYI> <TXT> (https://wotlk.wowhead.com/wotlk/quest=7741)
        [7886] = true, --* Talismans of Merit (https://wotlk.wowhead.com/wotlk/quest=7886)
        [7887] = true, --* Talismans of Merit (https://wotlk.wowhead.com/wotlk/quest=7887)
        [7888] = true, --* Talismans of Merit (https://wotlk.wowhead.com/wotlk/quest=7888)
        [7906] = true, --* Darkmoon Cards - Beasts (https://wotlk.wowhead.com/wotlk/quest=7906)
        [7921] = true, --* Talismans of Merit (https://wotlk.wowhead.com/wotlk/quest=7921)
        [7922] = true, --* Mark of Honor (https://wotlk.wowhead.com/wotlk/quest=7922)
        [7923] = true, --* Mark of Honor (https://wotlk.wowhead.com/wotlk/quest=7923)
        [7924] = true, --* Mark of Honor (https://wotlk.wowhead.com/wotlk/quest=7924)
        [7925] = true, --* Mark of Honor (https://wotlk.wowhead.com/wotlk/quest=7925)
        [8001] = true, --* Warsong Outriders <NYI> <TXT> (https://wotlk.wowhead.com/wotlk/quest=8001)
        [8002] = true, --* Silverwing Sentinels <NYI> <TXT> (https://wotlk.wowhead.com/wotlk/quest=8002)
        [8081] = true, --* More Resource Crates (https://wotlk.wowhead.com/wotlk/quest=8081)
        [8124] = true, --* More Resource Crates (https://wotlk.wowhead.com/wotlk/quest=8124)
        [8157] = true, --* More Resource Crates (https://wotlk.wowhead.com/wotlk/quest=8157)
        [8158] = true, --* More Resource Crates (https://wotlk.wowhead.com/wotlk/quest=8158)
        [8159] = true, --* More Resource Crates (https://wotlk.wowhead.com/wotlk/quest=8159)
        [8163] = true, --* More Resource Crates (https://wotlk.wowhead.com/wotlk/quest=8163)
        [8164] = true, --* More Resource Crates (https://wotlk.wowhead.com/wotlk/quest=8164)
        [8165] = true, --* More Resource Crates (https://wotlk.wowhead.com/wotlk/quest=8165)
        [8230] = true, --* Collin's Test Quest (https://wotlk.wowhead.com/wotlk/quest=8230)
        [8267] = true, --* Ribbons of Sacrifice (https://wotlk.wowhead.com/wotlk/quest=8267)
        [8269] = true, --* Ribbons of Sacrifice (https://wotlk.wowhead.com/wotlk/quest=8269)
        [8289] = true, --* Talismans of Merit (https://wotlk.wowhead.com/wotlk/quest=8289)
        [8292] = true, --* Talismans of Merit (https://wotlk.wowhead.com/wotlk/quest=8292)
        [8293] = true, --* Mark of Honor (https://wotlk.wowhead.com/wotlk/quest=8293)
        [8296] = true, --* Mark of Honor (https://wotlk.wowhead.com/wotlk/quest=8296)
        [8298] = true, --* More Resource Crates (https://wotlk.wowhead.com/wotlk/quest=8298)
        [8300] = true, --* More Resource Crates (https://wotlk.wowhead.com/wotlk/quest=8300)
        [8329] = true, --* Warrior Training (https://wotlk.wowhead.com/wotlk/quest=8329)
        [8340] = true, --* Twilight Signet Ring <NYI> <TXT> (https://wotlk.wowhead.com/wotlk/quest=8340)
        [8344] = true, --* Windows to the Source (https://wotlk.wowhead.com/wotlk/quest=8344)
        [8478] = true, --* Choose Your Weapon (https://wotlk.wowhead.com/wotlk/quest=8478)
        [8618] = true, --* The Horde Needs More Singed Corestones! (https://wotlk.wowhead.com/wotlk/quest=8618)
        [9342] = true, --* Marauding Crust Bursters (https://wotlk.wowhead.com/wotlk/quest=9342)
        [9344] = true, --* A Hasty Departure (https://wotlk.wowhead.com/wotlk/quest=9344)
        [9346] = true, --* When Helboars Fly (https://wotlk.wowhead.com/wotlk/quest=9346)
        [9378] = true, --* DND FLAG The Dread Citadel - Naxxramas (https://wotlk.wowhead.com/wotlk/quest=9378)
        [9382] = true, --* The Fate of the Clefthoof (https://wotlk.wowhead.com/wotlk/quest=9382)
        [9510] = true, --* Bristlehide Clefthoof Hides (https://wotlk.wowhead.com/wotlk/quest=9510)
        [9713] = true, --* Glowcap Harvesting Enabling Flag (https://wotlk.wowhead.com/wotlk/quest=9713)
        [9926] = true, --* FLAG Shadow Council/Warmaul Questline (https://wotlk.wowhead.com/wotlk/quest=9926)
        [9929] = true, --* The Missing Merchant (https://wotlk.wowhead.com/wotlk/quest=9929)
        [9930] = true, --* The Missing Merchant (https://wotlk.wowhead.com/wotlk/quest=9930)
        [9941] = true, --* Tracking Down the Culprits (https://wotlk.wowhead.com/wotlk/quest=9941)
        [9942] = true, --* Tracking Down the Culprits (https://wotlk.wowhead.com/wotlk/quest=9942)
        [9943] = true, --* Return to Thander (https://wotlk.wowhead.com/wotlk/quest=9943)
        [9947] = true, --* Return to Rokag (https://wotlk.wowhead.com/wotlk/quest=9947)
        [9949] = true, --* A Bird's-Eye View (https://wotlk.wowhead.com/wotlk/quest=9949)
        [9950] = true, --* A Bird's-Eye View (https://wotlk.wowhead.com/wotlk/quest=9950)
        [9952] = true, --* Prospector Balmoral (https://wotlk.wowhead.com/wotlk/quest=9952)
        [9953] = true, --* Lookout Nodak (https://wotlk.wowhead.com/wotlk/quest=9953)
        [9958] = true, --* Scouting the Defenses (https://wotlk.wowhead.com/wotlk/quest=9958)
        [9959] = true, --* Scouting the Defenses (https://wotlk.wowhead.com/wotlk/quest=9959)
        [9963] = true, --* Seeking Help from the Source (https://wotlk.wowhead.com/wotlk/quest=9963)
        [9964] = true, --* Seeking Help from the Source (https://wotlk.wowhead.com/wotlk/quest=9964)
        [9965] = true, --* A Show of Good Faith (https://wotlk.wowhead.com/wotlk/quest=9965)
        [9966] = true, --* A Show of Good Faith (https://wotlk.wowhead.com/wotlk/quest=9966)
        [9969] = true, --* The Final Reagents (https://wotlk.wowhead.com/wotlk/quest=9969)
        [9974] = true, --* The Final Reagents (https://wotlk.wowhead.com/wotlk/quest=9974)
        [9975] = true, --* Primal Magic (https://wotlk.wowhead.com/wotlk/quest=9975)
        [9976] = true, --* Primal Magic (https://wotlk.wowhead.com/wotlk/quest=9976)
        [9980] = true, --* Rescue Deirom! (https://wotlk.wowhead.com/wotlk/quest=9980)
        [9981] = true, --* Rescue Dugar! (https://wotlk.wowhead.com/wotlk/quest=9981)
        [10048] = true, --* A Handful of Magic Dust (https://wotlk.wowhead.com/wotlk/quest=10048)
        [10049] = true, --* A Handful of Magic Dust (https://wotlk.wowhead.com/wotlk/quest=10049)
        [10053] = true, --* Dealing with Zeth'Gor (https://wotlk.wowhead.com/wotlk/quest=10053)
        [10054] = true, --* Impending Doom (https://wotlk.wowhead.com/wotlk/quest=10054)
        [10056] = true, --* Bleeding Hollow Supplies (https://wotlk.wowhead.com/wotlk/quest=10056)
        [10059] = true, --* Dealing With Zeth'Gor (https://wotlk.wowhead.com/wotlk/quest=10059)
        [10060] = true, --* Impending Doom (https://wotlk.wowhead.com/wotlk/quest=10060)
        [10062] = true, --* Looking to the Leadership (https://wotlk.wowhead.com/wotlk/quest=10062)
        [10084] = true, --* Assault on Mageddon (https://wotlk.wowhead.com/wotlk/quest=10084)
        [10088] = true, --* When This Mine's a-Rockin' (https://wotlk.wowhead.com/wotlk/quest=10088)
        [10089] = true, --* Forge Camps of the Legion (https://wotlk.wowhead.com/wotlk/quest=10089)
        [10090] = true, --* The Legion's Plans (https://wotlk.wowhead.com/wotlk/quest=10090)
        [10092] = true, --* Assault on Mageddon (https://wotlk.wowhead.com/wotlk/quest=10092)
        [10100] = true, --* The Mastermind (https://wotlk.wowhead.com/wotlk/quest=10100)
        [10126] = true, --* Warboss Nekrogg's Orders (https://wotlk.wowhead.com/wotlk/quest=10126)
        [10128] = true, --* Saving Private Imarion (https://wotlk.wowhead.com/wotlk/quest=10128)
        [10131] = true, --* Planning the Escape (https://wotlk.wowhead.com/wotlk/quest=10131)
        [10133] = true, --* Mission: Kill the Messenger (https://wotlk.wowhead.com/wotlk/quest=10133)
        [10135] = true, --* Mission: Be the Messenger (https://wotlk.wowhead.com/wotlk/quest=10135)
        [10137] = true, --* Provoking the Warboss (https://wotlk.wowhead.com/wotlk/quest=10137)
        [10138] = true, --* Under Whose Orders? (https://wotlk.wowhead.com/wotlk/quest=10138)
        [10139] = true, --* Dispatching the Commander (https://wotlk.wowhead.com/wotlk/quest=10139)
        [10147] = true, --* Mission: Kill the Messenger (https://wotlk.wowhead.com/wotlk/quest=10147)
        [10148] = true, --* Mission: Be the Messenger (https://wotlk.wowhead.com/wotlk/quest=10148)
        [10149] = true, --* Mission: End All, Be All (https://wotlk.wowhead.com/wotlk/quest=10149)
        [10151] = true, --* Warboss Nekrogg's Orders (https://wotlk.wowhead.com/wotlk/quest=10151)
        [10153] = true, --* Saving Scout Makha (https://wotlk.wowhead.com/wotlk/quest=10153)
        [10154] = true, --* Planning the Escape (https://wotlk.wowhead.com/wotlk/quest=10154)
        [10155] = true, --* Provoking the Warboss (https://wotlk.wowhead.com/wotlk/quest=10155)
        [10156] = true, --* Under Whose Orders? (https://wotlk.wowhead.com/wotlk/quest=10156)
        [10157] = true, --* Dispatching the Commander (https://wotlk.wowhead.com/wotlk/quest=10157)
        [10158] = true, --* Bleeding Hollow Supplies (https://wotlk.wowhead.com/wotlk/quest=10158)
        [10195] = true, --* Mercenary See, Mercenary Do (https://wotlk.wowhead.com/wotlk/quest=10195)
        [10219] = true, --* Walk the Dog (https://wotlk.wowhead.com/wotlk/quest=10219)
        [10398] = true, --* Return to Honor Hold (https://wotlk.wowhead.com/wotlk/quest=10398)
        [10401] = true, --* Mission: End All, Be All (https://wotlk.wowhead.com/wotlk/quest=10401)
        [10454] = true, --* FLAG - OFF THE RAILS (https://wotlk.wowhead.com/wotlk/quest=10454)
        [10533] = true, --* More Resource Crates (https://wotlk.wowhead.com/wotlk/quest=10533)
        [10536] = true, --* More Resource Crates (https://wotlk.wowhead.com/wotlk/quest=10536)
        [10610] = true, --* Prospecting Basics (https://wotlk.wowhead.com/wotlk/quest=10610)
        [10841] = true, --* The Vengeful Harbinger (https://wotlk.wowhead.com/wotlk/quest=10841)
        [10925] = true, --* Evil Draws Near (https://wotlk.wowhead.com/wotlk/quest=10925)
        [11116] = true, --* Trial of the Naaru: (QUEST FLAG) (https://wotlk.wowhead.com/wotlk/quest=11116)
        [11486] = true, --* The Best of Brews (https://wotlk.wowhead.com/wotlk/quest=11486)
        [11487] = true, --* The Best of Brews (https://wotlk.wowhead.com/wotlk/quest=11487)
        [11518] = true, --* Sunwell Daily Portal Flag (https://wotlk.wowhead.com/wotlk/quest=11518)
        [11552] = true, --* Rohendor, the Second Gate (https://wotlk.wowhead.com/wotlk/quest=11552)
        [11553] = true, --* Archonisus, the Final Gate (https://wotlk.wowhead.com/wotlk/quest=11553)
        [11577] = true, --* WoW Collector's Edition: - DEM - E - FLAG (https://wotlk.wowhead.com/wotlk/quest=11577)
        [11874] = true, --* Upper Deck Promo - Rocket Mount (https://wotlk.wowhead.com/wotlk/quest=11874)
        [11937] = true, --* FLAG - all torch return quests are complete (https://wotlk.wowhead.com/wotlk/quest=11937)
        [11994] = true, --* Juno's Flag Tester (https://wotlk.wowhead.com/wotlk/quest=11994)
        [12023] = true, --* Sweeter Revenge (https://wotlk.wowhead.com/wotlk/quest=12023)
        [12103] = true, --* DEPRECATED (https://wotlk.wowhead.com/wotlk/quest=12103)
        [12186] = true, --* FLAG: Winner (https://wotlk.wowhead.com/wotlk/quest=12186)
        [12187] = true, --* FLAG: Participant (https://wotlk.wowhead.com/wotlk/quest=12187)
        [12228] = true, --* Reacquiring the Magic [PH] (https://wotlk.wowhead.com/wotlk/quest=12228)
        [12485] = true, --* Howling Fjord: aa - A - LK FLAG (https://wotlk.wowhead.com/wotlk/quest=12485)
        [12494] = true, --* FLAG: Riding Trainer Advertisement (20) (https://wotlk.wowhead.com/wotlk/quest=12494)
        [12600] = true, --* Upper Deck Promo - Bear Mount (https://wotlk.wowhead.com/wotlk/quest=12600)
        [12693] = true, --* Wolvar Faction Choice Tracker (https://wotlk.wowhead.com/wotlk/quest=12693)
        [12694] = true, --* Oracle Faction Choice Tracker (https://wotlk.wowhead.com/wotlk/quest=12694)
        [12764] = true, --* The Secret to Kungaloosh (DEPRECATED) (https://wotlk.wowhead.com/wotlk/quest=12764)
        [12765] = true, --* Kungaloosh (DEPRECATED) (https://wotlk.wowhead.com/wotlk/quest=12765)
        [12784] = true, --* Desperate Research (https://wotlk.wowhead.com/wotlk/quest=12784)
        [12809] = true, --* Ironforge (https://wotlk.wowhead.com/wotlk/quest=12809)
        [12845] = true, --* Dalaran Teleport Crystal Flag (https://wotlk.wowhead.com/wotlk/quest=12845)
        [13123] = true, --* WotLK Collector's Edition: - DEM - E - FLAG (https://wotlk.wowhead.com/wotlk/quest=13123)
        [13134] = true, --* Spill Their Blood (https://wotlk.wowhead.com/wotlk/quest=13134)
        [13136] = true, --* Jagged Shards (https://wotlk.wowhead.com/wotlk/quest=13136)
        [13138] = true, --* I'm Smelting... Smelting! (https://wotlk.wowhead.com/wotlk/quest=13138)
        [13140] = true, --* The Runesmiths of Malykriss (https://wotlk.wowhead.com/wotlk/quest=13140)
        [13143] = true, --* New Recruit (https://wotlk.wowhead.com/wotlk/quest=13143)
        [13144] = true, --* Killing Two Scourge With One Skeleton (https://wotlk.wowhead.com/wotlk/quest=13144)
        [13145] = true, --* The Vile Hold (https://wotlk.wowhead.com/wotlk/quest=13145)
        [13146] = true, --* Generosity Abounds (https://wotlk.wowhead.com/wotlk/quest=13146)
        [13147] = true, --* Matchmaker (https://wotlk.wowhead.com/wotlk/quest=13147)
        [13152] = true, --* A Visit to the Doctor (https://wotlk.wowhead.com/wotlk/quest=13152)
        [13153] = true, --* Warding the Warriors (https://wotlk.wowhead.com/wotlk/quest=13153)
        [13154] = true, --* Bones and Arrows (https://wotlk.wowhead.com/wotlk/quest=13154)
        [13155] = true, --* Vereth the Cunning (https://wotlk.wowhead.com/wotlk/quest=13155)
        [13160] = true, --* Stunning View (https://wotlk.wowhead.com/wotlk/quest=13160)
        [13161] = true, --* The Rider of the Unholy (https://wotlk.wowhead.com/wotlk/quest=13161)
        [13162] = true, --* The Rider of Frost (https://wotlk.wowhead.com/wotlk/quest=13162)
        [13163] = true, --* The Rider of Blood (https://wotlk.wowhead.com/wotlk/quest=13163)
        [13164] = true, --* The Fate of Bloodbane (https://wotlk.wowhead.com/wotlk/quest=13164)
        [13168] = true, --* Parting Gifts (https://wotlk.wowhead.com/wotlk/quest=13168)
        [13169] = true, --* An Undead's Best Friend (https://wotlk.wowhead.com/wotlk/quest=13169)
        [13170] = true, --* Honor is for the Weak (https://wotlk.wowhead.com/wotlk/quest=13170)
        [13171] = true, --* From Whence They Came (https://wotlk.wowhead.com/wotlk/quest=13171)
        [13172] = true, --* Seeds of Chaos (https://wotlk.wowhead.com/wotlk/quest=13172)
        [13174] = true, --* Amidst the Confusion (https://wotlk.wowhead.com/wotlk/quest=13174)
        [13192] = true, --* Warding the Walls (https://wotlk.wowhead.com/wotlk/quest=13192)
        [13195] = true, --* A Rare Herb (https://wotlk.wowhead.com/wotlk/quest=13195)
        [13196] = true, --* Bones and Arrows (https://wotlk.wowhead.com/wotlk/quest=13196)
        [13198] = true, --* Warding the Warriors (https://wotlk.wowhead.com/wotlk/quest=13198)
        [13199] = true, --* Bones and Arrows (https://wotlk.wowhead.com/wotlk/quest=13199)
        [13202] = true, --* Jinxing the Walls (https://wotlk.wowhead.com/wotlk/quest=13202)
        [13210] = true, --* Blizzard Account: - DEM - E - FLAG (https://wotlk.wowhead.com/wotlk/quest=13210)
        [13211] = true, --* By Fire Be Purged (https://wotlk.wowhead.com/wotlk/quest=13211)
        [13212] = true, --* He's Gone to Pieces (https://wotlk.wowhead.com/wotlk/quest=13212)
        [13220] = true, --* Putting Olakin Back Together Again (https://wotlk.wowhead.com/wotlk/quest=13220)
        [13221] = true, --* I'm Not Dead Yet! (https://wotlk.wowhead.com/wotlk/quest=13221)
        [13229] = true, --* I'm Not Dead Yet! (https://wotlk.wowhead.com/wotlk/quest=13229)
        [13235] = true, --* The Flesh Giant Champion (https://wotlk.wowhead.com/wotlk/quest=13235)
        [13236] = true, --* Army of the Damned (https://wotlk.wowhead.com/wotlk/quest=13236)
        [13271] = true, --* A Voice in the Dark (https://wotlk.wowhead.com/wotlk/quest=13271)
        [13275] = true, --* Time to Hide (https://wotlk.wowhead.com/wotlk/quest=13275)
        [13281] = true, --* Neutralizing the Plague (https://wotlk.wowhead.com/wotlk/quest=13281)
        [13282] = true, --* Return to the Surface (https://wotlk.wowhead.com/wotlk/quest=13282)
        [13304] = true, --* Field Repairs (https://wotlk.wowhead.com/wotlk/quest=13304)
        [13305] = true, --* Do Your Worst (https://wotlk.wowhead.com/wotlk/quest=13305)
        [13331] = true, --* Keeping the Alliance Blind (https://wotlk.wowhead.com/wotlk/quest=13331)
        [13348] = true, --* Futility (https://wotlk.wowhead.com/wotlk/quest=13348)
        [13349] = true, --* Cradle of the Frostbrood (https://wotlk.wowhead.com/wotlk/quest=13349)
        [13359] = true, --* Where Dragons Fell (https://wotlk.wowhead.com/wotlk/quest=13359)
        [13360] = true, --* Time for Answers (https://wotlk.wowhead.com/wotlk/quest=13360)
        [13361] = true, --* The Hunter and the Prince (https://wotlk.wowhead.com/wotlk/quest=13361)
        [13362] = true, --* Knowledge is a Terrible Burden (https://wotlk.wowhead.com/wotlk/quest=13362)
        [13363] = true, --* Argent Aid (https://wotlk.wowhead.com/wotlk/quest=13363)
        [13364] = true, --* Tirion's Gambit (https://wotlk.wowhead.com/wotlk/quest=13364)
        [13390] = true, --* A Voice in the Dark (https://wotlk.wowhead.com/wotlk/quest=13390)
        [13391] = true, --* Time to Hide (https://wotlk.wowhead.com/wotlk/quest=13391)
        [13392] = true, --* Return to the Surface (https://wotlk.wowhead.com/wotlk/quest=13392)
        [13393] = true, --* Field Repairs (https://wotlk.wowhead.com/wotlk/quest=13393)
        [13394] = true, --* Do Your Worst (https://wotlk.wowhead.com/wotlk/quest=13394)
        [13395] = true, --* Army of the Damned (https://wotlk.wowhead.com/wotlk/quest=13395)
        [13396] = true, --* Futility (https://wotlk.wowhead.com/wotlk/quest=13396)
        [13397] = true, --* Sindragosa's Fall (https://wotlk.wowhead.com/wotlk/quest=13397)
        [13398] = true, --* Where Dragons Fell (https://wotlk.wowhead.com/wotlk/quest=13398)
        [13399] = true, --* Time for Answers (https://wotlk.wowhead.com/wotlk/quest=13399)
        [13400] = true, --* The Hunter and the Prince (https://wotlk.wowhead.com/wotlk/quest=13400)
        [13401] = true, --* Knowledge is a Terrible Burden (https://wotlk.wowhead.com/wotlk/quest=13401)
        [13402] = true, --* Tirion's Help (https://wotlk.wowhead.com/wotlk/quest=13402)
        [13403] = true, --* Tirion's Gambit (https://wotlk.wowhead.com/wotlk/quest=13403)
        [13431] = true, --* The Cudgel of Kar'desh (https://wotlk.wowhead.com/wotlk/quest=13431)
        [13481] = true, --* Let's Get Out of Here! (https://wotlk.wowhead.com/wotlk/quest=13481)
        [13482] = true, --* Let's Get Out of Here (https://wotlk.wowhead.com/wotlk/quest=13482)
        [13592] = true, --* A Valiant's Field Training (https://wotlk.wowhead.com/wotlk/quest=13592)
        [13593] = true, --* Valiant Of Stormwind (https://wotlk.wowhead.com/wotlk/quest=13593)
        [13600] = true, --* A Worthy Weapon (https://wotlk.wowhead.com/wotlk/quest=13600)
        [13603] = true, --* A Blade Fit For A Champion (https://wotlk.wowhead.com/wotlk/quest=13603)
        [13616] = true, --* The Edge Of Winter (https://wotlk.wowhead.com/wotlk/quest=13616)
        [13625] = true, --* Learning The Reins (https://wotlk.wowhead.com/wotlk/quest=13625)
        [13627] = true, --* Jack Me Some Lumber (https://wotlk.wowhead.com/wotlk/quest=13627)
        [13633] = true, --* The Black Knight of Westfall? (https://wotlk.wowhead.com/wotlk/quest=13633)
        [13634] = true, --* The Black Knight of Silverpine? (https://wotlk.wowhead.com/wotlk/quest=13634)
        [13641] = true, --* The Seer's Crystal (https://wotlk.wowhead.com/wotlk/quest=13641)
        [13643] = true, --* The Stories Dead Men Tell (https://wotlk.wowhead.com/wotlk/quest=13643)
        [13654] = true, --* There's Something About the Squire (https://wotlk.wowhead.com/wotlk/quest=13654)
        [13663] = true, --* The Black Knight's Orders (https://wotlk.wowhead.com/wotlk/quest=13663)
        [13664] = true, --* The Black Knight's Fall (https://wotlk.wowhead.com/wotlk/quest=13664)
        [13665] = true, --* The Grand Melee (https://wotlk.wowhead.com/wotlk/quest=13665)
        [13666] = true, --* A Blade Fit For A Champion (https://wotlk.wowhead.com/wotlk/quest=13666)
        [13667] = true, --* The Argent Tournament (https://wotlk.wowhead.com/wotlk/quest=13667)
        [13668] = true, --* The Argent Tournament (https://wotlk.wowhead.com/wotlk/quest=13668)
        [13669] = true, --* A Worthy Weapon (https://wotlk.wowhead.com/wotlk/quest=13669)
        [13670] = true, --* The Edge Of Winter (https://wotlk.wowhead.com/wotlk/quest=13670)
        [13671] = true, --* Training In The Field (https://wotlk.wowhead.com/wotlk/quest=13671)
        [13672] = true, --* Up To The Challenge (https://wotlk.wowhead.com/wotlk/quest=13672)
        [13673] = true, --* A Blade Fit For A Champion (https://wotlk.wowhead.com/wotlk/quest=13673)
        [13674] = true, --* A Worthy Weapon (https://wotlk.wowhead.com/wotlk/quest=13674)
        [13675] = true, --* The Edge Of Winter (https://wotlk.wowhead.com/wotlk/quest=13675)
        [13676] = true, --* Training In The Field (https://wotlk.wowhead.com/wotlk/quest=13676)
        [13677] = true, --* Learning The Reins (https://wotlk.wowhead.com/wotlk/quest=13677)
        [13678] = true, --* Up To The Challenge (https://wotlk.wowhead.com/wotlk/quest=13678)
        [13679] = true, --* The Aspirant's Challenge (https://wotlk.wowhead.com/wotlk/quest=13679)
        [13680] = true, --* The Aspirant's Challenge (https://wotlk.wowhead.com/wotlk/quest=13680)
        [13681] = true, --* A Chip Off the Ulduar Block (https://wotlk.wowhead.com/wotlk/quest=13681)
        [13682] = true, --* Threat From Above (https://wotlk.wowhead.com/wotlk/quest=13682)
        [13684] = true, --* A Valiant Of Stormwind (https://wotlk.wowhead.com/wotlk/quest=13684)
        [13685] = true, --* A Valiant Of Ironforge (https://wotlk.wowhead.com/wotlk/quest=13685)
        [13686] = true, --* Alliance Tournament Eligibility Marker (https://wotlk.wowhead.com/wotlk/quest=13686)
        [13687] = true, --* Horde Tournament Eligibility Marker (https://wotlk.wowhead.com/wotlk/quest=13687)
        [13688] = true, --* A Valiant Of Gnomeregan (https://wotlk.wowhead.com/wotlk/quest=13688)
        [13689] = true, --* A Valiant Of Darnassus (https://wotlk.wowhead.com/wotlk/quest=13689)
        [13690] = true, --* A Valiant Of The Exodar (https://wotlk.wowhead.com/wotlk/quest=13690)
        [13691] = true, --* A Valiant Of Orgrimmar (https://wotlk.wowhead.com/wotlk/quest=13691)
        [13693] = true, --* A Valiant Of Sen'jin (https://wotlk.wowhead.com/wotlk/quest=13693)
        [13694] = true, --* A Valiant Of Thunder Bluff (https://wotlk.wowhead.com/wotlk/quest=13694)
        [13695] = true, --* A Valiant Of Undercity (https://wotlk.wowhead.com/wotlk/quest=13695)
        [13696] = true, --* A Valiant Of Silvermoon (https://wotlk.wowhead.com/wotlk/quest=13696)
        [13697] = true, --* The Valiant's Charge (https://wotlk.wowhead.com/wotlk/quest=13697)
        [13699] = true, --* The Valiant's Challenge (https://wotlk.wowhead.com/wotlk/quest=13699)
        [13700] = true, --* Alliance Champion Marker (https://wotlk.wowhead.com/wotlk/quest=13700)
        [13701] = true, --* Horde Champion Marker (https://wotlk.wowhead.com/wotlk/quest=13701)
        [13702] = true, --* A Champion Rises (https://wotlk.wowhead.com/wotlk/quest=13702)
        [13703] = true, --* Valiant Of Ironforge (https://wotlk.wowhead.com/wotlk/quest=13703)
        [13704] = true, --* Valiant Of Gnomeregan (https://wotlk.wowhead.com/wotlk/quest=13704)
        [13705] = true, --* Valiant Of The Exodar (https://wotlk.wowhead.com/wotlk/quest=13705)
        [13706] = true, --* Valiant Of Darnassus (https://wotlk.wowhead.com/wotlk/quest=13706)
        [13707] = true, --* Valiant Of Orgrimmar (https://wotlk.wowhead.com/wotlk/quest=13707)
        [13708] = true, --* Valiant Of Sen'jin (https://wotlk.wowhead.com/wotlk/quest=13708)
        [13709] = true, --* Valiant Of Thunder Bluff (https://wotlk.wowhead.com/wotlk/quest=13709)
        [13710] = true, --* Valiant Of Undercity (https://wotlk.wowhead.com/wotlk/quest=13710)
        [13711] = true, --* Valiant Of Silvermoon (https://wotlk.wowhead.com/wotlk/quest=13711)
        [13713] = true, --* The Valiant's Challenge (https://wotlk.wowhead.com/wotlk/quest=13713)
        [13714] = true, --* The Valiant's Charge (https://wotlk.wowhead.com/wotlk/quest=13714)
        [13715] = true, --* The Valiant's Charge (https://wotlk.wowhead.com/wotlk/quest=13715)
        [13716] = true, --* The Valiant's Charge (https://wotlk.wowhead.com/wotlk/quest=13716)
        [13717] = true, --* The Valiant's Charge (https://wotlk.wowhead.com/wotlk/quest=13717)
        [13718] = true, --* The Valiant's Charge (https://wotlk.wowhead.com/wotlk/quest=13718)
        [13719] = true, --* The Valiant's Charge (https://wotlk.wowhead.com/wotlk/quest=13719)
        [13720] = true, --* The Valiant's Charge (https://wotlk.wowhead.com/wotlk/quest=13720)
        [13721] = true, --* The Valiant's Charge (https://wotlk.wowhead.com/wotlk/quest=13721)
        [13722] = true, --* The Valiant's Charge (https://wotlk.wowhead.com/wotlk/quest=13722)
        [13723] = true, --* The Valiant's Challenge (https://wotlk.wowhead.com/wotlk/quest=13723)
        [13724] = true, --* The Valiant's Challenge (https://wotlk.wowhead.com/wotlk/quest=13724)
        [13725] = true, --* The Valiant's Challenge (https://wotlk.wowhead.com/wotlk/quest=13725)
        [13726] = true, --* The Valiant's Challenge (https://wotlk.wowhead.com/wotlk/quest=13726)
        [13727] = true, --* The Valiant's Challenge (https://wotlk.wowhead.com/wotlk/quest=13727)
        [13728] = true, --* The Valiant's Challenge (https://wotlk.wowhead.com/wotlk/quest=13728)
        [13729] = true, --* The Valiant's Challenge (https://wotlk.wowhead.com/wotlk/quest=13729)
        [13731] = true, --* The Valiant's Challenge (https://wotlk.wowhead.com/wotlk/quest=13731)
        [13732] = true, --* A Champion Rises (https://wotlk.wowhead.com/wotlk/quest=13732)
        [13733] = true, --* A Champion Rises (https://wotlk.wowhead.com/wotlk/quest=13733)
        [13734] = true, --* A Champion Rises (https://wotlk.wowhead.com/wotlk/quest=13734)
        [13735] = true, --* A Champion Rises (https://wotlk.wowhead.com/wotlk/quest=13735)
        [13736] = true, --* A Champion Rises (https://wotlk.wowhead.com/wotlk/quest=13736)
        [13737] = true, --* A Champion Rises (https://wotlk.wowhead.com/wotlk/quest=13737)
        [13738] = true, --* A Champion Rises (https://wotlk.wowhead.com/wotlk/quest=13738)
        [13739] = true, --* A Champion Rises (https://wotlk.wowhead.com/wotlk/quest=13739)
        [13740] = true, --* A Champion Rises (https://wotlk.wowhead.com/wotlk/quest=13740)
        [13741] = true, --* A Blade Fit For A Champion (https://wotlk.wowhead.com/wotlk/quest=13741)
        [13742] = true, --* A Worthy Weapon (https://wotlk.wowhead.com/wotlk/quest=13742)
        [13743] = true, --* The Edge Of Winter (https://wotlk.wowhead.com/wotlk/quest=13743)
        [13744] = true, --* A Valiant's Field Training (https://wotlk.wowhead.com/wotlk/quest=13744)
        [13745] = true, --* The Grand Melee (https://wotlk.wowhead.com/wotlk/quest=13745)
        [13746] = true, --* A Blade Fit For A Champion (https://wotlk.wowhead.com/wotlk/quest=13746)
        [13747] = true, --* A Worthy Weapon (https://wotlk.wowhead.com/wotlk/quest=13747)
        [13748] = true, --* The Edge Of Winter (https://wotlk.wowhead.com/wotlk/quest=13748)
        [13749] = true, --* A Valiant's Field Training (https://wotlk.wowhead.com/wotlk/quest=13749)
        [13750] = true, --* The Grand Melee (https://wotlk.wowhead.com/wotlk/quest=13750)
        [13752] = true, --* A Blade Fit For A Champion (https://wotlk.wowhead.com/wotlk/quest=13752)
        [13753] = true, --* A Worthy Weapon (https://wotlk.wowhead.com/wotlk/quest=13753)
        [13754] = true, --* The Edge Of Winter (https://wotlk.wowhead.com/wotlk/quest=13754)
        [13755] = true, --* A Valiant's Field Training (https://wotlk.wowhead.com/wotlk/quest=13755)
        [13756] = true, --* The Grand Melee (https://wotlk.wowhead.com/wotlk/quest=13756)
        [13757] = true, --* A Blade Fit For A Champion (https://wotlk.wowhead.com/wotlk/quest=13757)
        [13758] = true, --* A Worthy Weapon (https://wotlk.wowhead.com/wotlk/quest=13758)
        [13759] = true, --* The Edge Of Winter (https://wotlk.wowhead.com/wotlk/quest=13759)
        [13760] = true, --* A Valiant's Field Training (https://wotlk.wowhead.com/wotlk/quest=13760)
        [13761] = true, --* The Grand Melee (https://wotlk.wowhead.com/wotlk/quest=13761)
        [13762] = true, --* A Blade Fit For A Champion (https://wotlk.wowhead.com/wotlk/quest=13762)
        [13763] = true, --* A Worthy Weapon (https://wotlk.wowhead.com/wotlk/quest=13763)
        [13764] = true, --* The Edge Of Winter (https://wotlk.wowhead.com/wotlk/quest=13764)
        [13765] = true, --* A Valiant's Field Training (https://wotlk.wowhead.com/wotlk/quest=13765)
        [13767] = true, --* The Grand Melee (https://wotlk.wowhead.com/wotlk/quest=13767)
        [13768] = true, --* A Blade Fit For A Champion (https://wotlk.wowhead.com/wotlk/quest=13768)
        [13769] = true, --* A Worthy Weapon (https://wotlk.wowhead.com/wotlk/quest=13769)
        [13770] = true, --* The Edge Of Winter (https://wotlk.wowhead.com/wotlk/quest=13770)
        [13771] = true, --* A Valiant's Field Training (https://wotlk.wowhead.com/wotlk/quest=13771)
        [13772] = true, --* The Grand Melee (https://wotlk.wowhead.com/wotlk/quest=13772)
        [13773] = true, --* A Blade Fit For A Champion (https://wotlk.wowhead.com/wotlk/quest=13773)
        [13774] = true, --* A Worthy Weapon (https://wotlk.wowhead.com/wotlk/quest=13774)
        [13775] = true, --* The Edge Of Winter (https://wotlk.wowhead.com/wotlk/quest=13775)
        [13776] = true, --* A Valiant's Field Training (https://wotlk.wowhead.com/wotlk/quest=13776)
        [13777] = true, --* The Grand Melee (https://wotlk.wowhead.com/wotlk/quest=13777)
        [13778] = true, --* A Blade Fit For A Champion (https://wotlk.wowhead.com/wotlk/quest=13778)
        [13779] = true, --* A Worthy Weapon (https://wotlk.wowhead.com/wotlk/quest=13779)
        [13780] = true, --* The Edge Of Winter (https://wotlk.wowhead.com/wotlk/quest=13780)
        [13781] = true, --* A Valiant's Field Training (https://wotlk.wowhead.com/wotlk/quest=13781)
        [13782] = true, --* The Grand Melee (https://wotlk.wowhead.com/wotlk/quest=13782)
        [13783] = true, --* A Blade Fit For A Champion (https://wotlk.wowhead.com/wotlk/quest=13783)
        [13784] = true, --* A Worthy Weapon (https://wotlk.wowhead.com/wotlk/quest=13784)
        [13785] = true, --* The Edge Of Winter (https://wotlk.wowhead.com/wotlk/quest=13785)
        [13786] = true, --* A Valiant's Field Training (https://wotlk.wowhead.com/wotlk/quest=13786)
        [13787] = true, --* The Grand Melee (https://wotlk.wowhead.com/wotlk/quest=13787)
        [13788] = true, --* Threat From Above (https://wotlk.wowhead.com/wotlk/quest=13788)
        [13789] = true, --* Taking Battle To The Enemy (https://wotlk.wowhead.com/wotlk/quest=13789)
        [13790] = true, --* Among the Champions (https://wotlk.wowhead.com/wotlk/quest=13790)
        [13791] = true, --* Taking Battle To The Enemy (https://wotlk.wowhead.com/wotlk/quest=13791)
        [13793] = true, --* Among the Champions (https://wotlk.wowhead.com/wotlk/quest=13793)
        [13794] = true, --* Eadric the Pure (https://wotlk.wowhead.com/wotlk/quest=13794)
        [13795] = true, --* The Scourgebane (https://wotlk.wowhead.com/wotlk/quest=13795)
        [13807] = true, --* FLAG: Tournament Invitation (https://wotlk.wowhead.com/wotlk/quest=13807)
        [13809] = true, --* Threat From Above (https://wotlk.wowhead.com/wotlk/quest=13809)
        [13810] = true, --* Taking Battle To The Enemy (https://wotlk.wowhead.com/wotlk/quest=13810)
        [13811] = true, --* Among the Champions (https://wotlk.wowhead.com/wotlk/quest=13811)
        [13812] = true, --* Threat From Above (https://wotlk.wowhead.com/wotlk/quest=13812)
        [13813] = true, --* Taking Battle To The Enemy (https://wotlk.wowhead.com/wotlk/quest=13813)
        [13814] = true, --* Among the Champions (https://wotlk.wowhead.com/wotlk/quest=13814)
        [13820] = true, --* The Blastbolt Brothers (https://wotlk.wowhead.com/wotlk/quest=13820)
        [13828] = true, --* Mastery Of Melee (https://wotlk.wowhead.com/wotlk/quest=13828)
        [13829] = true, --* Mastery Of Melee (https://wotlk.wowhead.com/wotlk/quest=13829)
        [13835] = true, --* Mastery Of The Shield-Breaker (https://wotlk.wowhead.com/wotlk/quest=13835)
        [13837] = true, --* Mastery Of The Charge (https://wotlk.wowhead.com/wotlk/quest=13837)
        [13838] = true, --* Mastery Of The Shield-Breaker (https://wotlk.wowhead.com/wotlk/quest=13838)
        [13839] = true, --* Mastery Of The Charge (https://wotlk.wowhead.com/wotlk/quest=13839)
        [13843] = true, --* The Scrapbot Construction Kit (https://wotlk.wowhead.com/wotlk/quest=13843)
        [13846] = true, --* Contributin' To The Cause (https://wotlk.wowhead.com/wotlk/quest=13846)
        [13847] = true, --* At The Enemy's Gates (https://wotlk.wowhead.com/wotlk/quest=13847)
        [13851] = true, --* At The Enemy's Gates (https://wotlk.wowhead.com/wotlk/quest=13851)
        [13852] = true, --* At The Enemy's Gates (https://wotlk.wowhead.com/wotlk/quest=13852)
        [13854] = true, --* At The Enemy's Gates (https://wotlk.wowhead.com/wotlk/quest=13854)
        [13855] = true, --* At The Enemy's Gates (https://wotlk.wowhead.com/wotlk/quest=13855)
        [13856] = true, --* At The Enemy's Gates (https://wotlk.wowhead.com/wotlk/quest=13856)
        [13857] = true, --* At The Enemy's Gates (https://wotlk.wowhead.com/wotlk/quest=13857)
        [13858] = true, --* At The Enemy's Gates (https://wotlk.wowhead.com/wotlk/quest=13858)
        [13859] = true, --* At The Enemy's Gates (https://wotlk.wowhead.com/wotlk/quest=13859)
        [13860] = true, --* At The Enemy's Gates (https://wotlk.wowhead.com/wotlk/quest=13860)
        [13861] = true, --* Battle Before The Citadel (https://wotlk.wowhead.com/wotlk/quest=13861)
        [13862] = true, --* Battle Before The Citadel (https://wotlk.wowhead.com/wotlk/quest=13862)
        [13863] = true, --* Battle Before The Citadel (https://wotlk.wowhead.com/wotlk/quest=13863)
        [13864] = true, --* Battle Before The Citadel (https://wotlk.wowhead.com/wotlk/quest=13864)
        [13908] = true, --* Gearing Up To Ride (https://wotlk.wowhead.com/wotlk/quest=13908)
        [13929] = true, --* The Biggest Tree Ever! (https://wotlk.wowhead.com/wotlk/quest=13929)
        [13930] = true, --* Home Of The Bear-Men (https://wotlk.wowhead.com/wotlk/quest=13930)
        [13931] = true, --* Another Year, Another Souvenir. (https://wotlk.wowhead.com/wotlk/quest=13931)
        [13932] = true, --* Another Year, Another Souvenir. (https://wotlk.wowhead.com/wotlk/quest=13932)
        [13933] = true, --* The Bronze Dragonshrine (https://wotlk.wowhead.com/wotlk/quest=13933)
        [13934] = true, --* The Bronze Dragonshrine (https://wotlk.wowhead.com/wotlk/quest=13934)
        [13937] = true, --* A Trip To The Wonderworks (https://wotlk.wowhead.com/wotlk/quest=13937)
        [13938] = true, --* A Visit To The Wonderworks (https://wotlk.wowhead.com/wotlk/quest=13938)
        [13950] = true, --* Playmates! (https://wotlk.wowhead.com/wotlk/quest=13950)
        [13951] = true, --* Playmates! (https://wotlk.wowhead.com/wotlk/quest=13951)
        [13954] = true, --* The Dragon Queen (https://wotlk.wowhead.com/wotlk/quest=13954)
        [13955] = true, --* The Dragon Queen (https://wotlk.wowhead.com/wotlk/quest=13955)
        [13956] = true, --* Meeting a Great One (https://wotlk.wowhead.com/wotlk/quest=13956)
        [13957] = true, --* The Mighty Hemet Nesingwary (https://wotlk.wowhead.com/wotlk/quest=13957)
        [13959] = true, --* Back To The Orphanage (https://wotlk.wowhead.com/wotlk/quest=13959)
        [13960] = true, --* Back To The Orphanage (https://wotlk.wowhead.com/wotlk/quest=13960)
        [13990] = true, --* Upper Deck Promo - Chicken Mount (https://wotlk.wowhead.com/wotlk/quest=13990)
        [14016] = true, --* The Black Knight's Curse (https://wotlk.wowhead.com/wotlk/quest=14016)
        [14017] = true, --* The Black Knight's Fate (https://wotlk.wowhead.com/wotlk/quest=14017)
        [14024] = true, --* Pumpkin Pie (https://wotlk.wowhead.com/wotlk/quest=14024)
        [14028] = true, --* Cranberry Chutney (https://wotlk.wowhead.com/wotlk/quest=14028)
        [14030] = true, --* They're Ravenous In Darnassus (https://wotlk.wowhead.com/wotlk/quest=14030)
        [14033] = true, --* Candied Sweet Potatoes (https://wotlk.wowhead.com/wotlk/quest=14033)
        [14035] = true, --* Slow-roasted Turkey (https://wotlk.wowhead.com/wotlk/quest=14035)
        [14040] = true, --* Pumpkin Pie (https://wotlk.wowhead.com/wotlk/quest=14040)
        [14041] = true, --* Cranberry Chutney (https://wotlk.wowhead.com/wotlk/quest=14041)
        [14043] = true, --* Candied Sweet Potatoes (https://wotlk.wowhead.com/wotlk/quest=14043)
        [14044] = true, --* Undersupplied in the Undercity (https://wotlk.wowhead.com/wotlk/quest=14044)
        [14047] = true, --* Slow-roasted Turkey (https://wotlk.wowhead.com/wotlk/quest=14047)
        [14074] = true, --* A Leg Up (https://wotlk.wowhead.com/wotlk/quest=14074)
        [14076] = true, --* Breakfast Of Champions (https://wotlk.wowhead.com/wotlk/quest=14076)
        [14077] = true, --* The Light's Mercy (https://wotlk.wowhead.com/wotlk/quest=14077)
        [14080] = true, --* Stop The Aggressors (https://wotlk.wowhead.com/wotlk/quest=14080)
        [14090] = true, --* Gormok Wants His Snobolds (https://wotlk.wowhead.com/wotlk/quest=14090)
        [14092] = true, --* Breakfast Of Champions (https://wotlk.wowhead.com/wotlk/quest=14092)
        [14095] = true, --* Identifying the Remains (https://wotlk.wowhead.com/wotlk/quest=14095)
        [14096] = true, --* You've Really Done It This Time, Kul (https://wotlk.wowhead.com/wotlk/quest=14096)
        [14101] = true, --* Drottinn Hrothgar (https://wotlk.wowhead.com/wotlk/quest=14101)
        [14102] = true, --* Mistcaller Yngvar (https://wotlk.wowhead.com/wotlk/quest=14102)
        [14104] = true, --* Ornolf The Scarred (https://wotlk.wowhead.com/wotlk/quest=14104)
        [14105] = true, --* Deathspeaker Kharos (https://wotlk.wowhead.com/wotlk/quest=14105)
        [14107] = true, --* The Fate Of The Fallen (https://wotlk.wowhead.com/wotlk/quest=14107)
        [14108] = true, --* Get Kraken! (https://wotlk.wowhead.com/wotlk/quest=14108)
        [14112] = true, --* What Do You Feed a Yeti, Anyway? (https://wotlk.wowhead.com/wotlk/quest=14112)
        [14119] = true, --* Blank [PH] (https://wotlk.wowhead.com/wotlk/quest=14119)
        [14136] = true, --* Rescue at Sea (https://wotlk.wowhead.com/wotlk/quest=14136)
        [14140] = true, --* Stop The Aggressors (https://wotlk.wowhead.com/wotlk/quest=14140)
        [14141] = true, --* Gormok Wants His Snobolds (https://wotlk.wowhead.com/wotlk/quest=14141)
        [14142] = true, --* You've Really Done It This Time, Kul (https://wotlk.wowhead.com/wotlk/quest=14142)
        [14143] = true, --* A Leg Up (https://wotlk.wowhead.com/wotlk/quest=14143)
        [14144] = true, --* The Light's Mercy (https://wotlk.wowhead.com/wotlk/quest=14144)
        [14145] = true, --* What Do You Feed a Yeti, Anyway? (https://wotlk.wowhead.com/wotlk/quest=14145)
        [14147] = true, --* Blank [PH] (https://wotlk.wowhead.com/wotlk/quest=14147)
        [14148] = true, --* Blank [PH] (https://wotlk.wowhead.com/wotlk/quest=14148)
        [14149] = true, --* Blank [PH] (https://wotlk.wowhead.com/wotlk/quest=14149)
        [14150] = true, --* Blank [PH] (https://wotlk.wowhead.com/wotlk/quest=14150)
        [14152] = true, --* Rescue at Sea (https://wotlk.wowhead.com/wotlk/quest=14152)
        [14185] = true, --* FLAG: Riding Trainer Advertisement (40) (https://wotlk.wowhead.com/wotlk/quest=14185)
        [14186] = true, --* FLAG: Riding Trainer Advertisement (60) (https://wotlk.wowhead.com/wotlk/quest=14186)
        [14187] = true, --* FLAG: Riding Trainer Advertisement (70) (https://wotlk.wowhead.com/wotlk/quest=14187)
        [14200] = true, --* Kickoff Mail Marker (https://wotlk.wowhead.com/wotlk/quest=14200)
        [14409] = true, --* A Cautious Return (https://wotlk.wowhead.com/wotlk/quest=14409)
        [14441] = true, --* Garrosh's Autograph (https://wotlk.wowhead.com/wotlk/quest=14441)
        [14444] = true, --* What The Dragons Know (https://wotlk.wowhead.com/wotlk/quest=14444)
        [14457] = true, --* The Sunreaver Plan (https://wotlk.wowhead.com/wotlk/quest=14457)
        [20438] = true, --* A Suitable Disguise (https://wotlk.wowhead.com/wotlk/quest=20438)
        [20439] = true, --* A Meeting With The Magister (https://wotlk.wowhead.com/wotlk/quest=20439)
        [24428] = true, --* A Most Puzzling Circumstance (https://wotlk.wowhead.com/wotlk/quest=24428)
        [24429] = true, --* A Most Puzzling Circumstance (https://wotlk.wowhead.com/wotlk/quest=24429)
        [24442] = true, --* Battle Plans Of The Kvaldir (https://wotlk.wowhead.com/wotlk/quest=24442)
        [24451] = true, --* An Audience With The Arcanist (https://wotlk.wowhead.com/wotlk/quest=24451)
        [24454] = true, --* Return To Caladis Brightspear (https://wotlk.wowhead.com/wotlk/quest=24454)
        [24476] = true, --* Tempering The Blade (https://wotlk.wowhead.com/wotlk/quest=24476)
        [24508] = true, --* Temp Quest Record (https://wotlk.wowhead.com/wotlk/quest=24508)
        [24509] = true, --* Temp Quest Record (https://wotlk.wowhead.com/wotlk/quest=24509)
        [24522] = true, --* Journey To The Sunwell (https://wotlk.wowhead.com/wotlk/quest=24522)
        [24535] = true, --* Thalorien Dawnseeker (https://wotlk.wowhead.com/wotlk/quest=24535)
        [24541] = true, --* Pilfering Perfume (https://wotlk.wowhead.com/wotlk/quest=24541)
        [24555] = true, --* What The Dragons Know (https://wotlk.wowhead.com/wotlk/quest=24555)
        [24556] = true, --* A Suitable Disguise (https://wotlk.wowhead.com/wotlk/quest=24556)
        [24557] = true, --* The Silver Covenant's Scheme (https://wotlk.wowhead.com/wotlk/quest=24557)
        [24558] = true, --* Return To Myralion Sunblaze (https://wotlk.wowhead.com/wotlk/quest=24558)
        [24560] = true, --* Tempering The Blade (https://wotlk.wowhead.com/wotlk/quest=24560)
        [24562] = true, --* Journey To The Sunwell (https://wotlk.wowhead.com/wotlk/quest=24562)
        [24563] = true, --* Thalorien Dawnseeker (https://wotlk.wowhead.com/wotlk/quest=24563)
        [24576] = true, --* A Friendly Chat... (https://wotlk.wowhead.com/wotlk/quest=24576)
        [24594] = true, --* The Purification of Quel'Delar (https://wotlk.wowhead.com/wotlk/quest=24594)
        [24638] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24638)
        [24645] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24645)
        [24647] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24647)
        [24648] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24648)
        [24649] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24649)
        [24650] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24650)
        [24651] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24651)
        [24652] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24652)
        [24656] = true, --* Pilfering Perfume (https://wotlk.wowhead.com/wotlk/quest=24656)
        [24657] = true, --* A Friendly Chat... (https://wotlk.wowhead.com/wotlk/quest=24657)
        [24658] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24658)
        [24659] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24659)
        [24660] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24660)
        [24662] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24662)
        [24663] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24663)
        [24664] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24664)
        [24665] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24665)
        [24666] = true, --* Crushing the Crown (https://wotlk.wowhead.com/wotlk/quest=24666)
        [24792] = true, --* Man on the Inside (https://wotlk.wowhead.com/wotlk/quest=24792)
        [24793] = true, --* Man on the Inside (https://wotlk.wowhead.com/wotlk/quest=24793)
        [24795] = true, --* A Victory For The Silver Covenant (https://wotlk.wowhead.com/wotlk/quest=24795)
        [24796] = true, --* A Victory For The Silver Covenant (https://wotlk.wowhead.com/wotlk/quest=24796)
        [24798] = true, --* A Victory For The Sunreavers (https://wotlk.wowhead.com/wotlk/quest=24798)
        [24799] = true, --* A Victory For The Sunreavers (https://wotlk.wowhead.com/wotlk/quest=24799)
        [24800] = true, --* A Victory For The Sunreavers (https://wotlk.wowhead.com/wotlk/quest=24800)
        [24801] = true, --* A Victory For The Sunreavers (https://wotlk.wowhead.com/wotlk/quest=24801)
        [24808] = true, --* Tank Ring Flag (https://wotlk.wowhead.com/wotlk/quest=24808)
        [24809] = true, --* Healer Ring Flag (https://wotlk.wowhead.com/wotlk/quest=24809)
        [24810] = true, --* Melee Ring Flag (https://wotlk.wowhead.com/wotlk/quest=24810)
        [24811] = true, --* Caster Ring Flag (https://wotlk.wowhead.com/wotlk/quest=24811)
        [24848] = true, --* Fireworks At The Gilded Rose (https://wotlk.wowhead.com/wotlk/quest=24848)
        [24849] = true, --* Hot On The Trail (https://wotlk.wowhead.com/wotlk/quest=24849)
        [24850] = true, --* Snivel's Sweetheart (https://wotlk.wowhead.com/wotlk/quest=24850)
        [24851] = true, --* Hot On The Trail (https://wotlk.wowhead.com/wotlk/quest=24851)
        [24869] = true, --* Deprogramming (https://wotlk.wowhead.com/wotlk/quest=24869)
        [24870] = true, --* Securing the Ramparts (https://wotlk.wowhead.com/wotlk/quest=24870)
        [24871] = true, --* Securing the Ramparts (https://wotlk.wowhead.com/wotlk/quest=24871)
        [24872] = true, --* Respite for a Tormented Soul (https://wotlk.wowhead.com/wotlk/quest=24872)
        [24873] = true, --* Residue Rendezvous (https://wotlk.wowhead.com/wotlk/quest=24873)
        [24874] = true, --* Blood Quickening (https://wotlk.wowhead.com/wotlk/quest=24874)
        [24875] = true, --* Deprogramming (https://wotlk.wowhead.com/wotlk/quest=24875)
        [24876] = true, --* Securing the Ramparts (https://wotlk.wowhead.com/wotlk/quest=24876)
        [24877] = true, --* Securing the Ramparts (https://wotlk.wowhead.com/wotlk/quest=24877)
        [24878] = true, --* Residue Rendezvous (https://wotlk.wowhead.com/wotlk/quest=24878)
        [24879] = true, --* Blood Quickening (https://wotlk.wowhead.com/wotlk/quest=24879)
        [24880] = true, --* Respite for a Tormented Soul (https://wotlk.wowhead.com/wotlk/quest=24880)
        [25199] = true, --* Basic Orders (https://wotlk.wowhead.com/wotlk/quest=25199)
        [25212] = true, --* Vent Horizon (https://wotlk.wowhead.com/wotlk/quest=25212)
        [25229] = true, --* A Few Good Gnomes (https://wotlk.wowhead.com/wotlk/quest=25229)
        [25238] = true, --* Strength Ring Flag (https://wotlk.wowhead.com/wotlk/quest=25238)
        [25283] = true, --* Prepping the Speech (https://wotlk.wowhead.com/wotlk/quest=25283)
        [25285] = true, --* In and Out (https://wotlk.wowhead.com/wotlk/quest=25285)
        [25286] = true, --* Words for Delivery (https://wotlk.wowhead.com/wotlk/quest=25286)
        [25287] = true, --* Words for Delivery (https://wotlk.wowhead.com/wotlk/quest=25287)
        [25289] = true, --* One Step Forward... (https://wotlk.wowhead.com/wotlk/quest=25289)
        [25293] = true, --* The Missing (https://wotlk.wowhead.com/wotlk/quest=25293)
        [25295] = true, --* Press Fire (https://wotlk.wowhead.com/wotlk/quest=25295)
        [25393] = true, --* Operation: Gnomeregan (https://wotlk.wowhead.com/wotlk/quest=25393)
        [25445] = true, --* Zalazane's Fall (https://wotlk.wowhead.com/wotlk/quest=25445)
        [25446] = true, --* Frogs Away! (https://wotlk.wowhead.com/wotlk/quest=25446)
        [25461] = true, --* Trollin' For Volunteers (https://wotlk.wowhead.com/wotlk/quest=25461)
        [25470] = true, --* Lady Of Da Tigers (https://wotlk.wowhead.com/wotlk/quest=25470)
        [25480] = true, --* Dance Of De Spirits (https://wotlk.wowhead.com/wotlk/quest=25480)
        [25495] = true, --* Preparin' For Battle (https://wotlk.wowhead.com/wotlk/quest=25495)
        [25500] = true, --* Words for Delivery (https://wotlk.wowhead.com/wotlk/quest=25500)
      }      
end