if GetLocale() ~= "deDE" then
    return
end

-- - @type l10n
local l10n = QuestieLoader:ImportModule("l10n")

l10n.factionGroupLookup = {
    -- UNKNOWN
    [-1] = {
        [59] = "Thoriumbruderschaft",
        [70] = "Syndikat",
        [87] = "Blutsegelbukaniere",
        [92] = "Gelkisklan",
        [93] = "Magramklan",
        [270] = "Stamm der Zandalar",
        [349] = "Ravenholdt",
        [471] = "Wildhammerklan",
        [529] = "Argentumdämmerung",
        [576] = "Holzschlundfeste",
        [589] = "Wintersäblerausbilder",
        [609] = "Zirkel des Cenarius",
        [749] = "Hydraxianer",
        [809] = "Shen'dralar",
        [909] = "Dunkelmond-Jahrmarkt",
        [910] = "Brut Nozdormus",
    },
    -- Horde
    [67] = {
        [68] = "Undercity",
        [76] = "Orgrimmar",
        [81] = "Thunder Bluff",
        [530] = "Darkspear",
    },
    -- Steamwheedle-Kartell
    [169] = {
        [21] = "Booty Bay",
        [369] = "Gadgetzan",
        [470] = "Ratchet",
        [577] = "Everlook",
    },
    -- Allianz
    [469] = {
        [47] = "Ironforge",
        [54] = "Gnomeregangnome",
        [69] = "Darnassus",
        [72] = "Stormwind",
    },
    -- Streitkräfte der Allianz
    [891] = {
        [509] = "Der Bund von Arathor",
        [730] = "Stormpikegarde",
        [890] = "Schildwachen der Silverwing",
    },
    -- Streitkräfte der Horde
    [892] = {
        [510] = "Die Entweihten",
        [729] = "Frostwolfklan",
        [889] = "Warsongvorhut",
    },
}
