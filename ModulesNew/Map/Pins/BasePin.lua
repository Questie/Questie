---@class QuestieNS
local Questie = select(2, ...)

----- System Imports -----
---@type MapEventBus
local MapEventBus = QuestieLoader:ImportModule("MapEventBus")
---@type SystemEventBus
local SystemEventBus = QuestieLoader:ImportModule("SystemEventBus")

local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---@class BasePinMixin : MapCanvasPinMixin
---@field data table @This contains the data for the pin
---@field dirty boolean @This is used to determine if the pin needs to be reset or not
---@field textures Texture[] @This is a table of textures that are attached to the pin
local BasePinMixin = CreateFromMixins(MapCanvasPinMixin) --[[@as MapCanvasPinMixin]]
Questie.BasePinMixin = BasePinMixin

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

function BasePinMixin:OnTooltip()
    -- Override in your mixing, called when the tooltip is shown
    error("This should be overridden")
end

function BasePinMixin:OnLoad()
    -- Override in your mixin, called when this pin is created
    -- print("PinOnLoad")
end

function BasePinMixin:GetType()
    return "BasePin"
end

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
        error("Pin must have data!")
        print(debugstack(2, 0, 5))
    end

    if self.GetType == nil then
        error("BasePinMixin must have a GetType function!")
    end

    --! Important to run this last, because if we want overwrite things in the submixins we need to do this last
    --? Mixin another pin with extra functionality
    if PinToMixin ~= nil then
        if PinToMixin.GetType == nil then
            error("Every PinMixin type must have a GetType function!")
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
        -- Run the OnAcquired on the subpin
        PinToMixin.OnAcquired(self, ...)
    end
end

function BasePinMixin:OnReleased()
    -- print("OnPinRelease")
    -- Override in your mixin, called when this pin is being released by a data provider and is no longer on the map
    --if(self.BasePinMixing) then
    --    self.BasePinMixin:UnInitialize();
    --    self.BasePinMixin = nil
    --end
    -- self:Hide()
    self:ClearNudgeSettings()
    -- self:SetParent(UIParent)
    -- self:ClearAllPoints()
end

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

function BasePinMixin:OnMouseLeave()
    -- Override in your mixin, called when the mouse leaves this pin
    -- print("leave")
    -- questieTooltip:Hide()
end

function BasePinMixin:OnMouseEnter()
    --* We set the enter position for the mouse
    mouseLocationX, mouseLocationY = GetCursorPosition()
    -- Override in your mixin, called when the mouse enters this pin
    --local _, _, _, xOfs, yOfs = self:GetPoint(1)
    --local w, h = self:GetSize()
    --local getEffectiveScale = self:GetEffectiveScale()

    --print("X", xOfs, "Y", yOfs)
    --print("W", w, "(",(w*getEffectiveScale), ")", "H", h, "(",(h*getEffectiveScale), ")")
    --local left, bottom, width, height = self:GetRect()
    --width = width * getEffectiveScale
    --height = height * getEffectiveScale
    --local bo = self:GetBottom();
    --local to = self:GetTop();
    --local le = self:GetLeft();
    --local ri = self:GetRight();
    --print("L", left * getEffectiveScale, "B", bottom * getEffectiveScale)
    --print("R", (left + width) * getEffectiveScale, "T", (bottom - height) * getEffectiveScale)
    --print(bo*getEffectiveScale, to*getEffectiveScale, le*getEffectiveScale, ri*getEffectiveScale)

    --globalT = self.data
    --Questie.ThreadLib:SimpleThread(function()
    -- MessageHandler.RegisterCallback(questieTooltip, MessageHandler.events.KEY_PRESS.MODIFIER_PRESSED_SHIFT, self.AdvancedTooltip, self)
    -- MessageHandler.RegisterCallback(questieTooltip, MessageHandler.events.KEY_PRESS.MODIFIER_RELEASED_SHIFT, self.SimpleTooltip, self)
    -- if IsShiftKeyDown() then
    --     self:AdvancedTooltip()
    -- else
    --     self:SimpleTooltip()
    -- end
    -- --end)

    -- if(self.object.OnMouseEnter) then
    --     self.object.OnMouseEnter()
    -- end


    -- local count = 0
    -- local first = true
    -- questieTooltip:ClearLines()
    -- questieTooltip:SetOwner(WorldMapFrame, "ANCHOR_CURSOR")
    -- for index, questData in pairs(self.data.availableData) do
    --     for questId, _ in pairs(questData) do
    --         local name = QuestieDB.QueryQuestSingle(questId, "name")
    --         questieTooltip:AddLine(name)
    --         count = count + 1
    --     end
    -- end

    -- questieTooltip:AddLine("Total Givers:" .. tostring(count))
    -- questieTooltip:Show()

    -- print(self.highlightTexture)
    -- if self.highlightTexture then
    --     self.highlightTexture:SetDrawLayer("HIGHLIGHT")
    --     self.highlightTexture:SetVertexColor(1, 1, 0, 1)
    --     -- self.highlightTexture:SetScale(2)
    --     self.highlightTexture:Show()
    -- end

    local tooltipFunction = function()
        local data = self.data
        MapEventBus:Fire(MapEventBus.events.TOOLTIP.RESET_TOOLTIP)
        -- for index, id in pairs(data.id) do
        --     local giverType = data.type[index]
        --     MapEventBus:Fire(MapEventBus.events.TOOLTIP.ADD_AVAILABLE_TOOLTIP(id, giverType))
        -- end
        local pinX, pinY = self:GetPosition()
        local otherPinX, otherPinY
        self:OnTooltip()
        -- ---@param pin BasePinMixin
        -- for pin in self:GetMap():EnumeratePinsByTemplate(worldPinTemplate) do
        --     otherPinX, otherPinY = pin:GetPosition()
        --     if pinX ~= otherPinX and pinY ~= otherPinY and Euclid(pinX, pinY, otherPinX, otherPinY) < 0.01 then
        --         pin:OnTooltip()
        --     end
        -- end
        MapEventBus:Fire(MapEventBus.events.TOOLTIP.DRAW_TOOLTIP)
    end

    SystemEventBus:ObjectRegisterRepeating(questieTooltip, SystemEventBus.events.KEY_PRESS.MODIFIER_PRESSED_SHIFT, tooltipFunction)
    SystemEventBus:ObjectRegisterRepeating(questieTooltip, SystemEventBus.events.KEY_PRESS.MODIFIER_RELEASED_SHIFT, tooltipFunction)
    tooltipFunction()

    if mouseTimer and mouseTimer.Cancel then
        mouseTimer:Cancel()
    end
    mouseTimer = C_Timer.NewTicker(0.1, mousePositionCheck)
    --local x, y = self:GetCenter()
    --local getEffectiveScale = self:GetEffectiveScale()
    --print("X", x*getEffectiveScale, "Y", y*getEffectiveScale)
    --print("W", width * getEffectiveScale, "H", height * getEffectiveScale)
end



function BasePinMixin:OnMouseDown()
    -- Override in your mixin, called when the mouse is pressed on this pin
    if (IsMouseButtonDown("LeftButton")) then
        WorldMapFrame.ScrollContainer:OnMouseDown("LeftButton")
    end
end

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

local setNudgeVector = BasePinMixin.SetNudgeVector

function BasePinMixin:SetNudgeVector(sourcePinZoomedOutNudgeFactor, sourcePinZoomedInNudgeFactor, x, y)
    -- print("SetNudgeVector", sourcePinZoomedOutNudgeFactor, sourcePinZoomedInNudgeFactor, x, y)
    setNudgeVector(self, sourcePinZoomedOutNudgeFactor, sourcePinZoomedInNudgeFactor, x, y)
end

function BasePinMixin:OnMapInsetSizeChanged(mapInsetIndex, expanded)
    -- Optionally override in your mixin, called when a map inset changes sizes
end

function BasePinMixin:OnMapInsetMouseEnter(mapInsetIndex)
    -- Optionally override in your mixin, called when a map inset gains mouse focus
end

function BasePinMixin:OnMapInsetMouseLeave(mapInsetIndex)
    -- Optionally override in your mixin, called when a map inset loses mouse focus
end

-- Clear the nudge settings, this is actually a blizzard function but does not exist in Classic it seems.
function BasePinMixin:ClearNudgeSettings()
    self.nudgeTargetFactor = nil;
    self.nudgeSourceRadius = nil;
    self.nudgeSourceZoomedOutMagnitude = nil;
    self.nudgeSourceZoomedInMagnitude = nil;
    self.zoomedInNudge = nil;
    self.zoomedOutNudge = nil;
end
