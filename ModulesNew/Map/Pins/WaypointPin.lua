---@class WaypointPinMixin : BasePinMixin, Button
---@field data WaypointPoint
---@field lineCornerPoints {[1]: XYPoint, [2]: XYPoint, [3]: XYPoint, [4]: XYPoint} @The points of the line corners, values between 0-1 is expected
local WaypointPinMixin = QuestieLoader:CreateModule("WaypointPinMixin")

----- System Imports -----
---@type MapEventBus
local MapEventBus = QuestieLoader:ImportModule("MapEventBus")
---@type SystemEventBus
local SystemEventBus = QuestieLoader:ImportModule("SystemEventBus")
---@type MapCoordinates
local MapCoordinates = QuestieLoader:ImportModule("MapCoordinates")

---@type FramePoolWaypoint
local FramePoolWaypoint = QuestieLoader:ImportModule("FramePoolWaypoint")

---@type PinTemplates
local PinTemplates = QuestieLoader:ImportModule("PinTemplates")

----- Imports -----
local QuestieQuest = QuestieLoader:ImportModule("QQuest")
local MapTooltip = QuestieLoader:ImportModule("MapTooltip")

local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
local l10n = QuestieLoader:ImportModule("l10n")
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
local QuestieEVent = QuestieLoader:ImportModule("QuestieEvent")

---@type WaypointAnimationHelper
local WaypointAnimationHelper = QuestieLoader("WaypointAnimationHelper")


--Up value
local questieTooltip = QuestieTooltip --Localize the tooltip
local wipe = wipe
local ScrollContainer = WorldMapFrame.ScrollContainer;

function WaypointPinMixin:GetType()
    return "WaypointPin"
end

---Get the IconScale for the pin, use UiMapId to get the scale for a specific map
---@param uiMapId UiMapId?
---@return number
function WaypointPinMixin:GetIconScale(uiMapId)
    -- It should always be 1
    return 1
end

function WaypointPinMixin:DrawLine(UiMapID, sX, sY, eX, eY, Linedata, maskTextures)
    -- Override in your mixin, called when this pin is being acquired by a data provider but before its added to the map
    local lineData = Linedata or {}
    local dx, dy = eX - sX, eY - sY;
    -- Normalize direction if necessary
    if (dx < 0) then
        dx, dy = -dx, -dy;
    end
    local cx, cy = (sX + eX) / 2, (sY + eY) / 2;
    local width, height = WorldMapFrame:GetCanvas():GetSize();
    width = width
    height = height
    local minX = math.min(sX, eX);
    local minY = math.min(sY, eY);
    local framePosX, framePosY = minX * width, minY * height
    -- self:ClearAllPoints()
    --self:SetParent(WorldMapFrame:GetCanvas())
    --self:SetPosition(minX+(windowX/2), minY+(windowY/2))
    --self:SetPosition(cx, cy)
    if (not self.minimapPin) then
        --pcall(self.SetPosition, self, cx, cy);
        self:SetPosition(cx, cy)
    end
    local fWidth, fHeight = dx * width, dy * height;
    self:SetSize(fWidth, fHeight)
    self.framePosX = framePosX
    self.framePosY = framePosY

    -- self.lineTexture = self.lineTexture or FramePoolWaypoint.LinePool:Acquire();
    local lineTexture = FramePoolWaypoint.LinePool:Acquire();
    -- lineTexture:ClearAllPoints()
    lineTexture:SetParent(self)
    local startX = sX * width
    local startY = sY * height -- We do by / -100 due to using the top left point
    local endX = eX * width
    local endY = eY * height

    --Due to thickness being used in linemixin we instead just use defaultThickness
    lineTexture.defaultThickness = lineData.thickness or 5;
    lineTexture.color = { r = lineData.r or 1, g = lineData.g or 1, b = lineData.b or 1, a = lineData.a or 0.6 }
    if (maskTextures) then
        for _, maskTexture in pairs(maskTextures) do
            lineTexture:AddMaskTexture(maskTexture)
        end
        lineTexture.maskTextures = maskTextures
    end
    lineTexture:SetVertexColor(lineTexture.color.r, lineTexture.color.g, lineTexture.color.b, lineTexture.color.a)
    lineTexture:SetStartPoint(startX - framePosX, -(startY - framePosY))
    lineTexture:SetEndPoint(endX - framePosX, -(endY - framePosY))
    lineTexture:SetThickness(lineTexture.defaultThickness);
    lineTexture:SetPoint("CENTER", endX - framePosX, -(endY - framePosY))


    --? Minimap Stuff
    -- local fWidth, fHeight = self:GetSize();

    -- local x1, y1= HBD:GetWorldCoordinatesFromZone(0, 0, UiMapID)
    -- local x2, y2 = HBD:GetWorldCoordinatesFromZone(1, 1, UiMapID)
    -- local mapWidth = x1 - x2;


    -- local mSizeX, mSizeY = Minimap:GetSize()
    -- self.minimapScale = {}

    -- local worldWidth = dx * mapWidth
    -- local numberOfMinimaps = worldWidth/(466 + 2/3)
    -- local frameWidth = numberOfMinimaps*mSizeX
    -- self.minimapScale["outdoor"] =  frameWidth/fWidth

    -- numberOfMinimaps = worldWidth/300
    -- frameWidth = numberOfMinimaps*mSizeX
    -- self.minimapScale["indoor"] =  frameWidth/fWidth
    --? end Minimap stuff

    --self.self.lineTexture = self.lineTexture


    lineTexture:Show()
    lineTexture.redraw(lineTexture, self:GetMap():GetCanvasScale())
    self.lineTexture = lineTexture
end

function WaypointPinMixin:OnReleased()

end

--! There are some fucky wucky going on with the Mouse clicking if zoomed out, but fixing when required
function WaypointPinMixin:OnClick(button)
    -- Override in your mixin, called when this pin is clicked
end

function WaypointPinMixin:OnMouseUp()
end

--! End fucky wucky, read above

function WaypointPinMixin:OnTooltip()
    local data = self.data
    local id = data.id
    local idType = data.type
    local object
    if idType == "npcFinisher" or idType == "npc" then
        object = QuestieQuest.Show.NPC[id]
    elseif idType == "objectFinisher" or idType == "object" then
        object = QuestieQuest.Show.GameObject[id]
    end
    MapTooltip.SimpleAvailableTooltip(id, idType, object)
end

function WaypointPinMixin:OnCanvasScaleChanged()
    -- Called when the canvas scale changes
    --? We redraw the line here with the new scale, we fetch the scale from the scrollcontainer
    --? because we need the performance. But Map:GetCanvasScale() also works.
    --* ScrollContainer.currentScale or ScrollContainer.targetScale or 1 == Map:GetCanvasScale

    --? Shrinks the width of the line when zooming in
    local canvasScale = ScrollContainer.currentScale or ScrollContainer.targetScale or 1
    if not self.lastScale or self.lastScale ~= canvasScale then
        WaypointAnimationHelper.ScaleTo(self, canvasScale, 0.01)
        self.lastScale = canvasScale
    end
end

do
    --? When multiple lines try to write we keep track of which have already been written in here
    local _drawnTooltip = {}

    function WaypointPinMixin:OnMouseEnterLine()
        -- Override in your mixin, called when the mouse enters this pin
        Questie:Debug(Questie.DEBUG_DEVELOP, "WaypointPinMixin:OnMouseEnterLine")
        print(self:GetName(), "OnMouseEnterLine")

        -- Register tooltip writer
        local onTooltip = function()
            if not _drawnTooltip[self.data.id] then
                _drawnTooltip[self.data.id] = true
                self:OnTooltip()
            end
        end
        MapEventBus:ObjectRegisterRepeating(self, MapEventBus.events.WRITE_WAYPOINT_TOOLTIP, onTooltip)
        -- Animate line
        WaypointAnimationHelper.ScaleWaypointsByPin(self, 0.8, 0.03)
    end

    function WaypointPinMixin:OnMouseLeaveLine()
        -- Override in your mixin, called when the mouse enters this pin
        Questie:Debug(Questie.DEBUG_DEVELOP, "WaypointPinMixin:OnMouseLeaveLine")
        print(self:GetName(), "OnMouseLeaveLine")

        -- Unregister the write command
        MapEventBus:ObjectUnregisterRepeating(self, MapEventBus.events.WRITE_WAYPOINT_TOOLTIP)
        questieTooltip:Hide()

        -- Remove the tooltip from the list of drawn tooltips
        _drawnTooltip[self.data.id] = nil
        -- Reset the scale of the waypoints
        WaypointAnimationHelper.ScaleWaypointsByPin(self, 1, 0.03)
    end
end

do
    --- This function checks if a point is inside a polygon (In this case a rectangle)
    ---@param line table<number, XYPoint> @A table with the outside points
    ---@param point XYPoint
    ---@return boolean @Inside or not, true or false
    local function insideLine(line, point)
        local oddNodes = false
        local j = #line
        for i = 1, #line do
            if (line[i].y < point.y and line[j].y >= point.y or line[j].y < point.y and line[i].y >= point.y) then
                if (line[i].x + (point.y - line[i].y) / (line[j].y - line[i].y) * (line[j].x - line[i].x) < point.x) then
                    oddNodes = not oddNodes;
                end
            end
            j = i;
        end
        return oddNodes
    end

    --Mouse specific function
    local lastX, lastY = 0, 0
    local hoveredLines = {}
    local mouseMovementTimer

    -- A value between 0-1 is expected for x and y
    ---@type XYPoint
    ---@diagnostic disable-next-line: assign-type-mismatch
    local mousePoint = { x = 0, y = 0 }

    function WaypointPinMixin:OnMouseEnter()
        --? If you want to do OnEnter stuff you are probably looking for the OnMouseEnterLine function

        --* Reset the mouse check timer
        if mouseMovementTimer ~= nil then
            mouseMovementTimer:Cancel()
            mouseMovementTimer = nil
            wipe(hoveredLines)
        end
        -- TODO: This is not 100% perfect, on very small lines the hover is patchy
        -- todo  Doing something like a lineLength check to see if it is very small and if the mouse is inside the frame would probably solve it
        if self.data.lineCornerPoints ~= nil and #self.data.lineCornerPoints > 0 then
            ---@type MapX, MapY
            local x, y
            mouseMovementTimer = C_Timer.NewTicker(0.1, function()
                x, y = ScrollContainer:GetNormalizedCursorPosition()
                if (x ~= lastX or y ~= lastY) then
                    mousePoint.x = x
                    mousePoint.y = y

                    --* Only rewrite the tooltip if something changed
                    local change = false

                    --? We have to enumerate all frame because sometimes two overlap and stop the mouse events
                    --? Such as OnMouseEnter and OnMouseLeave
                    ---@param line WaypointPinMixin
                    for line in self:GetMap():EnumeratePinsByTemplate(PinTemplates.WaypointPinTemplate) do
                        if insideLine(line.data.lineCornerPoints, mousePoint) then
                            --? If the line is not in the hoveredLines table, then we add it and call the OnMouseEnterLine
                            if not hoveredLines[line] then
                                line:OnMouseEnterLine()
                                hoveredLines[line] = true
                                change = true
                            end
                        else
                            --? If inside is false and the line is in the hoveredLines table, then it means that the mouse is no longer hovering over the line
                            if hoveredLines[line] then
                                line:OnMouseLeaveLine()
                                hoveredLines[line] = nil
                                change = true
                            end
                        end
                    end
                    if change then
                        MapEventBus:Fire(MapEventBus.events.RESET_TOOLTIP)
                        MapEventBus:Fire(MapEventBus.events.WRITE_WAYPOINT_TOOLTIP)
                        MapEventBus:Fire(MapEventBus.events.DRAW_TOOLTIP)
                    end

                    -- Set the last mouse position
                    lastX = x
                    lastY = y
                end
            end)
        end
    end

    function WaypointPinMixin:OnMouseLeave()
        print(self:GetName(), "OnMouseLeave")
        -- Override in your mixin, called when the mouse leaves this pin
        if mouseMovementTimer ~= nil then
            mouseMovementTimer:Cancel()
            mouseMovementTimer = nil

            --? We left the frame, push OnMouseLeaveLine to all lines
            for line, entered in pairs(hoveredLines or {}) do
                if entered then
                    line:OnMouseLeaveLine()
                end
            end
            wipe(hoveredLines)
        end
    end
end
