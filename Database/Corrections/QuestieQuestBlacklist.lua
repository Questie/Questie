---@class QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:CreateModule("QuestieQuestBlacklist")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")

---@return table<QuestId, boolean>
function QuestieQuestBlacklist:Load()
    local questsToBlacklist = {
        [7462] = true, -- Duplicate of 7877. See #1583
        [5663] = true, -- Touch of Weakness of Dark Cleric Beryl - Fixing #730
        [5658] = true, -- Touch of Weakness of Father Lankester -- See #1603
        [2358] = QuestieCorrections.CLASSIC_AND_TBC, -- See #921
        [787] = true, -- The New Horde is not in the game. See #830
        [6606] = true, -- Quest is not in the game. See #1338
        [6072] = true, -- Ayanna Everstride doesn't start "Hunter's Path" (this quest is most likely simply not in the game) #700
        [614] = true, -- Duplicate of 8551
        [615] = true, -- Duplicate of 8553. See #2215
        [618] = true, -- Duplicate of 8554
        [934] = true, -- Duplicate of 7383. See #2386
        --[960] = true, -- Duplicate of 961 -- different quests, not duplicate
        [9378] = true, -- Naxxramas quest which doesn't seem to be in the game
        [1318] = true, -- Duplicate of 7703 and not in the game
        [7704] = QuestieCorrections.CLASSIC_AND_TBC, -- Not implemented in Era, added in Wrath
        [7668] = true, -- Not in the game (yet) Replaced with 8258 in Ph 4-- #1805
        [636] = true, -- Not in the game - #1900
        [6066] = true, -- Not in the game - #1957
        [4603] = true, -- Duplicate of 2953
        [4604] = true, -- Duplicate of 2953
        [8856] = true, -- Duplicate of 8497
        [13053] = true, -- Removed
        [11402] = true, -- GM Island quest
        [11189] = true, -- Removed
        [13417] = true, -- Duplicate of 12973
        [936] = QuestieCorrections.CLASSIC_ONLY,
        [535] = QuestieCorrections.WOTLK_ONLY, -- Valik
        [2000] = true, -- Not in the game - #4487
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
        [8981] = true, --removed in wotlk
        [8993] = true, --removed in wotlk
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
        [11431] = true,
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
        [11891] = true,
        [11915] = true,
        [11917] = true,
        [11921] = true,
        [11922] = true,
        [11923] = true,
        [11924] = true,
        [11925] = true,
        [11926] = true,
        [11933] = true,
        [11935] = true,
        [11947] = true,
        [11948] = true,
        [11952] = true,
        [11953] = true,
        [11954] = true,
        [11955] = true,
        [11972] = true,
        [11975] = true,
        [11964] = true,
        [11966] = true,
        [11970] = true,
        [11971] = true,
        [12012] = true,
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
        [13483] = true,
        [13484] = true,
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
        [24536] = true,
        [24655] = true,
        [24804] = true,
        [24805] = true,

        --- Children's Week
        [13926] = true,
        [13927] = true,

        --- Hallow's End
        [12940] = true,
        [12941] = true,
        [12944] = true,
        [12945] = true,
        [12946] = true,
        [12947] = true,
        [12950] = true,
        [13433] = true,
        [13434] = true,
        [13435] = true,
        [13436] = true,
        [13437] = true,
        [13438] = true,
        [13439] = true,
        [13448] = true,
        [13452] = true,
        [13456] = true,
        [13459] = true,
        [13460] = true,
        [13461] = true,
        [13462] = true,
        [13463] = true,
        [13464] = true,
        [13465] = true,
        [13466] = true,
        [13467] = true,
        [13468] = true,
        [13469] = true,
        [13470] = true,
        [13471] = true,
        [13472] = true,
        [13473] = true,
        [13474] = true,
        [13501] = true,
        [13548] = true,

        --- Pilgrim's Bounty
        [14022] = true,
        [14036] = true,
        [14023] = true,
        [14024] = true,
        [14028] = true,
        [14030] = true,
        [14033] = true,
        [14035] = true,
        [14037] = true,
        [14040] = true,
        [14041] = true,
        [14043] = true,
        [14044] = true,
        [14047] = true,
        [14048] = true,
        [14051] = true,
        [14053] = true,
        [14054] = true,
        [14055] = true,
        [14058] = true,
        [14059] = true,
        [14060] = true,
        [14061] = true,
        [14062] = true,
        [14064] = true,
        [14065] = true,

        --- Brewfest
        [12193] = true,
        [12194] = true,
        [13931] = true,
        [13932] = true,

        -- Lunar Festival
        [13012] = true,
        [13013] = true,
        [13014] = true,
        [13015] = true,
        [13016] = true,
        [13017] = true,
        [13018] = true,
        [13019] = true,
        [13020] = true,
        [13021] = true,
        [13022] = true,
        [13023] = true,
        [13024] = true,
        [13025] = true,
        [13026] = true,
        [13027] = true,
        [13028] = true,
        [13029] = true,
        [13030] = true,
        [13031] = true,
        [13032] = true,
        [13033] = true,
        [13065] = true,
        [13066] = true,
        [13067] = true,


        -- End of Wotlk event quests
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
        [10090] = true, -- BETA The Legion's Plans
        [11027] = true, -- NOT IN GAME: Yous Have Da Darkrune? , "replaced" by 11060 (A Crystalforged Darkrune)

        [1] = true, -- Unavailable quest "The "Chow" Quest (123)aa"
        [2881] = QuestieCorrections.TBC_ONLY, -- Wildhammer faction removed in TBC. Repeatable to gain rep
        [8329] = true, -- Warrior Training / Not in the game
        [8547] = true, -- Welcome!
        [9065] = true, -- Unavailable quest "The "Chow" Quest (123)aa"
        [9278] = true, -- Welcome!
        --[9681] = true, -- Replaced with [A Study in Power (64319)] changed in wotlk again. 64319+63866 only present in SWP patch
        --[9684] = true, -- Replaced with [Claiming the Light (63866)] changed in wotlk again. 64319+63866 only present in SWP patch
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
        [64139] = true, -- Horde pala mount quest chain
        [64140] = true, -- Horde pala mount quest chain
        [64141] = true, -- Horde pala mount quest chain
        [64142] = true, -- Horde pala mount quest chain
        [64143] = true, -- Horde pala mount quest chain
        [64144] = true, -- Horde pala mount quest chain
        [64145] = true, -- Horde pala mount quest chain
        [64217] = true, -- Boosted character quest
        [64845] = QuestieCorrections.TBC_AND_WOTLK, -- Alliance War Effort
        [70395] = true, -- First quest for boosted characters. Blocked to not show for others
        [70396] = true, -- First quest for boosted characters. Blocked to not show for others
        [70397] = true, -- Boosted character quest
        [70398] = true, -- Boosted character quest
        [70401] = true, -- Boosted character quest
        [70411] = true, -- Boosted character quest
        [70734] = true, -- Boosted character quest
        [70735] = true, -- Boosted character quest
        [70736] = true, -- Boosted character quest
        [70737] = true, -- Boosted character quest
        [70761] = true, -- Boosted character quest
        [70762] = true, -- First quest for boosted characters. Blocked to not show for others
        [70764] = true, -- Boosted character quest
        [70765] = true, -- Boosted character quest
        [70865] = true, -- Boosted character quest
        [70869] = true, -- Boosted character quest
        [70870] = true, -- Boosted character quest
        [78136] = true, -- Boosted character quest
        [78137] = true, -- Boosted character quest
        [78138] = true, -- Boosted character quest
        [78140] = true, -- Boosted character quest
        [78151] = true, -- Boosted character quest
        [78157] = true, -- Boosted character quest
        [78158] = true, -- Boosted character quest
        [78164] = true, -- Boosted character quest
        [78166] = true, -- Boosted character quest
        [78167] = true, -- Boosted character quest
        [78168] = true, -- Boosted character quest
        [78219] = true, -- Boosted character quest
        [78220] = true, -- Boosted character quest
        [78221] = true, -- Boosted character quest
        [78222] = true, -- Boosted character quest
        [78223] = true, -- Boosted character quest
        [78224] = true, -- Boosted character quest
        [78225] = true, -- Boosted character quest

		-- Paladin class quests with SWP patch
        [64319] = true, -- removed in wotlk
        [63866] = true, -- removed in wotlk

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
        [1661] = QuestieCorrections.TBC_AND_WOTLK,
        [3366] = true,
        [3381] = true,
        [5627] = true,
        [5641] = QuestieCorrections.TBC_AND_WOTLK,
        [5645] = QuestieCorrections.TBC_AND_WOTLK,
        [5647] = QuestieCorrections.TBC_AND_WOTLK,
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

        [10985] = QuestieCorrections.WOTLK_ONLY, -- Got replaced by 13429
        [10888] = QuestieCorrections.WOTLK_ONLY, -- Got replaced by 13430
        [10901] = QuestieCorrections.WOTLK_ONLY, -- Got replaced by 13431
        [10445] = QuestieCorrections.WOTLK_ONLY, -- Got replaced by 13432
        [6144] = QuestieCorrections.WOTLK_ONLY, -- Got replaced by 14349
        [6821] = QuestieCorrections.WOTLK_ONLY, -- Not in the game
        [6822] = QuestieCorrections.WOTLK_ONLY, -- Not in the game
        [6823] = QuestieCorrections.WOTLK_ONLY, -- Not in the game
        [6824] = QuestieCorrections.WOTLK_ONLY, -- Not in the game
        [7486] = QuestieCorrections.WOTLK_ONLY, -- Not in the game
        [5634] = QuestieCorrections.WOTLK_ONLY, -- removed in wotlk
        [5635] = QuestieCorrections.WOTLK_ONLY, -- removed in wotlk
        [5636] = QuestieCorrections.WOTLK_ONLY, -- removed in wotlk
        [5637] = QuestieCorrections.WOTLK_ONLY, -- removed in wotlk
        [5638] = QuestieCorrections.WOTLK_ONLY, -- removed in wotlk
        [5639] = QuestieCorrections.WOTLK_ONLY, -- removed in wotlk
        [5640] = QuestieCorrections.WOTLK_ONLY, -- removed in wotlk
        [12881] = true, -- Not in the game
        [14351] = true, -- Not in the game
        [14353] = true, -- Not in the game
        [11621] = true, -- Not in the game
        [11179] = true, -- Not in the game
        [11622] = true, -- Not in the game
        [11551] = true, -- Not in the game
        [11552] = true, -- Not in the game
        [11553] = true, -- Not in the game
        [11578] = true, -- Not in the game
        [11579] = true, -- Not in the game
        [11939] = true, -- Not in the game
        [11997] = true, -- Not in the game
        [12087] = true, -- Not in the game
        [12156] = true, -- Not in the game
        [12108] = true, -- Not in the game
        [12233] = true, -- Not in the game
        [12426] = true, -- Not in the game
        [12479] = true, -- Not in the game
        [12480] = true, -- Not in the game
        [12490] = true, -- Not in the game
        [12493] = true, -- Not in the game
        [12780] = true, -- Not in the game
        [12590] = true, -- Not in the game
        [11461] = true, -- Not in the game
        [12911] = true, -- Not in the game
        [13150] = true, -- Not in the game
        [13317] = true, -- Not in the game
        --[14103] = true, -- Titanium Powder
        [14160] = true, -- Not in the game
        [13374] = true, -- Not in the game
        [13381] = true, -- Not in the game
        [13908] = true, -- Not in the game
        [11586] = true, -- Duplicate of 11585 (not entirely a duplicate but this is the easiest way to hide multiple quests)
        [11595] = true, -- Duplicate of 11596 and 11597 (not entirely a duplicate but this is the easiest way to hide multiple quests)
        [11597] = true, -- Duplicate of 11595 and 11596 (not entirely a duplicate but this is the easiest way to hide multiple quests)
        [12021] = true, -- Duplicate of 12067 and 12085 (not entirely a duplicate but this is the easiest way to hide multiple quests)
        [12015] = true, -- Not in the game
        [12162] = true, -- Not in the game
        [12163] = true, -- Not in the game
        [12051] = true, -- Not in the game
        [12682] = true, -- Not in the game
        [12586] = true, -- Not in the game
        [12835] = true, -- Not in the game
        [12837] = true, -- Not in the game
        [12834] = true, -- Not in the game
        [12825] = true, -- Not in the game
        [12890] = true, -- Not in the game
        [12990] = true, -- Not in the game
        [13184] = true, -- Not in the game
        [13176] = true, -- Not in the game
        [13173] = true, -- Not in the game
        [13175] = true, -- Not in the game
        [14203] = true, -- Not in the game
        [14032] = true, -- Not in the game
        [13825] = true, -- EXISTS ingame, but can only be picked up if quest 6610 was completed PRIOR to wrath - impossible for us to discern eligibility, better to hide than misinform everyone
        [13826] = true, -- EXISTS ingame, but can only be picked up if quest 6607 was completed PRIOR to wrath - impossible for us to discern eligibility, better to hide than misinform everyone
        --[13843] = true, -- Questie NYI - only available if recipe 55252 is not known but quest 12889 is completed, we can't yet determine recipe knowledge - fixed

        [8367] = QuestieCorrections.WOTLK_ONLY, -- pvp marks removed in wotlk
        [8371] = QuestieCorrections.WOTLK_ONLY, -- pvp marks removed in wotlk
        [8385] = QuestieCorrections.WOTLK_ONLY, -- pvp marks removed in wotlk
        [8388] = QuestieCorrections.WOTLK_ONLY, -- pvp marks removed in wotlk
        [13475] = QuestieCorrections.WOTLK_ONLY, -- pvp marks removed in wotlk
        [13476] = QuestieCorrections.WOTLK_ONLY, -- pvp marks removed in wotlk
        [13477] = QuestieCorrections.WOTLK_ONLY, -- pvp marks removed in wotlk
        [13478] = QuestieCorrections.WOTLK_ONLY, -- pvp marks removed in wotlk

        [6804] = QuestieCorrections.WOTLK_ONLY,
        [7737] = QuestieCorrections.WOTLK_ONLY, -- replaced by 13662 in wotlk
        [9094] = QuestieCorrections.WOTLK_ONLY,
        [9317] = QuestieCorrections.WOTLK_ONLY,
        [9318] = QuestieCorrections.WOTLK_ONLY,
        [9320] = QuestieCorrections.WOTLK_ONLY,
        [9321] = QuestieCorrections.WOTLK_ONLY,
        [9333] = QuestieCorrections.WOTLK_ONLY,
        [9334] = QuestieCorrections.WOTLK_ONLY,
        [9335] = QuestieCorrections.WOTLK_ONLY,
        [9336] = QuestieCorrections.WOTLK_ONLY,
        [9337] = QuestieCorrections.WOTLK_ONLY,
        [9341] = QuestieCorrections.WOTLK_ONLY,
        [9343] = QuestieCorrections.WOTLK_ONLY,

        -- Old Naxx quests (Naxx40 goes away in wotlk)
        [9120] = QuestieCorrections.WOTLK_ONLY, -- The Fall of Kel'Thuzad
        [9229] = QuestieCorrections.WOTLK_ONLY, -- The Fate of Ramaladni
        [9230] = QuestieCorrections.WOTLK_ONLY, -- Ramaladni's Icy Grasp
        [9232] = QuestieCorrections.WOTLK_ONLY, -- The Only Song I Know...
        [9233] = QuestieCorrections.WOTLK_ONLY, -- Omarion's Handbook
        [9234] = QuestieCorrections.WOTLK_ONLY, -- Icebane Gauntlets
        [9235] = QuestieCorrections.WOTLK_ONLY, -- Icebane Bracers
        [9236] = QuestieCorrections.WOTLK_ONLY, -- Icebane Breastplate
        [9237] = QuestieCorrections.WOTLK_ONLY, -- Glacial Cloak
        [9238] = QuestieCorrections.WOTLK_ONLY, -- Glacial Wrists
        [9239] = QuestieCorrections.WOTLK_ONLY, -- Glacial Gloves
        [9240] = QuestieCorrections.WOTLK_ONLY, -- Glacial Vest
        [9241] = QuestieCorrections.WOTLK_ONLY, -- Polar Bracers
        [9242] = QuestieCorrections.WOTLK_ONLY, -- Polar Gloves
        [9243] = QuestieCorrections.WOTLK_ONLY, -- Polar Tunic
        [9244] = QuestieCorrections.WOTLK_ONLY, -- Icy Scale Bracers
        [9245] = QuestieCorrections.WOTLK_ONLY, -- Icy Scale Gauntlets
        [9246] = QuestieCorrections.WOTLK_ONLY, -- Icy Scale Breastplate

        -- Vanilla Onyxia Alliance attunement
        [4182] = QuestieCorrections.WOTLK_ONLY,
        [4183] = QuestieCorrections.WOTLK_ONLY,
        [4184] = QuestieCorrections.WOTLK_ONLY,
        [4185] = QuestieCorrections.WOTLK_ONLY,
        [4186] = QuestieCorrections.WOTLK_ONLY,
        [4223] = QuestieCorrections.WOTLK_ONLY,
        [4224] = QuestieCorrections.WOTLK_ONLY,
        [4241] = QuestieCorrections.WOTLK_ONLY,
        [4242] = QuestieCorrections.WOTLK_ONLY,
        [4264] = QuestieCorrections.WOTLK_ONLY,
        [4282] = QuestieCorrections.WOTLK_ONLY,
        [4322] = QuestieCorrections.WOTLK_ONLY,
        [6402] = QuestieCorrections.WOTLK_ONLY,
        [6403] = QuestieCorrections.WOTLK_ONLY,
        [6501] = QuestieCorrections.WOTLK_ONLY,
        [6502] = QuestieCorrections.WOTLK_ONLY,

        -- Vanilla Onyxia Horde pre attunement
        [4903] = QuestieCorrections.WOTLK_ONLY,
        [4941] = QuestieCorrections.WOTLK_ONLY,
        [4974] = QuestieCorrections.WOTLK_ONLY,
        [6566] = QuestieCorrections.WOTLK_ONLY,
        [6567] = QuestieCorrections.WOTLK_ONLY,
        [6568] = QuestieCorrections.WOTLK_ONLY,
        [6569] = QuestieCorrections.WOTLK_ONLY,
        [6570] = QuestieCorrections.WOTLK_ONLY,
        [6582] = QuestieCorrections.WOTLK_ONLY,
        [6583] = QuestieCorrections.WOTLK_ONLY,
        [6584] = QuestieCorrections.WOTLK_ONLY,
        [6585] = QuestieCorrections.WOTLK_ONLY,
        [6601] = QuestieCorrections.WOTLK_ONLY,
        [6602] = QuestieCorrections.WOTLK_ONLY,

        -- "learn to ride" series (unimplemented)
        [14079] = true, -- elwynn (human)
        [14081] = true, -- eversong (belf)
        [14082] = true, -- exodar (draenei)
        [14083] = true, -- dun morogh (dwarf)
        [14084] = true, -- dun morogh (gnome)
        [14085] = true, -- darnassus (nelf)
        [14086] = true, -- orgrimmar (orc)
        [14087] = true, -- mulgore (tauren)
        [14088] = true, -- durotar (troll)
        [14089] = true, -- tirisfal (undead)

        -- Scourge invasion
        [12616] = true,
        [12752] = true,
        [12753] = true,
        [12772] = true,
        [12775] = true,
        [12777] = true,
        [12782] = true,
        [12783] = true,
        [12784] = true,
        [12808] = true,
        [12811] = true,

        --- Phase 2 Secrets of Ulduar
        [13372] = true, -- 10man EoE keys become unavailable with P2
        [13384] = true, -- 10man EoE keys become unavailable with P2

        --- Phase 3 Trial of the Crusader
        --[14076] = true, -- Breakfast Of Champions
        --[14090] = true, -- Gormok Wants His Snobolds
        --[14112] = true, -- What Do You Feed a Yeti, Anyway?
        --[14151] = true, -- Cardinal Ruby (Alchemy)
        --[14199] = true, -- Proof of Demise: The Black Knight (Daily heroic)
        --[14016] = true, --* The Black Knight's Curse (https://www.wowhead.com/wotlk/quest=14016) (Retail Data)
        --[14017] = true, --* The Black Knight's Fate (https://www.wowhead.com/wotlk/quest=14017) (Retail Data)
        --[14142] = true, --* You've Really Done It This Time, Kul (https://www.wowhead.com/wotlk/quest=14142) (Retail Data)
        --[14096] = true, --* You've Really Done It This Time, Kul (https://www.wowhead.com/wotlk/quest=14096) (Retail Data)
        --[14074] = true, --* A Leg Up (https://www.wowhead.com/wotlk/quest=14074) (Retail Data)
        --[14143] = true, --* A Leg Up (https://www.wowhead.com/wotlk/quest=14143) (Retail Data)
        --[14136] = true, --* Rescue at Sea (https://www.wowhead.com/wotlk/quest=14136) (Retail Data)
        --[14152] = true, --* Rescue at Sea (https://www.wowhead.com/wotlk/quest=14152) (Retail Data)
        --[14077] = true, --* The Light's Mercy (https://www.wowhead.com/wotlk/quest=14077) (Retail Data)
        --[14144] = true, --* The Light's Mercy (https://www.wowhead.com/wotlk/quest=14144) (Retail Data)
        --[14080] = true, --* Stop The Aggressors (https://www.wowhead.com/wotlk/quest=14080) (Retail Data)
        --[14140] = true, --* Stop The Aggressors (https://www.wowhead.com/wotlk/quest=14140) (Retail Data)

        --- Phase 4 Icecrown Citadel
        --[24827] = true, -- "Path of Courage"
        --[24834] = true, -- "Path of Courage"
        --[24835] = true, -- "Path of Courage"
        --[24828] = true, -- "Path of Destruction"
        --[24823] = true, -- "Path of Destruction"
        --[24829] = true, -- "Path of Destruction"
        --[25239] = true, -- "Path of Might"
        --[25240] = true, -- "Path of Might"
        --[25242] = true, -- "Path of Might"
        --[24826] = true, -- "Path of Vengeance"
        --[24832] = true, -- "Path of Vengeance"
        --[24833] = true, -- "Path of Vengeance"
        --[24825] = true, -- "Path of Wisdom"
        --[24830] = true, -- "Path of Wisdom"
        --[24831] = true, -- "Path of Wisdom"
        --[24819] = true, -- "A Change of Heart"
        --[24820] = true, -- "A Change of Heart"
        --[24821] = true, -- "A Change of Heart"
        --[24822] = true, -- "A Change of Heart"
        --[24836] = true, -- "A Change of Heart"
        --[24837] = true, -- "A Change of Heart"
        --[24838] = true, -- "A Change of Heart"
        --[24839] = true, -- "A Change of Heart"
        --[24840] = true, -- "A Change of Heart"
        --[24841] = true, -- "A Change of Heart"
        --[24842] = true, -- "A Change of Heart"
        --[24843] = true, -- "A Change of Heart"
        --[24844] = true, -- "A Change of Heart"
        --[24845] = true, -- "A Change of Heart"
        --[24846] = true, -- "A Change of Heart"
        --[24847] = true, -- "A Change of Heart"
        --[25246] = true, -- "A Change of Heart"
        --[25247] = true, -- "A Change of Heart"
        --[25248] = true, -- "A Change of Heart"
        --[25249] = true, -- "A Change of Heart"
        --[24506] = true, -- Inside the Frozen Citadel (H)
        --[24510] = true, -- Inside the Frozen Citadel (A)
        --[24554] = true, -- The Battered Hilt (H)
        --[14443] = true, -- The Battered Hilt (A)
        --[24555] = true, -- What The Dragons Know (H)
        --[14444] = true, -- What The Dragons Know (A)
        --[24557] = true, -- The Silver Covenant's Scheme (H)
        --[14457] = true, -- The Sunreaver Plan (A)
        --[24556] = true, -- A Suitable Disguise (H)
        --[20438] = true, -- A Suitable Disguise (A)
        --[24451] = true, -- An Audience With The Arcanist (H)
        --[20439] = true, -- A Meeting With The Magister (A)
        --[24558] = true, -- Return To Myralion Sunblaze (H)
        --[24454] = true, -- Return To Caladis Brightspear (A)
        --[24559] = true, -- Reforging The Sword (H)
        --[24461] = true, -- Reforging The Sword (A)
        --[24560] = true, -- Tempering The Blade (H)
        --[24476] = true, -- Tempering The Blade (A)
        --[24561] = true, -- The Halls Of Reflection (H)
        --[24480] = true, -- The Halls Of Reflection (A)
        --[24562] = true, -- Journey To The Sunwell (H)
        --[24522] = true, -- Journey To The Sunwell (A)
        --[24563] = true, -- Thalorien Dawnseeker (H)
        --[24535] = true, -- Thalorien Dawnseeker (A)
        --[24564] = true, -- The Purification of Quel'Delar (H)
        --[24553] = true, -- The Purification of Quel'Delar (A)
        --[24594] = true, -- The Purification of Quel'Delar (H Belf)
        --[24595] = true, -- The Purification of Quel'Delar (A Druid/Priest/Shaman)
        --[24598] = true, -- The Purification of Quel'Delar (H ?)
        --[24801] = true, -- A Victory For The Sunreavers (H)
        --[24796] = true, -- A Victory For The Silver Covenant (A)

        -- new raid weekly quests
        --[24579] = true,
        --[24580] = true,
        --[24581] = true,
        --[24582] = true,
        --[24583] = true,
        --[24584] = true,
        --[24585] = true,
        --[24586] = true,
        --[24587] = true,
        --[24588] = true,
        --[24589] = true,
        --[24590] = true,

        --- Phase 5 Ruby Sanctum
        --[26012] = true, -- Trouble at Wyrmrest
        --[26013] = true, -- Assault on the Sanctum

        ----- SoD -------------- SoD quests --------------- SoD -----
        [78611] = true, -- A Waylaid Shipment (no longer available in P2)
        [79100] = true, -- A Waylaid Shipment (no longer available in P2)
        [79482] = true, -- Stolen Winter Veil Treats
        [79483] = true, -- Stolen Winter Veil Treats
        [79484] = true, -- You're a Mean One...
        [79485] = true, -- You're a Mean One...
        [79486] = true, -- A Smokywood Pastures' Thank You!
        [79487] = true, -- A Smokywood Pastures' Thank You!
        [79492] = true, -- Metzen the Reindeer
        [79495] = true, -- Metzen the Reindeer
        [79588] = true, -- Small Furry Paws
        [79589] = true, -- Torn Bear Pelts
        [79590] = true, -- Heavy Grinding Stone
        [79591] = true, -- Whirring Bronze Gizmo
        [79592] = true, -- Carnival Jerkins
        [79593] = true, -- Coarse Weightstone
        [79594] = true, -- Copper Modulator
        [79595] = true, -- Carnival Boots
        [80421] = true, -- Green Iron Bracers
        [80422] = true, -- Green Fireworks
        [80423] = true, -- The World's Largest Gnome!

        --- Automatic Overrides (for when Wowhead data is wrong)
        [13134] = false, -- Spill Their Blood
        [13136] = false, -- Jagged Shards
        [13138] = false, -- I'm Smelting... Smelting!
        [13140] = false, -- The Runesmiths of Malykriss
        [13221] = false, -- I'm Not Dead Yet!
        [13229] = false, -- I'm Not Dead Yet!
        [13152] = false, -- A Visit to the Doctor
        [13211] = false, -- By Fire Be Purged
        [13144] = false, -- Killing Two Scourge With One Skeleton
        [13161] = false, -- The Rider of the Unholy
        [13162] = false, -- The Rider of the Frost
        [13163] = false, -- The Rider of the Blood
        [13212] = false, -- He's Gone to Pieces
        [13220] = false, -- Putting Olakin Back Together Again
        [13235] = false, -- The Flesh Giant Champion
        [13331] = false, -- Keeping the Alliance Blind
        [13359] = false, -- Where Dragons Fell
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

    if Questie.IsSoD then
        Questie:Debug(Questie.DEBUG_DEVELOP, "Blacklisting SoD quests...")
        local questsByPhase = QuestieQuestBlacklist:GetSoDQuestsToBlacklist()
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
        --! 1.11.1
        -- Battlegrounds -> Alterac Valley (6 -> 2597)
        [7361] = true, --* Favor Amongst the Darkspear (https://www.wowhead.com/wotlk/quest=7361) (Retail Data)
        [7362] = true, --* Ally of the Tauren (https://www.wowhead.com/wotlk/quest=7362) (Retail Data)
        [7363] = true, --* The Human Condition (https://www.wowhead.com/wotlk/quest=7363) (Retail Data)
        [7364] = true, --* Gnomeregan Bounty (https://www.wowhead.com/wotlk/quest=7364) (Retail Data)
        [7365] = true, --* Staghelm's Requiem (https://www.wowhead.com/wotlk/quest=7365) (Retail Data)
        [7366] = true, --* The Archbishop's Mercy (https://www.wowhead.com/wotlk/quest=7366) (Retail Data)
        [7381] = true, --* The Return of Korrak (https://www.wowhead.com/wotlk/quest=7381) (Retail Data)
        [7382] = true, --* Korrak the Everliving (https://www.wowhead.com/wotlk/quest=7382) (Retail Data)
        [7401] = true, --* WANTED: Dwarves! (https://www.wowhead.com/wotlk/quest=7401) (Retail Data)
        [7402] = true, --* WANTED: Orcs! (https://www.wowhead.com/wotlk/quest=7402) (Retail Data)


        --! 1.12.1
        -- Kalimdor -> Dustwallow Marsh (1 -> 15)
        [1289] = true, --* <nyi> Vimes's Report (https://www.wowhead.com/wotlk/quest=1289) (Retail Data)
        [1390] = true, --* <nyi> Oops, We Killed Them Again. (https://www.wowhead.com/wotlk/quest=1390) (Retail Data)

        -- Kalimdor -> Felwood (1 -> 361)
        [7741] = true, --* Praise from the Emerald Circle <NYI> <TXT> (https://www.wowhead.com/wotlk/quest=7741) (Retail Data)

        -- Kalimdor -> Silithus (1 -> 1377)
        [8340] = true, --* Twilight Signet Ring <NYI> <TXT> (https://www.wowhead.com/wotlk/quest=8340) (Retail Data)

        -- Classes -> Rogue (4 -> -162)
        [2018] = true, --* Rokar's Test (https://www.wowhead.com/wotlk/quest=2018) (Retail Data)
        [2019] = true, --* Tools of the Trade (https://www.wowhead.com/wotlk/quest=2019) (Retail Data)

        -- Uncategorized ->  (-2 -> 0)
        [6843] = true, --* Da Foo (https://www.wowhead.com/wotlk/quest=6843) (Retail Data)
        [8230] = true, --* Collin's Test Quest (https://www.wowhead.com/wotlk/quest=8230) (Retail Data)

        -- World Events -> Darkmoon Faire (9 -> -364)
        [7906] = true, --* Darkmoon Cards - Beasts (https://www.wowhead.com/wotlk/quest=7906) (Retail Data)

        -- Battlegrounds -> Warsong Gulch (6 -> 3277)
        [7886] = true, --* Talismans of Merit (https://www.wowhead.com/wotlk/quest=7886) (Retail Data)
        [7887] = true, --* Talismans of Merit (https://www.wowhead.com/wotlk/quest=7887) (Retail Data)
        [7888] = true, --* Talismans of Merit (https://www.wowhead.com/wotlk/quest=7888) (Retail Data)
        [7921] = true, --* Talismans of Merit (https://www.wowhead.com/wotlk/quest=7921) (Retail Data)
        [7922] = true, --* Mark of Honor (https://www.wowhead.com/wotlk/quest=7922) (Retail Data)
        [7923] = true, --* Mark of Honor (https://www.wowhead.com/wotlk/quest=7923) (Retail Data)
        [7924] = true, --* Mark of Honor (https://www.wowhead.com/wotlk/quest=7924) (Retail Data)
        [7925] = true, --* Mark of Honor (https://www.wowhead.com/wotlk/quest=7925) (Retail Data)
        [8001] = true, --* Warsong Outriders <NYI> <TXT> (https://www.wowhead.com/wotlk/quest=8001) (Retail Data)
        [8002] = true, --* Silverwing Sentinels <NYI> <TXT> (https://www.wowhead.com/wotlk/quest=8002) (Retail Data)
        [8267] = true, --* Ribbons of Sacrifice (https://www.wowhead.com/wotlk/quest=8267) (Retail Data)
        [8269] = true, --* Ribbons of Sacrifice (https://www.wowhead.com/wotlk/quest=8269) (Retail Data)
        [8289] = true, --* Talismans of Merit (https://www.wowhead.com/wotlk/quest=8289) (Retail Data)
        [8292] = true, --* Talismans of Merit (https://www.wowhead.com/wotlk/quest=8292) (Retail Data)
        [8293] = true, --* Mark of Honor (https://www.wowhead.com/wotlk/quest=8293) (Retail Data)
        [8296] = true, --* Mark of Honor (https://www.wowhead.com/wotlk/quest=8296) (Retail Data)

        -- Battlegrounds -> Alterac Valley (6 -> 2597)
        [7421] = true, --* Darkspear Defense (https://www.wowhead.com/wotlk/quest=7421) (Retail Data)
        [7422] = true, --* Tuft it Out (https://www.wowhead.com/wotlk/quest=7422) (Retail Data)
        [7423] = true, --* I've Got A Fever For More Bone Chips (https://www.wowhead.com/wotlk/quest=7423) (Retail Data)
        [7424] = true, --* What the Hoof? (https://www.wowhead.com/wotlk/quest=7424) (Retail Data)
        [7425] = true, --* Staghelm's Mojo Jamboree (https://www.wowhead.com/wotlk/quest=7425) (Retail Data)
        [7426] = true, --* One Man's Love (https://www.wowhead.com/wotlk/quest=7426) (Retail Data)
        [7427] = true, --* Wanted: MORE DWARVES! (https://www.wowhead.com/wotlk/quest=7427) (Retail Data)
        [7428] = true, --* Wanted: MORE ORCS! (https://www.wowhead.com/wotlk/quest=7428) (Retail Data)

        -- Battlegrounds -> Arathi Basin (6 -> 3358)
        [8081] = true, --* More Resource Crates (https://www.wowhead.com/wotlk/quest=8081) (Retail Data)
        [8124] = true, --* More Resource Crates (https://www.wowhead.com/wotlk/quest=8124) (Retail Data)
        [8157] = true, --* More Resource Crates (https://www.wowhead.com/wotlk/quest=8157) (Retail Data)
        [8158] = true, --* More Resource Crates (https://www.wowhead.com/wotlk/quest=8158) (Retail Data)
        [8159] = true, --* More Resource Crates (https://www.wowhead.com/wotlk/quest=8159) (Retail Data)
        [8163] = true, --* More Resource Crates (https://www.wowhead.com/wotlk/quest=8163) (Retail Data)
        [8164] = true, --* More Resource Crates (https://www.wowhead.com/wotlk/quest=8164) (Retail Data)
        [8165] = true, --* More Resource Crates (https://www.wowhead.com/wotlk/quest=8165) (Retail Data)
        [8298] = true, --* More Resource Crates (https://www.wowhead.com/wotlk/quest=8298) (Retail Data)
        [8300] = true, --* More Resource Crates (https://www.wowhead.com/wotlk/quest=8300) (Retail Data)

        -- Miscellaneous ->  (7 -> 0)
        [8618] = true, --* The Horde Needs More Singed Corestones! (https://www.wowhead.com/wotlk/quest=8618) (Retail Data)

        -- Miscellaneous -> Legendary (7 -> -344)
        [7521] = true, --* Thunderaan the Windseeker (https://www.wowhead.com/wotlk/quest=7521) (Retail Data)
        [7522] = true, --* Examine the Vessel (https://www.wowhead.com/wotlk/quest=7522) (Retail Data)

        -- Eastern Kingdoms -> Eversong Woods (0 -> 3430)
        [8329] = true, --* Warrior Training (https://www.wowhead.com/wotlk/quest=8329) (Retail Data)
        [8478] = true, --* Choose Your Weapon (https://www.wowhead.com/wotlk/quest=8478) (Retail Data)


        --! 1.13.2
        -- Professions -> Engineering (5 -> -201)
        [3638] = true, --* The Pledge of Secrecy (https://www.wowhead.com/wotlk/quest=3638)
        [3640] = true, --* The Pledge of Secrecy (https://www.wowhead.com/wotlk/quest=3640)
        [3642] = true, --* The Pledge of Secrecy (https://www.wowhead.com/wotlk/quest=3642)

        -- Raids ->  (3 -> 0)
        [7509] = true, --* The Forging of Quel'Serrar (https://www.wowhead.com/wotlk/quest=7509)

        -- Eastern Kingdoms -> Wetlands (0 -> 11)
        [1132] = true, --* Fiora Longears (https://www.wowhead.com/wotlk/quest=1132)

        -- Classes -> Warlock (4 -> -61)
        [1470] = true, --* Piercing the Veil (https://www.wowhead.com/wotlk/quest=1470)
        [1485] = true, --* Vile Familiars (https://www.wowhead.com/wotlk/quest=1485)
        [1598] = true, --* The Stolen Tome (https://www.wowhead.com/wotlk/quest=1598)
        [1599] = true, --* Beginnings (https://www.wowhead.com/wotlk/quest=1599)

        -- Classes -> Rogue (4 -> -162)
        [1978] = true, --* The Deathstalkers (https://www.wowhead.com/wotlk/quest=1978)

        -- Kalimdor -> Mulgore (1 -> 215)
        [781] = true, --* Attack on Camp Narache (https://www.wowhead.com/wotlk/quest=781)

        -- Kalimdor -> Darkshore (1 -> 148)
        [1133] = true, --* Journey to Astranaar (https://www.wowhead.com/wotlk/quest=1133)

        -- Dungeons -> Scarlet Monastery (2 -> 796)
        [1048] = true, --* Into The Scarlet Monastery (https://www.wowhead.com/wotlk/quest=1048)

        -- Dungeons -> Ragefire Chasm (2 -> 2437)
        [5725] = true, --* The Power to Destroy... (https://www.wowhead.com/wotlk/quest=5725)

        -- Dungeons -> Dire Maul (2 -> 2557)
        [7507] = true, --* Nostro's Compendium (https://www.wowhead.com/wotlk/quest=7507)
        [7508] = true, --* The Forging of Quel'Serrar (https://www.wowhead.com/wotlk/quest=7508)


        --! 2.4.2
        -- Uncategorized ->  (-2 -> 0)
        [12600] = true, --* Upper Deck Promo - Bear Mount (https://www.wowhead.com/wotlk/quest=12600) (Retail Data)


        --! 2.5.1
        -- Classes -> Warlock (4 -> -61)
        [8344] = true, --* Windows to the Source (https://www.wowhead.com/wotlk/quest=8344)


        --! 3.0.1
        -- World Events ->  (9 -> 0)
        [11937] = true, --* FLAG - all torch return quests are complete (https://www.wowhead.com/wotlk/quest=11937) (Retail Data)

        -- Uncategorized ->  (-2 -> 0)
        [11518] = true, --* Sunwell Daily Portal Flag (https://www.wowhead.com/wotlk/quest=11518) (Retail Data)
        [11577] = true, --* WoW Collector's Edition: - DEM - E - FLAG (https://www.wowhead.com/wotlk/quest=11577) (Retail Data)
        [11874] = true, --* Upper Deck Promo - Rocket Mount (https://www.wowhead.com/wotlk/quest=11874) (Retail Data)
        [11994] = true, --* Juno's Flag Tester (https://www.wowhead.com/wotlk/quest=11994) (Retail Data)
        [12186] = true, --* FLAG: Winner (https://www.wowhead.com/wotlk/quest=12186) (Retail Data)
        [12187] = true, --* FLAG: Participant (https://www.wowhead.com/wotlk/quest=12187) (Retail Data)
        [12693] = true, --* Wolvar Faction Choice Tracker (https://www.wowhead.com/wotlk/quest=12693) (Retail Data)
        [12694] = true, --* Oracle Faction Choice Tracker (https://www.wowhead.com/wotlk/quest=12694) (Retail Data)
        [12781] = true, --* Welcome! (https://www.wowhead.com/wotlk/quest=12781) (Retail Data)
        [12845] = true, --* Dalaran Teleport Crystal Flag (https://www.wowhead.com/wotlk/quest=12845) (Retail Data)


        --! 3.0.2
        -- Uncategorized ->  (-2 -> 0)
        [10454] = true, --* FLAG - OFF THE RAILS (https://www.wowhead.com/wotlk/quest=10454) (Retail Data)
        [13123] = true, --* WotLK Collector's Edition: - DEM - E - FLAG (https://www.wowhead.com/wotlk/quest=13123) (Retail Data)
        [13210] = true, --* Blizzard Account: - DEM - E - FLAG (https://www.wowhead.com/wotlk/quest=13210) (Retail Data)

        -- Outland ->  (8 -> 0)
        [10610] = true, --* Prospecting Basics (https://www.wowhead.com/wotlk/quest=10610) (Retail Data)


        --! 3.0.3
        -- Uncategorized ->  (-2 -> 0)
        [9713] = true, --* Glowcap Harvesting Enabling Flag (https://www.wowhead.com/wotlk/quest=9713) (Retail Data)


        --! 3.1.0
        -- Uncategorized ->  (-2 -> 0)
        [13807] = true, --* FLAG: Tournament Invitation (https://www.wowhead.com/wotlk/quest=13807) (Retail Data)


        --! 3.3.0
        -- Professions -> Alchemy (5 -> -181)
        [14147] = true, --* Blank [PH] (https://www.wowhead.com/wotlk/quest=14147) (Retail Data)
        [14148] = true, --* Blank [PH] (https://www.wowhead.com/wotlk/quest=14148) (Retail Data)
        [14149] = true, --* Blank [PH] (https://www.wowhead.com/wotlk/quest=14149) (Retail Data)
        [14150] = true, --* Blank [PH] (https://www.wowhead.com/wotlk/quest=14150) (Retail Data)

        -- Kalimdor -> Orgrimmar (1 -> 1637)
        --[24429] = true, --* A Most Puzzling Circumstance (https://www.wowhead.com/wotlk/quest=24429) (Retail Data)

        -- Kalimdor -> Darnassus (1 -> 1657)
        --[14409] = true, --* A Cautious Return (https://www.wowhead.com/wotlk/quest=14409) (Retail Data)

        --  ->  (0 -> 0)
        [12103] = true, --* Before the Storm (https://www.wowhead.com/wotlk/quest=12103) (Retail Data)

        -- Battlegrounds -> Arathi Basin (6 -> 3358)
        [10533] = true, --* More Resource Crates (https://www.wowhead.com/wotlk/quest=10533) (Retail Data)
        [10536] = true, --* More Resource Crates (https://www.wowhead.com/wotlk/quest=10536) (Retail Data)

        -- Classes -> Mage (4 -> -161)
        [12228] = true, --* Reacquiring the Magic [PH] (https://www.wowhead.com/wotlk/quest=12228) (Retail Data)

        -- Northrend -> Tournament (10 -> -241)
--         [13592] = true, --* A Valiant's Field Training (https://www.wowhead.com/wotlk/quest=13592) (Retail Data)
--         [13593] = true, --* Valiant Of Stormwind (https://www.wowhead.com/wotlk/quest=13593) (Retail Data)
--         [13600] = true, --* A Worthy Weapon (https://www.wowhead.com/wotlk/quest=13600) (Retail Data)
--         [13603] = true, --* A Blade Fit For A Champion (https://www.wowhead.com/wotlk/quest=13603) (Retail Data)
--         [13616] = true, --* The Edge Of Winter (https://www.wowhead.com/wotlk/quest=13616) (Retail Data)
--         [13625] = true, --* Learning The Reins (https://www.wowhead.com/wotlk/quest=13625) (Retail Data)
--         [13633] = true, --* The Black Knight of Westfall? (https://www.wowhead.com/wotlk/quest=13633) (Retail Data)
--         [13634] = true, --* The Black Knight of Silverpine? (https://www.wowhead.com/wotlk/quest=13634) (Retail Data)
--         [13641] = true, --* The Seer's Crystal (https://www.wowhead.com/wotlk/quest=13641) (Retail Data)
--         [13643] = true, --* The Stories Dead Men Tell (https://www.wowhead.com/wotlk/quest=13643) (Retail Data)
--         [13654] = true, --* There's Something About the Squire (https://www.wowhead.com/wotlk/quest=13654) (Retail Data)
--         [13663] = true, --* The Black Knight's Orders (https://www.wowhead.com/wotlk/quest=13663) (Retail Data)
--         [13664] = true, --* The Black Knight's Fall (https://www.wowhead.com/wotlk/quest=13664) (Retail Data)
--         [13665] = true, --* The Grand Melee (https://www.wowhead.com/wotlk/quest=13665) (Retail Data)
--         [13666] = true, --* A Blade Fit For A Champion (https://www.wowhead.com/wotlk/quest=13666) (Retail Data)
--         [13667] = true, --* The Argent Tournament (https://www.wowhead.com/wotlk/quest=13667) (Retail Data)
--         [13668] = true, --* The Argent Tournament (https://www.wowhead.com/wotlk/quest=13668) (Retail Data)
--         [13669] = true, --* A Worthy Weapon (https://www.wowhead.com/wotlk/quest=13669) (Retail Data)
--         [13670] = true, --* The Edge Of Winter (https://www.wowhead.com/wotlk/quest=13670) (Retail Data)
--         [13671] = true, --* Training In The Field (https://www.wowhead.com/wotlk/quest=13671) (Retail Data)
--         [13672] = true, --* Up To The Challenge (https://www.wowhead.com/wotlk/quest=13672) (Retail Data)
--         [13673] = true, --* A Blade Fit For A Champion (https://www.wowhead.com/wotlk/quest=13673) (Retail Data)
--         [13674] = true, --* A Worthy Weapon (https://www.wowhead.com/wotlk/quest=13674) (Retail Data)
--         [13675] = true, --* The Edge Of Winter (https://www.wowhead.com/wotlk/quest=13675) (Retail Data)
--         [13676] = true, --* Training In The Field (https://www.wowhead.com/wotlk/quest=13676) (Retail Data)
--         [13677] = true, --* Learning The Reins (https://www.wowhead.com/wotlk/quest=13677) (Retail Data)
--         [13678] = true, --* Up To The Challenge (https://www.wowhead.com/wotlk/quest=13678) (Retail Data)
--         [13679] = true, --* The Aspirant's Challenge (https://www.wowhead.com/wotlk/quest=13679) (Retail Data)
--         [13680] = true, --* The Aspirant's Challenge (https://www.wowhead.com/wotlk/quest=13680) (Retail Data)
--         [13684] = true, --* A Valiant Of Stormwind (https://www.wowhead.com/wotlk/quest=13684) (Retail Data)
--         [13685] = true, --* A Valiant Of Ironforge (https://www.wowhead.com/wotlk/quest=13685) (Retail Data)
--         [13686] = true, --* Alliance Tournament Eligibility Marker (https://www.wowhead.com/wotlk/quest=13686) (Retail Data)
--         [13687] = true, --* Horde Tournament Eligibility Marker (https://www.wowhead.com/wotlk/quest=13687) (Retail Data)
--         [13688] = true, --* A Valiant Of Gnomeregan (https://www.wowhead.com/wotlk/quest=13688) (Retail Data)
--         [13689] = true, --* A Valiant Of Darnassus (https://www.wowhead.com/wotlk/quest=13689) (Retail Data)
--         [13690] = true, --* A Valiant Of The Exodar (https://www.wowhead.com/wotlk/quest=13690) (Retail Data)
--         [13691] = true, --* A Valiant Of Orgrimmar (https://www.wowhead.com/wotlk/quest=13691) (Retail Data)
--         [13693] = true, --* A Valiant Of Sen'jin (https://www.wowhead.com/wotlk/quest=13693) (Retail Data)
--         [13694] = true, --* A Valiant Of Thunder Bluff (https://www.wowhead.com/wotlk/quest=13694) (Retail Data)
--         [13695] = true, --* A Valiant Of Undercity (https://www.wowhead.com/wotlk/quest=13695) (Retail Data)
--         [13696] = true, --* A Valiant Of Silvermoon (https://www.wowhead.com/wotlk/quest=13696) (Retail Data)
--         [13697] = true, --* The Valiant's Charge (https://www.wowhead.com/wotlk/quest=13697) (Retail Data)
--         [13699] = true, --* The Valiant's Challenge (https://www.wowhead.com/wotlk/quest=13699) (Retail Data)
--         [13700] = true, --* Alliance Champion Marker (https://www.wowhead.com/wotlk/quest=13700) (Retail Data)
--         [13701] = true, --* Horde Champion Marker (https://www.wowhead.com/wotlk/quest=13701) (Retail Data)
--         [13702] = true, --* A Champion Rises (https://www.wowhead.com/wotlk/quest=13702) (Retail Data)
--         [13703] = true, --* Valiant Of Ironforge (https://www.wowhead.com/wotlk/quest=13703) (Retail Data)
--         [13704] = true, --* Valiant Of Gnomeregan (https://www.wowhead.com/wotlk/quest=13704) (Retail Data)
--         [13705] = true, --* Valiant Of The Exodar (https://www.wowhead.com/wotlk/quest=13705) (Retail Data)
--         [13706] = true, --* Valiant Of Darnassus (https://www.wowhead.com/wotlk/quest=13706) (Retail Data)
--         [13707] = true, --* Valiant Of Orgrimmar (https://www.wowhead.com/wotlk/quest=13707) (Retail Data)
--         [13708] = true, --* Valiant Of Sen'jin (https://www.wowhead.com/wotlk/quest=13708) (Retail Data)
--         [13709] = true, --* Valiant Of Thunder Bluff (https://www.wowhead.com/wotlk/quest=13709) (Retail Data)
--         [13710] = true, --* Valiant Of Undercity (https://www.wowhead.com/wotlk/quest=13710) (Retail Data)
--         [13711] = true, --* Valiant Of Silvermoon (https://www.wowhead.com/wotlk/quest=13711) (Retail Data)
--         [13713] = true, --* The Valiant's Challenge (https://www.wowhead.com/wotlk/quest=13713) (Retail Data)
--         [13714] = true, --* The Valiant's Charge (https://www.wowhead.com/wotlk/quest=13714) (Retail Data)
--         [13715] = true, --* The Valiant's Charge (https://www.wowhead.com/wotlk/quest=13715) (Retail Data)
--         [13716] = true, --* The Valiant's Charge (https://www.wowhead.com/wotlk/quest=13716) (Retail Data)
--         [13717] = true, --* The Valiant's Charge (https://www.wowhead.com/wotlk/quest=13717) (Retail Data)
--         [13718] = true, --* The Valiant's Charge (https://www.wowhead.com/wotlk/quest=13718) (Retail Data)
--         [13719] = true, --* The Valiant's Charge (https://www.wowhead.com/wotlk/quest=13719) (Retail Data)
--         [13720] = true, --* The Valiant's Charge (https://www.wowhead.com/wotlk/quest=13720) (Retail Data)
--         [13721] = true, --* The Valiant's Charge (https://www.wowhead.com/wotlk/quest=13721) (Retail Data)
--         [13722] = true, --* The Valiant's Charge (https://www.wowhead.com/wotlk/quest=13722) (Retail Data)
--         [13723] = true, --* The Valiant's Challenge (https://www.wowhead.com/wotlk/quest=13723) (Retail Data)
--         [13724] = true, --* The Valiant's Challenge (https://www.wowhead.com/wotlk/quest=13724) (Retail Data)
--         [13725] = true, --* The Valiant's Challenge (https://www.wowhead.com/wotlk/quest=13725) (Retail Data)
--         [13726] = true, --* The Valiant's Challenge (https://www.wowhead.com/wotlk/quest=13726) (Retail Data)
--         [13727] = true, --* The Valiant's Challenge (https://www.wowhead.com/wotlk/quest=13727) (Retail Data)
--         [13728] = true, --* The Valiant's Challenge (https://www.wowhead.com/wotlk/quest=13728) (Retail Data)
--         [13729] = true, --* The Valiant's Challenge (https://www.wowhead.com/wotlk/quest=13729) (Retail Data)
--         [13731] = true, --* The Valiant's Challenge (https://www.wowhead.com/wotlk/quest=13731) (Retail Data)
--         [13732] = true, --* A Champion Rises (https://www.wowhead.com/wotlk/quest=13732) (Retail Data)
--         [13733] = true, --* A Champion Rises (https://www.wowhead.com/wotlk/quest=13733) (Retail Data)
--         [13734] = true, --* A Champion Rises (https://www.wowhead.com/wotlk/quest=13734) (Retail Data)
--         [13735] = true, --* A Champion Rises (https://www.wowhead.com/wotlk/quest=13735) (Retail Data)
--         [13736] = true, --* A Champion Rises (https://www.wowhead.com/wotlk/quest=13736) (Retail Data)
--         [13737] = true, --* A Champion Rises (https://www.wowhead.com/wotlk/quest=13737) (Retail Data)
--         [13738] = true, --* A Champion Rises (https://www.wowhead.com/wotlk/quest=13738) (Retail Data)
--         [13739] = true, --* A Champion Rises (https://www.wowhead.com/wotlk/quest=13739) (Retail Data)
--         [13740] = true, --* A Champion Rises (https://www.wowhead.com/wotlk/quest=13740) (Retail Data)
--         [13741] = true, --* A Blade Fit For A Champion (https://www.wowhead.com/wotlk/quest=13741) (Retail Data)
--         [13742] = true, --* A Worthy Weapon (https://www.wowhead.com/wotlk/quest=13742) (Retail Data)
--         [13743] = true, --* The Edge Of Winter (https://www.wowhead.com/wotlk/quest=13743) (Retail Data)
--         [13744] = true, --* A Valiant's Field Training (https://www.wowhead.com/wotlk/quest=13744) (Retail Data)
--         [13745] = true, --* The Grand Melee (https://www.wowhead.com/wotlk/quest=13745) (Retail Data)
--         [13746] = true, --* A Blade Fit For A Champion (https://www.wowhead.com/wotlk/quest=13746) (Retail Data)
--         [13747] = true, --* A Worthy Weapon (https://www.wowhead.com/wotlk/quest=13747) (Retail Data)
--         [13748] = true, --* The Edge Of Winter (https://www.wowhead.com/wotlk/quest=13748) (Retail Data)
--         [13749] = true, --* A Valiant's Field Training (https://www.wowhead.com/wotlk/quest=13749) (Retail Data)
--         [13750] = true, --* The Grand Melee (https://www.wowhead.com/wotlk/quest=13750) (Retail Data)
--         [13752] = true, --* A Blade Fit For A Champion (https://www.wowhead.com/wotlk/quest=13752) (Retail Data)
--         [13753] = true, --* A Worthy Weapon (https://www.wowhead.com/wotlk/quest=13753) (Retail Data)
--         [13754] = true, --* The Edge Of Winter (https://www.wowhead.com/wotlk/quest=13754) (Retail Data)
--         [13755] = true, --* A Valiant's Field Training (https://www.wowhead.com/wotlk/quest=13755) (Retail Data)
--         [13756] = true, --* The Grand Melee (https://www.wowhead.com/wotlk/quest=13756) (Retail Data)
--         [13757] = true, --* A Blade Fit For A Champion (https://www.wowhead.com/wotlk/quest=13757) (Retail Data)
--         [13758] = true, --* A Worthy Weapon (https://www.wowhead.com/wotlk/quest=13758) (Retail Data)
--         [13759] = true, --* The Edge Of Winter (https://www.wowhead.com/wotlk/quest=13759) (Retail Data)
--         [13760] = true, --* A Valiant's Field Training (https://www.wowhead.com/wotlk/quest=13760) (Retail Data)
--         [13761] = true, --* The Grand Melee (https://www.wowhead.com/wotlk/quest=13761) (Retail Data)
--         [13762] = true, --* A Blade Fit For A Champion (https://www.wowhead.com/wotlk/quest=13762) (Retail Data)
--         [13763] = true, --* A Worthy Weapon (https://www.wowhead.com/wotlk/quest=13763) (Retail Data)
--         [13764] = true, --* The Edge Of Winter (https://www.wowhead.com/wotlk/quest=13764) (Retail Data)
--         [13765] = true, --* A Valiant's Field Training (https://www.wowhead.com/wotlk/quest=13765) (Retail Data)
--         [13767] = true, --* The Grand Melee (https://www.wowhead.com/wotlk/quest=13767) (Retail Data)
--         [13768] = true, --* A Blade Fit For A Champion (https://www.wowhead.com/wotlk/quest=13768) (Retail Data)
--         [13769] = true, --* A Worthy Weapon (https://www.wowhead.com/wotlk/quest=13769) (Retail Data)
--         [13770] = true, --* The Edge Of Winter (https://www.wowhead.com/wotlk/quest=13770) (Retail Data)
--         [13771] = true, --* A Valiant's Field Training (https://www.wowhead.com/wotlk/quest=13771) (Retail Data)
--         [13772] = true, --* The Grand Melee (https://www.wowhead.com/wotlk/quest=13772) (Retail Data)
--         [13773] = true, --* A Blade Fit For A Champion (https://www.wowhead.com/wotlk/quest=13773) (Retail Data)
--         [13774] = true, --* A Worthy Weapon (https://www.wowhead.com/wotlk/quest=13774) (Retail Data)
--         [13775] = true, --* The Edge Of Winter (https://www.wowhead.com/wotlk/quest=13775) (Retail Data)
--         [13776] = true, --* A Valiant's Field Training (https://www.wowhead.com/wotlk/quest=13776) (Retail Data)
--         [13777] = true, --* The Grand Melee (https://www.wowhead.com/wotlk/quest=13777) (Retail Data)
--         [13778] = true, --* A Blade Fit For A Champion (https://www.wowhead.com/wotlk/quest=13778) (Retail Data)
--         [13779] = true, --* A Worthy Weapon (https://www.wowhead.com/wotlk/quest=13779) (Retail Data)
--         [13780] = true, --* The Edge Of Winter (https://www.wowhead.com/wotlk/quest=13780) (Retail Data)
--         [13781] = true, --* A Valiant's Field Training (https://www.wowhead.com/wotlk/quest=13781) (Retail Data)
--         [13782] = true, --* The Grand Melee (https://www.wowhead.com/wotlk/quest=13782) (Retail Data)
--         [13783] = true, --* A Blade Fit For A Champion (https://www.wowhead.com/wotlk/quest=13783) (Retail Data)
--         [13784] = true, --* A Worthy Weapon (https://www.wowhead.com/wotlk/quest=13784) (Retail Data)
--         [13786] = true, --* A Valiant's Field Training (https://www.wowhead.com/wotlk/quest=13786) (Retail Data)
--         [13787] = true, --* The Grand Melee (https://www.wowhead.com/wotlk/quest=13787) (Retail Data)
--         [13788] = true, --* Threat From Above (https://www.wowhead.com/wotlk/quest=13788) (Retail Data)
--         [13791] = true, --* Taking Battle To The Enemy (https://www.wowhead.com/wotlk/quest=13791) (Retail Data)
--         [13793] = true, --* Among the Champions (https://www.wowhead.com/wotlk/quest=13793) (Retail Data)
--         [13794] = true, --* Eadric the Pure (https://www.wowhead.com/wotlk/quest=13794) (Retail Data)
--         [13795] = true, --* The Scourgebane (https://www.wowhead.com/wotlk/quest=13795) (Retail Data)
--         [13812] = true, --* Threat From Above (https://www.wowhead.com/wotlk/quest=13812) (Retail Data)
--         [13813] = true, --* Taking Battle To The Enemy (https://www.wowhead.com/wotlk/quest=13813) (Retail Data)
--         [13814] = true, --* Among the Champions (https://www.wowhead.com/wotlk/quest=13814) (Retail Data)
           [13820] = true, --* The Blastbolt Brothers (https://www.wowhead.com/wotlk/quest=13820) (Retail Data)
--         [13828] = true, --* Mastery Of Melee (https://www.wowhead.com/wotlk/quest=13828) (Retail Data)
--         [13829] = true, --* Mastery Of Melee (https://www.wowhead.com/wotlk/quest=13829) (Retail Data)
--         [13835] = true, --* Mastery Of The Shield-Breaker (https://www.wowhead.com/wotlk/quest=13835) (Retail Data)
--         [13837] = true, --* Mastery Of The Charge (https://www.wowhead.com/wotlk/quest=13837) (Retail Data)
--         [13838] = true, --* Mastery Of The Shield-Breaker (https://www.wowhead.com/wotlk/quest=13838) (Retail Data)
--         [13839] = true, --* Mastery Of The Charge (https://www.wowhead.com/wotlk/quest=13839) (Retail Data)
--         [13846] = true, --* Contributin' To The Cause (https://www.wowhead.com/wotlk/quest=13846) (Retail Data)
--         [13847] = true, --* At The Enemy's Gates (https://www.wowhead.com/wotlk/quest=13847) (Retail Data)
--         [13851] = true, --* At The Enemy's Gates (https://www.wowhead.com/wotlk/quest=13851) (Retail Data)
--         [13852] = true, --* At The Enemy's Gates (https://www.wowhead.com/wotlk/quest=13852) (Retail Data)
--         [13854] = true, --* At The Enemy's Gates (https://www.wowhead.com/wotlk/quest=13854) (Retail Data)
--         [13855] = true, --* At The Enemy's Gates (https://www.wowhead.com/wotlk/quest=13855) (Retail Data)
--         [13856] = true, --* At The Enemy's Gates (https://www.wowhead.com/wotlk/quest=13856) (Retail Data)
--         [13857] = true, --* At The Enemy's Gates (https://www.wowhead.com/wotlk/quest=13857) (Retail Data)
--         [13858] = true, --* At The Enemy's Gates (https://www.wowhead.com/wotlk/quest=13858) (Retail Data)
--         [13859] = true, --* At The Enemy's Gates (https://www.wowhead.com/wotlk/quest=13859) (Retail Data)
--         [13860] = true, --* At The Enemy's Gates (https://www.wowhead.com/wotlk/quest=13860) (Retail Data)
--         [13863] = true, --* Battle Before The Citadel (https://www.wowhead.com/wotlk/quest=13863) (Retail Data)
--         [13864] = true, --* Battle Before The Citadel (https://www.wowhead.com/wotlk/quest=13864) (Retail Data)
--         [14016] = true, --* The Black Knight's Curse (https://www.wowhead.com/wotlk/quest=14016) (Retail Data)
--         [14017] = true, --* The Black Knight's Fate (https://www.wowhead.com/wotlk/quest=14017) (Retail Data)
--        [14076] = true, --* Breakfast Of Champions (https://www.wowhead.com/wotlk/quest=14076) (Retail Data)
--        [14090] = true, --* Gormok Wants His Snobolds (https://www.wowhead.com/wotlk/quest=14090) (Retail Data)
--        [14092] = true, --* Breakfast Of Champions (https://www.wowhead.com/wotlk/quest=14092) (Retail Data)
--         [14095] = true, --* Identifying the Remains (https://www.wowhead.com/wotlk/quest=14095) (Retail Data)
--         [14101] = true, --* Drottinn Hrothgar (https://www.wowhead.com/wotlk/quest=14101) (Retail Data)
--         [14102] = true, --* Mistcaller Yngvar (https://www.wowhead.com/wotlk/quest=14102) (Retail Data)
--         [14104] = true, --* Ornolf The Scarred (https://www.wowhead.com/wotlk/quest=14104) (Retail Data)
--         [14105] = true, --* Deathspeaker Kharos (https://www.wowhead.com/wotlk/quest=14105) (Retail Data)
--         [14107] = true, --* The Fate Of The Fallen (https://www.wowhead.com/wotlk/quest=14107) (Retail Data)
--         [14141] = true, --* Gormok Wants His Snobolds (https://www.wowhead.com/wotlk/quest=14141) (Retail Data)
--         [14145] = true, --* What Do You Feed a Yeti, Anyway? (https://www.wowhead.com/wotlk/quest=14145) (Retail Data)
--         [14200] = true, --* Kickoff Mail Marker (https://www.wowhead.com/wotlk/quest=14200) (Retail Data)
--         [24442] = true, --* Battle Plans Of The Kvaldir (https://www.wowhead.com/wotlk/quest=24442) (Retail Data)

        -- Northrend -> Icecrown (10 -> 210)
--      [14444] = true, --* What The Dragons Know (https://www.wowhead.com/wotlk/quest=14444) (Retail Data)
--      [20438] = true, --* A Suitable Disguise (https://www.wowhead.com/wotlk/quest=20438) (Retail Data)
--      [20439] = true, --* A Meeting With The Magister (https://www.wowhead.com/wotlk/quest=20439) (Retail Data)
--      [24451] = true, --* An Audience With The Arcanist (https://www.wowhead.com/wotlk/quest=24451) (Retail Data)
--      [24454] = true, --* Return To Caladis Brightspear (https://www.wowhead.com/wotlk/quest=24454) (Retail Data)
--      [24476] = true, --* Tempering The Blade (https://www.wowhead.com/wotlk/quest=24476) (Retail Data)
--      [24555] = true, --* What The Dragons Know (https://www.wowhead.com/wotlk/quest=24555) (Retail Data)
--      [24556] = true, --* A Suitable Disguise (https://www.wowhead.com/wotlk/quest=24556) (Retail Data)
--      [24558] = true, --* Return To Myralion Sunblaze (https://www.wowhead.com/wotlk/quest=24558) (Retail Data)
--      [24560] = true, --* Tempering The Blade (https://www.wowhead.com/wotlk/quest=24560) (Retail Data)
--      [24795] = true, --* A Victory For The Silver Covenant (https://www.wowhead.com/wotlk/quest=24795) (Retail Data)
--      [24796] = true, --* A Victory For The Silver Covenant (https://www.wowhead.com/wotlk/quest=24796) (Retail Data)
--      [24798] = true, --* A Victory For The Sunreavers (https://www.wowhead.com/wotlk/quest=24798) (Retail Data)
--      [24799] = true, --* A Victory For The Sunreavers (https://www.wowhead.com/wotlk/quest=24799) (Retail Data)
--      [24800] = true, --* A Victory For The Sunreavers (https://www.wowhead.com/wotlk/quest=24800) (Retail Data)
--      [24801] = true, --* A Victory For The Sunreavers (https://www.wowhead.com/wotlk/quest=24801) (Retail Data)
        [24808] = true, --* Tank Ring Flag (https://www.wowhead.com/wotlk/quest=24808) (Retail Data)
        [24809] = true, --* Healer Ring Flag (https://www.wowhead.com/wotlk/quest=24809) (Retail Data)
        [24810] = true, --* Melee Ring Flag (https://www.wowhead.com/wotlk/quest=24810) (Retail Data)
        [24811] = true, --* Caster Ring Flag (https://www.wowhead.com/wotlk/quest=24811) (Retail Data)
        [25238] = true, --* Strength Ring Flag (https://www.wowhead.com/wotlk/quest=25238) (Retail Data)

        -- Northrend -> Dalaran (10 -> 4395)
--      [14457] = true, --* The Sunreaver Plan (https://www.wowhead.com/wotlk/quest=14457) (Retail Data)
--      [24557] = true, --* The Silver Covenant's Scheme (https://www.wowhead.com/wotlk/quest=24557) (Retail Data)

        -- Northrend -> Sholazar Basin (10 -> 3711)
        [12764] = true, --* The Secret to Kungaloosh (https://www.wowhead.com/wotlk/quest=12764) (Retail Data)
        [12765] = true, --* Kungaloosh (https://www.wowhead.com/wotlk/quest=12765) (Retail Data)

        -- Northrend -> Dragonblight (10 -> 65)
        [12023] = true, --* Sweeter Revenge (https://www.wowhead.com/wotlk/quest=12023) (Retail Data)

        -- Northrend -> Howling Fjord (10 -> 495)
        [12485] = true, --* Howling Fjord: aa - A - LK FLAG (https://www.wowhead.com/wotlk/quest=12485) (Retail Data)

        -- Outland -> Hellfire Peninsula (8 -> 3483)
        [9342] = true, --* Marauding Crust Bursters (https://www.wowhead.com/wotlk/quest=9342)
        [9344] = true, --* A Hasty Departure (https://www.wowhead.com/wotlk/quest=9344)
        [9346] = true, --* When Helboars Fly (https://www.wowhead.com/wotlk/quest=9346)
        [9382] = true, --* The Fate of the Clefthoof (https://www.wowhead.com/wotlk/quest=9382)
        [9510] = true, --* Bristlehide Clefthoof Hides (https://www.wowhead.com/wotlk/quest=9510)
        [10053] = true, --* Dealing with Zeth'Gor (https://www.wowhead.com/wotlk/quest=10053)
        [10054] = true, --* Impending Doom (https://www.wowhead.com/wotlk/quest=10054)
        [10056] = true, --* Bleeding Hollow Supplies (https://www.wowhead.com/wotlk/quest=10056)
        [10059] = true, --* Dealing With Zeth'Gor (https://www.wowhead.com/wotlk/quest=10059)
        [10060] = true, --* Impending Doom (https://www.wowhead.com/wotlk/quest=10060)
        [10062] = true, --* Looking to the Leadership (https://www.wowhead.com/wotlk/quest=10062)
        [10084] = true, --* Assault on Mageddon (https://www.wowhead.com/wotlk/quest=10084)
        [10088] = true, --* When This Mine's a-Rockin' (https://www.wowhead.com/wotlk/quest=10088)
        [10089] = true, --* Forge Camps of the Legion (https://www.wowhead.com/wotlk/quest=10089)
        [10090] = true, --* The Legion's Plans (https://www.wowhead.com/wotlk/quest=10090)
        [10092] = true, --* Assault on Mageddon (https://www.wowhead.com/wotlk/quest=10092)
        [10100] = true, --* The Mastermind (https://www.wowhead.com/wotlk/quest=10100)
        [10126] = true, --* Warboss Nekrogg's Orders (https://www.wowhead.com/wotlk/quest=10126)
        [10128] = true, --* Saving Private Imarion (https://www.wowhead.com/wotlk/quest=10128)
        [10131] = true, --* Planning the Escape (https://www.wowhead.com/wotlk/quest=10131)
        [10133] = true, --* Mission: Kill the Messenger (https://www.wowhead.com/wotlk/quest=10133)
        [10135] = true, --* Mission: Be the Messenger (https://www.wowhead.com/wotlk/quest=10135)
        [10137] = true, --* Provoking the Warboss (https://www.wowhead.com/wotlk/quest=10137)
        [10138] = true, --* Under Whose Orders? (https://www.wowhead.com/wotlk/quest=10138)
        [10139] = true, --* Dispatching the Commander (https://www.wowhead.com/wotlk/quest=10139)
        [10147] = true, --* Mission: Kill the Messenger (https://www.wowhead.com/wotlk/quest=10147)
        [10148] = true, --* Mission: Be the Messenger (https://www.wowhead.com/wotlk/quest=10148)
        [10149] = true, --* Mission: End All, Be All (https://www.wowhead.com/wotlk/quest=10149)
        [10151] = true, --* Warboss Nekrogg's Orders (https://www.wowhead.com/wotlk/quest=10151)
        [10153] = true, --* Saving Scout Makha (https://www.wowhead.com/wotlk/quest=10153)
        [10154] = true, --* Planning the Escape (https://www.wowhead.com/wotlk/quest=10154)
        [10155] = true, --* Provoking the Warboss (https://www.wowhead.com/wotlk/quest=10155)
        [10156] = true, --* Under Whose Orders? (https://www.wowhead.com/wotlk/quest=10156)
        [10157] = true, --* Dispatching the Commander (https://www.wowhead.com/wotlk/quest=10157)
        [10158] = true, --* Bleeding Hollow Supplies (https://www.wowhead.com/wotlk/quest=10158)
        [10398] = true, --* Return to Honor Hold (https://www.wowhead.com/wotlk/quest=10398)
        [10401] = true, --* Mission: End All, Be All (https://www.wowhead.com/wotlk/quest=10401)

        -- Outland -> Terokkar Forest (8 -> 3519)
        [9929] = true, --* The Missing Merchant (https://www.wowhead.com/wotlk/quest=9929)
        [9930] = true, --* The Missing Merchant (https://www.wowhead.com/wotlk/quest=9930)
        [9941] = true, --* Tracking Down the Culprits (https://www.wowhead.com/wotlk/quest=9941)
        [9942] = true, --* Tracking Down the Culprits (https://www.wowhead.com/wotlk/quest=9942)
        [9943] = true, --* Return to Thander (https://www.wowhead.com/wotlk/quest=9943)
        [9947] = true, --* Return to Rokag (https://www.wowhead.com/wotlk/quest=9947)
        [9949] = true, --* A Bird's-Eye View (https://www.wowhead.com/wotlk/quest=9949)
        [9950] = true, --* A Bird's-Eye View (https://www.wowhead.com/wotlk/quest=9950)
        [9952] = true, --* Prospector Balmoral (https://www.wowhead.com/wotlk/quest=9952)
        [9953] = true, --* Lookout Nodak (https://www.wowhead.com/wotlk/quest=9953)
        [9958] = true, --* Scouting the Defenses (https://www.wowhead.com/wotlk/quest=9958)
        [9959] = true, --* Scouting the Defenses (https://www.wowhead.com/wotlk/quest=9959)
        [9963] = true, --* Seeking Help from the Source (https://www.wowhead.com/wotlk/quest=9963)
        [9964] = true, --* Seeking Help from the Source (https://www.wowhead.com/wotlk/quest=9964)
        [9965] = true, --* A Show of Good Faith (https://www.wowhead.com/wotlk/quest=9965)
        [9966] = true, --* A Show of Good Faith (https://www.wowhead.com/wotlk/quest=9966)
        [9969] = true, --* The Final Reagents (https://www.wowhead.com/wotlk/quest=9969)
        [9974] = true, --* The Final Reagents (https://www.wowhead.com/wotlk/quest=9974)
        [9975] = true, --* Primal Magic (https://www.wowhead.com/wotlk/quest=9975)
        [9976] = true, --* Primal Magic (https://www.wowhead.com/wotlk/quest=9976)
        [9980] = true, --* Rescue Deirom! (https://www.wowhead.com/wotlk/quest=9980)
        [9981] = true, --* Rescue Dugar! (https://www.wowhead.com/wotlk/quest=9981)
        [10048] = true, --* A Handful of Magic Dust (https://www.wowhead.com/wotlk/quest=10048)
        [10049] = true, --* A Handful of Magic Dust (https://www.wowhead.com/wotlk/quest=10049)
        [10195] = true, --* Mercenary See, Mercenary Do (https://www.wowhead.com/wotlk/quest=10195)
        [10841] = true, --* The Vengeful Harbinger (https://www.wowhead.com/wotlk/quest=10841)
        [10925] = true, --* Evil Draws Near (https://www.wowhead.com/wotlk/quest=10925)

        -- Outland -> Nagrand (8 -> 3518)
        [9926] = true, --* FLAG Shadow Council/Warmaul Questline (https://www.wowhead.com/wotlk/quest=9926)

        -- Uncategorized ->  (-2 -> 0)
        [10219] = true, --* Walk the Dog (https://www.wowhead.com/wotlk/quest=10219) (Retail Data)
        [12494] = true, --* FLAG: Riding Trainer Advertisement (20) (https://www.wowhead.com/wotlk/quest=12494) (Retail Data)
        [13990] = true, --* Upper Deck Promo - Chicken Mount (https://www.wowhead.com/wotlk/quest=13990) (Retail Data)
        [14185] = true, --* FLAG: Riding Trainer Advertisement (40) (https://www.wowhead.com/wotlk/quest=14185) (Retail Data)
        [14186] = true, --* FLAG: Riding Trainer Advertisement (60) (https://www.wowhead.com/wotlk/quest=14186) (Retail Data)
        [14187] = true, --* FLAG: Riding Trainer Advertisement (70) (https://www.wowhead.com/wotlk/quest=14187) (Retail Data)
        [24508] = true, --* Temp Quest Record (https://www.wowhead.com/wotlk/quest=24508) (Retail Data)
        [24509] = true, --* Temp Quest Record (https://www.wowhead.com/wotlk/quest=24509) (Retail Data)

        -- Raids -> Magtheridons Lair (3 -> 3836)
        [11116] = true, --* Trial of the Naaru: (QUEST FLAG) (https://www.wowhead.com/wotlk/quest=11116)

        -- Eastern Kingdoms -> Isle Of Queldanas (0 -> 4080)
        [11517] = true, --* Report to Nasuun (https://www.wowhead.com/wotlk/quest=11517) (Retail Data)
        [11534] = true, --* Report to Nasuun (https://www.wowhead.com/wotlk/quest=11534) (Retail Data)
        [11552] = true, --* Rohendor, the Second Gate (https://www.wowhead.com/wotlk/quest=11552) (Retail Data)
        [11553] = true, --* Archonisus, the Final Gate (https://www.wowhead.com/wotlk/quest=11553) (Retail Data)
--      [24522] = true, --* Journey To The Sunwell (https://www.wowhead.com/wotlk/quest=24522) (Retail Data)
--      [24535] = true, --* Thalorien Dawnseeker (https://www.wowhead.com/wotlk/quest=24535) (Retail Data)
--      [24562] = true, --* Journey To The Sunwell (https://www.wowhead.com/wotlk/quest=24562) (Retail Data)
--      [24563] = true, --* Thalorien Dawnseeker (https://www.wowhead.com/wotlk/quest=24563) (Retail Data)

        -- Eastern Kingdoms -> Eastern Plaguelands (0 -> 139)
        [9378] = true, --* DND FLAG The Dread Citadel - Naxxramas (https://www.wowhead.com/wotlk/quest=9378) (Retail Data)

        -- Eastern Kingdoms -> Stormwind City (0 -> 1519)
        --[24428] = true, --* A Most Puzzling Circumstance (https://www.wowhead.com/wotlk/quest=24428) (Retail Data)

        -- World Events -> Childrens Week (9 -> -1002)
        [13929] = true, --* The Biggest Tree Ever! (https://www.wowhead.com/wotlk/quest=13929) (Retail Data)
        [13930] = true, --* Home Of The Bear-Men (https://www.wowhead.com/wotlk/quest=13930) (Retail Data)
        [13933] = true, --* The Bronze Dragonshrine (https://www.wowhead.com/wotlk/quest=13933) (Retail Data)
        [13934] = true, --* The Bronze Dragonshrine (https://www.wowhead.com/wotlk/quest=13934) (Retail Data)
        [13937] = true, --* A Trip To The Wonderworks (https://www.wowhead.com/wotlk/quest=13937) (Retail Data)
        [13938] = true, --* A Visit To The Wonderworks (https://www.wowhead.com/wotlk/quest=13938) (Retail Data)
        [13950] = true, --* Playmates! (https://www.wowhead.com/wotlk/quest=13950) (Retail Data)
        [13951] = true, --* Playmates! (https://www.wowhead.com/wotlk/quest=13951) (Retail Data)
        [13954] = true, --* The Dragon Queen (https://www.wowhead.com/wotlk/quest=13954) (Retail Data)
        [13955] = true, --* The Dragon Queen (https://www.wowhead.com/wotlk/quest=13955) (Retail Data)
        [13956] = true, --* Meeting a Great One (https://www.wowhead.com/wotlk/quest=13956) (Retail Data)
        [13957] = true, --* The Mighty Hemet Nesingwary (https://www.wowhead.com/wotlk/quest=13957) (Retail Data)
        [13959] = true, --* Back To The Orphanage (https://www.wowhead.com/wotlk/quest=13959) (Retail Data)
        [13960] = true, --* Back To The Orphanage (https://www.wowhead.com/wotlk/quest=13960) (Retail Data)
        [14441] = true, --* Garrosh's Autograph (https://www.wowhead.com/wotlk/quest=14441) (Retail Data)

        -- World Events -> Brewfest (9 -> -370)
        [11486] = true, --* The Best of Brews (https://www.wowhead.com/wotlk/quest=11486) (Retail Data)
        [11487] = true, --* The Best of Brews (https://www.wowhead.com/wotlk/quest=11487) (Retail Data)
        [12491] = true, --* Direbrew's Dire Brew (https://www.wowhead.com/wotlk/quest=12491) (Retail Data)
        [12492] = true, --* Direbrew's Dire Brew (https://www.wowhead.com/wotlk/quest=12492) (Retail Data)

        -- World Events -> Love Is In The Air (9 -> -1004)
        [24576] = true, --* A Friendly Chat... (https://www.wowhead.com/wotlk/quest=24576) (Retail Data)
        [24657] = true, --* A Friendly Chat... (https://www.wowhead.com/wotlk/quest=24657) (Retail Data)
        [24792] = true, --* Man on the Inside (https://www.wowhead.com/wotlk/quest=24792) (Retail Data)
        [24793] = true, --* Man on the Inside (https://www.wowhead.com/wotlk/quest=24793) (Retail Data)
        [24848] = true, --* Fireworks At The Gilded Rose (https://www.wowhead.com/wotlk/quest=24848) (Retail Data)
        [24849] = true, --* Hot On The Trail (https://www.wowhead.com/wotlk/quest=24849) (Retail Data)
        [24850] = true, --* Snivel's Sweetheart (https://www.wowhead.com/wotlk/quest=24850) (Retail Data)
        [24851] = true, --* Hot On The Trail (https://www.wowhead.com/wotlk/quest=24851) (Retail Data)


        --! 3.3.2
        -- Raids -> Icecrown Citadel (3 -> 4812)
        --[24869] = true, --* Deprogramming (https://www.wowhead.com/wotlk/quest=24869)
        --[24870] = true, --* Securing the Ramparts (https://www.wowhead.com/wotlk/quest=24870)
        --[24871] = true, --* Securing the Ramparts (https://www.wowhead.com/wotlk/quest=24871)
        --[24873] = true, --* Residue Rendezvous (https://www.wowhead.com/wotlk/quest=24873)
        --[24874] = true, --* Blood Quickening (https://www.wowhead.com/wotlk/quest=24874)
        --[24875] = true, --* Deprogramming (https://www.wowhead.com/wotlk/quest=24875)
        --[24876] = true, --* Securing the Ramparts (https://www.wowhead.com/wotlk/quest=24876)
        --[24877] = true, --* Securing the Ramparts (https://www.wowhead.com/wotlk/quest=24877)
        --[24878] = true, --* Residue Rendezvous (https://www.wowhead.com/wotlk/quest=24878)
        --[24879] = true, --* Blood Quickening (https://www.wowhead.com/wotlk/quest=24879)

        -- World Events -> Love Is In The Air (9 -> -1004)
        [24541] = true, --* Pilfering Perfume (https://www.wowhead.com/wotlk/quest=24541) (Retail Data)
        [24656] = true, --* Pilfering Perfume (https://www.wowhead.com/wotlk/quest=24656) (Retail Data)

        -- Northrend -> Tournament (10 -> -241)
        --[14112] = true, --* What Do You Feed a Yeti, Anyway? (https://www.wowhead.com/wotlk/quest=14112) (Retail Data)

        -- Raids -> Icecrown Citadel (3 -> 4812)
        --[24872] = true, --* Respite for a Tormented Soul (https://www.wowhead.com/wotlk/quest=24872)
        --[24880] = true, --* Respite for a Tormented Soul (https://www.wowhead.com/wotlk/quest=24880)

        --  ->  (0 -> 0)
        [25293] = true, --* The Missing (https://www.wowhead.com/wotlk/quest=25293) (Retail Data)

        -- Northrend -> Tournament (10 -> -241)
        [13627] = true, --* Jack Me Some Lumber (https://www.wowhead.com/wotlk/quest=13627) (Retail Data)
        [13681] = true, --* A Chip Off the Ulduar Block (https://www.wowhead.com/wotlk/quest=13681) (Retail Data)
--         [13682] = true, --* Threat From Above (https://www.wowhead.com/wotlk/quest=13682) (Retail Data)
--         [13785] = true, --* The Edge Of Winter (https://www.wowhead.com/wotlk/quest=13785) (Retail Data)
--         [13789] = true, --* Taking Battle To The Enemy (https://www.wowhead.com/wotlk/quest=13789) (Retail Data)
--         [13790] = true, --* Among the Champions (https://www.wowhead.com/wotlk/quest=13790) (Retail Data)
--         [13809] = true, --* Threat From Above (https://www.wowhead.com/wotlk/quest=13809) (Retail Data)
--         [13810] = true, --* Taking Battle To The Enemy (https://www.wowhead.com/wotlk/quest=13810) (Retail Data)
--         [13811] = true, --* Among the Champions (https://www.wowhead.com/wotlk/quest=13811) (Retail Data)
--         [13861] = true, --* Battle Before The Citadel (https://www.wowhead.com/wotlk/quest=13861) (Retail Data)
--         [13862] = true, --* Battle Before The Citadel (https://www.wowhead.com/wotlk/quest=13862) (Retail Data)
--         [14108] = true, --* Get Kraken! (https://www.wowhead.com/wotlk/quest=14108) (Retail Data)

        -- World Events -> Love Is In The Air (9 -> -1004)
        [24638] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24638) (Retail Data)
        [24645] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24645) (Retail Data)
        [24647] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24647) (Retail Data)
        [24648] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24648) (Retail Data)
        [24649] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24649) (Retail Data)
        [24650] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24650) (Retail Data)
        [24651] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24651) (Retail Data)
        [24652] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24652) (Retail Data)
        [24658] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24658) (Retail Data)
        [24659] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24659) (Retail Data)
        [24660] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24660) (Retail Data)
        [24662] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24662) (Retail Data)
        [24663] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24663) (Retail Data)
        [24664] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24664) (Retail Data)
        [24665] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24665) (Retail Data)
        [24666] = true, --* Crushing the Crown (https://www.wowhead.com/wotlk/quest=24666) (Retail Data)

        -- Midsummer Festival
        [13440] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13440) (Retail Data)
        [13441] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13441) (Retail Data)
        [13442] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13442) (Retail Data)
        [13443] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13443) (Retail Data)
        [13444] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13444) (Retail Data)
        [13445] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13445) (Retail Data)
        [13446] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13446) (Retail Data)
        [13447] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13447) (Retail Data)
        [13449] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13449) (Retail Data)
        [13450] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13445) (Retail Data)
        [13451] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13451) (Retail Data)
        [13453] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13453) (Retail Data)
        [13454] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13454) (Retail Data)
        [13455] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13455) (Retail Data)
        [13457] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13457) (Retail Data)
        [13458] = true, --* Desecrate this Fire! (https://www.wowhead.com/wotlk/quest=13458) (Retail Data)
        [13485] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13485) (Retail Data)
        [13486] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13486) (Retail Data)
        [13487] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13487) (Retail Data)
        [13488] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13488) (Retail Data)
        [13489] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13489) (Retail Data)
        [13490] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13490) (Retail Data)
        [13491] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13491) (Retail Data)
        [13492] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13492) (Retail Data)
        [13493] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13493) (Retail Data)
        [13494] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13494) (Retail Data)
        [13495] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13495) (Retail Data)
        [13496] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13496) (Retail Data)
        [13497] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13497) (Retail Data)
        [13498] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13498) (Retail Data)
        [13499] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13499) (Retail Data)
        [13500] = true, --* Honor the Flame (https://www.wowhead.com/wotlk/quest=13500) (Retail Data)


        --! 3.4.0
        -- Northrend -> Grizzly Hills (10 -> 394)
        --[12432] = true, --* Riding the Red Rocket (https://www.wowhead.com/wotlk/quest=12432)
        --[12437] = true, --* Riding the Red Rocket (https://www.wowhead.com/wotlk/quest=12437)

        -- Dungeons -> The Slave Pens (2 -> 3717)
        --[13431] = true, --* The Cudgel of Kar'desh (https://www.wowhead.com/wotlk/quest=13431) -- it is still available in wotlk P3

        -- Darnassus WOTLK
        [10520] = QuestieCorrections.WOTLK_ONLY, --*Assisting Arch Druid Staghelm (https://www.wowhead.com/wotlk/quest=10520) not present anymore in wotlk

        --! 8.0.1
        -- Raids -> Sunwell Plateau (3 -> 4075)
        --[24594] = true, --* The Purification of Quel'Delar (https://www.wowhead.com/wotlk/quest=24594) (Retail Data)

        -- 3.4.3
        -- ICC
        [13240] = true, --* Timear Foresees Centrifuge Constructs in your Future! (https://www.wowhead.com/wotlk/quest=13240) (Retail Data)
        [13241] = true, --* Timear Foresees Ymirjar Berserkers in your Future! (https://www.wowhead.com/wotlk/quest=13241) (Retail Data)
        [13243] = true, --* Timear Foresees Infinite Agents in your Future! (https://www.wowhead.com/wotlk/quest=13243) (Retail Data)
        [13244] = true, --* Timear Foresees Titanium Vanguards in your Future! (https://www.wowhead.com/wotlk/quest=13244) (Retail Data)
        [13245] = true, --* Proof of Demise: Ingvar the Plunderer (https://www.wowhead.com/wotlk/quest=13245) (Retail Data)
        [13246] = true, --* Proof of Demise: Keristrasza (https://www.wowhead.com/wotlk/quest=13246) (Retail Data)
        [13247] = true, --* Proof of Demise: Ley-Guardian Eregos (https://www.wowhead.com/wotlk/quest=13247) (Retail Data)
        [13248] = true, --* Proof of Demise: King Ymiron (https://www.wowhead.com/wotlk/quest=13248) (Retail Data)
        [13249] = true, --* Proof of Demise: The Prophet Tharon'ja (https://www.wowhead.com/wotlk/quest=13249) (Retail Data)
        [13250] = true, --* Proof of Demise: Gal'darah (https://www.wowhead.com/wotlk/quest=13250) (Retail Data)
        [13251] = true, --* Proof of Demise: Mal'Ganis (https://www.wowhead.com/wotlk/quest=13251) (Retail Data)
        [13252] = true, --* Proof of Demise: Sjonnir The Ironshaper (https://www.wowhead.com/wotlk/quest=13252) (Retail Data)
        [13253] = true, --* Proof of Demise: Loken (https://www.wowhead.com/wotlk/quest=13253) (Retail Data)
        [13254] = true, --* Proof of Demise: Anub'arak (https://www.wowhead.com/wotlk/quest=13254) (Retail Data)
        [13255] = true, --* Proof of Demise: Herald Volazj (https://www.wowhead.com/wotlk/quest=13255) (Retail Data)
        [13256] = true, --* Proof of Demise: Cyanigosa (https://www.wowhead.com/wotlk/quest=13256) (Retail Data)
        [14199] = true, --* Proof of Demise: The Black Knight (https://www.wowhead.com/wotlk/quest=14199) (Retail Data)

    }
end

