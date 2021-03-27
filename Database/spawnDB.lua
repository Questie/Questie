-- AUTO GENERATED FILE! DO NOT EDIT!

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

local isTbcClient = string.byte(GetBuildInfo(), 1) == 50;


QuestieDB.npcKeys = {
    ['name'] = 1, -- string
    ['minLevelHealth'] = 2, -- int
    ['maxLevelHealth'] = 3, -- int
    ['minLevel'] = 4, -- int
    ['maxLevel'] = 5, -- int
    ['rank'] = 6, -- int, see https://github.com/cmangos/issues/wiki/creature_template#rank
    ['spawns'] = 7, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    ['waypoints'] = 8, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    ['zoneID'] = 9, -- guess as to where this NPC is most common
    ['questStarts'] = 10, -- table {questID(int),...}
    ['questEnds'] = 11, -- table {questID(int),...}
    ['factionID'] = 12, -- int, see https://github.com/cmangos/issues/wiki/FactionTemplate.dbc
    ['friendlyToFaction'] = 13, -- string, Contains "A" and/or "H" depending on NPC being friendly towards those factions. nil if hostile to both.
    ['subName'] = 14, -- string, The title or function of the NPC, e.g. "Weapon Vendor"
    ['npcFlags'] = 15, -- int, Bitmask containing various flags about the NPCs function (Vendor, Trainer, Flight Master, etc.).
                       -- For flag values see https://github.com/cmangos/mangos-classic/blob/172c005b0a69e342e908f4589b24a6f18246c95e/src/game/Entities/Unit.h#L536
}

QuestieDB.npcCompilerTypes = {
    ['name'] = "u8string",
    ['minLevelHealth'] = "u24",
    ['maxLevelHealth'] = "u24",
    ['minLevel'] = "u8",
    ['maxLevel'] = "u8",
    ['rank'] = "u8",
    ['spawns'] = "spawnlist",
    ['waypoints'] = "waypointlist",
    ['zoneID'] = "u16",
    ['questStarts'] = "u8u16array",
    ['questEnds'] = "u8u16array",
    ['factionID'] = "u16",
    ['friendlyToFaction'] = "faction",
    ['subName'] = "u8string",
    ['npcFlags'] = "u32",
}

QuestieDB.npcCompilerOrder = { -- order easily skipable data first for efficiency
    --static size
    'minLevelHealth', 'maxLevelHealth', 'minLevel', 'maxLevel', 'rank', 'zoneID', 'factionID', 'friendlyToFaction', 'npcFlags',

    -- variable size
    'name', 'spawns', 'waypoints', 'questStarts', 'questEnds', 'subName'
}

QuestieDB.npcFlags = {
    NONE = 0,
    GOSSIP = 1,
    QUEST_GIVER = 2,
    VENDOR = 4,
    FLIGHT_MASTER = 8,
    TRAINER = 16,
    SPIRIT_HEALER = 32,
    SPIRIT_GUIDE = 64,
    INNKEEPER = 128,
    BANKER = 256,
    PETITIONER = 512,
    TABARD_DESIGNER = 1024,
    BATTLEMASTER = 2048,
    AUCTIONEER = 4096,
    STABLEMASTER = 8192,
    REPAIR = 16384
}

-- temporary, until we remove the old db funcitons
QuestieDB._npcAdapterQueryOrder = {}
for key, id in pairs(QuestieDB.npcKeys) do
    QuestieDB._npcAdapterQueryOrder[id] = key
end

if (not isTbcClient) then
    return
end


QuestieDB.npcData = {
-- TODO import TBC npc data
-- custom NPCs below
[995000] = {'Mount Vendor',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995001] = {'1H Axes',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995002] = {'2H Axes',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995003] = {'Bows',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995004] = {'Guns',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995005] = {'1H Maces',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995006] = {'2H Maces',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995007] = {'Polearms',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995008] = {'1H Swords',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995009] = {'2H Swords',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995010] = {'Staves',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995011] = {'Fist Weapons',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995012] = {'Daggers',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995013] = {'Thrown',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995014] = {'Crossbows',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995015] = {'Red Gems',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995016] = {'Blue Gems',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995017] = {'Yellow Gems',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995018] = {'Purple Gems',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995019] = {'Green Gems',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995020] = {'Orange Gems',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995021] = {'Necks',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995022] = {'Rings',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995023] = {'Trinkets',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995024] = {'Cloth Heads',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995025] = {'Cloth Shoulders',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995026] = {'Cloth Chests',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995027] = {'Cloth Waists',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995028] = {'Cloth Legs',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995029] = {'Cloth Feet',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995030] = {'Cloth Wrists',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995031] = {'Cloth Hands',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995032] = {'Capes',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995033] = {'Cloth Robes',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995034] = {'Leather Heads',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995035] = {'Leather Shoulders',0,0,70,105,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995036] = {'Leather Chests',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995037] = {'Leather Waists',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995038] = {'Leather Legs',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995039] = {'Leather Feet',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995040] = {'Leather Wrists',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995041] = {'Leather Hands',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995042] = {'Leather Robes',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995043] = {'Mail Heads',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995044] = {'Mail Shoulders',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995045] = {'Mail Chests',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995046] = {'Mail Waists',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995047] = {'Mail Legs',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995048] = {'Mail Feet',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995049] = {'Mail Wrists',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995050] = {'Mail Hands',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995051] = {'Mail Robes',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995052] = {'Plate Heads',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995053] = {'Plate Shoulders',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995054] = {'Plate Chests',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995055] = {'Plate Waists',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995056] = {'Plate Legs',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995057] = {'Plate Feet',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995058] = {'Plate Wrists',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995059] = {'Plate Hands',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995060] = {'Shields',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995061] = {'Librams',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995062] = {'Idols',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995063] = {'Totems',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995064] = {'Ammo',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995065] = {'Quivers',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995066] = {'Bag Vendor',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995067] = {'Reagents',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995068] = {'Food Vendor',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995069] = {'Potions Vendor',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995070] = {'Mining Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,145,},
[995071] = {'Blacksmithing Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,145,},
[995072] = {'Engineering Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,145,},
[995073] = {'Jewelcrafting Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,145,},
[995074] = {'Tailoring Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,145,},
[995075] = {'Enchanting Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,145,},
[995076] = {'Skinning Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,17,},
[995077] = {'Leatherworking Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,145,},
[995078] = {'Herbalism Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,17,},
[995079] = {'Alchemy Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,145,},
[995080] = {'First Aid Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,145,},
[995081] = {'Fishing Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,145,},
[995082] = {'Cooking Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,145,},
[995083] = {'Weapon Master',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,19,},
[995084] = {'Riding Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,18,},
[995085] = {'Enchants',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995086] = {'Keymaster',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995087] = {'Demon Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,131,},
[995088] = {'Innkeeper',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,65536,},
[995089] = {'Poison Vendor',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995090] = {'Bank',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,131072,},
[995091] = {'Arena Teams',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,262144,},
[995093] = {'Auction House',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,2097152,},
[995094] = {'Stable Master',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4194304,},
[995095] = {'Pet Trainer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,19,},
[995096] = {'Meta Gems',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995097] = {'Bandages',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995098] = {'Scrolls',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995099] = {'Off-Hands',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH",nil,4224,},
[995101] = {'Azuryx',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH","Rogue Tier",4224,},
[995102] = {'Tomatoes',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH","Paladin Tier",4224,},
[995103] = {'Eric',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH","Warlock Tier",4224,},
[995104] = {'Moocifer',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH","Druid Tier",4224,},
[995105] = {'Azarath',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH","Mage Tier",4224,},
[995106] = {'Tom',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH","Shaman Tier",4224,},
[995107] = {'Doomcow',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH","Warrior Tier",4224,},
[995108] = {'Tombomb',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH","Priest Tier",4224,},
[995109] = {'Ravenshadow',0,0,70,70,0,nil,nil,0,nil,nil,35,"AH","Hunter Tier",4224,},
[995201] = {'Skinning 1 to 50',1,1,10,10,0,nil,nil,0,nil,nil,7,"AH",nil,0,},
[995202] = {'Skinning 50 to 100',1,1,15,15,0,nil,nil,0,nil,nil,7,"AH",nil,0,},
[995203] = {'Skinning 100 to 150',1,1,20,20,0,nil,nil,0,nil,nil,7,"AH",nil,0,},
[995204] = {'Skinning 150 to 200',1,1,30,30,0,nil,nil,0,nil,nil,7,"AH",nil,0,},
[995205] = {'Skinning 200 to 250',1,1,40,40,0,nil,nil,0,nil,nil,7,"AH",nil,0,},
[995206] = {'Skinning 250 to 300',1,1,50,50,0,nil,nil,0,nil,nil,7,"AH",nil,0,},
};