---@type QuestieAuto
local QuestieAuto = QuestieLoader:ImportModule("QuestieAuto")
local _QuestieAuto = QuestieAuto.private


-- NPC Id based.
---@see QuestieAutoPrivate
_QuestieAuto.disallowedNPC = {
    -- AQ
    -- Ally
    [15458] = true, -- Commander Stronghammer (Alliance Ambassador)
    [15701] = true, -- Field Marshal Snowfall (War Effort Commander)
    -- Horde
    [15539] = true, -- General Zog (Horde Ambassador)
    [15700] = true, -- Warlord Gorchuk (War Effort Commander)
    -- Commendations
    [15764] = true, -- Officer Ironbeard (Ironforge Commendations)
    [15762] = true, -- Officer Lunalight (Darnassus Commendations)
    [15766] = true, -- Officer Maloof (Stormwind Commendations)
    [15763] = true, -- Officer Porterhouse (Gnomeregan Commendations)
    [15768] = true, -- Officer Gothena (Undercity Commendations)
    [15765] = true, -- Officer Redblade (Orgrimmar Commendations)
    [15767] = true, -- Officer Thunderstrider (Thunder Bluff Commendations)
    [15761] = true, -- Officer Vu'Shalay (Darkspear Commendations)
    [15731] = true, -- Darnassus Commendation Officer
    [15737] = true, -- Darkspear Commendation Officer
    [15735] = true, -- Stormwind Commendation Officer
    [15739] = true, -- Thunder Bluff Commendation Officer
    [15736] = true, -- Orgrimmar Commendation Officer
    [15734] = true, -- Ironforge Commendation Officer
    [15738] = true, -- Undercity Commendation Officer
    [15733] = true, -- Gnomeregan Commendation Officer
    -- AQ gear turnin
    [15378] = true,
    [15380] = true,
    [15498] = true,
    [15499] = true,
    [15500] = true,
    [15503] = true,
    -- Stray
    [7802] = true, -- Galvan the Ancient (Blacksmith recipes, Stranglethorn Vale)
    [12944] = true, -- Lokhtos Darkbargainer (Thorium Brotherhood, Blackrock Depths)
    [14567] = true, -- Derotain Mudsipper (Blacksmith recipes, Tanaris)
    [14828] = true, -- Gelvas Grimegate (Darkmoon Faire Ticket Redemption)
    [14921] = true, -- Rin'wosho the Trader (Zul'Gurub Isle, Stranglethorn Vale)
    [15192] = true, -- Anachronos (Caverns of Time)
    [18166] = true, -- Khadgar (Allegiance to Aldor/Scryer, Shattrath)
    [18253] = true, -- Archmage Leryda (Violet Eye)
    [18471] = true, -- Gurgthock (The Ring of Blood)
    [19935] = true, -- Soridormi (The Scale of Sands)
    [19936] = true, -- Arazmodu (The Scale of Sands)
    [25112] = true, -- Anchorite Ayuri (Shattered Sun Offensive Charity NPC)
    [25163] = true, -- Anchorite Kairthos (Shattered Sun Offensive Title NPC)
}

---@see QuestieAutoPrivate
_QuestieAuto.disallowedQuests = {
    -- Escort Quests
    [155] = true, -- The Defias Traitor (The Defias Brotherhood)
    [219] = true, -- Corporal Keeshan (Missing In Action)
    [309] = true, -- Miran (Protecting the Shipment)
    [349] = true, -- Stranglethorn Fever (Consumes items)
    [434] = true, -- Tyrion (The Attack!)
    [435] = true, -- Deathstalker Erland (Escorting Erland)
    [648] = true, -- Homing Robot OOX-17/TN (Rescue OOX-17/TN!)
    [660] = true, -- Kinelory (Hints of a New Plague?)
    [665] = true, -- Professor Phizzlethorpe (Sunken Treasure)
    [667] = true, -- Shakes O'Breen (Death From Below)
    [731] = true, -- Prospector Remtravel (The Absent Minded Prospector)
    [836] = true, -- Homing Robot OOX-09/HL (Rescue OOX-09/HL!)
    [863] = true, -- Wizzlecrank's Shredder (The Escape)
    [898] = true, -- Gilthares Firebough (Free From the Hold)
    [938] = true, -- Mist (Mist)
    [945] = true, -- Therylune (Therylune's Escape)
    [976] = true, -- Feero Ironhand (Supplies to Auberdine)
    [994] = true, -- Volcor (Escape Through Force)
    [995] = true, -- Volcor (Escape Through Stealth)
    [1144] = true, -- Willix the Importer (Willix the Importer)
    [1222] = true, -- Stinky Ignatz (Stinky's Escape)
    [1270] = true, -- Stinky Ignatz (Stinky's Escape)
    [1273] = true, -- Ogron (Questioning Reethe)
    [1324] = true, -- Private Hendel (The Missing Diplomat)
    [1393] = true, -- Galen Goodward (Galen's Escape)
    [1440] = true, -- Dalinda Malem (Return to Vahlarriel)
    [1560] = true, -- Tooga (Tooga's Quest)
    [2742] = true, -- Rin'ji (Rin'ji is Trapped!)
    [2767] = true, -- Homing Robot OOX-22/FE (Rescue OOX-22/FE!)
    [2845] = true, -- Shay Leafrunner (Wandering Shay)
    [2904] = true, -- Kernobee (A Fine Mess)
    [3367] = true, -- Dorius Stonetender (Suntara Stones)
    [3382] = true, -- Captain Vanessa Beltis (A Crew Under Fire)
    [3525] = true, -- Belnistrasz (Extinguishing the Idol)
    [3982] = true, -- Commander Gor'shak (What Is Going On?)
    [4121] = true, -- Grark Lorkrub (Precarious Predicament)
    [4245] = true, -- A-Me 01 (Chasing A-Me 01)
    [4261] = true, -- Arei (Ancient Spirit)
    [4322] = true, -- Marshal Windsor (Jail Break!)
    [4491] = true, -- Ringo (A Little Help From My Friends)
    [4770] = true, -- Pao'ka Swiftmountain (Homeward Bound)
    [4901] = true, -- Ranshalla (Guardians of the Altar)
    [4904] = true, -- Lakota Windsong (Free at Last)
    [4966] = true, -- Kanati Greycloud (Protect Kanati Greycloud)
    [5203] = true, -- Captured Arko'narin (Rescue From Jaedenar)
    [5321] = true, -- Kerlonian Evershade (The Sleeper Has Awakened)
    [5713] = true, -- Sentinel Aynasha (One Shot. One Kill.)
    [5821] = true, -- Cork Gizelton (Bodyguard for Hire)
    [5943] = true, -- Rigger Gizelton (Gizelton Caravan)
    [5944] = true, -- Highlord Taelan Fordring (In Dreams)
    [6132] = true, -- Melizza Brimbuzzle (Get Me Out of Here!)
    [6403] = true, -- Reginald Windsor (The Great Masquerade)
    [6482] = true, -- Ruul Snowhoof (Freedom to Ruul)
    [6523] = true, -- Kaya Flathoof (Protect Kaya)
    [6544] = true, -- Torek (Torek's Assault)
    [6641] = true, -- Muglash (Vorsha the Lasher)
    [7046] = true, -- Celebras the Redeemed (The Scepter of Celebras)
    [7637] = true, -- Emphasis on Sacrifice (Paladin quest)
    [3375] = true,
    [2948] = true,
    [2199] = true,
    [2950] = true,
    [4781] = true,
    [4083] = true,
    [5166] = true,
    [5167] = true,
    [5067] = true,
    [5063] = true,
    [5068] = true,
    [8196] = true,
    [9212] = true, -- Escape from the Catacombs
    [9338] = true, -- Allegiance to Cenarion Circle
    [9446] = true, -- Tomb of the Lightbringer
    [9528] = true, -- A Cry For Help
    [9729] = true, -- Fhwoor Smash!
    [9752] = true, -- Escape from Umbrafen
    [9868] = true, -- The Totem of Kar'dash
    [9879] = true, -- The Totem of Kar'dash
    [10051] = true, -- Escape from Firewing Point!
    [10052] = true, -- Escape from Firewing Point!
    [10191] = true, -- Mark V is Alive!
    [10218] = true, -- Someone Else's Hard Work Pays Off
    [10310] = true, -- Sabotage the Warp-Gate!
    [10337] = true, -- When the Cows Come Home
    [10346] = true, -- Gryphoneer Windbellow (Return to the Abyssal Shelf) (Alliance)
    [10347] = true, -- Wing Commander Brack (Return to the Abyssal Shelf) (Horde)
    [10406] = true, -- Delivering the Message
    [10425] = true, -- Escape from the Staging Grounds
    [10451] = true, -- Escape from Coilskar Cistern
    [10898] = true, -- Skywing
    [10922] = true, -- Digging Through Bones
    [10975] = true, -- Purging the Chambers of Bash'ir
    [11085] = true, -- Escape from Skettis
    [11189] = true, -- One Last Time
    [11241] = true, -- Trail of Fire
    [11570] = true, -- Escape from the Winterfin Caverns
    [11673] = true, -- Get Me Outa Here!
    [11930] = true, -- Across Transborea
    [12082] = true, -- Dun-da-Dun-tah!
    [12570] = true, -- Fortunate Misunderstandings
    [12832] = true, -- Bitter Departure
    [13221] = true, -- I'm Not Dead Yet!
    [13229] = true, -- I'm Not Dead Yet!
    [13284] = true, -- Assault by Ground
    [13301] = true, -- Assault by Ground
    [13481] = true, -- Let's Get Out of Here!
    [13482] = true, -- Let's Get Out of Here
    -- Netherwing Drake quests
    [11109] = true,
    [11110] = true,
    [11111] = true,
    [11112] = true,
    [11113] = true,
    [11114] = true,
    -- The Barrens Bloodshard quests
    [889] = true,
    [5042] = true,
    [5043] = true,
    [5044] = true,
    [5045] = true,
    [5046] = true,
    -- AQ
    [8548] = true,
    [8572] = true,
    [8573] = true,
    [8574] = true,
    [8288] = true,
    -- Aldor/scryer quests
    [10551] = true,
    [10552] = true,
    -- PvP token quests
    [8367] = true,
    [8388] = true,
    [8371] = true,
    [8385] = true,
    [64845] = true,
    --
    [12174] = true, -- Flies you across Dragonblight
    [12567] = true, -- Blessing of Zim'Abwa repeatable
    [12618] = true, -- Blessing of Zim'Torga repeatable
    [12656] = true, -- Blessing of Zim'Rhuk repeatable
}
