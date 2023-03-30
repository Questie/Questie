if GetLocale() ~= "frFR" then
    return
end

-- - @type l10n
local l10n = QuestieLoader:ImportModule("l10n")

l10n.factionGroupLookup = {
    -- UNKNOWN
    [-1] = {
        [70] = "Syndicat",
        [471] = "Clan Marteau-hardi",
        [589] = "Éleveurs de sabres-d'hiver",
    },
    -- Horde
    [67] = {
        [68] = "Fossoyeuse",
        [76] = "Orgrimmar",
        [81] = "Les Pitons du Tonnerre",
        [530] = "Trolls Sombrelance",
        [911] = "Lune-d'argent",
    },
    -- Cartel Gentepression
    [169] = {
        [21] = "Baie-du-Butin",
        [369] = "Gadgetzan",
        [470] = "Cabestan",
        [577] = "Long-guet",
    },
    -- Alliance
    [469] = {
        [47] = "Forgefer",
        [54] = "Exilés de Gnomeregan",
        [69] = "Darnassus",
        [72] = "Hurlevent",
        [930] = "Exodar",
    },
    -- Forces de l'Alliance
    [891] = {
        [509] = "La Ligue d'Arathor",
        [730] = "Garde Foudrepique",
        [890] = "Sentinelles d'Aile-argent",
    },
    -- Forces de la Horde
    [892] = {
        [510] = "Les Profanateurs",
        [729] = "Clan Loup-de-givre",
        [889] = "Voltigeurs Chanteguerre",
    },
    -- Shattrath
    [936] = {
        [932] = "L'Aldor",
        [934] = "Les Clairvoyants",
        [935] = "Les Sha'tar",
        [1011] = "Ville basse",
        [1031] = "Garde-ciel sha'tari",
        [1077] = "Opération Soleil brisé",
    },
    -- The Burning Crusade
    [980] = {
        [933] = "Le Consortium",
        [941] = "Mag'har",
        [942] = "Expédition cénarienne",
        [946] = "Bastion de l'Honneur",
        [947] = "Thrallmar",
        [967] = "L'Œil pourpre",
        [970] = "Sporeggar",
        [978] = "Kurenaï",
        [989] = "Gardiens du Temps",
        [990] = "La Balance des sables",
        [1012] = "Ligemort cendrelangue",
        [1015] = "Aile-du-Néant",
        [1038] = "Ogri'la",
    },
    -- Avant-garde de l'Alliance
    [1037] = {
        [1050] = "Expédition de la Bravoure",
        [1068] = "Ligue des explorateurs",
        [1094] = "Le Concordat argenté",
        [1126] = "Les Givre-nés",
    },
    -- Expédition de la Horde
    [1052] = {
        [1064] = "Les Taunkas",
        [1067] = "La Main de la vengeance",
        [1085] = "Offensive chanteguerre",
        [1124] = "Les Saccage-soleil",
    },
    -- Wrath of the Lich King
    [1097] = {
        [1037] = "Avant-garde de l'Alliance",
        [1052] = "Expédition de la Horde",
        [1073] = "Les Kalu'aks",
        [1090] = "Kirin Tor",
        [1091] = "L'Accord du Repos du ver",
        [1098] = "Chevaliers de la Lame d'ébène",
        [1106] = "La Croisade d'argent",
        [1119] = "Les Fils de Hodir",
        [1156] = "Le Verdict des cendres",
    },
    -- Bassin de Sholazar
    [1117] = {
        [1104] = "Tribu Frénécœur",
        [1105] = "Les Oracles",
    },
    -- Classique
    [1118] = {
        [59] = "Confrérie du thorium",
        [87] = "La Voile sanglante",
        [92] = "Centaures (Gelkis)",
        [93] = "Centaures (Magram)",
        [270] = "Tribu Zandalar",
        [349] = "Ravenholdt",
        [529] = "Aube d'argent",
        [576] = "Les Grumegueules",
        [609] = "Cercle cénarien",
        [749] = "Les Hydraxiens",
        [809] = "Shen'dralar",
        [909] = "Foire de Sombrelune",
        [910] = "Progéniture de Nozdormu",
        [922] = "Tranquillien",
    },
}
