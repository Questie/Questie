---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");
---@class QuestieMapUtils
QuestieMap.utils = QuestieMap.utils or {}

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");

local HBD = LibStub("HereBeDragonsQuestie-2.0")

local ZOOM_MODIFIER = 1;

-- All the speed we can get is worth it.
local tinsert = table.insert
local pairs = pairs

function QuestieMap.utils:SetDrawOrder(frame)
    -- This is all fixes to always be on top of HandyNotes notes Let the frame level wars begin.
    -- HandyNotes uses GetFrameLevel + 6, so we use +7
    if frame.miniMapIcon then
        local frameLevel = Minimap:GetFrameLevel() + 7
        local frameStrata = Minimap:GetFrameStrata()
        frame:SetParent(Minimap)
        frame:SetFrameStrata(frameStrata)
        frame:SetFrameLevel(frameLevel)
    else
        local frameLevel = WorldMapFrame:GetFrameLevel() + 7
        local frameStrata = WorldMapFrame:GetFrameStrata()
        frame:SetParent(WorldMapFrame)
        frame:SetFrameStrata(frameStrata)
        frame:SetFrameLevel(frameLevel)
    end

    -- Draw layer is between -8 and 7, please leave some number above so we don't paint ourselves into a corner...
    if frame.data then
        if frame.data.Icon == ICON_TYPE_REPEATABLE then
            frame.texture:SetDrawLayer("OVERLAY", 4)
        elseif frame.data.Icon == ICON_TYPE_AVAILABLE then
            frame.texture:SetDrawLayer("OVERLAY", 5)
        elseif frame.data.Icon == ICON_TYPE_COMPLETE then
            frame.texture:SetDrawLayer("OVERLAY", 6)
        else
            frame.texture:SetDrawLayer("OVERLAY", 0)
        end
    else
        frame.texture:SetDrawLayer("OVERLAY", 0)
    end
end

---@param points table<number, Point> @{{x=0, y=0}, ...}
---@return number x, number y @Center coordinates
function QuestieMap.utils.CenterPoint(points)
    local x, y = 0, 0
    local count = #points
    for i=1, count do
        local point = points[i]
        x = x + point.x
        y = y + point.y
    end
    x = x / count
    y = y / count
    return x, y
end

---@param points table<number, Point> @A pointlist with {worldX=0, worldY=0, UiMapID=0, distance=0}
---@param rangeR number @Range of the hotzones.
---@param count number @Optional, used to allow more notes if far away from the quest giver.
---@return table<number, table<number, Point>> @A table of hotzones
function QuestieMap.utils:CalcHotzones(points, rangeR, count)
--    if(points == nil) then return nil; end

    local hotzones = {}
    local pointsCount = #points

    if pointsCount == 1 then
        -- This is execution shortcut to skip loop in case table size == 1

        hotzones = { { points[1] } }
        return hotzones
    end

    --If count isn't set we want to distance clustering to still work,
    --to simplify the logic we just use a big number.
    if not count then
        count = 99999;
    end

    local useMovingRange = (count > 100)

    local range = rangeR or 100;

    for j=1, pointsCount do
        local point = points[j]
        if not point.touched then
            point.touched = true
            local notes = { point }

            --We want things further away to be clustered more
            local movingRange = range
            if useMovingRange and (point.distance > 1000) then
                movingRange = movingRange * (point.distance/1000);
            end

            local aX, aY = point.worldX, point.worldY

            for i=j+1, pointsCount do
                local point2 = points[i]
                --We only want to cluster icons that are on the same map.
                if (not point2.touched) and (point.UiMapID == point2.UiMapID) then
                    local distance = QuestieLib:Euclid(aX, aY, point2.worldX, point2.worldY)
                    if (distance < movingRange) then
                        point2.touched = true
                        notes[#notes+1] = point2
                    end
                end
            end
            hotzones[#hotzones+1] = notes
        end
    end
    return hotzones
end

function QuestieMap.utils:IsExplored(uiMapId, x, y)
    local IsExplored = false
    if uiMapId then
        local exploredAreaIDs =
            C_MapExplorationInfo.GetExploredAreaIDsAtPosition(uiMapId,
                                                              CreateVector2D(
                                                                  x / 100,
                                                                  y / 100))
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

function QuestieMap.utils:MapExplorationUpdate()
    for _, frameList in pairs(QuestieMap.questIdFrames) do
        for _, frameName in pairs(frameList) do
            local frame = _G[frameName]
            if (frame and frame.x and frame.y and frame.UiMapID and frame.hidden) then
                if (QuestieMap.utils:IsExplored(frame.UiMapID, frame.x, frame.y)) then
                    frame:FakeShow()
                end
            end
        end
    end
end

--- Rescale a single icon
---@param frameRef string|IconFrame @The global name/iconRef of the icon frame, e.g. "QuestieFrame1"
---@param mapScale number @Scale value for the final size of the Icon
function QuestieMap.utils:RescaleIcon(frameRef, mapScale)
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
                scale = 16 * (frame.data.IconScale or 1) * (Questie.db.global.globalMiniMapScale or 0.7);
            else
                --? If you ever chanage this logic, make sure you change the logic in QuestieMap:ProcessQueue() too!
                scale = (16 * (frame.data.IconScale or 1) * (Questie.db.global.globalScale or 0.7)) * iconScale;
            end

            if scale > 1 then
                frame:SetSize(scale * ZOOM_MODIFIER, scale * ZOOM_MODIFIER);
            end
        else
            Questie:Error("A frame is lacking the GetIconScale function for resizing!", frame.data.Id);
        end
    end
end
