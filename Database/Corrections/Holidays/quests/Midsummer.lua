---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

local tinsert = table.insert
local eventQuests = QuestieEvent.eventQuests

tinsert(eventQuests, {"Midsummer", 9324}) -- Stealing Orgrimmar's Flame
tinsert(eventQuests, {"Midsummer", 9325}) -- Stealing Thunder Bluff's Flame
tinsert(eventQuests, {"Midsummer", 9326}) -- Stealing the Undercity's Flame
tinsert(eventQuests, {"Midsummer", 9330}) -- Stealing Stormwind's Flame
tinsert(eventQuests, {"Midsummer", 9331}) -- Stealing Ironforge's Flame
tinsert(eventQuests, {"Midsummer", 9332}) -- Stealing Darnassus's Flame
tinsert(eventQuests, {"Midsummer", 9339}) -- A Thief's Reward
tinsert(eventQuests, {"Midsummer", 9365}) -- A Thief's Reward

-- Removed in TBC
tinsert(eventQuests, {"Midsummer", 9388, nil, nil, Expansions.Current >= Expansions.Cata}) -- Flickering Flames in Kalimdor
tinsert(eventQuests, {"Midsummer", 9389, nil, nil, Expansions.Current >= Expansions.Cata}) -- Flickering Flames in the Eastern Kingdoms
tinsert(eventQuests, {"Midsummer", 9319, nil, nil, Expansions.Current >= Expansions.Cata}) -- A Light in Dark Places
tinsert(eventQuests, {"Midsummer", 9386, nil, nil, Expansions.Current >= Expansions.Cata}) -- A Light in Dark Places
tinsert(eventQuests, {"Midsummer", 9367, nil, nil, Expansions.Current >= Expansions.Cata}) -- The Festival of Fire
tinsert(eventQuests, {"Midsummer", 9368, nil, nil, Expansions.Current >= Expansions.Cata}) -- The Festival of Fire
tinsert(eventQuests, {"Midsummer", 9322, nil, nil, Expansions.Current >= Expansions.Cata}) -- Wild Fires in Kalimdor
tinsert(eventQuests, {"Midsummer", 9323, nil, nil, Expansions.Current >= Expansions.Cata}) -- Wild Fires in the Eastern Kingdoms

-- TBC quests
tinsert(eventQuests, {"Midsummer", 11580}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11581}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11583}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11584}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11657}) -- Torch Catching
tinsert(eventQuests, {"Midsummer", 11691, nil, nil, Expansions.Current >= Expansions.Cata}) -- Summon Ahune
tinsert(eventQuests, {"Midsummer", 11696, nil, nil, Expansions.Current >= Expansions.Cata}) -- Ahune is Here!
tinsert(eventQuests, {"Midsummer", 11731}) -- Torch Tossing
tinsert(eventQuests, {"Midsummer", 11732}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11734}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11735}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11736}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11737}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11738}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11739}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11740}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11741}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11742}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11743}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11744}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11745}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11746}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11747}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11748, nil, nil, Expansions.Current >= Expansions.Cata}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11749}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11750}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11751}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11752}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11753}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11754}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11755}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11756}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11757}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11758}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11759}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11760}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11761}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11762}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11763}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11764}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11765}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11766}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11767}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11768}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11769}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11770}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11771}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11772}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11773}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11774}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11775}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11776}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11777}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11778}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11779}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11780}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11781}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11782}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11783}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11784}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11785, nil, nil, Expansions.Current >= Expansions.Cata}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11786}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11787}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11799}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11800}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11801}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11802}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11803}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11804}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11805}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11806}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11807}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11808}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11809}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11810}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11811}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11812}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11813}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11814}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11815}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11816}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11817}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11818}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11819, nil, nil, Expansions.Current >= Expansions.Cata}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11820}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11821}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11822}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11823}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11824}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11825}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11826}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11827}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11828}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11829}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11830}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11831}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11832}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11833}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11834}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11835}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11836}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11837}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11838}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11839}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11840}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11841}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11842}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11843}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11844}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11845}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11846}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11847}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11848}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11849}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11850}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11851}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11852}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11853}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11854}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11855}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11856}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11857}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11858}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11859}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11860}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11861, nil, nil, Expansions.Current >= Expansions.Cata}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11862}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11863}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11882}) -- Playing with Fire
tinsert(eventQuests, {"Midsummer", 11886}) -- Unusual Activity
tinsert(eventQuests, {"Midsummer", 11891}) -- An Innocent Disguise
tinsert(eventQuests, {"Midsummer", 11915}) -- Playing with Fire
tinsert(eventQuests, {"Midsummer", 11917}) -- Striking Back (level 22)
tinsert(eventQuests, {"Midsummer", 11921}) -- Midsummer
tinsert(eventQuests, {"Midsummer", 11922}) -- Midsummer
tinsert(eventQuests, {"Midsummer", 11923}) -- Torch Catching
tinsert(eventQuests, {"Midsummer", 11924}) -- More Torch Catching
tinsert(eventQuests, {"Midsummer", 11925}) -- More Torch Catching
tinsert(eventQuests, {"Midsummer", 11926}) -- Midsummer
tinsert(eventQuests, {"Midsummer", 11933}) -- Stealing the Exodar's Flame
tinsert(eventQuests, {"Midsummer", 11935}) -- Stealing Silvermoon's Flame
tinsert(eventQuests, {"Midsummer", 11947}) -- Striking Back (level 32)
tinsert(eventQuests, {"Midsummer", 11948}) -- Striking Back (level 43)
tinsert(eventQuests, {"Midsummer", 11952}) -- Striking Back (level 51)
tinsert(eventQuests, {"Midsummer", 11953}) -- Striking Back (level 60)
tinsert(eventQuests, {"Midsummer", 11954}) -- Striking Back (level 67)
tinsert(eventQuests, {"Midsummer", 11955, nil, nil, Expansions.Current >= Expansions.Cata}) -- Ahune, the Frost Lord
tinsert(eventQuests, {"Midsummer", 11972}) -- Shards of Ahune
tinsert(eventQuests, {"Midsummer", 11964}) -- Incense for the Summer Scorchlings
tinsert(eventQuests, {"Midsummer", 11966}) -- Incense for the Festival Scorchlings
tinsert(eventQuests, {"Midsummer", 11970}) -- The Master of Summer Lore
tinsert(eventQuests, {"Midsummer", 11971}) -- The Spinner of Summer Tales
tinsert(eventQuests, {"Midsummer", 12012}) -- Inform the Elder

-- WotLK quests
tinsert(eventQuests, {"Midsummer", 13440}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13441}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13442}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13443}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13444}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13445}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13446}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13447}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13449}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13450}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13451}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13453}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13454}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13455}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13457}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13458}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 13485}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 13486}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 13487}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 13488}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 13489}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 13490}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 13491}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 13492}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 13493}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 13494}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 13495}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 13496}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 13497}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 13498}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 13499}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 13500}) -- Honor the Flame

-- Cata quests
tinsert(eventQuests, {"Midsummer", 28910}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28911}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28912}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28913}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28914}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28915}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28916}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28917}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28918}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28919}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28920}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28921}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28922}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 28923}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 28924}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 28925}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 28926}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 28927}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 28928}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 28929}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 28930}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 28931}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 28932}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 28933}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 28943}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28944}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28945}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 28946}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 28947}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28948}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 28949}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 28950}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 29030}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 29031}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 29036}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 29092}) -- Inform the Elder
