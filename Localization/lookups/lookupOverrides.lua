---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

if GetLocale() == "deDE" then
    l10n.questLookupOverrides = loadstring([[return {
        [63866] = {"Die Beherrschung des Lichts", {"Füllt das schimmernde Gefäß bei M'uru und kehrt anschließend zu Ritterfürst Heldenblut in Silbermond zurück."}},
        [64319] = {"Eine Studie der Macht", {"Sprecht mit Magister Astalor Blutschwur in der Geheimen Kammer unter dem Hauptquartier der Blutelfen."}},
        [78752] = {"Todesbeweise: Titanenrune mit Protokoll Gamma",{"Erzmagier Lan'dalock in Dalaran möchte, dass Ihr ihm ein Medaillon der Entweihten von einem beliebigen, finalen Dungeonboss bringt.","","Diese Quest kann nur in einem Titanenrunendungeon mit aktivem Protokoll Gamma abgeschlossen werden."}},
        [78753] = {"Todesbeweise: Bedrohungen für Azeroth",{"Erzmagier Lan'dalock in Dalaran möchte, dass Ihr ihm ein geheimnisvolles Artefakt von einem beliebigen, finalen Dungeonboss bringt.","","Diese Quest kann nur in einem heroischen Dungeon abgeschlossen werden."}},
    }]])
    l10n.itemLookupOverrides = loadstring([[return {
        [185956] = "Schimmerndes Gefäß",
    }]])
elseif GetLocale() == "esES" then
    l10n.questLookupOverrides = loadstring([[return {
        [63866] = {"Buscando la Luz", {"Llena la vasija refulgente en M'uru y llévasela al Lord caballero Sangrevalor a Ciudad de Lunargenta."}},
        [64319] = {"Un estudio sobre el poder", {"Habla con el magister Astalor Jurasangre en la cámara oculta debajo del cuartel general de los Caballeros de sangre."}},
        [78752] = {"Prueba de defunción: protocolo Gamma de runa titánica",{"El archimago Lan'dalock de Dalaran quiere que regreses con el medallón del profanador que se consigue del último jefe de cualquier mazmorra.","","Esta misión solo se puede completar en la dificultad de mazmorra protocolo Gamma de runa titánica."}},
        [78753] = {"Prueba de defunción: amenazas a Azeroth",{"El archimago Lan'dalock de Dalaran quiere que regreses con el artefacto misterioso que se consigue del último jefe de cualquier mazmorra.","","Esta misión solo se puede completar en la dificultad de mazmorra heroica."}},
    }]])
    l10n.itemLookupOverrides = loadstring([[return {
        [185956] = "Vasija refulgente",
    }]])
elseif GetLocale() == "esMX" then
    l10n.questLookupOverrides = loadstring([[return {
        [63866] = {"Buscando la Luz", {"Llena la vasija refulgente en M'uru y llévasela al Lord caballero Sangrevalor a Ciudad de Lunargenta."}},
        [64319] = {"Un estudio sobre el poder", {"Habla con el magister Astalor Jurasangre en la cámara oculta debajo del puesto de mando de los Caballeros de sangre"}},
        [78752] = {"Prueba de defunción: Protocolo gamma de runa titánica",{"El archimago Lan'dalock de Dalaran quiere que vuelvas con el medallón de profanador de cualquier jefe final de calabozo.","","Esta misión solo se puede completar en cualquier calabozo de dificultad Protocolo gamma de runa titánica."}},
        [78753] = {"Prueba de defunción: Amenazas contra Azeroth",{"El archimago Lan'dalock de Dalaran quiere que vuelvas con el artefacto misterioso de cualquier jefe final de calabozo.","","Esta misión solo se puede completar en cualquier calabozo de dificultad heroica."}},
    }]])
    l10n.itemLookupOverrides = loadstring([[return {
        [185956] = "Vasija refulgente",
    }]])
elseif GetLocale() == "frFR" then
    l10n.questLookupOverrides = loadstring([[return {
        [63866] = {"Revendiquer la Lumière", {"Utilisez le Calice chatoyant sur M’uru pour le remplir et retournez voir le chevalier-seigneur Vaillessang à Lune-d'argent."}},
        [64319] = {"Une étude du pouvoir", {"Parlez au magistère Astalor Ligessang dans la chambre secrète sous les quartiers généraux des chevaliers de sang."}},
        [78752] = {"Preuves de la mort : protocole Gamma de rune des Titans",{"L’archimage Lan’dalock de Dalaran vous demande de revenir avec le médaillon des Profanateurs, obtenu auprès d’un boss final ou d’une boss finale de donjon.","","Cette quête peut être achevée dans les donjons de runes des Titans avec protocole Gamma."}},
        [78753] = {"Preuves de la mort : menaces pour Azeroth",{"L’archimage Lan’dalock de Dalaran vous demande de revenir avec le mystérieux artéfact obtenu auprès d’un boss final ou d’une boss finale de donjon.","","Cette quête peut être achevée dans les donjons en mode héroïque."}},
    }]])
    l10n.itemLookupOverrides = loadstring([[return {
        [185956] = "Calice chatoyant",
    }]])
elseif GetLocale() == "koKR" then
    l10n.questLookupOverrides = loadstring([[return {
        [63866] = {"빛을 추구하다", {"희미하게 빛나는 용기 안에 므우루의 힘을 가득 채운 다음 실버문의 기사군주 블러드밸러와 다시 대화해야 합니다."}},
        [64319] = {"힘을 연구하다", {"혈기사 본부 지하에 숨겨진 방에 있는 마법학자 아스탈로르 블러드스원과 대화해야 합니다."}},
        [78752] = {"죽음의 증거: 티탄 룬 프로토콜 감마",{"던전 최종 우두머리를 처치하고 모독자의 메달을 획득해 달라란에 있는 대마법사 랜달록에게 가져가야 합니다.","","본 퀘스트는 티탄 룬 프로토콜 감마 던전 난이도로만 완료할 수 있습니다."}},
        [78753] = {"죽음의 증거: 아제로스의 위협",{"던전 최종 우두머리를 처치하고 수수께끼의 유물을 획득해 달라란에 있는 대마법사 랜달록에게 가져가야 합니다.","","본 퀘스트는 영웅 던전 난이도로만 완료할 수 있습니다."}},
    }]])
    l10n.itemLookupOverrides = loadstring([[return {
        [185956] = "희미하게 빛나는 용기",
    }]])
elseif GetLocale() == "ptBR" then
    l10n.questLookupOverrides = loadstring([[return {
        [63866] = {"Poder sobre a Luz", {"Use o Recipiente Cintilante em M'uru para enchê-lo e fale novamente com o Grão-cavaleiro Sangueroico em Luaprata."}},
        [64319] = {"Um estudo da energia", {"Fale com o Magíster Astalor Jurassangue na câmara oculta sob o quartel-general dos Cavaleiros Sangrentos."}},
        [78752] = {"Prova da Morte: Protocolo Gama de Runa Titânica",{"O Arquimago Lan'dalock, em Dalaran, quer que você retorne com o Medalhão do Profanador de qualquer chefe de masmorra final.","","Esta missão só pode ser concluída em qualquer masmorra no modo Protocolo Gama de Runa Titânica."}},
        [78753] = {"Prova da Morte: Ameaças a Azeroth",{"O Arquimago Lan'dalock, em Dalaran, quer que você retorne com o Artefato Misterioso de qualquer chefe de masmorra final.","","Esta missão só pode ser concluída em qualquer masmorra no modo Heroico."}},
    }]])
    l10n.itemLookupOverrides = loadstring([[return {
        [185956] = "Recipiente Cintilante",
    }]])
elseif GetLocale() == "ruRU" then
    l10n.questLookupOverrides = loadstring([[return {
        [63866] = {"Получение силы Света", {"Примените мерцающий сосуд к М'ууру, чтобы наполнить его магической силой, и возвращайтесь к предводителю рыцарей по имени Доблестная Кровь в Луносвет."}},
        [64319] = {"Источник силы", {"Поговорите с магистром Асталором Кровавой Клятвой в тайной зале, расположенной под штабом рыцарей крови."}},
        [78752] = {"Доказательство смерти: руна титанов – протокол \"Гамма\"",{"Верховный маг Лан'далок в Даларане просит вас принести ему медальон Осквернителя, который можно получить за победу над любым из финальных боссов подземелий.","","Это задание можно выполнить на любом уровне сложности подземелья с руной титанов и защитным протоколом \"Гамма\"."}},
        [78753] = {"Доказательство смерти: угрозы безопасности Азерота",{"Верховный маг Лан'далок в Даларане просит вас принести ему таинственный артефакт, который можно получить за победу над любым из финальных боссов подземелий.","","Это задание можно выполнить только в героическом режиме."}},
    }]])
    l10n.itemLookupOverrides = loadstring([[return {
        [185956] = "Мерцающий сосуд",
    }]])
elseif GetLocale() == "zhCN" then
    l10n.questLookupOverrides = loadstring([[return {
        [63866] = {"驾驭圣光", {"对穆鲁使用微光容器以装满它，然后向银月城的骑士领主布拉德瓦罗复命。"}},
        [64319] = {"掌握力量", {"与血骑士总部楼下密室中的魔导师阿斯塔洛·血誓谈一谈。"}},
        [78752] = {"死亡证明：泰坦符文协议伽马",{"达拉然的大法师兰达洛克要你从任意地下城的最终首领处取回污染者的勋章。","","该任务必须在泰坦符文协议伽马难度的地下城中完成。"}},
        [78753] = {"死亡证明：艾泽拉斯的威胁",{"达拉然的大法师兰达洛克要你从任意地下城的最终首领处取回神秘的古器。","","该任务必须在英雄难度的地下城中完成。"}},
        [83713] = {"死亡证明：泰坦符文协议阿尔法",{"达拉然的大法师兰达洛克要你从任意地下城的最终首领处取回污染者的勋章。","","该任务必须在泰坦符文协议阿尔法难度的地下城中完成。"}},
        [83714] = {"死亡证明：艾泽拉斯的威胁",{"达拉然的大法师兰达洛克要你从任意地下城的最终首领处取回神秘的古器。","","该任务必须在英雄难度的地下城中完成。"}},
        [83717] = {"死亡证明：泰坦符文协议贝塔",{"达拉然的大法师兰达洛克要你从任意地下城的最终首领处取回污染者的勋章。","","该任务必须在泰坦符文协议贝塔难度的地下城中完成。"}},
        [87379] = {"死亡证明：艾泽拉斯的威胁",{"达拉然的大法师兰达洛克要你从任意地下城的最终首领处取回神秘的古器。","","该任务必须在英雄难度的地下城中完成。"}},
        [93975] = {"拉格纳罗斯必须死！",{"团队消灭拉格纳罗斯。"}},
        [94577] = {"凯尔萨斯必须死！",{"消灭风暴要塞的凯尔萨斯逐日者。"}},
        [94579] = {"消灭帕奇维克！",{"消灭纳克萨玛斯的帕奇维克。"}},
    }]])
    l10n.itemLookupOverrides = loadstring([[return {
        [185956] = "微光容器",
    }]])
elseif GetLocale() == "zhTW" then
    l10n.questLookupOverrides = loadstring([[return {
        [63866] = {"掌握聖光", {"在莫魯身上使用幻光容器來裝滿它，再回到銀月城的騎士領主伯洛德瓦勒那裡。"}},
        [64319] = {"學習力量", {"到血騎士總部底下隱藏的房間裡和博學者阿斯塔樂·血誓談談。"}},
        [78752] = {"死亡證明：泰坦符文伽瑪系統",{"大法師朗達拉克要你帶回從任一地城中的最後首領身上取得的褻瀆者勳章。","","這個任務只能在任一泰坦符文伽瑪系統難度地城中完成。"}},
        [78753] = {"死亡證明：艾澤拉斯的威脅",{"大法師朗達拉克要你帶回從任一地城中的最後首領身上取得的神秘的古器。","","這個任務只能在任一英雄難度地城中完成。"}},
    }]])
    l10n.itemLookupOverrides = loadstring([[return {
        [185956] = "幻光容器",
    }]])
end

-- Some existing quests have been changed for the Titan Reforged servers
---@return table<QuestId, table<string,table<string>>>
function Questie.LoadTitanQuestLookupOverrides()
    local questKeys = QuestieDB.questKeys

    return {
        [6805] = { -- Greater Stormers and Rumblers
            [questKeys.name] = "大雷暴和巨磐石",
            [questKeys.objectivesText] = {"消灭15个大型灰尘风暴和15个大型沙漠奔行者，然后回到艾萨拉的海达克西斯公爵那儿。"},
        },
        [7787] = { -- Legend of the Past
            [questKeys.name] = "昔日的传奇",
            [questKeys.objectivesText] = {"寻找对休眠之刃有所了解的人。"},
        },
        [8184] = { -- Prophecy of Wrath
            [questKeys.name] = "愤怒预言", -- warrior
        },
        [8185] = { -- Syncretist's Prophecy
            [questKeys.name] = "调和预言", -- paladin
        },
        [8186] = { -- Death's Prophecy
            [questKeys.name] = "死亡预言", -- rogue
        },
        [8187] = { -- Falcon's Embodiment
            [questKeys.name] = "猎鹰化身", -- hunter
        },
        [8188] = { -- Vodouisant's Prophecy
            [questKeys.name] = "巫毒预言", -- shaman
        },
        [8189] = { -- Arcanist's Prophecy
            [questKeys.name] = "奥术师预言", -- mage
        },
        [8190] = { -- Hoodoo Prophecy
            [questKeys.name] = "妖术预言", -- warlock
        },
        [8191] = { -- Auratic Prophecy
            [questKeys.name] = "光晕预言", -- priest
        },
        [8192] = { -- Animist's Prophecy
            [questKeys.name] = "万灵预言", -- druid
        },
    }
end
