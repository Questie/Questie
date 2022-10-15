-- Credits for the code below go to fusionpit https://github.com/fusionpit/QuestFrameFixer (released with MIT license)

---@class GossipFrameDailyMarker
local GossipFrameDailyMarker = QuestieLoader:CreateModule("GossipFrameDailyMarker")

local DAILY_AVAILABLE_QUEST_ICON_FILE_ID = GetFileIDFromPath("Interface\\GossipFrame\\DailyQuestIcon")
local REPEATABLE_QUEST_ICON_FILE_ID = GetFileIDFromPath("Interface\\GossipFrame\\DailyActiveQuestIcon")

local function _GetLineAndIconMaps()
    local lines = {}
    local icons = {}

    for i = 1, NUMGOSSIPBUTTONS do
        local titleLine = _G["GossipTitleButton" .. i]
        if (not titleLine) then
            break
        end
        tinsert(lines, titleLine)
        tinsert(icons, _G[titleLine:GetName() .. "GossipIcon"])
    end

    return lines, icons
end

local function _MarkDailyAndRepeatableQuests(lines, textures, ...)
    local lineIndex = 0
    for i=1, select("#", ...), 7 do
        lineIndex = lineIndex + 1
        local activeQuestLine = lines[lineIndex]
        if activeQuestLine:IsVisible() and activeQuestLine.type == "Available" then
            local _, _, _, frequency, isRepeatable = select(i, ...)
            if isRepeatable then
                local texture = textures[lineIndex]
                texture:SetTexture(REPEATABLE_QUEST_ICON_FILE_ID)
            elseif (frequency == LE_QUEST_FREQUENCY_DAILY or frequency == LE_QUEST_FREQUENCY_WEEKLY) then
                local texture = textures[lineIndex]
                texture:SetTexture(DAILY_AVAILABLE_QUEST_ICON_FILE_ID)
            end
        end
    end
end

local gossipTitleLines, gossipIconTextures = _GetLineAndIconMaps()

---This function changes the icons of available quests in the Gossip Frame
---Repeatable turn in quests get a blue ? and repeatable quests (like dailies) get a blue !
function GossipFrameDailyMarker.Mark()
    _MarkDailyAndRepeatableQuests(gossipTitleLines, gossipIconTextures, GetGossipAvailableQuests())
end
