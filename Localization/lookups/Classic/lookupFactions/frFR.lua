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
        [471] = "Clan Wildhammer",
        [529] = "Aube d'argent",
        [576] = "Les Grumegueules",
        [589] = "Éleveurs de sabres-d'hiver",
        [609] = "Cercle cénarien",
        [749] = "Les Hydraxiens",
        [809] = "Shen'dralar",
        [909] = "Foire de Sombrelune",
        [910] = "Progéniture de Nozdormu",
    },
    -- Horde
    [67] = {
        [68] = "Undercity",
        [76] = "Orgrimmar",
        [81] = "Thunder Bluff",
        [530] = "Trolls Darkspear",
    },
    -- Cartel Gentepression
    [169] = {
        [21] = "Baie-du-Butin",
        [369] = "Gadgetzan",
        [470] = "Ratchet",
        [577] = "Long-guet",
    },
    -- Alliance
    [469] = {
        [47] = "Ironforge",
        [54] = "Exilés de Gnomeregan",
        [69] = "Darnassus",
        [72] = "Stormwind",
    },
    -- Forces de l'Alliance
    [891] = {
        [509] = "La Ligue d'Arathor",
        [730] = "Garde Stormpike",
        [890] = "Sentinelles d'Aile-argent",
    },
    -- Forces de la Horde
    [892] = {
        [510] = "Les Profanateurs",
        [729] = "Clan Frostwolf",
        [889] = "Voltigeurs Warsong",
    },
}
