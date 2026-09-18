-- Reviewed overlay from QuestieDB-DBC/support/Zones, build 1.60.1.69893 (UiMapAssignment and AreaTable).
-- Loaded only by the Camelot TOC. The staging bundle is partial, so preserve shared dungeon and navigation overrides.
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

---@type table<AreaId, UiMapId>
ZoneDB.private.clientAreaIdToUiMapId = {
    [616] = 2482, -- Mount Hyjal; other clients use map 198.
    [16591] = 2548, -- Riverglades
    [16593] = 2521, -- Zephras Isle
    [16606] = 2524, -- Darkspear Islands
    [16651] = 2652, -- Shen'dralas
}

-- Only relationships belonging to these new/reworked zones are overlaid.
---@type table<AreaId, AreaId>
ZoneDB.private.clientSubZoneToParentZone = {
    [2657] = 16651, -- Valley of Bones
    [16607] = 16606, -- Ruins
    [16608] = 16606, -- Camp
    [16609] = 16606, -- Shipwreck Cove
    [16610] = 16606, -- Abandoned Tower
    [16622] = 16593, -- Thendal Grove
    [16623] = 16593, -- Shen'dar Highlands
    [16624] = 16593, -- Shen'dar Village
    [16625] = 16593, -- Windsong Lake
    [16626] = 16593, -- Gustberry Lowlands
    [16628] = 16593, -- Valanaar Skydocks
    [16629] = 16593, -- Shrine of Akir
    [16630] = 16593, -- Rohashi Spires
    [16631] = 16593, -- Shadowgale Forest
    [16635] = 16593, -- Thendal Village
    [16636] = 16593, -- Falaath Village
    [16638] = 16593, -- Valanaar
    [16663] = 16593, -- Windfield Orchard
    [16672] = 16593, -- Shriekling Den
    [16673] = 16593, -- Thendal Cave
    [16674] = 16593, -- Bandit Hideout
    [16675] = 16651, -- Magram Front
    [16676] = 16651, -- Outcast Hideaway
    [16677] = 16651, -- Bristleback Retreat
    [16678] = 16651, -- Evenshade's Overlook
    [16679] = 16593, -- Sanctum of Storms
    [16685] = 16591, -- Twilight's Shroud
    [16720] = 16593, -- Nightclaw Cavern
    [16723] = 16591, -- Sunnyglade
    [16724] = 16591, -- Farholde Keep
    [16725] = 16591, -- Wheeler's Grange
    [16726] = 16591, -- Bolder'ok
    [16727] = 16591, -- Powderfuse Port
    [16728] = 16591, -- Eastwind Shore
    [16729] = 16591, -- Terral's Watch
    [16731] = 16591, -- Windstead
    [16734] = 16591, -- Elbrim's Farm
    [16735] = 16591, -- Meadowsbrook
    [16736] = 16591, -- Turner's Logging Camp
    [16737] = 16591, -- Bristle Hills
    [16742] = 16651, -- Forlorn Gardens
    [16743] = 16591, -- Rog'mar
    [16744] = 16591, -- Southern Watch
    [16820] = 16591, -- The Forbidding Sea
    [16833] = 16593, -- Ruins of Ban'aethal
    [16848] = 616, -- Elderwild
    [16849] = 616, -- Summit of Eternity
    [16853] = 616, -- Tainted Foothills
    [16866] = 616, -- Dae'gun
    [16867] = 616, -- Shrine of Aviana
    [16868] = 616, -- Mourning's Rest
    [16988] = 16593, -- Rise of Spirits
    [17050] = 616, -- Felblood Scar
    [17144] = 616, -- Malorne's Retreat
    [17145] = 616, -- Cradle of Tranquility
    [17221] = 16593, -- Skywall
    [17674] = 16593, -- West Pylon Watchtower
    [17675] = 16593, -- East Pylon Watchtower
    [17676] = 16593, -- Windsong Standing Stones
    [17677] = 16593, -- Overlook Standing Stones
    [17678] = 16593, -- Thendal Standing Stones
    [17684] = 16593, -- Fairweather Stables
    [17780] = 16591, -- Krol'dok Stronghold
    [17808] = 16591, -- Ashwood's Fall
    [17809] = 16591, -- Forlorn Pit
}
