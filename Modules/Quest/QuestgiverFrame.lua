---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

---@class QuestgiverFrame
local QuestgiverFrame = QuestieLoader:CreateModule("QuestgiverFrame")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

local _G = _G

-- This is the logic used for determining which icon we should show for a quest
-- This just determines the "type" of icon shown, not the exact icon file - see Questie.icons
---@param questID number
---@param isActive boolean
---@return string
local function determineAppropriateQuestIcon(questID, isActive)
    if questID == 0 then -- if we were fed a questID of 0, the ID bruteforce failed, abort
        if isActive == true then
            return Questie.icons["incomplete"]
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
    Questie.Debug(Questie.DEBUG_DEVELOP, "Updating Gossip frame 9.0-")
    local numAvailable = QuestieCompat.GetNumGossipAvailableQuests()
    local numActive = QuestieCompat.GetNumGossipActiveQuests()
    local availQuests = QuestieCompat.GetAvailableQuests()
    local activeQuests = QuestieCompat.GetActiveQuests()
    local index = 0 -- this variable tracks the GossipTitleButton we should be targeting for icon changes
    local questGiver = UnitGUID("npc")
    if numAvailable > 0 then
        for i = 1, numAvailable do
            index = index + 1
            local questId = availQuests[i].questID
            if questId == 0 then
                local questTitle = availQuests[i].title
                questId = QuestieDB.GetQuestIDFromName(questTitle, questGiver, true)
            end
            local gossipIcon = _G["GossipTitleButton" .. index .. "GossipIcon"]
            gossipIcon:SetTexture(determineAppropriateQuestIcon(questId, false))
        end
        -- each new section in a gossip frame has an offset of 1, so for instance, with 2 quests shown,
        -- 1 active 1 available, the available will be GossipTitleButton1 and the active will be GossipTitleButton3
        if numActive > 0 then index = index + 1 end
    end
    if numActive > 0 then
        for i = 1, numActive do
            index = index + 1
            local questTitle = activeQuests[i].title
            local questId = QuestieDB.GetQuestIDFromName(questTitle, questGiver, false)
            local gossipIcon = _G["GossipTitleButton" .. index .. "GossipIcon"]
            gossipIcon:SetTexture(determineAppropriateQuestIcon(questId, true))
        end
    end
end

---Updates quest-greeting icons using each button's list index and active/available status.
local function updateGreetingFrame()
    local npcGuid = UnitGUID("npc")
    QuestieCompat.ForEachQuestGreetingButton(function(button, icon)
        local isActive = button.isActive == 1
        local index = button:GetID()
        local count = isActive and GetNumActiveQuests() or GetNumAvailableQuests()
        -- An event can arrive before Blizzard releases buttons from the previous greeting.
        if index < 1 or index > count then
            return
        end
        local questID = QuestieCompat.GetQuestGreetingQuestID(index, isActive, npcGuid)
        icon:SetTexture(determineAppropriateQuestIcon(questID, isActive))
    end)
end

-- This function is called for QUEST_LOG_UPDATE events.
-- If that event fires, this function checks to see if a greeting dialog is currently open,
-- and if so it runs our icon pass again. This is because the greeting dialog may open
-- showing we've accepted a quest before Questie is even aware we're on it.
-- This also fixes race conditions with server lag delaying events.
function QuestgiverFrame.RecheckGreeting()
    local activeTitle, _ = GetActiveTitle(1)
    local availableTitle, _ = GetAvailableTitle(1)
    if activeTitle or availableTitle then
        Questie.Debug(Questie.DEBUG_DEVELOP, "Greeting Panel Refreshing. Active: " .. tostring(activeTitle) .. " Available: " .. tostring(availableTitle))
        QuestgiverFrame.GreetingMark()
    end
end

function QuestgiverFrame.GossipMark()
    if Questie.db.profile.enableQuestFrameIcons == true then
        if GossipAvailableQuestButtonMixin then -- This call is added with Dragonflight (10.0.0) API, use if available
            return -- This call is automatically hooked, no need to run a function
        else -- If DF API not available, use Shadowlands (9.0.0) method
            updateGossipFrame()
        end
    end
end

---Applies Questie's icons to populated greeting buttons once Questie is ready and icons are enabled.
function QuestgiverFrame.GreetingMark()
    if Questie.started and Questie.db.profile.enableQuestFrameIcons == true then
        updateGreetingFrame()
    end
end

-- XML keeps its original OnShow reference; quest-log updates call the global rebuild helper.
-- Run after both paths so Blizzard cannot overwrite our icons when its event handler runs last.
if QuestFrameGreetingPanel then
    QuestFrameGreetingPanel:HookScript("OnShow", QuestgiverFrame.GreetingMark)
end
if _G.QuestFrameGreetingPanel_OnShow then
    hooksecurefunc("QuestFrameGreetingPanel_OnShow", QuestgiverFrame.GreetingMark)
end

-- Gossip uses a separate list and its own button mixins.
if GossipAvailableQuestButtonMixin then
    local oldAvailableSetup = GossipAvailableQuestButtonMixin.Setup
    function GossipAvailableQuestButtonMixin:Setup(...)
        Questie.Debug(Questie.DEBUG_DEVELOP, "Updating GossipAvailableQuestButtonMixin frame 10.0+")
        oldAvailableSetup(self, ...)
        if (not Questie.started) then
            return
        end

        if self.GetElementData ~= nil and Questie.db.profile.enableQuestFrameIcons == true then
            local id = self.GetElementData().info.questID
            if id then
                self.Icon:SetTexture(determineAppropriateQuestIcon(id, false))
            else
                Questie.Error("Frame error! Missing Gossip line item quest ID. Please report this on Github or Discord!")
                Questie.Error("Questgiver for available quest is: " .. UnitGUID("npc"))
                Questie.Error("Client info is: " .. GetBuildInfo() .. "; " .. QuestieLib:GetAddonVersionString())
                return
            end
        end
    end

    local oldActiveSetup = GossipActiveQuestButtonMixin.Setup
    function GossipActiveQuestButtonMixin:Setup(...)
        Questie.Debug(Questie.DEBUG_DEVELOP, "Updating GossipActiveQuestButtonMixin frame 10.0+")
        oldActiveSetup(self, ...)
        if (not Questie.started) then
            return
        end

        if self.GetElementData ~= nil and Questie.db.profile.enableQuestFrameIcons == true then
            local id = self.GetElementData().info.questID
            if id then
                self.Icon:SetTexture(determineAppropriateQuestIcon(id, true))
            else
                Questie.Error("Frame error! Missing Gossip line item quest ID. Please report this on Github or Discord!")
                Questie.Error("Questgiver for active quest is: " .. UnitGUID("npc"))
                Questie.Error("Client info is: " .. GetBuildInfo() .. "; " .. QuestieLib:GetAddonVersionString())
                return
            end
        end
    end
end
