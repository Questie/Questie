-- Credits for the code below go to fusionpit https://github.com/fusionpit/QuestFrameFixer (released with MIT license)

---@class GossipFrameDailyMarker
local GossipFrameDailyMarker = QuestieLoader:CreateModule("GossipFrameDailyMarker")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local oldAvailableSetup = GossipAvailableQuestButtonMixin.Setup
function GossipAvailableQuestButtonMixin:Setup(...)
    oldAvailableSetup(self, ...)
    if self.GetElementData ~= nil then
        local info = self.GetElementData().info
        if info == nil then return end
        local id = info.questID
        if QuestieDB.isTrivial(id) then
            self.Icon:SetTexture(ICON_TYPE_AVAILABLE_GRAY)
        elseif QuestieDB.IsPvPQuest(id) then
            self.Icon:SetTexture(ICON_TYPE_PVPQUEST)
        elseif QuestieDB.IsActiveEventQuest(id) then
            self.Icon:SetTexture(ICON_TYPE_EVENTQUEST)
        elseif QuestieDB.IsRepeatable(id) then
            self.Icon:SetTexture(ICON_TYPE_REPEATABLE)
        else
            self.Icon:SetTexture(ICON_TYPE_AVAILABLE)
        end
    end
end

local oldActiveSetup = GossipActiveQuestButtonMixin.Setup
function GossipActiveQuestButtonMixin:Setup(...)
    oldActiveSetup(self, ...)
    if self.GetElementData ~= nil then
        local info = self.GetElementData().info
        if info == nil then return end
        local id = info.questID
        if QuestieDB.IsComplete(id) == 1 then
            if QuestieDB.IsPvPQuest(id) then
                self.Icon:SetTexture(ICON_TYPE_PVPQUEST_COMPLETE)
            elseif QuestieDB.IsActiveEventQuest(id) then
                self.Icon:SetTexture(ICON_TYPE_EVENTQUEST_COMPLETE)
            elseif QuestieDB.IsRepeatable(id) then
                self.Icon:SetTexture(ICON_TYPE_REPEATABLE_COMPLETE)
            else
                self.Icon:SetTexture(ICON_TYPE_COMPLETE)
            end
        else
            self.Icon:SetTexture(ICON_TYPE_INCOMPLETE)
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
