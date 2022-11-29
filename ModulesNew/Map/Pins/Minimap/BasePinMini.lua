---@class BasePinMiniMixin : MinimapCanvasPinMixin
---@field data table @This contains the data for the pin
---@field dirty boolean @This is used to determine if the pin needs to be reset or not
---@field textures Texture[] @This is a table of textures that are attached to the pin
local BasePinMiniMixin = Mixin(QuestieLoader:CreateModule("BasePinMiniMixin"), QuestieLoader("MinimapCanvasPinMixin"))

--Up value
local questieTooltip = QuestieTooltip --Localize the tooltip

---@param self MapIconFrame
function BasePinMiniMixin:OnTooltip()
    -- Override in your mixing, called when the tooltip is shown
    -- error("This should be overridden")
end

---@param self MapIconFrame
function BasePinMiniMixin:OnLoad()
    -- Override in your mixin, called when this pin is created
    -- print("PinOnLoad")
end

---@param self MapIconFrame
function BasePinMiniMixin:GetType()
    return "BasePin"
end

---@param self MapIconFrame
function BasePinMiniMixin:OnAcquired(PinData, PinToMixin, ...) -- the arguments here are anything that are passed into AcquirePin after the pinTemplate
    --? Set the pin as dirty, this makes it reset fully when going through the framepool
    self.dirty = true


    -- print("Base Acquired")
    -- Override in your mixin, called when this pin is being acquired by a data provider but before its added to the map
    --print("Pin Acquired args:", select("#", ...))
    --local typeMixin = select(1, ...)
    --if(not typeMixin) then
    --    self.BasePinMini = Mixin(self, typeMixin)
    --    self.BasePinMini:Initialize();
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

    -- if (PinData) then
    --     self.data = PinData
    -- else
    --     error("Pin must have data!", 2)
    -- end

    -- if self.GetType == nil then
    --     error("BasePinMini must have a GetType function!", 2)
    -- end

    -- --! Important to run this last, because if we want overwrite things in the submixins we need to do this last
    -- --? Mixin another pin with extra functionality
    -- if PinToMixin ~= nil then
    --     if PinToMixin.GetType == nil then
    --         error("Every PinMixin type must have a GetType function!", 2)
    --     end
    --     if PinToMixin.GetIconScale == nil then
    --         error("Every PinMixin type must have a GetIconScale function!", 2)
    --     end
    --     MixinPin(self, PinToMixin)
    --     -- local isMouseClickEnabled = self:IsMouseClickEnabled();
    --     -- if isMouseClickEnabled then
    --     --     self:SetScript("OnMouseUp", self.OnMouseUp);
    --     --     self:SetScript("OnMouseDown", self.OnMouseDown);
    --     -- end

    --     local isMouseMotionEnabled = self:IsMouseMotionEnabled();
    --     if isMouseMotionEnabled then
    --         self:SetScript("OnEnter", self.OnMouseEnter);
    --         self:SetScript("OnLeave", self.OnMouseLeave);
    --     end
    --     -- Run the OnAcquired on the subpin if it exists
    --     if PinToMixin.OnAcquired ~= nil then
    --         PinToMixin.OnAcquired(self, ...)
    --     end
    -- end
end

---@param self MapIconFrame
function BasePinMiniMixin:OnReleased()
    -- print("OnPinRelease")
    -- Override in your mixin, called when this pin is being released by a data provider and is no longer on the map
    --if(self.BasePinMinig) then
    --    self.BasePinMini:UnInitialize();
    --    self.BasePinMini = nil
    --end
    -- self:Hide()
    -- self:ClearNudgeSettings()
    -- self:SetParent(UIParent)
    -- self:ClearAllPoints()
end

---@param self MapIconFrame
function BasePinMiniMixin:OnClick(button)
    -- Override in your mixin, called when this pin is clicked
    --Make the polygon click-through
    print(self:GetAlpha())
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
    ---@param self MapIconFrame
    function BasePinMiniMixin:OnMouseLeave()
        -- Override in your mixin, called when the mouse leaves this pin
        -- Reset the icons to their state
    end

    ---@param self MapIconFrame
    function BasePinMiniMixin:OnMouseEnter()
        print("OnMouseEnter")

        if mouseTimer and mouseTimer.Cancel then
            mouseTimer:Cancel()
        end
        mouseTimer = C_Timer.NewTicker(0.1, mousePositionCheck)
    end
end


---@param self MapIconFrame
function BasePinMiniMixin:OnMouseDown()
    -- Override in your mixin, called when the mouse is pressed on this pin
    if (IsMouseButtonDown("LeftButton")) then
        WorldMapFrame.ScrollContainer:OnMouseDown("LeftButton")
    end
end

---@param self MapIconFrame
function BasePinMiniMixin:OnMouseUp()
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
