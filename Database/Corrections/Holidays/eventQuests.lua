---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")

local tinsert = table.insert
local eventQuests = {}

-- This variable will be cleared at the end of the load, do not use, use QuestieEvent.activeQuests.
QuestieEvent.eventQuests = eventQuests

tinsert(eventQuests, {"Lunar Festival", 8619}) -- Morndeep the Elder
tinsert(eventQuests, {"Lunar Festival", 8635}) -- Splitrock the Elder
tinsert(eventQuests, {"Lunar Festival", 8636}) -- Rumblerock the Elder
tinsert(eventQuests, {"Lunar Festival", 8642}) -- Silvervein the Elder
tinsert(eventQuests, {"Lunar Festival", 8643}) -- Highpeak the Elder
tinsert(eventQuests, {"Lunar Festival", 8644}) -- Stonefort the Elder
tinsert(eventQuests, {"Lunar Festival", 8645}) -- Obsidian the Elder
tinsert(eventQuests, {"Lunar Festival", 8646}) -- Hammershout the Elder
tinsert(eventQuests, {"Lunar Festival", 8647}) -- Bellowrage the Elder
tinsert(eventQuests, {"Lunar Festival", 8648}) -- Darkcore the Elder
tinsert(eventQuests, {"Lunar Festival", 8649}) -- Stormbrow the Elder
tinsert(eventQuests, {"Lunar Festival", 8650}) -- Snowcrown the Elder
tinsert(eventQuests, {"Lunar Festival", 8651}) -- Ironband the Elder
tinsert(eventQuests, {"Lunar Festival", 8652}) -- Graveborn the Elder
tinsert(eventQuests, {"Lunar Festival", 8653}) -- Goldwell the Elder
tinsert(eventQuests, {"Lunar Festival", 8654}) -- Primestone the Elder
tinsert(eventQuests, {"Lunar Festival", 8670}) -- Runetotem the Elder
tinsert(eventQuests, {"Lunar Festival", 8671}) -- Ragetotem the Elder
tinsert(eventQuests, {"Lunar Festival", 8672}) -- Stonespire the Elder
tinsert(eventQuests, {"Lunar Festival", 8673}) -- Bloodhoof the Elder
tinsert(eventQuests, {"Lunar Festival", 8674}) -- Winterhoof the Elder
tinsert(eventQuests, {"Lunar Festival", 8675}) -- Skychaser the Elder
tinsert(eventQuests, {"Lunar Festival", 8676}) -- Wildmane the Elder
tinsert(eventQuests, {"Lunar Festival", 8677}) -- Darkhorn the Elder
tinsert(eventQuests, {"Lunar Festival", 8678}) -- Proudhorn the Elder
tinsert(eventQuests, {"Lunar Festival", 8679}) -- Grimtotem the Elder
tinsert(eventQuests, {"Lunar Festival", 8680}) -- Windtotem the Elder
tinsert(eventQuests, {"Lunar Festival", 8681}) -- Thunderhorn the Elder
tinsert(eventQuests, {"Lunar Festival", 8682}) -- Skyseer the Elder
tinsert(eventQuests, {"Lunar Festival", 8683}) -- Dawnstrider the Elder
tinsert(eventQuests, {"Lunar Festival", 8684}) -- Dreamseer the Elder
tinsert(eventQuests, {"Lunar Festival", 8685}) -- Mistwalker the Elder
tinsert(eventQuests, {"Lunar Festival", 8686}) -- High Mountain the Elder
tinsert(eventQuests, {"Lunar Festival", 8688}) -- Windrun the Elder
tinsert(eventQuests, {"Lunar Festival", 8713}) -- Starsong the Elder
tinsert(eventQuests, {"Lunar Festival", 8714}) -- Moonstrike the Elder
tinsert(eventQuests, {"Lunar Festival", 8715}) -- Bladeleaf the Elder
tinsert(eventQuests, {"Lunar Festival", 8716}) -- Starglade the Elder
tinsert(eventQuests, {"Lunar Festival", 8717}) -- Moonwarden the Elder
tinsert(eventQuests, {"Lunar Festival", 8718}) -- Bladeswift the Elder
tinsert(eventQuests, {"Lunar Festival", 8719}) -- Bladesing the Elder
tinsert(eventQuests, {"Lunar Festival", 8720}) -- Skygleam the Elder
tinsert(eventQuests, {"Lunar Festival", 8721}) -- Starweave the Elder
tinsert(eventQuests, {"Lunar Festival", 8722}) -- Meadowrun the Elder
tinsert(eventQuests, {"Lunar Festival", 8723}) -- Nightwind the Elder
tinsert(eventQuests, {"Lunar Festival", 8724}) -- Morningdew the Elder
tinsert(eventQuests, {"Lunar Festival", 8725}) -- Riversong the Elder
tinsert(eventQuests, {"Lunar Festival", 8726}) -- Brightspear the Elder
tinsert(eventQuests, {"Lunar Festival", 8727}) -- Farwhisper the Elder
tinsert(eventQuests, {"Lunar Festival", 8862, nil, nil, QuestieCorrections.CLASSIC_HIDE}) -- Elune's Candle
tinsert(eventQuests, {"Lunar Festival", 8863, nil, nil, QuestieCorrections.CLASSIC_HIDE}) -- Festival Dumplings
tinsert(eventQuests, {"Lunar Festival", 8864, nil, nil, QuestieCorrections.CLASSIC_HIDE}) -- Festive Lunar Dresses
tinsert(eventQuests, {"Lunar Festival", 8865, nil, nil, QuestieCorrections.CLASSIC_HIDE}) -- Festive Lunar Pant Suits
tinsert(eventQuests, {"Lunar Festival", 8866}) -- Bronzebeard the Elder
tinsert(eventQuests, {"Lunar Festival", 8867}) -- Lunar Fireworks
tinsert(eventQuests, {"Lunar Festival", 8868}) -- Elune's Blessing
tinsert(eventQuests, {"Lunar Festival", 8870}) -- The Lunar Festival
tinsert(eventQuests, {"Lunar Festival", 8871}) -- The Lunar Festival
tinsert(eventQuests, {"Lunar Festival", 8872}) -- The Lunar Festival
tinsert(eventQuests, {"Lunar Festival", 8873}) -- The Lunar Festival
tinsert(eventQuests, {"Lunar Festival", 8874}) -- The Lunar Festival
tinsert(eventQuests, {"Lunar Festival", 8875}) -- The Lunar Festival
tinsert(eventQuests, {"Lunar Festival", 8876, nil, nil, QuestieCorrections.CLASSIC_HIDE}) -- Small Rockets
tinsert(eventQuests, {"Lunar Festival", 8877, nil, nil, QuestieCorrections.CLASSIC_HIDE}) -- Firework Launcher
tinsert(eventQuests, {"Lunar Festival", 8878, nil, nil, QuestieCorrections.CLASSIC_HIDE}) -- Festive Recipes
tinsert(eventQuests, {"Lunar Festival", 8879, nil, nil, QuestieCorrections.CLASSIC_HIDE}) -- Large Rockets
tinsert(eventQuests, {"Lunar Festival", 8880, nil, nil, QuestieCorrections.CLASSIC_HIDE}) -- Cluster Rockets
tinsert(eventQuests, {"Lunar Festival", 8881, nil, nil, QuestieCorrections.CLASSIC_HIDE}) -- Large Cluster Rockets
tinsert(eventQuests, {"Lunar Festival", 8882, nil, nil, QuestieCorrections.CLASSIC_HIDE}) -- Cluster Launcher
tinsert(eventQuests, {"Lunar Festival", 8883}) -- Valadar Starsong
-- Northrend Elders
tinsert(eventQuests, {"Lunar Festival", 13012}) -- Sardis the Elder
tinsert(eventQuests, {"Lunar Festival", 13013}) -- Beldak the Elder
tinsert(eventQuests, {"Lunar Festival", 13014}) -- Morthie the Elder
tinsert(eventQuests, {"Lunar Festival", 13015}) -- Fargal the Elder
tinsert(eventQuests, {"Lunar Festival", 13016}) -- Northal the Elder
tinsert(eventQuests, {"Lunar Festival", 13017}) -- Jarten the Elder
tinsert(eventQuests, {"Lunar Festival", 13018}) -- Sandrene the Elder
tinsert(eventQuests, {"Lunar Festival", 13019}) -- Thoim the Elder
tinsert(eventQuests, {"Lunar Festival", 13020}) -- Stonebeard the Elder
tinsert(eventQuests, {"Lunar Festival", 13021}) -- Igasho the Elder
tinsert(eventQuests, {"Lunar Festival", 13022}) -- Nurgen the Elder
tinsert(eventQuests, {"Lunar Festival", 13023}) -- Kilias the Elder
tinsert(eventQuests, {"Lunar Festival", 13024}) -- Wanikaya the Elder
tinsert(eventQuests, {"Lunar Festival", 13025}) -- Lunaro the Elder
tinsert(eventQuests, {"Lunar Festival", 13026}) -- Bluewolf the Elder
tinsert(eventQuests, {"Lunar Festival", 13027}) -- Tauros the Elder
tinsert(eventQuests, {"Lunar Festival", 13028}) -- Graymane the Elder
tinsert(eventQuests, {"Lunar Festival", 13029}) -- Pamuya the Elder
tinsert(eventQuests, {"Lunar Festival", 13030}) -- Whurain the Elder
tinsert(eventQuests, {"Lunar Festival", 13031}) -- Skywarden the Elder
tinsert(eventQuests, {"Lunar Festival", 13032}) -- Muraco the Elder
tinsert(eventQuests, {"Lunar Festival", 13033}) -- Arp the Elder
tinsert(eventQuests, {"Lunar Festival", 13065}) -- Ohanzee the Elder
tinsert(eventQuests, {"Lunar Festival", 13066}) -- Yurauk the Elder
tinsert(eventQuests, {"Lunar Festival", 13067}) -- Chogan'gada the Elder

tinsert(eventQuests, {"Love is in the Air", 8897}) -- Dearest Colara
tinsert(eventQuests, {"Love is in the Air", 8898}) -- Dearest Colara
tinsert(eventQuests, {"Love is in the Air", 8899}) -- Dearest Colara
tinsert(eventQuests, {"Love is in the Air", 8900}) -- Dearest Elenia
tinsert(eventQuests, {"Love is in the Air", 8901}) -- Dearest Elenia
tinsert(eventQuests, {"Love is in the Air", 8902}) -- Dearest Elenia
tinsert(eventQuests, {"Love is in the Air", 8903}) -- Dangerous Love
tinsert(eventQuests, {"Love is in the Air", 8904}) -- Dangerous Love
tinsert(eventQuests, {"Love is in the Air", 8979}) -- Fenstad's Hunch
tinsert(eventQuests, {"Love is in the Air", 8980}) -- Zinge's Assessment
tinsert(eventQuests, {"Love is in the Air", 8981, nil, nil, QuestieCorrections.CLASSIC_HIDE}) -- Gift Giving
tinsert(eventQuests, {"Love is in the Air", 8982}) -- Tracing the Source
tinsert(eventQuests, {"Love is in the Air", 8983}) -- Tracing the Source
tinsert(eventQuests, {"Love is in the Air", 8984}) -- The Source Revealed
tinsert(eventQuests, {"Love is in the Air", 8993, nil, nil, QuestieCorrections.CLASSIC_HIDE}) -- Gift Giving
tinsert(eventQuests, {"Love is in the Air", 9024}) -- Aristan's Hunch
tinsert(eventQuests, {"Love is in the Air", 9025}) -- Morgan's Discovery
tinsert(eventQuests, {"Love is in the Air", 9026}) -- Tracing the Source
tinsert(eventQuests, {"Love is in the Air", 9027}) -- Tracing the Source
tinsert(eventQuests, {"Love is in the Air", 9028}) -- The Source Revealed
tinsert(eventQuests, {"Love is in the Air", 9029}) -- A Bubbling Cauldron

tinsert(eventQuests, {"Children's Week", 171}) -- A Warden of the Alliance
tinsert(eventQuests, {"Children's Week", 172}) -- Children's Week
tinsert(eventQuests, {"Children's Week", 558}) -- Jaina's Autograph
tinsert(eventQuests, {"Children's Week", 910}) -- Down at the Docks
tinsert(eventQuests, {"Children's Week", 911}) -- Gateway to the Frontier
tinsert(eventQuests, {"Children's Week", 915}) -- You Scream, I Scream...
tinsert(eventQuests, {"Children's Week", 925}) -- Cairne's Hoofprint
tinsert(eventQuests, {"Children's Week", 1468}) -- Children's Week
tinsert(eventQuests, {"Children's Week", 1479}) -- The Bough of the Eternals
tinsert(eventQuests, {"Children's Week", 1558}) -- The Stonewrought Dam
tinsert(eventQuests, {"Children's Week", 1687}) -- Spooky Lighthouse
tinsert(eventQuests, {"Children's Week", 1800}) -- Lordaeron Throne Room
tinsert(eventQuests, {"Children's Week", 4822}) -- You Scream, I Scream...
tinsert(eventQuests, {"Children's Week", 5502}) -- A Warden of the Horde

tinsert(eventQuests, {"Harvest Festival", 8149}) -- Honoring a Hero
tinsert(eventQuests, {"Harvest Festival", 8150}) -- Honoring a Hero

tinsert(eventQuests, {"Hallow's End", 8373}) -- The Power of Pine
tinsert(eventQuests, {"Hallow's End", 1658}) -- Crashing the Wickerman Festival
tinsert(eventQuests, {"Hallow's End", 8311}) -- Hallow's End Treats for Jesper!
tinsert(eventQuests, {"Hallow's End", 8312}) -- Hallow's End Treats for Spoops!
tinsert(eventQuests, {"Hallow's End", 8322}) -- Rotten Eggs
tinsert(eventQuests, {"Hallow's End", 1657}) -- Stinking Up Southshore
tinsert(eventQuests, {"Hallow's End", 8409}) -- Ruined Kegs
tinsert(eventQuests, {"Hallow's End", 8357}) -- Dancing for Marzipan
tinsert(eventQuests, {"Hallow's End", 8355}) -- Incoming Gumdrop
tinsert(eventQuests, {"Hallow's End", 8356}) -- Flexing for Nougat
tinsert(eventQuests, {"Hallow's End", 8358}) -- Incoming Gumdrop
tinsert(eventQuests, {"Hallow's End", 8353}) -- Chicken Clucking for a Mint
tinsert(eventQuests, {"Hallow's End", 8359}) -- Flexing for Nougat
tinsert(eventQuests, {"Hallow's End", 8354}) -- Chicken Clucking for a Mint
tinsert(eventQuests, {"Hallow's End", 8360}) -- Dancing for Marzipan

tinsert(eventQuests, {"Winter Veil", 6961}) -- Great-father Winter is Here!
tinsert(eventQuests, {"Winter Veil", 7021}) -- Great-father Winter is Here!
tinsert(eventQuests, {"Winter Veil", 7022}) -- Greatfather Winter is Here!
tinsert(eventQuests, {"Winter Veil", 7023}) -- Greatfather Winter is Here!
tinsert(eventQuests, {"Winter Veil", 7024}) -- Great-father Winter is Here!
tinsert(eventQuests, {"Winter Veil", 6962}) -- Treats for Great-father Winter
tinsert(eventQuests, {"Winter Veil", 7025}) -- Treats for Greatfather Winter
tinsert(eventQuests, {"Winter Veil", 7043}) -- You're a Mean One...
tinsert(eventQuests, {"Winter Veil", 6983}) -- You're a Mean One...
tinsert(eventQuests, {"Winter Veil", 6984}) -- A Smokywood Pastures' Thank You!
tinsert(eventQuests, {"Winter Veil", 7045}) -- A Smokywood Pastures' Thank You!
tinsert(eventQuests, {"Winter Veil", 7063}) -- The Feast of Winter Veil
tinsert(eventQuests, {"Winter Veil", 7061}) -- The Feast of Winter Veil
tinsert(eventQuests, {"Winter Veil", 6963}) -- Stolen Winter Veil Treats
tinsert(eventQuests, {"Winter Veil", 7042}) -- Stolen Winter Veil Treats
tinsert(eventQuests, {"Winter Veil", 7062}) -- The Reason for the Season
tinsert(eventQuests, {"Winter Veil", 8763}) -- The Hero of the Day
tinsert(eventQuests, {"Winter Veil", 8799}) -- The Hero of the Day
tinsert(eventQuests, {"Winter Veil", 6964}) -- The Reason for the Season
tinsert(eventQuests, {"Winter Veil", 8762}) -- Metzen the Reindeer
tinsert(eventQuests, {"Winter Veil", 8746}) -- Metzen the Reindeer
-- New SoD quests
tinsert(eventQuests, {"Winter Veil", 79482}) -- Stolen Winter Veil Treats
tinsert(eventQuests, {"Winter Veil", 79483}) -- Stolen Winter Veil Treats
tinsert(eventQuests, {"Winter Veil", 79484}) -- You're a Mean One...
tinsert(eventQuests, {"Winter Veil", 79485}) -- You're a Mean One...
tinsert(eventQuests, {"Winter Veil", 79486}) -- A Smokywood Pastures' Thank You!
tinsert(eventQuests, {"Winter Veil", 79487}) -- A Smokywood Pastures' Thank You!
tinsert(eventQuests, {"Winter Veil", 79492}) -- Metzen the Reindeer
tinsert(eventQuests, {"Winter Veil", 79495}) -- Metzen the Reindeer
tinsert(eventQuests, {"Winter Veil", 8744, "25/12", "2/1"}) -- A Carefully Wrapped Present
tinsert(eventQuests, {"Winter Veil", 8767, "25/12", "2/1"}) -- A Gently Shaken Gift
tinsert(eventQuests, {"Winter Veil", 8768, "25/12", "2/1"}) -- A Gaily Wrapped Present
tinsert(eventQuests, {"Winter Veil", 8769, "25/12", "2/1"}) -- A Ticking Present
tinsert(eventQuests, {"Winter Veil", 8788, "25/12", "2/1"}) -- A Gently Shaken Gift
tinsert(eventQuests, {"Winter Veil", 8803, "25/12", "2/1"}) -- A Festive Gift
tinsert(eventQuests, {"Winter Veil", 8827, "25/12", "2/1"}) -- Winter's Presents
tinsert(eventQuests, {"Winter Veil", 8828, "25/12", "2/1"}) -- Winter's Presents
tinsert(eventQuests, {"Winter Veil", 8860, "31/12", "1/1"}) -- New Year Celebrations!
tinsert(eventQuests, {"Winter Veil", 8861, "31/12", "1/1"}) -- New Year Celebrations!

tinsert(eventQuests, {"Darkmoon Faire", 7902}) -- Vibrant Plumes
tinsert(eventQuests, {"Darkmoon Faire", 7903}) -- Evil Bat Eyes
tinsert(eventQuests, {"Darkmoon Faire", 8222}) -- Glowing Scorpid Blood
tinsert(eventQuests, {"Darkmoon Faire", 7901, nil, nil, QuestieCorrections.SOD_HIDE}) -- Soft Bushy Tails
tinsert(eventQuests, {"Darkmoon Faire", 7899, nil, nil, QuestieCorrections.SOD_HIDE}) -- Small Furry Paws
tinsert(eventQuests, {"Darkmoon Faire", 7940}) -- 1200 Tickets - Orb of the Darkmoon
tinsert(eventQuests, {"Darkmoon Faire", 7900, nil, nil, QuestieCorrections.SOD_HIDE}) -- Torn Bear Pelts
tinsert(eventQuests, {"Darkmoon Faire", 7907}) -- Darkmoon Beast Deck
tinsert(eventQuests, {"Darkmoon Faire", 7927}) -- Darkmoon Portals Deck
tinsert(eventQuests, {"Darkmoon Faire", 7929}) -- Darkmoon Elementals Deck
tinsert(eventQuests, {"Darkmoon Faire", 7928}) -- Darkmoon Warlords Deck
tinsert(eventQuests, {"Darkmoon Faire", 7946, nil, nil, QuestieCorrections.SOD_HIDE}) -- Spawn of Jubjub
tinsert(eventQuests, {"Darkmoon Faire", 8223}) -- More Glowing Scorpid Blood
tinsert(eventQuests, {"Darkmoon Faire", 7934}) -- 50 Tickets - Darkmoon Storage Box
tinsert(eventQuests, {"Darkmoon Faire", 7981}) -- 1200 Tickets - Amulet of the Darkmoon
tinsert(eventQuests, {"Darkmoon Faire", 7943}) -- More Bat Eyes
tinsert(eventQuests, {"Darkmoon Faire", 7894, nil, nil, QuestieCorrections.SOD_HIDE}) -- Copper Modulator
tinsert(eventQuests, {"Darkmoon Faire", 7933}) -- 40 Tickets - Greater Darkmoon Prize
tinsert(eventQuests, {"Darkmoon Faire", 7898}) -- Thorium Widget
tinsert(eventQuests, {"Darkmoon Faire", 7885}) -- Armor Kits
tinsert(eventQuests, {"Darkmoon Faire", 7942}) -- More Thorium Widgets
tinsert(eventQuests, {"Darkmoon Faire", 7883, nil, nil, QuestieCorrections.SOD_HIDE}) -- The World's Largest Gnome!
tinsert(eventQuests, {"Darkmoon Faire", 7892}) -- Big Black Mace
tinsert(eventQuests, {"Darkmoon Faire", 7937}) -- Your Fortune Awaits You...
tinsert(eventQuests, {"Darkmoon Faire", 7939}) -- More Dense Grinding Stones
tinsert(eventQuests, {"Darkmoon Faire", 7893}) -- Rituals of Strength
tinsert(eventQuests, {"Darkmoon Faire", 7891, nil, nil, QuestieCorrections.SOD_HIDE}) -- Green Iron Bracers
tinsert(eventQuests, {"Darkmoon Faire", 7896, nil, nil, QuestieCorrections.SOD_HIDE}) -- Green Fireworks
tinsert(eventQuests, {"Darkmoon Faire", 7884}) -- Crocolisk Boy and the Bearded Murloc
tinsert(eventQuests, {"Darkmoon Faire", 7882, nil, nil, QuestieCorrections.SOD_HIDE}) -- Carnival Jerkins
tinsert(eventQuests, {"Darkmoon Faire", 7897}) -- Mechanical Repair Kits
tinsert(eventQuests, {"Darkmoon Faire", 7895, nil, nil, QuestieCorrections.SOD_HIDE}) -- Whirring Bronze Gizmo
tinsert(eventQuests, {"Darkmoon Faire", 7941}) -- More Armor Kits
tinsert(eventQuests, {"Darkmoon Faire", 7881, nil, nil, QuestieCorrections.SOD_HIDE}) -- Carnival Boots
tinsert(eventQuests, {"Darkmoon Faire", 7890, nil, nil, QuestieCorrections.SOD_HIDE}) -- Heavy Grinding Stone
tinsert(eventQuests, {"Darkmoon Faire", 7889, nil, nil, QuestieCorrections.SOD_HIDE}) -- Coarse Weightstone
tinsert(eventQuests, {"Darkmoon Faire", 7945}) -- Your Fortune Awaits You...
tinsert(eventQuests, {"Darkmoon Faire", 7935}) -- 10 Tickets - Last Month's Mutton
tinsert(eventQuests, {"Darkmoon Faire", 7938}) -- Your Fortune Awaits You...
tinsert(eventQuests, {"Darkmoon Faire", 7944}) -- Your Fortune Awaits You...
tinsert(eventQuests, {"Darkmoon Faire", 7932}) -- 12 Tickets - Lesser Darkmoon Prize
tinsert(eventQuests, {"Darkmoon Faire", 7930}) -- 5 Tickets - Darkmoon Flower
tinsert(eventQuests, {"Darkmoon Faire", 7931}) -- 5 Tickets - Minor Darkmoon Prize
tinsert(eventQuests, {"Darkmoon Faire", 7936}) -- 50 Tickets - Last Year's Mutton
tinsert(eventQuests, {"Darkmoon Faire", 7905}) -- The Darkmoon Faire
tinsert(eventQuests, {"Darkmoon Faire", 7926}) -- The Darkmoon Faire
-- New SoD quests
tinsert(eventQuests, {"Darkmoon Faire", 79588}) -- Small Furry Paws
tinsert(eventQuests, {"Darkmoon Faire", 79589}) -- Torn Bear Pelts
tinsert(eventQuests, {"Darkmoon Faire", 79590}) -- Heavy Grinding Stone
tinsert(eventQuests, {"Darkmoon Faire", 79591}) -- Whirring Bronze Gizmo
tinsert(eventQuests, {"Darkmoon Faire", 79592}) -- Carnival Jerkins
tinsert(eventQuests, {"Darkmoon Faire", 79593}) -- Coarse Weightstone
tinsert(eventQuests, {"Darkmoon Faire", 79594}) -- Copper Modulator
tinsert(eventQuests, {"Darkmoon Faire", 79595}) -- Carnival Boots
tinsert(eventQuests, {"Darkmoon Faire", 80421}) -- Green Iron Bracers
tinsert(eventQuests, {"Darkmoon Faire", 80422}) -- Green Fireworks
tinsert(eventQuests, {"Darkmoon Faire", 80423}) -- The World's Largest Gnome!
tinsert(eventQuests, {"Lunar Festival", 80169}) -- Cluster Launcher

-- New TBC event quests

tinsert(eventQuests, {"Children's Week", 10942}) -- Children's Week
tinsert(eventQuests, {"Children's Week", 10943}) -- Children's Week
tinsert(eventQuests, {"Children's Week", 10945}) -- Hch'uu and the Mushroom People
tinsert(eventQuests, {"Children's Week", 10950}) -- Auchindoun and the Ring of Observance
tinsert(eventQuests, {"Children's Week", 10951}) -- A Trip to the Dark Portal
tinsert(eventQuests, {"Children's Week", 10952}) -- A Trip to the Dark Portal
tinsert(eventQuests, {"Children's Week", 10953}) -- Visit the Throne of the Elements
tinsert(eventQuests, {"Children's Week", 10954}) -- Jheel is at Aeris Landing!
tinsert(eventQuests, {"Children's Week", 10956}) -- The Seat of the Naaru
-- tinsert(eventQuests, {"Children's Week", 10960}) -- When I Grow Up... -- Not in the game
tinsert(eventQuests, {"Children's Week", 10962}) -- Time to Visit the Caverns
tinsert(eventQuests, {"Children's Week", 10963}) -- Time to Visit the Caverns
tinsert(eventQuests, {"Children's Week", 10966}) -- Back to the Orphanage
tinsert(eventQuests, {"Children's Week", 10967}) -- Back to the Orphanage
tinsert(eventQuests, {"Children's Week", 10968}) -- Call on the Farseer
tinsert(eventQuests, {"Children's Week", 11975}) -- Now, When I Grow Up...

tinsert(eventQuests, {"Darkmoon Faire", 9249}) -- 40 Tickets - Schematic: Steam Tonk Controller
tinsert(eventQuests, {"Darkmoon Faire", 10938}) -- Darkmoon Blessings Deck
tinsert(eventQuests, {"Darkmoon Faire", 10939}) -- Darkmoon Storms Deck
tinsert(eventQuests, {"Darkmoon Faire", 10940}) -- Darkmoon Furies Deck
tinsert(eventQuests, {"Darkmoon Faire", 10941}) -- Darkmoon Lunacy Deck

tinsert(eventQuests, {"Hallow's End", 11450}) -- Fire Training
tinsert(eventQuests, {"Hallow's End", 11356}) -- Costumed Orphan Matron
tinsert(eventQuests, {"Hallow's End", 11357}) -- Masked Orphan Matron
tinsert(eventQuests, {"Hallow's End", 11131}) -- Stop the Fires!
tinsert(eventQuests, {"Hallow's End", 11135, nil, nil, QuestieCorrections.TBC_HIDE}) -- The Headless Horseman
tinsert(eventQuests, {"Hallow's End", 11220, nil, nil, QuestieCorrections.TBC_HIDE}) -- The Headless Horseman
tinsert(eventQuests, {"Hallow's End", 11219}) -- Stop the Fires!
tinsert(eventQuests, {"Hallow's End", 11361}) -- Fire Training
tinsert(eventQuests, {"Hallow's End", 11360}) -- Fire Brigade Practice
tinsert(eventQuests, {"Hallow's End", 11449}) -- Fire Training
tinsert(eventQuests, {"Hallow's End", 11440}) -- Fire Brigade Practice
tinsert(eventQuests, {"Hallow's End", 11439}) -- Fire Brigade Practice
tinsert(eventQuests, {"Hallow's End", 12133}) -- Smash the Pumpkin
tinsert(eventQuests, {"Hallow's End", 12135}) -- Let the Fires Come!
tinsert(eventQuests, {"Hallow's End", 12139}) -- Let the Fires Come!
tinsert(eventQuests, {"Hallow's End", 12155}) -- Smash the Pumpkin
tinsert(eventQuests, {"Hallow's End", 12286}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12331}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12332}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12333}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12334}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12335}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12336}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12337}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12338}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12339}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12340}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12341}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12342}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12343}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12344}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12345}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12346}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12347}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12348}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12349}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12350}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12351}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12352}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12353}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12354}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12355}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12356}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12357}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12358}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12359}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12360}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12361}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12362}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12363}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12364}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12365}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12366}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12367}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12368}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12369}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12370}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12371}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12373}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12374}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12375}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12376}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12377}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12378}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12379}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12380}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12381}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12382}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12383}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12384}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12385}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12386}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12387}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12388}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12389}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12390}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12391}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12392}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12393}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12394}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12395}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12396}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12397}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12398}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12399}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12400}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12401}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12402}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12403}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12404}) -- Candy Bucket
--tinsert(eventQuests, {"Hallow's End", 12405}) -- Candy Bucket -- doesn't exist
tinsert(eventQuests, {"Hallow's End", 12406}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12407}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12408}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12409}) -- Candy Bucket
--tinsert(eventQuests, {"Hallow's End", 12410}) -- Candy Bucket -- doesn't exist
tinsert(eventQuests, {"Hallow's End", 11392, nil, nil, QuestieCorrections.TBC_HIDE}) -- Call the Headless Horseman
tinsert(eventQuests, {"Hallow's End", 11401, nil, nil, QuestieCorrections.TBC_HIDE}) -- Call the Headless Horseman
tinsert(eventQuests, {"Hallow's End", 11403}) -- Free at Last!
tinsert(eventQuests, {"Hallow's End", 11242}) -- Free at Last!
--tinsert(eventQuests, {"Hallow's End", 11404}) -- Call the Headless Horseman
--tinsert(eventQuests, {"Hallow's End", 11405}) -- Call the Headless Horseman

tinsert(eventQuests, {"Brewfest", 11127}) -- <NYI>Thunderbrew Secrets
tinsert(eventQuests, {"Brewfest", 12022}) -- Chug and Chuck!
tinsert(eventQuests, {"Brewfest", 11122}) -- There and Back Again
tinsert(eventQuests, {"Brewfest", 11412}) -- There and Back Again
tinsert(eventQuests, {"Brewfest", 11117}) -- Catch the Wild Wolpertinger!
tinsert(eventQuests, {"Brewfest", 11431}) -- Catch the Wild Wolpertinger!
tinsert(eventQuests, {"Brewfest", 11318}) -- Now This is Ram Racing... Almost.
tinsert(eventQuests, {"Brewfest", 11409}) -- Now This is Ram Racing... Almost.
tinsert(eventQuests, {"Brewfest", 11438}) -- [PH] Beer Garden B
tinsert(eventQuests, {"Brewfest", 12020}) -- This One Time, When I Was Drunk...
tinsert(eventQuests, {"Brewfest", 12192}) -- This One Time, When I Was Drunk...
tinsert(eventQuests, {"Brewfest", 11437}) -- [PH] Beer Garden A
--tinsert(eventQuests, {"Brewfest", 11454}) -- Seek the Saboteurs
tinsert(eventQuests, {"Brewfest", 12420}) -- Brew of the Month Club
tinsert(eventQuests, {"Brewfest", 12421}) -- Brew of the Month Club
--tinsert(eventQuests, {"Brewfest", 12306}) -- Brew of the Month Club
tinsert(eventQuests, {"Brewfest", 11120}) -- Pink Elekks On Parade
tinsert(eventQuests, {"Brewfest", 11400}) -- Brewfest Riding Rams
tinsert(eventQuests, {"Brewfest", 11442}) -- Welcome to Brewfest!
tinsert(eventQuests, {"Brewfest", 11447}) -- Welcome to Brewfest!
--tinsert(eventQuests, {"Brewfest", 12278}) -- Brew of the Month Club
tinsert(eventQuests, {"Brewfest", 11118}) -- Pink Elekks On Parade
tinsert(eventQuests, {"Brewfest", 11320}) -- [NYI] Now this is Ram Racing... Almost.
tinsert(eventQuests, {"Brewfest", 11441}) -- Brewfest!
tinsert(eventQuests, {"Brewfest", 11446}) -- Brewfest!
tinsert(eventQuests, {"Brewfest", 12062}) -- Insult Coren Direbrew
--tinsert(eventQuests, {"Brewfest", 12194}) -- Say, There Wouldn't Happen to be a Souvenir This Year, Would There?
--tinsert(eventQuests, {"Brewfest", 12193}) -- Say, There Wouldn't Happen to be a Souvenir This Year, Would There?
tinsert(eventQuests, {"Brewfest", 12191}) -- Chug and Chuck!
tinsert(eventQuests, {"Brewfest", 11293}) -- Bark for the Barleybrews!
tinsert(eventQuests, {"Brewfest", 11294}) -- Bark for the Thunderbrews!
tinsert(eventQuests, {"Brewfest", 11407}) -- Bark for Drohn's Distillery!
tinsert(eventQuests, {"Brewfest", 11408}) -- Bark for T'chali's Voodoo Brewery!
tinsert(eventQuests, {"Brewfest", 12318}) -- Save Brewfest!
tinsert(eventQuests, {"Brewfest", 12491}) -- Direbrew's Dire Brew
tinsert(eventQuests, {"Brewfest", 12492}) -- Direbrew's Dire Brew


tinsert(eventQuests, {"Midsummer", 9324}) -- Stealing Orgrimmar's Flame
tinsert(eventQuests, {"Midsummer", 9325}) -- Stealing Thunder Bluff's Flame
tinsert(eventQuests, {"Midsummer", 9326}) -- Stealing the Undercity's Flame
tinsert(eventQuests, {"Midsummer", 9330}) -- Stealing Stormwind's Flame
tinsert(eventQuests, {"Midsummer", 9331}) -- Stealing Ironforge's Flame
tinsert(eventQuests, {"Midsummer", 9332}) -- Stealing Darnassus's Flame
tinsert(eventQuests, {"Midsummer", 9339}) -- A Thief's Reward
tinsert(eventQuests, {"Midsummer", 9365}) -- A Thief's Reward

-- Removed in TBC
--tinsert(eventQuests, {"Midsummer", 9388}) -- Flickering Flames in Kalimdor
--tinsert(eventQuests, {"Midsummer", 9389}) -- Flickering Flames in the Eastern Kingdoms
--tinsert(eventQuests, {"Midsummer", 9319}) -- A Light in Dark Places
--tinsert(eventQuests, {"Midsummer", 9386}) -- A Light in Dark Places
--tinsert(eventQuests, {"Midsummer", 9367}) -- The Festival of Fire
--tinsert(eventQuests, {"Midsummer", 9368}) -- The Festival of Fire
--tinsert(eventQuests, {"Midsummer", 9322}) -- Wild Fires in Kalimdor
--tinsert(eventQuests, {"Midsummer", 9323}) -- Wild Fires in the Eastern Kingdoms

tinsert(eventQuests, {"Midsummer", 11580}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11581}) -- Desecrate this Fire!
tinsert(eventQuests, {"Midsummer", 11583}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11584}) -- Honor the Flame
tinsert(eventQuests, {"Midsummer", 11657}) -- Torch Catching
tinsert(eventQuests, {"Midsummer", 11691, nil, nil, QuestieCorrections.CATA_HIDE}) -- Summon Ahune
tinsert(eventQuests, {"Midsummer", 11696, nil, nil, QuestieCorrections.CATA_HIDE}) -- Ahune is Here!
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
tinsert(eventQuests, {"Midsummer", 11748, nil, nil, QuestieCorrections.CATA_HIDE}) -- Desecrate this Fire!
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
tinsert(eventQuests, {"Midsummer", 11785, nil, nil, QuestieCorrections.CATA_HIDE}) -- Desecrate this Fire!
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
tinsert(eventQuests, {"Midsummer", 11819, nil, nil, QuestieCorrections.CATA_HIDE}) -- Honor the Flame
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
tinsert(eventQuests, {"Midsummer", 11861, nil, nil, QuestieCorrections.CATA_HIDE}) -- Honor the Flame
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
tinsert(eventQuests, {"Midsummer", 11955, nil, nil, QuestieCorrections.CATA_HIDE}) -- Ahune, the Frost Lord
tinsert(eventQuests, {"Midsummer", 11972, nil, nil, QuestieCorrections.CATA_HIDE}) -- Shards of Ahune
tinsert(eventQuests, {"Midsummer", 11964}) -- Incense for the Summer Scorchlings
tinsert(eventQuests, {"Midsummer", 11966}) -- Incense for the Festival Scorchlings
tinsert(eventQuests, {"Midsummer", 11970}) -- The Master of Summer Lore
tinsert(eventQuests, {"Midsummer", 11971}) -- The Spinner of Summer Tales
tinsert(eventQuests, {"Midsummer", 12012}) -- Inform the Elder

tinsert(eventQuests, {"Winter Veil", 11528, "25/12", "2/1"}) -- A Winter Veil Gift
tinsert(eventQuests, {"Winter Veil", 13203, "25/12", "2/1"}) -- A Winter Veil Gift
tinsert(eventQuests, {"Winter Veil", 13966, "25/12", "2/1"}) -- A Winter Veil Gift

--- Wotlk event quests

tinsert(eventQuests, {"Noblegarden", 13483}) -- Spring Gatherers
tinsert(eventQuests, {"Noblegarden", 13484}) -- Spring Collectors
tinsert(eventQuests, {"Noblegarden", 13479}) -- The Great Egg Hunt
tinsert(eventQuests, {"Noblegarden", 13480}) -- The Great Egg Hunt
tinsert(eventQuests, {"Noblegarden", 13502}) -- A Tisket, a Tasket, a Noblegarden Basket
tinsert(eventQuests, {"Noblegarden", 13503}) -- A Tisket, a Tasket, a Noblegarden Basket

tinsert(eventQuests, {"Love is in the Air", 14483}) -- Something is in the Air (and it Ain't Love)
tinsert(eventQuests, {"Love is in the Air", 14488}) -- You've Been Served
tinsert(eventQuests, {"Love is in the Air", 24597}) -- A Gift for the King of Stormwind
tinsert(eventQuests, {"Love is in the Air", 24609}) -- A Gift for the Lord of Ironforge
tinsert(eventQuests, {"Love is in the Air", 24610}) -- A Gift for the High Priestess of Elune
tinsert(eventQuests, {"Love is in the Air", 24611}) -- A Gift for the Prophet
tinsert(eventQuests, {"Love is in the Air", 24612}) -- A Gift for the Warchief
tinsert(eventQuests, {"Love is in the Air", 24613}) -- A Gift for the Banshee Queen
tinsert(eventQuests, {"Love is in the Air", 24614}) -- A Gift for the High Chieftain
tinsert(eventQuests, {"Love is in the Air", 24615}) -- A Gift for the Regent Lord of Quel'Thalas
tinsert(eventQuests, {"Love is in the Air", 24629}) -- A Perfect Puff of Perfume
tinsert(eventQuests, {"Love is in the Air", 24635}) -- A Cloudlet of Classy Cologne
tinsert(eventQuests, {"Love is in the Air", 24636}) -- Bonbon Blitz
tinsert(eventQuests, {"Love is in the Air", 24536}) -- Something Stinks
tinsert(eventQuests, {"Love is in the Air", 24655}) -- Something Stinks
tinsert(eventQuests, {"Love is in the Air", 24541}) -- Pilfering Perfume
tinsert(eventQuests, {"Love is in the Air", 24656}) -- Pilfering Perfume
tinsert(eventQuests, {"Love is in the Air", 24745}) -- Something is in the Air (and it Ain't Love)
tinsert(eventQuests, {"Love is in the Air", 24804}) -- Uncommon Scents
tinsert(eventQuests, {"Love is in the Air", 24805}) -- Uncommon Scents

tinsert(eventQuests, {"Love is in the Air", 24576}) -- A Friendly Chat...
tinsert(eventQuests, {"Love is in the Air", 24657}) -- A Friendly Chat...

-- These seem to be breadcrumbs to "You've Been Served" (14488) but aren't available
-- Might either not be in game at all or guarded behind finishing one of the two "A Friendly Chat..." quests above
tinsert(eventQuests, {"Love is in the Air", 24792}) -- Man on the Inside
tinsert(eventQuests, {"Love is in the Air", 24793}) -- Man on the Inside

tinsert(eventQuests, {"Love is in the Air", 24848}) -- Fireworks At The Gilded Rose
tinsert(eventQuests, {"Love is in the Air", 24849}) -- Hot On The Trail
tinsert(eventQuests, {"Love is in the Air", 24850}) -- Snivel's Sweetheart
tinsert(eventQuests, {"Love is in the Air", 24851}) -- Hot On The Trail

-- These "Crushing the Crown" quests are dailies, handed out based on the player's current level.
-- The Durotar + Elwynn quests are available at level 5, with each successive quest being available
-- at 14, 23, 32, 41, 51, 61, and 71, respectively. They are exclusive to each other; once you hit 14,
-- you can no longer pick up the level 5 quest. However, since we have no way of filtering quests based
-- on a "maximum" level, we simply hide all of the higher level ones, which will be picked up automatically
-- instead of the level 5 one. Users can only tell the difference if they're watching quest IDs.
-- TODO: If we implement maxLevel, these hacky workarounds should be implemented properly.
tinsert(eventQuests, {"Love is in the Air", 24638}) -- Crushing the Crown (Durotar)
tinsert(eventQuests, {"Love is in the Air", 24645}) -- Crushing the Crown (Ambermill)
tinsert(eventQuests, {"Love is in the Air", 24647}) -- Crushing the Crown (Hillsbrad H)
tinsert(eventQuests, {"Love is in the Air", 24648}) -- Crushing the Crown (Theramore H)
tinsert(eventQuests, {"Love is in the Air", 24649}) -- Crushing the Crown (Aerie Peak H)
tinsert(eventQuests, {"Love is in the Air", 24650}) -- Crushing the Crown (Everlook H)
tinsert(eventQuests, {"Love is in the Air", 24651}) -- Crushing the Crown (Shattrath H)
tinsert(eventQuests, {"Love is in the Air", 24652}) -- Crushing the Crown (Crystalsong H)
tinsert(eventQuests, {"Love is in the Air", 24658}) -- Crushing the Crown (Elwynn)
tinsert(eventQuests, {"Love is in the Air", 24659}) -- Crushing the Crown (Darkshore)
tinsert(eventQuests, {"Love is in the Air", 24660}) -- Crushing the Crown (Hillsbrad A)
tinsert(eventQuests, {"Love is in the Air", 24662}) -- Crushing the Crown (Theramore A)
tinsert(eventQuests, {"Love is in the Air", 24663}) -- Crushing the Crown (Aerie Peak A)
tinsert(eventQuests, {"Love is in the Air", 24664}) -- Crushing the Crown (Everlook A)
tinsert(eventQuests, {"Love is in the Air", 24665}) -- Crushing the Crown (Shattrath A)
tinsert(eventQuests, {"Love is in the Air", 24666}) -- Crushing the Crown (Crystalsong A)

tinsert(eventQuests, {"Children's Week", 13926}) -- Little Orphan Roo Of The Oracles
tinsert(eventQuests, {"Children's Week", 13927}) -- Little Orphan Kekek Of The Wolvar
tinsert(eventQuests, {"Children's Week", 13929}) -- The Biggest Tree Ever!
tinsert(eventQuests, {"Children's Week", 13930}) -- Home Of The Bear-Men
tinsert(eventQuests, {"Children's Week", 13933}) -- The Bronze Dragonshrine
tinsert(eventQuests, {"Children's Week", 13934}) -- The Bronze Dragonshrine
tinsert(eventQuests, {"Children's Week", 13937}) -- A Trip To The Wonderworks
tinsert(eventQuests, {"Children's Week", 13938}) -- A Visit To The Wonderworks
tinsert(eventQuests, {"Children's Week", 13950}) -- Playmates!
tinsert(eventQuests, {"Children's Week", 13951}) -- Playmates!
tinsert(eventQuests, {"Children's Week", 13954}) -- The Dragon Queen
tinsert(eventQuests, {"Children's Week", 13955}) -- The Dragon Queen
tinsert(eventQuests, {"Children's Week", 13956}) -- Meeting a Great One
tinsert(eventQuests, {"Children's Week", 13957}) -- The Mighty Hemet Nesingwary
tinsert(eventQuests, {"Children's Week", 13959}) -- Back To The Orphanage
tinsert(eventQuests, {"Children's Week", 13960}) -- Back To The Orphanage

tinsert(eventQuests, {"Hallow's End", 12940}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12941}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12944}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12945}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12946}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12947}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12950}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13433}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13434}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13435}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13436}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13437}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13438}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13439}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13448}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13452}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13456}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13459}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13460}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13461}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13462}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13463}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13464}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13465}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13466}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13467}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13468}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13469}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13470}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13471}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13472}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13473}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13474}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13501}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 13548}) -- Candy Bucket

--tinsert(eventQuests, {"Pilgrim's Bounty", 14036}) -- Pilgrim's Bounty
--tinsert(eventQuests, {"Pilgrim's Bounty", 14022}) -- Pilgrim's Bounty
tinsert(eventQuests, {"Pilgrim's Bounty", 14023}) -- Spice Bread Stuffing
tinsert(eventQuests, {"Pilgrim's Bounty", 14024}) -- Pumpkin Pie
tinsert(eventQuests, {"Pilgrim's Bounty", 14028}) -- Cranberry Chutney
tinsert(eventQuests, {"Pilgrim's Bounty", 14030}) -- They're Ravenous In Darnassus
tinsert(eventQuests, {"Pilgrim's Bounty", 14033}) -- Candied Sweet Potatoes
tinsert(eventQuests, {"Pilgrim's Bounty", 14035}) -- Slow-roasted Turkey
tinsert(eventQuests, {"Pilgrim's Bounty", 14037}) -- Spice Bread Stuffing
tinsert(eventQuests, {"Pilgrim's Bounty", 14040}) -- Pumpkin Pie
tinsert(eventQuests, {"Pilgrim's Bounty", 14041}) -- Cranberry Chutney
tinsert(eventQuests, {"Pilgrim's Bounty", 14043}) -- Candied Sweet Potatoes
tinsert(eventQuests, {"Pilgrim's Bounty", 14044}) -- Undersupplied in the Undercity
tinsert(eventQuests, {"Pilgrim's Bounty", 14047}) -- Slow-roasted Turkey
tinsert(eventQuests, {"Pilgrim's Bounty", 14048}) -- Can't Get Enough Turkey
tinsert(eventQuests, {"Pilgrim's Bounty", 14051}) -- Don't Forget The Stuffing
tinsert(eventQuests, {"Pilgrim's Bounty", 14053}) -- We're Out of Cranberry Chutney Again?
tinsert(eventQuests, {"Pilgrim's Bounty", 14054}) -- Easy As Pie
tinsert(eventQuests, {"Pilgrim's Bounty", 14055}) -- She Says Potato
tinsert(eventQuests, {"Pilgrim's Bounty", 14058}) -- She Says Potato
tinsert(eventQuests, {"Pilgrim's Bounty", 14059}) -- We're Out of Cranberry Chutney Again?
tinsert(eventQuests, {"Pilgrim's Bounty", 14060}) -- Easy As Pie
tinsert(eventQuests, {"Pilgrim's Bounty", 14061}) -- Can't Get Enough Turkey
tinsert(eventQuests, {"Pilgrim's Bounty", 14062}) -- Don't Forget The Stuffing
tinsert(eventQuests, {"Pilgrim's Bounty", 14064}) -- Sharing a Bountiful Feast
tinsert(eventQuests, {"Pilgrim's Bounty", 14065}) -- Sharing a Bountiful Feast

tinsert(eventQuests, {"Brewfest", 13931}) -- Another Year, Another Souvenir. -- Doesn't seem to be in the game
tinsert(eventQuests, {"Brewfest", 13932}) -- Another Year, Another Souvenir. -- Doesn't seem to be in the game

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

-- Cataclysm event quests

tinsert(eventQuests, {"Darkmoon Faire", 27664}) -- Darkmoon Volcanic Deck
tinsert(eventQuests, {"Darkmoon Faire", 27665}) -- Darkmoon Hurricane Deck
tinsert(eventQuests, {"Darkmoon Faire", 27666}) -- Darkmoon Tsunami Deck
tinsert(eventQuests, {"Darkmoon Faire", 27667}) -- Darkmoon Earthquake Deck
tinsert(eventQuests, {"Darkmoon Faire", 29433}) -- Test Your Strength
tinsert(eventQuests, {"Darkmoon Faire", 29434}) -- Tonk Commander
tinsert(eventQuests, {"Darkmoon Faire", 29436}) -- The Humanoid Cannonball
tinsert(eventQuests, {"Darkmoon Faire", 29438}) -- He Shoots, He Scores!
tinsert(eventQuests, {"Darkmoon Faire", 29443}) -- A Curious Crystal
tinsert(eventQuests, {"Darkmoon Faire", 29444}) -- An Exotic Egg
tinsert(eventQuests, {"Darkmoon Faire", 29445}) -- An Intriguing Grimoire
tinsert(eventQuests, {"Darkmoon Faire", 29446}) -- A Wondrous Weapon
tinsert(eventQuests, {"Darkmoon Faire", 29451}) -- The Master Strategist
tinsert(eventQuests, {"Darkmoon Faire", 29455}) -- Target: Turtle
tinsert(eventQuests, {"Darkmoon Faire", 29456}) -- A Captured Banner
tinsert(eventQuests, {"Darkmoon Faire", 29457}) -- The Enemy's Insignia
tinsert(eventQuests, {"Darkmoon Faire", 29458}) -- The Captured Journal
tinsert(eventQuests, {"Darkmoon Faire", 29463}) -- It's Hammer Time
tinsert(eventQuests, {"Darkmoon Faire", 29464}) -- Tools of Divination
tinsert(eventQuests, {"Darkmoon Faire", 29506}) -- A Fizzy Fusion
tinsert(eventQuests, {"Darkmoon Faire", 29507}) -- Fun for the Little Ones
tinsert(eventQuests, {"Darkmoon Faire", 29508}) -- Baby Needs Two Pair of Shoes
tinsert(eventQuests, {"Darkmoon Faire", 29509}) -- Putting the Crunch in the Frog
tinsert(eventQuests, {"Darkmoon Faire", 29510}) -- Putting Trash to Good Use
tinsert(eventQuests, {"Darkmoon Faire", 29511}) -- Talkin' Tonks
tinsert(eventQuests, {"Darkmoon Faire", 29513}) -- Spoilin' for Salty Sea Dogs
tinsert(eventQuests, {"Darkmoon Faire", 29514}) -- Herbs for Healing
tinsert(eventQuests, {"Darkmoon Faire", 29515}) -- Writing the Future
tinsert(eventQuests, {"Darkmoon Faire", 29516}) -- Keeping the Faire Sparkling
tinsert(eventQuests, {"Darkmoon Faire", 29517}) -- Eyes on the Prizes
tinsert(eventQuests, {"Darkmoon Faire", 29518}) -- Rearm, Reuse, Recycle
tinsert(eventQuests, {"Darkmoon Faire", 29519}) -- Tan My Hide
tinsert(eventQuests, {"Darkmoon Faire", 29520}) -- Banners, Banners Everywhere!
tinsert(eventQuests, {"Darkmoon Faire", 29601}) -- The Darkmoon Field Guide
tinsert(eventQuests, {"Darkmoon Faire", 29760}) -- Pit Fighter
tinsert(eventQuests, {"Darkmoon Faire", 29761}) -- Master Pit Fighter

tinsert(eventQuests, {"Lunar Festival", 29734}) -- Deepforge the Elder
tinsert(eventQuests, {"Lunar Festival", 29735}) -- Stonebrand the Elder
tinsert(eventQuests, {"Lunar Festival", 29736}) -- Darkfeather the Elder
tinsert(eventQuests, {"Lunar Festival", 29737}) -- Firebeard the Elder
tinsert(eventQuests, {"Lunar Festival", 29738}) -- Moonlance the Elder
tinsert(eventQuests, {"Lunar Festival", 29739}) -- Windsong the Elder
tinsert(eventQuests, {"Lunar Festival", 29740}) -- Evershade the Elder
tinsert(eventQuests, {"Lunar Festival", 29741}) -- Sekhemi the Elder
tinsert(eventQuests, {"Lunar Festival", 29742}) -- Menkhaf the Elder

tinsert(eventQuests, {"Love is in the Air", 28935}) -- Crushing the Crown

--tinsert(eventQuests, {"Children's Week", 28879}) -- Back To The Orphanage -- not available yet in children's week 2024
--tinsert(eventQuests, {"Children's Week", 28880}) -- Back To The Orphanage -- not available yet in children's week 2024
tinsert(eventQuests, {"Children's Week", 29093}) -- Cruisin' the Chasm
tinsert(eventQuests, {"Children's Week", 29106}) -- The Biggest Diamond Ever!
tinsert(eventQuests, {"Children's Week", 29107}) -- Malfurion Has Returned!
tinsert(eventQuests, {"Children's Week", 29117}) -- Let's Go Fly a Kite
tinsert(eventQuests, {"Children's Week", 29119}) -- You Scream, I Scream...
tinsert(eventQuests, {"Children's Week", 29146}) -- Ridin' the Rocketway
tinsert(eventQuests, {"Children's Week", 29167}) -- The Banshee Queen
tinsert(eventQuests, {"Children's Week", 29176}) -- The Fallen Chieftain
tinsert(eventQuests, {"Children's Week", 29190}) -- Let's Go Fly a Kite
tinsert(eventQuests, {"Children's Week", 29191}) -- You Scream, I Scream...

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

tinsert(eventQuests, {"Brewfest", 11413}) -- Did Someone Say "Souvenir?"
tinsert(eventQuests, {"Brewfest", 29393}) -- Brew For Brewfest
tinsert(eventQuests, {"Brewfest", 29394}) -- Brew For Brewfest
tinsert(eventQuests, {"Brewfest", 29396}) -- A New Supplier of Souvenirs
tinsert(eventQuests, {"Brewfest", 29397}) -- A New Supplier of Souvenirs

tinsert(eventQuests, {"Hallow's End", 28934}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28951}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28952}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28953}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28954}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28955}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28956}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28957}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28958}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28959}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28960}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28961}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28962}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28963}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28964}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28965}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28966}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28967}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28968}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28969}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28970}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28971}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28972}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28973}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28974}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28975}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28976}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28977}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28978}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28979}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28980}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28981}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28982}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28983}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28984}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28985}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28986}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28987}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28988}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28989}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28990}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28991}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28992}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28993}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28994}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28995}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28996}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28997}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28998}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 28999}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29000}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29001}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29002}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29003}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29004}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29005}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29006}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29007}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29008}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29009}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29010}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29011}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29012}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29013}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29014}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29016}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29017}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29018}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29019}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29020}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 29054}) -- Stink Bombs Away!
tinsert(eventQuests, {"Hallow's End", 29074}) -- A Season for Celebration
tinsert(eventQuests, {"Hallow's End", 29075}) -- A Time to Gain
tinsert(eventQuests, {"Hallow's End", 29144}) -- Clean Up in Stormwind
tinsert(eventQuests, {"Hallow's End", 29371}) -- A Time to Lose
tinsert(eventQuests, {"Hallow's End", 29374}) -- Stink Bombs Away!
tinsert(eventQuests, {"Hallow's End", 29375}) -- Clean Up in Undercity
tinsert(eventQuests, {"Hallow's End", 29376}) -- A Time to Build Up
tinsert(eventQuests, {"Hallow's End", 29377}) -- A Time to Break Down
tinsert(eventQuests, {"Hallow's End", 29392}) -- Missing Heirlooms
tinsert(eventQuests, {"Hallow's End", 29398}) -- Fencing the Goods
tinsert(eventQuests, {"Hallow's End", 29399}) -- Shopping Around
tinsert(eventQuests, {"Hallow's End", 29400}) -- A Season for Celebration
tinsert(eventQuests, {"Hallow's End", 29402}) -- Taking Precautions
tinsert(eventQuests, {"Hallow's End", 29403}) -- The Collector's Agent
tinsert(eventQuests, {"Hallow's End", 29411}) -- What Now?
tinsert(eventQuests, {"Hallow's End", 29415}) -- Missing Heirlooms
tinsert(eventQuests, {"Hallow's End", 29416}) -- Fencing the Goods
tinsert(eventQuests, {"Hallow's End", 29425}) -- Shopping Around
tinsert(eventQuests, {"Hallow's End", 29426}) -- Taking Precautions
tinsert(eventQuests, {"Hallow's End", 29427}) -- The Collector's Agent
tinsert(eventQuests, {"Hallow's End", 29428}) -- What Now?
tinsert(eventQuests, {"Hallow's End", 29430}) -- A Friend in Need
tinsert(eventQuests, {"Hallow's End", 29431}) -- A Friend in Need

tinsert(eventQuests, {"Day of the Dead", 13952}) -- The Grateful Dead
tinsert(eventQuests, {"Day of the Dead", 14166}) -- The Grateful Dead
tinsert(eventQuests, {"Day of the Dead", 14167}) -- The Grateful Dead
tinsert(eventQuests, {"Day of the Dead", 14168}) -- The Grateful Dead
tinsert(eventQuests, {"Day of the Dead", 14169}) -- The Grateful Dead
tinsert(eventQuests, {"Day of the Dead", 14170}) -- The Grateful Dead
tinsert(eventQuests, {"Day of the Dead", 14171}) -- The Grateful Dead
tinsert(eventQuests, {"Day of the Dead", 14172}) -- The Grateful Dead
tinsert(eventQuests, {"Day of the Dead", 14173}) -- The Grateful Dead
tinsert(eventQuests, {"Day of the Dead", 14174}) -- The Grateful Dead
tinsert(eventQuests, {"Day of the Dead", 14175}) -- The Grateful Dead
tinsert(eventQuests, {"Day of the Dead", 14176}) -- The Grateful Dead
tinsert(eventQuests, {"Day of the Dead", 14177}) -- The Grateful Dead
tinsert(eventQuests, {"Day of the Dead", 27841}) -- The Grateful Dead
tinsert(eventQuests, {"Day of the Dead", 27846}) -- The Grateful Dead

tinsert(eventQuests, {"Winter Veil", 13966}) -- A Winter Veil Gift
tinsert(eventQuests, {"Winter Veil", 29382}) -- Thanks, But No Thanks
tinsert(eventQuests, {"Winter Veil", 29383}) -- Thanks, But No Thanks
tinsert(eventQuests, {"Winter Veil", 29385}) -- A Winter Veil Gift
tinsert(eventQuests, {"Winter Veil", 28878}) -- A Winter Veil Gift
