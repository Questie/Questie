---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");
---@class QuestieMapUtils
QuestieMap.utils = QuestieMap.utils or {}

-- All the speed we can get is worth it.
local pairs = pairs

-- FrameLevel to be added for the icon based on its icon type.
-- ! Order of these in the table must be the same as values of the constants Questie.ICON_TYPE_* in Questie.lua
local DRAW_ORDER_BY_ICON_TYPE_LOOKUP = {
    0, -- ICON_TYPE_SLAY
    0, -- ICON_TYPE_LOOT
    0, -- ICON_TYPE_EVENT
    0, -- ICON_TYPE_OBJECT
    0, -- ICON_TYPE_TALK
    1, -- ICON_TYPE_AVAILABLE
    0, -- ICON_TYPE_AVAILABLE_GRAY
    3, -- ICON_TYPE_COMPLETE
    0, -- ICON_TYPE_GLOW
    2, -- ICON_TYPE_REPEATABLE
    3, -- ICON_TYPE_REPEATABLE_COMPLETE
    0, -- ICON_TYPE_INCOMPLETE
    2, -- ICON_TYPE_EVENTQUEST
    3, -- ICON_TYPE_EVENTQUEST_COMPLETE
    2, -- ICON_TYPE_PVPQUEST
    3, -- ICON_TYPE_PVPQUEST_COMPLETE
    0, -- ICON_TYPE_INTERACT
    3, -- ICON_TYPE_SODRUNE
    0, -- ICON_TYPE_MOUNT_UP
    0, -- ICON_TYPE_NODE_FISH
    0, -- ICON_TYPE_NODE_HERB
    0, -- ICON_TYPE_NODE_ORE
    0, -- ICON_TYPE_CHEST
    0, -- ICON_TYPE_PET_BATTLE
}

-- Maximum value used in the above table. (value, not key/index)
local MAX_DRAW_ORDER_BY_ICON_TYPE = 0
for _, v in pairs(DRAW_ORDER_BY_ICON_TYPE_LOOKUP) do
    if v > MAX_DRAW_ORDER_BY_ICON_TYPE then
        MAX_DRAW_ORDER_BY_ICON_TYPE = v
    end
end
-- Add +1 here to make code that uses the value more efficient.
MAX_DRAW_ORDER_BY_ICON_TYPE = MAX_DRAW_ORDER_BY_ICON_TYPE + 1

-- Framelevel that is infront of all aboves
local DRAW_ORDER_QUEST_COMPLETE = 2 * MAX_DRAW_ORDER_BY_ICON_TYPE

--- Set frame's frameLevel.
---@param frame IconFrame
function QuestieMap.utils.SetDrawOrder(frame)
    -- We need to add 2015, because of the regular WorldMapFrame.ScrollContainer which seems to start at 2000
    -- Add +1 to be above waypoint lines
    local frameLevel = 2016

    if frame.data and frame.data.Type == "complete" then
        -- Show quest finishers always infront of other icons.
        frameLevel = frameLevel + DRAW_ORDER_QUEST_COMPLETE
    else
        frameLevel = frameLevel
            + ((frame.data and DRAW_ORDER_BY_ICON_TYPE_LOOKUP[frame.data.Icon]) or 0) -- Get draw order for the icon type
            + ((frame.isManualIcon and 0) or MAX_DRAW_ORDER_BY_ICON_TYPE) -- This is to make sure that manual icons are always below other icons
    end

    -- Setting ParentFrame and FrameStrata are handled by HBD / WOW-UI code

    frame:SetFixedFrameLevel(false)
    frame:SetFrameLevel(frameLevel)
    frame:SetFixedFrameLevel(true) -- Stop framelevel changes when parent changes
end

function QuestieMap.utils.IsExplored(uiMapId, x, y)
    local IsExplored = false
    if uiMapId then
        local exploredAreaIDs = C_MapExplorationInfo.GetExploredAreaIDsAtPosition(uiMapId, CreateVector2D(x / 100, y / 100))
        if exploredAreaIDs then
            IsExplored = true -- Explored
        elseif (uiMapId == 1453) then
            IsExplored = true -- Stormwind
        elseif (uiMapId == 1455) then
            IsExplored = true -- Ironforge
        elseif (uiMapId == 1457) then
            IsExplored = true -- Darnassus
        elseif (uiMapId == 1458) then
            IsExplored = true -- Undercity
        elseif (uiMapId == 1454) then
            IsExplored = true -- Orgrimmar
        elseif (uiMapId == 1456) then
            IsExplored = true -- Thunder Bluff
        end
    end
    return IsExplored
end

function QuestieMap.utils.MapExplorationUpdate()
    for _, frameList in pairs(QuestieMap.questIdFrames) do
        for _, frameName in pairs(frameList) do
            local frame = _G[frameName]
            if (frame and frame.x and frame.y and frame.UiMapID and frame.hidden) then
                if (QuestieMap.utils.IsExplored(frame.UiMapID, frame.x, frame.y)) then
                    frame:FakeShow()
                end
            end
        end
    end
end

--- Rescale a single icon
---@param frameRef string|IconFrame @The global name/iconRef of the icon frame, e.g. "QuestieFrame1"
---@param mapScale number? @Scale value for the final size of the Icon
function QuestieMap.utils.RescaleIcon(frameRef, mapScale)
    local frame = frameRef;
    local iconScale = mapScale or 1
    if type(frameRef) == "string" then
        frame = _G[frameRef];
    end
    if frame and frame.data then
        if frame.data.GetIconScale then
            frame.data.IconScale = frame.data:GetIconScale();
            local scale
            if frame.miniMapIcon then
                -- Use globalMiniMapTownsfolkScale for townsfolk icons, globalMiniMapScale for quest icons
                local scaleProfile = frame.isManualIcon and Questie.db.profile.globalMiniMapTownsfolkScale or Questie.db.profile.globalMiniMapScale
                scale = 16 * (frame.data.IconScale or 1) * (scaleProfile or 0.7);
            else
                --? If you ever chanage this logic, make sure you change the logic in QuestieMap:ProcessQueue() too!
                local scaleProfile = frame.isManualIcon and Questie.db.profile.globalTownsfolkScale or Questie.db.profile.globalScale
                scale = (16 * (frame.data.IconScale or 1) * (scaleProfile or 0.7)) * iconScale;
            end

            if scale > 1 then
                frame:SetSize(scale, scale)
                frame:GlowUpdate()
            end
        else
            Questie.Error("A frame is lacking the GetIconScale function for resizing!", frame.data.Id);
        end
    end
end
