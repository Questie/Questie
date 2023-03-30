if GetLocale() ~= "esES" then
    return
end

-- - @type l10n
local l10n = QuestieLoader:ImportModule("l10n")

l10n.factionGroupLookup = {
    -- UNKNOWN
    [-1] = {
        [59] = "Hermandad del torio",
        [70] = "Sindicato",
        [87] = "Bucaneros Velasangre",
        [92] = "Centauro del clan Gelkis",
        [93] = "Centauro del clan Magram",
        [270] = "Tribu Zandalar",
        [349] = "Ravenholdt",
        [471] = "Clan Martillo Salvaje",
        [529] = "Alba Argenta",
        [576] = "Bastión de los Fauces de Madera",
        [589] = "Entrenadores de Sableinvernales",
        [609] = "Círculo Cenarion",
        [749] = "Señores del Agua de Hydraxis",
        [809] = "Shen'dralar",
        [909] = "Feria de la Luna Negra",
        [910] = "Linaje de Nozdormu",
    },
    -- Horda
    [67] = {
        [68] = "Entrañas",
        [76] = "Orgrimmar",
        [81] = "Cima del Trueno",
        [530] = "Trols de Lanza Negra",
    },
    -- Cártel Bonvapor
    [169] = {
        [21] = "Bahía del Botín",
        [369] = "Gadgetzan",
        [470] = "Trinquete",
        [577] = "Vista Eterna",
    },
    -- Alianza
    [469] = {
        [47] = "Forjaz",
        [54] = "Exiliado de Gnomeregan",
        [69] = "Darnassus",
        [72] = "Ventormenta",
    },
    -- Fuerzas de la Alianza
    [891] = {
        [509] = "Liga de Arathor",
        [730] = "Guardia de Pico Tormenta",
        [890] = "Centinelas Ala de Plata",
    },
    -- Fuerzas de la Horda
    [892] = {
        [510] = "Los Rapiñadores",
        [729] = "Clan Lobo Gélido",
        [889] = "Escolta Grito de Guerra",
    },
}
