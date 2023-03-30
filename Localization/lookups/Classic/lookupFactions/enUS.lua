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
    },
    -- Horde
    [67] = {
        [68] = "Undercity",
        [76] = "Orgrimmar",
        [81] = "Thunder Bluff",
        [530] = "Darkspear Trolls",
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
}
