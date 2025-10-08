---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

local tinsert = table.insert
local eventQuests = QuestieEvent.eventQuests

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

-- TBC quests
tinsert(eventQuests, {"Hallow's End", 11450}) -- Fire Training
tinsert(eventQuests, {"Hallow's End", 11356}) -- Costumed Orphan Matron
tinsert(eventQuests, {"Hallow's End", 11357}) -- Masked Orphan Matron
tinsert(eventQuests, {"Hallow's End", 11131}) -- Stop the Fires!
tinsert(eventQuests, {"Hallow's End", 11135, nil, nil, Questie.IsTBC}) -- The Headless Horseman
tinsert(eventQuests, {"Hallow's End", 11220, nil, nil, Questie.IsTBC}) -- The Headless Horseman
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
tinsert(eventQuests, {"Hallow's End", 12338, nil, nil, Expansions.Current >= Expansions.Cata}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12339}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12340}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12341}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12342}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12343}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12344}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12345}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12346, nil, nil, Expansions.Current >= Expansions.Cata}) -- Candy Bucket
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
tinsert(eventQuests, {"Hallow's End", 12375, nil, nil, Expansions.Current >= Expansions.Cata}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12376}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12377}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12378}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12379, nil, nil, Expansions.Current >= Expansions.Cata}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12380}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12381}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12382}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12383}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12384}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 12385, nil, nil, Expansions.Current >= Expansions.Cata}) -- Candy Bucket
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
tinsert(eventQuests, {"Hallow's End", 11392, nil, nil, Questie.IsTBC}) -- Call the Headless Horseman
tinsert(eventQuests, {"Hallow's End", 11401, nil, nil, Questie.IsTBC}) -- Call the Headless Horseman
tinsert(eventQuests, {"Hallow's End", 11403}) -- Free at Last!
tinsert(eventQuests, {"Hallow's End", 11242}) -- Free at Last!
--tinsert(eventQuests, {"Hallow's End", 11404}) -- Call the Headless Horseman
--tinsert(eventQuests, {"Hallow's End", 11405}) -- Call the Headless Horseman

-- WoTLK quests
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

-- Cata quests
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
tinsert(eventQuests, {"Hallow's End", 29413}) -- The Creepy Crate
tinsert(eventQuests, {"Hallow's End", 29415}) -- Missing Heirlooms
tinsert(eventQuests, {"Hallow's End", 29416}) -- Fencing the Goods
tinsert(eventQuests, {"Hallow's End", 29425}) -- Shopping Around
tinsert(eventQuests, {"Hallow's End", 29426}) -- Taking Precautions
tinsert(eventQuests, {"Hallow's End", 29427}) -- The Collector's Agent
tinsert(eventQuests, {"Hallow's End", 29428}) -- What Now?
tinsert(eventQuests, {"Hallow's End", 29429}) -- The Creepy Crate
tinsert(eventQuests, {"Hallow's End", 29430}) -- A Friend in Need
tinsert(eventQuests, {"Hallow's End", 29431}) -- A Friend in Need

-- MoP quests
tinsert(eventQuests, {"Hallow's End", 32020}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32021}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32022}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32023}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32024}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32026}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32027}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32028}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32029}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32031}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32032}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32033}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32034}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32036}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32037}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32039}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32040}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32041}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32042}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32043}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32044}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32046}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32047}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32048}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32049}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32050}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32051}) -- Candy Bucket
tinsert(eventQuests, {"Hallow's End", 32052}) -- Candy Bucket
