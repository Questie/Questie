---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");
---@class QuestieMapUtils
QuestieMap.utils = QuestieMap.utils or {}

local ZOOM_MODIFIER = 1;

-- All the speed we can get is worth it.
local pairs = pairs

---@param frame IconFrame
function QuestieMap.utils:SetDrawOrder(frame)
    -- We need to add 2015, because of the regular WorldMapFrame.ScrollContainer which seems to start at 2000
    if frame.miniMapIcon then
        local frameLevel = Minimap:GetFrameLevel() + 2015
        if frame.isManualIcon then
            frameLevel = frameLevel - 1 -- This is to make sure that manual icons are always below other icons
        end
        local frameStrata = Minimap:GetFrameStrata()
        frame:SetParent(Minimap)
        frame:SetFrameStrata(frameStrata)
        frame:SetFrameLevel(frameLevel)
    else
        local frameLevel = WorldMapFrame:GetFrameLevel() + 2015
        if frame.isManualIcon then
            frameLevel = frameLevel - 1 -- This is to make sure that manual icons are always below other icons
        end
        local frameStrata = WorldMapFrame:GetFrameStrata()
        frame:SetParent(WorldMapFrame)
        frame:SetFrameStrata(frameStrata)
        frame:SetFrameLevel(frameLevel)
    end

    -- Draw layer is between -8 and 7, please leave some number above so we don't paint ourselves into a corner...
    -- These are sorted by order of most common occurrence to reduce if checks; it's less readable but more performant with so many icons
    if frame.data then
        if frame.data.Icon == Questie.ICON_TYPE_AVAILABLE then
            frame.texture:SetDrawLayer("OVERLAY", 5)
        elseif frame.data.Icon == Questie.ICON_TYPE_REPEATABLE then
            frame.texture:SetDrawLayer("OVERLAY", 4)
        elseif frame.data.Icon == Questie.ICON_TYPE_EVENTQUEST then
            frame.texture:SetDrawLayer("OVERLAY", 4)
        elseif frame.data.Icon == Questie.ICON_TYPE_PVPQUEST then
            frame.texture:SetDrawLayer("OVERLAY", 4)
        elseif frame.data.Icon == Questie.ICON_TYPE_COMPLETE then
            frame.texture:SetDrawLayer("OVERLAY", 6)
        elseif frame.data.Icon == Questie.ICON_TYPE_REPEATABLE_COMPLETE then
            frame.texture:SetDrawLayer("OVERLAY", 6)
        elseif frame.data.Icon == Questie.ICON_TYPE_EVENTQUEST_COMPLETE then
            frame.texture:SetDrawLayer("OVERLAY", 6)
        elseif frame.data.Icon == Questie.ICON_TYPE_PVPQUEST_COMPLETE then
            frame.texture:SetDrawLayer("OVERLAY", 6)
        elseif frame.data.Icon == Questie.ICON_TYPE_SODRUNE then
            frame.texture:SetDrawLayer("OVERLAY", 6)
        else
            frame.texture:SetDrawLayer("OVERLAY", 0)
        end
    else
        frame.texture:SetDrawLayer("OVERLAY", 0)
    end
end

function QuestieMap.utils:IsExplored(uiMapId, x, y)
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
---@param mapScale number? @Scale value for the final size of the Icon
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
                -- Use globalMiniMapTownsfolkScale for townsfolk icons, globalMiniMapScale for quest icons
                local scaleProfile = frame.isManualIcon and Questie.db.profile.globalMiniMapTownsfolkScale or Questie.db.profile.globalMiniMapScale
                scale = 16 * (frame.data.IconScale or 1) * (scaleProfile or 0.7);
            else
                --? If you ever chanage this logic, make sure you change the logic in QuestieMap:ProcessQueue() too!
                local scaleProfile = frame.isManualIcon and Questie.db.profile.globalTownsfolkScale or Questie.db.profile.globalScale
                scale = (16 * (frame.data.IconScale or 1) * (scaleProfile or 0.7)) * iconScale;
            end

            if scale > 1 then
                frame:SetSize(scale * ZOOM_MODIFIER, scale * ZOOM_MODIFIER);
            end
        else
            Questie:Error("A frame is lacking the GetIconScale function for resizing!", frame.data.Id);
        end
    end
end
