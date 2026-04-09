---@type QuestieDBPrivate
local _QuestieDB = QuestieLoader:ImportModule("QuestieDB").private

---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")


--- Tag corrections for quests for which the GetQuestTagInfo API returns the wrong values.
function _QuestieDB.InitializeQuestTagInfoCorrections()

    ---@type table<number, {[1]: QuestTagIds, [2]: string}>
    _QuestieDB.questTagCorrections = {
        [17] = Expansions.Current == Expansions.Era and {81, l10n("Dungeon")} or nil, -- Uldaman Reagent Run
        [19] = {1, l10n("Elite")}, -- Tharil'zun
        [55] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Morbent Fel
        [99] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Arugal's Folly
        [105] = {1, l10n("Elite")}, -- Alas, Andorhal
        [115] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Shadow Magic
        [155] = Expansions.Current >= Expansions.Tbc and {1, l10n("Elite")} or nil, -- The Defias Brotherhood
        [166] = {81, l10n("Dungeon")}, -- The Defias Brotherhood
        [169] = {1, l10n("Elite")}, -- Wanted: Gath'Ilzogg
        [176] = {1, l10n("Elite")}, -- Wanted: "Hogger"
        [193] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Panther Mastery
        [197] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Raptor Mastery
        [202] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Colonel Kurzen
        [206] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Mai'Zoth
        [208] = Expansions.Current < Expansions.Cata and {1, l10n("Elite")} or nil, -- Big Game Hunter
        [211] = {1, l10n("Elite")}, -- Alas, Andorhal
        [214] = {81, l10n("Dungeon")}, -- Red Silk Bandanas
        [228] = {1, l10n("Elite")}, -- Mor'Ladim
        [236] = {41, l10n("PvP")}, -- Fueling the Demolishers
        [248] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Looking Further
        [249] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Morganth
        [253] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Bride of the Embalmer
        [255] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Mercenaries
        [256] = {1, l10n("Elite")}, -- WANTED: Chok'sul
        [271] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Vyrin's Revenge
        [278] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- A Dark Threat Looms
        [303] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Dark Iron War
        [304] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- A Grim Task
        [314] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Protecting the Herd
        [377] = {81, l10n("Dungeon")}, -- Crime and Punishment
        [378] = {81, l10n("Dungeon")}, -- The Fury Runs Deep
        [386] = {81, l10n("Dungeon")}, -- What Comes Around...
        [387] = {81, l10n("Dungeon")}, -- Quell The Uprising
        [388] = {81, l10n("Dungeon")}, -- The Color of Blood
        [391] = {81, l10n("Dungeon")}, -- The Stockade Riots
        [442] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Assault on Fenris Isle
        [450] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- A Recipe For Death
        [452] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Pyrewood Ambush
        [474] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Defeat Nek'rosh
        [504] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Crushridge Warmongers
        [517] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Elixir of Agony
        [518] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Crown of Will
        [519] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Crown of Will
        [520] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Crown of Will
        [531] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Vyrin's Revenge
        [540] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Preserving Knowledge
        [541] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Battle of Hillsbrad
        [543] = {1, l10n("Elite")}, -- The Perenolde Tiara
        [547] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Humbert's Sword
        [591] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Mind's Eye
        [611] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Curse of the Tides
        [613] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Cracking Maury's Foot
        [628] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Excelsior
        [629] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Vile Reef
        [630] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Message in a Bottle
        [631] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Thandol Span
        [639] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Sigil of Strom
        [640] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Broken Sigil
        [643] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Sigil of Arathor
        [644] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Sigil of Trollbane
        [645] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Trol'kalar
        [646] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Trol'kalar
        [652] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Breaking the Keystone
        [656] = {1, l10n("Elite")}, -- Summoning the Princess
        [673] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Foul Magics
        [679] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Call to Arms
        [680] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Real Threat
        [682] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Stromgarde Badges
        [684] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Wanted! Marez Cowl
        [685] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Wanted! Otto and Falconcrest
        [694] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Trelane's Defenses
        [695] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- An Apprentice's Enchantment
        [696] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Attack on the Tower
        [697] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Malin's Request
        [704] = Expansions.Current == Expansions.Era and {81, l10n("Dungeon")} or nil, -- Agmond's Fate
        [705] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Pearl Diving
        [706] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Fiery Blaze Enchantments
        [709] = Expansions.Current == Expansions.Era and {81, l10n("Dungeon")} or nil, -- Solution to Doom
        [717] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Tremors of the Earth
        [721] = {81, l10n("Dungeon")}, -- A Sign of Hope
        [722] = {81, l10n("Dungeon")}, -- Amulet of Secrets
        [731] = Expansions.Current >= Expansions.Tbc and {1, l10n("Elite")} or nil, -- The Absent Minded Prospector
        [735] = {1, l10n("Elite")}, -- The Star, the Hand and the Heart
        [736] = {1, l10n("Elite")}, -- The Star, the Hand and the Heart
        [762] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- An Ambassador of Evil
        [793] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Broken Alliances
        [914] = {81, l10n("Dungeon")}, -- Leaders of the Fang
        [969] = {1, l10n("Elite")}, -- Luck Be With You
        [971] = {81, l10n("Dungeon")}, -- Knowledge in the Deeps
        [1013] = {81, l10n("Dungeon")}, -- The Book of Ur
        [1014] = {81, l10n("Dungeon")}, -- Arugal Must Die
        [1048] = {81, l10n("Dungeon")}, -- Into The Scarlet Monastery
        [1049] = {81, l10n("Dungeon")}, -- Compendium of the Fallen
        [1050] = {81, l10n("Dungeon")}, -- Mythology of the Titans
        [1051] = {1, l10n("Elite")}, -- Vorrel's Revenge
        [1053] = {81, l10n("Dungeon")}, -- In the Name of the Light
        [1089] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Den
        [1098] = {81, l10n("Dungeon")}, -- Deathstalkers in Shadowfang
        [1100] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Lonebrow's Journal
        [1101] = {81, l10n("Dungeon")}, -- The Crone of the Kraul
        [1102] = {81, l10n("Dungeon")}, -- A Vengeful Fate
        [1107] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Encrusted Tail Fins
        [1109] = {81, l10n("Dungeon")}, -- Going, Going, Guano!
        [1139] = {81, l10n("Dungeon")}, -- The Lost Tablets of Will
        [1142] = {81, l10n("Dungeon")}, -- Mortality Wanes
        [1144] = {81, l10n("Dungeon")}, -- Willix the Importer
        [1151] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Test of Strength
        [1160] = {81, l10n("Dungeon")}, -- Test of Lore
        [1166] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Overlord Mok'Morokk's Concern
        [1172] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Brood of Onyxia
        [1173] = {1, l10n("Elite")}, -- Challenge Overlord Mok'Morokk
        [1193] = {81, l10n("Dungeon")}, -- A Broken Trap
        [1198] = {81, l10n("Dungeon")}, -- In Search of Thaelrid
        [1199] = {81, l10n("Dungeon")}, -- Twilight Falls
        [1200] = {81, l10n("Dungeon")}, -- Blackfathom Villainy
        [1221] = {81, l10n("Dungeon")}, -- Blueleaf Tubers
        [1222] = Expansions.Current >= Expansions.Tbc and {84, l10n("Escort")} or nil, -- Stinky's Escape
        [1270] = Expansions.Current >= Expansions.Tbc and {84, l10n("Escort")} or nil, -- Stinky's Escape
        [1275] = {81, l10n("Dungeon")}, -- Researching the Corruption
        [1360] = Expansions.Current == Expansions.Era and {81, l10n("Dungeon")} or nil, -- Reclaimed Treasures
        [1380] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Khan Hratha
        [1381] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Khan Hratha
        [1383] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Nothing But The Truth
        [1424] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Pool of Tears
        [1442] = {81, l10n("Dungeon")}, -- Seeking the Kor Gem
        [1445] = {81, l10n("Dungeon")}, -- The Temple of Atal'Hakkar
        [1446] = {81, l10n("Dungeon")}, -- Jammal'an the Prophet
        [1448] = {1, l10n("Elite")}, -- In Search of The Temple
        [1475] = {81, l10n("Dungeon")}, -- Into The Temple of Atal'Hakkar
        [1486] = {81, l10n("Dungeon")}, -- Deviate Hides
        [1487] = {81, l10n("Dungeon")}, -- Deviate Eradication
        [1488] = {1, l10n("Elite")}, -- The Corrupter
        [1491] = {81, l10n("Dungeon")}, -- Smart Drinks
        [1653] = {81, l10n("Dungeon")}, -- The Test of Righteousness
        [1654] = {81, l10n("Dungeon")}, -- The Test of Righteousness
        [1655] = {1, l10n("Elite")}, -- Bailor's Ore Shipment
        [1657] = {41, l10n("PvP")}, -- Stinking Up Southshore
        [1658] = {41, l10n("PvP")}, -- Crashing the Wickerman Festival
        [1701] = {1, l10n("Elite")}, -- Fire Hardened Mail
        [1713] = {1, l10n("Elite")}, -- The Summoning
        [1740] = {81, l10n("Dungeon")}, -- The Orb of Soran'ruk
        [1951] = {81, l10n("Dungeon")}, -- Rituals of Power
        [1955] = {1, l10n("Elite")}, -- The Exorcism
        [1956] = {81, l10n("Dungeon")}, -- Power in Uldaman
        [2040] = {81, l10n("Dungeon")}, -- Underground Assault
        [2078] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Gyromast's Revenge
        [2198] = {81, l10n("Dungeon")}, -- The Shattered Necklace
        [2199] = {81, l10n("Dungeon")}, -- Lore for a Price
        [2200] = {81, l10n("Dungeon")}, -- Back to Uldaman
        [2201] = {81, l10n("Dungeon")}, -- Find the Gems
        [2202] = Expansions.Current == Expansions.Era and {81, l10n("Dungeon")} or nil, -- Uldaman Reagent Run
        [2203] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Badlands Reagent Run II
        [2204] = {81, l10n("Dungeon")}, -- Restoring the Necklace
        [2240] = {81, l10n("Dungeon")}, -- The Hidden Chamber
        [2278] = {81, l10n("Dungeon")}, -- The Platinum Discs
        [2280] = {81, l10n("Dungeon")}, -- The Platinum Discs
        [2283] = {81, l10n("Dungeon")}, -- Necklace Recovery
        [2284] = {81, l10n("Dungeon")}, -- Necklace Recovery, Take 2
        [2318] = {81, l10n("Dungeon")}, -- Translating the Journal
        [2338] = {81, l10n("Dungeon")}, -- Translating the Journal
        [2339] = {81, l10n("Dungeon")}, -- Find the Gems and Power Source
        [2340] = {81, l10n("Dungeon")}, -- Deliver the Gems
        [2341] = {81, l10n("Dungeon")}, -- Necklace Recovery, Take 3
        [2342] = Expansions.Current == Expansions.Era and {81, l10n("Dungeon")} or nil, -- Reclaimed Treasures
        [2359] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Klaven's Tower
        [2361] = {81, l10n("Dungeon")}, -- Restoring the Necklace
        [2398] = {81, l10n("Dungeon")}, -- The Lost Dwarves
        [2418] = Expansions.Current == Expansions.Era and {81, l10n("Dungeon")} or nil, -- Power Stones
        [2478] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Mission: Possible But Not Probable
        [2499] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Oakenscowl
        [2501] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Badlands Reagent Run II
        [2721] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Kirith
        [2768] = {81, l10n("Dungeon")}, -- Divino-matic Rod
        [2769] = {81, l10n("Dungeon")}, -- The Brassbolts Brothers
        [2770] = {81, l10n("Dungeon")}, -- Gahz'rilla
        [2841] = {81, l10n("Dungeon")}, -- Rig Wars
        [2842] = {81, l10n("Dungeon")}, -- Chief Engineer Scooty
        [2843] = {81, l10n("Dungeon")}, -- Gnomer-gooooone!
        [2846] = {81, l10n("Dungeon")}, -- Tiara of the Deep
        [2861] = {81, l10n("Dungeon")}, -- Tabetha's Task
        [2864] = {81, l10n("Dungeon")}, -- Tran'rek
        [2865] = {81, l10n("Dungeon")}, -- Scarab Shells
        [2904] = {81, l10n("Dungeon")}, -- A Fine Mess
        [2922] = {81, l10n("Dungeon")}, -- Save Techbot's Brain!
        [2923] = {81, l10n("Dungeon")}, -- Tinkmaster Overspark
        [2924] = {81, l10n("Dungeon")}, -- Essential Artificials
        [2925] = {81, l10n("Dungeon")}, -- Klockmort's Essentials
        [2926] = {81, l10n("Dungeon")}, -- Gnogaine
        [2927] = {81, l10n("Dungeon")}, -- The Day After
        [2928] = {81, l10n("Dungeon")}, -- Gyrodrillmatic Excavationators
        [2929] = {81, l10n("Dungeon")}, -- The Grand Betrayal
        [2930] = {81, l10n("Dungeon")}, -- Data Rescue
        [2931] = {81, l10n("Dungeon")}, -- Castpipe's Task
        [2935] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Consult Master Gadrin
        [2936] = {81, l10n("Dungeon")}, -- The Spider God
        [2937] = {1, l10n("Elite")}, -- Summoning Shadra
        [2944] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Super Snapper FX
        [2945] = {81, l10n("Dungeon")}, -- Grime-Encrusted Ring
        [2946] = {1, l10n("Elite")}, -- Seeing What Happens
        [2947] = {81, l10n("Dungeon")}, -- Return of the Ring
        [2949] = {81, l10n("Dungeon")}, -- Return of the Ring
        [2951] = {81, l10n("Dungeon")}, -- The Sparklematic 5200!
        [2952] = {81, l10n("Dungeon")}, -- The Sparklematic 5200!
        [2953] = {81, l10n("Dungeon")}, -- More Sparklematic Action
        [2954] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Stone Watcher
        [2962] = {81, l10n("Dungeon")}, -- The Only Cure is More Green Glow
        [2966] = {1, l10n("Elite")}, -- Seeing What Happens
        [2967] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Return to Thunder Bluff
        [2977] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Return to Ironforge
        [2991] = {81, l10n("Dungeon")}, -- Nekrum's Medallion
        [2993] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Return to the Hinterlands
        [2994] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Saving Sharpbeak
        [3042] = {81, l10n("Dungeon")}, -- Troll Temper
        [3062] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Dark Heart
        [3127] = {1, l10n("Elite")}, -- Mountain Giant Muisek
        [3181] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Horn of the Beast
        [3182] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Proof of Deed
        [3201] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- At Last!
        [3341] = {81, l10n("Dungeon")}, -- Bring the End
        [3372] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Release Them
        [3373] = {81, l10n("Dungeon")}, -- The Essence of Eranikus
        [3380] = {81, l10n("Dungeon")}, -- The Sunken Temple
        [3385] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Undermarket
        [3446] = {81, l10n("Dungeon")}, -- Into the Depths
        [3447] = {81, l10n("Dungeon")}, -- Secret of the Circle
        [3452] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Flame's Casing
        [3463] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Set Them Ablaze!
        [3510] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Name of the Beast
        [3514] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Horde Presence
        [3523] = {81, l10n("Dungeon")}, -- Scourge of the Downs
        [3525] = {81, l10n("Dungeon")}, -- Extinguishing the Idol
        [3527] = {81, l10n("Dungeon")}, -- The Prophecy of Mosh'aru
        [3528] = {81, l10n("Dungeon")}, -- The God Hakkar
        [3566] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Rise, Obsidion!
        [3602] = {1, l10n("Elite")}, -- Azsharite
        [3627] = {1, l10n("Elite")}, -- Uniting the Shattered Amulet
        [3628] = {1, l10n("Elite")}, -- You Are Rakh'likh, Demon
        [3636] = {81, l10n("Dungeon")}, -- Bring the Light
        [3801] = {81, l10n("Dungeon")}, -- Dark Iron Legacy
        [3802] = {81, l10n("Dungeon")}, -- Dark Iron Legacy
        [3906] = {81, l10n("Dungeon")}, -- Disharmony of Flame
        [3907] = {81, l10n("Dungeon")}, -- Disharmony of Fire
        [3962] = {1, l10n("Elite")}, -- It's Dangerous to Go Alone
        [3981] = {81, l10n("Dungeon")}, -- Commander Gor'shak
        [3982] = {81, l10n("Dungeon")}, -- What Is Going On?
        [4001] = {81, l10n("Dungeon")}, -- What Is Going On?
        [4002] = {81, l10n("Dungeon")}, -- The Eastern Kingdoms
        [4003] = {81, l10n("Dungeon")}, -- The Royal Rescue
        [4004] = {81, l10n("Dungeon")}, -- The Princess Saved?
        [4021] = Expansions.Current >= Expansions.Tbc and {1, l10n("Elite")} or nil, -- Counterattack!
        [4023] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- A Taste of Flame
        [4024] = {81, l10n("Dungeon")}, -- A Taste of Flame
        [4063] = {81, l10n("Dungeon")}, -- The Rise of the Machines
        [4081] = {81, l10n("Dungeon")}, -- KILL ON SIGHT: Dark Iron Dwarves
        [4082] = {81, l10n("Dungeon")}, -- KILL ON SIGHT: High Ranking Dark Iron Officials
        [4083] = {81, l10n("Dungeon")}, -- The Spectral Chalice
        [4121] = {81, l10n("Dungeon")}, -- Precarious Predicament
        [4122] = {81, l10n("Dungeon")}, -- Grark Lorkrub
        [4123] = {81, l10n("Dungeon")}, -- The Heart of the Mountain
        [4126] = {81, l10n("Dungeon")}, -- Hurley Blackbreath
        [4128] = {81, l10n("Dungeon")}, -- Ragnar Thunderbrew
        [4132] = {81, l10n("Dungeon")}, -- Operation: Death to Angerforge
        [4133] = {81, l10n("Dungeon")}, -- Vivian Lagrave
        [4134] = {81, l10n("Dungeon")}, -- Lost Thunderbrew Recipe
        [4136] = {81, l10n("Dungeon")}, -- Ribbly Screwspigot
        [4143] = {81, l10n("Dungeon")}, -- Haze of Evil
        [4146] = Expansions.Current >= Expansions.Tbc and {81, l10n("Dungeon")} or {1, l10n("Elite")}, -- Zapper Fuel
        [4148] = {81, l10n("Dungeon")}, -- Bloodpetal Zapper
        [4182] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Dragonkin Menace
        [4201] = {81, l10n("Dungeon")}, -- The Love Potion
        [4241] = {81, l10n("Dungeon")}, -- Marshal Windsor
        [4242] = {81, l10n("Dungeon")}, -- Abandoned Hope
        [4262] = {81, l10n("Dungeon")}, -- Overmaster Pyron
        [4263] = {81, l10n("Dungeon")}, -- Incendius!
        [4264] = {81, l10n("Dungeon")}, -- A Crumpled Up Note
        [4282] = {81, l10n("Dungeon")}, -- A Shred of Hope
        [4286] = {81, l10n("Dungeon")}, -- The Good Stuff
        [4295] = {81, l10n("Dungeon")}, -- Rocknot's Ale
        [4322] = {81, l10n("Dungeon")}, -- Jail Break!
        [4324] = {81, l10n("Dungeon")}, -- Yuka Screwspigot
        [4341] = {81, l10n("Dungeon")}, -- Kharan Mighthammer
        [4342] = {81, l10n("Dungeon")}, -- Kharan's Tale
        [4361] = {81, l10n("Dungeon")}, -- The Bearer of Bad News
        [4362] = {81, l10n("Dungeon")}, -- The Fate of the Kingdom
        [4363] = {81, l10n("Dungeon")}, -- The Princess's Surprise
        [4601] = {81, l10n("Dungeon")}, -- The Sparklematic 5200!
        [4602] = {81, l10n("Dungeon")}, -- The Sparklematic 5200!
        [4603] = {81, l10n("Dungeon")}, -- More Sparklematic Action
        [4604] = {81, l10n("Dungeon")}, -- More Sparklematic Action
        [4605] = {81, l10n("Dungeon")}, -- The Sparklematic 5200!
        [4606] = {81, l10n("Dungeon")}, -- The Sparklematic 5200!
        [4701] = {81, l10n("Dungeon")}, -- Put Her Down
        [4724] = {81, l10n("Dungeon")}, -- The Pack Mistress
        [4729] = {81, l10n("Dungeon")}, -- Kibler's Exotic Pets
        [4734] = {62, l10n("Raid")}, -- Egg Freezing
        [4735] = {62, l10n("Raid")}, -- Egg Collection
        [4742] = {81, l10n("Dungeon")}, -- Seal of Ascension
        [4743] = {81, l10n("Dungeon")}, -- Seal of Ascension
        [4764] = {62, l10n("Raid")}, -- Doomrigger's Clasp
        [4766] = {62, l10n("Raid")}, -- Mayara Brightwing
        [4768] = {62, l10n("Raid")}, -- The Darkstone Tablet
        [4769] = {62, l10n("Raid")}, -- Vivian Lagrave and the Darkstone Tablet
        [4771] = {81, l10n("Dungeon")}, -- Dawn's Gambit
        [4787] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Ancient Egg
        [4788] = {81, l10n("Dungeon")}, -- The Final Tablets
        [4862] = {81, l10n("Dungeon")}, -- En-Ay-Es-Tee-Why
        [4866] = {81, l10n("Dungeon")}, -- Mother's Milk
        [4867] = {81, l10n("Dungeon")}, -- Urok Doomhowl
        [4903] = {81, l10n("Dungeon")}, -- Warlord's Command
        [4907] = {62, l10n("Raid")}, -- Tinkee Steamboil
        [4961] = {1, l10n("Elite")}, -- Cleansing of the Orb of Orahil
        [4974] = {62, l10n("Raid")}, -- For The Horde!
        [4981] = {81, l10n("Dungeon")}, -- Operative Bijou
        [4982] = {81, l10n("Dungeon")}, -- Bijou's Belongings
        [4983] = {81, l10n("Dungeon")}, -- Bijou's Reconnaissance Report
        [5001] = {81, l10n("Dungeon")}, -- Bijou's Belongings
        [5002] = {81, l10n("Dungeon")}, -- Message to Maxwell
        [5047] = {81, l10n("Dungeon")}, -- Pip Quickwit, At Your Service!
        [5054] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Ursius of the Shardtooth
        [5055] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Brumeran of the Chillwind
        [5056] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Shy-Rotam
        [5063] = {1, l10n("Elite")}, -- Cap of the Scarlet Savant
        [5065] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Lost Tablets of Mosh'aru
        [5067] = {1, l10n("Elite")}, -- Leggings of Arcana
        [5068] = {1, l10n("Elite")}, -- Breastplate of Bloodthirst
        [5081] = {81, l10n("Dungeon")}, -- Maxwell's Mission
        [5088] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Arikara
        [5089] = {81, l10n("Dungeon")}, -- General Drakkisath's Command
        [5098] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- All Along the Watchtowers
        [5102] = {62, l10n("Raid")}, -- General Drakkisath's Demise
        [5103] = {81, l10n("Dungeon")}, -- Hot Fiery Death
        [5121] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- High Chief Winterfall
        [5122] = {81, l10n("Dungeon")}, -- The Medallion of Faith
        [5124] = {1, l10n("Elite")}, -- Fiery Plate Gauntlets
        [5125] = {81, l10n("Dungeon")}, -- Aurius' Reckoning
        [5127] = {81, l10n("Dungeon")}, -- The Demon Forge
        [5151] = {1, l10n("Elite")}, -- Hypercapacitor Gizmo
        [5153] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- A Strange Historian
        [5156] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Verifying the Corruption
        [5160] = {81, l10n("Dungeon")}, -- The Matron Protectorate
        [5162] = {1, l10n("Elite")}, -- Wrath of the Blue Flight
        [5164] = {1, l10n("Elite")}, -- Catalogue of the Wayward
        [5166] = {1, l10n("Elite")}, -- Breastplate of the Chromatic Flight
        [5167] = {1, l10n("Elite")}, -- Legplates of the Chromatic Defier
        [5168] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Heroes of Darrowshire
        [5212] = {81, l10n("Dungeon")}, -- The Flesh Does Not Lie
        [5213] = {81, l10n("Dungeon")}, -- The Active Agent
        [5214] = {81, l10n("Dungeon")}, -- The Great Ezra Grimm
        [5243] = {81, l10n("Dungeon")}, -- Houses of the Holy
        [5247] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Fragments of the Past
        [5251] = {81, l10n("Dungeon")}, -- The Archivist
        [5262] = {81, l10n("Dungeon")}, -- The Truth Comes Crashing Down
        [5263] = {81, l10n("Dungeon")}, -- Above and Beyond
        [5264] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Lord Maxwell Tyrosus
        [5265] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Argent Hold
        [5281] = {81, l10n("Dungeon")}, -- The Restless Souls
        [5282] = {81, l10n("Dungeon")}, -- The Restless Souls
        [5305] = {81, l10n("Dungeon")}, -- Sweet Serenity
        [5306] = {81, l10n("Dungeon")}, -- Snakestone of the Shadow Huntress
        [5307] = {81, l10n("Dungeon")}, -- Corruption
        [5341] = {81, l10n("Dungeon")}, -- Barov Family Fortune
        [5342] = Expansions.Current == Expansions.Era and {41, l10n("PvP")} or {1, l10n("Elite")}, -- The Last Barov
        [5343] = {81, l10n("Dungeon")}, -- Barov Family Fortune
        [5344] = Expansions.Current == Expansions.Era and {41, l10n("PvP")} or {1, l10n("Elite")}, -- The Last Barov
        [5382] = {81, l10n("Dungeon")}, -- Doctor Theolen Krastinov, the Butcher
        [5384] = {81, l10n("Dungeon")}, -- Kirtonos the Herald
        [5461] = {1, l10n("Elite")}, -- The Human, Ras Frostwhisper
        [5462] = {1, l10n("Elite")}, -- The Dying, Ras Frostwhisper
        [5463] = {81, l10n("Dungeon")}, -- Menethil's Gift
        [5464] = {1, l10n("Elite")}, -- Menethil's Gift
        [5465] = {1, l10n("Elite")}, -- Soulbound Keepsake
        [5466] = {81, l10n("Dungeon")}, -- The Lich, Ras Frostwhisper
        [5515] = {81, l10n("Dungeon")}, -- Krastinov's Bag of Horrors
        [5518] = {81, l10n("Dungeon")}, -- The Gordok Ogre Suit
        [5519] = {81, l10n("Dungeon")}, -- The Gordok Ogre Suit
        [5522] = {81, l10n("Dungeon")}, -- Leonid Barthalomew
        [5525] = {81, l10n("Dungeon")}, -- Free Knot!
        [5526] = {81, l10n("Dungeon")}, -- Shards of the Felvine
        [5528] = {81, l10n("Dungeon")}, -- The Gordok Taste Test
        [5529] = {81, l10n("Dungeon")}, -- Plagued Hatchlings
        [5531] = {81, l10n("Dungeon")}, -- Betina Bigglezink
        [5582] = {81, l10n("Dungeon")}, -- Healthy Dragon Scale
        [5721] = {62, l10n("Raid")}, -- The Battle of Darrowshire
        [5722] = {81, l10n("Dungeon")}, -- Searching for the Lost Satchel
        [5723] = {81, l10n("Dungeon")}, -- Testing an Enemy's Strength
        [5724] = {81, l10n("Dungeon")}, -- Returning the Lost Satchel
        [5725] = {81, l10n("Dungeon")}, -- The Power to Destroy...
        [5728] = {81, l10n("Dungeon")}, -- Hidden Enemies
        [5761] = {81, l10n("Dungeon")}, -- Slaying the Beast
        [5803] = {1, l10n("Elite")}, -- Araj's Scarab
        [5804] = {1, l10n("Elite")}, -- Araj's Scarab
        [5848] = {81, l10n("Dungeon")}, -- Of Love and Family
        [5862] = {1, l10n("Elite")}, -- Scarlet Subterfuge
        [5892] = {41, l10n("PvP")}, -- Irondeep Supplies
        [5893] = {41, l10n("PvP")}, -- Coldtooth Supplies
        [5944] = {1, l10n("Elite")}, -- In Dreams
        [5981] = {1, l10n("Elite")}, -- Rampaging Giants
        [6025] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Unfinished Business
        [6041] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- When Smokey Sings, I Get Violent
        [6135] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Duskwing, Oh How I Hate Thee...
        [6136] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Corpulent One
        [6145] = {1, l10n("Elite")}, -- The Crimson Courier
        [6146] = {1, l10n("Elite")}, -- Nathanos' Ruse
        [6147] = {1, l10n("Elite")}, -- Return to Nathanos
        [6148] = {1, l10n("Elite")}, -- The Scarlet Oracle, Demetria
        [6163] = {81, l10n("Dungeon")}, -- Ramstein
        [6182] = {1, l10n("Elite")}, -- The First and the Last
        [6183] = {1, l10n("Elite")}, -- Honor the Dead
        [6184] = {1, l10n("Elite")}, -- Flint Shadowmore
        [6185] = {1, l10n("Elite")}, -- The Eastern Plagues
        [6186] = {1, l10n("Elite")}, -- The Blightcaller Cometh
        [6187] = {62, l10n("Raid")}, -- Order Must Be Restored
        [6283] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Bloodfury Bloodline
        [6284] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Arachnophobia
        [6402] = {62, l10n("Raid")}, -- Stormwind Rendezvous
        [6403] = {62, l10n("Raid")}, -- The Great Masquerade
        [6481] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Earthen Arise
        [6501] = {62, l10n("Raid")}, -- The Dragon's Eye
        [6502] = {62, l10n("Raid")}, -- Drakefire Amulet
        [6521] = {81, l10n("Dungeon")}, -- An Unholy Alliance
        [6522] = {81, l10n("Dungeon")}, -- An Unholy Alliance
        [6561] = {81, l10n("Dungeon")}, -- Blackfathom Villainy
        [6562] = {81, l10n("Dungeon")}, -- Trouble in the Deeps
        [6563] = {81, l10n("Dungeon")}, -- The Essence of Aku'Mai
        [6564] = {81, l10n("Dungeon")}, -- Allegiance to the Old Gods
        [6565] = {81, l10n("Dungeon")}, -- Allegiance to the Old Gods
        [6569] = {62, l10n("Raid")}, -- Oculus Illusions
        [6570] = {1, l10n("Elite")}, -- Emberstrife
        [6582] = {62, l10n("Raid")}, -- The Test of Skulls, Scryer
        [6583] = {62, l10n("Raid")}, -- The Test of Skulls, Somnus
        [6584] = {62, l10n("Raid")}, -- The Test of Skulls, Chronalis
        [6585] = {62, l10n("Raid")}, -- The Test of Skulls, Axtroz
        [6602] = {62, l10n("Raid")}, -- Blood of the Black Dragon Champion
        [6626] = {81, l10n("Dungeon")}, -- A Host of Evil
        [6641] = Expansions.Current >= Expansions.Tbc and {1, l10n("Elite")} or nil, -- Vorsha the Lasher
        [6642] = {81, l10n("Dungeon")}, -- Favor Amongst the Brotherhood, Dark Iron Ore
        [6643] = {81, l10n("Dungeon")}, -- Favor Amongst the Brotherhood, Fiery Core
        [6644] = {81, l10n("Dungeon")}, -- Favor Amongst the Brotherhood, Lava Core
        [6645] = {81, l10n("Dungeon")}, -- Favor Amongst the Brotherhood, Core Leather
        [6646] = {81, l10n("Dungeon")}, -- Favor Amongst the Brotherhood, Blood of the Mountain
        [6741] = {41, l10n("PvP")}, -- More Booty!
        [6781] = {41, l10n("PvP")}, -- More Armor Scraps
        [6801] = {41, l10n("PvP")}, -- Lokholar the Ice Lord
        [6821] = {62, l10n("Raid")}, -- Eye of the Emberseer
        [6822] = {62, l10n("Raid")}, -- The Molten Core
        [6824] = {62, l10n("Raid")}, -- Hands of the Enemy
        [6825] = {41, l10n("PvP")}, -- Call of Air - Guse's Fleet
        [6826] = {41, l10n("PvP")}, -- Call of Air - Jeztor's Fleet
        [6827] = {41, l10n("PvP")}, -- Call of Air - Mulverick's Fleet
        [6846] = {41, l10n("PvP")}, -- Begin the Attack!
        [6847] = {41, l10n("PvP")}, -- Master Ryson's All Seeing Eye
        [6848] = {41, l10n("PvP")}, -- Master Ryson's All Seeing Eye
        [6861] = {41, l10n("PvP")}, -- Zinfizzlex's Portable Shredder Unit
        [6862] = {41, l10n("PvP")}, -- Zinfizzlex's Portable Shredder Unit
        [6881] = {41, l10n("PvP")}, -- Ivus the Forest Lord
        [6901] = {41, l10n("PvP")}, -- Launch the Attack!
        [6921] = {81, l10n("Dungeon")}, -- Amongst the Ruins
        [6922] = {81, l10n("Dungeon")}, -- Baron Aquanis
        [6941] = {41, l10n("PvP")}, -- Call of Air - Vipore's Fleet
        [6942] = {41, l10n("PvP")}, -- Call of Air - Slidore's Fleet
        [6943] = {41, l10n("PvP")}, -- Call of Air - Ichman's Fleet
        [6982] = {41, l10n("PvP")}, -- Coldtooth Supplies
        [6983] = {1, l10n("Elite")}, -- You're a Mean One...
        [6985] = {41, l10n("PvP")}, -- Irondeep Supplies
        [7001] = {41, l10n("PvP")}, -- Empty Stables
        [7002] = {41, l10n("PvP")}, -- Ram Hide Harnesses
        [7026] = {41, l10n("PvP")}, -- Ram Riding Harnesses
        [7027] = {41, l10n("PvP")}, -- Empty Stables
        [7028] = {81, l10n("Dungeon")}, -- Twisted Evils
        [7029] = {81, l10n("Dungeon")}, -- Vyletongue Corruption
        [7041] = {81, l10n("Dungeon")}, -- Vyletongue Corruption
        [7043] = {1, l10n("Elite")}, -- You're a Mean One...
        [7044] = {81, l10n("Dungeon")}, -- Legends of Maraudon
        [7046] = {81, l10n("Dungeon")}, -- The Scepter of Celebras
        [7064] = {81, l10n("Dungeon")}, -- Corruption of Earth and Seed
        [7065] = {81, l10n("Dungeon")}, -- Corruption of Earth and Seed
        [7066] = {81, l10n("Dungeon")}, -- Seed of Life
        [7067] = {81, l10n("Dungeon")}, -- The Pariah's Instructions
        [7068] = {81, l10n("Dungeon")}, -- Shadowshard Fragments
        [7070] = {81, l10n("Dungeon")}, -- Shadowshard Fragments
        [7081] = {41, l10n("PvP")}, -- Alterac Valley Graveyards
        [7082] = {41, l10n("PvP")}, -- The Graveyards of Alterac
        [7101] = {41, l10n("PvP")}, -- Towers and Bunkers
        [7102] = {41, l10n("PvP")}, -- Towers and Bunkers
        [7121] = {41, l10n("PvP")}, -- The Quartermaster
        [7122] = {41, l10n("PvP")}, -- Capture a Mine
        [7123] = {41, l10n("PvP")}, -- Speak with our Quartermaster
        [7124] = {41, l10n("PvP")}, -- Capture a Mine
        [7141] = {41, l10n("PvP")}, -- The Battle of Alterac
        [7142] = {41, l10n("PvP")}, -- The Battle for Alterac
        [7161] = {41, l10n("PvP")}, -- Proving Grounds
        [7162] = {41, l10n("PvP")}, -- Proving Grounds
        [7163] = {41, l10n("PvP")}, -- Rise and Be Recognized
        [7164] = {41, l10n("PvP")}, -- Honored Amongst the Clan
        [7165] = {41, l10n("PvP")}, -- Earned Reverence
        [7166] = {41, l10n("PvP")}, -- Legendary Heroes
        [7167] = {41, l10n("PvP")}, -- The Eye of Command
        [7168] = {41, l10n("PvP")}, -- Rise and Be Recognized
        [7169] = {41, l10n("PvP")}, -- Honored Amongst the Guard
        [7170] = {41, l10n("PvP")}, -- Earned Reverence
        [7171] = {41, l10n("PvP")}, -- Legendary Heroes
        [7172] = {41, l10n("PvP")}, -- The Eye of Command
        [7181] = {41, l10n("PvP")}, -- The Legend of Korrak
        [7201] = {81, l10n("Dungeon")}, -- The Last Element
        [7202] = {41, l10n("PvP")}, -- Korrak the Bloodrager
        [7221] = {41, l10n("PvP")}, -- Speak with Prospector Stonehewer
        [7222] = {41, l10n("PvP")}, -- Speak with Voggah Deathgrip
        [7223] = {41, l10n("PvP")}, -- Armor Scraps
        [7224] = {41, l10n("PvP")}, -- Enemy Booty
        [7241] = {41, l10n("PvP")}, -- In Defense of Frostwolf
        [7261] = {41, l10n("PvP")}, -- The Sovereign Imperative
        [7281] = {41, l10n("PvP")}, -- Brotherly Love
        [7282] = {41, l10n("PvP")}, -- Brotherly Love
        [7301] = {41, l10n("PvP")}, -- Fallen Sky Lords
        [7302] = {41, l10n("PvP")}, -- Fallen Sky Lords
        [7361] = {41, l10n("PvP")}, -- Favor Amongst the Darkspear
        [7362] = {41, l10n("PvP")}, -- Ally of the Tauren
        [7363] = {41, l10n("PvP")}, -- The Human Condition
        [7364] = {41, l10n("PvP")}, -- Gnomeregan Bounty
        [7365] = {41, l10n("PvP")}, -- Staghelm's Requiem
        [7366] = {41, l10n("PvP")}, -- The Archbishop's Mercy
        [7367] = {41, l10n("PvP")}, -- Defusing the Threat
        [7368] = {41, l10n("PvP")}, -- Defusing the Threat
        [7381] = {41, l10n("PvP")}, -- The Return of Korrak
        [7382] = {41, l10n("PvP")}, -- Korrak the Everliving
        [7385] = {41, l10n("PvP")}, -- A Gallon of Blood
        [7386] = {41, l10n("PvP")}, -- Crystal Cluster
        [7401] = {41, l10n("PvP")}, -- WANTED: Dwarves!
        [7402] = {41, l10n("PvP")}, -- WANTED: Orcs!
        [7421] = {41, l10n("PvP")}, -- Darkspear Defense
        [7422] = {41, l10n("PvP")}, -- Tuft it Out
        [7423] = {41, l10n("PvP")}, -- I've Got A Fever For More Bone Chips
        [7424] = {41, l10n("PvP")}, -- What the Hoof?
        [7425] = {41, l10n("PvP")}, -- Staghelm's Mojo Jamboree
        [7426] = {41, l10n("PvP")}, -- One Man's Love
        [7427] = {41, l10n("PvP")}, -- Wanted: MORE DWARVES!
        [7428] = {41, l10n("PvP")}, -- Wanted: MORE ORCS!
        [7429] = {81, l10n("Dungeon")}, -- Free Knot!
        [7441] = {81, l10n("Dungeon")}, -- Pusillin and the Elder Azj'Tordin
        [7461] = {81, l10n("Dungeon")}, -- The Madness Within
        [7463] = {81, l10n("Dungeon")}, -- Arcane Refreshment
        [7481] = {81, l10n("Dungeon")}, -- Elven Legends
        [7482] = {81, l10n("Dungeon")}, -- Elven Legends
        [7483] = {81, l10n("Dungeon")}, -- Libram of Rapidity
        [7484] = {81, l10n("Dungeon")}, -- Libram of Focus
        [7485] = {81, l10n("Dungeon")}, -- Libram of Protection
        [7488] = {81, l10n("Dungeon")}, -- Lethtendris's Web
        [7489] = {81, l10n("Dungeon")}, -- Lethtendris's Web
        [7492] = {81, l10n("Dungeon")}, -- Camp Mojache
        [7494] = {81, l10n("Dungeon")}, -- Feathermoon Stronghold
        [7498] = {81, l10n("Dungeon")}, -- Garona: A Study on Stealth and Treachery
        [7499] = {81, l10n("Dungeon")}, -- Codex of Defense
        [7500] = {81, l10n("Dungeon")}, -- The Arcanist's Cookbook
        [7501] = {81, l10n("Dungeon")}, -- The Light and How To Swing It
        [7502] = {81, l10n("Dungeon")}, -- Harnessing Shadows
        [7503] = {81, l10n("Dungeon")}, -- The Greatest Race of Hunters
        [7504] = {81, l10n("Dungeon")}, -- Holy Bologna: What the Light Won't Tell You
        [7505] = {81, l10n("Dungeon")}, -- Frost Shock and You
        [7506] = {81, l10n("Dungeon")}, -- The Emerald Dream...
        [7507] = {81, l10n("Dungeon")}, -- Nostro's Compendium
        [7508] = {81, l10n("Dungeon")}, -- The Forging of Quel'Serrar
        [7509] = {62, l10n("Raid")}, -- The Forging of Quel'Serrar
        [7581] = {81, l10n("Dungeon")}, -- The Prison's Bindings
        [7582] = {1, l10n("Elite")}, -- The Prison's Casing
        [7583] = {1, l10n("Elite")}, -- Suppression
        [7603] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Kroshius' Infernal Core
        [7604] = {81, l10n("Dungeon")}, -- A Binding Contract
        [7629] = {81, l10n("Dungeon")}, -- Imp Delivery
        [7631] = {81, l10n("Dungeon")}, -- Dreadsteed of Xoroth
        [7634] = {62, l10n("Raid")}, -- Ancient Sinew Wrapped Lamina
        [7635] = {62, l10n("Raid")}, -- A Proper String
        [7636] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Stave of the Ancients
        [7642] = {81, l10n("Dungeon")}, -- Collection of Goods
        [7643] = {81, l10n("Dungeon")}, -- Ancient Equine Spirit
        [7647] = {81, l10n("Dungeon")}, -- Judgment and Redemption
        [7649] = {81, l10n("Dungeon")}, -- Enchanted Thorium Platemail: Volume I
        [7650] = {81, l10n("Dungeon")}, -- Enchanted Thorium Platemail: Volume II
        [7651] = {81, l10n("Dungeon")}, -- Enchanted Thorium Platemail: Volume III
        [7666] = {81, l10n("Dungeon")}, -- Again Into the Great Ossuary
        [7668] = {81, l10n("Dungeon")}, -- The Darkreaver Menace
        [7701] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- WANTED: Overseer Maltorius
        [7703] = {81, l10n("Dungeon")}, -- Unfinished Gordok Business
        [7737] = {81, l10n("Dungeon")}, -- Gaining Acceptance
        [7761] = {81, l10n("Dungeon")}, -- Blackhand's Command
        [7786] = {62, l10n("Raid")}, -- Thunderaan the Windseeker
        [7788] = {41, l10n("PvP")}, -- Vanquish the Invaders!
        [7789] = {41, l10n("PvP")}, -- Quell the Silverwing Usurpers
        [7810] = {41, l10n("PvP")}, -- Arena Master
        [7816] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Gammerita, Mon!
        [7838] = {41, l10n("PvP")}, -- Arena Grandmaster
        [7841] = {41, l10n("PvP")}, -- Message to the Wildhammer
        [7842] = {41, l10n("PvP")}, -- Another Message to the Wildhammer
        [7843] = {41, l10n("PvP")}, -- The Final Message to the Wildhammer
        [7845] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Kidnapped Elder Torntusk!
        [7846] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Recover the Key!
        [7847] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Return to Primal Torntusk
        [7848] = {81, l10n("Dungeon")}, -- Attunement to the Core
        [7849] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Separation Anxiety
        [7850] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Dark Vessels
        [7861] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Wanted: Vile Priestess Hexx and Her Minions
        [7862] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Job Opening: Guard Captain of Revantusk Village
        [7871] = {41, l10n("PvP")}, -- Vanquish the Invaders!
        [7872] = {41, l10n("PvP")}, -- Vanquish the Invaders!
        [7873] = {41, l10n("PvP")}, -- Vanquish the Invaders!
        [7874] = {41, l10n("PvP")}, -- Quell the Silverwing Usurpers
        [7875] = {41, l10n("PvP")}, -- Quell the Silverwing Usurpers
        [7876] = {41, l10n("PvP")}, -- Quell the Silverwing Usurpers
        [7877] = {81, l10n("Dungeon")}, -- The Treasure of the Shen'dralar
        [7886] = {41, l10n("PvP")}, -- Talismans of Merit
        [7887] = {41, l10n("PvP")}, -- Talismans of Merit
        [7888] = {41, l10n("PvP")}, -- Talismans of Merit
        [7921] = {41, l10n("PvP")}, -- Talismans of Merit
        [7922] = {41, l10n("PvP")}, -- Mark of Honor
        [7923] = {41, l10n("PvP")}, -- Mark of Honor
        [7924] = {41, l10n("PvP")}, -- Mark of Honor
        [7925] = {41, l10n("PvP")}, -- Mark of Honor
        [8041] = {62, l10n("Raid")}, -- Strength of Mount Mugamba
        [8042] = {62, l10n("Raid")}, -- Strength of Mount Mugamba
        [8043] = {62, l10n("Raid")}, -- Strength of Mount Mugamba
        [8044] = {62, l10n("Raid")}, -- The Rage of Mugamba
        [8045] = {62, l10n("Raid")}, -- The Heathen's Brand
        [8046] = {62, l10n("Raid")}, -- The Heathen's Brand
        [8047] = {62, l10n("Raid")}, -- The Heathen's Brand
        [8048] = {62, l10n("Raid")}, -- The Hero's Brand
        [8049] = {62, l10n("Raid")}, -- The Eye of Zuldazar
        [8050] = {62, l10n("Raid")}, -- The Eye of Zuldazar
        [8051] = {62, l10n("Raid")}, -- The Eye of Zuldazar
        [8052] = {62, l10n("Raid")}, -- The All-Seeing Eye of Zuldazar
        [8053] = {62, l10n("Raid")}, -- Paragons of Power: The Freethinker's Armguards
        [8054] = {62, l10n("Raid")}, -- Paragons of Power: The Freethinker's Belt
        [8055] = {62, l10n("Raid")}, -- Paragons of Power: The Freethinker's Breastplate
        [8056] = {62, l10n("Raid")}, -- Paragons of Power: The Augur's Bracers
        [8057] = {62, l10n("Raid")}, -- Paragons of Power: The Haruspex's Bracers
        [8058] = {62, l10n("Raid")}, -- Paragons of Power: The Vindicator's Armguards
        [8059] = {62, l10n("Raid")}, -- Paragons of Power: The Demoniac's Wraps
        [8060] = {62, l10n("Raid")}, -- Paragons of Power: The Illusionist's Wraps
        [8061] = {62, l10n("Raid")}, -- Paragons of Power: The Confessor's Wraps
        [8062] = {62, l10n("Raid")}, -- Paragons of Power: The Predator's Bracers
        [8063] = {62, l10n("Raid")}, -- Paragons of Power: The Madcap's Bracers
        [8064] = {62, l10n("Raid")}, -- Paragons of Power: The Haruspex's Belt
        [8065] = {62, l10n("Raid")}, -- Paragons of Power: The Haruspex's Tunic
        [8066] = {62, l10n("Raid")}, -- Paragons of Power: The Predator's Belt
        [8067] = {62, l10n("Raid")}, -- Paragons of Power: The Predator's Mantle
        [8068] = {62, l10n("Raid")}, -- Paragons of Power: The Illusionist's Mantle
        [8069] = {62, l10n("Raid")}, -- Paragons of Power: The Illusionist's Robes
        [8070] = {62, l10n("Raid")}, -- Paragons of Power: The Confessor's Bindings
        [8071] = {62, l10n("Raid")}, -- Paragons of Power: The Confessor's Mantle
        [8072] = {62, l10n("Raid")}, -- Paragons of Power: The Madcap's Mantle
        [8073] = {62, l10n("Raid")}, -- Paragons of Power: The Madcap's Tunic
        [8074] = {62, l10n("Raid")}, -- Paragons of Power: The Augur's Belt
        [8075] = {62, l10n("Raid")}, -- Paragons of Power: The Augur's Hauberk
        [8076] = {62, l10n("Raid")}, -- Paragons of Power: The Demoniac's Mantle
        [8077] = {62, l10n("Raid")}, -- Paragons of Power: The Demoniac's Robes
        [8078] = {62, l10n("Raid")}, -- Paragons of Power: The Vindicator's Belt
        [8079] = {62, l10n("Raid")}, -- Paragons of Power: The Vindicator's Breastplate
        [8080] = {41, l10n("PvP")}, -- Arathi Basin Resources!
        [8081] = {41, l10n("PvP")}, -- More Resource Crates
        [8101] = {62, l10n("Raid")}, -- The Pebble of Kajaro
        [8102] = {62, l10n("Raid")}, -- The Pebble of Kajaro
        [8103] = {62, l10n("Raid")}, -- The Pebble of Kajaro
        [8104] = {62, l10n("Raid")}, -- The Jewel of Kajaro
        [8105] = {41, l10n("PvP")}, -- The Battle for Arathi Basin!
        [8106] = {62, l10n("Raid")}, -- Kezan's Taint
        [8107] = {62, l10n("Raid")}, -- Kezan's Taint
        [8108] = {62, l10n("Raid")}, -- Kezan's Taint
        [8109] = {62, l10n("Raid")}, -- Kezan's Unstoppable Taint
        [8110] = {62, l10n("Raid")}, -- Enchanted South Seas Kelp
        [8111] = {62, l10n("Raid")}, -- Enchanted South Seas Kelp
        [8112] = {62, l10n("Raid")}, -- Enchanted South Seas Kelp
        [8113] = {62, l10n("Raid")}, -- Pristine Enchanted South Seas Kelp
        [8114] = {41, l10n("PvP")}, -- Control Four Bases
        [8115] = {41, l10n("PvP")}, -- Control Five Bases
        [8116] = {62, l10n("Raid")}, -- Vision of Voodress
        [8117] = {62, l10n("Raid")}, -- Vision of Voodress
        [8118] = {62, l10n("Raid")}, -- Vision of Voodress
        [8119] = {62, l10n("Raid")}, -- The Unmarred Vision of Voodress
        [8120] = {41, l10n("PvP")}, -- The Battle for Arathi Basin!
        [8121] = {41, l10n("PvP")}, -- Take Four Bases
        [8122] = {41, l10n("PvP")}, -- Take Five Bases
        [8123] = {41, l10n("PvP")}, -- Cut Arathor Supply Lines
        [8124] = {41, l10n("PvP")}, -- More Resource Crates
        [8141] = {62, l10n("Raid")}, -- Zandalarian Shadow Talisman
        [8142] = {62, l10n("Raid")}, -- Zandalarian Shadow Talisman
        [8143] = {62, l10n("Raid")}, -- Zandalarian Shadow Talisman
        [8144] = {62, l10n("Raid")}, -- Zandalarian Shadow Mastery Talisman
        [8145] = {62, l10n("Raid")}, -- The Maelstrom's Tendril
        [8146] = {62, l10n("Raid")}, -- The Maelstrom's Tendril
        [8147] = {62, l10n("Raid")}, -- The Maelstrom's Tendril
        [8148] = {62, l10n("Raid")}, -- Maelstrom's Wrath
        [8154] = {41, l10n("PvP")}, -- Arathi Basin Resources!
        [8155] = {41, l10n("PvP")}, -- Arathi Basin Resources!
        [8156] = {41, l10n("PvP")}, -- Arathi Basin Resources!
        [8157] = {41, l10n("PvP")}, -- More Resource Crates
        [8158] = {41, l10n("PvP")}, -- More Resource Crates
        [8159] = {41, l10n("PvP")}, -- More Resource Crates
        [8160] = {41, l10n("PvP")}, -- Cut Arathor Supply Lines
        [8161] = {41, l10n("PvP")}, -- Cut Arathor Supply Lines
        [8162] = {41, l10n("PvP")}, -- Cut Arathor Supply Lines
        [8163] = {41, l10n("PvP")}, -- More Resource Crates
        [8164] = {41, l10n("PvP")}, -- More Resource Crates
        [8165] = {41, l10n("PvP")}, -- More Resource Crates
        [8166] = {41, l10n("PvP")}, -- The Battle for Arathi Basin!
        [8167] = {41, l10n("PvP")}, -- The Battle for Arathi Basin!
        [8168] = {41, l10n("PvP")}, -- The Battle for Arathi Basin!
        [8169] = {41, l10n("PvP")}, -- The Battle for Arathi Basin!
        [8170] = {41, l10n("PvP")}, -- The Battle for Arathi Basin!
        [8171] = {41, l10n("PvP")}, -- The Battle for Arathi Basin!
        [8181] = {62, l10n("Raid")}, -- Confront Yeh'kinya
        [8182] = {62, l10n("Raid")}, -- The Hand of Rastakhan
        [8184] = {62, l10n("Raid")}, -- Presence of Might
        [8185] = {62, l10n("Raid")}, -- Syncretist's Sigil
        [8186] = {62, l10n("Raid")}, -- Death's Embrace
        [8187] = {62, l10n("Raid")}, -- Falcon's Call
        [8188] = {62, l10n("Raid")}, -- Vodouisant's Vigilant Embrace
        [8189] = {62, l10n("Raid")}, -- Presence of Sight
        [8190] = {62, l10n("Raid")}, -- Hoodoo Hex
        [8191] = {62, l10n("Raid")}, -- Prophetic Aura
        [8192] = {62, l10n("Raid")}, -- Animist's Caress
        [8201] = {62, l10n("Raid")}, -- A Collection of Heads
        [8227] = {62, l10n("Raid")}, -- Nat's Measuring Tape
        [8232] = {81, l10n("Dungeon")}, -- The Green Drake
        [8236] = {81, l10n("Dungeon")}, -- The Azure Key
        [8253] = {81, l10n("Dungeon")}, -- Destroy Morphaz
        [8257] = {81, l10n("Dungeon")}, -- Blood of Morphaz
        [8258] = {81, l10n("Dungeon")}, -- The Darkreaver Menace
        [8260] = {41, l10n("PvP")}, -- Arathor Basic Care Package
        [8261] = {41, l10n("PvP")}, -- Arathor Standard Care Package
        [8262] = {41, l10n("PvP")}, -- Arathor Advanced Care Package
        [8263] = {41, l10n("PvP")}, -- Defiler's Basic Care Package
        [8264] = {41, l10n("PvP")}, -- Defiler's Standard Care Package
        [8265] = {41, l10n("PvP")}, -- Defiler's Advanced Care Package
        [8266] = {41, l10n("PvP")}, -- Ribbons of Sacrifice
        [8267] = {41, l10n("PvP")}, -- Ribbons of Sacrifice
        [8268] = {41, l10n("PvP")}, -- Ribbons of Sacrifice
        [8269] = {41, l10n("PvP")}, -- Ribbons of Sacrifice
        [8271] = {41, l10n("PvP")}, -- Hero of the Stormpike
        [8272] = {41, l10n("PvP")}, -- Hero of the Frostwolf
        [8283] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Wanted - Deathclasp, Terror of the Sands
        [8288] = {62, l10n("Raid")}, -- Only One May Rise
        [8289] = {41, l10n("PvP")}, -- Talismans of Merit
        [8290] = {41, l10n("PvP")}, -- Vanquish the Invaders
        [8291] = {41, l10n("PvP")}, -- Vanquish the Invaders!
        [8292] = {41, l10n("PvP")}, -- Talismans of Merit
        [8293] = {41, l10n("PvP")}, -- Mark of Honor
        [8294] = {41, l10n("PvP")}, -- Quell the Silverwing Usurpers
        [8295] = {41, l10n("PvP")}, -- Quell the Silverwing Usurpers
        [8296] = {41, l10n("PvP")}, -- Mark of Honor
        [8297] = {41, l10n("PvP")}, -- Arathi Basin Resources!
        [8298] = {41, l10n("PvP")}, -- More Resource Crates
        [8299] = {41, l10n("PvP")}, -- Cut Arathor Supply Lines
        [8300] = {41, l10n("PvP")}, -- More Resource Crates
        [8301] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Path of the Righteous
        [8302] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- The Hand of the Righteous
        [8304] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Dearest Natalia
        [8306] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Into The Maw of Madness
        [8308] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Brann Bronzebeard's Lost Letter
        [8309] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Glyph Chasing
        [8310] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Breaking the Code
        [8314] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Unraveling the Mystery
        [8315] = Expansions.Current == Expansions.Era and {62, l10n("Raid")} or {1, l10n("Elite")}, -- The Calling
        [8316] = {62, l10n("Raid")}, -- Armaments of War
        [8322] = {41, l10n("PvP")}, -- Rotten Eggs
        [8331] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Aurel Goldleaf
        [8332] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Dukes of the Council
        [8341] = {1, l10n("Elite")}, -- Lords of the Council
        [8348] = {1, l10n("Elite")}, -- Signet of the Dukes
        [8349] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Bor Wildmane
        [8351] = {62, l10n("Raid")}, -- Bor Wishes to Speak
        [8352] = {62, l10n("Raid")}, -- Scepter of the Council
        [8361] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Abyssal Contacts
        [8362] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Abyssal Crests
        [8363] = {1, l10n("Elite")}, -- Abyssal Signets
        [8364] = {62, l10n("Raid")}, -- Abyssal Scepters
        [8367] = {41, l10n("PvP")}, -- For Great Honor
        [8368] = {41, l10n("PvP")}, -- Battle of Warsong Gulch
        [8369] = {41, l10n("PvP")}, -- Invaders of Alterac Valley
        [8370] = {41, l10n("PvP")}, -- Conquering Arathi Basin
        [8371] = {41, l10n("PvP")}, -- Concerted Efforts
        [8372] = {41, l10n("PvP")}, -- Fight for Warsong Gulch
        [8373] = {41, l10n("PvP")}, -- The Power of Pine
        [8374] = {41, l10n("PvP")}, -- Claiming Arathi Basin
        [8375] = {41, l10n("PvP")}, -- Remember Alterac Valley!
        [8376] = {62, l10n("Raid")}, -- Armaments of War
        [8377] = {62, l10n("Raid")}, -- Armaments of War
        [8378] = {62, l10n("Raid")}, -- Armaments of War
        [8379] = {62, l10n("Raid")}, -- Armaments of War
        [8380] = {62, l10n("Raid")}, -- Armaments of War
        [8381] = {62, l10n("Raid")}, -- Armaments of War
        [8382] = {62, l10n("Raid")}, -- Armaments of War
        [8383] = {41, l10n("PvP")}, -- Remember Alterac Valley!
        [8384] = {41, l10n("PvP")}, -- Claiming Arathi Basin
        [8385] = {41, l10n("PvP")}, -- Concerted Efforts
        [8386] = {41, l10n("PvP")}, -- Fight for Warsong Gulch
        [8387] = {41, l10n("PvP")}, -- Invaders of Alterac Valley
        [8388] = {41, l10n("PvP")}, -- For Great Honor
        [8389] = {41, l10n("PvP")}, -- Battle of Warsong Gulch
        [8390] = {41, l10n("PvP")}, -- Conquering Arathi Basin
        [8391] = {41, l10n("PvP")}, -- Claiming Arathi Basin
        [8392] = {41, l10n("PvP")}, -- Claiming Arathi Basin
        [8393] = {41, l10n("PvP")}, -- Claiming Arathi Basin
        [8394] = {41, l10n("PvP")}, -- Claiming Arathi Basin
        [8395] = {41, l10n("PvP")}, -- Claiming Arathi Basin
        [8396] = {41, l10n("PvP")}, -- Claiming Arathi Basin
        [8397] = {41, l10n("PvP")}, -- Claiming Arathi Basin
        [8398] = {41, l10n("PvP")}, -- Claiming Arathi Basin
        [8399] = {41, l10n("PvP")}, -- Fight for Warsong Gulch
        [8400] = {41, l10n("PvP")}, -- Fight for Warsong Gulch
        [8401] = {41, l10n("PvP")}, -- Fight for Warsong Gulch
        [8402] = {41, l10n("PvP")}, -- Fight for Warsong Gulch
        [8403] = {41, l10n("PvP")}, -- Fight for Warsong Gulch
        [8404] = {41, l10n("PvP")}, -- Fight for Warsong Gulch
        [8405] = {41, l10n("PvP")}, -- Fight for Warsong Gulch
        [8406] = {41, l10n("PvP")}, -- Fight for Warsong Gulch
        [8407] = {41, l10n("PvP")}, -- Fight for Warsong Gulch
        [8408] = {41, l10n("PvP")}, -- Fight for Warsong Gulch
        [8409] = {41, l10n("PvP")}, -- Ruined Kegs
        [8413] = {81, l10n("Dungeon")}, -- Da Voodoo
        [8418] = {81, l10n("Dungeon")}, -- Forging the Mightstone
        [8422] = {81, l10n("Dungeon")}, -- Trolls of a Feather
        [8425] = {81, l10n("Dungeon")}, -- Voodoo Feathers
        [8426] = {41, l10n("PvP")}, -- Battle of Warsong Gulch
        [8427] = {41, l10n("PvP")}, -- Battle of Warsong Gulch
        [8428] = {41, l10n("PvP")}, -- Battle of Warsong Gulch
        [8429] = {41, l10n("PvP")}, -- Battle of Warsong Gulch
        [8430] = {41, l10n("PvP")}, -- Battle of Warsong Gulch
        [8431] = {41, l10n("PvP")}, -- Battle of Warsong Gulch
        [8432] = {41, l10n("PvP")}, -- Battle of Warsong Gulch
        [8433] = {41, l10n("PvP")}, -- Battle of Warsong Gulch
        [8434] = {41, l10n("PvP")}, -- Battle of Warsong Gulch
        [8435] = {41, l10n("PvP")}, -- Battle of Warsong Gulch
        [8436] = {41, l10n("PvP")}, -- Conquering Arathi Basin
        [8437] = {41, l10n("PvP")}, -- Conquering Arathi Basin
        [8438] = {41, l10n("PvP")}, -- Conquering Arathi Basin
        [8439] = {41, l10n("PvP")}, -- Conquering Arathi Basin
        [8440] = {41, l10n("PvP")}, -- Conquering Arathi Basin
        [8441] = {41, l10n("PvP")}, -- Conquering Arathi Basin
        [8442] = {41, l10n("PvP")}, -- Conquering Arathi Basin
        [8443] = {41, l10n("PvP")}, -- Conquering Arathi Basin
        [8481] = {1, l10n("Elite")}, -- The Root of All Evil
        [8498] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Twilight Battle Orders
        [8501] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Target: Hive'Ashi Stingers
        [8502] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Target: Hive'Ashi Workers
        [8507] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Field Duty
        [8534] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Hive'Zora Scout Report
        [8535] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Hoary Templar
        [8536] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Earthen Templar
        [8537] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Crimson Templar
        [8538] = {1, l10n("Elite")}, -- The Four Dukes
        [8539] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Target: Hive'Zora Hive Sisters
        [8544] = {62, l10n("Raid")}, -- Conqueror's Spaulders
        [8551] = {1, l10n("Elite")}, -- The Captain's Chest
        [8554] = {1, l10n("Elite")}, -- Facing Negolash
        [8556] = {62, l10n("Raid")}, -- Signet of Unyielding Strength
        [8557] = {62, l10n("Raid")}, -- Drape of Unyielding Strength
        [8558] = {62, l10n("Raid")}, -- Sickle of Unyielding Strength
        [8559] = {62, l10n("Raid")}, -- Conqueror's Greaves
        [8560] = {62, l10n("Raid")}, -- Conqueror's Legguards
        [8561] = {62, l10n("Raid")}, -- Conqueror's Crown
        [8562] = {62, l10n("Raid")}, -- Conqueror's Breastplate
        [8578] = {62, l10n("Raid")}, -- Scrying Goggles? No Problem!
        [8579] = {62, l10n("Raid")}, -- Mortal Champions
        [8585] = {62, l10n("Raid")}, -- The Isle of Dread!
        [8592] = {62, l10n("Raid")}, -- Tiara of the Oracle
        [8593] = {62, l10n("Raid")}, -- Trousers of the Oracle
        [8594] = {62, l10n("Raid")}, -- Mantle of the Oracle
        [8595] = {62, l10n("Raid")}, -- Mortal Champions
        [8596] = {62, l10n("Raid")}, -- Footwraps of the Oracle
        [8602] = {62, l10n("Raid")}, -- Stormcaller's Pauldrons
        [8603] = {62, l10n("Raid")}, -- Vestments of the Oracle
        [8606] = {1, l10n("Elite")}, -- Decoy!
        [8620] = {62, l10n("Raid")}, -- The Only Prescription
        [8621] = {62, l10n("Raid")}, -- Stormcaller's Footguards
        [8622] = {62, l10n("Raid")}, -- Stormcaller's Hauberk
        [8623] = {62, l10n("Raid")}, -- Stormcaller's Diadem
        [8624] = {62, l10n("Raid")}, -- Stormcaller's Leggings
        [8625] = {62, l10n("Raid")}, -- Enigma Shoulderpads
        [8626] = {62, l10n("Raid")}, -- Striker's Footguards
        [8627] = {62, l10n("Raid")}, -- Avenger's Breastplate
        [8628] = {62, l10n("Raid")}, -- Avenger's Crown
        [8629] = {62, l10n("Raid")}, -- Avenger's Legguards
        [8630] = {62, l10n("Raid")}, -- Avenger's Pauldrons
        [8631] = {62, l10n("Raid")}, -- Enigma Leggings
        [8632] = {62, l10n("Raid")}, -- Enigma Circlet
        [8633] = {62, l10n("Raid")}, -- Enigma Robes
        [8634] = {62, l10n("Raid")}, -- Enigma Boots
        [8637] = {62, l10n("Raid")}, -- Deathdealer's Boots
        [8638] = {62, l10n("Raid")}, -- Deathdealer's Vest
        [8639] = {62, l10n("Raid")}, -- Deathdealer's Helm
        [8640] = {62, l10n("Raid")}, -- Deathdealer's Leggings
        [8641] = {62, l10n("Raid")}, -- Deathdealer's Spaulders
        [8655] = {62, l10n("Raid")}, -- Avenger's Greaves
        [8656] = {62, l10n("Raid")}, -- Striker's Hauberk
        [8657] = {62, l10n("Raid")}, -- Striker's Diadem
        [8658] = {62, l10n("Raid")}, -- Striker's Leggings
        [8659] = {62, l10n("Raid")}, -- Striker's Pauldrons
        [8660] = {62, l10n("Raid")}, -- Doomcaller's Footwraps
        [8661] = {62, l10n("Raid")}, -- Doomcaller's Robes
        [8662] = {62, l10n("Raid")}, -- Doomcaller's Circlet
        [8663] = {62, l10n("Raid")}, -- Doomcaller's Trousers
        [8664] = {62, l10n("Raid")}, -- Doomcaller's Mantle
        [8665] = {62, l10n("Raid")}, -- Genesis Boots
        [8666] = {62, l10n("Raid")}, -- Genesis Vest
        [8667] = {62, l10n("Raid")}, -- Genesis Helm
        [8668] = {62, l10n("Raid")}, -- Genesis Trousers
        [8669] = {62, l10n("Raid")}, -- Genesis Shoulderpads
        [8687] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Target: Hive'Zora Tunnelers
        [8689] = {62, l10n("Raid")}, -- Shroud of Infinite Wisdom
        [8690] = {62, l10n("Raid")}, -- Cloak of the Gathering Storm
        [8691] = {62, l10n("Raid")}, -- Drape of Vaulted Secrets
        [8692] = {62, l10n("Raid")}, -- Cloak of Unending Life
        [8693] = {62, l10n("Raid")}, -- Cloak of Veiled Shadows
        [8694] = {62, l10n("Raid")}, -- Shroud of Unspoken Names
        [8695] = {62, l10n("Raid")}, -- Cape of Eternal Justice
        [8696] = {62, l10n("Raid")}, -- Cloak of the Unseen Path
        [8697] = {62, l10n("Raid")}, -- Ring of Infinite Wisdom
        [8698] = {62, l10n("Raid")}, -- Ring of the Gathering Storm
        [8699] = {62, l10n("Raid")}, -- Band of Vaulted Secrets
        [8700] = {62, l10n("Raid")}, -- Band of Unending Life
        [8701] = {62, l10n("Raid")}, -- Band of Veiled Shadows
        [8702] = {62, l10n("Raid")}, -- Ring of Unspoken Names
        [8703] = {62, l10n("Raid")}, -- Ring of Eternal Justice
        [8704] = {62, l10n("Raid")}, -- Signet of the Unseen Path
        [8705] = {62, l10n("Raid")}, -- Gavel of Infinite Wisdom
        [8706] = {62, l10n("Raid")}, -- Hammer of the Gathering Storm
        [8707] = {62, l10n("Raid")}, -- Blade of Vaulted Secrets
        [8708] = {62, l10n("Raid")}, -- Mace of Unending Life
        [8709] = {62, l10n("Raid")}, -- Dagger of Veiled Shadows
        [8710] = {62, l10n("Raid")}, -- Kris of Unspoken Names
        [8711] = {62, l10n("Raid")}, -- Blade of Eternal Justice
        [8712] = {62, l10n("Raid")}, -- Scythe of the Unseen Path
        [8729] = {62, l10n("Raid")}, -- The Wrath of Neptulon
        [8730] = {62, l10n("Raid")}, -- Nefarius's Corruption
        [8731] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Field Duty
        [8735] = {62, l10n("Raid")}, -- The Nightmare's Corruption
        [8736] = {62, l10n("Raid")}, -- The Nightmare Manifests
        [8737] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Azure Templar
        [8738] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Hive'Regal Scout Report
        [8739] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Hive'Ashi Scout Report
        [8740] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Twilight Marauders
        [8743] = {82, l10n("World Event")}, -- Bang a Gong!
        [8770] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Target: Hive'Ashi Defenders
        [8771] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Target: Hive'Ashi Sandstalkers
        [8772] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Target: Hive'Zora Waywatchers
        [8773] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Target: Hive'Zora Reavers
        [8774] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Target: Hive'Regal Ambushers
        [8775] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Target: Hive'Regal Spitfires
        [8776] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Target: Hive'Regal Slavemakers
        [8777] = Expansions.Current == Expansions.Era and {1, l10n("Elite")} or nil, -- Target: Hive'Regal Burrowers
        [8789] = {62, l10n("Raid")}, -- Imperial Qiraji Armaments
        [8790] = {62, l10n("Raid")}, -- Imperial Qiraji Regalia
        [8791] = {62, l10n("Raid")}, -- The Fall of Ossirian
        [8829] = {1, l10n("Elite")}, -- The Ultimate Deception
        [8868] = {62, l10n("Raid")}, -- Elune's Blessing
        [8905] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8906] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8907] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8908] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8909] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8910] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8911] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8912] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8913] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8914] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8915] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8916] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8917] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8918] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8919] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8920] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [8926] = {81, l10n("Dungeon")}, -- Just Compensation
        [8927] = {81, l10n("Dungeon")}, -- Just Compensation
        [8928] = {1, l10n("Elite")}, -- A Shifty Merchant
        [8931] = {81, l10n("Dungeon")}, -- Just Compensation
        [8932] = {81, l10n("Dungeon")}, -- Just Compensation
        [8933] = {81, l10n("Dungeon")}, -- Just Compensation
        [8934] = {81, l10n("Dungeon")}, -- Just Compensation
        [8935] = {81, l10n("Dungeon")}, -- Just Compensation
        [8936] = {81, l10n("Dungeon")}, -- Just Compensation
        [8937] = {81, l10n("Dungeon")}, -- Just Compensation
        [8938] = {81, l10n("Dungeon")}, -- Just Compensation
        [8939] = {81, l10n("Dungeon")}, -- Just Compensation
        [8940] = {81, l10n("Dungeon")}, -- Just Compensation
        [8941] = {81, l10n("Dungeon")}, -- Just Compensation
        [8942] = {81, l10n("Dungeon")}, -- Just Compensation
        [8943] = {81, l10n("Dungeon")}, -- Just Compensation
        [8944] = {81, l10n("Dungeon")}, -- Just Compensation
        [8945] = {81, l10n("Dungeon")}, -- Dead Man's Plea
        [8948] = {81, l10n("Dungeon")}, -- Anthion's Old Friend
        [8949] = {81, l10n("Dungeon")}, -- Falrin's Vendetta
        [8950] = {81, l10n("Dungeon")}, -- The Instigator's Enchantment
        [8951] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [8952] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [8953] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [8954] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [8955] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [8956] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [8957] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [8958] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [8959] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [8961] = {62, l10n("Raid")}, -- Three Kings of Flame
        [8962] = {1, l10n("Elite")}, -- Components of Importance
        [8963] = {1, l10n("Elite")}, -- Components of Importance
        [8964] = {1, l10n("Elite")}, -- Components of Importance
        [8965] = {1, l10n("Elite")}, -- Components of Importance
        [8966] = {81, l10n("Dungeon")}, -- The Left Piece of Lord Valthalak's Amulet
        [8967] = {81, l10n("Dungeon")}, -- The Left Piece of Lord Valthalak's Amulet
        [8968] = {81, l10n("Dungeon")}, -- The Left Piece of Lord Valthalak's Amulet
        [8969] = {81, l10n("Dungeon")}, -- The Left Piece of Lord Valthalak's Amulet
        [8970] = {1, l10n("Elite")}, -- I See Alcaz Island In Your Future...
        [8985] = {1, l10n("Elite")}, -- More Components of Importance
        [8986] = {1, l10n("Elite")}, -- More Components of Importance
        [8987] = {1, l10n("Elite")}, -- More Components of Importance
        [8988] = {1, l10n("Elite")}, -- More Components of Importance
        [8989] = {81, l10n("Dungeon")}, -- The Right Piece of Lord Valthalak's Amulet
        [8990] = {81, l10n("Dungeon")}, -- The Right Piece of Lord Valthalak's Amulet
        [8991] = {81, l10n("Dungeon")}, -- The Right Piece of Lord Valthalak's Amulet
        [8992] = {81, l10n("Dungeon")}, -- The Right Piece of Lord Valthalak's Amulet
        [8994] = {62, l10n("Raid")}, -- Final Preparations
        [8995] = {62, l10n("Raid")}, -- Mea Culpa, Lord Valthalak
        [8999] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9000] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9001] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9002] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9003] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9004] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9005] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9006] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9007] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9008] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9009] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9010] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9011] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9012] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9013] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9014] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [9015] = {81, l10n("Dungeon")}, -- The Challenge
        [9016] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [9017] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [9018] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [9019] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [9020] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [9021] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [9022] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [9023] = {62, l10n("Raid")}, -- The Perfect Poison
        [9033] = {62, l10n("Raid")}, -- Echoes of War
        [9034] = {62, l10n("Raid")}, -- Dreadnaught Breastplate
        [9036] = {62, l10n("Raid")}, -- Dreadnaught Legplates
        [9037] = {62, l10n("Raid")}, -- Dreadnaught Helmet
        [9038] = {62, l10n("Raid")}, -- Dreadnaught Pauldrons
        [9039] = {62, l10n("Raid")}, -- Dreadnaught Sabatons
        [9040] = {62, l10n("Raid")}, -- Dreadnaught Gauntlets
        [9041] = {62, l10n("Raid")}, -- Dreadnaught Waistguard
        [9042] = {62, l10n("Raid")}, -- Dreadnaught Bracers
        [9043] = {62, l10n("Raid")}, -- Redemption Tunic
        [9044] = {62, l10n("Raid")}, -- Redemption Legguards
        [9045] = {62, l10n("Raid")}, -- Redemption Headpiece
        [9046] = {62, l10n("Raid")}, -- Redemption Spaulders
        [9047] = {62, l10n("Raid")}, -- Redemption Boots
        [9048] = {62, l10n("Raid")}, -- Redemption Handguards
        [9049] = {62, l10n("Raid")}, -- Redemption Girdle
        [9050] = {62, l10n("Raid")}, -- Redemption Wristguards
        [9051] = {1, l10n("Elite")}, -- Toxic Test
        [9053] = {81, l10n("Dungeon")}, -- A Better Ingredient
        [9054] = {62, l10n("Raid")}, -- Cryptstalker Tunic
        [9055] = {62, l10n("Raid")}, -- Cryptstalker Legguards
        [9056] = {62, l10n("Raid")}, -- Cryptstalker Headpiece
        [9057] = {62, l10n("Raid")}, -- Cryptstalker Spaulders
        [9058] = {62, l10n("Raid")}, -- Cryptstalker Boots
        [9059] = {62, l10n("Raid")}, -- Cryptstalker Handguards
        [9060] = {62, l10n("Raid")}, -- Cryptstalker Girdle
        [9061] = {62, l10n("Raid")}, -- Cryptstalker Wristguards
        [9068] = {62, l10n("Raid")}, -- Earthshatter Tunic
        [9069] = {62, l10n("Raid")}, -- Earthshatter Legguards
        [9070] = {62, l10n("Raid")}, -- Earthshatter Headpiece
        [9071] = {62, l10n("Raid")}, -- Earthshatter Spaulders
        [9072] = {62, l10n("Raid")}, -- Earthshatter Boots
        [9073] = {62, l10n("Raid")}, -- Earthshatter Handguards
        [9074] = {62, l10n("Raid")}, -- Earthshatter Girdle
        [9075] = {62, l10n("Raid")}, -- Earthshatter Wristguards
        [9077] = {62, l10n("Raid")}, -- Bonescythe Breastplate
        [9078] = {62, l10n("Raid")}, -- Bonescythe Legplates
        [9079] = {62, l10n("Raid")}, -- Bonescythe Helmet
        [9080] = {62, l10n("Raid")}, -- Bonescythe Pauldrons
        [9081] = {62, l10n("Raid")}, -- Bonescythe Sabatons
        [9082] = {62, l10n("Raid")}, -- Bonescythe Gauntlets
        [9083] = {62, l10n("Raid")}, -- Bonescythe Waistguard
        [9084] = {62, l10n("Raid")}, -- Bonescythe Bracers
        [9085] = Expansions.Current >= Expansions.Tbc and {1, l10n("Elite")} or nil, -- Shadows of Doom
        [9086] = {62, l10n("Raid")}, -- Dreamwalker Tunic
        [9087] = {62, l10n("Raid")}, -- Dreamwalker Legguards
        [9088] = {62, l10n("Raid")}, -- Dreamwalker Headpiece
        [9089] = {62, l10n("Raid")}, -- Dreamwalker Spaulders
        [9090] = {62, l10n("Raid")}, -- Dreamwalker Boots
        [9091] = {62, l10n("Raid")}, -- Dreamwalker Handguards
        [9092] = {62, l10n("Raid")}, -- Dreamwalker Girdle
        [9093] = {62, l10n("Raid")}, -- Dreamwalker Wristguards
        [9095] = {62, l10n("Raid")}, -- Frostfire Robe
        [9096] = {62, l10n("Raid")}, -- Frostfire Leggings
        [9097] = {62, l10n("Raid")}, -- Frostfire Circlet
        [9098] = {62, l10n("Raid")}, -- Frostfire Shoulderpads
        [9099] = {62, l10n("Raid")}, -- Frostfire Sandals
        [9100] = {62, l10n("Raid")}, -- Frostfire Gloves
        [9101] = {62, l10n("Raid")}, -- Frostfire Belt
        [9102] = {62, l10n("Raid")}, -- Frostfire Bindings
        [9103] = {62, l10n("Raid")}, -- Plagueheart Robe
        [9104] = {62, l10n("Raid")}, -- Plagueheart Leggings
        [9105] = {62, l10n("Raid")}, -- Plagueheart Circlet
        [9106] = {62, l10n("Raid")}, -- Plagueheart Shoulderpads
        [9107] = {62, l10n("Raid")}, -- Plagueheart Sandals
        [9108] = {62, l10n("Raid")}, -- Plagueheart Gloves
        [9109] = {62, l10n("Raid")}, -- Plagueheart Belt
        [9110] = {62, l10n("Raid")}, -- Plagueheart Bindings
        [9111] = {62, l10n("Raid")}, -- Robe of Faith
        [9112] = {62, l10n("Raid")}, -- Leggings of Faith
        [9113] = {62, l10n("Raid")}, -- Circlet of Faith
        [9114] = {62, l10n("Raid")}, -- Shoulderpads of Faith
        [9115] = {62, l10n("Raid")}, -- Sandals of Faith
        [9116] = {62, l10n("Raid")}, -- Gloves of Faith
        [9117] = {62, l10n("Raid")}, -- Belt of Faith
        [9118] = {62, l10n("Raid")}, -- Bindings of Faith
        [9156] = {1, l10n("Elite")}, -- Wanted: Knucklerot and Luzran
        [9167] = {1, l10n("Elite")}, -- The Traitor's Destruction
        [9208] = {62, l10n("Raid")}, -- The Savage Guard - Arcanum of Protection
        [9209] = {62, l10n("Raid")}, -- The Savage Guard - Arcanum of Rapidity
        [9210] = {62, l10n("Raid")}, -- The Savage Guard - Arcanum of Focus
        [9215] = {1, l10n("Elite")}, -- Bring Me Kel'gash's Head!
        [9315] = {1, l10n("Elite")}, -- Anok'suten
        [9229] = {62, l10n("Raid")}, -- The Fate of Ramaladni
        [9230] = {62, l10n("Raid")}, -- Ramaladni's Icy Grasp
        [9232] = {62, l10n("Raid")}, -- The Only Song I Know...
        [9233] = {62, l10n("Raid")}, -- Omarion's Handbook
        [9234] = {62, l10n("Raid")}, -- Icebane Gauntlets
        [9235] = {62, l10n("Raid")}, -- Icebane Bracers
        [9236] = {62, l10n("Raid")}, -- Icebane Breastplate
        [9237] = {62, l10n("Raid")}, -- Glacial Cloak
        [9238] = {62, l10n("Raid")}, -- Glacial Wrists
        [9239] = {62, l10n("Raid")}, -- Glacial Gloves
        [9240] = {62, l10n("Raid")}, -- Glacial Vest
        [9241] = {62, l10n("Raid")}, -- Polar Bracers
        [9242] = {62, l10n("Raid")}, -- Polar Gloves
        [9243] = {62, l10n("Raid")}, -- Polar Tunic
        [9244] = {62, l10n("Raid")}, -- Icy Scale Bracers
        [9245] = {62, l10n("Raid")}, -- Icy Scale Gauntlets
        [9246] = {62, l10n("Raid")}, -- Icy Scale Breastplate
        [9250] = {62, l10n("Raid")}, -- Frame of Atiesh
        [9251] = {62, l10n("Raid")}, -- Atiesh, the Befouled Greatstaff
        [9257] = {81, l10n("Dungeon")}, -- Atiesh, Greatstaff of the Guardian
        [9269] = {81, l10n("Dungeon")}, -- Atiesh, Greatstaff of the Guardian
        [9270] = {81, l10n("Dungeon")}, -- Atiesh, Greatstaff of the Guardian
        [9271] = {81, l10n("Dungeon")}, -- Atiesh, Greatstaff of the Guardian
        [9375] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or {84, l10n("Escort")}, -- The Road to Falcon Watch
        [9419] = {41, l10n("PvP")}, -- Scouring the Desert
        [9422] = {41, l10n("PvP")}, -- Scouring the Desert
        [9444] = {41, l10n("PvP")}, -- Defiling Uther's Tomb
        [9446] = {1, l10n("Elite")}, -- Tomb of the Lightbringer
        [9466] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Wanted: Blacktalon the Savage
        [9490] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- The Rock Flayer Matriarch
        [9492] = {81, l10n("Dungeon")}, -- Turning the Tide
        [9493] = {81, l10n("Dungeon")}, -- Pride of the Fel Horde
        [9494] = {81, l10n("Dungeon")}, -- Fel Embers
        [9495] = {81, l10n("Dungeon")}, -- The Will of the Warchief
        [9496] = {81, l10n("Dungeon")}, -- Pride of the Fel Horde
        [9521] = {41, l10n("PvP")}, -- Report from the Northern Front
        [9524] = {85, l10n("Heroic")}, -- Imprisoned in the Citadel
        [9525] = {85, l10n("Heroic")}, -- Imprisoned in the Citadel
        [9528] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- A Cry For Help
        [9664] = {41, l10n("PvP")}, -- Establishing New Outposts
        [9665] = {41, l10n("PvP")}, -- Bolstering Our Defenses
        [9572] = {81, l10n("Dungeon")}, -- Weaken the Ramparts
        [9575] = {81, l10n("Dungeon")}, -- Weaken the Ramparts
        [9587] = {81, l10n("Dungeon")}, -- Dark Tidings
        [9588] = {81, l10n("Dungeon")}, -- Dark Tidings
        [9589] = {81, l10n("Dungeon")}, -- The Blood is Life
        [9590] = {81, l10n("Dungeon")}, -- The Blood is Life
        [9607] = {81, l10n("Dungeon")}, -- Heart of Rage
        [9608] = {81, l10n("Dungeon")}, -- Heart of Rage
        [9630] = {62, l10n("Raid")}, -- Medivh's Journal
        [9637] = {85, l10n("Heroic")}, -- Kalynna's Request
        [9640] = {62, l10n("Raid")}, -- The Shade of Aran
        [9644] = {62, l10n("Raid")}, -- Nightbane
        [9645] = {62, l10n("Raid")}, -- The Master's Terrace
        [9689] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Razormaw
        [9692] = {81, l10n("Dungeon")}, -- The Path of the Adept
        [9706] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Galaen's Journal - The Fate of Vindicator Saruan
        [9711] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Matis the Cruel
        [9714] = {81, l10n("Dungeon")}, -- Bring Me Another Shrubbery!
        [9715] = {81, l10n("Dungeon")}, -- Bring Me A Shrubbery!
        [9717] = {81, l10n("Dungeon")}, -- Oh, It's On!
        [9719] = {81, l10n("Dungeon")}, -- Stalk the Stalker
        [9723] = {81, l10n("Dungeon")}, -- A Gesture of Commitment
        [9729] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Fhwoor Smash!
        [9730] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Leader of the Darkcrest
        [9735] = {1, l10n("Elite")}, -- True Masters of the Light
        [9737] = {81, l10n("Dungeon")}, -- True Masters of the Light
        [9738] = {81, l10n("Dungeon")}, -- Lost in Action
        [9753] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- What We Know...
        [9756] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- What We Don't Know...
        [9759] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Ending Their World
        [9760] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Vindicator's Rest
        [9761] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Clearing the Way
        [9763] = {81, l10n("Dungeon")}, -- The Warlord's Hideout
        [9765] = {81, l10n("Dungeon")}, -- Preparing for War
        [9817] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Leader of the Bloodscale
        [9831] = {81, l10n("Dungeon")}, -- Entry Into Karazhan
        [9832] = {81, l10n("Dungeon")}, -- The Second and Third Fragments
        [9836] = {81, l10n("Dungeon")}, -- The Master's Touch
        [9840] = {62, l10n("Raid")}, -- Assessing the Situation
        [9843] = {62, l10n("Raid")}, -- Keanna's Log
        [9844] = {62, l10n("Raid")}, -- A Demonic Presence
        [9851] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Clefthoof Mastery
        [9852] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- The Ultimate Bloodsport
        [9853] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Gurok the Usurper
        [9856] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Windroc Mastery
        [9859] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Talbuk Mastery
        [9868] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- The Totem of Kar'dash
        [9879] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- The Totem of Kar'dash
        [9894] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Safeguarding the Watchers
        [9895] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- The Dying Balance
        [9937] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Wanted: Durn the Hungerer
        [9938] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Wanted: Durn the Hungerer
        [9946] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Cho'war the Pillager
        [9954] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Corki's Ransom
        [9955] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Cho'war the Pillager
        [9962] = {1, l10n("Elite")}, -- The Ring of Blood: Brokentoe
        [9967] = {1, l10n("Elite")}, -- The Ring of Blood: The Blue Brothers
        [9970] = {1, l10n("Elite")}, -- The Ring of Blood: Rokdar the Sundered Lord
        [9972] = {1, l10n("Elite")}, -- The Ring of Blood: Skra'gath
        [9973] = {1, l10n("Elite")}, -- The Ring of Blood: The Warmaul Champion
        [9977] = {1, l10n("Elite")}, -- The Ring of Blood: The Final Challenge
        [9982] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- He Called Himself Altruis...
        [9983] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- He Called Himself Altruis...
        [9991] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Survey the Land
        [9999] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Buying Time
        [10001] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- The Master Planner
        [10004] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Patience and Understanding
        [10009] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Crackin' Some Skulls
        [10010] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- It's Just That Easy?
        [10011] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Forge Camp: Annihilated
        [10020] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- A Cure for Zahlia
        [10035] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Torgos!
        [10036] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Torgos!
        [10051] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Escape from Firewing Point!
        [10052] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Escape from Firewing Point!
        [10074] = {41, l10n("PvP")}, -- Oshu'gun Crystal Powder
        [10075] = {41, l10n("PvP")}, -- Oshu'gun Crystal Powder
        [10076] = {41, l10n("PvP")}, -- Oshu'gun Crystal Powder
        [10077] = {41, l10n("PvP")}, -- Oshu'gun Crystal Powder
        [10091] = {81, l10n("Dungeon")}, -- The Soul Devices
        [10094] = {81, l10n("Dungeon")}, -- The Codex of Blood
        [10095] = {81, l10n("Dungeon")}, -- Into the Heart of the Labyrinth
        [10097] = {81, l10n("Dungeon")}, -- Brother Against Brother
        [10098] = {81, l10n("Dungeon")}, -- Terokk's Legacy
        [10106] = {41, l10n("PvP")}, -- Hellfire Fortifications
        [10110] = {41, l10n("PvP")}, -- Hellfire Fortifications
        [10111] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Bring Me The Egg!
        [10116] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Wanted: Chieftain Mummaki
        [10117] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Wanted: Chieftain Mummaki
        [10132] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Colossal Menace
        [10134] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Crimson Crystal Clue
        [10136] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Cruel's Intentions
        [10164] = {81, l10n("Dungeon")}, -- Everything Will Be Alright
        [10165] = {81, l10n("Dungeon")}, -- Undercutting the Competition
        [10167] = {81, l10n("Dungeon")}, -- Auchindoun...
        [10168] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- What the Soul Sees
        [10177] = {81, l10n("Dungeon")}, -- Trouble at Auchindoun
        [10178] = {81, l10n("Dungeon")}, -- Find Spy To'gun
        [10191] = {1, l10n("Elite")}, -- Mark V is Alive!
        [10216] = {81, l10n("Dungeon")}, -- Safety Is Job One
        [10218] = {81, l10n("Dungeon")}, -- Someone Else's Hard Work Pays Off
        [10231] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- What Book? I Don't See Any Book.
        [10247] = {1, l10n("Elite")}, -- Doctor Vomisa, Ph.T.
        [10248] = {1, l10n("Elite")}, -- You, Robot
        [10252] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Vision of the Dead
        [10253] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Levixus the Soul Caller
        [10256] = {1, l10n("Elite")}, -- Finding the Keymaster
        [10257] = {81, l10n("Dungeon")}, -- Capturing the Keystone
        [10261] = {1, l10n("Elite")}, -- Wanted: Annihilator Servo!
        [10274] = {1, l10n("Elite")}, -- Securing the Celestial Ridge
        [10276] = {1, l10n("Elite")}, -- Full Triangle
        [10282] = {81, l10n("Dungeon")}, -- Old Hillsbrad
        [10283] = {81, l10n("Dungeon")}, -- Taretha's Diversion
        [10284] = {81, l10n("Dungeon")}, -- Escape from Durnholde
        [10290] = {1, l10n("Elite")}, -- In Search of Farahlite
        [10293] = {1, l10n("Elite")}, -- Hitting the Motherlode
        [10296] = {81, l10n("Dungeon")}, -- The Black Morass
        [10297] = {81, l10n("Dungeon")}, -- The Opening of the Dark Portal
        [10309] = {1, l10n("Elite")}, -- It's a Fel Reaver, But with Heart
        [10310] = {1, l10n("Elite")}, -- Sabotage the Warp-Gate!
        [10320] = {1, l10n("Elite")}, -- Destroy Naberius!
        [10323] = {1, l10n("Elite")}, -- Shutting Down Manaforge Ara
        [10337] = {1, l10n("Elite")}, -- When the Cows Come Home
        [10349] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- The Earthbinder
        [10351] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Natural Remedies
        [10365] = {1, l10n("Elite")}, -- Shutting Down Manaforge Ara
        [10400] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Overlord
        [10407] = {1, l10n("Elite")}, -- Socrethar's Shadow
        [10408] = {1, l10n("Elite")}, -- Nexus-King Salhadaar
        [10409] = {1, l10n("Elite")}, -- Deathblow to the Legion
        [10439] = {1, l10n("Elite")}, -- Dimensius the All-Devouring
        [10445] = {62, l10n("Raid")}, -- The Vials of Eternity
        [10451] = {1, l10n("Elite")}, -- Escape from Coilskar Cistern
        [10492] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [10493] = {81, l10n("Dungeon")}, -- An Earnest Proposition
        [10494] = {81, l10n("Dungeon")}, -- Just Compensation
        [10495] = {81, l10n("Dungeon")}, -- Just Compensation
        [10496] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [10497] = {81, l10n("Dungeon")}, -- Anthion's Parting Words
        [10498] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [10499] = {81, l10n("Dungeon")}, -- Saving the Best for Last
        [10507] = {1, l10n("Elite")}, -- Turning Point
        [10508] = {1, l10n("Elite")}, -- A Gift for Voren'thal
        [10518] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Planting the Banner
        [10578] = {1, l10n("Elite")}, -- The Cipher of Damnation - Borak's Charge
        [10588] = {1, l10n("Elite")}, -- The Cipher of Damnation
        [10593] = {81, l10n("Dungeon")}, -- Ancient Evil
        [10626] = {1, l10n("Elite")}, -- Capture the Weapons
        [10627] = {1, l10n("Elite")}, -- Capture the Weapons
        [10634] = {1, l10n("Elite")}, -- Divination: Gorefiend's Armor
        [10636] = {1, l10n("Elite")}, -- Divination: Gorefiend's Truncheon
        [10647] = {1, l10n("Elite")}, -- Wanted: Uvuros, Scourge of Shadowmoon
        [10648] = {1, l10n("Elite")}, -- Wanted: Uvuros, Scourge of Shadowmoon
        [10649] = {81, l10n("Dungeon")}, -- The Book of Fel Names
        [10651] = {1, l10n("Elite")}, -- Varedis Must Be Stopped
        [10665] = {81, l10n("Dungeon")}, -- Fresh from the Mechanar
        [10666] = {81, l10n("Dungeon")}, -- The Lexicon Demonica
        [10667] = {81, l10n("Dungeon")}, -- Underworld Loam
        [10670] = {81, l10n("Dungeon")}, -- Tear of the Earthmother
        [10692] = {1, l10n("Elite")}, -- Varedis Must Be Stopped
        [10701] = {1, l10n("Elite")}, -- Breaking Down Netherock
        [10704] = {81, l10n("Dungeon")}, -- How to Break Into the Arcatraz
        [10705] = {81, l10n("Dungeon")}, -- Seer Udalo
        [10707] = {1, l10n("Elite")}, -- The Ata'mal Terrace
        [10724] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Prisoner of the Bladespire
        [10742] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Showdown
        [10750] = {1, l10n("Elite")}, -- The Path of Conquest
        [10751] = {1, l10n("Elite")}, -- Breaching the Path
        [10758] = {1, l10n("Elite")}, -- Hotter than Hell
        [10764] = {1, l10n("Elite")}, -- Hotter than Hell
        [10765] = {1, l10n("Elite")}, -- When Worlds Collide...
        [10768] = {1, l10n("Elite")}, -- Tabards of the Illidari
        [10769] = {1, l10n("Elite")}, -- Dissension Amongst the Ranks...
        [10772] = {1, l10n("Elite")}, -- The Path of Conquest
        [10773] = {1, l10n("Elite")}, -- Breaching the Path
        [10774] = {1, l10n("Elite")}, -- Blood Elf + Giant = ???
        [10775] = {1, l10n("Elite")}, -- Tabards of the Illidari
        [10776] = {1, l10n("Elite")}, -- Dissension Amongst the Ranks...
        [10781] = {1, l10n("Elite")}, -- Battle of the Crimson Watch
        [10793] = {1, l10n("Elite")}, -- The Journal of Val'zareq: Portends of War
        [10805] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Massacre at Gruul's Lair
        [10806] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Showdown
        [10821] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- You're Fired!
        [10834] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Grillok "Darkeye"
        [10838] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- The Demoniac Scryer
        [10842] = Expansions.Current == Expansions.Tbc and {1, l10n("Elite")} or nil, -- The Vengeful Harbinger/Vengeful Souls
        [10858] = {1, l10n("Elite")}, -- Karynaku
        [10866] = {1, l10n("Elite")}, -- Zuluhed the Whacked
        [10872] = {1, l10n("Elite")}, -- Zuluhed the Whacked
        [10876] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- The Foot of the Citadel
        [10879] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- The Skettis Offensive
        [10882] = {81, l10n("Dungeon")}, -- Harbinger of Doom
        [10884] = {85, l10n("Heroic")}, -- Trial of the Naaru: Mercy
        [10885] = {85, l10n("Heroic")}, -- Trial of the Naaru: Strength
        [10886] = {85, l10n("Heroic")}, -- Trial of the Naaru: Tenacity
        [10888] = {62, l10n("Raid")}, -- Trial of the Naaru: Magtheridon
        [10897] = {81, l10n("Dungeon")}, -- Master of Potions
        [10898] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Skywing
        [10900] = {62, l10n("Raid")}, -- The Mark of Vashj
        [10901] = {62, l10n("Raid")}, -- The Cudgel of Kar'desh
        [10902] = {81, l10n("Dungeon")}, -- Master of Elixirs
        [10921] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Terokkarantula
        [10922] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Digging Through Bones
        [10923] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Evil Draws Near
        [10929] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Fumping
        [10930] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- The Big Bone Worm
        [10937] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Drill the Drillmaster
        [10946] = {62, l10n("Raid")}, -- Ruse of the Ashtongue
        [10947] = {62, l10n("Raid")}, -- An Artifact From the Past
        [10957] = {62, l10n("Raid")}, -- Redemption of the Ashtongue
        [10958] = {62, l10n("Raid")}, -- Seek Out the Ashtongue
        [10959] = {62, l10n("Raid")}, -- The Fall of the Betrayer
        [10974] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Stasis Chambers of Bash'ir
        [10975] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Purging the Chambers of Bash'ir
        [10976] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- The Mark of the Nexus-King
        [10977] = {85, l10n("Heroic")}, -- Stasis Chambers of the Mana-Tombs
        [10981] = {85, l10n("Heroic")}, -- Nexus-Prince Shaffar's Personal Chamber
        [10995] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Grulloc Has Two Skulls
        [10996] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Maggoc's Treasure Chest
        [10997] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Even Gronn Have Standards
        [10998] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Grim(oire) Business
        [11000] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Into the Soulgrinder
        [11001] = {85, l10n("Heroic")}, -- Vanquish the Raven God
        [11041] = {1, l10n("Elite")}, -- A Job Unfinished...
        [11059] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- Guardian of the Monument
        [11073] = {1, l10n("Elite")}, -- Terokk's Downfall
        [11078] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- To Rule The Skies
        [11079] = Expansions.Current <= Expansions.Wotlk and {1, l10n("Elite")} or nil, -- A Fel Whip For Gahk
        [11097] = {1, l10n("Elite")}, -- The Deadliest Trap Ever Laid
        [11101] = {1, l10n("Elite")}, -- The Deadliest Trap Ever Laid
        [11130] = {62, l10n("Raid")}, -- Oooh, Shinies!
        [11132] = {62, l10n("Raid")}, -- Promises, Promises...
        [11164] = {62, l10n("Raid")}, -- Tuskin' Raiders
        [11165] = {62, l10n("Raid")}, -- A Troll Among Trolls
        [11166] = {62, l10n("Raid")}, -- X Marks... Your Doom!
        [11171] = {62, l10n("Raid")}, -- Hex Lord? Hah!
        [11178] = {62, l10n("Raid")}, -- Blood of the Warlord
        [11195] = {62, l10n("Raid")}, -- Playin' With Dolls
        [11196] = Expansions.Current <= Expansions.Wotlk and {62, l10n("Raid")} or {81, l10n("Dungeon")}, -- Warlord of the Amani
        [11335] = {41, l10n("PvP")}, -- Call to Arms: Arathi Basin
        [11336] = {41, l10n("PvP")}, -- Call to Arms: Alterac Valley
        [11337] = {41, l10n("PvP")}, -- Call to Arms: Eye of the Storm
        [11338] = {41, l10n("PvP")}, -- Call to Arms: Warsong Gulch
        [11339] = {41, l10n("PvP")}, -- Call to Arms: Arathi Basin
        [11340] = {41, l10n("PvP")}, -- Call to Arms: Alterac Valley
        [11341] = {41, l10n("PvP")}, -- Call to Arms: Eye of the Storm
        [11342] = {41, l10n("PvP")}, -- Call to Arms: Warsong Gulch
        [11354] = {85, l10n("Heroic")}, -- Wanted: Nazan's Riding Crop
        [11362] = {85, l10n("Heroic")}, -- Wanted: Keli'dan's Feathered Stave
        [11363] = {85, l10n("Heroic")}, -- Wanted: Bladefist's Seal
        [11364] = {81, l10n("Dungeon")}, -- Wanted: Wanted: Shattered Hand Centurions
        [11368] = {85, l10n("Heroic")}, -- Wanted: The Heart of Quagmirran
        [11369] = {85, l10n("Heroic")}, -- Wanted: A Black Stalker Egg
        [11370] = {85, l10n("Heroic")}, -- Wanted: The Warlord's Treatise
        [11371] = {81, l10n("Dungeon")}, -- Wanted: Coilfang Myrmidons
        [11372] = {85, l10n("Heroic")}, -- Wanted: The Headfeathers of Ikiss
        [11373] = {85, l10n("Heroic")}, -- Wanted: Shaffar's Wondrous Pendant
        [11374] = {85, l10n("Heroic")}, -- Wanted: The Exarch's Soul Gem
        [11375] = {85, l10n("Heroic")}, -- Wanted: Murmur's Whisper
        [11376] = {81, l10n("Dungeon")}, -- Wanted: Malicious Instructors
        [11378] = {85, l10n("Heroic")}, -- Wanted: The Epoch Hunter's Head
        [11382] = {85, l10n("Heroic")}, -- Wanted: Aeonus's Hourglass
        [11383] = {81, l10n("Dungeon")}, -- Wanted: Rift Lords
        [11384] = {85, l10n("Heroic")}, -- Wanted: A Warp Splinter Clipping
        [11385] = {81, l10n("Dungeon")}, -- Wanted: Sunseeker Channelers
        [11386] = {85, l10n("Heroic")}, -- Wanted: Pathaleon's Projector
        [11387] = {81, l10n("Dungeon")}, -- Wanted: Tempest-Forge Destroyers
        [11388] = {85, l10n("Heroic")}, -- Wanted: The Scroll of Skyriss
        [11389] = {81, l10n("Dungeon")}, -- Wanted: Arcatraz Sentinels
        [11401] = {81, l10n("Dungeon")}, -- Call the Headless Horseman
        [11405] = {81, l10n("Dungeon")}, -- Call the Headless Horseman
        [11488] = {81, l10n("Dungeon")}, -- Magisters' Terrace
        [11490] = {81, l10n("Dungeon")}, -- The Scryer's Scryer
        [11492] = {81, l10n("Dungeon")}, -- Hard to Kill
        [11499] = {85, l10n("Heroic")}, -- Wanted: The Signet Ring of Prince Kael'thas
        [11500] = {81, l10n("Dungeon")}, -- Wanted: Sisters of Torment
        [11502] = {41, l10n("PvP")}, -- In Defense of Halaa
        [11503] = {41, l10n("PvP")}, -- Enemies, Old and New
        [11505] = {41, l10n("PvP")}, -- Spirits of Auchindoun
        [11506] = {41, l10n("PvP")}, -- Spirits of Auchindoun
        [11691] = {81, l10n("Dungeon")}, -- Summon Ahune
        [11885] = {1, l10n("Elite")}, -- Adversarial Blood
        [11955] = {81, l10n("Dungeon")}, -- Ahune, the Frost Lord
        [12062] = {81, l10n("Dungeon")}, -- Insult Coren Direbrew
        [12170] = {41, l10n("PvP")}, -- 
        [12244] = {41, l10n("PvP")}, -- 
        [12268] = {41, l10n("PvP")}, -- 
        [12270] = {41, l10n("PvP")}, -- 
        [12280] = {41, l10n("PvP")}, -- 
        [12284] = {41, l10n("PvP")}, -- 
        [12288] = {41, l10n("PvP")}, -- 
        [12289] = {41, l10n("PvP")}, -- 
        [12296] = {41, l10n("PvP")}, -- 
        [12314] = {41, l10n("PvP")}, -- 
        [12315] = {41, l10n("PvP")}, -- 
        [12316] = {41, l10n("PvP")}, -- 
        [12317] = {41, l10n("PvP")}, -- 
        [12323] = {41, l10n("PvP")}, -- 
        [12324] = {41, l10n("PvP")}, -- 
        [12432] = {41, l10n("PvP")}, -- 
        [12433] = {41, l10n("PvP")}, -- 
        [12434] = {41, l10n("PvP")}, -- 
        [12437] = {41, l10n("PvP")}, -- 
        [12443] = {41, l10n("PvP")}, -- 
        [12446] = {41, l10n("PvP")}, -- 
        [12513] = {81, l10n("Dungeon")}, -- Nice Hat...
        [12515] = {81, l10n("Dungeon")}, -- Nice Hat...
        [13129] = {81, l10n("Dungeon")}, -- Head Games
        [13199] = {41, l10n("PvP")}, -- 
        [13662] = {81, l10n("Dungeon")}, -- Gaining Acceptance
        [26452] = {41, l10n("PvP")}, -- 
        [26856] = {81, l10n("Dungeon")}, -- 
        [26858] = {81, l10n("Dungeon")}, -- 
        [26862] = {81, l10n("Dungeon")}, -- 
        [26866] = {81, l10n("Dungeon")}, -- 
        [26962] = {81, l10n("Dungeon")}, -- 
        [26967] = {81, l10n("Dungeon")}, -- 
        [27848] = {81, l10n("Dungeon")}, -- 
        [27850] = {81, l10n("Dungeon")}, -- 
        [28735] = {81, l10n("Dungeon")}, -- 
        [28737] = {81, l10n("Dungeon")}, -- 
        [28738] = {81, l10n("Dungeon")}, -- 
        [28740] = {81, l10n("Dungeon")}, -- 
        [28760] = {81, l10n("Dungeon")}, -- 
        [28814] = {81, l10n("Dungeon")}, -- 
        [28845] = {81, l10n("Dungeon")}, -- 
        [29135] = {62, l10n("Raid")}, -- 
        [29153] = {81, l10n("Dungeon")}, -- 
        [29154] = {81, l10n("Dungeon")}, -- 
        [29172] = {81, l10n("Dungeon")}, -- 
        [29173] = {81, l10n("Dungeon")}, -- 
        [29175] = {81, l10n("Dungeon")}, -- 
        [29208] = {81, l10n("Dungeon")}, -- 
        [29241] = {81, l10n("Dungeon")}, -- 
        [29242] = {81, l10n("Dungeon")}, -- 
        [29251] = {81, l10n("Dungeon")}, -- 
        [29252] = {81, l10n("Dungeon")}, -- 
        [29760] = {41, l10n("PvP")}, -- 
        [29761] = {41, l10n("PvP")}, -- 
        [64845] = {41, l10n("PvP")}, -- 
        [78680] = {1, l10n("Elite")}, -- 
        [78681] = {1, l10n("Elite")}, -- 
        [78684] = {1, l10n("Elite")}, -- 
        [80098] = {1, l10n("Elite")}, -- 
        [80147] = {1, l10n("Elite")}, -- 
        [80148] = {1, l10n("Elite")}, -- 
        [80149] = {1, l10n("Elite")}, -- 
        [80150] = {1, l10n("Elite")}, -- 
        [80151] = {1, l10n("Elite")}, -- 
        [80152] = {1, l10n("Elite")}, -- 
        [90014] = {1, l10n("Elite")}, -- 
        [90054] = {1, l10n("Elite")}, -- 
        [90070] = {1, l10n("Elite")}, -- 
        [90081] = {1, l10n("Elite")}, -- 
        [90091] = {1, l10n("Elite")}, -- 
        [90094] = {1, l10n("Elite")}, -- 
        [90113] = {1, l10n("Elite")}, -- 
        [90114] = {1, l10n("Elite")}, -- 
        [90119] = {1, l10n("Elite")}, -- 
        [90122] = {1, l10n("Elite")}, -- 
        [90151] = {1, l10n("Elite")}, -- 
        [90152] = {1, l10n("Elite")}, -- 
        [90159] = {1, l10n("Elite")}, -- 
        [90163] = {1, l10n("Elite")}, -- 
        [90166] = {1, l10n("Elite")}, -- 
        [90169] = {1, l10n("Elite")}, -- 
        [90175] = {1, l10n("Elite")}, -- 
        [90190] = {1, l10n("Elite")}, -- 
        [90202] = {1, l10n("Elite")}, -- 
        [90204] = {1, l10n("Elite")}, -- 
        [90221] = {1, l10n("Elite")}, -- 
        [90225] = {1, l10n("Elite")}, -- 
        [90230] = {1, l10n("Elite")}, -- 
        [90269] = {1, l10n("Elite")}, -- 
        [90271] = {1, l10n("Elite")}, -- 
        [90281] = {1, l10n("Elite")}, -- 
        [90282] = {1, l10n("Elite")}, -- 
        [90287] = {1, l10n("Elite")}, -- 
        [90288] = {1, l10n("Elite")}, -- 
        [90289] = {1, l10n("Elite")}, -- 
        [90308] = {1, l10n("Elite")}, -- 
        [90312] = {1, l10n("Elite")}, -- 
        [90334] = {1, l10n("Elite")}, -- 
        [90335] = {1, l10n("Elite")}, -- 
        [90339] = {1, l10n("Elite")}, -- 
        [90343] = {1, l10n("Elite")}, -- 
        [90344] = {1, l10n("Elite")}, -- 
        [90353] = {1, l10n("Elite")}, -- 

        -- MoP quests
        [30567] = {98, l10n("Scenario")}, -- 
        [31058] = {98, l10n("Scenario")}, -- 
        [31454] = {83, l10n("Legendary")}, -- 
        [31468] = {83, l10n("Legendary")}, -- 
        [31473] = {83, l10n("Legendary")}, -- 
        [31488] = {83, l10n("Legendary")}, -- 
        [31489] = {83, l10n("Legendary")}, -- 
        [31519] = {85, l10n("Heroic")}, -- 
        [31520] = {85, l10n("Heroic")}, -- 
        [31522] = {85, l10n("Heroic")}, -- 
        [31523] = {85, l10n("Heroic")}, -- 
        [31524] = {85, l10n("Heroic")}, -- 
        [31525] = {85, l10n("Heroic")}, -- 
        [31526] = {85, l10n("Heroic")}, -- 
        [31527] = {85, l10n("Heroic")}, -- 
        [31528] = {85, l10n("Heroic")}, -- 
        [31611] = {98, l10n("Scenario")}, -- 
        [31613] = {98, l10n("Scenario")}, -- 
        [31917] = {102, l10n("Account")}, -- 
        [31918] = {102, l10n("Account")}, -- 
        [31975] = {102, l10n("Account")}, -- 
        [31976] = {102, l10n("Account")}, -- 
        [31977] = {102, l10n("Account")}, -- 
        [31980] = {102, l10n("Account")}, -- 
        [31981] = {102, l10n("Account")}, -- 
        [31982] = {102, l10n("Account")}, -- 
        [31983] = {102, l10n("Account")}, -- 
        [31984] = {102, l10n("Account")}, -- 
        [31985] = {102, l10n("Account")}, -- 
        [31986] = {102, l10n("Account")}, -- 
        [31998] = {85, l10n("Heroic")}, -- 
        [32000] = {85, l10n("Heroic")}, -- 
        [32001] = {85, l10n("Heroic")}, -- 
        [32002] = {85, l10n("Heroic")}, -- 
        [32003] = {85, l10n("Heroic")}, -- 
        [32004] = {85, l10n("Heroic")}, -- 
        [32005] = {85, l10n("Heroic")}, -- 
        [32006] = {85, l10n("Heroic")}, -- 
        [32007] = {85, l10n("Heroic")}, -- 
        [91701] = {294, l10n("Celestial")}, -- 
        [91702] = {294, l10n("Celestial")}, -- 
        [91703] = {294, l10n("Celestial")}, -- 
        [91704] = {294, l10n("Celestial")}, -- 
        [91705] = {294, l10n("Celestial")}, -- 
        [91706] = {294, l10n("Celestial")}, -- 
        [91707] = {294, l10n("Celestial")}, -- 
        [91708] = {294, l10n("Celestial")}, -- 
        [91709] = {294, l10n("Celestial")}, -- 
        [91710] = {294, l10n("Celestial")}, -- 
        [91711] = {294, l10n("Celestial")}, -- 
        [91712] = {294, l10n("Celestial")}, -- 
        [91713] = {294, l10n("Celestial")}, -- 
        [91714] = {294, l10n("Celestial")}, -- 
        [91715] = {294, l10n("Celestial")}, -- 
        [91716] = {294, l10n("Celestial")}, -- 
        [91717] = {294, l10n("Celestial")}, -- 
        [91718] = {294, l10n("Celestial")}, -- 
        [91786] = {294, l10n("Celestial")}, -- 

        -- TBC Anniversary quests
        [95455] = {41, l10n("PvP")}, -- 
        [95457] = {41, l10n("PvP")}, -- 
    }
end
