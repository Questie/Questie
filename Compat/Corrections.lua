---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

if QuestieCompat.WOW_PROJECT_ID < QuestieCompat.WOW_PROJECT_WRATH_CLASSIC then return end

QuestieCompat.RegisterCorrection("questData", function()
	local questKeys = QuestieDB.questKeys

	return {
        [12372] = {
            [questKeys.objectivesText] = {"Afrasastrasz at Wyrmrest Temple has asked you to slay 3 Azure Dragons, slay 5 Azure Drakes, and to destabilize the Azure Dragonshrine while riding a Wyrmrest Defender into battle."},
        },
        [12435] = {
            [questKeys.name] = "Report to Lord Afrasastrasz",
            [questKeys.objectivesText] = {"Speak with Lord Afrasastrasz at Wyrmrest Temple."},
        },
		[24656] = {
			[questKeys.objectives] = {nil,nil,nil,nil,nil,{{71522}}},
        },
		[24541] = {
			[questKeys.objectives] = {nil,nil,nil,nil,nil,{{71539}}},
        },
	}
end)

QuestieCompat.RegisterCorrection("npcData", function()
	local npcKeys = QuestieDB.npcKeys

	return {
        [27575] = {
            [npcKeys.name] = "Lord Afrasastrasz",
        },
	}
end)

QuestieCompat.RegisterBlacklist("hiddenQuests", function()
    return {
        -- "Zalazane's Fall" event quests
        [25444] = true, --* Da Perfect Spies (https://www.wowhead.com/wotlk/quest=25444) (Retail Data)
        [25445] = true, --* Zalazane's Fall (https://www.wowhead.com/wotlk/quest=25445) (Retail Data)
        [25446] = true, --* Frogs Away! (https://www.wowhead.com/wotlk/quest=25446) (Retail Data)
        [25461] = true, --* Trollin' For Volunteers (https://www.wowhead.com/wotlk/quest=25461) (Retail Data)
        [25470] = true, --* Lady Of Da Tigers (https://www.wowhead.com/wotlk/quest=25470) (Retail Data)
        [25480] = true, --* Dance Of De Spirits (https://www.wowhead.com/wotlk/quest=25480) (Retail Data)
        [25495] = true, --* Preparin' For Battle (https://www.wowhead.com/wotlk/quest=25495) (Retail Data)

        -- "Operation: Gnomeregan" event quests
        [25199] = true, --* Basic Orders (https://www.wowhead.com/wotlk/quest=25199) (Retail Data)
        [25212] = true, --* Vent Horizon (https://www.wowhead.com/wotlk/quest=25212) (Retail Data)
        [25229] = true, --* A Few Good Gnomes (https://www.wowhead.com/wotlk/quest=25229) (Retail Data)
        [25283] = true, --* Prepping the Speech (https://www.wowhead.com/wotlk/quest=25283) (Retail Data)
        [25285] = true, --* In and Out (https://www.wowhead.com/wotlk/quest=25285) (Retail Data)
        [25286] = true, --* Words for Delivery (https://www.wowhead.com/wotlk/quest=25286) (Retail Data)
        [25287] = true, --* Words for Delivery (https://www.wowhead.com/wotlk/quest=25287) (Retail Data)
        [25289] = true, --* One Step Forward... (https://www.wowhead.com/wotlk/quest=25289) (Retail Data)
        [25295] = true, --* Press Fire (https://www.wowhead.com/wotlk/quest=25295) (Retail Data)
        [25393] = true, --* Operation: Gnomeregan (https://www.wowhead.com/wotlk/quest=25393) (Retail Data)
        [25500] = true, --* Words for Delivery (https://www.wowhead.com/wotlk/quest=25500) (Retail Data)

        -- heroic daily dungeon quests
        [13240] = false, --* Timear Foresees Centrifuge Constructs in your Future! (https://www.wowhead.com/wotlk/quest=13240) (Retail Data)
        [13241] = false, --* Timear Foresees Ymirjar Berserkers in your Future! (https://www.wowhead.com/wotlk/quest=13241) (Retail Data)
        [13243] = false, --* Timear Foresees Infinite Agents in your Future! (https://www.wowhead.com/wotlk/quest=13243) (Retail Data)
        [13244] = false, --* Timear Foresees Titanium Vanguards in your Future! (https://www.wowhead.com/wotlk/quest=13244) (Retail Data)
        [13245] = false, --* Proof of Demise: Ingvar the Plunderer (https://www.wowhead.com/wotlk/quest=13245) (Retail Data)
        [13246] = false, --* Proof of Demise: Keristrasza (https://www.wowhead.com/wotlk/quest=13246) (Retail Data)
        [13247] = false, --* Proof of Demise: Ley-Guardian Eregos (https://www.wowhead.com/wotlk/quest=13247) (Retail Data)
        [13248] = false, --* Proof of Demise: King Ymiron (https://www.wowhead.com/wotlk/quest=13248) (Retail Data)
        [13249] = false, --* Proof of Demise: The Prophet Tharon'ja (https://www.wowhead.com/wotlk/quest=13249) (Retail Data)
        [13250] = false, --* Proof of Demise: Gal'darah (https://www.wowhead.com/wotlk/quest=13250) (Retail Data)
        [13251] = false, --* Proof of Demise: Mal'Ganis (https://www.wowhead.com/wotlk/quest=13251) (Retail Data)
        [13252] = false, --* Proof of Demise: Sjonnir The Ironshaper (https://www.wowhead.com/wotlk/quest=13252) (Retail Data)
        [13253] = false, --* Proof of Demise: Loken (https://www.wowhead.com/wotlk/quest=13253) (Retail Data)
        [13254] = false, --* Proof of Demise: Anub'arak (https://www.wowhead.com/wotlk/quest=13254) (Retail Data)
        [13255] = false, --* Proof of Demise: Herald Volazj (https://www.wowhead.com/wotlk/quest=13255) (Retail Data)
        [13256] = false, --* Proof of Demise: Cyanigosa (https://www.wowhead.com/wotlk/quest=13256) (Retail Data)
        [14199] = false, --* Proof of Demise: The Black Knight (https://www.wowhead.com/wotlk/quest=14199) (Retail Data)
    }
end)