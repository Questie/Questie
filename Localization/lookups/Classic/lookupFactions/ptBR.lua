if GetLocale() ~= "ptBR" then
    return
end

-- - @type l10n
local l10n = QuestieLoader:ImportModule("l10n")

l10n.factionGroupLookup = {
    -- UNKNOWN
    [-1] = {
        [59] = "Irmandade do Tório",
        [70] = "Camarilha",
        [87] = "Bucaneiros da Vela Sangrenta",
        [92] = "Clã dos Centauros Gelkis",
        [93] = "Clã dos Centauros Magram",
        [270] = "Tribo Zandalar",
        [349] = "Corvoforte",
        [471] = "Clã Martelo Feroz",
        [529] = "Aurora Argêntea",
        [576] = "Domínio dos Presamatos",
        [589] = "Treinadores de Sabres-do-inverno",
        [609] = "Círculo Cenariano",
        [749] = "Senhores das Águas Hidraxianos",
        [809] = "Shen'dralar",
        [909] = "Feira de Negraluna",
        [910] = "Prole de Nozdormu",
    },
    -- Horda
    [67] = {
        [68] = "Cidade Baixa",
        [76] = "Orgrimmar",
        [81] = "Penhasco do Trovão",
        [530] = "Trolls Lançanegra",
    },
    -- Cartel Bondebico
    [169] = {
        [21] = "Angra do Butim",
        [369] = "Geringontzan",
        [470] = "Vila Catraca",
        [577] = "Visteterna",
    },
    -- Aliança
    [469] = {
        [47] = "Altaforja",
        [54] = "Exilados de Gnomeregan",
        [69] = "Darnassus",
        [72] = "Ventobravo",
    },
    -- Forças da Aliança
    [891] = {
        [509] = "A Liga de Arathor",
        [730] = "Guarda de Lançatroz",
        [890] = "Sentinelas da Asa de Prata",
    },
    -- Forças da Horda
    [892] = {
        [510] = "Os Profanadores",
        [729] = "Clã Lobo do Gelo",
        [889] = "Pioneiros do Brado Guerreiro",
    },
}
