---@class QuestgiverFrame
local QuestgiverFrame = QuestieLoader:CreateModule("QuestgiverFrame")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

local _G = _G
local tinsert = tinsert
local MAX_NUM_QUESTS = MAX_NUM_QUESTS

-- This is the logic used for determining which icon we should show for a quest
-- This just determines the "type" of icon shown, not the exact icon file - see Questie.icons
---@param questID number
---@param isActive boolean
---@return string
local function determineAppropriateQuestIcon(questID, isActive)
    if questID == 0 then -- if we were fed a questID of 0, the ID bruteforce failed, abort
        if isActive == true then
            return Questie.icons["complete"]
        else
            return Questie.icons["available"]
        end
    end
    local icon = Questie.icons["available"] -- fallback icon in case any of the logic below fails
    if isActive == true then
        icon = Questie.icons["incomplete"] -- fallback icon in case any of the logic below fails
        if QuestieDB.IsComplete(questID) == 1 then
            if QuestieDB.IsPvPQuest(questID) then
                icon = Questie.icons["pvpquest_complete"]
            elseif QuestieDB.IsActiveEventQuest(questID) then
                icon = Questie.icons["eventquest_complete"]
            elseif QuestieDB.IsRepeatable(questID) then
                icon = Questie.icons["repeatable_complete"]
            else
                icon = Questie.icons["complete"]
            end
        end
    else
        if QuestieDB.IsPvPQuest(questID) then
            icon = Questie.icons["pvpquest"]
        elseif QuestieDB.IsActiveEventQuest(questID) then
            icon = Questie.icons["eventquest"]
        elseif QuestieDB.IsRepeatable(questID) then
            icon = Questie.icons["repeatable"]
        end
    end
    return icon
end

-- 9.0.0 API GOSSIP
local function updateGossipFrame()
    local numAvailable = GetNumGossipAvailableQuests()
    local numActive = GetNumGossipActiveQuests()
    local availQuests = {QuestieCompat.GetAvailableQuests()}
    local activeQuests = {QuestieCompat.GetActiveQuests()}
    local index = 0 -- this variable tracks the GossipTitleButton we should be targeting for icon changes
    local questgiver = UnitGUID("npc")
    if numAvailable > 0 then
        for i=1, numAvailable do
            index = index + 1
            -- GetGossipAvailableQuests() returns 7 individual values per quest entry...
            -- so we have to filter out to every 7th value, starting with 1, 8, 15, etc
            local questIndex = (1 + ((i - 1) * 7))
            local questname = availQuests[questIndex]
            local questid = QuestieDB.GetQuestIDFromName(questname, questgiver, true)
            local gossipIcon = _G["GossipTitleButton" .. index .. "GossipIcon"]
            gossipIcon:SetTexture(determineAppropriateQuestIcon(questid, false))
        end
        -- each new section in a gossip frame has an offset of 1, so for instance, with 2 quests shown,
        -- 1 active 1 available, the available will be GossipTitleButton1 and the active will be GossipTitleButton3
        if numActive > 0 then index = index + 1 end
    end
    if numActive > 0 then
        for i=1, numActive do
            index = index + 1
            -- GetGossipActiveQuests() returns 6 individual values per quest entry...
            -- so we have to filter out to every 6th value, starting with 1, 7, 13, etc
            local questIndex = (1 + ((i - 1) * 6))
            local questname = activeQuests[questIndex]
            local questid = QuestieDB.GetQuestIDFromName(questname, questgiver, false)
            local gossipIcon = _G["GossipTitleButton" .. index .. "GossipIcon"]
            gossipIcon:SetTexture(determineAppropriateQuestIcon(questid, true))
        end
    end
end

-- GREETING FRAMES (API independent)
local function updateGreetingFrame()
    local titleLines = {}
    local questIconTextures = {}
    local questgiver = UnitGUID("npc")
    for i = 1, MAX_NUM_QUESTS do
        local titleLine = _G["QuestTitleButton" .. i]
        if titleLine then
            tinsert(titleLines, titleLine)
            tinsert(questIconTextures, _G[titleLine:GetName() .. "QuestIcon"])
        else
            Questie:Error("Frame error! Could not obtain Greeting's QuestTitleButton object. Please report this on Github or Discord!")
            Questie:Error("Questgiver is: " .. questgiver)
            Questie:Error("Client info is: " .. GetBuildInfo() .. "; " .. QuestieLib:GetAddonVersionString())
            return
        end
    end
    for i, titleLine in ipairs(titleLines) do
        if (titleLine:IsVisible()) then
            local lineIcon = questIconTextures[i]
            -- determining if the current line is a "Current" quest or "Available" quest is important
            -- because we have to use different API calls to obtain their quest titles
            if (titleLine.isActive == 1) then
                lineIcon:SetTexture(Questie.icons["incomplete"]) -- fallback icon in case any of the logic below fails
                local title = GetActiveTitle(titleLine:GetID()) -- obtain plaintext name of quest
                local questID = QuestieDB.GetQuestIDFromName(title, questgiver, false)
                local icon = determineAppropriateQuestIcon(questID, true)
                lineIcon:SetTexture(icon)
            else
                lineIcon:SetTexture(Questie.icons["available"]) -- fallback icon in case any of the logic below fails
                local title = GetAvailableTitle(titleLine:GetID())
                local questID = QuestieDB.GetQuestIDFromName(title, questgiver, true)
                local icon = determineAppropriateQuestIcon(questID, false)
                lineIcon:SetTexture(icon)
            end
        end
    end
end

function QuestgiverFrame.GossipMark()
    if Questie.db.char.enableQuestFrameIcons == true then
        if GossipAvailableQuestButtonMixin then -- This call is added with Dragonflight (10.0.0) API, use if available
            return -- This call is automatically hooked, no need to run a function
        else -- If DF API not available, use Shadowlands (9.0.0) method
            updateGossipFrame()
        end
    end
end

function QuestgiverFrame.GreetingMark()
    if Questie.db.char.enableQuestFrameIcons == true then
        updateGreetingFrame()
    end
end

-- 10.0.0 API GOSSIP
-- Boy, this code is clean... these DF Gossip APIs sure are great!
-- What a shame that the greeting API hasn't been touched in two decades.
if GossipAvailableQuestButtonMixin then
    local oldAvailableSetup = GossipAvailableQuestButtonMixin.Setup
    function GossipAvailableQuestButtonMixin:Setup(...)
        oldAvailableSetup(self, ...)
        if self.GetElementData ~= nil and Questie.db.char.enableQuestFrameIcons == true then
            local id = self.GetElementData().info.questID
            if id then
                self.Icon:SetTexture(determineAppropriateQuestIcon(id, false))
            else
                Questie:Error("Frame error! Missing Gossip line item quest ID. Please report this on Github or Discord!")
                Questie:Error("Questgiver for available quest is: " .. UnitGUID("npc"))
                Questie:Error("Client info is: " .. GetBuildInfo() .. "; " .. QuestieLib:GetAddonVersionString())
                return
            end
        end
    end

    local oldActiveSetup = GossipActiveQuestButtonMixin.Setup
    function GossipActiveQuestButtonMixin:Setup(...)
        oldActiveSetup(self, ...)
        if self.GetElementData ~= nil and Questie.db.char.enableQuestFrameIcons == true then
            local id = self.GetElementData().info.questID
            if id then
                self.Icon:SetTexture(determineAppropriateQuestIcon(id, true))
            else
                Questie:Error("Frame error! Missing Gossip line item quest ID. Please report this on Github or Discord!")
                Questie:Error("Questgiver for active quest is: " .. UnitGUID("npc"))
                Questie:Error("Client info is: " .. GetBuildInfo() .. "; " .. QuestieLib:GetAddonVersionString())
                return
            end
        end
    end
end
