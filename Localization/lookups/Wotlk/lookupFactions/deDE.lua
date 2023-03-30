if GetLocale() ~= "deDE" then
    return
end

-- - @type l10n
local l10n = QuestieLoader:ImportModule("l10n")

l10n.factionGroupLookup = {
    -- UNKNOWN
    [-1] = {
        [70] = "Syndikat",
        [471] = "Wildhammerklan",
        [589] = "Wintersäblerausbilder",
    },
    -- Horde
    [67] = {
        [68] = "Unterstadt",
        [76] = "Orgrimmar",
        [81] = "Donnerfels",
        [530] = "Dunkelspeertrolle",
        [911] = "Silbermond",
    },
    -- Dampfdruckkartell
    [169] = {
        [21] = "Beutebucht",
        [369] = "Gadgetzan",
        [470] = "Ratschet",
        [577] = "Ewige Warte",
    },
    -- Allianz
    [469] = {
        [47] = "Eisenschmiede",
        [54] = "Gnomeregangnome",
        [69] = "Darnassus",
        [72] = "Sturmwind",
        [930] = "Die Exodar",
    },
    -- Streitkräfte der Allianz
    [891] = {
        [509] = "Der Bund von Arathor",
        [730] = "Sturmlanzengarde",
        [890] = "Silberschwingen",
    },
    -- Streitkräfte der Horde
    [892] = {
        [510] = "Die Entweihten",
        [729] = "Frostwolfklan",
        [889] = "Kriegshymnenklan",
    },
    -- Shattrath
    [936] = {
        [932] = "Die Aldor",
        [934] = "Die Seher",
        [935] = "Die Sha'tar",
        [1011] = "Unteres Viertel",
        [1031] = "Himmelswache der Sha'tari",
        [1077] = "Offensive der Zerschmetterten Sonne",
    },
    -- The Burning Crusade
    [980] = {
        [933] = "Das Konsortium",
        [941] = "Die Mag'har",
        [942] = "Expedition des Cenarius",
        [946] = "Ehrenfeste",
        [947] = "Thrallmar",
        [967] = "Das Violette Auge",
        [970] = "Sporeggar",
        [978] = "Kurenai",
        [989] = "Hüter der Zeit",
        [990] = "Die Wächter der Sande",
        [1012] = "Die Todeshörigen",
        [1015] = "Netherschwingen",
        [1038] = "Ogri'la",
    },
    -- Vorposten der Allianz
    [1037] = {
        [1050] = "Expedition Valianz",
        [1068] = "Forscherliga",
        [1094] = "Der Silberbund",
        [1126] = "Die Frosterben",
    },
    -- Expedition der Horde
    [1052] = {
        [1064] = "Die Taunka",
        [1067] = "Die Hand der Rache",
        [1085] = "Kriegshymnenoffensive",
        [1124] = "Die Sonnenhäscher",
    },
    -- Wrath of the Lich King
    [1097] = {
        [1037] = "Vorposten der Allianz",
        [1052] = "Expedition der Horde",
        [1073] = "Die Kalu'ak",
        [1090] = "Kirin Tor",
        [1091] = "Der Wyrmruhpakt",
        [1098] = "Ritter der Schwarzen Klinge",
        [1106] = "Argentumkreuzzug",
        [1119] = "Die Söhne Hodirs",
        [1156] = "Das Äscherne Verdikt",
    },
    -- Sholazarbecken
    [1117] = {
        [1104] = "Stamm der Wildherzen",
        [1105] = "Die Orakel",
    },
    -- Classic
    [1118] = {
        [59] = "Thoriumbruderschaft",
        [87] = "Blutsegelbukaniere",
        [92] = "Gelkisklan",
        [93] = "Magramklan",
        [270] = "Stamm der Zandalari",
        [349] = "Rabenholdt",
        [529] = "Argentumdämmerung",
        [576] = "Holzschlundfeste",
        [609] = "Zirkel des Cenarius",
        [749] = "Hydraxianer",
        [809] = "Shen'dralar",
        [909] = "Dunkelmond-Jahrmarkt",
        [910] = "Brut Nozdormus",
        [922] = "Tristessa",
    },
}
