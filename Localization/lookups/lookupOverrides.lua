---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

if GetLocale() == "deDE" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"Einen Vorteil gewinnen",{"Bringt dem Abgesandten Mordin in Shattrath 8 Netherrückstände."}},
        [64998] = {"Einen Vorteil gewinnen",{"Bringt dem Abgesandten Mordin in Shattrath 8 Netherrückstände."}},
        [64999] = {"Einen Vorteil gewinnen",{"Bringt dem Abgesandten Mordin in Shattrath 8 Netherrückstände."}},
        [78752] = {"Todesbeweise: Titanenrune mit Protokoll Gamma",{"Erzmagier Lan'dalock in Dalaran möchte, dass Ihr ihm ein Medaillon der Entweihten von einem beliebigen, finalen Dungeonboss bringt.","","Diese Quest kann nur in einem Titanenrunendungeon mit aktivem Protokoll Gamma abgeschlossen werden."}},
        [78753] = {"Todesbeweise: Bedrohungen für Azeroth",{"Erzmagier Lan'dalock in Dalaran möchte, dass Ihr ihm ein geheimnisvolles Artefakt von einem beliebigen, finalen Dungeonboss bringt.","","Diese Quest kann nur in einem heroischen Dungeon abgeschlossen werden."}},
    }]])
elseif GetLocale() == "esES" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"Lograr ventaja",{"Llévale 8 residuos abisales al emisario Mordin en la Ciudad de Shattrath."}},
        [64998] = {"Lograr ventaja",{"Llévale 8 residuos abisales al emisario Mordin en la Ciudad de Shattrath."}},
        [64999] = {"Lograr ventaja",{"Llévale 8 residuos abisales al emisario Mordin en la Ciudad de Shattrath."}},
        [78752] = {"Prueba de defunción: protocolo Gamma de runa titánica",{"El archimago Lan'dalock de Dalaran quiere que regreses con el medallón del profanador que se consigue del último jefe de cualquier mazmorra.","","Esta misión solo se puede completar en la dificultad de mazmorra protocolo Gamma de runa titánica."}},
        [78753] = {"Prueba de defunción: amenazas a Azeroth",{"El archimago Lan'dalock de Dalaran quiere que regreses con el artefacto misterioso que se consigue del último jefe de cualquier mazmorra.","","Esta misión solo se puede completar en la dificultad de mazmorra heroica."}},
    }]])
elseif GetLocale() == "esMX" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"Lograr ventaja",{"Llévale 8 residuos abisales al emisario Mordin en la Ciudad de Shattrath."}},
        [64998] = {"Lograr ventaja",{"Llévale 8 residuos abisales al emisario Mordin en la Ciudad de Shattrath."}},
        [64999] = {"Lograr ventaja",{"Llévale 8 residuos abisales al emisario Mordin en la Ciudad de Shattrath."}},
        [78752] = {"Prueba de defunción: Protocolo gamma de runa titánica",{"El archimago Lan'dalock de Dalaran quiere que vuelvas con el medallón de profanador de cualquier jefe final de calabozo.","","Esta misión solo se puede completar en cualquier calabozo de dificultad Protocolo gamma de runa titánica."}},
        [78753] = {"Prueba de defunción: Amenazas contra Azeroth",{"El archimago Lan'dalock de Dalaran quiere que vuelvas con el artefacto misterioso de cualquier jefe final de calabozo.","","Esta misión solo se puede completar en cualquier calabozo de dificultad heroica."}},
    }]])
elseif GetLocale() == "frFR" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"Prendre l'avantage",{"Apportez 8 Résidus de Néant à l'Émissaire Mordin, à Shattrath."}},
        [64998] = {"Prendre l'avantage",{"Apportez 8 Résidus de Néant à l'Émissaire Mordin, à Shattrath."}},
        [64999] = {"Prendre l'avantage",{"Apportez 8 Résidus de Néant à l'Émissaire Mordin, à Shattrath."}},
        [78752] = {"Preuves de la mort : protocole Gamma de rune des Titans",{"L’archimage Lan’dalock de Dalaran vous demande de revenir avec le médaillon des Profanateurs, obtenu auprès d’un boss final ou d’une boss finale de donjon.","","Cette quête peut être achevée dans les donjons de runes des Titans avec protocole Gamma."}},
        [78753] = {"Preuves de la mort : menaces pour Azeroth",{"L’archimage Lan’dalock de Dalaran vous demande de revenir avec le mystérieux artéfact obtenu auprès d’un boss final ou d’une boss finale de donjon.","","Cette quête peut être achevée dans les donjons en mode héroïque."}},
    }]])
elseif GetLocale() == "koKR" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"공격대 지원",{"샤트라스에 있는 사절 모르딘에게 황천의 잔류물 8개를 가져가야 합니다."}},
        [64998] = {"공격대 지원",{"샤트라스에 있는 사절 모르딘에게 황천의 잔류물 8개를 가져가야 합니다."}},
        [64999] = {"공격대 지원",{"샤트라스에 있는 사절 모르딘에게 황천의 잔류물 8개를 가져가야 합니다."}},
        [78752] = {"죽음의 증거: 티탄 룬 프로토콜 감마",{"던전 최종 우두머리를 처치하고 모독자의 메달을 획득해 달라란에 있는 대마법사 랜달록에게 가져가야 합니다.","","본 퀘스트는 티탄 룬 프로토콜 감마 던전 난이도로만 완료할 수 있습니다."}},
        [78753] = {"죽음의 증거: 아제로스의 위협",{"던전 최종 우두머리를 처치하고 수수께끼의 유물을 획득해 달라란에 있는 대마법사 랜달록에게 가져가야 합니다.","","본 퀘스트는 영웅 던전 난이도로만 완료할 수 있습니다."}},
    }]])
elseif GetLocale() == "ptBR" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"Tomando a dianteira",{"Leve 8 Resíduos de Éter ao Emissário Mordin em Shattrath."}},
        [64998] = {"Tomando a dianteira",{"Leve 8 Resíduos de Éter ao Emissário Mordin em Shattrath."}},
        [64999] = {"Tomando a dianteira",{"Leve 8 Resíduos de Éter ao Emissário Mordin em Shattrath."}},
        [78752] = {"Prova da Morte: Protocolo Gama de Runa Titânica",{"O Arquimago Lan'dalock, em Dalaran, quer que você retorne com o Medalhão do Profanador de qualquer chefe de masmorra final.","","Esta missão só pode ser concluída em qualquer masmorra no modo Protocolo Gama de Runa Titânica."}},
        [78753] = {"Prova da Morte: Ameaças a Azeroth",{"O Arquimago Lan'dalock, em Dalaran, quer que você retorne com o Artefato Misterioso de qualquer chefe de masmorra final.","","Esta missão só pode ser concluída em qualquer masmorra no modo Heroico."}},
    }]])
elseif GetLocale() == "ruRU" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"Обретение преимущества",{"Принесите 8 горстей пыли Пустоты эмиссару Мордину в Шаттрат."}},
        [64998] = {"Обретение преимущества",{"Принесите 8 горстей пыли Пустоты эмиссару Мордину в Шаттрат."}},
        [64999] = {"Обретение преимущества",{"Принесите 8 горстей пыли Пустоты эмиссару Мордину в Шаттрат."}},
        [78752] = {"Доказательство смерти: руна титанов – протокол \"Гамма\"",{"Верховный маг Лан'далок в Даларане просит вас принести ему медальон Осквернителя, который можно получить за победу над любым из финальных боссов подземелий.","","Это задание можно выполнить на любом уровне сложности подземелья с руной титанов и защитным протоколом \"Гамма\"."}},
        [78753] = {"Доказательство смерти: угрозы безопасности Азерота",{"Верховный маг Лан'далок в Даларане просит вас принести ему таинственный артефакт, который можно получить за победу над любым из финальных боссов подземелий.","","Это задание можно выполнить только в героическом режиме."}},
    }]])
elseif GetLocale() == "zhCN" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"占据上风",{"给沙塔斯城的摩尔丁特使带去8份虚空残渣。"}},
        [64998] = {"占据上风",{"给沙塔斯城的摩尔丁特使带去8份虚空残渣。"}},
        [64999] = {"占据上风",{"给沙塔斯城的摩尔丁特使带去8份虚空残渣。"}},
        [78752] = {"死亡证明：泰坦符文协议伽马",{"达拉然的大法师兰达洛克要你从任意地下城的最终首领处取回污染者的勋章。","","该任务必须在泰坦符文协议伽马难度的地下城中完成。"}},
        [78753] = {"死亡证明：艾泽拉斯的威胁",{"达拉然的大法师兰达洛克要你从任意地下城的最终首领处取回神秘的古器。","","该任务必须在英雄难度的地下城中完成。"}},
        [83713] = {"死亡证明：泰坦符文协议阿尔法",{"达拉然的大法师兰达洛克要你从任意地下城的最终首领处取回污染者的勋章。","","该任务必须在泰坦符文协议阿尔法难度的地下城中完成。"}},
        [83714] = {"死亡证明：艾泽拉斯的威胁",{"达拉然的大法师兰达洛克要你从任意地下城的最终首领处取回神秘的古器。","","该任务必须在英雄难度的地下城中完成。"}},
        [83717] = {"死亡证明：泰坦符文协议贝塔",{"达拉然的大法师兰达洛克要你从任意地下城的最终首领处取回污染者的勋章。","","该任务必须在泰坦符文协议贝塔难度的地下城中完成。"}},
        [87379] = {"死亡证明：艾泽拉斯的威胁",{"达拉然的大法师兰达洛克要你从任意地下城的最终首领处取回神秘的古器。","","该任务必须在英雄难度的地下城中完成。"}},
        [93975] = {"拉格纳罗斯必须死！",{"团队消灭拉格纳罗斯。"}},
        [94577] = {"凯尔萨斯必须死！",{"消灭风暴要塞的凯尔萨斯逐日者。"}},
    }]])
elseif GetLocale() == "zhTW" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"取得優勢",{"將8個虛空殘渣交給撒塔斯城中的大使莫爾丁。"}},
        [64998] = {"取得優勢",{"將8個虛空殘渣交給撒塔斯城中的大使莫爾丁。"}},
        [64999] = {"取得優勢",{"將8個虛空殘渣交給撒塔斯城中的大使莫爾丁。"}},
        [78752] = {"死亡證明：泰坦符文伽瑪系統",{"大法師朗達拉克要你帶回從任一地城中的最後首領身上取得的褻瀆者勳章。","","這個任務只能在任一泰坦符文伽瑪系統難度地城中完成。"}},
        [78753] = {"死亡證明：艾澤拉斯的威脅",{"大法師朗達拉克要你帶回從任一地城中的最後首領身上取得的神秘的古器。","","這個任務只能在任一英雄難度地城中完成。"}},
    }]])
end
