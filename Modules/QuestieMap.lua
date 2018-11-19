QuestieMap = {...}

Map = {}
Map[0] = {}
Map[1] = {}
--Eastern Kindoms
	Map[0][14] = "Eastern Kingdoms"
	Map[0][614] = "Abyssal Depths"
	Map[0][16] = "Arathi Highlands"
	Map[0][17] = "Badlands"
	Map[0][19] = "Blasted Lands"
	Map[0][29] = "Burning Steppes"
	Map[0][866] = "Coldridge Valley"
	Map[0][32] = "Deadwind Pass"
	Map[0][892] = "Deathknell"
	Map[0][27] = "Dun Morogh"
	Map[0][34] = "Duskwood"
	Map[0][23] = "Eastern Plaguelands"
	Map[0][30] = "Elwynn Forest"
	Map[0][462] = "Eversong Woods"
	Map[0][463] = "Ghostlands"
	Map[0][545] = "Gilneas"
	Map[0][611] = "Gilneas City"
	Map[0][24] = "Hillsbrad Foothills"
	Map[0][341] = "Ironforge"
	Map[0][499] = "Isle of Quel'Danas"
	Map[0][610] = "Kelp'thar Forest"
	Map[0][35] = "Loch Modan"
	Map[0][895] = "New Tinkertown"
	Map[0][37] = "Northern Stranglethorn"
	Map[0][864] = "Northshire"
	Map[0][36] = "Redridge Mountains"
	Map[0][684] = "Ruins of Gilneas"
	Map[0][685] = "Ruins of Gilneas City"
	Map[0][28] = "Searing Gorge"
	Map[0][615] = "Shimmering Expanse"
	Map[0][480] = "Silvermoon City"
	Map[0][21] = "Silverpine Forest"
	Map[0][301] = "Stormwind City"
	Map[0][689] = "Stranglethorn Vale"
	Map[0][893] = "Sunstrider Isle"
	Map[0][38] = "Swamp of Sorrows"
	Map[0][673] = "The Cape of Stranglethorn"
	Map[0][26] = "The Hinterlands"
	Map[0][502] = "The Scarlet Enclave"
	Map[0][20] = "Tirisfal Glades"
	Map[0][708] = "Tol Barad"
	Map[0][709] = "Tol Barad Peninsula"
	Map[0][700] = "Twilight Highlands"
	Map[0][382] = "Undercity"
	Map[0][613] = "Vashj'ir"
	Map[0][22] = "Western Plaguelands"
	Map[0][39] = "Westfall"
	Map[0][40] = "Wetlands"

--Kalimdor
	Map[1][13] = "Kalimdor"
	Map[1][772] = "Ahn'Qiraj: The Fallen Kingdom"
	Map[1][894] = "Ammen Vale"
	Map[1][43] = "Ashenvale"
	Map[1][181] = "Azshara"
	Map[1][464] = "Azuremyst Isle"
	Map[1][476] = "Bloodmyst Isle"
	Map[1][890] = "Camp Narache"
	Map[1][42] = "Darkshore"
	Map[1][381] = "Darnassus"
	Map[1][101] = "Desolace"
	Map[1][4] = "Durotar"
	Map[1][141] = "Dustwallow Marsh"
	Map[1][891] = "Echo Isles"
	Map[1][182] = "Felwood"
	Map[1][121] = "Feralas"
	Map[1][795] = "Molten Front"
	Map[1][241] = "Moonglade"
	Map[1][606] = "Mount Hyjal"
	Map[1][9] = "Mulgore"
	Map[1][11] = "Northern Barrens"
	Map[1][321] = "Orgrimmar"
	Map[1][888] = "Shadowglen"
	Map[1][261] = "Silithus"
	Map[1][607] = "Southern Barrens"
	Map[1][81] = "Stonetalon Mountains"
	Map[1][161] = "Tanaris"
	Map[1][41] = "Teldrassil"
	Map[1][471] = "The Exodar"
	Map[1][61] = "Thousand Needles"
	Map[1][362] = "Thunder Bluff"
	Map[1][720] = "Uldum"
	Map[1][201] = "Un'Goro Crater"
	Map[1][889] = "Valley of Trials"
	Map[1][281] = "Winterspring"

--Old Questie data (Vanilla map ids)
QuestieZones = {
    ["WorldMap"] = {1337, 1337, 0, 0}, --
    ["Azeroth"] = {-1, -1, -1, 2, 0}, --
    ["Kalimdor"] = {-1, -1, -1, 1, 0}, --
    ["Hinterlands"] = {42, 2, 24, 2, 20}, -- -- I found the code questhelper used, didnt do enough searching D:
    ["Moonglade"] = {20, 1, 12, 1, 10}, --
    ["ThousandNeedles"] = {14, 1, 21, 1, 18}, --
    ["Winterspring"] = {19, 1, 24, 1, 21}, --
    ["BloodmystIsle"] = {9, 1, 4, -1, -1},--
    ["TerokkarForest"] = {55, 3, 7, -1, -1},--
    ["Arathi"] = {39, 2, 2, 2, 2},--
    ["EversongWoods"] = {41, 2, 11, -1, -1}, --
    ["Dustwallow"] = {10, 1, 9, 1, 7},--
    ["Badlands"] = {27, 2, 3, 2, 3}, --
    ["Darkshore"] = {16, 1, 5, 1, 3},--
    ["Orgrimmar"] = {1, 1, 14, 1, 12},--
    ["BladesEdgeMountains"] = {54, 3, 1, -1, -1},
    ["Undercity"] = {45, 2, 26, 2, 22},
    ["Desolace"] = {4, 1, 7, 1, 5},
    ["Netherstorm"] = {59, 3, 4, -1, -1},
    ["Barrens"] = {11, 1, 19, 1, 17},
    ["Tanaris"] = {8, 1, 17, 1, 15},
    ["Stormwind"] = {36, 2, 21, 2, 17},--
    ["Zangarmarsh"] = {57, 3, 8, -1, -1},
    ["Durotar"] = {7, 1, 8, 1, 6},--
    ["Hellfire"] = {56, 3, 2, -1, -1},
    ["Silithus"] = {5, 1, 15, 1, 13},
    ["ShattrathCity"] = {60, 3, 6, -1, -1},
    ["ShadowmoonValley"] = {53, 3, 5, -1, -1},
    ["SwampOfSorrows"] = {46, 2, 23, 2, 19},
    ["SilvermoonCity"] = {52, 2, 19, -1, -1},
    ["Darnassis"] = {21, 1, 6, 1, 4},
    ["AzuremystIsle"] = {3, 1, 3, -1, -1},
    ["Elwynn"] = {37, 2, 10, 2, 10},--
    ["Stranglethorn"] = {38, 2, 22, 2, 18},
    ["EasternPlaguelands"] = {34, 2, 9, 2, 9},
    ["Duskwood"] = {31, 2, 8, 2, 8},
    ["WesternPlaguelands"] = {50, 2, 27, 2, 23},
    ["Westfall"] = {49, 2, 28, 2, 24},
    ["Ashenvale"] = {2, 1, 1, 1, 1},
    ["Teldrassil"] = {24, 1, 18, 1, 16},
    ["Redridge"] = {30, 2, 17, 2, 14},
    ["UngoroCrater"] = {18, 1, 23, 1, 20},
    ["Mulgore"] = {22, 1, 13, 1, 11},
    ["Ironforge"] = {25, 2, 14, 2, 12},
    ["Felwood"] = {13, 1, 10, 1, 8},
    ["Hilsbrad"] = {48, 2, 13, 2, 11},
    ["DeadwindPass"] = {47, 2, 6, 2, 6},
    ["BurningSteppes"] = {40, 2, 5, 2, 5},
    ["Ghostlands"] = {44, 2, 12, -1, -1},
    ["Tirisfal"] = {43, 2, 25, 2, 21},
    ["TheExodar"] = {12, 1, 20, -1, -1},
    ["Wetlands"] = {51, 2, 29, 2, 25},
    ["SearingGorge"] = {32, 2, 18, 2, 15},
    ["BlastedLands"] = {33, 2, 4, 2, 4},
    ["Silverpine"] = {35, 2, 20, 2, 16},
    ["LochModan"] = {29, 2, 16, 2, 13},
    ["Feralas"] = {17, 1, 11, 1, 9},
    ["DunMorogh"] = {28, 2, 7, 2, 7},
    ["Alterac"] = {26, 2, 1, 2, 1},
    ["ThunderBluff"] = {23, 1, 22, 1, 19},
    ["Aszhara"] = {15, 1, 2, 1, 2},
    ["StonetalonMountains"] = {6, 1, 16, 1, 14},
    ["Nagrand"] = {58, 3, 3, -1, -1},
    ["Kalimdor"] = {61, 1, 0, 1, 0},
    ["Azeroth"] = {62, 2, 0, 2, 0},
    ["Expansion01"] = {63, 3, 0, -1, -1},
    ["Sunwell"] = {64, 2, 15, -1, -1} -- code copied from questhelper (this is actually the only code that was directly copied, the database was put through JavaRefactorProject
}



function QuestieMap:GetVanillaMapIDFromRetail(Zoneid)
  --Need to manually fix the names above to match.
  return 28 --DunMorogh
end

function QuestieMap:GetRetailMapIDFromVanilla(Zoneid)
  --Need to manually fix the names above to match.
  return 27 --DunMorogh
end

function GetWorldContinentFromZone(ZoneID)
  if(Map[0][ZoneID] ~= nil)then
    return 0
  elseif(Map[1][ZoneID] ~= nil)then
    return 1
  end
end
