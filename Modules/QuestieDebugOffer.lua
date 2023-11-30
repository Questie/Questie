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

local gameType = ""
if Questie.IsWotlk then
    gameType = "Wrath"
elseif Questie.IsSoD then -- seasonal checks must be made before non-seasonal for that client, since IsEra resolves true in SoD
    gameType = "SoD"
elseif Questie.IsEra then
    gameType = "Era"
end

local _, playerRace = UnitRace(player)
local playerClass = UnitClassBase(player)

-- Missing itemID when looting

function QuestieDebugOffer.LootWindow()
    local lootInfo = GetLootInfo()

    for i=1, #lootInfo do
        local info = lootInfo[i]
        itemLink = GetLootSlotLink(i)
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

        -- Required checks: Item ID is valid, and item is NOT present in DB
        -- If in instance, item MUST be a queststarter OR a quest item
        -- If not in instance, no additional check required
        if itemID > 0 and itemPresentInDB == false and (((questItem == true or questStarts == true) and inInstance == true) or (inInstance == false)) then
            debugIndex = debugIndex + 1
            DebugInformation[debugIndex] = "Item not present in ItemDB!"
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n\n|cFFAAAAAAItem ID:|r " .. itemID
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAItem Name:|r " .. itemLink
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Item:|r " .. tostring(questItem)
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Starter:|r " .. tostring(questStarts)
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest ID:|r " .. questID
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAACharacter:|r Lvl " .. UnitLevel(player) .. " " .. string.upper(playerRace) .. " " .. playerClass
            local debugContainer = GetLootSourceInfo(i)
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAContainer:|r " .. debugContainer
            local mapID = GetBestMapForUnit(player)
            local pos = GetPlayerMapPosition(mapID, player);
            PosX = pos.x * 100
            PosY = pos.y * 100
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAPlayer Coords:|r  [" .. mapID .. "]  " .. format("(%.3f, %.3f)", PosX, PosY)
            local questLog = ""
            for k in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do questLog = k .. ", " .. questLog end
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuestLog:|r " .. questLog
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAClient:|r " .. GetBuildInfo() .. " " .. gameType
            DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuestie:|r " .. QuestieLib:GetAddonVersionString()
            Questie:Print(l10n("An item you just encountered is missing from the Questie database.") .. " " .. l10n("Would you like to help us fix it?") .. " |cff71d5ff|Haddon:questie:offer:" .. debugIndex .. "|h[" .. l10n("More Info") .. "]|h|r")

        end
    end
end

-- Missing questID when conversing
function QuestieDebugOffer.QuestDialog()
    local questID = GetQuestID() -- obtain quest ID from dialog
    if questID <= 0 or questID == nil then
        return -- invalid data from API, abandon offer attempt
    end
    if QuestieDB.QueryQuestSingle(questID, "name") == nil then -- if ID not in our DB
        debugIndex = debugIndex + 1
        local questTitle = GetTitleText()
        local questText = GetQuestText()
        local objectiveText = GetObjectiveText()
        local rewardText = GetRewardText()
        local rewardXP = GetRewardXP()

        DebugInformation[debugIndex] = "Quest in dialog not present in QuestDB!"
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n\n|cFFAAAAAAQuest ID:|r " .. tostring(questID)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Name:|r " .. tostring(questTitle)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Text:|r " .. tostring(questText)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAObjective Text:|r " .. tostring(objectiveText)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAReward Text:|r " .. tostring(rewardText)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAReward XP:|r " .. tostring(rewardXP)
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAACharacter:|r Lvl " .. tostring(UnitLevel(player)) .. " " .. string.upper(tostring(playerRace)) .. " " .. playerClass
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuestgiver:|r " .. tostring(UnitGUID(questnpc))
        local mapID = GetBestMapForUnit(player)
        local pos = GetPlayerMapPosition(mapID, player);
        if pos then PosX = pos.x * 100; PosY = pos.y * 100 end
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAPlayer Coords:|r  [" .. tostring(mapID) .. "]  " .. format("(%.3f, %.3f)", PosX, PosY)
        local questLog = ""
        for k in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do questLog = k .. ", " .. questLog end
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuestLog:|r " .. questLog
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAClient:|r " .. GetBuildInfo() .. " " .. gameType
        DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuestie:|r " .. QuestieLib:GetAddonVersionString()
        Questie:Print(l10n("A quest you just encountered is missing from the Questie database.") .. " " .. l10n("Would you like to help us fix it?") .. " |cff71d5ff|Haddon:questie:offer:" .. debugIndex .. "|h[" .. l10n("More Info") .. "]|h|r")
    end
end

-- Missing questID when tracking
---@param questID number
function QuestieDebugOffer.QuestTracking(questID) -- ID supplied by tracker during update
    if QuestieDB.QueryQuestSingle(questID, "name") == nil then -- if ID not in our DB
        for i=1, GetNumQuestLogEntries() do
            local questTitle, questLevel, suggestedGroup, _, _, _, frequency, questLogId = GetQuestLogTitle(i)
            local questText, objectiveText = GetQuestLogQuestText(i)
            if questID == questLogId then
                debugIndex = debugIndex + 1
                DebugInformation[debugIndex] = "Quest in tracker not present in QuestDB!"
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n\n|cFFAAAAAAQuest ID:|r " .. tostring(questLogId)
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Name:|r " .. tostring(questTitle)
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuest Text:|r " .. tostring(questText)
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAObjective Text:|r " .. tostring(objectiveText)
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAACharacter:|r Lvl " .. tostring(UnitLevel(player)) .. " " .. string.upper(playerRace) .. " " .. playerClass
                local mapID = GetBestMapForUnit(player)
                local pos = GetPlayerMapPosition(mapID, player);
                PosX = pos.x * 100
                PosY = pos.y * 100
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAPlayer Coords:|r  [" .. tostring(mapID) .. "]  " .. format("(%.3f, %.3f)", PosX, PosY)
                local questLog = ""
                for k in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do questLog = k .. ", " .. questLog end
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuestLog:|r " .. questLog
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAClient:|r " .. GetBuildInfo() .. " " .. gameType
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuestie:|r " .. QuestieLib:GetAddonVersionString()
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
    local inInstance, _ = IsInInstance()
    if inInstance == true then
        return -- temporary override for SoD launch to not prompt NPC debug offers inside instances at all, to prevent BFD spam
    end
    local targetGUID = UnitGUID(target)
    local unit_type = strsplit("-", tostring(targetGUID)) -- determine target type
    if unit_type == "Creature" then -- if target is an NPC
        local npcID = tonumber(targetGUID:match("-(%d+)-%x+$"), 10) -- obtain NPC ID
        if targetTimeout[npcID] == true then -- if target was already targeted recently
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieDebugOffer] - NPC targeted was targeted recently, ignoring")
            return
        else -- if target was NOT targeted recently
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
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAACharacter:|r Lvl " .. tostring(UnitLevel(player)) .. " " .. string.upper(playerRace) .. " " .. playerClass
                local mapID = GetBestMapForUnit(player)
                local pos = GetPlayerMapPosition(mapID, player);
                PosX = pos.x * 100
                PosY = pos.y * 100
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAPlayer Coords:|r  [" .. tostring(mapID) .. "]  " .. format("(%.3f, %.3f)", PosX, PosY)
                local questLog = ""
                for k in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do questLog = k .. ", " .. questLog end
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuestLog:|r " .. questLog
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAClient:|r " .. GetBuildInfo() .. " " .. gameType
                DebugInformation[debugIndex] = DebugInformation[debugIndex] .. "\n|cFFAAAAAAQuestie:|r " .. QuestieLib:GetAddonVersionString()
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
