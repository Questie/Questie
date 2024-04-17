---@class QuestieDebugOffer
local QuestieDebugOffer = QuestieLoader:CreateModule("QuestieDebugOffer")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")

---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local DebugInformation = {} -- stores text of debug data dump per session
local debugIndex = 0 -- current debug index, used so we can still retrieve info from previous offers
local openDebugWindows = {} -- determines if existing debug window is already open, prevents duplicates

local GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition
local PosX = 0
local PosY = 0
local target = "target"
local player = "player"
local questnpc = "questnpc"

local _, playerRace = UnitRace(player)
local playerClass = UnitClassBase(player)

local gameType = ""
if Questie.IsWotlk then
    gameType = "Wrath"
elseif Questie.IsSoD then -- seasonal checks must be made before non-seasonal for that client, since IsEra resolves true in SoD
    gameType = "SoD"
elseif Questie.IsEra then
    gameType = "Era"
end

-- determines what level is required to receive debug offers
-- adjust as needed to cut down spam during major game releases
-- entries on whitelist ignore this value
local minLevelForDebugOffers = 10

local itemBlacklist = {
    209027, -- Crap Treats (these are also looted from fishing, for which no real "objects" exists)
    215430, -- gnomeregan fallout, drops from nearly every mob in gnomeregan
    -- Waylaid Supplies level 10
    211316, -- peacebloom
    211933, -- rough stone
    211331, -- brilliant smallfish
    210771, -- copper bars
    211934, -- healing potions
    211315, -- light leather
    211317, -- silverleaf
    211327, -- brown linen pants
    211328, -- brown linen robes
    211332, -- heavy linen bandages
    211324, -- rough boomsticks
    211330, -- spiced wolf meat
    211329, -- herb baked eggs
    211325, -- handstitched leather belts
    211321, -- lesser magic wands
    211320, -- runed copper pants
    211323, -- rough copper bombs
    211319, -- copper shortswords
    211326, -- embossed leather vests
    211318, -- minor healing potions
    211322, -- minor wizard oil
    -- Waylaid Supplies level 25
    211823, -- swiftthistle
    211834, -- pearl clasped cloaks
    211832, -- hillmans shoulders
    211827, -- runed silver rods
    211935, -- elixir of firepower
    211833, -- gray woolen shirts
    211821, -- medium leather
    211819, -- bronze bars
    211826, -- silver skeleton keys
    211831, -- dark leather cloaks
    211836, -- smoked bear meat
    211830, -- ornate spyglasses
    211820, -- silver bars
    211837, -- goblin deviled clams
    211822, -- bruiseweed
    211825, -- rough bronze boots
    211835, -- smoked sagefish
    211824, -- lesser mana potions
    211838, -- heavy wool bandages
    211829, -- small bronze bombs
    211828, -- minor mana oil
    -- Waylaid Supplies level 30
    215408, -- guardian gloves
    215413, -- formal white shirts
    215421, -- fire oil
    215420, -- rockscale cod
    215411, -- frost leather cloaks
    215398, -- green iron bracers
    215387, -- heavy hide
    215402, -- big iron bombs
    215391, -- wintersbite
    215389, -- fadeleaf
    215403, -- deadly scopes
    215400, -- solid grinding stones
    -- Waylaid Supplies level 35
    215415, -- rich purple silk shirts
    215414, -- crimson silk pantaloons
    215407, -- barbaric shoulders
    215410, -- dusky belts
    215418, -- spider sausages
    215417, -- soothing turtle bisque
    215412, -- shadowskin gloves
    215419, -- heavy silk bandages
    215401, -- compact harvest reaper kits
    215385, -- gold bars
    215399, -- heavy mithril gauntlets
    215388, -- thick leather
    215395, -- elixirs of agility
    215386, -- mithril bars
    215393, -- greater healing potions
    215390, -- khadgars whisker
    215392, -- purple lotus
    -- Waylaid Supplies level 40
    215416, -- white bandit masks
    215409, -- turtle scale bracers
    215397, -- massive iron axes
    215394, -- lesser stoneshield potions
    215404, -- mithril blunderbuss
    215396, -- elixirs of greater defense
    215405, -- gnomish rocket boots
    215406, -- goblin mortars
    -- Waylaid Supplies level 50
    220918, -- undermine clam chowder
    220919, -- nightfin soup
    220920, -- tender wolf steaks
    220921, -- heavy mageweave bandages
    220922, -- sungrass
    220923, -- dreamfoil
    220924, -- truesilver bars
    220925, -- thorium bars
    220926, -- rugged leather
    220927, -- thick hide
    220928, -- enchanted thorium bars
    220929, -- superior mana potions
    220930, -- major healing potions
    220931, -- hi-explosive bombs
    220932, -- thorium grenades
    220933, -- thorium rifles
    220934, -- mithril coifs
    220935, -- thorium belts
    220936, -- truesilver gauntlets
    220937, -- rugged armor kits
    220938, -- wicked leather bracers
    220939, -- runic leather bracers
    220940, -- black mageweave headbands
    220941, -- runecloth belts
    220942, -- tuxedo shirts

    203753, -- Mage encoded spell notes
    203752, -- Mage encoded spell notes
    208754, -- Mage encoded spell notes
    208854, -- Mage encoded spell notes
    203751, -- Mage encoded spell notes
    209028, -- Mage encoded spell notes
    210655, -- Mage encoded spell notes
    213543, -- Scroll: UPDOG
    213544, -- Scroll: TOPAZ YORAK
    211785, -- Scroll: CWAL
    213547, -- Scroll: THAW WORDS
    211787, -- Scroll: LOWER PING WHOMEVER
    213545, -- Scroll: PEATCHY ATTAX
    213546, -- Scroll: SHOOBEEDOOP
    211780, -- Scroll: KWYJIBO
    211786, -- Scroll: CHAP BALK WELLES
    211855, -- Scroll: STHENIC LUNATE
    211784, -- Scroll: WUBBA WUBBA
    211854, -- Scroll: OMIT KESA
    211853, -- Scroll: VOCE WELL

    -- Dalaran Relics
    216945, -- Curious Dalaran Relic
    216946, -- Glittering Dalaran Relic
    216947, -- Whirring Dalaran Relic
    216948, -- Odd Dalaran Relic
    216949, -- Heavy Dalaran Relic
    216950, -- Creepy Dalaran Relic
    216951, -- Slippery Dalaran Relic

    -- Updates Profession Recipes
    217249, -- Pattern: Earthen Silk Belt
    217251, -- Pattern: Crimson Silk Shoulders
    217254, -- Pattern: Boots of the Enchanter
    217260, -- Pattern: Big Voodoo Mask
    217262, -- Pattern: Big Voodoo Robe
    217264, -- Pattern: Guardian Leather Bracers
    217266, -- Pattern: Guardian Belt
    217271, -- Pattern: Turtle Scale Gloves
    217274, -- Plans: Golden Scale Gauntlets
    217276, -- Plans: Golden Scale Boots
    217278, -- Plans: Golden Scale Cuirass
    217280, -- Plans: Golden Scale Coif
    217282, -- Plans: Moonsteel Broadsword
    217284, -- Plans: Golden Scale Shoulders
    217286, -- Plans: Golden Scale Leggings

    -- New Darkmoon Cards
    221271, -- Ace of Wilds
    221273, -- Two of Wilds
    221274, -- Three of Wilds
    221275, -- Four of Wilds
    221276, -- Five of Wilds
    221277, -- Six of Wilds
    221278, -- Seven of Wilds
    221279, -- Eight of Wilds
    221281, -- Ace of Plagues
    221282, -- Two of Plagues
    221283, -- Three of Plagues
    221284, -- Four of Plagues
    221285, -- Five of Plagues
    221286, -- Six of Plagues
    221287, -- Seven of Plagues
    221288, -- Eight of Plagues
    221290, -- Ace of Dunes
    221291, -- Two of Dunes
    221292, -- Three of Dunes
    221293, -- Four of Dunes
    221294, -- Five of Dunes
    221295, -- Six of Dunes
    221296, -- Seven of Dunes
    221297, -- Eight of Dunes
    221298, -- Ace of Nightmares
    221300, -- Two of Nightmares
    221301, -- Three of Nightmares
    221302, -- Four of Nightmares
    221303, -- Five of Nightmares
    221304, -- Six of Nightmares
    221305, -- Seven of Nightmares
    221306, -- Eight of Nightmares

}

local itemWhitelist = {
    -- TODO: Add distance check for these
    --208609, -- glade flower for druid living seed
    --206469, -- prairie flower for druid living seed
}

local itemTripCodes = {
    ['ItemWhitelisted'] = 0, -- itemID is whitelisted; we want all its data anyway
    ['ItemMissingFromDB'] = 1, -- error when itemID is missing from DB entirely
    ['StartQuestIDMismatch'] = 2, -- error when item quest start ID does not match Questie ItemDB
    ['MissingDropFromNPC'] = 3, -- error when item dropped from npc (corpses) not matching ItemDB
    ['MissingDropFromObject'] = 4, -- error when item dropped from object (chests in world) not matching ItemDB
    ['MissingDropFromItem'] = 5, -- error when item dropped from item (lockboxes in inventory) not matching ItemDB
    ['ContainerMissingFromNPCDB'] = 6, -- error when item's container is missing from NpcDB
    ['ContainerMissingFromObjectDB'] = 7, -- error when item's container is missing from ObjectDB
    ['ContainerMissingFromItemDB'] = 8, -- error when item's container is missing from ItemDB
}

-- determines whether to offer a debug offer for a looted item
-- if we should create an offer, return an enumerated value from itemTripCodes
-- if we should not create an offer, return nil
---@param itemID integer -- ID of looted item
---@param itemInfo table -- subset from GetLootInfo()
local function filterItem(itemID, itemInfo, containerGUID)
    -- return true if we should create debug offer, false if not
    if itemID <= 0 or itemID == nil or containerGUID == nil then -- if itemID or containerGUID is invalid don't bother going further
        return nil
    elseif itemID < 190000 then
        -- temporary catch-all for any item added before SoD so we only get SoD reports;
        -- OG chronoboon displacer was 184937 so safe to say any SoD items are higher than 190000
        return nil
    else
        if tContains(itemWhitelist, itemID) then -- if item is in our whitelist, we want it no matter what
            return itemTripCodes.ItemWhitelisted
        elseif tContains(itemBlacklist, itemID) then -- if item is in our blacklist, ignore it
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - ItemFilter - Item " .. itemID .. " is in debug offer item blacklist, ignoring")
            return nil
        elseif UnitLevel(player) < minLevelForDebugOffers then -- if player level is below our threshold, ignore it
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - ItemFilter - Player does not meet level threshold for debug offers, ignoring")
            return nil
        elseif QuestieCorrections.questItemBlacklist[itemID] then
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - ItemFilter - Item " .. itemID .. " is in QuestieCorrections item blacklist, ignoring")
            return nil
        end

        -- Proceeding with checks, so gather required info
        local questID = 0
        if itemInfo.questId then
            questID = itemInfo.questId
        end
        local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
        itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
        expacID, setID, isCraftingReagent = GetItemInfo(itemID)
        local containerID = tonumber(containerGUID:match("-(%d+)-%x+$"), 10)
        local containerType = strsplit("-", containerGUID)

        -- Begin data checks.
        -- We do basic comparisons at the top level so a laggy DB can't drag down our final determination;
        -- Slow determinations can compound quickly the more items a container holds.

        -- check if item is even in our DB
        if itemID <= 0 or not QuestieDB.QueryItemSingle(itemID, "name") then
            return itemTripCodes.ItemMissingFromDB
        end

        -- check matching questID for quest start items
        if questID > 0 then
            if questID ~= QuestieDB.QueryItemSingle(itemID, "startQuest") then
                return itemTripCodes.StartQuestIDMismatch
            else
                Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - ItemFilter - QuestID for " .. itemID .. " present but matches DB, ignoring")
            end
        else
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - ItemFilter - QuestID value not present, ignoring")
        end

        -- check loot source data
        if containerType == "Creature" then -- if container is an NPC (corpse)
            -- first check if creature is even in our DB
            if not QuestieDB.QueryNPCSingle(containerID, "name") then
                return itemTripCodes.ContainerMissingFromNPCDB
            end

            -- check if item can drop from this creature
            local lootTable = QuestieDB.QueryItemSingle(itemID, "npcDrops")
            if not lootTable or tContains(lootTable, containerID) == false then
                return itemTripCodes.MissingDropFromNPC
            else
                Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - ItemFilter - NPC drop data for item " .. itemID .. " OK, ignoring")
            end
        elseif containerType == "GameObject" then -- if container is an object
            -- first check if object is even in our DB
            if not QuestieDB.QueryObjectSingle(containerID, "name") then
                return itemTripCodes.ContainerMissingFromObjectDB
            end

            -- check if item can drop from this object
            local lootTable = QuestieDB.QueryItemSingle(itemID, "objectDrops")
            if lootTable then
                if tContains(lootTable, containerID) == false then
                    return itemTripCodes.MissingDropFromObject
                else
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - ItemFilter - Object drop data for item " .. itemID .. " OK, ignoring")
                end
            end
        elseif containerType == "Item" and containerID > 0 then -- if container is an item and there is an containerID for it
            -- TODO: I am quite sure this case can never happen, because the containerID is always 0 for items. Is there a different way?
            -- first check if container item is even in our DB.
            if (not QuestieDB.QueryItemSingle(containerID, "name")) then
                return itemTripCodes.ContainerMissingFromItemDB
            end

            -- check if item can drop from this container
            local lootTable = QuestieDB.QueryItemSingle(itemID, "itemDrops")
            if lootTable then
                if tContains(lootTable, containerID) == false then
                    return itemTripCodes.MissingDropFromItem
                else
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - ItemFilter - ItemSource drop data for item " .. itemID .. " OK, ignoring")
                end
            end
        end
    end
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - ItemFilter - No data mismatches found for " .. itemID .. ", ignoring")
    return nil -- if no exceptions raised, we don't need to create a debug offer
end

local npcBlacklist = {
    202093, -- Polymorphed Apprentice, for mage polymorph rune quest
}

-- Appends character info, player coordinates, quest log, client version, questie version, and locale to the end of Debug Offers
---@param input string --@String containing debug information input
local function _AppendUniversalText(input)
    local text = tostring(input)

    text = text .. "\n|cFFAAAAAACharacter:|r Lvl " .. UnitLevel(player) .. " " .. string.upper(playerRace) .. " " .. playerClass

    local mapID = GetBestMapForUnit(player)
    local pos = GetPlayerMapPosition(mapID, player);
    PosX = pos.x * 100
    PosY = pos.y * 100
    text = text .. "\n|cFFAAAAAAPlayer Coords:|r  [" .. mapID .. "]  " .. format("(%.3f, %.3f)", PosX, PosY)

    local questLog = ""
    for k in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do questLog = k .. ", " .. questLog end

    text = text .. "\n|cFFAAAAAAQuestLog:|r " .. questLog
    text = text .. "\n|cFFAAAAAAClient:|r " .. GetBuildInfo() .. " " .. gameType
    text = text .. "\n|cFFAAAAAAQuestie:|r " .. QuestieLib:GetAddonVersionString()
    text = text .. "\n|cFFAAAAAALocale:|r " .. GetLocale()

    return text
end

-- Missing itemID when looting
function QuestieDebugOffer.LootWindow()
    local lootInfo = GetLootInfo()
    local debugContainer, _ = GetLootSourceInfo(1) -- happens early in case the rest of the code is so slow that the container closes before we're ready
    local inInstance, _ = IsInInstance()
    if inInstance == true then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - ItemLoot - Player looting item is in instance, ignoring")
        return -- temporary for SoD to reduce new raid loot triggering debug spam
    end

    for i=1, #lootInfo do
        local itemInfo = lootInfo[i]
        local itemLink = GetLootSlotLink(i)
        local itemID = 0
        if itemLink then
            local itemIdFromLink = GetItemInfoFromHyperlink(itemLink)
            if itemIdFromLink then
                itemID = itemIdFromLink
            end
        end

        local tripCode = filterItem(itemID, itemInfo, debugContainer)
        if tripCode then
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - ItemLoot - Creating debug offer for item " .. itemID .. " reason " .. tripCode)
            debugIndex = debugIndex + 1
            if tripCode == itemTripCodes.ItemWhitelisted then
                DebugInformation[debugIndex] = "ItemDB is missing some data about this item!"
            elseif tripCode == itemTripCodes.ItemMissingFromDB then
                DebugInformation[debugIndex] = "Item not present in ItemDB!"
            elseif tripCode == itemTripCodes.StartQuestIDMismatch then
                DebugInformation[debugIndex] = "Item's QuestID does not match ItemDB!"
            elseif tripCode == itemTripCodes.MissingDropFromNPC then
                DebugInformation[debugIndex] = "Item does not match ItemDB npcDrops!"
            elseif tripCode == itemTripCodes.MissingDropFromObject then
                DebugInformation[debugIndex] = "Item does not match ItemDB objectDrops!"
            elseif tripCode == itemTripCodes.MissingDropFromItem then
                DebugInformation[debugIndex] = "Item does not match ItemDB itemDrops!"
            elseif tripCode == itemTripCodes.ContainerMissingFromNPCDB then
                DebugInformation[debugIndex] = "Item's container is missing from NpcDB!"
            elseif tripCode == itemTripCodes.ContainerMissingFromObjectDB then
                DebugInformation[debugIndex] = "Item's container is missing from ObjectDB!"
            elseif tripCode == itemTripCodes.ContainerMissingFromItemDB then
                DebugInformation[debugIndex] = "Item's container is missing from ItemDB!"
            else
                DebugInformation[debugIndex] = "General data mismatch for item!"
            end
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n\n|cFFAAAAAAItem ID:|r " .. tostring(itemID)
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAItem Name:|r " .. itemLink
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Item:|r " .. tostring(itemInfo.isQuestItem)
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest ID:|r " .. tostring(itemInfo.questId)
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAContainer:|r " .. tostring(debugContainer)
            DebugInformation[debugIndex] = _AppendUniversalText(DebugInformation[debugIndex])
            Questie:Print(l10n("An item you just encountered has data missing from the Questie database.") .. " " .. l10n("Would you like to help us fix it?") .. " |cff71d5ff|Haddon:questie:offer:" .. debugIndex .. "|h[" .. l10n("More Info") .. "]|h|r")
            return -- we only want to show one debug offer per interaction, so break on the first one
        end
    end
end

-- Missing questID when conversing
function QuestieDebugOffer.QuestDialog()
    local questID = GetQuestID() -- obtain quest ID from dialog
    if questID <= 0 or questID == nil then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - QuestDialog - Invalid quest ID from API, ignoring")
        return -- invalid data from API, abandon offer attempt
    end
    if UnitLevel(player) < minLevelForDebugOffers then -- if player level is below our threshold, ignore it
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - QuestDialog - Player does not meet level threshold for debug offers, ignoring")
        return
    end
    if QuestieDB.QueryQuestSingle(questID, "name") == nil then -- if ID not in our DB
        debugIndex = debugIndex + 1
        local questTitle = GetTitleText()
        local questText = GetQuestText()
        local objectiveText = GetObjectiveText()
        local rewardText = GetRewardText()
        local rewardXP = GetRewardXP()

        if questText then questText = questText:gsub(GetUnitName(player), "<playername>") end -- strip out player name from quest text
        if objectiveText then objectiveText = objectiveText:gsub(GetUnitName(player), "<playername>") end -- strip out player name from objective text
        if rewardText then rewardText = rewardText:gsub(GetUnitName(player), "<playername>") end -- strip out player name from reward text

        DebugInformation[debugIndex] = "Quest in dialog not present in QuestDB!"
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n\n|cFFAAAAAAQuest ID:|r " .. tostring(questID)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Name:|r " .. tostring(questTitle)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Text:|r " .. tostring(questText)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAObjective Text:|r " .. tostring(objectiveText)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAReward Text:|r " .. tostring(rewardText)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAReward XP:|r " .. tostring(rewardXP)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuestgiver:|r " .. tostring(UnitGUID(questnpc))
        DebugInformation[debugIndex] = _AppendUniversalText(DebugInformation[debugIndex])
        Questie:Print(l10n("A quest you just encountered is missing from the Questie database.") .. " " .. l10n("Would you like to help us fix it?") .. " |cff71d5ff|Haddon:questie:offer:" .. debugIndex .. "|h[" .. l10n("More Info") .. "]|h|r")
    end
end

-- Missing questID when tracking
---@param questID number
function QuestieDebugOffer.QuestTracking(questID) -- ID supplied by tracker during update
    if UnitLevel(player) < minLevelForDebugOffers then -- if player level is below our threshold, ignore it
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - QuestTracking - Player does not meet level threshold for debug offers, ignoring")
        return
    end
    if QuestieDB.QueryQuestSingle(questID, "name") == nil then -- if ID not in our DB
        for i=1, GetNumQuestLogEntries() do
            local questTitle, questLevel, suggestedGroup, _, _, _, frequency, questLogId = GetQuestLogTitle(i)
            local questText, objectiveText = GetQuestLogQuestText(i)

            if questText then questText = questText:gsub(GetUnitName(player), "<playername>") end -- strip out player name from quest text
            if objectiveText then objectiveText = objectiveText:gsub(GetUnitName(player), "<playername>") end -- strip out player name from objective text

            if questID == questLogId then
                debugIndex = debugIndex + 1
                DebugInformation[debugIndex] = "Quest in tracker not present in QuestDB!"
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n\n|cFFAAAAAAQuest ID:|r " .. tostring(questLogId)
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Name:|r " .. tostring(questTitle)
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Text:|r " .. tostring(questText)
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAObjective Text:|r " .. tostring(objectiveText)
                DebugInformation[debugIndex] = _AppendUniversalText(DebugInformation[debugIndex])
                Questie:Print(l10n("A quest in your quest log is missing from the Questie database and can't be tracked.") .. " " .. l10n("Would you like to help us fix it?") .. " |cff71d5ff|Haddon:questie:offer:" .. debugIndex .. "|h[" .. l10n("More Info") .. "]|h|r")
                --print(tostring(QuestieDB.IsSoDRuneQuest(questlogid)))
            end
        end
    end
end

local targetTimeout = {} -- store timeouts per-ID so we don't cause lag or spam chat if a player clicks on an unknown NPC often
local timeoutDurationOverworld = 120 -- how many seconds to ignore re-passes outside of instances
local timeoutDurationInstance = 600 -- how many seconds to ignore re-passes outside of instances
-- Missing NPC ID when targeting
function QuestieDebugOffer.NPCTarget()
    if UnitLevel(player) < minLevelForDebugOffers then -- if player level is below our threshold, ignore it
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - NPCTarget - Player does not meet level threshold for debug offers, ignoring")
        return
    end
    local inInstance, _ = IsInInstance()
    if inInstance == true then -- temporary override for SoD launch to not prompt NPC debug offers inside instances at all, to prevent BFD spam
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - NPCTarget - Player targeting NPC is in instance, ignoring")
        return
    end
    local targetGUID = UnitGUID(target)
    local unit_type = strsplit("-", tostring(targetGUID)) -- determine target type
    if unit_type == "Creature" then -- if target is an NPC
        local npcID = tonumber(targetGUID:match("-(%d+)-%x+$"), 10) -- obtain NPC ID
        if targetTimeout[npcID] == true then -- if target was already targeted recently
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - NPCTarget - Targeted NPC was targeted recently, ignoring")
            return
        else -- if target was NOT targeted recently
            if tContains(npcBlacklist, npcID) then -- if NPC is in our blacklist, ignore it
                Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - NPCTarget - Targeted NPC is in NPC blacklist, ignoring")
                return
            end
            targetTimeout[npcID] = true
            if QuestieDB.QueryNPCSingle(npcID, "name") == nil then -- if ID not in our DB
                debugIndex = debugIndex + 1
                DebugInformation[debugIndex] = "Targeted NPC not present in NPC DB!"
                local npcName = UnitFullName(target)
                local npcLevel = UnitLevel(target)
                local npcHealth = UnitHealth(target)
                local npcHealthMax = UnitHealthMax(target)
                local npcHostile = UnitIsEnemy(target, player)
                local npcFriendly = UnitIsFriend(target, player)
                local npcStatus = "Unknown"
                if npcHostile == true then
                    npcStatus = "Hostile"
                elseif npcFriendly == true then
                    npcStatus = "Friendly"
                elseif npcFriendly == false then
                    npcStatus = "Neutral"
                end
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n\n|cFFAAAAAANPC ID:|r " .. tostring(npcID)
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAANPC Name:|r " .. tostring(npcName)
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAANPC Level:|r " .. tostring(npcLevel)
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAANPC Health, Max:|r " .. tostring(npcHealth) .. ", " .. tostring(npcHealthMax)
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAANPC Allegiance:|r " .. tostring(npcStatus)
                DebugInformation[debugIndex] = _AppendUniversalText(DebugInformation[debugIndex])
                Questie:Print(l10n("The NPC you just targeted is missing from the Questie database.") .. " " .. l10n("Would you like to help us fix it?") .. " |cff71d5ff|Haddon:questie:offer:" .. debugIndex .. "|h[" .. l10n("More Info") .. "]|h|r")
            end
            if inInstance == false then
                C_Timer.NewTimer (timeoutDurationOverworld, function() targetTimeout[npcID] = false end)
            else
                C_Timer.NewTimer (timeoutDurationInstance, function() targetTimeout[npcID] = false end)
            end
        end
    else
        return -- If the target is not an NPC, bail!
    end
end

---- Link handling code

local LINK_CODE = "addon:questie:offer";
local LINK_COLOR = CreateColorFromHexString("cff71d5ff");
local LINK_LENGTHS = LINK_CODE:len();

-- handles clicking on link
hooksecurefunc("SetItemRef", function(link)
    local linkType = link:sub(1, LINK_LENGTHS);
    if linkType == LINK_CODE then
        QuestieDebugOffer.ShowOffer(link)
    end
end);

---@param popupText string --@A string containing the lines of text to be displayed in the popup
---@param discordURL string --@A string containing the URL to the Questie Discord
---@param index number --@Integer containing the index of the DebugOffer in question
local function _CreateOfferFrame(popupText, discordURL, index)
    if openDebugWindows[index] == true then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - An offer is already open, not creating new frame")
        return
    end
    local debugFrame = CreateFrame("Frame", "QuestieDebugOfferFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    debugFrame:SetPoint("CENTER")
    debugFrame:SetMovable(true)
    debugFrame:EnableMouse(true)
    debugFrame:RegisterForDrag("LeftButton")
    debugFrame:SetScript("OnDragStart", debugFrame.StartMoving)
    debugFrame:SetScript("OnDragStop", debugFrame.StopMovingOrSizing)

    -- Dynamically set the height of the frame based on the number of lines of text
    local numLines = 0
    for _ in popupText:gmatch("\n") do
        numLines = numLines + 1
    end
    debugFrame:SetSize(300, numLines * 30 + 20)

    debugFrame.title = debugFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    debugFrame.title:SetPoint("TOP", 0, -15)
    debugFrame.title:SetText("|TInterface\\Addons\\Questie\\Icons\\startendstart.tga:16|t |cFFFED218" .. l10n("Questie Debug Info") .. "|r |TInterface\\Addons\\Questie\\Icons\\startendstart.tga:16|t")

    -- Create a single large edit box with no background
    debugFrame.dataEditBox = CreateFrame("EditBox", nil, debugFrame)
    debugFrame.dataEditBox:SetText(popupText)
    debugFrame.dataEditBox:SetFontObject(ChatFontNormal)
    debugFrame.dataEditBox:SetMultiLine(true)
    debugFrame.dataEditBox:SetPoint("TOP", debugFrame.title, "BOTTOM", 0, -10)
    debugFrame.dataEditBox:SetJustifyH("CENTER")
    debugFrame.dataEditBox:SetJustifyV("CENTER")
    debugFrame.dataEditBox:SetSize(270, 1) -- Height of a multiline EditBox is automatically adjusted
    debugFrame.dataEditBox:SetFocus()
    debugFrame.dataEditBox:SetScript("OnCursorChanged", function(self)
        self:SetText(popupText)
        self:HighlightText()
    end)
    debugFrame.dataEditBox:SetScript("OnEscapePressed", function()
        debugFrame:Hide();
        openDebugWindows[index] = false;
    end)

    debugFrame.discordText = debugFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    debugFrame.discordText:SetPoint("TOP", debugFrame.dataEditBox, "BOTTOM", 0, -15)
    debugFrame.discordText:SetText("|cFFAAAAAA" .. l10n("Please share this info with us on") .. "  |TInterface\\Addons\\Questie\\Icons\\discord.blp:16|t |cFF5765ECDiscord|r\n" .. "(" .. l10n("You can copy the data above") .. ")")

    debugFrame.discordLinkEditBox = CreateFrame("EditBox", nil, debugFrame, "InputBoxTemplate")
    debugFrame.discordLinkEditBox:SetSize(200, 20)
    debugFrame.discordLinkEditBox:SetPoint("TOP", debugFrame.discordText, "BOTTOM", 0, -10)
    debugFrame.discordLinkEditBox:SetAutoFocus(false)
    debugFrame.discordLinkEditBox:SetText(discordURL)

    debugFrame.dismissButton = CreateFrame("Button", nil, debugFrame, "UIPanelButtonTemplate")
    debugFrame.dismissButton:SetSize(80, 22)
    debugFrame.dismissButton:SetPoint("TOP", debugFrame.discordLinkEditBox, "BOTTOM", 0, -10)
    debugFrame.dismissButton:SetText(l10n("Dismiss"))
    debugFrame.dismissButton:SetScript("OnClick", function()
        debugFrame:Hide();
        openDebugWindows[index] = false;
    end)

    debugFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })

    openDebugWindows[index] = true
    debugFrame:Show()
end


-- generates dialog based on link clicked
---@param link string
function QuestieDebugOffer.ShowOffer(link)
    -- We also have access to the questie.dev domain (purchased by Logon)
    local discordURL = "https://discord.gg/Q6j4qByndw" -- redirect to #bug-redirect
    local i = tonumber(string.sub(link,21))
    local popupText = DebugInformation[i]

    _CreateOfferFrame(popupText, discordURL, i)
end
