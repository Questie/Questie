if GetLocale() ~= "enUS" then
    return
end

-- - @type l10n
local l10n = QuestieLoader:ImportModule("l10n")

l10n.factionGroupLookup = {
    -- UNKNOWN
    [-1] = {
        [70] = "Syndicate",
        [471] = "Wildhammer Clan",
        [589] = "Wintersaber Trainers",
    },
    -- Horde
    [67] = {
        [68] = "Undercity",
        [76] = "Orgrimmar",
        [81] = "Thunder Bluff",
        [530] = "Darkspear Trolls",
        [911] = "Silvermoon City",
    },
    -- Steamwheedle Cartel
    [169] = {
        [21] = "Booty Bay",
        [369] = "Gadgetzan",
        [470] = "Ratchet",
        [577] = "Everlook",
    },
    -- Alliance
    [469] = {
        [47] = "Ironforge",
        [54] = "Gnomeregan Exiles",
        [69] = "Darnassus",
        [72] = "Stormwind",
        [930] = "Exodar",
    },
    -- Alliance Forces
    [891] = {
        [509] = "The League of Arathor",
        [730] = "Stormpike Guard",
        [890] = "Silverwing Sentinels",
    },
    -- Horde Forces
    [892] = {
        [510] = "The Defilers",
        [729] = "Frostwolf Clan",
        [889] = "Warsong Outriders",
    },
    -- Shattrath City
    [936] = {
        [932] = "The Aldor",
        [934] = "The Scryers",
        [935] = "The Sha'tar",
        [1011] = "Lower City",
        [1031] = "Sha'tari Skyguard",
        [1077] = "Shattered Sun Offensive",
    },
    -- The Burning Crusade
    [980] = {
        [933] = "The Consortium",
        [941] = "The Mag'har",
        [942] = "Cenarion Expedition",
        [946] = "Honor Hold",
        [947] = "Thrallmar",
        [967] = "The Violet Eye",
        [970] = "Sporeggar",
        [978] = "Kurenai",
        [989] = "Keepers of Time",
        [990] = "The Scale of the Sands",
        [1012] = "Ashtongue Deathsworn",
        [1015] = "Netherwing",
        [1038] = "Ogri'la",
    },
    -- Alliance Vanguard
    [1037] = {
        [1050] = "Valiance Expedition",
        [1068] = "Explorers' League",
        [1094] = "The Silver Covenant",
        [1126] = "The Frostborn",
    },
    -- Horde Expedition
    [1052] = {
        [1064] = "The Taunka",
        [1067] = "The Hand of Vengeance",
        [1085] = "Warsong Offensive",
        [1124] = "The Sunreavers",
    },
    -- Wrath of the Lich King
    [1097] = {
        [1037] = "Alliance Vanguard",
        [1052] = "Horde Expedition",
        [1073] = "The Kalu'ak",
        [1090] = "Kirin Tor",
        [1091] = "The Wyrmrest Accord",
        [1098] = "Knights of the Ebon Blade",
        [1106] = "Argent Crusade",
        [1119] = "The Sons of Hodir",
        [1156] = "The Ashen Verdict",
    },
    -- Sholazar Basin
    [1117] = {
        [1104] = "Frenzyheart Tribe",
        [1105] = "The Oracles",
    },
    -- Classic
    [1118] = {
        [59] = "Thorium Brotherhood",
        [87] = "Bloodsail Buccaneers",
        [92] = "Gelkis Clan Centaur",
        [93] = "Magram Clan Centaur",
        [270] = "Zandalar Tribe",
        [349] = "Ravenholdt",
        [529] = "Argent Dawn",
        [576] = "Timbermaw Hold",
        [609] = "Cenarion Circle",
        [749] = "Hydraxian Waterlords",
        [809] = "Shen'dralar",
        [909] = "Darkmoon Faire",
        [910] = "Brood of Nozdormu",
        [922] = "Tranquillien",
    },
}
