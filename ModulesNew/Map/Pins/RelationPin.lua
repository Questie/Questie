---@class RelationPinMixin : BasePinMixin
local RelationPinMixin = QuestieLoader:CreateModule("RelationPinMixin")

----- System Imports -----
---@type MapEventBus
local MapEventBus = QuestieLoader:ImportModule("MapEventBus")
---@type SystemEventBus
local SystemEventBus = QuestieLoader:ImportModule("SystemEventBus")
---@type MapCoordinates
local MapCoordinates = QuestieLoader:ImportModule("MapCoordinates")

----- Imports -----
local QuestieQuest = QuestieLoader:ImportModule("QQuest")
local MapTooltip = QuestieLoader:ImportModule("MapTooltip")

local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
local l10n = QuestieLoader:ImportModule("l10n")
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
local QuestieEVent = QuestieLoader:ImportModule("QuestieEvent")


--Up value
local questieTooltip = QuestieTooltip --Localize the tooltip

function RelationPinMixin:GetType()
    return "RelationPin"
end

function RelationPinMixin:OnAcquired() -- the arguments here are anything that are passed into AcquirePin after the pinTemplate
    local uiMapId = self.data and self.data.uiMapId and self.data.uiMapId or nil
    local normalScale = (self:GetIconScale(uiMapId) or 1)
    local zoomedScale = (normalScale * 1.2)

    self:SetScalingLimits(1, normalScale, zoomedScale)
end

---Get the IconScale for the pin, use UiMapId to get the scale for a specific map
---@param uiMapId UiMapId?
---@return number
function RelationPinMixin:GetIconScale(uiMapId)
    --? Scale the icon based on what mapType it is
    local mapTypeScale = 1
    if uiMapId then
        local mapData = MapCoordinates.MapInfo[uiMapId]
        if mapData.mapType == 1 then -- World
            mapTypeScale = 0.8
        elseif mapData.mapType == 2 then -- Continent
            mapTypeScale = 0.9
        end
    end
    return ((Questie.db.global.availableScale or 1.2) * (Questie.db.global.globalScale or 0.6)) * mapTypeScale
end

--! There are some fucky wucky going on with the Mouse clicking if zoomed out, but fixing when required
function RelationPinMixin:OnClick(button)
    -- Override in your mixin, called when this pin is clicked
    --Make the polygon click-through
    print("Available", button)
    DevTools_Dump(self.data)
end

function RelationPinMixin:OnMouseUp()
    print("Available", button)
    DevTools_Dump(self.data)
end

--! End fucky wucky, read above

function RelationPinMixin:OnTooltip()
    local data = self.data
    for i = 1, #data.id do
        local id = data.id[i]
        local idType = data.type[i]
        local object
        if idType == "npcFinisher" or idType == "npc" then
            object = QuestieQuest.Show.NPC[id]
        elseif idType == "objectFinisher" or idType == "object" then
            object = QuestieQuest.Show.GameObject[id]
        elseif idType == "item" then
            object = QuestieQuest.Show.Item[id]
        end
        MapTooltip.SimpleAvailableTooltip(id, idType, object)
    end
end


function RelationPinMixin:OnMouseEnter()
    -- print("enter2")
    -- Override in your mixin, called when this pin is clicked

    -- local firstLine = true
    -- local shift = IsShiftKeyDown()

    -- local tooltipFunction = function()
    --     local data = self.data
    --     MapEventBus:Fire(MapEventBus.events.RESET_TOOLTIP)
    --     -- for index, id in pairs(data.id) do
    --     --     local giverType = data.type[index]
    --     --     MapEventBus:Fire(MapEventBus.events.ADD_AVAILABLE_TOOLTIP(id, giverType))
    --     -- end
    --     self:OnTooltip()
    --     MapEventBus:Fire(MapEventBus.events.DRAW_TOOLTIP)
    -- end

    -- SystemEventBus:ObjectRegisterRepeating(questieTooltip, SystemEventBus.events.MODIFIER_PRESSED_SHIFT, tooltipFunction)
    -- SystemEventBus:ObjectRegisterRepeating(questieTooltip, SystemEventBus.events.MODIFIER_RELEASED_SHIFT, tooltipFunction)
    -- tooltipFunction()

    -- questieTooltip:ClearLines()
    -- questieTooltip:SetOwner(WorldMapFrame, "ANCHOR_CURSOR")
    -- for index, id in pairs(data.id) do
    --     local giverType = data.type[index]
    --     local giverName = ""
    --     if giverType == "npc" then
    --         giverName = QuestieDB.QueryNPCSingle(id, "name")
    --     elseif giverType == "object" then
    --         giverName = QuestieDB.QueryObjectSingle(id, "name")
    --     elseif giverType == "item" then
    --         giverName = QuestieDB.QueryItemSingle(id, "name")
    --     end

    --     if shift and (not firstLine) then
    --         -- Spacer between NPCs
    --         questieTooltip:AddLine("             ")
    --     end
    --     if (firstLine and not shift) then
    --         questieTooltip:AddDoubleLine(giverName, "(" .. l10n('Hold Shift') .. ")", 0.2, 1, 0.2, 0.43, 0.43, 0.43)
    --         firstLine = false
    --     elseif (firstLine and shift) then
    --         questieTooltip:AddLine(giverName, 0.2, 1, 0.2)
    --         firstLine = false
    --     else
    --         questieTooltip:AddLine(giverName, 0.2, 1, 0.2)
    --     end
    --     for questId, _ in pairs(data.availableData[index]) do
    --         local questName, questType = getType(questId)
    --         local reputationReward = QuestieDB.QueryQuestSingle(questId, "reputationReward")
    --         local rewardString = questType
    --         if (not shift) and reputationReward and next(reputationReward) then
    --             -- questieTooltip:AddDoubleLine(REPUTATION_ICON_TEXTURE .. " " .. questData.title, rewardString, 1, 1, 1, 1, 1, 0)
    --             questieTooltip:AddDoubleLine(REPUTATION_ICON_TEXTURE .. " " .. questName, rewardString, 1, 1, 1, 1, 1, 0)
    --         else
    --             if shift then
    --                 questieTooltip:AddDoubleLine(questName, rewardString, 1, 1, 1, 1, 1, 0)
    --             else
    --                 -- We use a transparent icon because this eases setting the correct margin
    --                 -- questieTooltip:AddDoubleLine(TRANSPARENT_ICON_TEXTURE .. " " .. questData.title, rewardString, 1, 1, 1, 1, 1, 0)
    --                 questieTooltip:AddDoubleLine(TRANSPARENT_ICON_TEXTURE .. " " ..questName, rewardString, 1, 1, 1, 1, 1, 0)
    --             end
    --         end
    --         count = count + 1
    --     end
    -- end
    -- for index, questData in pairs(self.data.availableData) do
    --     local giver =
    --     for questId, _ in pairs(questData) do
    --         local questName = QuestieDB.QueryQuestSingle(questId, "name")
    --         if shift and (not firstLine) then
    --             -- Spacer between NPCs
    --             questieTooltip:AddLine("             ")
    --         end
    --         if (firstLine and not shift) then
    --             questieTooltip:AddDoubleLine(questName, "(".. l10n('Hold Shift')..")", 0.2, 1, 0.2, 0.43, 0.43, 0.43)
    --             firstLine = false
    --         elseif (firstLine and shift) then
    --             questieTooltip:AddLine(questName, 0.2, 1, 0.2)
    --             firstLine = false
    --         else
    --             questieTooltip:AddLine(questName, 0.2, 1, 0.2)
    --         end
    --         count = count + 1
    --     end
    -- end

    -- questieTooltip:AddLine("Total Givers:" .. tostring(count))
    -- questieTooltip:Show()
end

function RelationPinMixin:OnMouseLeave()
    -- Override in your mixin, called when the mouse leaves this pin
    -- print("leave2")
    questieTooltip:Hide()
end
