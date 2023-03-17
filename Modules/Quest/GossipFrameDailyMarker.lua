---@class GossipFrameDailyMarker
local GossipFrameDailyMarker = QuestieLoader:CreateModule("GossipFrameDailyMarker")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

--------
-- GOSSIP FRAME BEGIN
--------

function GossipFrameDailyMarker.Mark()
    if GossipAvailableQuestButtonMixin then -- This call is added with Dragonflight (10.0.0) API, use if available
        return -- This call is automatically hooked, no need to run a function
    else -- If DF API not available, use Shadowlands (9.0.0) method
        -- todo
    end
end

-- 10.0.0 API 

local oldAvailableSetup = GossipAvailableQuestButtonMixin.Setup
function GossipAvailableQuestButtonMixin:Setup(...)
    oldAvailableSetup(self, ...)
    if self.GetElementData ~= nil then
        local id = self.GetElementData().info.questID
        if QuestieDB.IsPvPQuest(id) then
            self.Icon:SetTexture(Questie.icons["pvpquest"])
        elseif QuestieDB.IsActiveEventQuest(id) then
            self.Icon:SetTexture(Questie.icons["eventquest"])
        elseif QuestieDB.IsRepeatable(id) then
            self.Icon:SetTexture(Questie.icons["repeatable"])
        else
            self.Icon:SetTexture(Questie.icons["available"])
        end
    end
end

local oldActiveSetup = GossipActiveQuestButtonMixin.Setup
function GossipActiveQuestButtonMixin:Setup(...)
    oldActiveSetup(self, ...)
    if self.GetElementData ~= nil then
        local id = self.GetElementData().info.questID
        if QuestieDB.IsComplete(id) == 1 then
            if QuestieDB.IsPvPQuest(id) then
                self.Icon:SetTexture(Questie.icons["pvpquest_complete"])
            elseif QuestieDB.IsActiveEventQuest(id) then
                self.Icon:SetTexture(Questie.icons["eventquest_complete"])
            elseif QuestieDB.IsRepeatable(id) then
                self.Icon:SetTexture(Questie.icons["repeatable_complete"])
            else
                self.Icon:SetTexture(Questie.icons["complete"])
            end
        else
            self.Icon:SetTexture(Questie.icons["incomplete"])
        end
    end
end

-- 9.0.0 API

-- todo

-- END GOSSIP FRAME

-- GREETING FRAME LOGIC BEGINS (api independent)

local _G = _G
local tinsert = tinsert
local MAX_NUM_QUESTS = MAX_NUM_QUESTS

local titleLines = {}
local questIconTextures = {}
for i = 1, MAX_NUM_QUESTS do
    local titleLine = _G["QuestTitleButton" .. i]
    tinsert(titleLines, titleLine)
    tinsert(questIconTextures, _G[titleLine:GetName() .. "QuestIcon"])
end

QuestFrameGreetingPanel:HookScript(
    "OnShow",
    function()
        --    TODO:
        --  This entire section is a very hacky workaround (bruteforce) because Blizzard's classic API
        --  doesn't expose questIDs for any aspect of greeting frames, only for gossip frames. If this
        --  changes in the future, this entire function should be ditched to match gossip frame logic.
        --    -yttrium
        
        -- First, we get the interacting NPC's ID and grab their DB info locally
        local questgiverID = tonumber(UnitGUID("npc"):match("-(%d+)-%x+$"), 10)
        local questGiver = QuestieDB:GetNPC(questgiverID)
        
        -- Now we iterate through each line in the greeting frame
        for i, titleLine in ipairs(titleLines) do
            if (titleLine:IsVisible()) then
                local lineIcon = questIconTextures[i]
                
                -- determining if the current line is a "Current" quest or "Available" quest is important because
                -- we have to use different API calls to obtain their quest titles
                if (titleLine.isActive == 1) then
                
                    lineIcon:SetTexture(Questie.icons["incomplete"]) -- fallback icon in case any of the logic below fails
                    local title, isComplete = GetActiveTitle(titleLine:GetID()) -- obtain plaintext name of quest
        
                    -- iterate through every questEnds entry in our NPC's DB,
                    -- and check if the quest name matches this greeting frame entry
                    for k,questID in pairs(questGiver.questEnds) do
                        if (title == QuestieDB.QueryQuestSingle(questID, "name")) and (QuestieDB.IsDoable(questID)) then
                        -- the QuestieDB.IsDoable check is important to filter out identically named quests
                        
                            if QuestieDB.IsComplete(questID) == 1 then
                                if QuestieDB.IsPvPQuest(questID) then
                                    lineIcon:SetTexture(Questie.icons["pvpquest_complete"])
                                elseif QuestieDB.IsActiveEventQuest(questID) then
                                    lineIcon:SetTexture(Questie.icons["eventquest_complete"])
                                elseif QuestieDB.IsRepeatable(questID) then
                                    lineIcon:SetTexture(Questie.icons["repeatable_complete"])
                                else
                                    lineIcon:SetTexture(Questie.icons["complete"])
                                end
                            end
                        end
                    end
                    
                else
                
                    lineIcon:SetTexture(Questie.icons["available"]) -- fallback icon in case any of the logic below fails
                    local title, isComplete = GetAvailableTitle(titleLine:GetID())
                    
                    -- iterate through every questStarts entry in our NPC's DB,
                    -- and check if the quest name matches this greeting frame entry
                    for k,questID in pairs(questGiver.questStarts) do
                        if (title == QuestieDB.QueryQuestSingle(questID, "name")) and (QuestieDB.IsDoable(questID)) then
                        -- the QuestieDB.IsDoable check is important to filter out identically named quests
                        
                            if QuestieDB.IsPvPQuest(questID) then
                                lineIcon:SetTexture(Questie.icons["pvpquest"])
                            elseif QuestieDB.IsActiveEventQuest(questID) then
                                lineIcon:SetTexture(Questie.icons["eventquest"])
                            elseif QuestieDB.IsRepeatable(questID) then
                                lineIcon:SetTexture(Questie.icons["repeatable"])
                            end
                        end
                    end
                end
            end
        end
    end
)