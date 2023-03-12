-- Credits for the code below go to fusionpit https://github.com/fusionpit/QuestFrameFixer (released with MIT license)

---@class GossipFrameDailyMarker
local GossipFrameDailyMarker = QuestieLoader:CreateModule("GossipFrameDailyMarker")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

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

---This function changes the icons of available quests in the Gossip Frame
---Repeatable turn in quests get a blue ? and repeatable quests (like dailies) get a blue !
function GossipFrameDailyMarker.Mark()
    --print("test1")
    if GossipAvailableQuestButtonMixin then -- This call is added with Dragonflight (10.0.0) API, use if available
        --print("test2")
        return -- This call is automatically hooked, no need to run a function
    else -- If DF API not available, use Shadowlands (9.0.0) method
        --print("test3")
        _MarkDailyAndRepeatableQuests(gossipTitleLines, gossipIconTextures, QuestieCompat.GetAvailableQuests())
    end
end
