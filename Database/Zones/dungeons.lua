---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

---@alias DungeonZoneEntry
---@field [1] string name
---@field [2] AreaId? alternativeAreaId
---@field [3] AreaId parentZone
---@field [4] table<AreaId, AreaCoordinate> dungeonLocations

---@type table<AreaId, DungeonZoneEntry>
local dungeons = {
    [206] = {"Utgarde Keep",nil,495,{{495, 58.8, 48.3}}},
    [209] = {"Shadowfang Keep",236,130,{{130, 44.8, 67.8}}},
    [491] = {"Razorfen Kraul",1717,17,{{17, 42.3, 89.9}}},
    [717] = {"The Stockade",nil,1519,{{1519, 40.5, 55.9}}},
    [718] = {"Wailing Caverns",nil,17,{{17, 46, 36.5}}},
    [719] = {"Blackfathom Deeps",2797,331,{{331, 14.5, 14.2}}},
    [721] = {"Gnomeregan",133,1,{{1, 24.4, 39.8}}},
    [722] = {"Razorfen Downs",1316,17,{{17, 50.8, 92.8}}},
    [796] = {"Scarlet Monastery",nil,85,{{85, 82.6, 33.8}}},
    [1176] = {"Zul'Farrak",978,440,{{440, 38.7, 20.1}}},
    [1196] = {"Utgarde Pinnacle",nil,495,{{495, 57.3, 46.8}}},
    [1337] = {"Uldaman",1517,3,{{3, 44.4, 12.2},{3, 65.2, 43.5}}},
    [1477] = {"The Temple of Atal'Hakkar",1417,8,{{8, 69.9, 53.5}}},
    [1581] = {"The Deadmines",nil,40,{{40, 42.5, 71.7}}},
    [1583] = {"Blackrock Spire",nil,51,{{51, 34.8, 85.3}, {46, 29.4, 38.3}}},
    [1584] = {"Blackrock Depths",1585,51,{{51, 34.8, 85.3},{46, 29.4, 38.3}}},
    [1977] = {"Zul'Gurub",nil,33,{{33, 53.8, 17.5}}},
    [2017] = {"Stratholme",2279,139,{{139, 31.3, 15.7}, {139, 47.9, 24.0}}},
    [2057] = {"Scholomance",nil,28,{{28, 69.7, 73.2}}},
    [2100] = {"Maraudon",nil,405,{{405, 29.1, 62.5}}},
    [2159] = {"Onyxia's Lair",nil,15,{{15, 52.6, 76.8}}},
    [2257] = {"Deeprun Tramp",nil,1519,{{1519, 67.6, 4.1}, {1537, 84.1, 53.1}}},
    [2366] = {"The Black Morass",nil,440,{{440, 65.7, 49.8}}},
    [2367] = {"Old Hillsbrad Foothills",nil,440,{{440, 65.7, 49.8}}},
    [2437] = {"Ragefire Chasm",nil,1637,{{1637, 51.7, 49.8}}},
    [2557] = {"Dire Maul",2577,357,{{357, 59.2, 45.1}}},
    [2597] = {"Alterac Valley",nil,36,{{36, 66.6, 51.3},}},
    [2677] = {"Blackwing Lair",nil,46,{{51, 34.8, 85.3}, {46, 29.4, 38.3}}},
    [2717] = {"Molten Core",nil,46,{{51, 34.8, 85.3}, {46, 29.4, 38.3}}},
    [2917] = {"Hall of Legends",nil,1637,{{1637, 40.4, 68.3}}},
    [2918] = {"Champions' Hall",nil,1519,{{1519, 72.7, 54}}},
    [3428] = {"Temple of Ahn'Qiraj",nil,1377,{{1377, 28.6, 92.3}}},
    [3429] = {"Ruins of Ahn'Qiraj",nil,1377,{{1377, 28.6, 92.3}}},
    [3456] = {"Naxxramas",nil,65,{{139, 39.9, 25.8}}},
    [3457] = {"Karazhan",nil,41,{{41, 46.7, 70.2},{41, 46.9, 74.7}}},
    [3562] = {"Hellfire Ramparts",nil,3483,{{3483, 47.7, 53.6}}},
    [3606] = {"Hyjal Summit",nil,440,{{440, 65.7, 49.8}}},
    [3607] = {"Serpentshire Cavern",nil,3521,{{3521, 50.4, 40.9}}},
    [3713] = {"The Blood Furnace",nil,3483,{{3483, 46.0, 51.8}}},
    [3714] = {"The Shattered Halls",3535,3483,{{3483, 47.7, 52.0}}},
    [3715] = {"The Steamvault",nil,3521,{{3521, 50.4, 40.9}}},
    [3716] = {"The Underbog",nil,3521,{{3521, 50.4, 40.9}}},
    [3717] = {"The Slave Pens",nil,3521,{{3521, 50.4, 40.9}}},
    [3789] = {"Shadow Labyrinth",nil,3519,{{3519, 39.6, 71.0}}},
    [3790] = {"Auchenai Crypts",nil,3519,{{3519, 36.1, 65.6}}},
    [3791] = {"Sethekk Halls",nil,3519,{{3519, 43.2, 65.6}}},
    [3792] = {"Mana-Tombs",nil,3519,{{3519, 39.7, 60.2}}},
    [3805] = {"Zul'Aman",nil,3433,{{3433, 82.25, 64.3}}},
    [3836] = {"Magtheridon's Lair",nil,3483,{{3483, 46.6, 52.81}}},
    [3845] = {"Tempest Keep",nil,3523,{{3523, 73.7, 63.7}}},
    [3847] = {"The Botanica",nil,3523,{{3523, 71.7, 55.0}}},
    [3848] = {"The Arcatraz",nil,3523,{{3523, 74.4, 57.7}}},
    [3849] = {"The Mechanar",nil,3523,{{3523, 70.6, 69.7}}},
    [3923] = {"Gruul's Lair",nil,3522,{{3522, 68.7, 24.3}}},
    [3959] = {"Black Temple",nil,3520,{{3520, 71.1, 46.3}}},
    [4075] = {"Sunwell Plateau",nil,4080,{{4080, 44.3, 45.5}}},
    [4100] = {"The Culling of Stratholme",nil,440,{{440, 65.7, 49.8}}},
    [4131] = {"Magisters' Terrace",nil,4080,{{4080, 61.2, 30.9}}},
    [4196] = {"Drak'Tharon Keep",nil,66,{{66, 29.0, 83.9},{394, 17.5, 27.0}}},
    [4265] = {"The Nexus",nil,3537,{{3537, 27.6, 26.6}}},
    [4228] = {"The Oculus",nil,3537,{{3537, 27.6, 26.6}}},
    [4264] = {"Halls of Stone",nil,67,{{67, 39.6, 26.9}}},
    [4272] = {"Halls of Lightning",nil,67,{{67, 45.4, 21.4}}},
    [4273] = {"Ulduar",nil,67,{{67, 41.6, 17.8}}},
    [4277] = {"Azjol-Nerub",nil,65,{{65, 26.2, 49.6}}},
    [4415] = {"The Violet Hold",nil,4395,{{4395, 66.8, 68.2}}},
    [4416] = {"Gundrak",nil,66,{{66, 76.2, 21.1},{66, 81.2, 28.9}}},
    [4493] = {"The Obsidian Sanctum",nil,65,{{65, 59.6, 51.1}}},
    [4494] = {"Ahn'kahet: The Old Kingdom",nil,65,{{65, 26.2, 49.6}}},
    [4500] = {"The Eye of Eternity",nil,3537,{{3537, 27.6, 26.6}}},
    [4603] = {"Vault of Archavon",nil,4197,{{4197, 50.5, 16.4}}},
    [4722] = {"Trial of the Crusader",nil,210,{{210, 75.1, 21.8}}},
    [4723] = {"Trial of the Champion",nil,210,{{210, 74.2, 20.5}}},
    [4809] = {"The Forge of Souls",nil,210,{{210, 52.6, 89.4}}},
    [4812] = {"Icecrown Citadel",nil,210,{{210, 53.3, 85.5}}},
    [4813] = {"Pit of Saron",nil,210,{{210, 52.6, 89.4}}},
    [4820] = {"Halls of Reflection",nil,210,{{210, 52.6, 89.4}}},
    [4926] = {"Blackrock Caverns",nil,51,{{51, 34.9, 83.9}, {46, 21, 37.9}}},
    [4950] = {"Grim Batol",nil,4922,{{4922, 19.2, 54.0}}},
    [4945] = {"Halls of Origination",nil,5034,{{5034, 71.6, 52.2}}},
    [4987] = {"The Ruby Sanctum",nil,65,{{65, 59.6, 51.1}}},
    [5004] = {"Throne of the Tides",nil,5146,{{5145, 70.8, 29.0}}},
    [5035] = {"The Vortex Pinnacle",nil,5034,{{5034, 76.7, 84.4}}},
    [5088] = {"The Stonecore",nil,5042,{{5042, 47.6, 52.0}}},
    [5094] = {"Blackwing Descent",nil,46,{{46, 23.0, 26.6}}},
    [5334] = {"The Bastion of Twilight",nil,4922,{{4922, 34.0, 78.0}}},
    [5396] = {"Lost City of the Tol'vir",nil,5034,{{5034, 60.5, 64.2}}},
    [5600] = {"Baradin Hold",nil,5095,{{5095, 46.3, 47.9}}},
    [5638] = {"Throne of the Four Winds",nil,5034,{{5034, 38.4, 80.6}}},
    [5723] = {"Firelands",nil,616,{{616, 47.3, 78.0}}},
    [5788] = {"Well of Eternity",nil,440,{{440, 64.8, 50}}},
    [5789] = {"End Time",nil,440,{{440, 64.8, 50}}},
    [5844] = {"Hour of Twilight",nil,440,{{440, 64.8, 50}}},
    [5861] = {"Darkmoon Faire Island",nil,440,{{12, 41.79, 69.52},{215, 36.85, 35.86}}},
    [5892] = {"Dragon Soul",nil,440,{{440, 64.8, 50}}},
    [7307] = {"Upper Blackrock Spire",nil,51,{{51, 34.8, 85.3}, {46, 29.4, 38.3}}},
    [15475] = {"Demon Fall Canyon",nil,331,{{331, 84.7, 74.4}}},
    [15531] = {"The Tainted Scar",nil,4,{{4, 45.3,55.0}}},
}

if Questie.IsCata then
    dungeons[491][3] = 4709 -- Utgarde Keep
    dungeons[491][4] = {{4709, 41, 94.6}} -- Utgarde Keep
    dungeons[717][4] = {{1519, 52.4, 70}} -- The Stockade
    dungeons[718][4] = {{17, 38.9, 69.1}} -- Wailing Caverns
    dungeons[719][4] = {{331, 14.2, 13.9}} -- Blackfathom Deeps
    dungeons[721][4] = {{1, 31.1, 37.9}} -- Gnomeregan
    dungeons[722][3] = 400 -- Razorfen Downs
    dungeons[722][4] = {{400, 41.5, 29.4}} -- Razorfen Downs
    dungeons[796][4] = {{85, 82.5, 33.3}} -- Scarlet Monastery
    dungeons[1176][4] = {{440, 39.2, 21.3}} -- Zul'Farrak
    dungeons[1337][4] = {{3, 41.7, 11.6}, {3, 58.6, 37}} -- Uldaman
    dungeons[1477][4] = {{8, 69.7, 53.5}} -- The Temple of Atal'Hakkar
    dungeons[1581][4] = {{40, 42.6, 71.8}} -- The Deadmines
    dungeons[1583][4] = {{51, 34.9, 83.9}, {46, 21, 37.9}} -- Blackrock Spire
    dungeons[1584][4] = {{51, 34.9, 83.9}, {46, 21, 37.9}} -- Blackrock Depths
    dungeons[1977][4] = {{33, 72.1, 32.9}} -- Zul'Gurub
    dungeons[2017][4] = {{139, 27.7, 11.5}, {139, 43.5, 19.4}} -- Stratholme
    dungeons[2100][4] = {{405, 29.1, 62.6}} -- Maraudon
    dungeons[2257][4] = {{1519, 69.49, 31.2}, {1537, 84.1, 53.1}} -- Deeprun Tram
    dungeons[2366][4] = {{440, 64.8, 50}} -- The Black Morass
    dungeons[2367][4] = {{440, 64.8, 50}} -- Old Hillsbrad Foothills
    dungeons[2437][4] = {{1637, 55.2, 51.2}} -- Ragefire Chasm
    dungeons[2557][4] = {{357, 62.1, 30.2}} -- Dire Maul
    dungeons[2677][4] = {{51, 34.9, 83.9}, {46, 21, 37.9}} -- Blackwing Lair
    dungeons[2717][4] = {{51, 34.9, 83.9}, {46, 21, 37.9}} -- Molten Core
    dungeons[3428][4] = {{1377, 24.4, 87.5}} -- Temple of Ahn'Qiraj
    dungeons[3429][4] = {{1377, 36.5, 93.9}} -- Ruins of Ahn'Qiraj
    dungeons[3456][4] = {{65, 87.4, 51.1}} -- Naxxramas
    dungeons[3606][4] = {{440, 64.8, 50}} -- Hyjal Summit
    dungeons[4100][4] = {{440, 64.8, 50}} -- The Culling of Stratholme
    dungeons[7307][4] = {{51, 34.9, 83.9}, {46, 21, 37.9}} -- Upper Blackrock Spire
elseif Questie.IsWotlk then
    dungeons[717][4] = {{1519, 52.4, 70}} -- The Stockade
    dungeons[2257][4] = {{1519, 72, 28}, {1537, 84.1, 53.1}} -- Deeprun Tram
    dungeons[3456][4] = {{65, 87.4, 51.1}} -- Naxxramas
end

ZoneDB.private.dungeons = dungeons
