if GetLocale() ~= "ptBR" then
    return
end

-- - @type l10n
local l10n = QuestieLoader:ImportModule("l10n")

l10n.factionGroupLookup = {
    -- UNKNOWN
    [-1] = {
        [70] = "Camarilha",
        [471] = "Clã Martelo Feroz",
        [589] = "Treinadores de Sabres-do-inverno",
    },
    -- Horda
    [67] = {
        [68] = "Cidade Baixa",
        [76] = "Orgrimmar",
        [81] = "Penhasco do Trovão",
        [530] = "Trolls Lançanegra",
        [911] = "Luaprata",
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
        [930] = "Exodar",
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
    -- Shattrath
    [936] = {
        [932] = "Os Aldor",
        [934] = "Os Áugures",
        [935] = "Os Sha'tar",
        [1011] = "Bairro Inferior",
        [1031] = "Guarda Aérea Sha'tari",
        [1077] = "Ofensiva Sol Partido",
    },
    -- The Burning Crusade
    [980] = {
        [933] = "O Consórcio",
        [941] = "Os Mag'har",
        [942] = "Expedição Cenariana",
        [946] = "Fortaleza da Honra",
        [947] = "Thrallmar",
        [967] = "O Olho Violeta",
        [970] = "Sporeggar",
        [978] = "Kurenai",
        [989] = "Defensores do Tempo",
        [990] = "A Escama das Areias",
        [1012] = "Devotos da Morte Grislíngua",
        [1015] = "Asa Etérea",
        [1038] = "Ogri'la",
    },
    -- Vanguarda da Aliança
    [1037] = {
        [1050] = "Expedição Valentia",
        [1068] = "Liga dos Exploradores",
        [1094] = "O Pacto de Prata",
        [1126] = "Os Gelonatos",
    },
    -- Expedição da Horda
    [1052] = {
        [1064] = "Os Taunka",
        [1067] = "A Mão da Vingança",
        [1085] = "Ofensiva Brado Guerreiro",
        [1124] = "Os Fendessol",
    },
    -- Wrath of the Lich King
    [1097] = {
        [1037] = "Vanguarda da Aliança",
        [1052] = "Expedição da Horda",
        [1073] = "Os Kalu'ak",
        [1090] = "Kirin Tor",
        [1091] = "A Aliança do Repouso das Serpes",
        [1098] = "Cavaleiros da Lâmina de Ébano",
        [1106] = "Cruzada Argêntea",
        [1119] = "Os Filhos de Hodir",
        [1156] = "Veredito Cinzento",
    },
    -- Bacia Sholazar
    [1117] = {
        [1104] = "Tribo Feralma",
        [1105] = "Os Oráculos",
    },
    -- Clássico
    [1118] = {
        [59] = "Irmandade do Tório",
        [87] = "Bucaneiros da Vela Sangrenta",
        [92] = "Clã dos Centauros Gelkis",
        [93] = "Clã dos Centauros Magram",
        [270] = "Tribo Zandalar",
        [349] = "Corvoforte",
        [529] = "Aurora Argêntea",
        [576] = "Domínio dos Presamatos",
        [609] = "Círculo Cenariano",
        [749] = "Senhores das Águas Hidraxianos",
        [809] = "Shen'dralar",
        [909] = "Feira de Negraluna",
        [910] = "Prole de Nozdormu",
        [922] = "Tranquillien",
    },
}
