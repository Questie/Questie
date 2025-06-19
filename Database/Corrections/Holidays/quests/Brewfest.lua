---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

local tinsert = table.insert
local eventQuests = QuestieEvent.eventQuests

-- TBC quests
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
tinsert(eventQuests, {"Brewfest", 12062, nil, nil, Expansions.Current >= Expansions.Cata}) -- Insult Coren Direbrew
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

-- WotLK quests
tinsert(eventQuests, {"Brewfest", 13931, nil, nil, Expansions.Current >= Expansions.Cata}) -- Another Year, Another Souvenir. -- Doesn't seem to be in the game
tinsert(eventQuests, {"Brewfest", 13932, nil, nil, Expansions.Current >= Expansions.Cata}) -- Another Year, Another Souvenir. -- Doesn't seem to be in the game

-- Cata quests
--tinsert(eventQuests, {"Brewfest", 11413}) -- Did Someone Say "Souvenir?"
tinsert(eventQuests, {"Brewfest", 29393}) -- Brew For Brewfest
tinsert(eventQuests, {"Brewfest", 29394}) -- Brew For Brewfest
tinsert(eventQuests, {"Brewfest", 29396}) -- A New Supplier of Souvenirs
tinsert(eventQuests, {"Brewfest", 29397}) -- A New Supplier of Souvenirs
