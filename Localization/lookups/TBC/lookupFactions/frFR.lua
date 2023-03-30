if GetLocale() ~= "frFR" then
    return
end

-- - @type l10n
local l10n = QuestieLoader:ImportModule("l10n")

l10n.factionGroupLookup = {
    -- UNKNOWN
    [-1] = {
        [59] = "Confrérie du thorium",
        [70] = "Syndicat",
        [87] = "La Voile sanglante",
        [92] = "Centaures (Gelkis)",
        [93] = "Centaures (Magram)",
        [270] = "Tribu Zandalar",
        [349] = "Ravenholdt",
        [471] = "Clan Marteau-hardi",
        [529] = "Aube d'argent",
        [576] = "Les Grumegueules",
        [589] = "Éleveurs de sabres-d'hiver",
        [609] = "Cercle cénarien",
        [749] = "Les Hydraxiens",
        [809] = "Shen'dralar",
        [909] = "Foire de Sombrelune",
        [910] = "Progéniture de Nozdormu",
        [922] = "Tranquillien",
        [967] = "L'Œil pourpre",
        [989] = "Gardiens du Temps",
        [990] = "La Balance des sables",
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
    -- Outreterre
    [980] = {
        [933] = "Le Consortium",
        [941] = "Mag'har",
        [942] = "Expédition cénarienne",
        [946] = "Bastion de l'Honneur",
        [947] = "Thrallmar",
        [970] = "Sporeggar",
        [978] = "Kurenaï",
        [1012] = "Ligemort cendrelangue",
        [1015] = "Aile-du-Néant",
        [1038] = "Ogri'la",
    },
}
