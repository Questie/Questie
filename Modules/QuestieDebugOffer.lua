---@class QuestieDebugOffer
local QuestieDebugOffer = QuestieLoader:CreateModule("QuestieDebugOffer")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---@class QuestiePlayer
local QuestiePlayer = QuestieLoader:CreateModule("QuestiePlayer");

---@class QuestLogCache
local QuestLogCache = QuestieLoader:CreateModule("QuestLogCache")


local AceGUI = LibStub("AceGUI-3.0")

local hook
local _E

local DebugInformation = "Nothing here!"

local GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition
local PosX = 0
local PosY = 0
local itemLink

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

        if itemID > 0 and itemPresentInDB == false then
            DebugInformation = "Item not present in ItemDB!"
            DebugInformation = DebugInformation .. "\n\n|cFFAAAAAAItem ID:|r " .. itemID .. "\n|cFFAAAAAAItem Name:|r " .. itemLink
            DebugInformation = DebugInformation .. "\n|cFFAAAAAAQuest Item:|r " .. tostring(questItem)
            DebugInformation = DebugInformation .. "\n|cFFAAAAAAQuest Starter:|r " .. tostring(questStarts)
            DebugInformation = DebugInformation .. "\n|cFFAAAAAAQuest ID:|r " .. questID
            local _, playerrace = UnitRace("player")
            DebugInformation = DebugInformation .. "\n|cFFAAAAAACharacter:|r Lvl " .. UnitLevel("player") .. " " .. string.upper(playerrace) .. " " .. UnitClassBase("player")
            local debugContainer = GetLootSourceInfo(i)
            DebugInformation = DebugInformation .. "\n|cFFAAAAAAContainer:|r " .. debugContainer
            local mapID = GetBestMapForUnit("player")
            local pos = GetPlayerMapPosition(mapID, "player");
            PosX = pos.x * 100
            PosY = pos.y * 100
            DebugInformation = DebugInformation .. "\n|cFFAAAAAACoordinates:|r  [" .. mapID .. "]  " .. format("(%.3f, %.3f)", PosX, PosY)
            local questLog = ""
            for k in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do questLog = k .. ", " .. questLog end
            DebugInformation = DebugInformation .. "\n|cFFAAAAAAQuestLog:|r " .. questLog
            local gameType = ""
            if Questie.IsWotlk then
                gameType = "Wrath"
            elseif Questie.IsSoD then
                gameType = "SoD"
            elseif Questie.IsEra then
                gameType = "Era"
            end
            DebugInformation = DebugInformation .. "\n|cFFAAAAAAClient:|r " .. GetBuildInfo() .. " " .. gameType
            DebugInformation = DebugInformation .. "\n|cFFAAAAAAQuestie:|r " .. QuestieLib:GetAddonVersionString()

            --print(DebugInformation)
            Questie:Print("An item you just encountered is missing from the Questie database. Would you like to help us fix it? |cff71d5ff|Haddon:questie:offer|h[More Info]|h|r")

        end
    end
end

-- Missing questID when conversing
function QuestieDebugOffer.QuestDialog()
    local questID = GetQuestID()
    if QuestieDB.QueryQuestSingle(questID, "name") == nil then
        local questTitle = GetTitleText()
        local questText = GetQuestText()
        local objectiveText = GetObjectiveText()
        local rewardText = GetRewardText()
        local rewardXP = GetRewardXP()

        DebugInformation = "Quest in dialog not present in QuestDB!"
        DebugInformation = DebugInformation .. "\n\n|cFFAAAAAAQuest ID:|r " .. tostring(questID) .. "\n|cFFAAAAAAQuest Name:|r " .. tostring(questTitle)
        DebugInformation = DebugInformation .. "\n|cFFAAAAAAQuest Text:|r " .. tostring(questText)
        DebugInformation = DebugInformation .. "\n|cFFAAAAAAObjective Text:|r " .. tostring(objectiveText)
        DebugInformation = DebugInformation .. "\n|cFFAAAAAAReward Text:|r " .. tostring(rewardText)
        DebugInformation = DebugInformation .. "\n|cFFAAAAAAReward XP:|r " .. tostring(rewardXP)
        local _, playerrace = UnitRace("player")
        DebugInformation = DebugInformation .. "\n|cFFAAAAAACharacter:|r Lvl " .. tostring(UnitLevel("player")) .. " " .. string.upper(tostring(playerrace)) .. " " .. tostring(UnitClassBase("player"))
        DebugInformation = DebugInformation .. "\n|cFFAAAAAAQuestgiver:|r " .. tostring(UnitGUID("questnpc"))
        local mapID = GetBestMapForUnit("player")
        local pos = GetPlayerMapPosition(mapID, "player");
        if pos then PosX = pos.x * 100; PosY = pos.y * 100 end
        DebugInformation = DebugInformation .. "\n|cFFAAAAAACoordinates:|r  [" .. tostring(mapID) .. "]  " .. format("(%.3f, %.3f)", PosX, PosY)
        local questLog = ""
        for k in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do questLog = k .. ", " .. questLog end
        DebugInformation = DebugInformation .. "\n|cFFAAAAAAQuestLog:|r " .. questLog
        local gameType = ""
        if Questie.IsWotlk then
            gameType = "Wrath"
        elseif Questie.IsSoD then
            gameType = "SoD"
        elseif Questie.IsEra then
            gameType = "Era"
        end
        DebugInformation = DebugInformation .. "\n|cFFAAAAAAClient:|r " .. GetBuildInfo() .. " " .. gameType
        DebugInformation = DebugInformation .. "\n|cFFAAAAAAQuestie:|r " .. QuestieLib:GetAddonVersionString()
        Questie:Print("A quest you just encountered is missing from the Questie database. Would you like to help us fix it? |cff71d5ff|Haddon:questie:offer|h[More Info]|h|r")
    end
end

-- Missing questID when tracking
---@param questID number
function QuestieDebugOffer.QuestTracking(questID)
    if QuestieDB.QueryQuestSingle(questID, "name") == nil or true then
        for i=1, GetNumQuestLogEntries() do
            local questTitle, questLevel, suggestedGroup, _, _, _, frequency, questlogid = GetQuestLogTitle(i)
            if questID == questlogid then
                local questText, objectiveText = GetQuestLogQuestText(i)
                DebugInformation = "Quest in tracker not present in QuestDB!"
                DebugInformation = DebugInformation .. "\n\n|cFFAAAAAAQuest ID:|r " .. tostring(questlogid) .. "\n|cFFAAAAAAQuest Name:|r " .. tostring(questTitle)
                DebugInformation = DebugInformation .. "\n|cFFAAAAAAQuest Text:|r " .. tostring(questText)
                DebugInformation = DebugInformation .. "\n|cFFAAAAAAObjective Text:|r " .. tostring(objectiveText)
                local _, playerrace = UnitRace("player")
                DebugInformation = DebugInformation .. "\n|cFFAAAAAACharacter:|r Lvl " .. tostring(UnitLevel("player")) .. " " .. string.upper(playerrace) .. " " .. tostring(UnitClassBase("player"))
                local mapID = GetBestMapForUnit("player")
                local pos = GetPlayerMapPosition(mapID, "player");
                PosX = pos.x * 100
                PosY = pos.y * 100
                DebugInformation = DebugInformation .. "\n|cFFAAAAAACoordinates:|r  [" .. tostring(mapID) .. "]  " .. format("(%.3f, %.3f)", PosX, PosY)
                local questLog = ""
                for k in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do questLog = k .. ", " .. questLog end
                DebugInformation = DebugInformation .. "\n|cFFAAAAAAQuestLog:|r " .. questLog
                local gameType = ""
                if Questie.IsWotlk then
                    gameType = "Wrath"
                elseif Questie.IsSoD then
                    gameType = "SoD"
                elseif Questie.IsEra then
                    gameType = "Era"
                end
                DebugInformation = DebugInformation .. "\n|cFFAAAAAAClient:|r " .. GetBuildInfo() .. " " .. gameType
                DebugInformation = DebugInformation .. "\n|cFFAAAAAAQuestie:|r " .. QuestieLib:GetAddonVersionString()
                Questie:Print("A quest in your quest log is missing from the Questie database and can't be tracked. Would you like to help us fix it? |cff71d5ff|Haddon:questie:offer|h[More Info]|h|r")
            end
        end
    end
end

-- Link handling code

local LINK_CODE = "addon:questie:offer";
local LINK_COLOR = CreateColorFromHexString("cff71d5ff");
local LINK_LENGTHS = LINK_CODE:len();

hooksecurefunc("SetItemRef", function(link)
    local linkType = link:sub(1, LINK_LENGTHS);
    if linkType == LINK_CODE then
        QuestieDebugOffer.ShowOffer()
    end
end);

function QuestieDebugOffer.ShowOffer()
    local discordURL = "https://discord.gg/txNSuwyBQ8"
    if Questie.IsWotlk then
        discordURL = "https://discord.gg/7qyRwwNncS"
    elseif Questie.IsSoD then
        discordURL = "https://discord.gg/Gbm9NZE43a"
    elseif Questie.IsClassic then
        discordURL = "https://discord.gg/KAzNSy5D9C"
    end
    StaticPopupDialogs["QUESTIE_DEBUGOFFER"] = {
        text = "|TInterface\\Addons\\Questie\\Icons\\startendstart.tga:16|t |cFFFED218Questie Debug Info|r |TInterface\\Addons\\Questie\\Icons\\startendstart.tga:16|t\n\n" .. DebugInformation .. "\n\n|cFFAAAAAAPlease screenshot this info\nand share it with us on  |TInterface\\Addons\\Questie\\Icons\\discord.blp:16|t |cFF5765ECDiscord|r:|r",
        button1 = "Dismiss",
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        hasEditBox = true,
        EditBoxOnTextChanged = function (self)
            self.editBox:SetText(discordURL)
            self.editBox:HighlightText()
        end,
        OnShow = function (self, data)
            self.editBox:SetText(discordURL)
            self.editBox:SetWidth(200)
            self.editBox:HighlightText()
        end,
    }
    StaticPopup_Show("QUESTIE_DEBUGOFFER")
end