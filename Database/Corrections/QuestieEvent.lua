--[[
Feast of Winter Veil	1.2.0	18 December 2004	
Noblegarden	1.3.0	7 March 2005	X
Children's Week	1.4.0	5 May 2005	
Darkmoon Faire	1.6.0	2 July 2005	
Harvest Festival	1.6.0	2 July 2005	X
Hallow's End	1.8.0	10 October 2005	
Lunar Festival	1.9.0	3 January 2006	X
Love is in the Air	1.9.3	7 February 2006	
Midsummer Fire Festival	1.11.0	20 June 2006	
Peon Day	1.12.1	22 August 2006	X

New Year	31st Dec - 1st Jan	New Year's Eve	Gregorian calendar
Lunar Festival	Varies (Spring)	Lunar New Year	Chinese calendar
Love is in the Air	7th Feb - 20th Feb	Valentine's Day	
Noblegarden	Varies (Easter)	Easter	
Children's Week	1st May - 7th May	Children's Day - Japan
Mother's Day - US (and in most other countries, including: Belgium and the Netherlands)	
Midsummer Fire Festival	21st June - 5th July	Midsummer
Canada Day - CAN
Independence Day - US	US observed! Fire in the Sky Engineers' Explosive Extravaganza
Pirates' Day	19th Sept	International Talk Like a Pirate Day	First observed Sept 19th, 2008.
Brewfest	20th Sept - 4th Oct	Oktoberfest - Germany	
Harvest Festival	27th Sept - 4th Oct	Roughly Thanksgiving - Canada, US (actually celebrated in October and November in Canada and US, respectively)
Columbus Day - US
US Stress Test ended: September 12, 2004	
Peon Day	30th Sept	EU Closed Beta began: September 30, 2004	Observed only in Europe[1]
Hallow's End	18th Oct - 1st Nov	Halloween	
Day of the Dead	1st Nov - 2nd Nov	Day of the Dead	
WoW's Anniversary	16th Nov - 30th Nov		
Pilgrim's Bounty	22nd Nov - 28th Nov	Thanksgiving	
Feast of Winter Veil	15th Dec - 2nd Jan	Christmas	
]]--

QuestieEvent = {}
QuestieEvent.activeQuests = {}

function QuestieEvent:Load()
  local month = tonumber(date("%m"));
  local day = tonumber(date("%d"));
  local year = date("%y");

  --We want to replace the lunarharvest date with the date that we estimate
  QuestieEvent.eventDates["LunarFestival"] = QuestieEvent.lunarHarvest[year];

  local activeEvents = {}

  for eventName, eventData in pairs(QuestieEvent.eventDates) do
    local startDay, startMonth = strsplit("/", eventData.startDate);
    local endDay, endMonth = strsplit("/", eventData.endDate);

    -- startDate = "15/12",
    -- endDate = "2/1",
    if((day >= tonumber(startDay) and month == tonumber(startMonth)) or (day <= tonumber(endDay) and month == tonumber(endMonth))) then
      Questie:Debug(DEBUG_INFO, "[QuestieEvent]", eventName, "event is active!");
      activeEvents[eventName] = true;
    end
  end

  for index, questData in pairs(QuestieEvent.eventQuests) do
    local eventName = questData[1];
    local questId = questData[2];
    if(activeEvents[eventName] == true) then
      QuestieCorrections.hiddenQuests[questId] = nil;
      QuestieEvent.activeQuests[questId] = true;
    end
  end

  --Clear the quests to save memory
  QuestieEvent.eventQuests = nil;

end



--EUROPEAN FORMAT! NO FUCKING AMERICAN SHIDAZZLE FORMAT!
QuestieEvent.eventDates = {
  ["LunarFestival"] = {-- WARNING THIS DATE VARIES!!!!
    startDate="24/1",
    endDate="7/2",
  },
  ["LoveIsInTheAir"] = {
    startDate = "7/2",
    endDate = "20/2",
  },
  ["Noblegarden"] = {-- WARNING THIS DATE VARIES!!!!
    startDate = "13/5",
    endDate = "19/5",
  },
  ["ChildrensWeek"] = {
    startDate = "1/6",
    endDate = "7/6",
  },
  ["MidsummerFireFestival"] = {
    startDate = "13/5",
    endDate = "19/5",
  },
  ["HarvestFestival"] = {
    startDate = "27/9",
    endDate = "4/10",
  },
  ["PeonDay"] = {
    startDate = "30/9",
    endDate = "30/9",
  },
  ["HallowsEnd"] = {
    startDate = "18/10",
    endDate = "1/11",
  },
  ["WinterVeil"] = {
    startDate = "15/12",
    endDate = "2/1",
  },
}

QuestieEvent.lunarHarvest = {
  ["19"] = {
    startDate = "5/2",
    endDate="19/2",
  },
  ["20"] = {
    startDate = "24/1",
    endDate="7/2",
  },
  --Below are estimates
  ["21"] = {
    startDate = "12/2",
    endDate="26/2",
  },
  ["22"] = {
    startDate = "1/2",
    endDate="15/2",
  },
  ["23"] = {
    startDate = "22/1",
    endDate="5/2",
  },
  ["24"] = {
    startDate = "10/2",
    endDate="24/2",
  },
  ["25"] = {
    startDate = "29/1",
    endDate="12/2",
  },
  ["26"] = {
    startDate = "17/2",
    endDate="3/3",
  },
  ["27"] = {
    startDate = "7/2",
    endDate="21/2",
  },
  ["28"] = {
    startDate = "27/1",
    endDate="10/2",
  },
}

--This variable will be cleared at the end of the load, do not use, use QuestieEvent.activeQuests.
QuestieEvent.eventQuests = {}
table.insert(QuestieEvent.eventQuests, {"HallowsEnd", 8373}) --The Power of Pine
table.insert(QuestieEvent.eventQuests, {"HallowsEnd", 1658}) --Crashing the Wickerman Festival
table.insert(QuestieEvent.eventQuests, {"HallowsEnd", 8311}) --Hallow's End Treats for Jesper!
table.insert(QuestieEvent.eventQuests, {"HallowsEnd", 8312}) --Hallow's End Treats for Spoops!
table.insert(QuestieEvent.eventQuests, {"HallowsEnd", 8322}) --Rotten Eggs
table.insert(QuestieEvent.eventQuests, {"HallowsEnd", 1657}) --Stinking Up Southshore
table.insert(QuestieEvent.eventQuests, {"HallowsEnd", 8409}) --Ruined Kegs
table.insert(QuestieEvent.eventQuests, {"HallowsEnd", 8357}) --Dancing for Marzipan
table.insert(QuestieEvent.eventQuests, {"HallowsEnd", 8355}) --Incoming Gumdrop
table.insert(QuestieEvent.eventQuests, {"HallowsEnd", 8356}) --Flexing for Nougat
table.insert(QuestieEvent.eventQuests, {"HallowsEnd", 8358}) --Incoming Gumdrop
table.insert(QuestieEvent.eventQuests, {"HallowsEnd", 8353}) --Chicken Clucking for a Mint
table.insert(QuestieEvent.eventQuests, {"HallowsEnd", 8359}) --Flexing for Nougat
table.insert(QuestieEvent.eventQuests, {"HallowsEnd", 8354}) --Chicken Clucking for a Mint
table.insert(QuestieEvent.eventQuests, {"HallowsEnd", 8360}) --Dancing for Marzipan
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7902}) --Vibrant Plumes
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7903}) --Evil Bat Eyes
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 8222}) --Glowing Scorpid Blood
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7901}) --Soft Bushy Tails
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 6983}) --You're a Mean One...
table.insert(QuestieEvent.eventQuests, {"ChildrensWeek", 5502}) --A Warden of the Horde
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7899}) --Small Furry Paws
table.insert(QuestieEvent.eventQuests, {"ChildrensWeek", 172}) --Children's Week
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7940}) --1200 Tickets - Orb of the Darkmoon
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7900}) --Torn Bear Pelts
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8684}) --Dreamseer the Elder
table.insert(QuestieEvent.eventQuests, {"HarvestFestival", 8149}) --Honoring a Hero
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7907}) --Darkmoon Beast Deck
table.insert(QuestieEvent.eventQuests, {"HarvestFestival", 8150}) --Honoring a Hero
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7929}) --Darkmoon Elementals Deck
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 7043}) --You're a Mean One...
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7928}) --Darkmoon Warlords Deck
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7946}) --Spawn of Jubjub
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7927}) --Darkmoon Portals Deck
table.insert(QuestieEvent.eventQuests, {"ChildrensWeek", 171}) --A Warden of the Alliance
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 8223}) --More Glowing Scorpid Blood
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7934}) --50 Tickets - Darkmoon Storage Box
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 6984}) --A Smokywood Pastures' Thank You!
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7981}) --1200 Tickets - Amulet of the Darkmoon
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7943}) --More Bat Eyes
table.insert(QuestieEvent.eventQuests, {"ChildrensWeek", 1468}) --Children's Week
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7898}) --Thorium Widget
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8635}) --Splitrock the Elder
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 7045}) --A Smokywood Pastures' Thank You!
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 7063}) --The Feast of Winter Veil
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8713}) --Starsong the Elder
table.insert(QuestieEvent.eventQuests, {"ChildrensWeek", 1558}) --The Stonewrought Dam
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7885}) --Armor Kits
table.insert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9388}) --Flickering Flames in Kalimdor
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 7061}) --The Feast of Winter Veil
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8883}) --Valadar Starsong
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7933}) --40 Tickets - Greater Darkmoon Prize
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7894}) --Copper Modulator
table.insert(QuestieEvent.eventQuests, {"ChildrensWeek", 915}) --You Scream, I Scream...
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8867}) --Lunar Fireworks
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7942}) --More Thorium Widgets
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7883}) --The World's Largest Gnome!
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7892}) --Big Black Mace
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7937}) --Your Fortune Awaits You...
table.insert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9365}) --A Thief's Reward
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7939}) --More Dense Grinding Stones
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 7025}) --Treats for Greatfather Winter
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 8828}) --Winter's Presents
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 6963}) --Stolen Winter Veil Treats
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7893}) --Rituals of Strength
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7891}) --Green Iron Bracers
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 9249}) --40 Tickets - Schematic: Steam Tonk Controller
table.insert(QuestieEvent.eventQuests, {"ChildrensWeek", 4822}) --You Scream, I Scream...
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 8827}) --Winter's Presents
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 9339}) --A Thief's Reward
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7896}) --Green Fireworks
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8865}) --Festive Lunar Pant Suits
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 8571}) --<UNUSED> Armor Kits
table.insert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9389}) --Flickering Flames in the Eastern Kingdoms
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7884}) --Crocolisk Boy and the Bearded Murloc
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 6962}) --Treats for Great-father Winter
table.insert(QuestieEvent.eventQuests, {"ChildrensWeek", 1687}) --Spooky Lighthouse
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7895}) --Whirring Bronze Gizmo
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 6964}) --The Reason for the Season
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8642}) --Silvervein the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8866}) --Bronzebeard the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8643}) --Highpeak the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8864}) --Festive Lunar Dresses
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7882}) --Carnival Jerkins
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8678}) --Proudhorn the Elder
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 8763}) --The Hero of the Day
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7897}) --Mechanical Repair Kits
table.insert(QuestieEvent.eventQuests, {"ChildrensWeek", 558}) --Jaina's Autograph
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8670}) --Runetotem the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8725}) --Riversong the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8683}) --Dawnstrider the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8879}) --Large Rockets
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7941}) --More Armor Kits
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7881}) --Carnival Boots
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8716}) --Starglade the Elder
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7890}) --Heavy Grinding Stone
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8650}) --Snowcrown the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8876}) --Small Rockets
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8874}) --The Lunar Festival
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8880}) --Cluster Rockets
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 8769}) --A Ticking Present
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8722}) --Meadowrun the Elder
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7945}) --Your Fortune Awaits You...
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7906}) --Darkmoon Cards - Beasts
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 8768}) --A Gaily Wrapped Present
table.insert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9323}) --Wild Fires in the Eastern Kingdoms
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7889}) --Coarse Weightstone
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8652}) --Graveborn the Elder
--table.insert(QuestieEvent.eventQuests, {"-1006", 8861}) --New Year Celebrations!
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 6961}) --Great-father Winter is Here!
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8878}) --Festive Recipes
table.insert(QuestieEvent.eventQuests, {"ChildrensWeek", 925}) --Cairne's Hoofprint
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8873}) --The Lunar Festival
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8720}) --Skygleam the Elder
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 7042}) --Stolen Winter Veil Treats
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8673}) --Bloodhoof the Elder
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 7021}) --Great-father Winter is Here!
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 7062}) --The Reason for the Season
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7935}) --10 Tickets - Last Month's Mutton
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7938}) --Your Fortune Awaits You...
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7944}) --Your Fortune Awaits You...
table.insert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9319}) --A Light in Dark Places
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8875}) --The Lunar Festival
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7930}) --5 Tickets - Darkmoon Flower
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 8767}) --A Gently Shaken Gift
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8862}) --Elune's Candle
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8723}) --Nightwind the Elder
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 8799}) --The Hero of the Day
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8681}) --Thunderhorn the Elder
table.insert(QuestieEvent.eventQuests, {"ChildrensWeek", 1479}) --The Bough of the Eternals
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8676}) --Wildmane the Elder
table.insert(QuestieEvent.eventQuests, {"ChildrensWeek", 911}) --Gateway to the Frontier
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8651}) --Ironband the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8863}) --Festival Dumplings
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8672}) --Stonespire the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8871}) --The Lunar Festival
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8649}) --Stormbrow the Elder
table.insert(QuestieEvent.eventQuests, {"ChildrensWeek", 1800}) --Lordaeron Throne Room
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8872}) --The Lunar Festival
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 8762}) --Metzen the Reindeer
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8726}) --Brightspear the Elder
table.insert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9367}) --The Festival of Fire
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8877}) --Firework Launcher
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8718}) --Bladeswift the Elder
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 8803}) --A Festive Gift
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 7024}) --Great-father Winter is Here!
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8685}) --Mistwalker the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8653}) --Goldwell the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8671}) --Ragetotem the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8677}) --Darkhorn the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8882}) --Cluster Launcher
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8714}) --Moonstrike the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8645}) --Obsidian the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8717}) --Moonwarden the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8648}) --Darkcore the Elder
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7932}) --12 Tickets - Lesser Darkmoon Prize
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 8744}) --A Carefully Wrapped Present
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8715}) --Bladeleaf the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8646}) --Hammershout the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8724}) --Morningdew the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8727}) --Farwhisper the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8679}) --Grimtotem the Elder
table.insert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9368}) --The Festival of Fire
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 8746}) --Metzen the Reindeer
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8647}) --Bellowrage the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8674}) --Winterhoof the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8680}) --Windtotem the Elder
table.insert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9386}) --A Light in Dark Places
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7931}) --5 Tickets - Minor Darkmoon Prize
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8686}) --High Mountain the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8654}) --Primestone the Elder
--table.insert(QuestieEvent.eventQuests, {"-1006", 8860}) --New Year Celebrations!
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8721}) --Starweave the Elder
table.insert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9324}) --Stealing Orgrimmar's Flame
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7904}) --<UNUSED>
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8881}) --Large Cluster Rockets
table.insert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9331}) --Stealing Ironforge's Flame
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 7022}) --Greatfather Winter is Here!
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8619}) --Morndeep the Elder
table.insert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9326}) --Stealing the Undercity's Flame
table.insert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9332}) --Stealing Darnassus's Flame
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 7023}) --Greatfather Winter is Here!
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8688}) --Windrun the Elder
table.insert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9330}) --Stealing Stormwind's Flame
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8682}) --Skyseer the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8636}) --Rumblerock the Elder
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8644}) --Stonefort the Elder
table.insert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9322}) --Wild Fires in Kalimdor
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8675}) --Skychaser the Elder
table.insert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7936}) --50 Tickets - Last Year's Mutton
table.insert(QuestieEvent.eventQuests, {"ChildrensWeek", 910}) --Down at the Docks
table.insert(QuestieEvent.eventQuests, {"LunarFestival", 8719}) --Bladesing the Elder
table.insert(QuestieEvent.eventQuests, {"WinterVeil", 8788}) --A Gently Shaken Gift
table.insert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9325}) --Stealing Thunder Bluff's Flame