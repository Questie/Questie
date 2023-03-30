if GetLocale() ~= "enUS" then
    return
end

-- - @type l10n
local l10n = QuestieLoader:ImportModule("l10n")

l10n.factionGroupLookup = {
    -- UNKNOWN
    [-1] = {
        [59] = "Thorium Brotherhood",
        [70] = "Syndicate",
        [87] = "Bloodsail Buccaneers",
        [92] = "Gelkis Clan Centaur",
        [93] = "Magram Clan Centaur",
        [270] = "Zandalar Tribe",
        [349] = "Ravenholdt",
        [471] = "Wildhammer Clan",
        [529] = "Argent Dawn",
        [576] = "Timbermaw Hold",
        [589] = "Wintersaber Trainers",
        [609] = "Cenarion Circle",
        [749] = "Hydraxian Waterlords",
        [809] = "Shen'dralar",
        [909] = "Darkmoon Faire",
        [910] = "Brood of Nozdormu",
        [922] = "Tranquillien",
        [967] = "The Violet Eye",
        [989] = "Keepers of Time",
        [990] = "The Scale of the Sands",
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
    -- Outland
    [980] = {
        [933] = "The Consortium",
        [941] = "The Mag'har",
        [942] = "Cenarion Expedition",
        [946] = "Honor Hold",
        [947] = "Thrallmar",
        [970] = "Sporeggar",
        [978] = "Kurenai",
        [1012] = "Ashtongue Deathsworn",
        [1015] = "Netherwing",
        [1038] = "Ogri'la",
    },
}
