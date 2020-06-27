---@type QuestieAuto
local QuestieAuto = QuestieLoader:ImportModule("QuestieAuto")
local _QuestieAuto = QuestieAuto.private


-- NPC Id based.
_QuestieAuto.disallowedNPC = {
    -- AQ
    -- Ally
    [15446] = true, -- Bonnie Stoneflayer (Light Leather)
    [15458] = true, -- Commander Stronghammer (Alliance Ambassador)
    [15431] = true, -- Corporal Carnes (Iron Bar)
    [15432] = true, -- Dame Twinbraid (Thorium Bar)
    [15453] = true, -- Keeper Moonshade (Runecloth Bandage)
    [15457] = true, -- Huntress Swiftriver (Spotted Yellowtail)
    [15450] = true, -- Marta Finespindle (Thick Leather)
    [15437] = true, -- Master Nightsong (Purple Lotus)
    [15452] = true, -- Nurse Stonefield (Silk Bandage)
    [15434] = true, -- Private Draxlegauge (Stranglekelp)
    [15448] = true, -- Private Porter (Medium Leather)
    [15456] = true, -- Sarah Sadwhistle (Roast Raptor)
    [15451] = true, -- Sentinel Silversky (Linen Bandage)
    [15445] = true, -- Sergeant Major Germaine (Arthas' Tears)
    [15383] = true, -- Sergeant Stonebrow (Copper Bar)
    [15455] = true, -- Slicky Gastronome (Rainbow Fin Albacore)
    -- Horde
    [15512] = true, -- Apothecary Jezel (Purple Lotus)
    [15508] = true, -- Batrider Pele'keiki (Firebloom)
    [15533] = true, -- Bloodguard Rawtar (Lean Wolf Steak)
    [15535] = true, -- Chief Sharpclaw (Baked Salmon)
    [15525] = true, -- Doctor Serratus (Rugged Leather)
    [15534] = true, -- Fisherman Lin'do (Spotted Yellowtail)
    [15539] = true, -- General Zog (Horde Ambassador)
    [15460] = true, -- Grunt Maug (Tin Bar)
    [15528] = true, -- Healer Longrunner (Wool Bandage)
    [15477] = true, -- Herbalist Proudfeather (Peacebloom)
    [15529] = true, -- Lady Callow (Mageweave Bandage)
    [15459] = true, -- Miner Cromwell (Copper Bar)
    [15469] = true, -- Senior Sergeant T'kelah (Mithril Bar)
    [15522] = true, -- Sergeant Umala (Thick Leather)
    [15515] = true, -- Skinner Jamani (Heavy Leather)
    [15532] = true, -- Stoneguard Clayhoof (Runecloth Bandage)

    -- Commendations
    [15764] = true, -- Officer Ironbeard (Ironforge Commendations)
    [15762] = true, -- Officer Lunalight (Darnassus Commendations)
    [15766] = true, -- Officer Maloof (Stormwind Commendations)
    [15763] = true, -- Officer Porterhouse (Gnomeregan Commendations)
    [15768] = true, -- Officer Gothena (Undercity Commendations)
    [15765] = true, -- Officer Redblade (Orgrimmar Commendations)
    [15767] = true, -- Officer Thunderstrider (Thunder Bluff Commendations)
    [15761] = true, -- Officer Vu'Shalay (Darkspear Commendations)

    -- Stray
    [15192] = true, -- Anachronos (Caverns of Time)
    [12944] = true, -- Lokhtos Darkbargainer (Thorium Brotherhood, Blackrock Depths)
    -- AQ gear turnin
    [15192] = true,
    [15378] = true,
    [15380] = true,
    [15498] = true,
    [15499] = true,
    [15500] = true,
    [15503] = true
}

_QuestieAuto.disallowedQuests = {
    -- Escort Quests
    [155] = true, -- The Defias Traitor (The Defias Brotherhood)
    [219] = true, -- Corporal Keeshan (Missing In Action)
    [309] = true, -- Miran (Protecting the Shipment)
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
    [8288] = true
    --
}
