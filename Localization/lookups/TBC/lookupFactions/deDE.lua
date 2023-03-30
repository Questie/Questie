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
        [349] = "Rabenholdt",
        [471] = "Wildhammerklan",
        [529] = "Argentumdämmerung",
        [576] = "Holzschlundfeste",
        [589] = "Wintersäblerausbilder",
        [609] = "Zirkel des Cenarius",
        [749] = "Hydraxianer",
        [809] = "Shen'dralar",
        [909] = "Dunkelmond-Jahrmarkt",
        [910] = "Brut Nozdormus",
        [922] = "Tristessa",
        [967] = "Das Violette Auge",
        [989] = "Hüter der Zeit",
        [990] = "Die Wächter der Sande",
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
    -- Scherbenwelt
    [980] = {
        [933] = "Das Konsortium",
        [941] = "Die Mag'har",
        [942] = "Expedition des Cenarius",
        [946] = "Ehrenfeste",
        [947] = "Thrallmar",
        [970] = "Sporeggar",
        [978] = "Kurenai",
        [1012] = "Die Todeshörigen",
        [1015] = "Netherschwingen",
        [1038] = "Ogri'la",
    },
}
