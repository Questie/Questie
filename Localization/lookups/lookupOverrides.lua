---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

if GetLocale() == "deDE" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"Einen Vorteil gewinnen",{"Bringt dem Abgesandten Mordin in Shattrath 8 Netherrückstände."}},
        [64998] = {"Einen Vorteil gewinnen",{"Bringt dem Abgesandten Mordin in Shattrath 8 Netherrückstände."}},
        [64999] = {"Einen Vorteil gewinnen",{"Bringt dem Abgesandten Mordin in Shattrath 8 Netherrückstände."}},
    }]])
elseif GetLocale() == "esES" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"Lograr ventaja",{"Llévale 8 residuos abisales al emisario Mordin en la Ciudad de Shattrath."}},
        [64998] = {"Lograr ventaja",{"Llévale 8 residuos abisales al emisario Mordin en la Ciudad de Shattrath."}},
        [64999] = {"Lograr ventaja",{"Llévale 8 residuos abisales al emisario Mordin en la Ciudad de Shattrath."}},
    }]])
elseif GetLocale() == "esMX" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"Lograr ventaja",{"Llévale 8 residuos abisales al emisario Mordin en la Ciudad de Shattrath."}},
        [64998] = {"Lograr ventaja",{"Llévale 8 residuos abisales al emisario Mordin en la Ciudad de Shattrath."}},
        [64999] = {"Lograr ventaja",{"Llévale 8 residuos abisales al emisario Mordin en la Ciudad de Shattrath."}},
    }]])
elseif GetLocale() == "frFR" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"Prendre l'avantage",{"Apportez 8 Résidus de Néant à l'Émissaire Mordin, à Shattrath."}},
        [64998] = {"Prendre l'avantage",{"Apportez 8 Résidus de Néant à l'Émissaire Mordin, à Shattrath."}},
        [64999] = {"Prendre l'avantage",{"Apportez 8 Résidus de Néant à l'Émissaire Mordin, à Shattrath."}},
    }]])
elseif GetLocale() == "koKR" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"공격대 지원",{"샤트라스에 있는 사절 모르딘에게 황천의 잔류물 8개를 가져가야 합니다."}},
        [64998] = {"공격대 지원",{"샤트라스에 있는 사절 모르딘에게 황천의 잔류물 8개를 가져가야 합니다."}},
        [64999] = {"공격대 지원",{"샤트라스에 있는 사절 모르딘에게 황천의 잔류물 8개를 가져가야 합니다."}},
    }]])
elseif GetLocale() == "ptBR" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"Tomando a dianteira",{"Leve 8 Resíduos de Éter ao Emissário Mordin em Shattrath."}},
        [64998] = {"Tomando a dianteira",{"Leve 8 Resíduos de Éter ao Emissário Mordin em Shattrath."}},
        [64999] = {"Tomando a dianteira",{"Leve 8 Resíduos de Éter ao Emissário Mordin em Shattrath."}},
    }]])
elseif GetLocale() == "ruRU" then
    l10n.questLookupOverrides = loadstring([[return {
        [64997] = {"Обретение преимущества",{"Принесите 8 горстей пыли Пустоты эмиссару Мордину в Шаттрат."}},
        [64998] = {"Обретение преимущества",{"Принесите 8 горстей пыли Пустоты эмиссару Мордину в Шаттрат."}},
        [64999] = {"Обретение преимущества",{"Принесите 8 горстей пыли Пустоты эмиссару Мордину в Шаттрат."}},
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
