---@class QuestieFramePool
local QuestieFramePool = QuestieLoader:CreateModule("QuestieFramePool");
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieDBMIntegration
local QuestieDBMIntegration = QuestieLoader:ImportModule("QuestieDBMIntegration");
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms");
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips");
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

local _QuestieFramePool = {...} --Local Functions
_QuestieFramePool.numberOfFrames = 0

_QuestieFramePool.unusedFrames = {}
_QuestieFramePool.usedFrames = {};

_QuestieFramePool.allFrames = {}

local HBD = LibStub("HereBeDragonsQuestie-2.0")
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")
local HBDMigrate = LibStub("HereBeDragonsQuestie-Migrate")

-- set pins parent to QuestieFrameGroup for easier compatibility with other addons
-- cant use this because it fucks with everything, but we gotta stick with HereBeDragonsQuestie anyway
HBDPins.MinimapGroup = CreateFrame("Frame", "QuestieFrameGroup", Minimap)
--HBDPins:SetMinimapObject(_CreateMinimapParent())


function QuestieFramePool:SetIcons()
    if(Questie.db.char.enableMinimalisticIcons) then
        ICON_TYPE_SLAY =  QuestieLib.AddonPath.."Icons\\slay_tiny.blp"
        ICON_TYPE_LOOT =  QuestieLib.AddonPath.."Icons\\loot_tiny.blp"
        ICON_TYPE_EVENT =  QuestieLib.AddonPath.."Icons\\event_tiny.blp"
        ICON_TYPE_OBJECT =  QuestieLib.AddonPath.."Icons\\object_tiny.blp"
    else
        ICON_TYPE_SLAY =  QuestieLib.AddonPath.."Icons\\slay.blp"
        ICON_TYPE_LOOT =  QuestieLib.AddonPath.."Icons\\loot.blp"
        ICON_TYPE_EVENT =  QuestieLib.AddonPath.."Icons\\event.blp"
        ICON_TYPE_OBJECT =  QuestieLib.AddonPath.."Icons\\object.blp"
    end
    --TODO: Add all types (we gotta stop using globals, needs refactoring)
    ICON_TYPE_AVAILABLE =  QuestieLib.AddonPath.."Icons\\available.blp"
    ICON_TYPE_AVAILABLE_GRAY =  QuestieLib.AddonPath.."Icons\\available_gray.blp"
    ICON_TYPE_COMPLETE =  QuestieLib.AddonPath.."Icons\\complete.blp"
    ICON_TYPE_GLOW = QuestieLib.AddonPath.."Icons\\glow.blp"
    ICON_TYPE_BLACK = QuestieLib.AddonPath.."Icons\\black.blp"
    ICON_TYPE_REPEATABLE =  QuestieLib.AddonPath.."Icons\\repeatable.blp"
end


StaticPopupDialogs["QUESTIE_CONFIRMHIDE"] = {
    text = "", -- set before showing
    QuestID = 0, -- set before showing
    button1 = QuestieLocale:GetUIString("CONFIRM_HIDE_YES"),
    button2 = QuestieLocale:GetUIString("CONFIRM_HIDE_NO"),
    OnAccept = function()
        QuestieQuest:HideQuest(StaticPopupDialogs["QUESTIE_CONFIRMHIDE"].QuestID)
    end,
    SetQuest = function(self, id)
        self.QuestID = id
        self.text = QuestieLocale:GetUIString("CONFIRM_HIDE_QUEST", QuestieDB:GetQuest(self.QuestID):GetColoredQuestName())

        -- locale might not be loaded when this is first created (this does happen almost always)
        self.button1 = QuestieLocale:GetUIString("CONFIRM_HIDE_YES")
        self.button2 = QuestieLocale:GetUIString("CONFIRM_HIDE_NO")
    end,
    OnShow = function(self)
        self:SetFrameStrata("TOOLTIP")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

-- Global Functions --
function QuestieFramePool:GetFrame()
    local returnFrame = nil--tremove(_QuestieFramePool.unusedFrames)

    -- im not sure its this, but using string keys for the table prevents double-adding to _QuestieFramePool.unusedFrames, calling unload() twice could double-add it maybe?
    for frameId, frame in pairs(_QuestieFramePool.unusedFrames) do -- yikes (why is tremove broken? is there a better to get the first key of a non-indexed table?)
        returnFrame = frame
        _QuestieFramePool.unusedFrames[frameId] = nil
        break
    end


    if returnFrame and returnFrame.frameId and _QuestieFramePool.usedFrames[returnFrame.frameId] then
        -- something went horribly wrong (desync bug?) don't use this frame since its already in use
        returnFrame = nil
    end
    if not returnFrame then
        returnFrame = _QuestieFramePool:QuestieCreateFrame()
    end
    if returnFrame ~= nil and returnFrame.hidden and returnFrame._show ~= nil and returnFrame._hide ~= nil then -- restore state to normal (toggle questie)
        returnFrame.hidden = false
        returnFrame.Show = returnFrame._show;
        returnFrame.Hide = returnFrame._hide;
        returnFrame._show = nil
        returnFrame._hide = nil
    end
    returnFrame.FadeLogic = nil
    returnFrame.faded = nil
    returnFrame.miniMapIcon = nil
    returnFrame._hidden_toggle_hack = nil -- TODO: this will be removed later, see QuestieQuest:UpdateHiddenNotes()

    --if f.IsShowing ~= nil and f:IsShowing() then
    returnFrame.data = {} -- this should probably be nil but QuestieCreateFrame sets it to an empty table for some reason
    returnFrame.x = nil;
    returnFrame.y = nil;
    returnFrame.AreaID = nil;
    returnFrame:Hide();
    --end

    if returnFrame.texture then
        returnFrame.texture:SetVertexColor(1, 1, 1, 1)
    end
    returnFrame.loaded = true
    returnFrame.shouldBeShowing = nil
    returnFrame.hidden = nil

    if returnFrame.BaseOnShow then
        returnFrame:SetScript("OnShow", returnFrame.BaseOnShow)
    end

    if returnFrame.BaseOnUpdate then
        --f:SetScript("OnUpdate", f.BaseOnUpdate)
        returnFrame.glowLogicTimer = C_Timer.NewTicker(1, returnFrame.BaseOnUpdate);
    else
        returnFrame:SetScript("OnUpdate", nil)
    end

    if returnFrame.BaseOnHide then
        returnFrame:SetScript("OnHide", returnFrame.BaseOnHide)
    end

    _QuestieFramePool.usedFrames[returnFrame.frameId] = returnFrame
    return returnFrame
end

--for i, frame in ipairs(_QuestieFramePool.allFrames) do
--    if(frame.loaded == nil)then
--        return frame
--    end
--end

function QuestieFramePool:UnloadAll()

    Questie:Debug(DEBUG_DEVELOP, "[QuestieFramePool] ".. QuestieLocale:GetUIString('DEBUG_UNLOAD_ALL', #_QuestieFramePool.allFrames))
    for i, frame in ipairs(_QuestieFramePool.allFrames) do
        --_QuestieFramePool:UnloadFrame(frame);
        frame:Unload()
    end
    QuestieMap.questIdFrames = {}
    QuestieMap.manualFrames = {}
end

function QuestieFramePool:UpdateGlowConfig(mini, mode)
    if mode then
        for _, icon in pairs(_QuestieFramePool.usedFrames) do
            if (((mini and icon.miniMapIcon) or not mini) and icon.glow) and icon.IsShown and icon:IsShown() then
                icon:GetScript("OnShow")(icon) -- forces a glow update
            end
        end
    else
        for _, icon in pairs(_QuestieFramePool.usedFrames) do
            if ((mini and icon.miniMapIcon) or (not mini and not icon.miniMapIcon)) and icon.glow then
                icon.glow:Hide()
            end
        end
    end
end

function QuestieFramePool:UpdateColorConfig(mini, enable)
    if enable then
        for _, icon in pairs(_QuestieFramePool.usedFrames) do
            if (mini and icon.miniMapIcon) or (not mini and not icon.miniMapIcon) then
                local colors = {1, 1, 1}
                if icon.data.IconColor ~= nil then
                    colors = icon.data.IconColor
                end
                icon.texture:SetVertexColor(colors[1], colors[2], colors[3], 1)
            end
        end
    else
        for _, icon in pairs(_QuestieFramePool.usedFrames) do
            if (mini and icon.miniMapIcon) or (not mini and not icon.miniMapIcon) then
                icon.texture:SetVertexColor(1, 1, 1, 1)
            end
        end
    end
end

-- Local Functions --

--[[Use FRAME.Unload(FRAME) on frame object to unload!
function _QuestieFramePool:UnloadFrame(frame)
    --We are reseting the frames, making sure that no data is wrong.
  HBDPins:RemoveMinimapIcon(Questie, frame);
  HBDPins:RemoveWorldMapIcon(Questie, frame);
  frame.data = nil; -- Just to be safe
  frame.loaded = nil;
    table.insert(_QuestieFramePool.unusedFrames, frame)
end]]--
---@class IconFrame
function _QuestieFramePool:QuestieCreateFrame()
    _QuestieFramePool.numberOfFrames = _QuestieFramePool.numberOfFrames + 1
    local newFrame = CreateFrame("Button", "QuestieFrame".._QuestieFramePool.numberOfFrames, nil)
    newFrame.frameId = _QuestieFramePool.numberOfFrames;

    if(_QuestieFramePool.numberOfFrames > 5000) then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieFramePool] Over 5000 frames... maybe there is a leak?", _QuestieFramePool.numberOfFrames)
    end

    newFrame.glow = CreateFrame("Button", "QuestieFrame".._QuestieFramePool.numberOfFrames.."Glow", newFrame) -- glow frame
    newFrame.glow:SetFrameStrata("FULLSCREEN");
    newFrame.glow:SetWidth(18) -- Set these to whatever height/width is needed
    newFrame.glow:SetHeight(18)


    newFrame:SetFrameStrata("FULLSCREEN");
    newFrame:SetWidth(16) -- Set these to whatever height/width is needed
    newFrame:SetHeight(16) -- for your Texture
    newFrame:SetPoint("CENTER", -8, -8)
    newFrame:EnableMouse(true)--f:EnableMouse()

    local newTexture = newFrame:CreateTexture(nil, "OVERLAY", nil, 0)
    --t:SetTexture("Interface\\Icons\\INV_Misc_Eye_02.blp")
    --t:SetTexture("Interface\\Addons\\!Questie\\Icons\\available.blp")
    newTexture:SetWidth(16)
    newTexture:SetHeight(16)
    newTexture:SetAllPoints(newFrame)
    newTexture:SetTexelSnappingBias(0)
    newTexture:SetSnapToPixelGrid(false)

    local glowt = newFrame.glow:CreateTexture(nil, "OVERLAY", nil, -1)
    glowt:SetWidth(18)
    glowt:SetHeight(18)
    glowt:SetAllPoints(newFrame.glow)

    newFrame.texture = newTexture;
    newFrame.glowTexture = glowt
    newFrame.glowTexture:SetTexture(ICON_TYPE_GLOW)
    newFrame.glow:Hide()
    newFrame.glow:SetPoint("CENTER", -9, -9) -- 2 pixels bigger than normal icon
    newFrame.glow:EnableMouse(false)

    newFrame:SetScript("OnEnter", function(self) _QuestieFramePool:Questie_Tooltip(self) end); --Script Toolip
    newFrame:SetScript("OnLeave", function(self) 
      if(WorldMapTooltip) then WorldMapTooltip:Hide(); WorldMapTooltip._rebuild = nil; end 
      if(GameTooltip) then GameTooltip:Hide(); GameTooltip._Rebuild = nil; end 

      --Reset highlighting if it exists.
      for k, lineFrame in pairs(self.data.lineFrames or {}) do
        lineFrame.line:SetColorTexture(lineFrame.line.dR, lineFrame.line.dG, lineFrame.line.dB, lineFrame.line.dA)
      end
    end) --Script Exit Tooltip
    newFrame:RegisterForClicks("RightButtonUp", "LeftButtonUp")
    newFrame:SetScript("OnClick", function(self, button)
        --_QuestieFramePool:Questie_Click(self)
        if self and self.data and self.data.UiMapID and WorldMapFrame and WorldMapFrame:IsShown() then
            if button == "RightButton" then
                local currentMapParent = WorldMapFrame:GetMapID()
                if currentMapParent then
                    currentMapParent = QuestieZoneToParentTable[currentMapParent];
                    if currentMapParent and currentMapParent > 0 then
                        WorldMapFrame:SetMapID(currentMapParent)
                    end
                end
            else
                if self.data.UiMapID ~= WorldMapFrame:GetMapID() then
                    WorldMapFrame:SetMapID(self.data.UiMapID);
                end
            end
            if self.data.Type == "available" and IsShiftKeyDown() then
                StaticPopupDialogs["QUESTIE_CONFIRMHIDE"]:SetQuest(self.data.QuestData.Id)
                StaticPopup_Show ("QUESTIE_CONFIRMHIDE")
            elseif self.data.Type == "manual" and IsShiftKeyDown() then
                QuestieMap:UnloadManualFrames(self.data.id)
            end
        end
        if self and self.data and self.data.UiMapID and IsControlKeyDown() and TomTom and TomTom.AddWaypoint then
            -- tomtom integration (needs more work, will come with tracker
            if Questie.db.char._tom_waypoint and TomTom.RemoveWaypoint then -- remove old waypoint
                TomTom:RemoveWaypoint(Questie.db.char._tom_waypoint)
            end
            Questie.db.char._tom_waypoint = TomTom:AddWaypoint(self.data.UiMapID, self.x/100, self.y/100,  {title = self.data.Name, crazy = true})
        elseif self.miniMapIcon then
            local _, _, _, x, y = self:GetPoint()
            Minimap:PingLocation(x, y)
        end
    end);
    newFrame.GlowUpdate = function(self)--f:HookScript("OnUpdate", function(self)
        if self.glow and self.glow.IsShown and self.glow:IsShown() then
            self.glow:SetWidth(self:GetWidth()*1.13)
            self.glow:SetHeight(self:GetHeight()*1.13)
            self.glow:SetPoint("CENTER", self, 0, 0)
            if self.data and self.data.ObjectiveData and self.data.ObjectiveData.Color and self.glowTexture then
                local _,_,_,alpha = self.texture:GetVertexColor()
                self.glowTexture:SetVertexColor(self.data.ObjectiveData.Color[1], self.data.ObjectiveData.Color[2], self.data.ObjectiveData.Color[3], alpha or 1);
            end
        end
        --self.glow:SetPoint("BOTTOMLEFT", self, 1, 1)
    end--end)
    newFrame.BaseOnUpdate = function(self)
        if self.GlowUpdate then
            self:GlowUpdate()
        end
    end
    newFrame.BaseOnShow = function(self)--f:SetScript("OnShow", function(self)
        if self.data and self.data.Type and self.data.Type == "complete" then
            self:SetFrameLevel(self:GetFrameLevel() + 1)
        end
        if ((self.miniMapIcon and Questie.db.global.alwaysGlowMinimap) or ((not self.miniMapIcon) and Questie.db.global.alwaysGlowMap)) and self.data and self.data.ObjectiveData and self.data.ObjectiveData.Color and (self.data.Type and (self.data.Type ~= "available" and self.data.Type ~= "complete")) then
            self.glow:SetWidth(self:GetWidth()*1.13)
            self.glow:SetHeight(self:GetHeight()*1.13)
            self.glow:SetPoint("CENTER", self, 0, 0)
            local _,_,_,alpha = self.texture:GetVertexColor()
            self.glowTexture:SetVertexColor(self.data.ObjectiveData.Color[1], self.data.ObjectiveData.Color[2], self.data.ObjectiveData.Color[3], alpha or 1);
            self.glow:Show()
            local frameLevel = self:GetFrameLevel();
            if(frameLevel > 0) then
                self.glow:SetFrameLevel(frameLevel - 1)
            end
        end
    end--end)
    newFrame.BaseOnHide = function(self)--f:HookScript("OnHide", function(self)
        self.glow:Hide()
    end--end)
    --f.Unload = function(frame) _QuestieFramePool:UnloadFrame(frame) end;

    function newFrame:UpdateTexture(texture)
        --Different settings depending on noteType
        local globalScale = 0.7
        local objectiveColor = false;
        if(self.miniMapIcon) then
            globalScale = Questie.db.global.globalMiniMapScale;
            objectiveColor = Questie.db.global.questMinimapObjectiveColors;
        else
            globalScale = Questie.db.global.globalScale;
            objectiveColor = Questie.db.global.questObjectiveColors;
        end

        self.texture:SetTexture(texture)
        self.data.Icon = texture;
        local colors = {1, 1, 1}
        if self.data.IconColor ~= nil and objectiveColor then
            colors = self.data.IconColor
        end
        self.texture:SetVertexColor(colors[1], colors[2], colors[3], 1);
        
        if self.data.IconScale then
            local scale = 16 * ((self.data:GetIconScale() or 1)*(globalScale or 0.7));
            self:SetWidth(scale)
            self:SetHeight(scale)
        else
            self:SetWidth(16)
            self:SetHeight(16)
        end
    end

    function newFrame:Unload()
        self:SetScript("OnUpdate", nil)
        self:SetScript("OnShow", nil)
        self:SetScript("OnHide", nil)
        self:SetFrameStrata("FULLSCREEN");
        self:SetFrameLevel(0);

        if(QuestieMap.minimapFramesShown[self.frameId]) then
            QuestieMap.minimapFramesShown[self.frameId] = nil;
        end

        if(QuestieMap.mapFramesShown[self.frameId]) then
            QuestieMap.mapFramesShown[self.frameId] = nil;
        end

        --We are reseting the frames, making sure that no data is wrong.
        if self ~= nil and self.hidden and self._show ~= nil and self._hide ~= nil then -- restore state to normal (toggle questie)
            self.hidden = false
            self.Show = self._show;
            self.Hide = self._hide;
            self._show = nil
            self._hide = nil
        end
        self.shouldBeShowing = nil
        self.faded = nil
        HBDPins:RemoveMinimapIcon(Questie, self)
        HBDPins:RemoveWorldMapIcon(Questie, self)
        QuestieDBMIntegration:UnregisterHudQuestIcon(tostring(self))
        if(self.texture) then
            self.texture:SetVertexColor(1, 1, 1, 1)
        end
        self.miniMapIcon = nil;
        self:SetScript("OnUpdate", nil)
        if(self.fadeLogicTimer) then
          self.fadeLogicTimer:Cancel();
        end
        if(self.glowLogicTimer) then
          self.glowLogicTimer:Cancel();
        end
        --Unload potential waypoint frames that are used for pathing.
        if(self.data and self.data.lineFrames) then
            for index, lineFrame in pairs(self.data.lineFrames) do
                lineFrame:Unload();
            end
        end
        
        if self.OnHide then self:OnHide() end -- the event might trigger after OnHide=nil even if its set after self:Hide()
        --self.OnHide = nil
        --self.OnShow = nil
        self:Hide()
        self.glow:Hide()
        --self.glow:Hide()
        self.data = nil -- Just to be safe
        self.loaded = nil
        self.x = nil;self.y = nil;self.AreaID = nil
        if _QuestieFramePool.usedFrames[self.frameId] then
            _QuestieFramePool.usedFrames[self.frameId] = nil
            _QuestieFramePool.unusedFrames[self.frameId] = self--table.insert(_QuestieFramePool.unusedFrames, self)
        end
    end
    newFrame.data = {}
    newFrame:Hide()

    -- functions for fake hide/unhide
    function newFrame:FadeOut()
        if not self.faded then
            self.faded = true
            if self.texture then
                local r,g,b = self.texture:GetVertexColor()
                self.texture:SetVertexColor(r,g,b, Questie.db.global.iconFadeLevel)
            end
            if self.glowTexture then
                local r,g,b = self.glowTexture:GetVertexColor()
                self.glowTexture:SetVertexColor(r,g,b, Questie.db.global.iconFadeLevel)
            end
        end
    end

    function newFrame:FadeIn()
        if self.faded then
            self.faded = nil
            if self.texture then
                local r,g,b = self.texture:GetVertexColor()
                self.texture:SetVertexColor(r,g,b, 1)
            end
            if self.glowTexture then
                local r,g,b = self.glowTexture:GetVertexColor()
                self.glowTexture:SetVertexColor(r,g,b, 1)
            end
        end
    end
    function newFrame:FakeHide()
        if not self.hidden then
            self.shouldBeShowing = self:IsShown();
            self._show = self.Show;
            self.Show = function()
                self.shouldBeShowing = true;
            end
            self:Hide();
            self._hide = self.Hide;
            self.Hide = function()
                self.shouldBeShowing = false;
            end
            self.hidden = true
        end
    end
    function newFrame:FakeUnhide()
        if self.hidden then
            self.hidden = false
            self.Show = self._show;
            self.Hide = self._hide;
            self._show = nil
            self._hide = nil
            if self.shouldBeShowing then
                self:Show();
            end
        end
    end

    function newFrame:OnShow()
        if(self.miniMapIcon) then
            QuestieMap.minimapFramesShown[self.frameId] = self
        else
            QuestieMap.mapFramesShown[self.frameId] = self
        end
    end
    function newFrame:OnHide()
        if(self.miniMapIcon) then
            QuestieMap.minimapFramesShown[self.frameId] = nil
        else
            QuestieMap.mapFramesShown[self.frameId] = nil
        end
    end

    hooksecurefunc(newFrame, "Hide", function() 
        if newFrame.OnHide then
            newFrame:OnHide()
        end
    end)
    hooksecurefunc(newFrame, "Show", function()
        --For the love of god don't remove this.
        QuestieMap.utils:SetDrawOrder(newFrame);
        if newFrame.OnShow then
            newFrame:OnShow()
        end
    end)
    --f:HookScript("OnHide", function() if self.OnHide then self:OnHide() end end)
    --f:HookScript("OnShow", function() if self.OnShow then self:OnShow() end end)
    
    --f.glow:Hide()
    table.insert(_QuestieFramePool.allFrames, newFrame)
    return newFrame
end


_QuestieFramePool.lastTooltipShowHack = GetTime()
function _QuestieFramePool:IsMinimapInside()
    if _QuestieFramePool._lastMiniInsideCheck and GetTime() - _QuestieFramePool._lastMiniInsideCheck < 1 then
        return _QuestieFramePool._lastMiniInside
    end
    local tempzoom = 0;
    if (GetCVar("minimapZoom") == GetCVar("minimapInsideZoom")) then
        if (GetCVar("minimapInsideZoom")+0 >= 3) then
            Minimap:SetZoom(Minimap:GetZoom() - 1);
            tempzoom = 1;
        else
            Minimap:SetZoom(Minimap:GetZoom() + 1);
            tempzoom = -1;
        end
    end
    if (GetCVar("minimapInsideZoom")+0 == Minimap:GetZoom()) then
        Minimap:SetZoom(Minimap:GetZoom() + tempzoom);
        _QuestieFramePool._lastMiniInside = true
        _QuestieFramePool._lastMiniInsideCheck = GetTime()
        return true
    else
        _QuestieFramePool._lastMiniInside = false
        _QuestieFramePool._lastMiniInsideCheck = GetTime()
        Minimap:SetZoom(Minimap:GetZoom() + tempzoom);
        return false
    end
end


local tinsert = table.insert;
local tpack = table.pack;
local tremove = table.remove;
local tunpack = unpack;

---@param iconFrame IconFrame @The parent frame for the current line.
---@param waypointTable table<integer, Point> @A table containing waypoints {{X, Y}, ...}
---@param lineWidth integer @Width of the line.
---@param color integer[] @A table consisting of 4 variable {1, 1, 1, 1} RGB-Opacity
---@return LineFrame[]
function QuestieFramePool:CreateWaypoints(iconFrame, waypointTable, lineWidth, color)
    local lineFrameList = {}
    local lastPos = nil
    --Set defaults if needed.
    local lWidth = lineWidth or 1.5;
    local col = color or {1,0.72,0,0.3};

    for index, waypoint in pairs(waypointTable) do
        if(lastPos == nil) then
            lastPos = waypoint;
        else
            local lineFrame = QuestieFramePool:CreateLine(iconFrame, lastPos[1], lastPos[2], waypoint[1], waypoint[2], lWidth, col)
            tinsert(lineFrameList, lineFrame);
            lastPos = waypoint;
        end
    end
    local lineFrame = QuestieFramePool:CreateLine(iconFrame, lastPos[1], lastPos[2], waypointTable[1][1], waypointTable[1][2], lWidth, col)
    tinsert(lineFrameList, lineFrame);
    return lineFrameList;
end

---@param iconFrame IconFrame @The parent frame for the current line.
---@param startX integer @A value between 0-100
---@param startY integer @A value between 0-100
---@param endX integer @A value between 0-100
---@param endY integer @A value between 0-100
---@param lineWidth integer @Width of the line.
---@param color integer[] @A table consisting of 4 variable {1, 1, 1, 1} RGB-Opacity
---@return LineFrame
---@class LineFrame @A frame that contains the line used in waypoints.
local lineFrames = 1;
function QuestieFramePool:CreateLine(iconFrame, startX, startY, endX, endY, lineWidth, color)

    --Create the framepool for lines if it does not already exist.
    if not QuestieFramePool.Routes_Lines then
        QuestieFramePool.Routes_Lines={}
        QuestieFramePool.Routes_Lines_Used={}
    end
    --Names are not stricktly needed, but it is nice for debugging.
    local frameName = "questieLineFrame"..lineFrames;

    --tremove default always picks the last element, however counting arrays is kinda bugged? So just get index 1 instead.
    local lineFrame = tremove(QuestieFramePool.Routes_Lines, 1) or CreateFrame("Frame", frameName, iconFrame);
    if not lineFrame.frameId then
        lineFrame.frameId = lineFrames;
    end

    local width = WorldMapFrame:GetCanvas():GetWidth();
    local height = WorldMapFrame:GetCanvas():GetHeight();
    
    --Setting the parent is required to get the correct frame levels.
    lineFrame:SetParent(iconFrame);
    lineFrame:SetHeight(width);
    lineFrame:SetWidth(height);
    lineFrame:SetPoint("TOPLEFT", WorldMapFrame:GetCanvas(), "TOPLEFT", 0, 0)
    local frameLevel = iconFrame:GetFrameLevel();
    if(frameLevel > 1) then
        frameLevel = frameLevel - 1;
    end
    lineFrame:SetFrameLevel(frameLevel)
    lineFrame:SetFrameStrata("FULLSCREEN");

    --How to identify what the frame actually contains, this is not used atm could easily be changed.
    lineFrame.type = "line"

    --Include the line in the iconFrame.
    if(iconFrame.data.lineFrames == nil) then
        iconFrame.data.lineFrames = {};
    end
    tinsert(iconFrame.data.lineFrames, lineFrame);
    lineFrame.iconFrame = iconFrame;
    
    --Set the line as used.
    tinsert(QuestieFramePool.Routes_Lines_Used, lineFrame)
    --QuestieFramePool.Routes_Lines_Used[lineFrame:GetName()] = lineFrame;


    function lineFrame:Unload()
        self:Hide();
        self.iconFrame = nil;
        local debugFoundSelf = false;
        for index, lineFrame in pairs(QuestieFramePool.Routes_Lines_Used) do
            if(lineFrame:GetName() == self:GetName()) then
                debugFoundSelf = true;
                --Remove it from used frames...
                QuestieFramePool.Routes_Lines_Used[index] = nil;
                break;
            end
        end
        if(not debugFoundSelf) then
            --Questie:Error("lineFrame unload failed, could not find self in used frames when unloaded...", self:GetName());
        end
        HBDPins:RemoveWorldMapIcon(Questie, self)
        tinsert(QuestieFramePool.Routes_Lines, self);
    end
    local line = lineFrame.line or lineFrame:CreateLine();
    lineFrame.line = line;


    line.dR = color[1];
    line.dG = color[2];
    line.dB = color[3];
    line.dA = color[4];
    line:SetColorTexture(color[1],color[2],color[3],color[4]);

    -- Set texture coordinates and anchors
    --line:ClearAllPoints();

    local calcX = width/100;
    local calcY = height/100;
    
    line:SetDrawLayer("OVERLAY", -5)
    line:SetStartPoint("TOPLEFT", startX*calcX, (startY*calcY)*-1) -- We do by *-1 due to using the top left point
    line:SetEndPoint("TOPLEFT", endX*calcX, (endY*calcY)*-1) -- We do by *-1 due to using the top left point
    line:SetThickness(lineWidth);

    --line:Hide()
    lineFrame:Hide();


    --Should we keep these frames in the questIdFrames? Currently it is also a child of the icon.
    --Maybe the unload of the parent should just unload the children.
    --For safety we check this here too.
    --if(QuestieMap.questIdFrames[lineFrame.iconFrame.data.Id] == nil) then
    --    QuestieMap.questIdFrames[lineFrame.iconFrame.data.Id] = {}
    --end
    --tinsert(QuestieMap.questIdFrames[lineFrame.iconFrame.data.Id], lineFrame:GetName());
    
    --Keep a total lineFrame count for names.
    lineFrames = lineFrames + 1;
    return lineFrame
end

function _QuestieFramePool:Questie_Tooltip_line(self)
    local Tooltip = GameTooltip;
    Tooltip:SetOwner(self, "ANCHOR_CURSOR"); --"ANCHOR_CURSOR" or (self, self)
    Tooltip:AddLine("Test");
    Tooltip:SetFrameStrata("TOOLTIP");
    Tooltip:Show();
    --_QuestieFramePool:Questie_Tooltip(self.iconFrame)
end

function _QuestieFramePool:Questie_Tooltip(self)
    local r, g, b, a = self.texture:GetVertexColor();
    if(a == 0) then
        return
    end
    if GetTime() - _QuestieFramePool.lastTooltipShowHack < 0.05 and GameTooltip:IsShown() then
        return
    end
    _QuestieFramePool.lastTooltipShowHack = GetTime()
    local Tooltip = GameTooltip;
    Tooltip._owner = self;
    Tooltip:SetOwner(self, "ANCHOR_CURSOR"); --"ANCHOR_CURSOR" or (self, self)

    local maxDistCluster = 1
    local mid = WorldMapFrame:GetMapID();
    if mid == 947 then -- world
        maxDistCluster = 6
    elseif mid == 1415 or mid == 1414 then -- kalimdor/ek
        maxDistCluster = 4
    end
    if self.miniMapIcon then
        if _QuestieFramePool:IsMinimapInside() then
            maxDistCluster = 0.3 / (1+Minimap:GetZoom())
        else
            maxDistCluster = 0.5 / (1+Minimap:GetZoom())
        end
    end
    local already = {}; -- per quest
    local alreadyUnique = {}; -- per objective

    local headers = {};
    local footers = {};
    local contents = {};

    --Highlight waypoints if they exist.
    for k, lineFrame in pairs(self.data.lineFrames or {}) do
      lineFrame.line:SetColorTexture(math.min(lineFrame.line.dR*1.3, 1), math.min(lineFrame.line.dG*1.3, 1), math.min(lineFrame.line.dB*1.3, 1), math.min(lineFrame.line.dA*1.3, 1))
    end

    -- FIXME: `data` can be nil here which leads to an error, will have to debug:
    -- https://discordapp.com/channels/263036731165638656/263040777658171392/627808795715960842
    -- happens when a note doesn't get removed after a quest has been finished, see #1170
    -- TODO: change how the logic works, so this [ObjectiveIndex?] can be nil
    -- it is nil on some notes like starters/finishers, because its for objectives. However, it needs to be an integer here for duplicate checks
    if self.data.ObjectiveIndex == nil then
        self.data.ObjectiveIndex = 0
    end

    --for k,v in pairs(self.data.tooltip) do
    --Tooltip:AddLine(v);
    --end

    local usedText = {}

    local npcOrder = {};
    local questOrder = {};
    local manualOrder = {};
    if 1 then
        for _, icon in pairs(QuestieMap.mapFramesShown) do -- I added "_QuestieFramePool.usedFrames" because I think its a bit more efficient than using _G but I might be wrong
            if icon and icon.data and icon.x and icon.AreaID == self.AreaID then
                local dist = QuestieLib:Maxdist(icon.x, icon.y, self.x, self.y);
                if dist < maxDistCluster then
                    if icon.data.Type == "available" or icon.data.Type == "complete" then
                        if npcOrder[icon.data.Name] == nil then
                            npcOrder[icon.data.Name] = {};
                        end
                        local dat = {};
                        if icon.data.Type == "complete" then
                            dat.type = QuestieLocale:GetUIString("TOOLTIP_QUEST_COMPLETE");
                        else
                            local questType, questTag = GetQuestTagInfo(icon.data.Id);
                            if(icon.data.QuestData.Repeatable) then
                                dat.type = QuestieLocale:GetUIString("TOOLTIP_QUEST_REPEATABLE");--"(Repeatable)"; --
                            elseif(questType == 81 or questType == 83 or questType == 62 or questType == 41 or questType == 1) then
                                -- Dungeon or Legendary or Raid or PvP or Group(Elite)
                                dat.type = "("..questTag..")";
                            elseif(QuestieEvent and QuestieEvent.activeQuests[icon.data.Id]) then
                                dat.type = QuestieLocale:GetUIString("TOOLTIP_QUEST_EVENT");--"(Event)";--QuestieLocale:GetUIString("TOOLTIP_QUEST_AVAILABLE");
                            else
                                dat.type = QuestieLocale:GetUIString("TOOLTIP_QUEST_AVAILABLE");
                            end
                        end
                        dat.title = icon.data.QuestData:GetColoredQuestName(true)
                        dat.subData = icon.data.QuestData.Description
                        dat.questId = icon.data.Id;
                        npcOrder[icon.data.Name][dat.title] = dat
                        --table.insert(npcOrder[icon.data.Name], dat);
                    elseif icon.data.ObjectiveData and icon.data.ObjectiveData.Description then
                        --Questie:Print("Close icon", icon:GetName(), icon.data.QuestData:GetColoredQuestName())
                        local key = icon.data.Id--.QuestData:GetColoredQuestName();
                        if not questOrder[key] then
                            questOrder[key] = {};
                        end
                        local order = {}
                        icon.data.ObjectiveData:Update(); -- update progress info
                        if icon.data.Type == "event" then
                            local t = {
                                [icon.data.ObjectiveData.Description] = {},
                            }
                            if(icon.data.ObjectiveData.Index) then
                                local objectiveDesc = icon.data.QuestData.Objectives[icon.data.ObjectiveData.Index].Description;
                                t[icon.data.ObjectiveData.Description][objectiveDesc] = true;
                            end

                            --We need to check for duplicates.
                            local add = true;
                            for index, data in pairs(questOrder[key]) do
                              for text, nameData in pairs(data) do
                                if(text == icon.data.ObjectiveData.Description) then
                                  add = false;
                                  break;
                                end
                              end
                            end
                            if(add) then
                              table.insert(questOrder[key], t);
                            end
                            --questOrder[key][icon.data.ObjectiveData.Description] = true
                        else
                            --dat.subData = icon.data.ObjectiveData
                            local text = icon.data.ObjectiveData.Description
                            if icon.data.ObjectiveData.Needed then
                                text = tostring(icon.data.ObjectiveData.Collected) .. "/" .. tostring(icon.data.ObjectiveData.Needed) .. " " .. text
                            end
                            if(QuestieComms) then
                                local anotherPlayer = false;
                                for playerName, objectiveData in pairs(QuestieComms:GetQuest(icon.data.Id) or {}) do
                                    --[[
                                        -.type = objective.type;
                                        -.finished = objective.finished;
                                        -.fulfilled = objective.numFulfilled;
                                        -.required = objective.numRequired;  
                                    ]]
                                    local playerInfo = QuestiePlayer:GetPartyMemberByName(playerName);
                                    if(playerInfo) then
                                        local colorizedPlayerName = " (|c"..playerInfo.colorHex..playerName.."|r|cFF33FF33)|r";
                                        local remoteText = icon.data.ObjectiveData.Description;
                                        if objectiveData[icon.data.ObjectiveIndex] and objectiveData[icon.data.ObjectiveIndex].fulfilled and objectiveData[icon.data.ObjectiveIndex].required then
                                            local fulfilled = objectiveData[icon.data.ObjectiveIndex].fulfilled;
                                            local required = objectiveData[icon.data.ObjectiveIndex].required;
                                            remoteText = tostring(fulfilled) .. "/" .. tostring(required) .. " " .. remoteText .. colorizedPlayerName;
                                        else
                                            remoteText = remoteText .. colorizedPlayerName;
                                        end
                                        local t = {
                                            [remoteText] = {},
                                        }
                                        if icon.data.Name then
                                            t[remoteText][icon.data.Name] = true;
                                        end
                                        table.insert(order, t);
                                        anotherPlayer = true;

                                        --if not questOrder[key][remoteText] then
                                        --    questOrder[key][remoteText] = {}
                                        --end
                                        --if icon.data.Name then
                                        --    questOrder[key][remoteText][icon.data.Name] = true
                                        --end
                                    end
                                end
                                if(anotherPlayer) then
                                    local name = UnitName("player");
                                    local className, classFilename = UnitClass("player");
                                    local rPerc, gPerc, bPerc, argbHex = GetClassColor(classFilename)
                                    name = " (|c"..argbHex..name.."|r|cFF33FF33)|r";
                                    text = text .. name;
                                end
                            end

                            local t = {
                                [text] = {},
                            }
                            if icon.data.Name then
                                t[text][icon.data.Name] = true;
                            end
                            table.insert(order, 1, t);
                            for index, data in pairs(order) do
                              --Questie:Print("1",index, data)
                                for text, nameTable in pairs(data) do
                                  --Questie:Print("2",text, v)
                                  local data = {}
                                  data[text] = nameTable;
                                  --Add the data for the first time
                                  if(usedText[text] == nil) then
                                    table.insert(questOrder[key], data);
                                    usedText[text] = true;
                                  else
                                    --We want to add more NPCs as possible candidates when shift is pressed.
                                    if(icon.data.Name) then
                                      for dataIndex, data in pairs(questOrder[key]) do
                                        if(questOrder[key][dataIndex][text]) then
                                          questOrder[key][dataIndex][text][icon.data.Name] = true;
                                        end
                                      end
                                    end
                                  end
                                end
                            end

                            --if not questOrder[key][text] then
                            --    questOrder[key][text] = {}
                            --end
                            --if icon.data.Name then
                            --    questOrder[key][text][icon.data.Name] = true
                            --end
                            --table.insert(questOrder[key], text);--questOrder[key][icon.data.ObjectiveData.Description] = tostring(icon.data.ObjectiveData.Collected) .. "/" .. tostring(icon.data.ObjectiveData.Needed) .. " " .. icon.data.ObjectiveData.Description--table.insert(questOrder[key], tostring(icon.data.ObjectiveData.Collected) .. "/" .. tostring(icon.data.ObjectiveData.Needed) .. " " .. icon.data.ObjectiveData.Description);
                        end
                    elseif icon.data.CustomTooltipData then
                        questOrder[icon.data.CustomTooltipData.Title] = {}
                        table.insert(questOrder[icon.data.CustomTooltipData.Title], icon.data.CustomTooltipData.Body);
                    elseif icon.data.ManualTooltipData then
                        manualOrder[icon.data.ManualTooltipData.Title] = icon.data.ManualTooltipData.Body
                    end
                end
            end
        end
    end
    Tooltip.npcOrder = npcOrder
    Tooltip.questOrder = questOrder
    Tooltip.manualOrder = manualOrder
    Tooltip.miniMapIcon = self.miniMapIcon
    Tooltip._Rebuild = function(self)
        local xpString = QuestieLocale:GetUIString('XP');
        local shift = IsShiftKeyDown()
        local haveGiver = false -- hack
        local firstLine = true;
        for questTitle, quests in pairs(self.npcOrder) do -- this logic really needs to be improved
            haveGiver = true
            if(firstLine and not shift) then
                self:AddDoubleLine(questTitle, "("..QuestieLocale:GetUIString('ICON_SHIFT_HOLD')..")", 0.2, 1, 0.2, 0.43, 0.43, 0.43); --"(Shift+click)"
                firstLine = false;
            elseif(firstLine and shift) then
                --self:AddDoubleLine(questTitle, "(".."Click to hide"..")", 0.2, 1, 0.2, 0.43, 0.43, 0.43); --"(Shift+click)"
                self:AddLine(questTitle, 0.2, 1, 0.2);
                firstLine = false;
            else
              self:AddLine(questTitle, 0.2, 1, 0.2);
            end
            for k2, questData in pairs(quests) do
                if questData.title ~= nil then
                    local quest = QuestieDB:GetQuest(questData.questId);
                    if(quest and shift and QuestiePlayer:GetPlayerLevel() ~= 60) then
                        self:AddDoubleLine("   " .. questData.title, QuestieLib:PrintDifficultyColor(quest.level, "("..GetQuestLogRewardXP(questData.questId)..xpString..") ")..questData.type, 1, 1, 1, 1, 1, 0);
                    else
                        self:AddDoubleLine("   " .. questData.title, questData.type, 1, 1, 1, 1, 1, 0);
                    end
                end
                if questData.subData and shift then
                    local dataType = type(questData.subData)
                    if dataType == "table" then
                        for _,line in pairs(questData.subData) do
                            self:AddLine("      " .. line, 0.86, 0.86, 0.86);
                        end
                    elseif dataType == "string" then
                        self:AddLine("      " .. questData.subData, 0.86, 0.86, 0.86);
                        --self:AddLine("      |cFFDDDDDD" .. v2.subData);
                    end
                end
            end
        end
        for questId, textList in pairs(self.questOrder) do -- this logic really needs to be improved
            local quest = QuestieDB:GetQuest(questId);
            local questTitle = quest:GetColoredQuestName();
            if haveGiver then
                self:AddLine(" ");
                self:AddDoubleLine(questTitle, QuestieLocale:GetUIString("TOOLTIP_QUEST_ACTIVE"), 1, 1, 1, 1, 1, 0);
                haveGiver = false -- looks better when only the first one shows (active)
            else
                if(quest and shift and QuestiePlayer:GetPlayerLevel() ~= 60) then
                    local r, g, b = QuestieLib:GetDifficultyColorPercent(quest.level);
                    self:AddDoubleLine(questTitle, "("..GetQuestLogRewardXP(questId)..xpString..")", 0.2, 1, 0.2, r, g, b);
                    firstLine = false;
                elseif(firstLine and not shift) then
                    self:AddDoubleLine(questTitle, "("..QuestieLocale:GetUIString('ICON_SHIFT_HOLD')..")", 0.2, 1, 0.2, 0.43, 0.43, 0.43); --"(Shift+click)"
                    firstLine = false;
                else
                    self:AddLine(questTitle);
                end
            end
            if shift then
                for index, textData in pairs(textList) do
                    for textLine, nameData in pairs(textData) do
                        local dataType = type(nameData)
                        if dataType == "table" then
                            for name in pairs(nameData) do
                                self:AddLine("   |cFFDDDDDD" .. name);
                            end
                        elseif dataType == "string" then
                            self:AddLine("   |cFFDDDDDD" .. nameData);
                        end
                        self:AddLine("      |cFF33FF33" .. textLine);
                    end
                end
            else
                for index, textData in pairs(textList) do
                    for textLine, v2 in pairs(textData) do
                        self:AddLine("   |cFF33FF33" .. textLine);
                    end
                end
            end
        end
        for title, body in pairs(self.manualOrder) do
            self:AddLine(title)
            for _, stringOrTable in ipairs(body) do
                local dataType = type(stringOrTable)
                if dataType == "string" then
                    self:AddLine(stringOrTable)
                elseif dataType == "table" then
                    self:AddDoubleLine(stringOrTable[1], '|cFFffffff'..stringOrTable[2]..'|r') --normal, white
                end
            end
            if self.miniMapIcon == false then
                self:AddLine('|cFFa6a6a6Shift-click to hide|r') -- grey
            end
        end
    end
    Tooltip:_Rebuild() -- we separate this so things like MODIFIER_STATE_CHANGED can redraw the tooltip
    --Tooltip:AddDoubleLine("" .. self:GetFrameStrata(), ""..self:GetFrameLevel())
    --Tooltip:AddDoubleLine("" .. self.glow:GetFrameStrata(), ""..self.glow:GetFrameLevel())
    Tooltip:SetFrameStrata("TOOLTIP");
    QuestieTooltips.lastTooltipTime = GetTime() -- hack for object tooltips
    Tooltip:Show();
end

function _QuestieFramePool:Questie_Click(self)
    Questie:Print("Click!");
    --TODO Logic for click!
    -- Preferably call something outside, keep it "abstract" here
end
