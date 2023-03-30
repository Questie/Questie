if GetLocale() ~= "esMX" then
    return
end

-- - @type l10n
local l10n = QuestieLoader:ImportModule("l10n")

l10n.factionGroupLookup = {
    -- UNKNOWN
    [-1] = {
        [59] = "Hermandad del Torio",
        [70] = "La Hermandad",
        [87] = "Bucaneros Velasangre",
        [92] = "Centauros del clan Gelkis",
        [93] = "Centauros del clan Magram",
        [270] = "Tribu Zandalar",
        [349] = "Ravenholdt",
        [471] = "Clan Martillo Salvaje",
        [529] = "El Alba Argenta",
        [576] = "Bastión Fauces de Madera",
        [589] = "Instructores de sableinvernales",
        [609] = "Círculo Cenarion",
        [749] = "Srs. del Agua de Hydraxis",
        [809] = "Shen'dralar",
        [909] = "Feria de la Luna Negra",
        [910] = "Linaje de Nozdormu",
    },
    -- Horda
    [67] = {
        [68] = "Entrañas",
        [76] = "Orgrimmar",
        [81] = "Cima del Trueno",
        [530] = "Trols Lanza Negra",
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
        [54] = "Exiliados de Gnomeregan",
        [69] = "Darnassus",
        [72] = "Ventormenta",
    },
    -- Fuerzas de la Alianza
    [891] = {
        [509] = "Liga de Arathor",
        [730] = "Guardia Pico Tormenta",
        [890] = "Centinelas Ala de Plata",
    },
    -- Fuerzas de la Horda
    [892] = {
        [510] = "Los Rapiñadores",
        [729] = "Clan Lobo Gélido",
        [889] = "Escoltas Grito de Guerra",
    },
}
