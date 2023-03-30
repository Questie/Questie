if GetLocale() ~= "esES" then
    return
end

-- - @type l10n
local l10n = QuestieLoader:ImportModule("l10n")

l10n.factionGroupLookup = {
    -- UNKNOWN
    [-1] = {
        [70] = "La Hermandad",
        [471] = "Clan Martillo Salvaje",
        [589] = "Instructores de Sableinvernales",
    },
    -- Horda
    [67] = {
        [68] = "Entrañas",
        [76] = "Orgrimmar",
        [81] = "Cima del Trueno",
        [530] = "Trols Lanza Negra",
        [911] = "Ciudad de Lunargenta",
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
        [930] = "El Exodar",
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
    -- Ciudad de Shattrath
    [936] = {
        [932] = "Los Aldor",
        [934] = "Los Arúspices",
        [935] = "Los Sha'tar",
        [1011] = "Bajo Arrabal",
        [1031] = "Guardia del cielo Sha'tari",
        [1077] = "Ofensiva Sol Devastado",
    },
    -- The Burning Crusade
    [980] = {
        [933] = "El Consorcio",
        [941] = "Los Mag'har",
        [942] = "Expedición Cenarion",
        [946] = "Bastión del Honor",
        [947] = "Thrallmar",
        [967] = "El Ojo Violeta",
        [970] = "Esporaggar",
        [978] = "Kurenai",
        [989] = "Vigilantes del Tiempo",
        [990] = "La Escama de las Arenas",
        [1012] = "Juramorte Lengua de ceniza",
        [1015] = "Ala Abisal",
        [1038] = "Ogri'la",
    },
    -- Vanguardia de la Alianza
    [1037] = {
        [1050] = "Expedición de Denuedo",
        [1068] = "Liga de Expedicionarios",
        [1094] = "El Pacto de Plata",
        [1126] = "Los Natoescarcha",
    },
    -- Expedición de la Horda
    [1052] = {
        [1064] = "Los taunka",
        [1067] = "La Mano de la Venganza",
        [1085] = "Ofensiva Grito de Guerra",
        [1124] = "Los Atracasol",
    },
    -- Wrath of the Lich King
    [1097] = {
        [1037] = "Vanguardia de la Alianza",
        [1052] = "Expedición de la Horda",
        [1073] = "Los Kalu'ak",
        [1090] = "Kirin Tor",
        [1091] = "El Acuerdo del Reposo del Dragón",
        [1098] = "Caballeros de la Espada de Ébano",
        [1106] = "Cruzada Argenta",
        [1119] = "Los Hijos de Hodir",
        [1156] = "El Veredicto Cinéreo",
    },
    -- Cuenca de Sholazar
    [1117] = {
        [1104] = "Tribu Corazón Frenético",
        [1105] = "Los Oráculos",
    },
    -- Clásicas
    [1118] = {
        [59] = "Hermandad del Torio",
        [87] = "Bucaneros Velasangre",
        [92] = "Centauros del clan Gelkis",
        [93] = "Centauros del clan Magram",
        [270] = "Tribu Zandalar",
        [349] = "Ravenholdt",
        [529] = "El Alba Argenta",
        [576] = "Bastión Fauces de Madera",
        [609] = "Círculo Cenarion",
        [749] = "Srs. del Agua de Hydraxis",
        [809] = "Shen'dralar",
        [909] = "Feria de la Luna Negra",
        [910] = "Linaje de Nozdormu",
        [922] = "Tranquillien",
    },
}
