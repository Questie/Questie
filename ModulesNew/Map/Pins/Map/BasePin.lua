---@class BasePinMixin : MapCanvasPinMixin
---@field data table @This contains the data for the pin
---@field dirty boolean @This is used to determine if the pin needs to be reset or not
---@field textures Texture[] @This is a table of textures that are attached to the pin
local BasePinMixin = Mixin(QuestieLoader:CreateModule("BasePinMixin"), MapCanvasPinMixin)

----- System Imports -----
---@type MapEventBus
local MapEventBus = QuestieLoader:ImportModule("MapEventBus")
---@type SystemEventBus
local SystemEventBus = QuestieLoader:ImportModule("SystemEventBus")

---@type PinTemplates
local PinTemplates = QuestieLoader:ImportModule("PinTemplates")
---@type PinAnimationHelper
local PinAnimationHelper = QuestieLoader("PinAnimationHelper")
---@type WaypointAnimationHelper
local WaypointAnimationHelper = QuestieLoader("WaypointAnimationHelper")

local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local tInsert = table.insert

--Up value
local questieTooltip = QuestieTooltip --Localize the tooltip

---@param pixels number         @Pixel size
---@param frameScale number     @Effective Frame scale
---@return number               @UI size
---See blizzard Util.lua [Documentation](https://github.com/tomrus88/BlizzardInterfaceCode/blob/ace1af63e38c058fa76cd3abca0b57b384c527d4/Interface/SharedXML/Util.lua#L128)
function ConvertPixelsToUI(pixels, frameScale)
    local physicalScreenHeight = select(2, GetPhysicalScreenSize());
    return (pixels * 768.0) / (physicalScreenHeight * frameScale);
end

local sqrt = math.sqrt
local function Euclid(x, y, i, e)
    -- No need for absolute values as these are used only as squared
    local xd = x - i
    local yd = y - e
    return sqrt(xd * xd + yd * yd)
end

---@param self MapIconFrame
function BasePinMixin:OnTooltip()
    -- Override in your mixing, called when the tooltip is shown
    -- error("This should be overridden")
end

---@param self MapIconFrame
function BasePinMixin:OnLoad()
    -- Override in your mixin, called when this pin is created
    -- print("PinOnLoad")
end

---@param self MapIconFrame
function BasePinMixin:GetType()
    return "BasePin"
end

---@param self MapIconFrame
function BasePinMixin:OnAcquired(PinData, PinToMixin, ...) -- the arguments here are anything that are passed into AcquirePin after the pinTemplate
    --? Set the pin as dirty, this makes it reset fully when going through the framepool
    self.dirty = true


    -- print("Base Acquired")
    -- Override in your mixin, called when this pin is being acquired by a data provider but before its added to the map
    --print("Pin Acquired args:", select("#", ...))
    --local typeMixin = select(1, ...)
    --if(not typeMixin) then
    --    self.BasePinMixin = Mixin(self, typeMixin)
    --    self.BasePinMixin:Initialize();
    --else
    --    self:Release();
    --end
    --self:SetPosition(0.5, 0.5)
    --Questie:Debug(DEBUG_DEVELOP, "BlobFrame", self)
    --self:SetFrameLevel(frameLevel)
    --self:ApplyFrameLevel()
    --self:Show()

    --Nudge test code, not really 100%
    -- local distWidth = ConvertPixelsToUI(4, WorldMapFrame:GetEffectiveScale()) --actual = 12
    -- local distHeight = ConvertPixelsToUI(4, WorldMapFrame:GetEffectiveScale()) --actual = 29

    -- local worldMapFrameWidth = WorldMapFrame:GetWidth() * WorldMapFrame:GetEffectiveScale()
    -- -- print((1 / worldMapFrameWidth) * distWidth,(1 / worldMapFrameWidth))
    -- -- Probably need to play with these settings
    -- self:SetNudgeSourceRadius(math.max(distWidth, distHeight))
    -- self:SetNudgeTargetFactor(1) --0.00125);
    -- -- self:SetNudgeTargetFactor(0.1) --0.00125);
    -- self:SetNudgeSourceMagnitude((1 / worldMapFrameWidth)* 6, (1 / worldMapFrameWidth)* 12)
    -- self:SetNudgeZoomedOutFactor(1); --1.25
    -- self:SetNudgeZoomedInFactor(1); -- This should probably be changed, makes it "jump" when zooming in

    -- Probably need to play with these settings
    -- self:SetNudgeSourceRadius(1)
    -- self:SetNudgeTargetFactor((1 / worldMapFrameWidth)) --0.00125);
    -- self:SetNudgeTargetFactor(0.1) --0.00125);
    -- self:SetNudgeSourceMagnitude(distWidth, distHeight)
    -- self:SetNudgeZoomedOutFactor(1); --1.25
    -- self:SetNudgeZoomedInFactor(0.8);
    -- self:SetScalingLimits(1, normalScale, zoomedScale)

    if (PinData) then
        self.data = PinData
    else
        error("Pin must have data!", 2)
    end

    if self.GetType == nil then
        error("BasePinMixin must have a GetType function!", 2)
    end

    --! Important to run this last, because if we want overwrite things in the submixins we need to do this last
    --? Mixin another pin with extra functionality
    if PinToMixin ~= nil then
        if PinToMixin.GetType == nil then
            error("Every PinMixin type must have a GetType function!", 2)
        end
        if PinToMixin.GetIconScale == nil then
            error("Every PinMixin type must have a GetIconScale function!", 2)
        end
        MixinPin(self, PinToMixin)
        -- local isMouseClickEnabled = self:IsMouseClickEnabled();
        -- if isMouseClickEnabled then
        --     self:SetScript("OnMouseUp", self.OnMouseUp);
        --     self:SetScript("OnMouseDown", self.OnMouseDown);
        -- end

        local isMouseMotionEnabled = self:IsMouseMotionEnabled();
        if isMouseMotionEnabled then
            self:SetScript("OnEnter", self.OnMouseEnter);
            self:SetScript("OnLeave", self.OnMouseLeave);
        end
        -- Run the OnAcquired on the subpin if it exists
        if PinToMixin.OnAcquired ~= nil then
            PinToMixin.OnAcquired(self, ...)
        end
    end
end

---@param self MapIconFrame
function BasePinMixin:OnReleased()
    -- print("OnPinRelease")
    -- Override in your mixin, called when this pin is being released by a data provider and is no longer on the map
    --if(self.BasePinMixing) then
    --    self.BasePinMixin:UnInitialize();
    --    self.BasePinMixin = nil
    --end
    -- self:Hide()
    -- self:ClearNudgeSettings()
    -- self:SetParent(UIParent)
    -- self:ClearAllPoints()
end

---@param self MapIconFrame
function BasePinMixin:OnClick(button)
    -- Override in your mixin, called when this pin is clicked
    --Make the polygon click-through
    if WorldMapFrame and WorldMapFrame:IsShown() then
        if button == "RightButton" then
            local currentMapParent = WorldMapFrame:GetMapID()
            if currentMapParent then
                local mapInfo = C_Map.GetMapInfo(currentMapParent)
                currentMapParent = mapInfo.parentMapID

                if currentMapParent and currentMapParent > 0 then
                    WorldMapFrame:SetMapID(currentMapParent)
                end
            end
        end
    end
end

--This function helps the OnMouseLeave because it doesn't always fire...
local mouseTimer
local mouseLocationX, mouseLocationY
local function mousePositionCheck()
    if questieTooltip:IsVisible() then
        local mouseX, mouseY = GetCursorPosition()
        if abs(mouseLocationX - mouseX) > 10 or abs(mouseLocationY - mouseY) > 10 then
            questieTooltip:Hide();
            mouseTimer:Cancel()
        end
    else
        mouseTimer:Cancel()
    end
end

do
    --? When multiple pins animate we keep track of which pins are animating in here.
    local _animationGroups = setmetatable({}, { __index = function(t, k)
        local new = {}
        t[k] = new
        return new
    end })

    ---@param self MapIconFrame
    function BasePinMixin:OnMouseLeave()
        -- Override in your mixin, called when the mouse leaves this pin
        -- Reset the icons to their state
        PinAnimationHelper.ScaleGroupTo(_animationGroups[self], 1, 0.03)
        wipe(_animationGroups[self])
    end

    ---@param self MapIconFrame
    function BasePinMixin:OnMouseEnter()
        --* We set the enter position for the mouse
        mouseLocationX, mouseLocationY = GetCursorPosition()

        local tooltipFunction = function()
            MapEventBus:Fire(MapEventBus.events.RESET_TOOLTIP)

            --? Maybe keep this?
            -- I swapped from actual coordinate location to the location of the pin in frame coordinates
            -- If you zoom you don't want the same combination of tooltips so this is better
            --? An idea might be to use cursor location here instead!
            -- local pinX, pinY = self:GetPosition()
            -- local otherPinX, otherPinY
            -- otherPinX, otherPinY = pin.normalizedX, pin.normalizedY --Same as pin:GetPosition() so they do exist.
            --distance < 0.008

            -- There might be a ton of pins, so declare them now for speed.
            local xd, yd = 0, 0
            local distance

            -- Run tooltip for hovered pin and add it to animation group
            self:OnTooltip()
            tInsert(_animationGroups[self], self)

            -- Get current position in the UI (PS. Not map X,Y coordinates)
            local _, _, _, pinX, pinY = self:GetPoint(1)
            ---@param pin MapIconFrame
            for pin in self:GetMap():EnumeratePinsByTemplate(PinTemplates.MapPinTemplate) do
                --? There is a potential for a pin not to have OnTooltip
                if pin.OnTooltip then
                    -- Euclid distance
                    -- Get current position for pin in the UI (PS. Not map X,Y coordinates)
                    local _, _, _, otherPinX, otherPinY = pin:GetPoint(1)
                    xd = pinX - otherPinX
                    yd = pinY - otherPinY
                    distance = sqrt(xd * xd + yd * yd)
                    if pinX ~= otherPinX and pinY ~= otherPinY and distance < 10 then
                        pin:OnTooltip()
                        tInsert(_animationGroups[self], pin)
                    end
                end
            end
            MapEventBus:Fire(MapEventBus.events.DRAW_TOOLTIP)
            -- Run animations for all affected pins
            PinAnimationHelper.ScaleGroupTo(_animationGroups[self], 1.2, 0.03)
        end


        -- Register tooltip for shift click
        SystemEventBus:ObjectRegisterRepeating(questieTooltip, SystemEventBus.events.MODIFIER_PRESSED_SHIFT, tooltipFunction)
        SystemEventBus:ObjectRegisterRepeating(questieTooltip, SystemEventBus.events.MODIFIER_RELEASED_SHIFT, tooltipFunction)

        -- Kick eveything off
        tooltipFunction()

        if mouseTimer and mouseTimer.Cancel then
            mouseTimer:Cancel()
        end
        mouseTimer = C_Timer.NewTicker(0.1, mousePositionCheck)
    end
end


---@param self MapIconFrame
function BasePinMixin:OnMouseDown()
    -- Override in your mixin, called when the mouse is pressed on this pin
    if (IsMouseButtonDown("LeftButton")) then
        WorldMapFrame.ScrollContainer:OnMouseDown("LeftButton")
    end
end

---@param self MapIconFrame
function BasePinMixin:OnMouseUp()
    -- Override in your mixin, called when the mouse is released
    local cursorX, cursorY = WorldMapFrame.ScrollContainer:GetCursorPosition();
    local isLeftClick = WorldMapFrame.ScrollContainer:WouldCursorPositionBeClick("LeftButton", cursorX, cursorY);
    if (not IsMouseButtonDown("LeftButton") and not isLeftClick) then
        WorldMapFrame.ScrollContainer:OnMouseUp("LeftButton")
    elseif (isLeftClick) then
        local mapId = WorldMapFrame:GetMapID()
        WorldMapFrame.ScrollContainer:OnMouseUp("LeftButton")
        if (mapId == WorldMapFrame:GetMapID()) then
            print(cursorX, cursorY, isLeftClick)
            print("Click")
        else
            questieTooltip:Hide()
        end
    end
end

-- function BasePinMixin:OnMapInsetSizeChanged(mapInsetIndex, expanded)
--     -- Optionally override in your mixin, called when a map inset changes sizes
-- end

-- function BasePinMixin:OnMapInsetMouseEnter(mapInsetIndex)
--     -- Optionally override in your mixin, called when a map inset gains mouse focus
-- end

-- function BasePinMixin:OnMapInsetMouseLeave(mapInsetIndex)
--     -- Optionally override in your mixin, called when a map inset loses mouse focus
-- end

-- Clear the nudge settings, this is actually a blizzard function but does not exist in Classic it seems.
function BasePinMixin:ClearNudgeSettings()
    self.nudgeTargetFactor = nil;
    self.nudgeSourceRadius = nil;
    self.nudgeSourceZoomedOutMagnitude = nil;
    self.nudgeSourceZoomedInMagnitude = nil;
    self.zoomedInNudge = nil;
    self.zoomedOutNudge = nil;
end
