---@class QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:CreateModule("QuestieQuestBlacklist")
---@type ContentPhases
local ContentPhases = QuestieLoader:ImportModule("ContentPhases")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

---@return table<QuestId, boolean>
function QuestieQuestBlacklist:Load()
    local questsToBlacklist = {
        [7462] = true, -- Duplicate of 7877. See #1583
        [5663] = true, -- Touch of Weakness of Dark Cleric Beryl - Fixing #730
        [5658] = true, -- Touch of Weakness of Father Lankester -- See #1603
        [2358] = true, -- See #921
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
        [7704] = Expansions.Current ~= Expansions.Wotlk, -- Only implemented in Wrath
        [7668] = true, -- Not in the game (yet) Replaced with 8258 in Ph 4-- #1805
        [636] = true, -- Not in the game - #1900
        [6066] = true, -- Not in the game - #1957
        [4601] = true, -- Duplicate of 2951
        [4602] = true, -- Duplicate of 2951
        [4603] = true, -- Duplicate of 2953
        [4604] = true, -- Duplicate of 2953
        [4605] = true, -- Duplicate of 2952
        [4606] = true, -- Duplicate of 2952
        [8856] = true, -- Duplicate of 8497
        [13053] = true, -- Removed
        [11402] = true, -- GM Island quest
        [11189] = true, -- Removed
        [13417] = true, -- Duplicate of 12973
        [936] = Expansions.Current == Expansions.Era or Expansions.Current >= Expansions.Cata,
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
        --[4295] = true,
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
        [11321] = true,
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
        [11976] = true,
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
        [12405] = true, -- not in the game
        [12406] = true,
        [12407] = true,
        [12408] = true,
        [12409] = true,
        [12410] = true, -- not in the game
        [12420] = true,
        [12421] = true,
        [13158] = Expansions.Current >= Expansions.Cata, -- replaced in Cata with 29829
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
        [6861] = Expansions.Current == Expansions.Era,
        [6862] = Expansions.Current == Expansions.Era,
        [6864] = Expansions.Current == Expansions.Era,
        [6901] = Expansions.Current == Expansions.Era,
        [7221] = true,
        [7222] = true,
        [7281] = Expansions.Current == Expansions.Era,
        [7282] = Expansions.Current == Expansions.Era,
        [7301] = Expansions.Current == Expansions.Era,
        [7302] = Expansions.Current == Expansions.Era,
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
        [7905] = Expansions.Current < Expansions.Cata,
        [7926] = Expansions.Current < Expansions.Cata,

        [8743] = true, -- Bang a Gong! (AQ40 opening quest)

        -- Classic Phase 6 Invasion quests
        -- Investigate the Scourge of X
        [9260] = (not Questie.IsSoD),
        [9261] = (not Questie.IsSoD),
        [9262] = (not Questie.IsSoD),
        [9263] = (not Questie.IsSoD),
        [9264] = (not Questie.IsSoD),
        [9265] = (not Questie.IsSoD),
        --
        [9085] = true,
        [9153] = true,
        [9154] = (not Questie.IsSoD),
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
        [6843] = true, -- Da Foo
        [7681] = true, -- Hunter test quest
        [7682] = true, -- Hunter test quest2
        [7797] = true, -- Dimensional Ripper - Everlook
        [7961] = true, -- Waskily Wabbits!
        [8021] = true, -- Redeem iCoke Prize Voucher
        [8022] = true, -- Redeem iCoke Prize Voucher
        [8023] = true, -- Redeem iCoke Prize Voucher
        [8024] = true, -- Redeem iCoke Prize Voucher
        [8025] = true, -- Redeem iCoke Prize Voucher
        [8026] = true, -- Redeem iCoke Prize Voucher
        [8230] = true, -- Collin's Test Quest
        [8478] = true, -- Choose Your Weapon
        [8489] = true, -- An Intact Converter
        [8896] = true, -- The Dwarven Spy
        [9168] = true, -- Heart of Deatholme
        [9284] = true, -- Aldor Faction Test
        [9285] = true, -- Consortium Faction Test
        [9286] = true, -- Scryers Faction Test
        [9342] = true, -- Marauding Crust Bursters
        [9344] = true, -- A Hasty Departure
        [9346] = true, -- When Helboars Fly
        [9357] = true, -- Report to Aeldon Sunbrand
        [9382] = true, -- The Fate of the Clefthoof
        [9408] = true, -- Forgotten Heroes
        [9511] = true, -- Kargath's Battle Plans
        [9556] = true, -- To The Victor...
        [9568] = true, -- On the Offensive
        [9713] = true, -- Glowcap Harvesting Enabling Flag
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
        [10219] = true, -- Walk the Dog
        [10244] = true, -- R.T.F.R.C.M.
        [10260] = true, -- Netherologist Coppernickels
        [10292] = true, -- More Power!
        [10370] = true, -- Nazgrel's Command <TXT>
        [10375] = true, -- Obsidian Warbeads
        [10383] = true, -- This is a Breadcrumb!
        [10386] = true, -- The Fel Reaver Slayer
        [10387] = true, -- The Fel Reaver Slayer
        [10398] = true, -- Return to Honor Hold
        [10401] = true, -- Mission: End All, Be All
        [10404] = true, -- Against the Legion
        [10441] = true, -- Peddling the Goods
        [10454] = true, -- FLAG - OFF THE RAILS
        [10610] = true, -- Prospecting Basics
        [10716] = true, -- Test Flight: Raven's Wood <needs reward>
        [10815] = true, -- The Journal of Val'zareq: Portends of War
        [10841] = true, -- The Vengeful Harbringer
        [10844] = true, -- Forge Camp: Anger
        [10871] = true, -- Ally of the Netherwing
        [10872] = true, -- Zuluhed the Whacked
        [10925] = true, -- Evil Draws Near
        [11518] = true, -- Sunwell Daily Portal Flag
        [11577] = true, -- WoW Collector's Edition: - DEM - E - FLAG
        [11874] = true, -- Upper Deck Promo - Rocket Mount

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
        [2881] = Expansions.Current >= Expansions.Tbc, -- Wildhammer faction removed in TBC. Repeatable to gain rep
        [8329] = Expansions.Current < Expansions.Cata, --* Warrior Training (https://www.wowhead.com/wotlk/quest=8329) (Retail Data)
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
        [64845] = Expansions.Current >= Expansions.Tbc, -- Alliance War Effort
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
        [1661] = Expansions.Current >= Expansions.Tbc,
        [3366] = true,
        [3381] = true,
        [5627] = true,
        [5641] = Expansions.Current >= Expansions.Tbc,
        [5645] = Expansions.Current >= Expansions.Tbc,
        [5647] = Expansions.Current >= Expansions.Tbc,
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
        [8411] = Expansions.Current >= Expansions.Cata, -- not sure when this quest was removed, Wowhead says Cata, it is present in Classic SoD
        [9712] = true,
        [10377] = true,
        [11052] = true,

        -- Marks of Honor PvP quests - All of them should only be available in Era
        [8367] = Expansions.Current >= Expansions.Tbc,
        [8368] = Expansions.Current >= Expansions.Tbc,
        [8369] = Expansions.Current >= Expansions.Tbc,
        [8370] = Expansions.Current >= Expansions.Tbc,
        [8371] = Expansions.Current >= Expansions.Tbc,
        [8372] = Expansions.Current >= Expansions.Tbc,
        [8374] = Expansions.Current >= Expansions.Tbc,
        [8375] = Expansions.Current >= Expansions.Tbc,
        [8383] = Expansions.Current >= Expansions.Tbc,
        [8384] = Expansions.Current >= Expansions.Tbc,
        [8385] = Expansions.Current >= Expansions.Tbc,
        [8386] = Expansions.Current >= Expansions.Tbc,
        [8387] = Expansions.Current >= Expansions.Tbc,
        [8388] = Expansions.Current >= Expansions.Tbc,
        [8389] = Expansions.Current >= Expansions.Tbc,
        [8390] = Expansions.Current >= Expansions.Tbc,
        [8391] = Expansions.Current >= Expansions.Tbc,
        [8392] = Expansions.Current >= Expansions.Tbc,
        [8393] = Expansions.Current >= Expansions.Tbc,
        [8394] = Expansions.Current >= Expansions.Tbc,
        [8395] = Expansions.Current >= Expansions.Tbc,
        [8396] = Expansions.Current >= Expansions.Tbc,
        [8397] = Expansions.Current >= Expansions.Tbc,
        [8398] = Expansions.Current >= Expansions.Tbc,
        [8399] = Expansions.Current >= Expansions.Tbc,
        [8400] = Expansions.Current >= Expansions.Tbc,
        [8401] = Expansions.Current >= Expansions.Tbc,
        [8402] = Expansions.Current >= Expansions.Tbc,
        [8403] = Expansions.Current >= Expansions.Tbc,
        [8404] = Expansions.Current >= Expansions.Tbc,
        [8405] = Expansions.Current >= Expansions.Tbc,
        [8406] = Expansions.Current >= Expansions.Tbc,
        [8407] = Expansions.Current >= Expansions.Tbc,
        [8408] = Expansions.Current >= Expansions.Tbc,
        [8426] = Expansions.Current >= Expansions.Tbc,
        [8427] = Expansions.Current >= Expansions.Tbc,
        [8428] = Expansions.Current >= Expansions.Tbc,
        [8429] = Expansions.Current >= Expansions.Tbc,
        [8430] = Expansions.Current >= Expansions.Tbc,
        [8431] = Expansions.Current >= Expansions.Tbc,
        [8432] = Expansions.Current >= Expansions.Tbc,
        [8433] = Expansions.Current >= Expansions.Tbc,
        [8434] = Expansions.Current >= Expansions.Tbc,
        [8435] = Expansions.Current >= Expansions.Tbc,
        [8436] = Expansions.Current >= Expansions.Tbc,
        [8437] = Expansions.Current >= Expansions.Tbc,
        [8438] = Expansions.Current >= Expansions.Tbc,
        [8439] = Expansions.Current >= Expansions.Tbc,
        [8440] = Expansions.Current >= Expansions.Tbc,
        [8441] = Expansions.Current >= Expansions.Tbc,
        [8442] = Expansions.Current >= Expansions.Tbc,
        [8443] = Expansions.Current >= Expansions.Tbc,

        -- Phase 4 Zul'Aman
        --[11196] = true, -- Not in the game

        ----- Wotlk -------------- Wotlk quests --------------- Wotlk -----
        ----- Wotlk ------------- starting here -------------- Wotlk -----

        [10985] = Expansions.Current >= Expansions.Wotlk, -- Got replaced by 13429
        [10888] = Expansions.Current >= Expansions.Wotlk, -- Got replaced by 13430
        [10901] = Expansions.Current >= Expansions.Wotlk, -- Got replaced by 13431
        [10445] = Expansions.Current >= Expansions.Wotlk, -- Got replaced by 13432
        [6144] = Expansions.Current >= Expansions.Wotlk, -- Got replaced by 14349
        [6821] = Expansions.Current >= Expansions.Wotlk, -- Not in the game
        [6822] = Expansions.Current >= Expansions.Wotlk, -- Not in the game
        [6823] = Expansions.Current >= Expansions.Wotlk, -- Not in the game
        [6824] = Expansions.Current >= Expansions.Wotlk, -- Not in the game
        [7486] = Expansions.Current >= Expansions.Wotlk, -- Not in the game
        [5634] = Expansions.Current >= Expansions.Wotlk, -- removed since wotlk
        [5635] = Expansions.Current >= Expansions.Wotlk, -- removed since wotlk
        [5636] = Expansions.Current >= Expansions.Wotlk, -- removed since wotlk
        [5637] = Expansions.Current >= Expansions.Wotlk, -- removed since wotlk
        [5638] = Expansions.Current >= Expansions.Wotlk, -- removed since wotlk
        [5639] = Expansions.Current >= Expansions.Wotlk, -- removed since wotlk
        [5640] = Expansions.Current >= Expansions.Wotlk, -- removed since wotlk
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
        [14106] = true, -- Not in the game
        [14160] = true, -- Not in the game
        [13374] = true, -- Not in the game
        [13381] = true, -- Not in the game
        [13908] = true, -- Not in the game
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
        [14032] = true, -- Not in the game
        [13825] = true, -- EXISTS ingame, but can only be picked up if quest 6610 was completed PRIOR to wrath - impossible for us to discern eligibility, better to hide than misinform everyone
        [13826] = true, -- EXISTS ingame, but can only be picked up if quest 6607 was completed PRIOR to wrath - impossible for us to discern eligibility, better to hide than misinform everyone
        --[13843] = true, -- Questie NYI - only available if recipe 55252 is not known but quest 12889 is completed, we can't yet determine recipe knowledge - fixed
        [25306] = true, -- Not in the game

        [13475] = Expansions.Current >= Expansions.Wotlk, -- pvp marks removed in wotlk
        [13476] = Expansions.Current >= Expansions.Wotlk, -- pvp marks removed in wotlk
        [13477] = Expansions.Current >= Expansions.Wotlk, -- pvp marks removed in wotlk
        [13478] = Expansions.Current >= Expansions.Wotlk, -- pvp marks removed in wotlk

        [6804] = Expansions.Current >= Expansions.Wotlk,
        [7737] = Expansions.Current == Expansions.Wotlk, -- replaced by 13662 in wotlk
        [9094] = Expansions.Current >= Expansions.Wotlk,
        [9317] = Expansions.Current >= Expansions.Wotlk,
        [9318] = Expansions.Current >= Expansions.Wotlk,
        [9320] = Expansions.Current >= Expansions.Wotlk,
        [9321] = Expansions.Current >= Expansions.Wotlk,
        [9333] = Expansions.Current >= Expansions.Wotlk,
        [9334] = Expansions.Current >= Expansions.Wotlk,
        [9335] = Expansions.Current >= Expansions.Wotlk,
        [9336] = Expansions.Current >= Expansions.Wotlk,
        [9337] = Expansions.Current >= Expansions.Wotlk,
        [9341] = Expansions.Current >= Expansions.Wotlk,
        [9343] = Expansions.Current >= Expansions.Wotlk,

        -- Old Naxx quests (Naxx40 goes away in wotlk)
        [9120] = Expansions.Current >= Expansions.Wotlk, -- The Fall of Kel'Thuzad
        [9229] = Expansions.Current >= Expansions.Wotlk, -- The Fate of Ramaladni
        [9230] = Expansions.Current >= Expansions.Wotlk, -- Ramaladni's Icy Grasp
        [9232] = Expansions.Current >= Expansions.Wotlk, -- The Only Song I Know...
        [9233] = Expansions.Current >= Expansions.Wotlk, -- Omarion's Handbook
        [9234] = Expansions.Current >= Expansions.Wotlk, -- Icebane Gauntlets
        [9235] = Expansions.Current >= Expansions.Wotlk, -- Icebane Bracers
        [9236] = Expansions.Current >= Expansions.Wotlk, -- Icebane Breastplate
        [9237] = Expansions.Current >= Expansions.Wotlk, -- Glacial Cloak
        [9238] = Expansions.Current >= Expansions.Wotlk, -- Glacial Wrists
        [9239] = Expansions.Current >= Expansions.Wotlk, -- Glacial Gloves
        [9240] = Expansions.Current >= Expansions.Wotlk, -- Glacial Vest
        [9241] = Expansions.Current >= Expansions.Wotlk, -- Polar Bracers
        [9242] = Expansions.Current >= Expansions.Wotlk, -- Polar Gloves
        [9243] = Expansions.Current >= Expansions.Wotlk, -- Polar Tunic
        [9244] = Expansions.Current >= Expansions.Wotlk, -- Icy Scale Bracers
        [9245] = Expansions.Current >= Expansions.Wotlk, -- Icy Scale Gauntlets
        [9246] = Expansions.Current >= Expansions.Wotlk, -- Icy Scale Breastplate

        -- Vanilla Onyxia Alliance attunement
        [4182] = Expansions.Current >= Expansions.Wotlk,
        [4183] = Expansions.Current >= Expansions.Wotlk,
        [4184] = Expansions.Current >= Expansions.Wotlk,
        [4185] = Expansions.Current >= Expansions.Wotlk,
        [4186] = Expansions.Current >= Expansions.Wotlk,
        [4223] = Expansions.Current >= Expansions.Wotlk,
        [4224] = Expansions.Current >= Expansions.Wotlk,
        [4241] = Expansions.Current >= Expansions.Wotlk,
        [4242] = Expansions.Current >= Expansions.Wotlk,
        [4264] = Expansions.Current >= Expansions.Wotlk,
        [4282] = Expansions.Current >= Expansions.Wotlk,
        [4322] = Expansions.Current >= Expansions.Wotlk,
        [6402] = Expansions.Current >= Expansions.Wotlk,
        [6403] = Expansions.Current >= Expansions.Wotlk,
        [6501] = Expansions.Current >= Expansions.Wotlk,
        [6502] = Expansions.Current >= Expansions.Wotlk,

        -- Vanilla Onyxia Horde pre attunement
        [4903] = Expansions.Current >= Expansions.Wotlk,
        [4941] = Expansions.Current >= Expansions.Wotlk,
        [4974] = Expansions.Current >= Expansions.Wotlk,
        [6566] = Expansions.Current >= Expansions.Wotlk,
        [6567] = Expansions.Current >= Expansions.Wotlk,
        [6568] = Expansions.Current >= Expansions.Wotlk,
        [6569] = Expansions.Current >= Expansions.Wotlk,
        [6570] = Expansions.Current >= Expansions.Wotlk,
        [6582] = Expansions.Current >= Expansions.Wotlk,
        [6583] = Expansions.Current >= Expansions.Wotlk,
        [6584] = Expansions.Current >= Expansions.Wotlk,
        [6585] = Expansions.Current >= Expansions.Wotlk,
        [6601] = Expansions.Current >= Expansions.Wotlk,
        [6602] = Expansions.Current >= Expansions.Wotlk,

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

        --- new raid weekly quests
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

        --- Chinese servers wotlk only
        [78752] = Expansions.Current >= Expansions.Cata, -- Proof of Demise: Titan Rune Protocol Gamma
        [78753] = Expansions.Current >= Expansions.Cata, -- Proof of Demise: Threats to Azeroth
        [83713] = Expansions.Current >= Expansions.Wotlk, -- Proof of Demise: Titan Rune Protocol Alpha (new version to reward correct emblems)
        [83714] = Expansions.Current >= Expansions.Wotlk, -- Proof of Demise: Threats to Azeroth (new version to reward correct emblems)
        [83717] = Expansions.Current >= Expansions.Wotlk, -- Proof of Demise: Titan Rune Protocol Gamma (not available anymore)
        [87379] = Expansions.Current >= Expansions.Wotlk, -- Proof of Demise: Threats to Azeroth (not available anymore)

        --- Daily quests
        [24788] = true, -- Daily Heroic Random (1st)
        [24789] = true, -- Daily Heroic Random (Nth)
        [24790] = true, -- Daily Normal Random (1st)
        [24791] = true, -- Daily Normal Random (Nth)
        [24881] = true, -- Classic Random 5-15 (1st)
        [24882] = true, -- Classic Random 15-25 (1st)
        [24883] = true, -- Classic Random 24-34 (1st)
        [24884] = true, -- Classic Random 35-45 (1st)
        [24885] = true, -- Classic Random 46-55 (1st)
        [24886] = true, -- Classic Random 56-60 (1st)
        [24887] = true, -- Classic Random 60-64 (1st)
        [24888] = true, -- Classic Random 65-70 (1st)
        [24889] = true, -- Classic Random 5-15 (Nth)
        [24890] = true, -- Classic Random 15-25 (Nth)
        [24891] = true, -- Classic Random 24-34 (Nth)
        [24892] = true, -- Classic Random 35-45 (Nth)
        [24893] = true, -- Classic Random 46-55 (Nth)
        [24894] = true, -- Classic Random 56-60 (Nth)
        [24895] = true, -- Classic Random 60-64 (Nth)
        [24896] = true, -- Classic Random 65-70 (Nth)
        [24922] = true, -- Classic Random Heroic (1st)
        [24923] = true, -- Burning Crusade Random Heroic (Nth)

        --- Daily world event RDF
        [25482] = true, -- World Event Dungeon - Headless Horseman
        [25483] = true, -- World Event Dungeon - Coren Direbrew
        [25484] = true, -- World Event Dungeon - Ahune
        [25485] = true, -- World Event Dungeon - Hummel

        ----- Cata -------------- Cata quests --------------- Cata -----
        ----- Cata ------------- starting here -------------- Cata -----

        [5] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [12] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [15] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [17] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [18] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [19] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [20] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [21] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [22] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [26] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [27] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [28] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [29] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [30] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [31] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [32] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [33] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [34] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [36] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [38] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [39] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [48] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [49] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [50] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [51] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [53] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [55] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [56] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [57] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [58] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [61] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [63] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [64] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [65] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [66] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [67] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [68] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [69] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [70] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [72] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [73] = true, -- Not in the game
        [74] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [75] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [77] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [78] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [79] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [80] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [81] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [82] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [89] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [90] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [91] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [92] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [93] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [94] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [95] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [96] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [97] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [98] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [99] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [100] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [101] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [102] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [103] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [104] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [105] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [108] = true, -- Not in the game
        [109] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [110] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [113] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [115] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [116] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [117] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [118] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [119] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [120] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [121] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [122] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [124] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [125] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [126] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [127] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [128] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [129] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [130] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [131] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [132] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [133] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [134] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [135] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [136] = Expansions.Current >= Expansions.Cata, -- Replaced by 26353
        [137] = true, -- Not in the game
        [138] = Expansions.Current >= Expansions.Cata, -- Replaced by 26355
        [139] = Expansions.Current >= Expansions.Cata, -- Replaced by 26356
        [140] = Expansions.Current >= Expansions.Cata, -- Replaced by 26354
        [141] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [142] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [143] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [144] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [145] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [146] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [148] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [149] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [150] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [151] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [152] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [153] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [154] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [155] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [156] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [157] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [158] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [159] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [160] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [161] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [162] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [163] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [164] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [165] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [166] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [167] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [168] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [169] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [170] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [173] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [174] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [175] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [177] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [178] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [179] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [180] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [181] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [183] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [189] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [198] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [199] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [200] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [201] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [202] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [203] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [204] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [205] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [206] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [207] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [209] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [210] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [211] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [212] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [213] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [214] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [215] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [217] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [219] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [220] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [221] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [222] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [223] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [224] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [225] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [226] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [227] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [228] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [229] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [230] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [231] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [232] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [233] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [234] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [235] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [237] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [238] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [240] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [241] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [242] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [243] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [244] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [245] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [246] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [247] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [248] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [249] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [250] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [251] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [252] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [253] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [254] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [255] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [256] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [257] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [258] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [259] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [260] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [261] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [262] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [263] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [265] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [266] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [267] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [268] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [269] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [270] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [271] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [272] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [273] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [274] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [275] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [276] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [277] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [278] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [279] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [280] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [281] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [282] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [283] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [284] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [285] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [286] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [287] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [288] = Expansions.Current >= Expansions.Cata, -- Replaced by 25815
        [289] = Expansions.Current >= Expansions.Cata, -- Replaced by 25817
        [290] = Expansions.Current >= Expansions.Cata, -- Replaced by 25818
        [291] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [292] = Expansions.Current >= Expansions.Cata, -- Replaced by 25819
        [293] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [294] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [295] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [296] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [297] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [298] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [299] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [301] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        --[302] = Expansions.Current >= Expansions.Cata, -- this quest is available if you did quest id 301 precata
        [303] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [304] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [305] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [306] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [307] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [308] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [310] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [311] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [312] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [316] = true, -- Not in the game
        [317] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [318] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [319] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [320] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [321] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [322] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [323] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [324] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [325] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [326] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [327] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [328] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [329] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [330] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [331] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [335] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [336] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [337] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [338] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [339] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [340] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [341] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [342] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [343] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [344] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [345] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [346] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [347] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [348] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [349] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [350] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [352] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [354] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [355] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [356] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [357] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [358] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [359] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [360] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [361] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [362] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [363] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [364] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [365] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [366] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [367] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [368] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [369] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [370] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [371] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [372] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [373] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [374] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [375] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [376] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [377] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [378] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [379] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [380] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [381] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [382] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [383] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [385] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [386] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [387] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [388] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [389] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [390] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [391] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [392] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [393] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [394] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [395] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [396] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [397] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [398] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [399] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [400] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [401] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [404] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [403] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [405] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [406] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [407] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [408] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [409] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [410] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [411] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [413] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [414] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [415] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [416] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [417] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [418] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [419] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [420] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [421] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [422] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [423] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [424] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [425] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [426] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [427] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [428] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [429] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [430] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [431] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [434] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [435] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [436] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [437] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [438] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [439] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [440] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [441] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [442] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [443] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [444] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [445] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [446] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [447] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [448] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [449] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [450] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [451] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [452] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [453] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [454] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [455] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [456] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [457] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [458] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [459] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [460] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [461] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [462] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [463] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [464] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [465] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [466] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [467] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [468] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [469] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [470] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [471] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [472] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [473] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [474] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [477] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [478] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [479] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [480] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [481] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [482] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [484] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [490] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [491] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [492] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [493] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [494] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [496] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [497] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [498] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [499] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [500] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [501] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [502] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [503] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [504] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [505] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [506] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [507] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [508] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [509] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [510] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [511] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [512] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [513] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [514] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [515] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [516] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [517] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [518] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [519] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [520] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [521] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [522] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [523] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [524] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [525] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [526] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [527] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [528] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [529] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [530] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [531] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [532] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [533] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [534] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [535] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [536] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [537] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [538] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [539] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [540] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [541] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [542] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [544] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [545] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [546] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [547] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [548] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [549] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [550] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [551] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [552] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [553] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [554] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [555] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [556] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [557] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [559] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [560] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [561] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [562] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [563] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [564] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [565] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [566] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [567] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [568] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [569] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [570] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [571] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [572] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [573] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [574] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [575] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [576] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [577] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [578] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [579] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [580] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [581] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [582] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [584] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [585] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [586] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [587] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [588] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [589] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [590] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [591] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [592] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [593] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [594] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [595] = Expansions.Current >= Expansions.Cata, -- Replaced by 26609
        [596] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [597] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [598] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [599] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [600] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [601] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [602] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [603] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [604] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [605] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [606] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [607] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [608] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [609] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [610] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [611] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [612] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [613] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [616] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [617] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [619] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [621] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [622] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [623] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [624] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [625] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [626] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [627] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [628] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [629] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [630] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [631] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [632] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [633] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [634] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [635] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [637] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [638] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [639] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [640] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [641] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [642] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [643] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [644] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [645] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [646] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [647] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [649] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [650] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [651] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [652] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [653] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [654] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [655] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [656] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [657] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [658] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [659] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [660] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [661] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [662] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [663] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [664] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [665] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [666] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [667] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [668] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [669] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [670] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [671] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [672] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [673] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [674] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [675] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [676] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [677] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [678] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [679] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [680] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [681] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [682] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [683] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [684] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [685] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [686] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [687] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [688] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [689] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [690] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [691] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [692] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [693] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [694] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [695] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [696] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [697] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [698] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [699] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [700] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [701] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [702] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [703] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [704] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [705] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [706] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [707] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [709] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [710] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [711] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [712] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [713] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [714] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [715] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [716] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [717] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [718] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [719] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [720] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [721] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [722] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [723] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [724] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [725] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [726] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [727] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [728] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [729] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [730] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [731] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [732] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [733] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [734] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [735] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [736] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [737] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [738] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [739] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [740] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [741] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [742] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [745] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [746] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [747] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [748] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [750] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [752] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [753] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [754] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [755] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [756] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [757] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [758] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [759] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [760] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [762] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [763] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [764] = Expansions.Current >= Expansions.Cata, -- Replaced by 26179
        [765] = Expansions.Current >= Expansions.Cata, -- Replaced by 26180
        [766] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [767] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [771] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [772] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [774] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [775] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [776] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [777] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [778] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [779] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [780] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [782] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [783] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [784] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [786] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [788] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [789] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [790] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [791] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [792] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [793] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [794] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [795] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [796] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [797] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [798] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [799] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [800] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [801] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [802] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [803] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [804] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [805] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [806] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [807] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [808] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [809] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [810] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [811] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [812] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [813] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [814] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [815] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [816] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [817] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [818] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [819] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [820] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [821] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [822] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [823] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [825] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [826] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [827] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [828] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [829] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [830] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [831] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [832] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [837] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [838] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [839] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [841] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [842] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [843] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [846] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [847] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [849] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [853] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [854] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [856] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [857] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [859] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [860] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [862] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [864] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [868] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [873] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [874] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [878] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [879] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [882] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [883] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [884] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [885] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [886] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [888] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [889] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [890] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [892] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [893] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [894] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [896] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [897] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [898] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [900] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [901] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [902] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [904] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [906] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [907] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [908] = Expansions.Current >= Expansions.Cata, -- Removed with cata (replaced with 26891)
        [912] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [913] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [914] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [916] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [917] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [920] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [921] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [924] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [926] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [928] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [939] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [940] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [942] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [943] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [944] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [945] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [946] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [947] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [948] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [949] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [950] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [951] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [952] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [953] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [954] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [955] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [956] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [957] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [958] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [959] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [960] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [961] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [962] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [963] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [964] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [965] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [966] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [967] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [968] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [969] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [970] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [971] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [972] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [973] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [974] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [975] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [976] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [977] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [978] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [979] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [980] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [981] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [982] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [983] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [984] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [985] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [986] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [987] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [988] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [989] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [990] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [991] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [992] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [993] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [994] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [995] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1000] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1001] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1002] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1003] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1004] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1007] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1008] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1009] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1010] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1011] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1012] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1013] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1014] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1015] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1016] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1017] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1018] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1019] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1020] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1021] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1022] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1023] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1024] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1025] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1026] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1027] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1028] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1029] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1030] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1031] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1032] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1033] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1034] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1035] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1037] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1038] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1039] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1040] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1041] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1042] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1043] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1044] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1045] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1046] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1047] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1049] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1050] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1051] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1052] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1053] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1054] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1055] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1056] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1057] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1058] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1059] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1060] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1061] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1062] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1063] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1064] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1065] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1066] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1067] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1068] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1069] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1070] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1071] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1072] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1073] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1074] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1075] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1076] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1077] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1078] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1079] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1080] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1081] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1082] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1083] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1084] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1085] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1086] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1087] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1088] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1089] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1090] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1091] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1092] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1093] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1094] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1095] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1096] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1098] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1100] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1101] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1102] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1103] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1104] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1105] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1106] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1107] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1108] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1109] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1110] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1111] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1112] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1113] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1114] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1115] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1116] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1117] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1118] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1119] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1120] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1121] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1122] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1123] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1124] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1125] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1126] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1127] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1128] = true, -- Not in the game
        [1129] = true, -- Not in the game
        [1130] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1131] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1132] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1134] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1135] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1136] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1137] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1138] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1139] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1140] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1141] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1142] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1143] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1144] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1145] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1146] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1147] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1148] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1149] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1150] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1151] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1152] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1153] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1154] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1155] = true, -- Not in the game
        [1156] = true, -- Not in the game
        [1157] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1158] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1159] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1160] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1161] = true, -- Not in the game
        [1162] = true, -- Not in the game
        [1163] = true, -- Not in the game
        [1164] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1165] = true, -- Not in the game
        [1166] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1167] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1169] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1170] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1171] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1172] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1173] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1174] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1175] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1176] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1177] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1178] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1179] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1180] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1181] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1182] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1183] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1184] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1185] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1186] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1187] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1188] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1189] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1190] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1191] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1192] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1193] = Expansions.Current >= Expansions.Cata, -- Removed with cata (replaced with 27118)
        [1194] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1195] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1196] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1197] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1198] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1199] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1200] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1203] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1206] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1218] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1219] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1220] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1221] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1238] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1239] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1240] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1241] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1242] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1243] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1244] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1245] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1246] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1247] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1248] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1249] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1250] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1251] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1252] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1253] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1259] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1260] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1261] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1262] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1264] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1265] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1266] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1267] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1268] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1269] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1273] = Expansions.Current >= Expansions.Cata, -- Replaced by 27261
        [1274] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1275] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1276] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1277] = true, -- Not in the game
        [1278] = true, -- Not in the game
        [1279] = true, -- Not in the game
        [1280] = true, -- Not in the game
        [1282] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1283] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1284] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1285] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1286] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1287] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1290] = true, -- Not in the game
        [1291] = true, -- Not in the game
        [1292] = true, -- Not in the game
        [1293] = true, -- Not in the game
        [1294] = true, -- Not in the game
        [1295] = true, -- Not in the game
        [1296] = true, -- Not in the game
        [1297] = true, -- Not in the game
        [1298] = true, -- Not in the game
        [1299] = true, -- Not in the game
        [1300] = true, -- Not in the game
        [1301] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1302] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1319] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1320] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1321] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1322] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1323] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1324] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1338] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1339] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1358] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1359] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1360] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1361] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1362] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1363] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1364] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1365] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1366] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1367] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1368] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1369] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1370] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1371] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1372] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1373] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1374] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1375] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1380] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1381] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1382] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1383] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1384] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1385] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1386] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1387] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1388] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1389] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1391] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1392] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1394] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1395] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1396] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1397] = true, -- Not in the game
        [1398] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1418] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1419] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1420] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1421] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1422] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1423] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1424] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1425] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1426] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1427] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1428] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1429] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1430] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1431] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1435] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1437] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1438] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1439] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1440] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1441] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1442] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1443] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1444] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1445] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1446] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1447] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1448] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1449] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1450] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1451] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1452] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1457] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1458] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1459] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1460] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1461] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1462] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1463] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1464] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1465] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1466] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1467] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1469] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1471] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1472] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1473] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1474] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1475] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1476] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1477] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1478] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1480] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1481] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1482] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1483] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1484] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1485] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1486] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1487] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1488] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1489] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1490] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1491] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1492] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1498] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1499] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1501] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1502] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1503] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1504] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1505] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1506] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1507] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1508] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1509] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1510] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1511] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1512] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1513] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1515] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1516] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1517] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1518] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1519] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1520] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1521] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1522] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1523] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1524] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1525] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1526] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1527] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1528] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1529] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1530] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1531] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1532] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1533] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1534] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1535] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1536] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1537] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1538] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1559] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1560] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1579] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1580] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1638] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1639] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1640] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1641] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1642] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1643] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1644] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1645] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1646] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1647] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1648] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1649] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1650] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1651] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1652] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1653] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1654] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1655] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1656] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1659] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1660] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1662] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1663] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1664] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1665] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1666] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1667] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1678] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1679] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1680] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1681] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1682] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1683] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1684] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1685] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1686] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1688] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1689] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1690] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1691] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1692] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1693] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1698] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1699] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1700] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1701] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1702] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1703] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1704] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1705] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1706] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1707] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1708] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1709] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1710] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1711] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1712] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1713] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1714] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1715] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1716] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1717] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1718] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1719] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1738] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1739] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1740] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1758] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1778] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1779] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1780] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1781] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1782] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1783] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1784] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1785] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1786] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1787] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1788] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1789] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1790] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1791] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1792] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1793] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1794] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1795] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1796] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1798] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1799] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1801] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1802] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1803] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1804] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1805] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1806] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1818] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1819] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1820] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1821] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1822] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1823] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1824] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1825] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1838] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1839] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1840] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1841] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1842] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1843] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1844] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1845] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1846] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1847] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1848] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1858] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1859] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1860] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1861] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1878] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1879] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1880] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1881] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1882] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1883] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1884] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1885] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1886] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1898] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1899] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1919] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1920] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1921] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1938] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1939] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1940] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1941] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1942] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1943] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1944] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1945] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1946] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1947] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1948] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1949] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1950] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1951] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1952] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1953] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1954] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1955] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1956] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1957] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1958] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1959] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1960] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1961] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1962] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1963] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1998] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [1999] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2020] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2038] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2040] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2041] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2058] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2059] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2078] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2098] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2118] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2138] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2139] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2160] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2161] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2178] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2198] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2199] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2200] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2201] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2202] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2203] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2204] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2205] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2206] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2218] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2238] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2239] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2240] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2241] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2242] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2258] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2259] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2260] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2279] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2281] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2282] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2283] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2284] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2298] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2299] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2300] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2318] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2338] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2339] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2340] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2341] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2342] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2359] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2360] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2361] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2378] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2379] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2380] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2381] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2382] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2398] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2418] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2439] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2440] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2458] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2460] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2478] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2479] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2480] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2498] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2500] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2501] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2519] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2520] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2521] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2522] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2581] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2582] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2583] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2584] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2585] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2586] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2601] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2602] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2603] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2604] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2605] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2606] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2607] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2608] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2609] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2621] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2622] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2623] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2641] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2661] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2662] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2681] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2701] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2702] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2721] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2741] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2742] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2743] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2744] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2745] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2746] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2747] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2748] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2749] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2750] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2756] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2757] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2758] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2759] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2760] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2761] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2762] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2763] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2764] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2765] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2766] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2767] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2768] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2769] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2770] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2771] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2772] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2773] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2781] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2782] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2783] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2784] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2801] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2821] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2822] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2841] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2842] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2843] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2844] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2845] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2846] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2847] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2848] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2849] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2850] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2851] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2852] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2853] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2854] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2855] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2856] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2857] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2858] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2859] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2860] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2861] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2862] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2863] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2864] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2865] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2866] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2867] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2868] = true, -- Not in the game
        [2869] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2870] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2871] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2872] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2873] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2874] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2875] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2876] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2877] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2879] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2880] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2882] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2902] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2903] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2904] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2922] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2923] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2924] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2925] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2926] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2927] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2928] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2929] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2930] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2931] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2932] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2933] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2934] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2935] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2936] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2937] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2938] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2939] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2940] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2941] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2942] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2943] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2944] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2946] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2950] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2954] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2962] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2963] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2964] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2965] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2966] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2967] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2968] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2969] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2970] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2971] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2972] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2973] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2974] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2975] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2976] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2977] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2978] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2979] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2980] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2981] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2982] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2983] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2984] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2985] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2986] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2987] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2988] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2989] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2990] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2991] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2992] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2993] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2994] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2995] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2996] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2997] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2998] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [2999] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3000] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3001] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3002] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3022] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3023] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3042] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3062] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3063] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3064] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3065] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3082] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3083] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3084] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3085] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3086] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3111] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [3112] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3113] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3114] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3121] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3122] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3123] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3124] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3125] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3126] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3127] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3128] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3129] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3130] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3141] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3161] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3181] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3182] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3201] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3221] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3241] = true, -- Not in the game
        [3261] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3281] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3301] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3321] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3341] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3362] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3364] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3365] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3367] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3368] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3369] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3370] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3371] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3372] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3373] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3374] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3375] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3376] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3377] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3378] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3379] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3380] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3382] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3383] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3384] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3385] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3401] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3402] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3403] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3404] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3405] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3421] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3422] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3423] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3424] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3425] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3441] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3442] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3443] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3444] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3445] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3446] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3447] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3448] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3449] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3450] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3451] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3452] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3453] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3454] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3461] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3462] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3463] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3481] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3483] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3501] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3502] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3503] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3504] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3505] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3506] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3507] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3508] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3509] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3510] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3511] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3512] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3513] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3514] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3515] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3516] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3517] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3518] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3519] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3520] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3521] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3522] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3523] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3524] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3525] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3526] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3527] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3528] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3529] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3530] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3531] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3541] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3542] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3561] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3562] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3563] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3564] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3565] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3566] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3567] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3568] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3569] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3570] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3581] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3601] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3602] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3621] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3622] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3623] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3624] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3625] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3626] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3627] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3628] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3629] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3630] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3631] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3632] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3633] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3634] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3635] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3636] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3637] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3638] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3639] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3640] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3641] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3642] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3643] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3644] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3645] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3646] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3647] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3661] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3681] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3701] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3702] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3741] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3761] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3762] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3763] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3764] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3765] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3767] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3781] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3782] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3783] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3784] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3785] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3786] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3787] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3788] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3789] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3790] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3791] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3792] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3801] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3802] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3803] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3804] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3821] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3822] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3823] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3824] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3825] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3841] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3842] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3843] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3844] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3845] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3881] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3882] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3883] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3884] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3885] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3901] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3902] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3903] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3904] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3905] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3906] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3907] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3908] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3909] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3910] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3911] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3912] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3913] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3914] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3921] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3922] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3923] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3924] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3941] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3942] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3961] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3962] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3981] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [3982] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4001] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4002] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4003] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4004] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4005] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4022] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4023] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4024] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4041] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4061] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4062] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4063] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4081] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4082] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4084] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4101] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4102] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4103] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4104] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4105] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4106] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4107] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4108] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4109] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4110] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4111] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4112] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4120] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4121] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4122] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4123] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4124] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4125] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4126] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4127] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4128] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4129] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4130] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4131] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4132] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4133] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4134] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4135] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4136] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4141] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4142] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4143] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4144] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4145] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4146] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4147] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4148] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4161] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4181] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4201] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4243] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4244] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4245] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4261] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4262] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4263] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4265] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4266] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4267] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4281] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4283] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4284] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4285] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4286] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4287] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4288] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4289] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4290] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4291] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4292] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4293] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4294] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4296] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4297] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4298] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4299] = true, -- Not in the game
        [4300] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4301] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4321] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4323] = true, -- Not in the game
        [4324] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4341] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4342] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4361] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4362] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4363] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4381] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4382] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4383] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4384] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4385] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4386] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4402] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4421] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4441] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4442] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4449] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4450] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4451] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4463] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4481] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4482] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4483] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4484] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4485] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4486] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4487] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4488] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4489] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4490] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4491] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4492] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4493] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4494] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4495] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4496] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4501] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4502] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4503] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4504] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4505] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4506] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4507] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4508] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4509] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4510] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4511] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4521] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4541] = true, -- Not in the game
        [4542] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4561] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4581] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4641] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4642] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4661] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4681] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4701] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4721] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4722] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4723] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4724] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4725] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4726] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4727] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4728] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4729] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4730] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4731] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4732] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4733] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4734] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4735] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4736] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4737] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4738] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4739] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4740] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4741] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4742] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4743] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4761] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4762] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4763] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4764] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4765] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4766] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4767] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4768] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4769] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4770] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4771] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4781] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4782] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4783] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4784] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4785] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4786] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4787] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4788] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4801] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4802] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4803] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4804] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4805] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4806] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4807] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4808] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4809] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4810] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4811] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4812] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4813] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4821] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4841] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4842] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4861] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4862] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4863] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4864] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4865] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4866] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4867] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4881] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4882] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4883] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4901] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4902] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4904] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4905] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4906] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4907] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4921] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4961] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4962] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4963] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4964] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4965] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4966] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4967] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4968] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4969] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4970] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4971] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4972] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4973] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4975] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4976] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4981] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4982] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4984] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4985] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4986] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [4987] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5001] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5002] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5021] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5022] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5023] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5042] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [5043] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [5044] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [5045] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [5046] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [5047] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5048] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5049] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5050] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5051] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5052] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5053] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5054] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5055] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5056] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5057] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5058] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5059] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5060] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5061] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5062] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5063] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5064] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5065] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5066] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5067] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5068] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5081] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5082] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5083] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5084] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5085] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5086] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5087] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5088] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5089] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5090] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5091] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5092] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5093] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5094] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5095] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5096] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5097] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5098] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5102] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5103] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5121] = Expansions.Current >= Expansions.Cata, -- Replaced by 28470
        [5122] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5123] = Expansions.Current >= Expansions.Cata, -- Replaced by 28471
        [5124] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5125] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5126] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5127] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5128] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5141] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5142] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5143] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5144] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5145] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5146] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5147] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5148] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5149] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5150] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5151] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5152] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5153] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5154] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5155] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5156] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5157] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5158] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5159] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5160] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5161] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5162] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5163] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5164] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5165] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5166] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5167] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5168] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5181] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5201] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5202] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5203] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5204] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5205] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5206] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5207] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5208] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5209] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5210] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5211] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5212] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5213] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5214] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5215] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5216] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5217] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5218] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5219] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5220] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5221] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5222] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5223] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5224] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5225] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5226] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5227] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5228] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5229] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5230] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5231] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5232] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5233] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5234] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5235] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5236] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5237] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5238] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5241] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5242] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5243] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5244] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5245] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5246] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5247] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5248] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5249] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5250] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5251] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5252] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5253] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5261] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5262] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5263] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5264] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5265] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5281] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5282] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5283] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5284] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5301] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5302] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5303] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5304] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5305] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5306] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5307] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5321] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5341] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5342] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5343] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5344] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5361] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5382] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5384] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5385] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5386] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5401] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5402] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5403] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5404] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5405] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5406] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5407] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5408] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5441] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5461] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5462] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5463] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5464] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5465] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5466] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5481] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5482] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5503] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5504] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5505] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5506] = true, -- Not in the game
        [5507] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5508] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5509] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5510] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5511] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5512] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5513] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5514] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5515] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5516] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5517] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5518] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5519] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5520] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5521] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5522] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5523] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5524] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5525] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5526] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5527] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5528] = Expansions.Current >= Expansions.Cata, -- Removed with cata (replaced with 27114)
        [5529] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5530] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5531] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5532] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5533] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5534] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5535] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5536] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5537] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5538] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5541] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5542] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5543] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5544] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5582] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5601] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5621] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5622] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5623] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5624] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5625] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5626] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5628] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5629] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5630] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5631] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5632] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5633] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5642] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5643] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5644] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5646] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5648] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5649] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5650] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5651] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5652] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5653] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5654] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5655] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5656] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5657] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5659] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5660] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5661] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5662] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5664] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5665] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5666] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5667] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5668] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5669] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5670] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5671] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5672] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5673] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5674] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5675] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5676] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5677] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5678] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5679] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5680] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5681] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5682] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5683] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5684] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5685] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5686] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5687] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5688] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5689] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5690] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5691] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5692] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5693] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5694] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5695] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5696] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5697] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5698] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5699] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5700] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5701] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5702] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5703] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5704] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5705] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5706] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5707] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5708] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5709] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5710] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5711] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5712] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5721] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5722] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5723] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5724] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5725] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5726] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5727] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5728] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5729] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5730] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5741] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5742] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5761] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5762] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5763] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5781] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5801] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5802] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5803] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5804] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5845] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5846] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5848] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5861] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5862] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5863] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5881] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5882] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5883] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5884] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5885] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5886] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5887] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5888] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5889] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5890] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5891] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5901] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5902] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5903] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5904] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5921] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5922] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5923] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5924] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5925] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5926] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5927] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5928] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5929] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5930] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5931] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5932] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5941] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5942] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5944] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5961] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [5981] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6001] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6002] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6003] = true, -- Not in the game
        [6004] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6021] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6022] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6023] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6024] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6025] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6026] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6027] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6028] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6029] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6030] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6041] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6042] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6061] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6062] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6063] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6064] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6065] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6067] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6068] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6069] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6070] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6071] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6073] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6074] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6075] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6076] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6081] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6082] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6083] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6084] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6085] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6086] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6087] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6088] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6089] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6101] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6102] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6103] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6121] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6122] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6123] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6124] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6125] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6126] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6127] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6128] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6129] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6130] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6133] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6135] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6136] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6141] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6142] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6143] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6145] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6146] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6147] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6148] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6161] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6162] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6163] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6164] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6165] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6182] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6183] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6184] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6185] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6186] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6187] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6201] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6202] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6282] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6283] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6284] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6301] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6381] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6382] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6383] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6389] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6390] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6393] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6394] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6395] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6401] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6421] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6461] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6481] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6504] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6521] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6522] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6523] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6541] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6542] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6543] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6545] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6546] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6547] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6548] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6561] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6562] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6563] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6564] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6565] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6571] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6581] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6603] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6604] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6605] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6609] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6612] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6623] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6626] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6627] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6628] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6629] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6681] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6701] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6702] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6703] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6704] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6705] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6706] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6707] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6708] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6709] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6710] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6711] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6761] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6762] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6805] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6841] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6842] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6844] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6845] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6921] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [6981] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7003] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7028] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7029] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7041] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7044] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7046] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7064] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7065] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7066] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7067] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7068] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7069] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7070] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7181] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7201] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7202] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7241] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7261] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7321] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7341] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7342] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7384] = true, -- Not in the game
        [7429] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7441] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7461] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7463] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7481] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7482] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7483] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7484] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7485] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7488] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7489] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7492] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7494] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7498] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7499] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7500] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7501] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7502] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7503] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7504] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7505] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7506] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7541] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7561] = true, -- Correct version is 7787
        [7562] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7563] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7564] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7581] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7582] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7583] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7601] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7602] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7603] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7621] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7622] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7623] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7624] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7625] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7626] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7627] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7628] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7629] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7630] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7631] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7632] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7633] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7634] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7635] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7636] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7637] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7638] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7639] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7640] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7641] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7642] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7643] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7644] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7645] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7646] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7647] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7648] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7649] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7650] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7651] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7652] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7653] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7654] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7655] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7656] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7657] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7658] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7659] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7666] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7667] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7669] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7670] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7701] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7702] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7703] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7721] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7722] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7723] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7724] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7725] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7726] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7727] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7728] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7729] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7730] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7731] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7732] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7733] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7734] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7735] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7736] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7738] = Expansions.Current >= Expansions.Cata, -- Removed with cata (replaced with 25454)
        [7790] = true, -- Not in the game
        [7791] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7792] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7793] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7794] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7795] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7796] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7798] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7799] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7800] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7801] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7802] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7803] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7804] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7805] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7806] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7807] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7808] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7809] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7811] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7812] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7813] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7814] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7815] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7816] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7817] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7818] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7819] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7820] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7821] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7822] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7823] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7824] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7825] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7826] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7827] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7828] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7829] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7830] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7831] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7832] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7833] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7834] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7835] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7836] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7837] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7839] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7840] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7841] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7842] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7843] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7844] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7845] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7846] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7847] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7849] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7850] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7861] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7862] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7869] = true, -- Not in the game
        [7870] = true, -- Not in the game
        [7877] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7908] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [7962] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8041] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8042] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8043] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8044] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8045] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8046] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8047] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8048] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8049] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8050] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8051] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8052] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8053] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8054] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8055] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8056] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8057] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8058] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8059] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8060] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8061] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8062] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8063] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8064] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8065] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8066] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8067] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8068] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8069] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8070] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8071] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8072] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8073] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8074] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8075] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8076] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8077] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8078] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8079] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8101] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8102] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8103] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8104] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8106] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8107] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8108] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8109] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8110] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8111] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8112] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8113] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8116] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8117] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8118] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8119] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8141] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8142] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8143] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8144] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8145] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8146] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8147] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8148] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8151] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8152] = true, -- Not in the game
        [8153] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8181] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8182] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8183] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8184] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8185] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8186] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8187] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8188] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8189] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8190] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8191] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8192] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8195] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8196] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8201] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8227] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8231] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8232] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8233] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8234] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8235] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8236] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8237] = true, -- Not in the game
        [8238] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8239] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8240] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8241] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8242] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8243] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8244] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8245] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8246] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8247] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8248] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8250] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8251] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8252] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8253] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8254] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8255] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8256] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8257] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8258] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8259] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8270] = true, -- Not in the game
        [8273] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8274] = true, -- Not in the game
        [8275] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8286] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8288] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8301] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8302] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8303] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8305] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8315] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8316] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8331] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8332] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8333] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8337] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8341] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8342] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8343] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8348] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8349] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8351] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8352] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8361] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8362] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8363] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8364] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8365] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8366] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8376] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8377] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8378] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8379] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8380] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8381] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8382] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8410] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8412] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8413] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8414] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8415] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8416] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8417] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8418] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8419] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8420] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8421] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8422] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8423] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8424] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8425] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8444] = true, -- Not in the game
        [8445] = true, -- Not in the game
        [8446] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8448] = true, -- Not in the game
        [8449] = true, -- Not in the game
        [8450] = true, -- Not in the game
        [8451] = true, -- Not in the game
        [8452] = true, -- Not in the game
        [8453] = true, -- Not in the game
        [8454] = true, -- Not in the game
        [8458] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8459] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8460] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8461] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8462] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8464] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8465] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8466] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8467] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8469] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8471] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8484] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8485] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8496] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8497] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8498] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8501] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8502] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8507] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8508] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8519] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8534] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8535] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8536] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8537] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8538] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8539] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8540] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8541] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8548] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8551] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8552] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8553] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8554] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8555] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8556] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8572] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8573] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8574] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8575] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8576] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8577] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8584] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8585] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8586] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8587] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8597] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8598] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8599] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8606] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8620] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8687] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8728] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8729] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8730] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8733] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8734] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8735] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8736] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8737] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8738] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8739] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8740] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8741] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8742] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8745] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8770] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8771] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8772] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8773] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8774] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8775] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8776] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8777] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8778] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8779] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8780] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8781] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8782] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8783] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8785] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8786] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8787] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8800] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8804] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8805] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8806] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8807] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8808] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8809] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8810] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8829] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8869] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8893] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8905] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8906] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8907] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8908] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8909] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8910] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8911] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8912] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8913] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8914] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8915] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8916] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8917] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8918] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8919] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8920] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8921] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8922] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8923] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8924] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8925] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8926] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8927] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8928] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8929] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8930] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8931] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8932] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8933] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8934] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8935] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8936] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8937] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8938] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8939] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8940] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8941] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8942] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8943] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8944] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8945] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8946] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8947] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8948] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8949] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8950] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8951] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8952] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8953] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8954] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8955] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8956] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8957] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8958] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8959] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8960] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8961] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8962] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8963] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8964] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8965] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8966] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8967] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8968] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8969] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8970] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8977] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8978] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8985] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8986] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8987] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8988] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8989] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8990] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8991] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8992] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8994] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8995] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8996] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8997] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8998] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [8999] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9000] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9001] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9002] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9003] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9004] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9005] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9006] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9007] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9008] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9009] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9010] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9011] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9012] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9013] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9014] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9015] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9016] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9017] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9018] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9019] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9020] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9021] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9022] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9023] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9030] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9031] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9032] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9033] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9034] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9036] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9037] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9038] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9039] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9040] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9041] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9042] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9043] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9044] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9045] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9046] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9047] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9048] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9049] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9050] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9051] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9052] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9053] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9054] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9055] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9056] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9057] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9058] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9059] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9060] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9061] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9063] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9068] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9069] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9070] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9071] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9072] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9073] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9074] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9075] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9077] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9078] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9079] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9080] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9081] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9082] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9083] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9084] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9086] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9087] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9088] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9089] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9090] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9091] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9092] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9093] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9095] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9096] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9097] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9098] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9099] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9100] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9101] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9102] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9103] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9104] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9105] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9106] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9107] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9108] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9109] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9110] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9111] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9112] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9113] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9114] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9115] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9116] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9117] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9118] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9121] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9122] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9123] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9124] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9125] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9126] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9127] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9128] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9129] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9131] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9132] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9136] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9137] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9141] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9142] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9165] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9178] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9179] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9181] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9182] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9183] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9184] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9185] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9186] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9187] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9188] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9189] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9190] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9191] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9194] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9195] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9196] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9197] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9198] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9200] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9201] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9202] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9203] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9204] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9205] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9206] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9208] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9209] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9210] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9211] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9213] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9221] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9222] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9223] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9224] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9225] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9226] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9227] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9228] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9231] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9248] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9273] = true, -- Redeem iCoke Prize Voucher
        [9287] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9288] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9289] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9290] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9291] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9296] = true, -- Not in the game
        [9297] = true, -- Not in the game
        [9298] = true, -- Not in the game
        [9306] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9307] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9308] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9316] = true, -- Not in the game
        [9338] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9347] = true, -- Correct version is 9351
        [9348] = true, -- Not in the game
        [9350] = true, -- Not in the game
        [9353] = true, -- Redeem iCoke Gift Box Voucher
        [9362] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9364] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9377] = true, -- Not in the game
        [9379] = true, -- Not in the game
        [9384] = true, -- Not in the game
        [9411] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9412] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9413] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9414] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9421] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9425] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9428] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9431] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9432] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9433] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9434] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9435] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9438] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9439] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9440] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9441] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9442] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9443] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9444] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9445] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9446] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9447] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9448] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9449] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9450] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9451] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9458] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9459] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9460] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9461] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9462] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9464] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9465] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9467] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9468] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9469] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9470] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9471] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9474] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9475] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9476] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9477] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9478] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9479] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9480] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9481] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9482] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9484] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9485] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9486] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9489] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9491] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9492] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9493] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9494] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9495] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9496] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9497] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9500] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9501] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9502] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9503] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9504] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9507] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9508] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9509] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9516] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9517] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9518] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9519] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9520] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9521] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9522] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9524] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9525] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9526] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9529] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9532] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9533] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9534] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9535] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9536] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9546] = true, -- Not in the game
        [9547] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9551] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9552] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9553] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9554] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9555] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9572] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9575] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9577] = true, -- Not in the game
        [9586] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9587] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9588] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9589] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9590] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9591] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9592] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9593] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9595] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9596] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [9597] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9598] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9600] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9601] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9607] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9608] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9609] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9610] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9611] = true, -- Not in the game
        [9613] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9614] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9615] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9617] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9618] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9619] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9633] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9650] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9651] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9652] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9653] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9654] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9655] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9656] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9657] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9658] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9659] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9660] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9661] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9662] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9664] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9665] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9673] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9675] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9677] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9678] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9679] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9681] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9684] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9685] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9686] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9690] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9691] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9692] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9695] = true, -- Not in the game
        [9707] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9710] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9714] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9715] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9717] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9719] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9721] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9722] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9723] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9725] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9735] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9736] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9737] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9738] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9745] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9757] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9763] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9764] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9876] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9880] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9881] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9908] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [9909] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10032] = true, -- Not in the game
        [10080] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10083] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10091] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10094] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10095] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10097] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10098] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10164] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10165] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10175] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10177] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10178] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10181] = true, -- Not in the game
        [10212] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10216] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10217] = true, -- Not in the game
        [10218] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10283] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10284] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10285] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10298] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10352] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10354] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10356] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10357] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10358] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10359] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10360] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10361] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10362] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10363] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10366] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10371] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10372] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10373] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10374] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10376] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10378] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10402] = true, -- Not in the game
        [10452] = true, -- Not in the game
        [10453] = true, -- Not in the game
        [10490] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10491] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10492] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10493] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10494] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10495] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10496] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10497] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10498] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10499] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10529] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10530] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10548] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10549] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10590] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10591] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10592] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10593] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10605] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10616] = true, -- Not in the game
        [10631] = true, -- Not in the game
        [10743] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10746] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10752] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10754] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10755] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10756] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10757] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10758] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10787] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10788] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10789] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10790] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10794] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10831] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10832] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10833] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10882] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10890] = true, -- Not in the game
        [10891] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10892] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10897] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10899] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10902] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10905] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10906] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10907] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10955] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10961] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10964] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10965] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10978] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10979] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10980] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10986] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10987] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10988] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10990] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10991] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10992] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10993] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [10994] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11001] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11011] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11087] = true, -- Not in the game
        [11088] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11115] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11116] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11121] = true, -- Not in the game
        [11123] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11124] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11125] = true, -- Not in the game
        [11126] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11128] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11130] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11132] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11133] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11134] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11136] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11137] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11138] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11139] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11140] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11141] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11142] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11143] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11144] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11145] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11146] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11147] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11148] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11149] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11151] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11150] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11152] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11156] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11158] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11159] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11160] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11161] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11162] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11163] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11164] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11165] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11166] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11169] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11171] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11172] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11173] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11174] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11177] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11178] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11180] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11181] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11183] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11184] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11185] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11186] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11191] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11192] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11193] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11194] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11195] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11197] = true, -- Promo
        [11198] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11200] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11201] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11203] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11204] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11205] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11206] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11207] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11209] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11210] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11214] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11217] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11222] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11223] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11225] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11226] = true, -- Promo
        [11252] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11334] = true, -- Not in the game
        [11335] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11336] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11337] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11338] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11339] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11340] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11341] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11342] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11345] = true, -- Not in the game
        [11347] = true, -- Not in the game
        [11353] = true, -- Not in the game
        [11354] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11362] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11363] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11368] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11372] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11382] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11419] = Expansions.Current >= Expansions.Wotlk, -- Removed with Wotlk
        [11435] = true, -- Not in the game
        [11488] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11492] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [11493] = true, -- Not in the game
        [11588] = true, -- Not in the game
        [11589] = true, -- Not in the game
        [11875] = true, -- hiding because we use fake quests to mimic this one
        [11934] = true, -- Not in the game
        [11992] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [12001] = true, -- Not in the game
        [12179] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [12238] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [12313] = true, -- Not in the game
        [12625] = true, -- Not in the game
        [12626] = true, -- Not in the game
        [12765] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [12918] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [12923] = true, -- Not in the game
        [12952] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13002] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13004] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13097] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13098] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13099] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13111] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13159] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13167] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13182] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13190] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13204] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13205] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13266] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13267] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13299] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13303] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13405] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13407] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13427] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13428] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13431] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13574] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13608] = true, -- Not in the game
        [13637] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13638] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13652] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13799] = true, -- Not in the game
        [13800] = true, -- Not in the game
        [13802] = true, -- Not in the game
        [13804] = true, -- Not in the game
        [13827] = true, -- Not in the game
        [13840] = true, -- Not in the game
        [13894] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13939] = true, -- Not in the game
        [13941] = true, -- Not in the game
        [13972] = true, -- Not in the game
        [13978] = true, -- Not in the game
        [13984] = true, -- Not in the game
        [13986] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13993] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [13994] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14000] = true, -- Not in the game
        [14002] = true, -- Not in the game
        [14015] = true, -- Not in the game
        [14020] = true, -- Not in the game
        [14025] = true, -- Not in the game
        [14026] = true, -- Not in the game
        [14027] = true, -- Not in the game
        [14029] = true, -- Not in the game
        [14097] = true, -- Not in the game
        [14100] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14111] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14114] = Expansions.Current >= Expansions.Cata, -- Hidden quest in cata
        [14119] = true, -- Not in the game
        [14133] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [14137] = Expansions.Current >= Expansions.Cata, -- Hidden quest in cata
        [14139] = Expansions.Current >= Expansions.Cata, -- Hidden quest in cata
        [14156] = true, -- Not in the game
        [14158] = Expansions.Current >= Expansions.Cata, -- Hidden quest in cata
        [14163] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14164] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14178] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14179] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14180] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14181] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14182] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14183] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14220] = true, -- Not in the game
        [14231] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [14259] = true, -- Not in the game
        [14298] = true, -- Not in the game
        [14315] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14317] = true, -- Not in the game
        [14319] = true, -- Not in the game
        [14349] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14350] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14352] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14355] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14356] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14409] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14411] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [14414] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [14415] = true, -- Not in the game
        [14418] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14419] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14420] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14421] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14425] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14426] = true, -- Not in the game
        [14427] = true, -- Not in the game
        [14436] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14437] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14439] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14440] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [14446] = Expansions.Current >= Expansions.Cata, -- Duplicate of 28826
        [14450] = true, -- Not in the game
        [14451] = true, -- Not in the game
        [14453] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [14454] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [14474] = Expansions.Current >= Expansions.Cata, -- Duplicate of 14001
        [14481] = true, -- Not in the game
        [24216] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24217] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24218] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24219] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24220] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24221] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24222] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24223] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24224] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24225] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24226] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24227] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24426] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24427] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24443] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24444] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24445] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24446] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24447] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24460] = true, -- Not in the game
        [24462] = true, -- Not in the game
        [24464] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24465] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24466] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24481] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24482] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24485] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24503] = Expansions.Current >= Expansions.Cata, -- Duplicate of 28414
        [24544] = true, -- Not in the game
        [24568] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24630] = true, -- Not in the game
        [24644] = Expansions.Current >= Expansions.Cata, -- Hidden quest in cata
        [24661] = true, -- Not in the game
        [24688] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24696] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24716] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24738] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24739] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24746] = true, -- Not in the game
        [24797] = true, -- Not in the game
        [24857] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24860] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24867] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24898] = true, -- Not in the game
        [24899] = true, -- Not in the game
        [24900] = true, -- Not in the game
        [24908] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24909] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24984] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24985] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24986] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24987] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24935] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24936] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24992] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [24993] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25016] = Expansions.Current >= Expansions.Cata, -- Hidden quest
        [25033] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25039] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25040] = Expansions.Current >= Expansions.Cata, -- Hidden quest
        [25055] = true, -- Not in the game
        [25071] = Expansions.Current >= Expansions.Cata, -- Hidden quest
        [25076] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25077] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25078] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25083] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25092] = true, -- Not in the game
        [25096] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25097] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25101] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25113] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25114] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25116] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25117] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25119] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25124] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25137] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25140] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25142] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25144] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25146] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25148] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25150] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25198] = true, -- Not in the game
        [25199] = true, -- Not in the game
        [25212] = true, -- Not in the game
        [25225] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25226] = true, -- Hidden quest
        [25229] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25231] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25245] = true, -- Hidden quest
        [25254] = true, -- Not in the game
        [25283] = true, -- Not in the game
        [25285] = true, -- Not in the game
        [25286] = true, -- Not in the game
        [25287] = true, -- Not in the game
        [25289] = true, -- Not in the game
        [25295] = true, -- Not in the game
        [25302] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25305] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25307] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25313] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25318] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25322] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25326] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25327] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25331] = true, -- Not in the game
        [25335] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25376] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25384] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25393] = true, -- Not in the game
        [25413] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25435] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25455] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25457] = true, -- Not in the game
        [25474] = Expansions.Current >= Expansions.Cata, -- Duplicate of 27729
        [25497] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25498] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25500] = true, -- Not in the game
        [25501] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25506] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25508] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25527] = true, -- Not in the game
        [25530] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25528] = true, -- Not in the game
        [25529] = true, -- Not in the game
        [25557] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25567] = true, -- Not in the game
        [25568] = true, -- Not in the game
        [25569] = true, -- Not in the game
        [25570] = true, -- Not in the game
        [25572] = true, -- Not in the game
        [25573] = Expansions.Current >= Expansions.Cata, -- Hidden quest
        [25603] = true, -- Not in the game
        [25604] = true, -- Not in the game
        [25605] = true, -- Not in the game
        [25606] = true, -- Not in the game
        [25625] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25635] = Expansions.Current >= Expansions.Cata, -- Duplicate of 25583 and 25956
        [25636] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25639] = Expansions.Current >= Expansions.Cata, -- Hidden quest
        [25666] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25737] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25738] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25742] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25750] = true, -- Not in the game
        [25781] = true, -- Not in the game
        [25782] = true, -- Not in the game
        [25783] = true, -- Not in the game
        [25784] = true, -- Not in the game
        [25785] = true, -- Not in the game
        [25786] = true, -- Not in the game
        [25787] = true, -- Not in the game
        [25788] = true, -- Not in the game
        [25827] = true, -- Not in the game
        [25828] = true, -- Not in the game
        [25829] = true, -- Hidden quest
        [25831] = true, -- Not in the game
        [25833] = true, -- Not in the game
        [25902] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [25903] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26104] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26109] = true, -- Not in the game
        [26119] = true, -- Hidden quest
        [26123] = true, -- Not in the game
        [26136] = true, -- Hidden quest
        [26138] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26151] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26155] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26156] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26216] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26217] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26218] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26231] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26239] = true, -- Not in the game
        [26242] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26243] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26253] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26262] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26282] = true, -- Not in the game
        [26379] = true, -- Not in the game
        [26392] = true, -- Not in the game
        [26398] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26415] = true, -- Not in the game
        [26431] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26458] = true, -- Not in the game
        [26459] = true, -- Not in the game
        [26460] = true, -- Not in the game
        [26461] = true, -- Not in the game
        [26471] = true, -- Not in the game
        [26522] = true, -- Not in the game
        [26527] = true, -- Not in the game
        [26559] = true, -- Hidden quest
        [26565] = Expansions.Current >= Expansions.Cata, -- Duplicate of 26588
        [26626] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26673] = true, -- Hidden quest
        [26675] = true, -- Not in the game
        [26704] = true, -- Hidden quest
        [26705] = true, -- Hidden quest
        [26715] = true, -- Not in the game
        [26716] = true, -- Not in the game
        [26718] = true, -- Not in the game
        [26741] = true, -- Not in the game
        [26758] = true, -- Not in the game
        [26759] = true, -- Not in the game
        [26764] = true, -- Not in the game
        [26767] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26782] = true, -- Duplicate of 26783
        [26789] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26790] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26826] = Expansions.Current >= Expansions.Cata, -- Duplicate of 26825
        [26837] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26839] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26847] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26848] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26849] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26850] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26851] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26852] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26853] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [26856] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26858] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26859] = true, -- Hidden quest
        [26862] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26865] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26866] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26867] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26874] = true, -- Hidden quest
        [26877] = true, -- Hidden quest
        [26879] = true, -- Hidden quest
        [26880] = true, -- Hidden quest
        [26893] = true, -- Not in the game
        [26900] = true, -- Not in the game
        [26902] = true, -- Hidden quest
        [26951] = Expansions.Current >= Expansions.Cata, -- Seems to not be available
        [26972] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26973] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26974] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26976] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26982] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26983] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26984] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26985] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26993] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26994] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [26996] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [27018] = Expansions.Current >= Expansions.Cata, -- Seems to not be available
        [27052] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [27079] = true, -- Hidden quest
        [27080] = true, -- Hidden quest
        [27081] = true, -- Not in the game
        [27121] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [27140] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [27142] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [27143] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [27145] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [27146] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [27147] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [27148] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [27149] = true, -- Not in the game
        [27250] = true, -- Not in the game
        [27289] = true, -- Not in the game
        [27309] = true, -- Duplicate version of 27293
        [27419] = true, -- Not in the game
        [27543] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [27552] = Expansions.Current >= Expansions.Cata, -- Hidden quest
        [27553] = Expansions.Current >= Expansions.Cata, -- Hidden quest
        [27554] = Expansions.Current >= Expansions.Cata, -- Hidden quest
        [27563] = Expansions.Current >= Expansions.Cata, -- Hidden quest
        [27634] = true, -- Not in the game
        [27678] = true, -- Not in the game
        [27723] = true, -- Not in the game
        [27819] = true, -- Not in the game
        [27861] = Expansions.Current >= Expansions.Cata, -- Duplicate of 27863
        [27862] = Expansions.Current >= Expansions.Cata, -- Duplicate of 27863
        [27872] = true, -- Hidden quest
        [27873] = true, -- Hidden quest
        [27925] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [27946] = true, -- Not in the game
        [28003] = true, -- Not in the game
        [28004] = true, -- Not in the game
        [28005] = true, -- Not in the game
        [28006] = true, -- Not in the game
        [28007] = true, -- Not in the game
        [28008] = true, -- Not in the game
        [28009] = true, -- Not in the game
        [28010] = true, -- Not in the game
        [28011] = true, -- Not in the game
        [28012] = true, -- Not in the game
        [28013] = true, -- Not in the game
        [28014] = true, -- Not in the game
        [28015] = true, -- Not in the game
        [28016] = true, -- Not in the game
        [28017] = true, -- Not in the game
        [28018] = true, -- Not in the game
        [28019] = true, -- Not in the game
        [28020] = true, -- Not in the game
        [28021] = true, -- Not in the game
        [28022] = true, -- Not in the game
        [28023] = true, -- Not in the game
        [28024] = true, -- Not in the game
        [28025] = true, -- Not in the game
        [28026] = true, -- Not in the game
        [28027] = true, -- Not in the game
        [28036] = true, -- Not in the game
        [28037] = true, -- Not in the game
        [28039] = true, -- Not in the game
        [28040] = true, -- Not in the game
        [28065] = true, -- Not in the game
        [28066] = true, -- Not in the game
        [28067] = true, -- Not in the game
        [28070] = true, -- Not in the game
        [28071] = true, -- Not in the game
        [28072] = true, -- Not in the game
        [28073] = true, -- Not in the game
        [28074] = true, -- Not in the game
        [28075] = true, -- Not in the game
        [28076] = true, -- Not in the game
        [28077] = true, -- Not in the game
        [28078] = true, -- Not in the game
        [28079] = true, -- Not in the game
        [28080] = true, -- Not in the game
        [28081] = true, -- Not in the game
        [28082] = true, -- Not in the game
        [28083] = true, -- Not in the game
        [28095] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28106] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28110] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28236] = Expansions.Current >= Expansions.Cata, -- Duplicate of 28233
        [28240] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28255] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28270] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28347] = true, -- Hidden quest
        [28365] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28371] = Expansions.Current >= Expansions.Cata, -- Hidden quest
        [28412] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28462] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28468] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28481] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28516] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28541] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28546] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28547] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28555] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28585] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28601] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28642] = Expansions.Current >= Expansions.Cata, -- Not in the game - Shy Rotam quest is 28742
        [28648] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28720] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28721] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28739] = true, -- Hidden quest
        [28743] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28751] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28752] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28754] = Expansions.Current >= Expansions.Cata, -- Duplicate of 28758
        [28835] = Expansions.Current >= Expansions.Cata, -- Hidden quest
        [28844] = true, -- Not in the game
        [28846] = true, -- Hidden quest
        [28851] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28855] = true, -- Not in the game
        [28876] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28877] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [28886] = true, -- Hidden quest
        [28887] = true, -- Hidden quest
        [28888] = true, -- Hidden quest
        [28889] = true, -- Hidden quest
        [28890] = true, -- Not in the game
        [28891] = true, -- Not in the game
        [28892] = true, -- Not in the game
        [28893] = true, -- Not in the game
        [28894] = true, -- Not in the game
        [28895] = true, -- Not in the game
        [28896] = true, -- Not in the game
        [28897] = true, -- Not in the game
        [28898] = true, -- Not in the game
        [28899] = true, -- Not in the game
        [28900] = true, -- Not in the game
        [28901] = true, -- Not in the game
        [28902] = true, -- Not in the game
        [28903] = true, -- Not in the game
        [28904] = true, -- Not in the game
        [28936] = true, -- Hidden quest
        [28937] = true, -- Hidden quest
        [28938] = true, -- Hidden quest
        [28940] = true, -- Hidden quest
        [28941] = true, -- Hidden quest
        [28942] = true, -- Hidden quest
        [29025] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29028] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29029] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29033] = true, -- Not in the game
        [29035] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29052
        [29037] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29039
        [29038] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29053
        [29040] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29051
        [29049] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29076] = true, -- Not in the game
        [29091] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29096] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29097] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29098] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29099] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29108] = true, -- Not in the game
        [29140] = true, -- Not in the game
        [29170] = true, -- Not in the game
        [29171] = true, -- Not in the game
        [29212] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29216] = true, -- Not in the game
        [29218] = true, -- Not in the game
        [29224] = true, -- Not in the game
        [29256] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29258] = true, -- Not in the game
        [29259] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29260] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29266] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29271] = true, -- Not in the game
        [29277] = true, -- Not in the game
        [29286] = true, -- Not in the game
        [29291] = true, -- Not in the game
        [29292] = true, -- Not in the game
        [29294] = true, -- Not in the game
        [29339] = true, -- Not in the game
        [29340] = true, -- Not in the game
        [29341] = true, -- Not in the game
        [29368] = true, -- Not in the game
        [29372] = true, -- Not in the game
        [29373] = true, -- Not in the game
        [29378] = true, -- Hidden quest
        [29379] = true, -- Hidden quest
        [29380] = true, -- Hidden quest
        [29381] = true, -- Hidden quest
        [29386] = true, -- Hidden quest
        [29395] = true, -- Hidden quest
        [29404] = Expansions.Current >= Expansions.MoP, -- Not in the game
        [29405] = Expansions.Current >= Expansions.MoP, -- Not in the game
        [29407] = Expansions.Current >= Expansions.MoP, -- Not in the game
        [29413] = true, -- Not in the game
        [29429] = true, -- Not in the game
        [29432] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29441] = true, -- Not in the game
        [29447] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29448] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29449] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29450] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29454] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29459] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29460] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29461] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29465] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29466] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29467] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29511
        [29468] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29508
        [29469] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29518
        [29470] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29519
        [29471] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29515
        [29472] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29517
        [29473] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29512
        [29474] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29510
        [29476] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29477
        [29478] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29506
        [29479] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29514
        [29480] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29520
        [29483] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29516
        [29484] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29509
        [29485] = Expansions.Current >= Expansions.Cata, -- Duplicate of 29507
        [29532] = true, -- Not in the game
        [29533] = true, -- Not in the game
        [29534] = true, -- Not in the game
        [29544] = true, -- Not in the game
        [29545] = true, -- Not in the game
        [29554] = true, -- Not in the game
        [29569] = true, -- Not in the game
        [29592] = true, -- Hidden quest
        [29597] = true, -- Not in the game
        [29601] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29659] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29671] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29672] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29673] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29683] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29703] = Expansions.Current >= Expansions.MoP, -- Not in the game
        [29705] = Expansions.Current >= Expansions.MoP, -- Not in the game
        [29706] = Expansions.Current >= Expansions.MoP, -- Not in the game
        [29761] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [29773] = Expansions.Current >= Expansions.MoP, -- Not in the game
        [29859] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [29868] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [29876] = Expansions.Current >= Expansions.MoP, -- Removed in MoP
        [30110] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [30111] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [30173] = true, -- Not in the game
        [30454] = Expansions.Current >= Expansions.MoP, -- Not in the game
        [30455] = Expansions.Current >= Expansions.MoP, -- Not in the game
        [30537] = true, -- Not in the game
        [30538] = true, -- Not in the game
        [30539] = true, -- Hidden quest
        [30540] = true, -- Hidden quest
        [30541] = true, -- Hidden quest
        [30542] = true, -- Hidden quest
        [30543] = true, -- Hidden quest
        [30544] = true, -- Hidden quest
        [30545] = true, -- Hidden quest
        [30546] = true, -- Hidden quest
        [30547] = true, -- Hidden quest
        [30548] = true, -- Hidden quest
        [30549] = true, -- Hidden quest
        [30550] = true, -- Hidden quest
        [30551] = true, -- Hidden quest
        [30552] = true, -- Hidden quest
        [30553] = true, -- Hidden quest
        [30554] = true, -- Hidden quest
        [30555] = true, -- Hidden quest
        [30556] = true, -- Hidden quest
        [30557] = true, -- Hidden quest
        [30558] = true, -- Hidden quest
        [30559] = true, -- Hidden quest
        [30560] = true, -- Hidden quest
        [30561] = true, -- Hidden quest
        [30562] = true, -- Hidden quest
        [30759] = true, -- Not in the game
        [30817] = Expansions.Current >= Expansions.MoP, -- Not in the game
        [30818] = Expansions.Current >= Expansions.MoP, -- Not in the game
        [30934] = true, -- Not in the game
        [31033] = Expansions.Current >= Expansions.MoP, -- Not in the game
        [31035] = Expansions.Current >= Expansions.MoP, -- Not in the game
        [31172] = Expansions.Current >= Expansions.MoP, -- Not in the game
        [32396] = Expansions.Current >= Expansions.MoP, -- Not in the game
        [32666] = true, -- Hidden quest
        [65593] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [65597] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [65601] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [65602] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [65603] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [65604] = Expansions.Current >= Expansions.Cata, -- Not in the game
        [65610] = Expansions.Current >= Expansions.Cata, -- Not in the game

        --- MoP Learn to Ride quests
        [32618] = true, -- Learn To Ride
        [32661] = true, -- Learn To Ride
        [32662] = true, -- Learn To Ride
        [32663] = true, -- Learn To Ride
        [32664] = true, -- Learn To Ride
        [32665] = true, -- Learn To Ride
        [32667] = true, -- Learn To Ride
        [32668] = true, -- Learn To Ride
        [32669] = true, -- Learn To Ride
        [32670] = true, -- Learn To Ride
        [32671] = true, -- Learn To Ride
        [32672] = true, -- Learn To Ride
        [32673] = true, -- Learn To Ride
        [32674] = true, -- I Believe You Can Fly
        [32675] = true, -- I Believe You Can Fly

        --- Daily quests
        [28905] = true, -- Daily Heroic Random (1st) (Cataclysm)
        [28906] = true, -- Daily Heroic Random (Nth)
        [28907] = true, -- Daily Normal Random (1st)
        [28908] = true, -- Daily Normal Random (Nth)
        [29084] = true, -- Classic Random 35-39 (1st)
        [29085] = true, -- Classic Random 35-39 (Nth)
        [29183] = true, -- Daily Tier 2 Heroic (Nth)
        [29185] = true, -- Daily Tier 2 Heroic (1st)
        [30177] = true, -- Daily Heroic Random (1st) (Cataclysm)

        -- ICC weekly quests
        [24869] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24870] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24871] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24872] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24873] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24874] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24875] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24876] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24877] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24878] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24879] = Expansions.Current >= Expansions.Cata, -- Removed with cata
        [24880] = Expansions.Current >= Expansions.Cata, -- Removed with cata

        -- First Pre-Event
        [25444] = true, -- Da Perfect Spies
        [25445] = true, -- Zalazane's Fall
        [25446] = true, -- Frogs Away!
        [25461] = true, -- Trollin' For Volunteers
        [25470] = true, -- Lady Of Da Tigers
        [25480] = true, -- Dance Of De Spirits
        [25495] = true, -- Preparin' For Battle

        -- Second Pre-event
        [25571] = true, -- A Natural Occurrence
        [25773] = true, -- A Natural Occurrence
        [27473] = true, -- What's Shaking in Ironforge
        [27546] = true, -- Speak with Captain Anton
        [27566] = true, -- A Gathering in Outland
        [27572] = true, -- A Gathering in Outland
        [25180] = true, -- Tablets of the Earth
        [25181] = true, -- Tablets of Fire
        [26054] = true, -- Water They Up To?
        [26990] = true, -- Water They Up To?
        [27137] = true, -- Earth Girls Aren't So Easy
        [27138] = true, -- Earth Girls Aren't So Easy
        [27122] = true, -- Fired Up and Not So Good To Go.
        [27127] = true, -- Fired Up and Not So Good To Go.
        [27207] = true, -- This Blows
        [27209] = true, -- This Blows

        -- Phase 2 - Rise of the Zandalari

        --[11196] = true, -- Warlord of the Amani
        --[29100] = true, -- Bwemba's Spirit
        --[29102] = true, -- To Fort Livingston
        --[29103] = true, -- Serpents and Poison
        --[29104] = true, -- Spirits Are With Us
        --[29153] = true, -- Booty Bay's Interests
        --[29154] = true, -- Booty Bay's Interests
        --[29155] = true, -- A Shiny Reward
        --[29156] = true, -- The Troll Incursion
        --[29157] = true, -- The Zandalari Menace
        [29158] = true, -- The Zandalar Representative
        [29168] = true, -- Secondary Targets
        [29169] = true, -- The Beasts Within
        --[29172] = true, -- The Beasts Within
        --[29173] = true, -- Secondary Targets
        [29174] = true, -- Break Their Spirits
        --[29175] = true, -- Break Their Spirits
        --[29186] = true, -- The Hex Lord's Fetish
        --[29208] = true, -- An Old Friend
        --[29217] = true, -- The Captive Scouts
        --[29219] = true, -- Bwemba's Spirit
        --[29220] = true, -- To Bambala
        --[29229] = true, -- Follow That Cat
        --[29241] = true, -- Break the Godbreaker
        --[29242] = true, -- Putting a Price on Priceless
        --[29251] = true, -- Booty Bay's Interests
        --[29252] = true, -- Booty Bay's Interests
        --[29261] = true, -- Zul'Aman Voodoo
        --[29262] = true, -- Zul'Gurub Voodoo

        -- Phase 3 - Rage of the Firelands

        -- [29129] = true, -- A Legendary Engagement
        -- [29132] = true, -- A Legendary Engagement
        --[29202] = true, -- The Fate of Runetotem
        [29204] = true, -- The Warden's Charge
        [29209] = true, -- Into the Fiery Depths
        [29244] = true, -- A Lieutenant of Flame
        --[29263] = true, -- A Bitter Pill
        --[29280] = true, -- Nourishing Waters
        --[29282] = true, -- Well Armed
        --[29284] = true, -- Aid of the Ancients
        [29289] = true, -- Mother's Malice
        --[29326] = true, -- The Nordrassil Summit
        --[29387] = true, -- Guardians of Hyjal: Firelands Invasion!
        --[29388] = true, -- Guardians of Hyjal: Firelands Invasion!
        --[29389] = true, -- Guardians of Hyjal: Firelands Invasion!
        --[29390] = true, -- Guardians of Hyjal: Call of the Ancients
        --[29391] = true, -- Guardians of Hyjal: Call of the Ancients
        --[29437] = true, -- The Fallen Guardian
        --[29439] = true, -- The Call of the World-Shaman
        --[29440] = true, -- The Call of the World-Shaman
        --[29452] = true, -- Your Time Has Come
        --[29453] = true, -- Your Time Has Come
        --[30094] = true, -- The End Time
        --[30095] = true, -- The End Time

        -- Phase 4 - Hour of Twilight
        --[29801] = true, -- Proving Your Worth

        -- Darkmoon Faire
        --[27664] = true, -- Darkmoon Volcanic Deck
        --[27665] = true, -- Darkmoon Hurricane Deck
        --[27666] = true, -- Darkmoon Tsunami Deck
        --[27667] = true, -- Darkmoon Earthquake Deck
        --[29433] = true, -- Test Your Strength
        --[29434] = true, -- Tonk Commander
        --[29436] = true, -- The Humanoid Cannonball
        --[29438] = true, -- He Shoots, He Scores!
        --[29443] = true, -- A Curious Crystal
        --[29444] = true, -- An Exotic Egg
        --[29445] = true, -- An Intriguing Grimoire
        --[29446] = true, -- A Wondrous Weapon
        --[29451] = true, -- The Master Strategist
        --[29455] = true, -- Target: Turtle
        --[29456] = true, -- A Captured Banner
        --[29457] = true, -- The Enemy's Insignia
        --[29458] = true, -- The Captured Journal
        --[29463] = true, -- It's Hammer Time
        --[29464] = true, -- Tools of Divination
        --[29506] = true, -- A Fizzy Fusion
        --[29507] = true, -- Fun for the Little Ones
        --[29508] = true, -- Baby Needs Two Pair of Shoes
        --[29509] = true, -- Putting the Crunch in the Frog
        --[29510] = true, -- Putting Trash to Good Use
        --[29511] = true, -- Talkin' Tonks
        --[29512] = true, -- Putting the Carnies Back Together Again
        --[29513] = true, -- Spoilin' for Salty Sea Dogs
        --[29514] = true, -- Herbs for Healing
        --[29515] = true, -- Writing the Future
        --[29516] = true, -- Keeping the Faire Sparkling
        --[29517] = true, -- Eyes on the Prizes
        --[29518] = true, -- Rearm, Reuse, Recycle
        --[29519] = true, -- Tan My Hide
        --[29520] = true, -- Banners, Banners Everywhere!
        --[29601] = true, -- The Darkmoon Field Guide
        --[29760] = true, -- Pit Fighter
        --[29761] = true, -- Master Pit Fighter

        -- Love is in the Air
        [14483] = true, -- Something is in the Air (and it Ain't Love)
        [24745] = true, -- Something is in the Air (and it Ain't Love)
        [28935] = true, -- Crushing the Crown

        -- Day of the Dead
        [13952] = true, -- The Grateful Dead
        [14166] = true, -- The Grateful Dead
        [14167] = true, -- The Grateful Dead
        [14168] = true, -- The Grateful Dead
        [14169] = true, -- The Grateful Dead
        [14170] = true, -- The Grateful Dead
        [14171] = true, -- The Grateful Dead
        [14172] = true, -- The Grateful Dead
        [14173] = true, -- The Grateful Dead
        [14174] = true, -- The Grateful Dead
        [14175] = true, -- The Grateful Dead
        [14176] = true, -- The Grateful Dead
        [14177] = true, -- The Grateful Dead
        [27841] = true, -- The Grateful Dead
        [27846] = true, -- The Grateful Dead

        -- Children's Week
        [28879] = true, -- Back To The Orphanage
        [28880] = true, -- Back To The Orphanage
        [29093] = true, -- Cruisin' the Chasm
        [29106] = true, -- The Biggest Diamond Ever!
        [29107] = true, -- Malfurion Has Returned!
        [29117] = true, -- Let's Go Fly a Kite
        [29119] = true, -- You Scream, I Scream...
        [29146] = true, -- Ridin' the Rocketway
        [29167] = true, -- The Banshee Queen
        [29176] = true, -- The Fallen Chieftain
        [29190] = true, -- Let's Go Fly a Kite
        [29191] = true, -- You Scream, I Scream...

        -- Midsummer
        [28910] = true, -- Desecrate this Fire!
        [28911] = true, -- Desecrate this Fire!
        [28912] = true, -- Desecrate this Fire!
        [28913] = true, -- Desecrate this Fire!
        [28914] = true, -- Desecrate this Fire!
        [28915] = true, -- Desecrate this Fire!
        [28916] = true, -- Desecrate this Fire!
        [28917] = true, -- Desecrate this Fire!
        [28918] = true, -- Desecrate this Fire!
        [28919] = true, -- Desecrate this Fire!
        [28920] = true, -- Desecrate this Fire!
        [28921] = true, -- Desecrate this Fire!
        [28922] = true, -- Honor the Flame
        [28923] = true, -- Honor the Flame
        [28924] = true, -- Honor the Flame
        [28925] = true, -- Honor the Flame
        [28926] = true, -- Honor the Flame
        [28927] = true, -- Honor the Flame
        [28928] = true, -- Honor the Flame
        [28929] = true, -- Honor the Flame
        [28930] = true, -- Honor the Flame
        [28931] = true, -- Honor the Flame
        [28932] = true, -- Honor the Flame
        [28933] = true, -- Honor the Flame
        [28943] = true, -- Desecrate this Fire!
        [28944] = true, -- Desecrate this Fire!
        [28945] = true, -- Honor the Flame
        [28946] = true, -- Honor the Flame
        [28947] = true, -- Desecrate this Fire!
        [28948] = true, -- Desecrate this Fire!
        [28949] = true, -- Honor the Flame
        [28950] = true, -- Honor the Flame
        [29030] = true, -- Honor the Flame
        [29031] = true, -- Honor the Flame
        [29036] = true, -- Honor the Flame
        [29092] = true, -- Inform the Elder

        -- Hallow's End
        [28934] = true, -- Candy Bucket
        [28951] = true, -- Candy Bucket
        [28952] = true, -- Candy Bucket
        [28953] = true, -- Candy Bucket
        [28954] = true, -- Candy Bucket
        [28955] = true, -- Candy Bucket
        [28956] = true, -- Candy Bucket
        [28957] = true, -- Candy Bucket
        [28958] = true, -- Candy Bucket
        [28959] = true, -- Candy Bucket
        [28960] = true, -- Candy Bucket
        [28961] = true, -- Candy Bucket
        [28962] = true, -- Candy Bucket
        [28963] = true, -- Candy Bucket
        [28964] = true, -- Candy Bucket
        [28965] = true, -- Candy Bucket
        [28966] = true, -- Candy Bucket
        [28967] = true, -- Candy Bucket
        [28968] = true, -- Candy Bucket
        [28969] = true, -- Candy Bucket
        [28970] = true, -- Candy Bucket
        [28971] = true, -- Candy Bucket
        [28972] = true, -- Candy Bucket
        [28973] = true, -- Candy Bucket
        [28974] = true, -- Candy Bucket
        [28975] = true, -- Candy Bucket
        [28976] = true, -- Candy Bucket
        [28977] = true, -- Candy Bucket
        [28978] = true, -- Candy Bucket
        [28979] = true, -- Candy Bucket
        [28980] = true, -- Candy Bucket
        [28981] = true, -- Candy Bucket
        [28982] = true, -- Candy Bucket
        [28983] = true, -- Candy Bucket
        [28984] = true, -- Candy Bucket
        [28985] = true, -- Candy Bucket
        [28986] = true, -- Candy Bucket
        [28987] = true, -- Candy Bucket
        [28988] = true, -- Candy Bucket
        [28989] = true, -- Candy Bucket
        [28990] = true, -- Candy Bucket
        [28991] = true, -- Candy Bucket
        [28992] = true, -- Candy Bucket
        [28993] = true, -- Candy Bucket
        [28994] = true, -- Candy Bucket
        [28995] = true, -- Candy Bucket
        [28996] = true, -- Candy Bucket
        [28997] = true, -- Candy Bucket
        [28998] = true, -- Candy Bucket
        [28999] = true, -- Candy Bucket
        [29000] = true, -- Candy Bucket
        [29001] = true, -- Candy Bucket
        [29002] = true, -- Candy Bucket
        [29003] = true, -- Candy Bucket
        [29004] = true, -- Candy Bucket
        [29005] = true, -- Candy Bucket
        [29006] = true, -- Candy Bucket
        [29007] = true, -- Candy Bucket
        [29008] = true, -- Candy Bucket
        [29009] = true, -- Candy Bucket
        [29010] = true, -- Candy Bucket
        [29011] = true, -- Candy Bucket
        [29012] = true, -- Candy Bucket
        [29013] = true, -- Candy Bucket
        [29014] = true, -- Candy Bucket
        [29016] = true, -- Candy Bucket
        [29017] = true, -- Candy Bucket
        [29018] = true, -- Candy Bucket
        [29019] = true, -- Candy Bucket
        [29020] = true, -- Candy Bucket
        [29054] = true, -- Stink Bombs Away!
        [29074] = true, -- A Season for Celebration
        [29075] = true, -- A Time to Gain
        [29144] = true, -- Clean Up in Stormwind
        [29371] = true, -- A Time to Lose
        [29374] = true, -- Stink Bombs Away!
        [29375] = true, -- Clean Up in Undercity
        [29376] = true, -- A Time to Build Up
        [29377] = true, -- A Time to Break Down
        [29392] = true, -- Missing Heirlooms
        [29398] = true, -- Fencing the Goods
        [29399] = true, -- Shopping Around
        [29400] = true, -- A Season for Celebration
        [29402] = true, -- Taking Precautions
        [29403] = true, -- The Collector's Agent
        [29411] = true, -- What Now?
        [29415] = true, -- Missing Heirlooms
        [29416] = true, -- Fencing the Goods
        [29425] = true, -- Shopping Around
        [29426] = true, -- Taking Precautions
        [29427] = true, -- The Collector's Agent
        [29428] = true, -- What Now?
        [29430] = true, -- A Friend in Need
        [29431] = true, -- A Friend in Need

        -- Winter's Veil
        [13966] = true, -- A Winter Veil Gift
        [29382] = true, -- Thanks, But No Thanks
        [29383] = true, -- Thanks, But No Thanks
        [29385] = true, -- A Winter Veil Gift
        [28878] = true, -- A Winter Veil Gift

        -- Brewfest
        [11413] = true, -- Did Someone Say "Souvenir?"
        [29393] = true, -- Brew For Brewfest
        [29394] = true, -- Brew For Brewfest
        [29396] = true, -- A New Supplier of Souvenirs
        [29397] = true, -- A New Supplier of Souvenirs

        -- Lunar Festival
        [29734] = true, -- Deepforge the Elder
        [29735] = true, -- Stonebrand the Elder
        [29736] = true, -- Darkfeather the Elder
        [29737] = true, -- Firebeard the Elder
        [29738] = true, -- Moonlance the Elder
        [29739] = true, -- Windsong the Elder
        [29740] = true, -- Evershade the Elder
        [29741] = true, -- Sekhemi the Elder
        [29742] = true, -- Menkhaf the Elder

        [82948] = true, -- Boosted quest
        [82949] = true, -- Boosted quest
        [82983] = true, -- Boosted quest
        [82985] = true, -- Boosted quest
        [82989] = true, -- Boosted quest

        [88776] = true, -- Boosted quest
        [88777] = true, -- Boosted quest
        [88778] = true, -- Boosted quest
        [88779] = true, -- Boosted quest
        [88780] = true, -- Boosted quest
        [88781] = true, -- Boosted quest
        [88782] = true, -- Boosted quest
        [88783] = true, -- Boosted quest
        [88784] = true, -- Boosted quest
        [88785] = true, -- Boosted quest
        [88786] = true, -- Boosted quest
        [88787] = true, -- Boosted quest
        [88788] = true, -- Boosted quest
        [88789] = true, -- Boosted quest
        [88790] = true, -- Boosted quest
        [88793] = true, -- Boosted quest
        [88794] = true, -- Boosted quest
        [88796] = true, -- Boosted quest
        [88797] = true, -- Boosted quest
        [88798] = true, -- Boosted quest
        [88800] = true, -- Boosted quest
        [88801] = true, -- Boosted quest

        ----- MoP -------------- MoP quests --------------- MoP -----
        ----- MoP ------------- starting here -------------- MoP -----
        [9754] = true, -- Not in the game
        [9755] = true, -- Not in the game
        [10215] = true, -- Not in the game
        [11522] = true, -- Not in the game
        [12445] = true, -- Not in the game
        [12731] = true, -- Not in the game
        [13541] = true, -- Not in the game
        [29547] = true, -- Not available in prepatch. Remove once MoP hits
        [29611] = true, -- Not available in prepatch. Remove once MoP hits
        [29612] = true, -- Not available in prepatch. Remove once MoP hits
        [31533] = true, -- The Perfect Feather (not in the game)
        [31887] = true, -- Pet Battle Trainers: Kalimdor
        [31888] = true, -- Pet Battle Trainers: Kalimdor
        [31890] = true, -- Pet Battle Trainers: Kalimdor
        [31892] = true, -- Battle Pet Trainers: Kalimdor
        [31893] = true, -- Battle Pet Trainers: Kalimdor
        [31940] = true, -- Battle Pet Trainers: Pandaria
        [31489] = true, -- Stranger in a Strange Land (Rogue only version of 31488. For those who know Wrathion already from the Fangs quest chain)
        [31554] = true, -- On The Mend (duplicate of 31553)
        [31979] = true, -- The Returning Champion (invalid version of 31975, 31976)
        [32442] = true, -- Deprecated - Reuse Me! (invalid version of 32428)
        [32482] = true, -- Test Your Chicken Guardian [PH]
        [33121] = true, -- DEPRECATED The Celestial Tournament
        [33122] = true, -- DEPRECATED Great Job, You Won

        -- Hallow's End
        [32020] = true,
        [32021] = true,
        [32022] = true,
        [32023] = true,
        [32024] = true,
        [32026] = true,
        [32027] = true,
        [32028] = true,
        [32029] = true,
        [32031] = true,
        [32032] = true,
        [32033] = true,
        [32034] = true,
        [32036] = true,
        [32037] = true,
        [32039] = true,
        [32040] = true,
        [32041] = true,
        [32042] = true,
        [32043] = true,
        [32044] = true,
        [32046] = true,
        [32047] = true,
        [32048] = true,
        [32049] = true,
        [32050] = true,
        [32051] = true,
        [32052] = true,

        ----- SoD -------------- SoD quests --------------- SoD -----
        [78287] = true, -- Let Me Make You An Offer (not longer in the game)
        [78288] = true, -- Let Me Make You An Offer (not longer in the game)
        [78297] = true, -- You've Got Yourself A Deal (not longer in the game)
        [78304] = true, -- You've Got Yourself A Deal (not longer in the game)
        [78611] = true, -- A Waylaid Shipment (no longer available in P2)
        [79100] = true, -- A Waylaid Shipment (no longer available in P2)
        [78924] = true, -- In Search of Thaelrid (no longer available)
        [79482] = true, -- Stolen Winter Veil Treats
        [79483] = true, -- Stolen Winter Veil Treats
        [79484] = true, -- You're a Mean One...
        [79485] = true, -- You're a Mean One...
        [79486] = true, -- A Smokywood Pastures' Thank You!
        [79487] = true, -- A Smokywood Pastures' Thank You!
        [79492] = true, -- Metzen the Reindeer
        [79495] = true, -- Metzen the Reindeer

        [80164] = true, -- Large Cluster Rockets
        [80165] = true, -- Cluster Rockets
        [80166] = true, -- Small Rockets
        [80167] = true, -- Large Rockets
        [80168] = true, -- Firework Launcher
        [80169] = true, -- Cluster Launcher
        [80170] = true, -- Festive Recipes

        [79588] = true, -- Small Furry Paws
        [79589] = true, -- Torn Bear Pelts
        [79590] = true, -- Heavy Grinding Stone
        [79591] = true, -- Whirring Bronze Gizmo
        [79592] = true, -- Carnival Jerkins
        [79593] = true, -- Coarse Weightstone
        [79594] = true, -- Copper Modulator
        [79595] = true, -- Carnival Boots
        [80417] = true, -- Soft Bushy Tails
        [80421] = true, -- Green Iron Bracers
        [80422] = true, -- Green Fireworks
        [80423] = true, -- The World's Largest Gnome!
        [82323] = true, -- Vibrant Plumes
        [82271] = true, -- More Glowing Scorpid Blood
        [82272] = true, -- Glowing Scorpid Blood
        [82273] = true, -- More Evil Bat Eyes
        [82274] = true, -- Evil Bat Eyes
        [82275] = true, -- Big Black Mace
        [82276] = true, -- Rituals of Strength
        [82277] = true, -- More Dense Grinding Stones
        [82278] = true, -- More Thorium Widgets
        [82279] = true, -- Thorium Widget
        [82280] = true, -- Mechanical Repair Kits
        [82281] = true, -- More Armor Kits
        [82282] = true, -- Armor Kits
        [82283] = true, -- Crocolisk Boy and the Bearded Murloc

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

    if Questie.IsSoD then
        Questie:Debug(Questie.DEBUG_DEVELOP, "Blacklisting quests for SoD...")
        questsToBlacklist = ContentPhases.BlacklistSoDQuestsByPhase(questsToBlacklist, ContentPhases.activePhases.SoD)
    elseif Questie.IsAnniversary or Questie.IsAnniversaryHardcore then
        Questie:Debug(Questie.DEBUG_DEVELOP, "Blacklisting quests for Anniversary...")
        questsToBlacklist = ContentPhases.BlacklistAnniversaryQuestsByPhase(questsToBlacklist, ContentPhases.activePhases.Anniversary)
    elseif Questie.IsSoM then
        Questie:Debug(Questie.DEBUG_DEVELOP, "Blacklisting quests for SoM...")
        questsToBlacklist = ContentPhases.BlacklistSoMQuestsByPhase(questsToBlacklist, ContentPhases.activePhases.SoM)
    elseif Questie.IsMoP then
        Questie:Debug(Questie.DEBUG_DEVELOP, "Blacklisting quests for MoP...")
        questsToBlacklist = ContentPhases.BlacklistMoPQuestsByPhase(questsToBlacklist, ContentPhases.activePhases.MoP)
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
        [10520] = Expansions.Current >= Expansions.Wotlk, --*Assisting Arch Druid Staghelm (https://www.wowhead.com/wotlk/quest=10520) not present anymore in wotlk

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

return QuestieQuestBlacklist
