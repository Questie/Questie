---@class RelationRenderers
local RelationRenderers = QuestieLoader:CreateModule("RelationRenderers")

---@type MapProvider
local MapProvider = QuestieLoader:ImportModule("MapProvider")
---@type WaypointMapProvider
local WaypointMapProvider = QuestieLoader:ImportModule("WaypointMapProvider")

local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

-- Pin Mixin
local RelationPinMixin = QuestieLoader:ImportModule("RelationPinMixin")
---@type WaypointPinMixin
local WaypointPinMixin = QuestieLoader:ImportModule("WaypointPinMixin")

---@type PinTemplates
local PinTemplates = QuestieLoader:ImportModule("PinTemplates")

local map
local waypointMap
--- -@type TexturePool
local texPool

local AVAILABLE_ICON_PATH = QuestieLib.AddonPath .. "Icons\\available.blp"
local LOOT_ICON_PATH = QuestieLib.AddonPath .. "Icons\\loot.blp"
local OBJECT_ICON_PATH = QuestieLib.AddonPath .. "Icons\\object.blp"
local AVAILABLE_LOOT_ICON_PATH = QuestieLib.AddonPath .. "Icons\\lootAvailable.blp"
local COMPLETE_ICON_PATH = QuestieLib.AddonPath .. "Icons\\complete.tga"

local function Initialize()
    map = MapProvider:GetMap()
    waypointMap = WaypointMapProvider:GetMap()
    texPool = TexturePool
end
C_Timer.After(0, Initialize)

---@param self RelationPoint
function RelationRenderers.Draw(self)
    ---@type MapIconFrame
    local Pin = map:AcquirePin(PinTemplates.MapPinTemplate, self, RelationPinMixin)

    -- local highlightTexture = texPool:Acquire()
    -- local highlightAlpha = 0.4
    -- highlightTexture:SetParent(Pin)
    -- highlightTexture:SetPoint("CENTER");
    -- highlightTexture:SetTexture(COMPLETE_ICON_PATH)
    -- highlightTexture:SetAlpha(highlightAlpha)
    -- highlightTexture:SetDrawLayer("HIGHLIGHT")
    -- highlightTexture:SetBlendMode("ADD")
    -- highlightTexture:Hide()
    -- Pin.textures[#Pin.textures + 1] = highlightTexture

    local baseTexture = texPool:Acquire();
    baseTexture:SetParent(Pin)
    baseTexture:SetPoint("CENTER");

    local frameLevelType = "PIN_FRAME_LEVEL_AREA_POI_AVAILABLE"

    if Pin.data.majorityType == "npcFinisher" then
        baseTexture:SetTexture(COMPLETE_ICON_PATH)

        -- highlightTexture:SetTexture(COMPLETE_ICON_PATH)
        Pin.highlightTexture:SetTexture(COMPLETE_ICON_PATH)
        frameLevelType = "PIN_FRAME_LEVEL_AREA_POI_COMPLETE"
        Pin:SetSize(10, 15)
    elseif Pin.data.majorityType == "objectFinisher" then
        baseTexture:SetTexture(COMPLETE_ICON_PATH)

        --? Is this even good...?
        -- The object icon for the complete icon
        local objectTexture = texPool:Acquire();
        objectTexture:SetParent(Pin)
        objectTexture:SetPoint("CENTER", 5, -5);
        objectTexture:SetTexture(OBJECT_ICON_PATH)
        objectTexture:SetSize(12, 12)
        objectTexture:Show();
        Pin.textures[#Pin.textures + 1] = objectTexture

        Pin.highlightTexture:SetTexture(COMPLETE_ICON_PATH)
        frameLevelType = "PIN_FRAME_LEVEL_AREA_POI_COMPLETE"
        Pin:SetSize(10, 15)
        -- elseif Pin.data.majorityType == "item" then
        --     -- The loot bag
        --     baseTexture:SetTexture(LOOT_ICON_PATH)

        --     -- The available icon for loot bag
        --     local availableTexture = texPool:Acquire();
        --     availableTexture:SetParent(Pin)
        --     availableTexture:SetPoint("CENTER");
        --     availableTexture:SetTexture(AVAILABLE_LOOT_ICON_PATH)
        --     availableTexture:Show();
        --     Pin.textures[#Pin.textures + 1] = availableTexture

        --     highlightTexture:SetTexture(LOOT_ICON_PATH) ---TODO: This has not been tested to see if it looks good.
    else
        baseTexture:SetTexture(AVAILABLE_ICON_PATH)
        Pin.textures[#Pin.textures + 1] = baseTexture

        Pin.highlightTexture:SetTexture(AVAILABLE_ICON_PATH)
        Pin:SetSize(8, 15)
    end
    baseTexture:Show();
    Pin.textures[#Pin.textures + 1] = baseTexture

    Pin:UseFrameLevelType(frameLevelType, self.frameLevel)
    Pin:SetPosition(self.x * 0.01, self.y * 0.01) -- Also runs ApplyFrameLevel
    -- Pin:ApplyFrameLevel()
    -- Pin:Show();
end


--- This is a debug function which is used to draw a small dot, for example, the corners of the waypoint rectangle
---comment
---@param self table
---@param vertexColor Color?
---@return unknown
function RelationRenderers.DrawDebugDot(self, vertexColor)
    local Pin = map:AcquirePin(PinTemplates.MapPinTemplate, self)
    local frameLevelType = "PIN_FRAME_LEVEL_AREA_POI_WAYPOINTS"
    Pin:SetSize(2, 2)

    local baseTexture = texPool:Acquire();
    baseTexture:SetParent(Pin)
    baseTexture:SetPoint("CENTER");
    baseTexture:SetTexture(QuestieLib.AddonPath .. "Icons\\masks\\circlemask.blp")
    baseTexture:SetSize(2, 2)
    baseTexture:Show();
    if vertexColor and #vertexColor >= 3 then
        baseTexture:SetVertexColor(vertexColor[1], vertexColor[2], vertexColor[3], vertexColor[4] or 1)
    end
    Pin.textures[#Pin.textures + 1] = baseTexture

    Pin:UseFrameLevelType(frameLevelType, self.frameLevel)
    Pin:SetPosition(self.x * 0.01, self.y * 0.01) -- Also runs ApplyFrameLevel
    Pin:Show();
    return Pin
end

---comment
---@param self WaypointPoint
function RelationRenderers.DrawWaypoint(self)
    --? Do not mixin the waypoint pin here, we mix it in during frameCreation
    local Pin = waypointMap:AcquirePin(PinTemplates.WaypointPinTemplate, self)
    -- print(self.sX, self.sY, self.eX, self.eY)

    -- --* Calculate the rectangle corners
    -- --? Information can be found: https://stackoverflow.com/questions/1936934/turn-a-line-into-a-rectangle
    -- local dx = self.eX - self.sX
    -- local dy = self.eY - self.sY
    -- --? Is this ever needed? : Logon
    -- -- Normalize direction if necessary
    -- -- if (dx < 0) then
    -- -- 	dx,dy = -dx,-dy;
    -- -- end
    -- local lineLength = sqrt(dx * dx + dy * dy)
    -- dx = dx / lineLength
    -- dy = dy / lineLength
    -- local thickness = (0.0012 / 4) * defaultLineDataMap.thickness
    -- local px = thickness * (-dy)
    -- local py = thickness * dx
    -- Pin.lineCornerPoints = {
    --     { x = self.sX + px, y = self.sY + py }, -- x1, y1
    --     { x = self.eX + px, y = self.eY + py }, -- x2, y2
    --     { x = self.eX - px, y = self.eY - py }, -- x3, y3
    --     { x = self.sX - px, y = self.sY - py }, -- x4, y4
    -- }
    Pin:DrawLine(self.uiMapId, self.sX, self.sY, self.eX, self.eY, self.defaultLineDataMap)

    --? This draws each waypoint as a rectangle, do not remove this code it is extreamly useful for debugging
    if true == false then
        --? Start and end dot
        RelationRenderers.DrawDebugDot({ uiMapId = self.uiMapId, x = self.sX * 100, y = self.sY * 100, frameLevel = 100, iconData = {}, id = self.id })
        RelationRenderers.DrawDebugDot({ uiMapId = self.uiMapId, x = self.eX * 100, y = self.eY * 100, frameLevel = 100, iconData = {}, id = self.id })
        --? Corner dots
        local vertexColor = { math.random(), math.random(), math.random(), 1 }
        RelationRenderers.DrawDebugDot({ uiMapId = self.uiMapId, x = self.lineCornerPoints[1].x * 100, y = self.lineCornerPoints[1].y * 100, frameLevel = 95, iconData = {},
            id = self.id }, vertexColor)
        RelationRenderers.DrawDebugDot({ uiMapId = self.uiMapId, x = self.lineCornerPoints[2].x * 100, y = self.lineCornerPoints[2].y * 100, frameLevel = 95, iconData = {},
            id = self.id }, vertexColor)
        RelationRenderers.DrawDebugDot({ uiMapId = self.uiMapId, x = self.lineCornerPoints[3].x * 100, y = self.lineCornerPoints[3].y * 100, frameLevel = 95, iconData = {},
            id = self.id }, vertexColor)
        RelationRenderers.DrawDebugDot({ uiMapId = self.uiMapId, x = self.lineCornerPoints[4].x * 100, y = self.lineCornerPoints[4].y * 100, frameLevel = 95, iconData = {},
            id = self.id }, vertexColor)
    end

    Pin:Show();
end
