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
        [7081] = {41, l10n("PvP")},
        [7082] = {41, l10n("PvP")},
        [7101] = {41, l10n("PvP")},
        [7102] = {41, l10n("PvP")},
        [7121] = {41, l10n("PvP")},
        [7122] = {41, l10n("PvP")},
        [7123] = {41, l10n("PvP")},
        [7124] = {41, l10n("PvP")},
        [7141] = {41, l10n("PvP")},
        [7142] = {41, l10n("PvP")},
        [7161] = {41, l10n("PvP")},
        [7162] = {41, l10n("PvP")},
        [7163] = {41, l10n("PvP")},
        [7164] = {41, l10n("PvP")},
        [7165] = {41, l10n("PvP")},
        [7166] = {41, l10n("PvP")},
        [7167] = {41, l10n("PvP")},
        [7168] = {41, l10n("PvP")},
        [7169] = {41, l10n("PvP")},
        [7170] = {41, l10n("PvP")},
        [7171] = {41, l10n("PvP")},
        [7172] = {41, l10n("PvP")},
        [7181] = {41, l10n("PvP")},
        [7202] = {41, l10n("PvP")},
        [7221] = {41, l10n("PvP")},
        [7222] = {41, l10n("PvP")},
        [7223] = {41, l10n("PvP")},
        [7224] = {41, l10n("PvP")},
        [7241] = {41, l10n("PvP")},
        [7261] = {41, l10n("PvP")},
        [7281] = {41, l10n("PvP")},
        [7282] = {41, l10n("PvP")},
        [7301] = {41, l10n("PvP")},
        [7302] = {41, l10n("PvP")},
        [7361] = {41, l10n("PvP")},
        [7362] = {41, l10n("PvP")},
        [7363] = {41, l10n("PvP")},
        [7364] = {41, l10n("PvP")},
        [7365] = {41, l10n("PvP")},
        [7366] = {41, l10n("PvP")},
        [7367] = {41, l10n("PvP")},
        [7368] = {41, l10n("PvP")},
        [7381] = {41, l10n("PvP")},
        [7382] = {41, l10n("PvP")},
        [7385] = {41, l10n("PvP")},
        [7386] = {41, l10n("PvP")},
        [7401] = {41, l10n("PvP")},
        [7402] = {41, l10n("PvP")},
        [7421] = {41, l10n("PvP")},
        [7422] = {41, l10n("PvP")},
        [7423] = {41, l10n("PvP")},
        [7424] = {41, l10n("PvP")},
        [7425] = {41, l10n("PvP")},
        [7426] = {41, l10n("PvP")},
        [7427] = {41, l10n("PvP")},
        [7428] = {41, l10n("PvP")},
        [7737] = {0, ""},
        [7788] = {41, l10n("PvP")},
        [7789] = {41, l10n("PvP")},
        [7810] = {41, l10n("PvP")},
        [7838] = {41, l10n("PvP")},
        [7841] = {0, ""},
        [7842] = {0, ""},
        [7843] = {0, ""},
        [7871] = {41, l10n("PvP")},
        [7872] = {41, l10n("PvP")},
        [7873] = {41, l10n("PvP")},
        [7874] = {41, l10n("PvP")},
        [7875] = {41, l10n("PvP")},
        [7876] = {41, l10n("PvP")},
        [7886] = {41, l10n("PvP")},
        [7887] = {41, l10n("PvP")},
        [7888] = {41, l10n("PvP")},
        [7908] = {41, l10n("PvP")},
        [7921] = {41, l10n("PvP")},
        [7922] = {41, l10n("PvP")},
        [7923] = {41, l10n("PvP")},
        [7924] = {41, l10n("PvP")},
        [7925] = {41, l10n("PvP")},
        [8001] = {41, l10n("PvP")},
        [8002] = {41, l10n("PvP")},
        [8080] = {41, l10n("PvP")},
        [8081] = {41, l10n("PvP")},
        [8105] = {41, l10n("PvP")},
        [8114] = {41, l10n("PvP")},
        [8115] = {41, l10n("PvP")},
        [8120] = {41, l10n("PvP")},
        [8121] = {41, l10n("PvP")},
        [8122] = {41, l10n("PvP")},
        [8123] = {41, l10n("PvP")},
        [8124] = {41, l10n("PvP")},
        [8154] = {41, l10n("PvP")},
        [8155] = {41, l10n("PvP")},
        [8156] = {41, l10n("PvP")},
        [8157] = {41, l10n("PvP")},
        [8158] = {41, l10n("PvP")},
        [8159] = {41, l10n("PvP")},
        [8160] = {41, l10n("PvP")},
        [8161] = {41, l10n("PvP")},
        [8162] = {41, l10n("PvP")},
        [8163] = {41, l10n("PvP")},
        [8164] = {41, l10n("PvP")},
        [8165] = {41, l10n("PvP")},
        [8166] = {41, l10n("PvP")},
        [8167] = {41, l10n("PvP")},
        [8168] = {41, l10n("PvP")},
        [8169] = {41, l10n("PvP")},
        [8170] = {41, l10n("PvP")},
        [8171] = {41, l10n("PvP")},
        [8260] = {41, l10n("PvP")},
        [8261] = {41, l10n("PvP")},
        [8262] = {41, l10n("PvP")},
        [8263] = {41, l10n("PvP")},
        [8264] = {41, l10n("PvP")},
        [8265] = {41, l10n("PvP")},
        [8266] = {41, l10n("PvP")},
        [8267] = {41, l10n("PvP")},
        [8268] = {41, l10n("PvP")},
        [8269] = {41, l10n("PvP")},
        [8271] = {41, l10n("PvP")},
        [8272] = {41, l10n("PvP")},
        [8289] = {41, l10n("PvP")},
        [8290] = {41, l10n("PvP")},
        [8291] = {41, l10n("PvP")},
        [8292] = {41, l10n("PvP")},
        [8293] = {41, l10n("PvP")},
        [8294] = {41, l10n("PvP")},
        [8295] = {41, l10n("PvP")},
        [8296] = {41, l10n("PvP")},
        [8297] = {41, l10n("PvP")},
        [8298] = {41, l10n("PvP")},
        [8299] = {41, l10n("PvP")},
        [8300] = {41, l10n("PvP")},
        [8322] = {41, l10n("PvP")},
        [8367] = {41, l10n("PvP")},
        [8368] = {41, l10n("PvP")},
        [8369] = {41, l10n("PvP")},
        [8370] = {41, l10n("PvP")},
        [8371] = {41, l10n("PvP")},
        [8372] = {41, l10n("PvP")},
        [8373] = {41, l10n("PvP")},
        [8374] = {41, l10n("PvP")},
        [8375] = {41, l10n("PvP")},
        [8383] = {41, l10n("PvP")},
        [8384] = {41, l10n("PvP")},
        [8385] = {41, l10n("PvP")},
        [8386] = {41, l10n("PvP")},
        [8387] = {41, l10n("PvP")},
        [8388] = {41, l10n("PvP")},
        [8389] = {41, l10n("PvP")},
        [8390] = {41, l10n("PvP")},
        [8391] = {41, l10n("PvP")},
        [8392] = {41, l10n("PvP")},
        [8393] = {41, l10n("PvP")},
        [8394] = {41, l10n("PvP")},
        [8395] = {41, l10n("PvP")},
        [8396] = {41, l10n("PvP")},
        [8397] = {41, l10n("PvP")},
        [8398] = {41, l10n("PvP")},
        [8399] = {41, l10n("PvP")},
        [8400] = {41, l10n("PvP")},
        [8401] = {41, l10n("PvP")},
        [8402] = {41, l10n("PvP")},
        [8403] = {41, l10n("PvP")},
        [8404] = {41, l10n("PvP")},
        [8405] = {41, l10n("PvP")},
        [8406] = {41, l10n("PvP")},
        [8407] = {41, l10n("PvP")},
        [8408] = {41, l10n("PvP")},
        [8409] = {41, l10n("PvP")},
        [8426] = {41, l10n("PvP")},
        [8427] = {41, l10n("PvP")},
        [8428] = {41, l10n("PvP")},
        [8429] = {41, l10n("PvP")},
        [8430] = {41, l10n("PvP")},
        [8431] = {41, l10n("PvP")},
        [8432] = {41, l10n("PvP")},
        [8433] = {41, l10n("PvP")},
        [8434] = {41, l10n("PvP")},
        [8435] = {41, l10n("PvP")},
        [8436] = {41, l10n("PvP")},
        [8437] = {41, l10n("PvP")},
        [8438] = {41, l10n("PvP")},
        [8439] = {41, l10n("PvP")},
        [8440] = {41, l10n("PvP")},
        [8441] = {41, l10n("PvP")},
        [8442] = {41, l10n("PvP")},
        [8443] = {41, l10n("PvP")},
        [9419] = {41, l10n("PvP")},
        [9422] = {41, l10n("PvP")},
        [9664] = {41, l10n("PvP")},
        [9665] = {41, l10n("PvP")},
        [11335] = {41, l10n("PvP")},
        [11336] = {41, l10n("PvP")},
        [11337] = {41, l10n("PvP")},
        [11338] = {41, l10n("PvP")},
        [11339] = {41, l10n("PvP")},
        [11340] = {41, l10n("PvP")},
        [11341] = {41, l10n("PvP")},
        [11342] = {41, l10n("PvP")},
        [12170] = {41, l10n("PvP")},
        [12244] = {41, l10n("PvP")},
        [12268] = {41, l10n("PvP")},
        [12270] = {41, l10n("PvP")},
        [12280] = {41, l10n("PvP")},
        [12284] = {41, l10n("PvP")},
        [12288] = {41, l10n("PvP")},
        [12289] = {41, l10n("PvP")},
        [12296] = {41, l10n("PvP")},
        [12314] = {41, l10n("PvP")},
        [12315] = {41, l10n("PvP")},
        [12316] = {41, l10n("PvP")},
        [12317] = {41, l10n("PvP")},
        [12323] = {41, l10n("PvP")},
        [12324] = {41, l10n("PvP")},
        [12432] = {41, l10n("PvP")},
        [12433] = {41, l10n("PvP")},
        [12434] = {41, l10n("PvP")},
        [12437] = {41, l10n("PvP")},
        [12443] = {41, l10n("PvP")},
        [12446] = {41, l10n("PvP")},
        [13129] = {81, l10n("Dungeon")},
        [13199] = {41, l10n("PvP")},
        [13662] = {0, ""},
        [26452] = {41, l10n("PvP")},
        [26856] = {81, l10n("Dungeon")},
        [26858] = {81, l10n("Dungeon")},
        [26862] = {81, l10n("Dungeon")},
        [26866] = {81, l10n("Dungeon")},
        [26962] = {81, l10n("Dungeon")},
        [26967] = {81, l10n("Dungeon")},
        [27848] = {81, l10n("Dungeon")},
        [27850] = {81, l10n("Dungeon")},
        [28735] = {81, l10n("Dungeon")},
        [28737] = {81, l10n("Dungeon")},
        [28738] = {81, l10n("Dungeon")},
        [28740] = {81, l10n("Dungeon")},
        [28760] = {81, l10n("Dungeon")},
        [28814] = {81, l10n("Dungeon")},
        [28845] = {81, l10n("Dungeon")},
        [29135] = {62, l10n("Raid")},
        [29153] = {81, l10n("Dungeon")},
        [29154] = {81, l10n("Dungeon")},
        [29172] = {81, l10n("Dungeon")},
        [29173] = {81, l10n("Dungeon")},
        [29175] = {81, l10n("Dungeon")},
        [29208] = {81, l10n("Dungeon")},
        [29241] = {81, l10n("Dungeon")},
        [29242] = {81, l10n("Dungeon")},
        [29251] = {81, l10n("Dungeon")},
        [29252] = {81, l10n("Dungeon")},
        [29760] = {41, l10n("PvP")},
        [29761] = {41, l10n("PvP")},
        [64845] = {41, l10n("PvP")},
        [78680] = {1, l10n("Elite")},
        [78681] = {1, l10n("Elite")},
        [78684] = {1, l10n("Elite")},
        [80098] = {1, l10n("Elite")},
        [80147] = {1, l10n("Elite")},
        [80148] = {1, l10n("Elite")},
        [80149] = {1, l10n("Elite")},
        [80150] = {1, l10n("Elite")},
        [80151] = {1, l10n("Elite")},
        [80152] = {1, l10n("Elite")},
        [90014] = {1, l10n("Elite")},
        [90054] = {1, l10n("Elite")},
        [90070] = {1, l10n("Elite")},
        [90081] = {1, l10n("Elite")},
        [90091] = {1, l10n("Elite")},
        [90094] = {1, l10n("Elite")},
        [90113] = {1, l10n("Elite")},
        [90114] = {1, l10n("Elite")},
        [90119] = {1, l10n("Elite")},
        [90122] = {1, l10n("Elite")},
        [90151] = {1, l10n("Elite")},
        [90152] = {1, l10n("Elite")},
        [90159] = {1, l10n("Elite")},
        [90163] = {1, l10n("Elite")},
        [90166] = {1, l10n("Elite")},
        [90169] = {1, l10n("Elite")},
        [90175] = {1, l10n("Elite")},
        [90190] = {1, l10n("Elite")},
        [90202] = {1, l10n("Elite")},
        [90204] = {1, l10n("Elite")},
        [90221] = {1, l10n("Elite")},
        [90225] = {1, l10n("Elite")},
        [90230] = {1, l10n("Elite")},
        [90269] = {1, l10n("Elite")},
        [90271] = {1, l10n("Elite")},
        [90281] = {1, l10n("Elite")},
        [90282] = {1, l10n("Elite")},
        [90287] = {1, l10n("Elite")},
        [90288] = {1, l10n("Elite")},
        [90289] = {1, l10n("Elite")},
        [90308] = {1, l10n("Elite")},
        [90312] = {1, l10n("Elite")},
        [90334] = {1, l10n("Elite")},
        [90335] = {1, l10n("Elite")},
        [90339] = {1, l10n("Elite")},
        [90343] = {1, l10n("Elite")},
        [90344] = {1, l10n("Elite")},
        [90353] = {1, l10n("Elite")},

        -- MoP quests
        [30567] = {98, l10n("Scenario")},
        [31058] = {98, l10n("Scenario")},
        [31454] = {83, l10n("Legendary")},
        [31468] = {83, l10n("Legendary")},
        [31473] = {83, l10n("Legendary")},
        [31488] = {83, l10n("Legendary")},
        [31489] = {83, l10n("Legendary")},
        [31519] = {85, l10n("Heroic")},
        [31520] = {85, l10n("Heroic")},
        [31522] = {85, l10n("Heroic")},
        [31523] = {85, l10n("Heroic")},
        [31524] = {85, l10n("Heroic")},
        [31525] = {85, l10n("Heroic")},
        [31526] = {85, l10n("Heroic")},
        [31527] = {85, l10n("Heroic")},
        [31528] = {85, l10n("Heroic")},
        [31611] = {98, l10n("Scenario")},
        [31613] = {98, l10n("Scenario")},
        [31917] = {102, l10n("Account")},
        [31918] = {102, l10n("Account")},
        [31975] = {102, l10n("Account")},
        [31976] = {102, l10n("Account")},
        [31977] = {102, l10n("Account")},
        [31980] = {102, l10n("Account")},
        [31981] = {102, l10n("Account")},
        [31982] = {102, l10n("Account")},
        [31983] = {102, l10n("Account")},
        [31984] = {102, l10n("Account")},
        [31985] = {102, l10n("Account")},
        [31986] = {102, l10n("Account")},
        [31998] = {85, l10n("Heroic")},
        [32000] = {85, l10n("Heroic")},
        [32001] = {85, l10n("Heroic")},
        [32002] = {85, l10n("Heroic")},
        [32003] = {85, l10n("Heroic")},
        [32004] = {85, l10n("Heroic")},
        [32005] = {85, l10n("Heroic")},
        [32006] = {85, l10n("Heroic")},
        [32007] = {85, l10n("Heroic")},
        [91701] = {294, l10n("Celestial")},
        [91702] = {294, l10n("Celestial")},
        [91703] = {294, l10n("Celestial")},
        [91704] = {294, l10n("Celestial")},
        [91705] = {294, l10n("Celestial")},
        [91706] = {294, l10n("Celestial")},
        [91707] = {294, l10n("Celestial")},
        [91708] = {294, l10n("Celestial")},
        [91709] = {294, l10n("Celestial")},
        [91710] = {294, l10n("Celestial")},
        [91711] = {294, l10n("Celestial")},
        [91712] = {294, l10n("Celestial")},
        [91713] = {294, l10n("Celestial")},
        [91714] = {294, l10n("Celestial")},
        [91715] = {294, l10n("Celestial")},
        [91716] = {294, l10n("Celestial")},
        [91717] = {294, l10n("Celestial")},
        [91718] = {294, l10n("Celestial")},
        [91786] = {294, l10n("Celestial")},

        -- TBC Anniversary quests
        [95455] = {41, l10n("PvP")},
        [95457] = {41, l10n("PvP")},
    }
end
