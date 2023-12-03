---@class QuestieDebugOffer
local QuestieDebugOffer = QuestieLoader:CreateModule("QuestieDebugOffer")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---@type QuestLogCache
local QuestLogCache = QuestieLoader:CreateModule("QuestLogCache")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local DebugInformation = {} -- stores text of debug data dump per session
local debugIndex = 0 -- current debug index, used so we can still retrieve info from previous offers
local openDebugWindows = {} -- determines if existing debug window is already open, prevents duplicates

local GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition
local PosX = 0
local PosY = 0
local itemLink
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
    210771, -- Waylaid Supplies 10-25
    211315, -- Waylaid Supplies 10-25
    211316, -- Waylaid Supplies 10-25
    211317, -- Waylaid Supplies 10-25
    211318, -- Waylaid Supplies 10-25
    211319, -- Waylaid Supplies 10-25
    211320, -- Waylaid Supplies 10-25
    211321, -- Waylaid Supplies 10-25
    211322, -- Waylaid Supplies 10-25
    211323, -- Waylaid Supplies 10-25
    211324, -- Waylaid Supplies 10-25
    211325, -- Waylaid Supplies 10-25
    211326, -- Waylaid Supplies 10-25
    211327, -- Waylaid Supplies 10-25
    211328, -- Waylaid Supplies 10-25
    211329, -- Waylaid Supplies 10-25
    211330, -- Waylaid Supplies 10-25
    211331, -- Waylaid Supplies 10-25
    211332, -- Waylaid Supplies 10-25
    211819, -- Waylaid Supplies 10-25
    211820, -- Waylaid Supplies 10-25
    211821, -- Waylaid Supplies 10-25
    211822, -- Waylaid Supplies 10-25
    211823, -- Waylaid Supplies 10-25
    211824, -- Waylaid Supplies 10-25
    211825, -- Waylaid Supplies 10-25
    211826, -- Waylaid Supplies 10-25
    211827, -- Waylaid Supplies 10-25
    211828, -- Waylaid Supplies 10-25
    211829, -- Waylaid Supplies 10-25
    211830, -- Waylaid Supplies 10-25
    211831, -- Waylaid Supplies 10-25
    211832, -- Waylaid Supplies 10-25
    211833, -- Waylaid Supplies 10-25
    211834, -- Waylaid Supplies 10-25
    211835, -- Waylaid Supplies 10-25
    211836, -- Waylaid Supplies 10-25
    211837, -- Waylaid Supplies 10-25
    211838, -- Waylaid Supplies 10-25
    211933, -- Waylaid Supplies 10-25
    211934, -- Waylaid Supplies 10-25
    211935, -- Waylaid Supplies 10-25
    203753, -- Mage encoded spell notes
    203752, -- Mage encoded spell notes
    208754, -- Mage encoded spell notes
    208854, -- Mage encoded spell notes
    203751, -- Mage encoded spell notes
    209028, -- Mage encoded spell notes
    210655, -- Mage encoded spell notes
    210179, -- Mage encoded spell notes
    211786, -- Mage encoded scrolls
    211785, -- Mage encoded scrolls
    211787, -- Mage encoded scrolls
    211780, -- Mage encoded scrolls
    211784, -- Mage encoded scrolls
    211854, -- Mage encoded scrolls
    211855, -- Mage encoded scrolls
    211853, -- Mage encoded scrolls
}

local itemWhitelist = {
    208609, -- glade flower for druid living seed
    206469, -- prairie flower for druid living seed
}

-- determines whether to ignore an item
---@param itemID integer
---@param itemPresentInDB boolean
---@param questItem boolean
---@param questStarts boolean
---@param inInstance boolean
local function filterItem(itemID, itemPresentInDB, questItem, questStarts, inInstance)
    -- return true if we should create debug offer, false if not
    if itemID <= 0 or itemPresentInDB == true then -- if itemID invalid or item is in the DB, don't bother going further
        return false
    else
        local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
        itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
        expacID, setID, isCraftingReagent = GetItemInfo(itemID)

        if tContains(itemWhitelist, itemID) then -- if item is in our whitelist, we want it no matter what
            return true
        end
        if UnitLevel(player) < minLevelForDebugOffers then -- if player level is below our threshold, ignore it
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - Player does not meet level threshold for debug offers, ignoring")
            return false
        end
        if tContains(itemBlacklist, itemID) then -- if item is in our blacklist, ignore it
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - Item is in item blacklist, ignoring")
            return false
        end
        if questItem == true or questStarts == true then -- if we know it's a quest item, we want it no matter what (barring blacklist)
            return true
        end
        if inInstance == true then -- if we're in an instance, and it isn't a quest item, ignore it
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - Player looting item is in instance, ignoring")
            return false
        end
        if bindType ~= 1 then -- if item is not BoP, then ignore it
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - Item is not BoP, ignoring")
            return false
        end
    end
    return true
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

    for i=1, #lootInfo do
        local info = lootInfo[i]
        itemLink = GetLootSlotLink(i)
        local debugContainer = GetLootSourceInfo(i) -- happens early in case the rest of the code is so slow that the container closes before we're ready
        local itemID = 0
        if itemLink then
            itemID = GetItemInfoFromHyperlink(GetLootSlotLink(i))
        end

        local questItem = false
        local questStarts = false
        local questID = 0
        if info.isQuestItem then
            questItem = true
        end
        if info.questId then
            questStarts = true
            questID = info.questId
        end

        local itemPresentInDB = false
        if itemID > 0 and QuestieDB.QueryItemSingle(itemID, "name") then
            itemPresentInDB = true
        end

        local inInstance, _ = IsInInstance()

        if filterItem(itemID, itemPresentInDB, questItem, questStarts, inInstance) == true then
            debugIndex = debugIndex + 1
            DebugInformation[debugIndex] = "Item not present in ItemDB!"
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n\n|cFFAAAAAAItem ID:|r " .. itemID
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAItem Name:|r " .. itemLink
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Item:|r " .. tostring(questItem)
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Starter:|r " .. tostring(questStarts)
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest ID:|r " .. questID
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAContainer:|r " .. debugContainer
            DebugInformation[debugIndex] = _AppendUniversalText(DebugInformation[debugIndex])
            Questie:Print(l10n("An item you just encountered is missing from the Questie database.") .. " " .. l10n("Would you like to help us fix it?") .. " |cff71d5ff|Haddon:questie:offer:" .. debugIndex .. "|h[" .. l10n("More Info") .. "]|h|r")

        end
    end
end

-- Missing questID when conversing
function QuestieDebugOffer.QuestDialog()
    local questID = GetQuestID() -- obtain quest ID from dialog
    if questID <= 0 or questID == nil then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - Invalid quest ID from API, ignoring")
        return -- invalid data from API, abandon offer attempt
    end
    if UnitLevel(player) < minLevelForDebugOffers then -- if player level is below our threshold, ignore it
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - Player does not meet level threshold for debug offers, ignoring")
        return
    end
    if QuestieDB.QueryQuestSingle(questID, "name") == nil then -- if ID not in our DB
        debugIndex = debugIndex + 1
        local questTitle = GetTitleText()
        local questText = GetQuestText()
        local objectiveText = GetObjectiveText()
        local rewardText = GetRewardText()
        local rewardXP = GetRewardXP()

        local filteredQuestText = questText:gsub(GetUnitName(player), "<playername>") -- strip out player name from quest text
        local filteredObjectiveText = objectiveText:gsub(GetUnitName(player), "<playername>") -- strip out player name from objective text
        local filteredRewardText = rewardText:gsub(GetUnitName(player), "<playername>") -- strip out player name from reward text

        DebugInformation[debugIndex] = "Quest in dialog not present in QuestDB!"
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n\n|cFFAAAAAAQuest ID:|r " .. tostring(questID)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Name:|r " .. tostring(questTitle)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Text:|r " .. tostring(filteredQuestText)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAObjective Text:|r " .. tostring(filteredObjectiveText)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAReward Text:|r " .. tostring(filteredRewardText)
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
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - Player does not meet level threshold for debug offers, ignoring")
        return
    end
    if QuestieDB.QueryQuestSingle(questID, "name") == nil then -- if ID not in our DB
        for i=1, GetNumQuestLogEntries() do
            local questTitle, questLevel, suggestedGroup, _, _, _, frequency, questLogId = GetQuestLogTitle(i)
            local questText, objectiveText = GetQuestLogQuestText(i)

            local filteredQuestText = questText:gsub(GetUnitName(player), "<playername>") -- strip out player name from quest text
            local filteredObjectiveText = objectiveText:gsub(GetUnitName(player), "<playername>") -- strip out player name from objective text
            if questID == questLogId then
                debugIndex = debugIndex + 1
                DebugInformation[debugIndex] = "Quest in tracker not present in QuestDB!"
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n\n|cFFAAAAAAQuest ID:|r " .. tostring(questLogId)
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Name:|r " .. tostring(questTitle)
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Text:|r " .. tostring(filteredQuestText)
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAObjective Text:|r " .. tostring(filteredObjectiveText)
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
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - Player does not meet level threshold for debug offers, ignoring")
        return
    end
    local inInstance, _ = IsInInstance()
    if inInstance == true then -- temporary override for SoD launch to not prompt NPC debug offers inside instances at all, to prevent BFD spam
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - Player targeting NPC is in instance, ignoring")
        return
    end
    local targetGUID = UnitGUID(target)
    local unit_type = strsplit("-", tostring(targetGUID)) -- determine target type
    if unit_type == "Creature" then -- if target is an NPC
        local npcID = tonumber(targetGUID:match("-(%d+)-%x+$"), 10) -- obtain NPC ID
        if targetTimeout[npcID] == true then -- if target was already targeted recently
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - Targeted NPC was targeted recently, ignoring")
            return
        else -- if target was NOT targeted recently
            if tContains(npcBlacklist, npcID) then -- if NPC is in our blacklist, ignore it
                Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - Targeted NPC is in NPC blacklist, ignoring")
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
    debugFrame.discordText:SetText("|cFFAAAAAA" .. l10n("Please share this info with us on") .. "  |TInterface\\Addons\\Questie\\Icons\\discord.blp:16|t |cFF5765ECDiscord|r\n" .. "(" .. l10n("You can copy the data above" .. ")"))

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
    -- The questie.dev domain was purchased by Logon
    local discordURL = "https://discord.gg/txNSuwyBQ8" -- redirect to #bug-reports
    if Questie.IsWotlk then
        discordURL = "https://questie.dev/wotlk" -- redirect to #wotlk-bug-reports
    elseif Questie.IsSoD then
        discordURL = "https://questie.dev/sod" -- redirect to #sod-bug-reports
    elseif Questie.IsClassic then
        discordURL = "https://questie.dev/era" -- redirect to #era-bug-reports
    end
    local i = tonumber(string.sub(link,21))
    local popupText = DebugInformation[i]

    _CreateOfferFrame(popupText, discordURL, i)
end