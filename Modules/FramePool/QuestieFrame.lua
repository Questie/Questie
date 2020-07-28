---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieDBMIntegration
local QuestieDBMIntegration = QuestieLoader:ImportModule("QuestieDBMIntegration")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

QuestieFramePool.Qframe = {}

local _Qframe = {}

---@return IconFrame
function QuestieFramePool.Qframe:New(frameId, OnEnter)
    ---@class IconFrame
    local newFrame = CreateFrame("Button", "QuestieFrame"..frameId)
    newFrame.frameId = frameId;

    -- Add the frames to the ignore list of the Minimap Button Bag (MBB) addon
    -- This is quite ugly but the only thing we can do currently from our side
    -- Check #1504
    if MBB_Ignore then
        tinsert(MBB_Ignore, newFrame:GetName())
    end
    if frameId > 5000 then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieFramePool] Over 5000 frames... maybe there is a leak?", frameId)
    end

    newFrame.glow = CreateFrame("Button", "QuestieFrame"..frameId.."Glow", newFrame) -- glow frame
    newFrame.glow:SetFrameStrata("FULLSCREEN");
    newFrame.glow:SetWidth(18) -- Set these to whatever height/width is needed
    newFrame.glow:SetHeight(18)


    newFrame:SetFrameStrata("FULLSCREEN");
    newFrame:SetWidth(16) -- Set these to whatever height/width is needed
    newFrame:SetHeight(16) -- for your Texture
    newFrame:SetPoint("CENTER", -8, -8)
    newFrame:EnableMouse(true)

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

    ---@class IconTexture
    newFrame.texture = newTexture;
    newFrame.texture.OLDSetVertexColor = newFrame.texture.SetVertexColor;
    function newFrame.texture:SetVertexColor(r, g, b, a)
        self:OLDSetVertexColor(r,g,b,a);
        --We save the colors to the texture object, this way we don't need to use GetVertexColor
        self.r = r or 1;
        self.g = g or 1;
        self.b = b or 1;
        self.a = a or 1;
    end
    --We save the colors to the texture object, this way we don't need to use GetVertexColor
    newFrame.texture:SetVertexColor(1,1,1,1);

    newFrame.glowTexture = glowt
    newFrame.glowTexture.OLDSetVertexColor = newFrame.glowTexture.SetVertexColor;
    function newFrame.glowTexture:SetVertexColor(r, g, b, a)
        self:OLDSetVertexColor(r,g,b,a);
        --We save the colors to the texture object, this way we don't need to use GetVertexColor
        self.r = r or 1;
        self.g = g or 1;
        self.b = b or 1;
        self.a = a or 1;
    end

    --We save the colors to the texture object, this way we don't need to use GetVertexColor
    newFrame.glowTexture:SetVertexColor(1,1,1,1);

    newFrame.glowTexture:SetTexture(ICON_TYPE_GLOW)
    newFrame.glow:Hide()
    newFrame.glow:SetPoint("CENTER", -9, -9) -- 2 pixels bigger than normal icon
    newFrame.glow:EnableMouse(false)

    newFrame:SetScript("OnEnter", OnEnter); --Script Toolip
    newFrame:SetScript("OnLeave", _Qframe.OnLeave) --Script Exit Tooltip
    newFrame:RegisterForClicks("RightButtonUp", "LeftButtonUp")
    newFrame:SetScript("OnClick", _Qframe.OnClick);

    newFrame.GlowUpdate = _Qframe.GlowUpdate
    newFrame.BaseOnUpdate = _Qframe.BaseOnUpdate
    newFrame.BaseOnShow = _Qframe.BaseOnShow
    newFrame.BaseOnHide = _Qframe.BaseOnHide

    newFrame.UpdateTexture = _Qframe.UpdateTexture
    newFrame.Unload = _Qframe.Unload

    -- functions for fake hide/unhide
    newFrame.FadeOut = _Qframe.FadeOut
    newFrame.FadeIn = _Qframe.FadeIn
    newFrame.FakeHide = _Qframe.FakeHide
    newFrame.FakeUnhide = _Qframe.FakeUnhide
    newFrame.OnShow = _Qframe.OnShow
    newFrame.OnHide = _Qframe.OnHide
    newFrame.ShouldBeHidden = _Qframe.ShouldBeHidden

    newFrame.data = nil
    newFrame:Hide()

    return newFrame
end

function _Qframe:OnLeave()
    if WorldMapTooltip then
        WorldMapTooltip:Hide()
        WorldMapTooltip._rebuild = nil
    end
    if GameTooltip then
        GameTooltip:Hide()
        GameTooltip._Rebuild = nil
    end

    --Reset highlighting if it exists.
    if self.data.lineFrames then
        for k, lineFrame in pairs(self.data.lineFrames) do
            local line = lineFrame.line
            line:SetColorTexture(line.dR, line.dG, line.dB, line.dA)
        end
    end

    if self.data.touchedPins then
        for _, entry in pairs(self.data.touchedPins) do
            local icon = entry.icon;
            icon.texture:SetVertexColor(unpack(entry.color));
        end
        self.data.touchedPins = nil;
    end
end

function _Qframe:OnClick(button)
    --_QuestieFramePool:Questie_Click(self)
    if self and self.UiMapID and WorldMapFrame and WorldMapFrame:IsShown() then
        if button == "RightButton" then
            local currentMapParent = WorldMapFrame:GetMapID()
            if currentMapParent then
                local mapInfo = C_Map.GetMapInfo(currentMapParent)
                currentMapParent = mapInfo.parentMapID

                if currentMapParent and currentMapParent > 0 then
                    WorldMapFrame:SetMapID(currentMapParent)
                end
            end
        else
            if self.UiMapID ~= WorldMapFrame:GetMapID() then
                WorldMapFrame:SetMapID(self.UiMapID);
            end
        end
        if self.data.Type == "available" and IsShiftKeyDown() then
            StaticPopupDialogs["QUESTIE_CONFIRMHIDE"]:SetQuest(self.data.QuestData.Id)
            StaticPopup_Show ("QUESTIE_CONFIRMHIDE")
        elseif self.data.Type == "manual" and IsShiftKeyDown() then
            QuestieMap:UnloadManualFrames(self.data.id)
        end
    end
    if self and self.UiMapID and IsControlKeyDown() and TomTom and TomTom.AddWaypoint then
        -- tomtom integration (needs more work, will come with tracker
        if Questie.db.char._tom_waypoint and TomTom.RemoveWaypoint then -- remove old waypoint
            TomTom:RemoveWaypoint(Questie.db.char._tom_waypoint)
        end
        Questie.db.char._tom_waypoint = TomTom:AddWaypoint(self.UiMapID, self.x/100, self.y/100, {title = self.data.Name, crazy = true})
    elseif self.miniMapIcon then
        local _, _, _, x, y = self:GetPoint()
        Minimap:PingLocation(x, y)
    end
end

function _Qframe:GlowUpdate()
    if self.glow and self.glow.IsShown and self.glow:IsShown() then
        --Due to this always being 1:1 we can assume that if one isn't correct, the other isn't either
        --We can also assume that both change at the same time so we only check one.
        if(self.glow:GetWidth() ~= self:GetWidth() * 1.13) then ---self.glow:GetHeight() ~= self:GetHeight() * 1.13
            self.glow:SetSize(self:GetWidth() * 1.13, self:GetHeight() * 1.13)
            self.glow:SetPoint("CENTER", self, 0, 0)
        end
        if self.data and self.data.ObjectiveData and self.data.ObjectiveData.Color and self.glowTexture then
            --Due to us now saving the alpha inside of the texture we don't need to check the main texture anymore.
            --The question is is it faster to get and compare or just set straight up?
            if(self.glowTexture.r ~= self.data.ObjectiveData.Color[1] or self.glowTexture.g ~= self.data.ObjectiveData.Color[2] or self.glowTexture.b ~= self.data.ObjectiveData.Color[3] or self.texture.a ~= self.glowTexture.a) then
                self.glowTexture:SetVertexColor(self.data.ObjectiveData.Color[1], self.data.ObjectiveData.Color[2], self.data.ObjectiveData.Color[3], self.texture.a or 1)
            end
        end
    end
end

--function _Qframe:BaseOnUpdate() -- why do this here when its called in QuestieMap.fadeLogicTimerShown?
--    if self.GlowUpdate then
--        self:GlowUpdate()
--    end
--end

function _Qframe:BaseOnShow()
    local data = self.data

    if data and data.Type and data.Type == "complete" then
        self:SetFrameLevel(self:GetFrameLevel() + 1)
    end
    if ((self.miniMapIcon and Questie.db.global.alwaysGlowMinimap) or ((not self.miniMapIcon) and Questie.db.global.alwaysGlowMap)) and
        data and data.ObjectiveData and
        data.ObjectiveData.Color and
        (data.Type and (data.Type ~= "available" and data.Type ~= "complete")
    ) then
        self.glow:SetWidth(self:GetWidth() * 1.13)
        self.glow:SetHeight(self:GetHeight() * 1.13)
        self.glow:SetPoint("CENTER", self, 0, 0)
        local _, _, _, alpha = self.texture:GetVertexColor()
        self.glowTexture:SetVertexColor(data.ObjectiveData.Color[1], data.ObjectiveData.Color[2], data.ObjectiveData.Color[3], alpha or 1)
        self.glow:Show()
        local frameLevel = self:GetFrameLevel()
        if frameLevel > 0 then
            self.glow:SetFrameLevel(frameLevel - 1)
        end
    end
end

function _Qframe:BaseOnHide()
    self.glow:Hide()
end

function _Qframe:UpdateTexture(texture)
    --Different settings depending on noteType
    local globalScale = 0.7
    local objectiveColor = false
    local alpha = 1;

    if(self.miniMapIcon) then
        globalScale = Questie.db.global.globalMiniMapScale;
        objectiveColor = Questie.db.global.questMinimapObjectiveColors;
        alpha = 0;
    else
        globalScale = Questie.db.global.globalScale;
        objectiveColor = Questie.db.global.questObjectiveColors;
        alpha = 1;
    end

    self.texture:SetTexture(texture)
    self.data.Icon = texture;
    local colors = {1, 1, 1}

    if self.data.IconColor ~= nil and objectiveColor then
        colors = self.data.IconColor
    end
    self.texture:SetVertexColor(colors[1], colors[2], colors[3], alpha);

    if self.data.IconScale then
        local scale = 16 * ((self.data:GetIconScale() or 1)*(globalScale or 0.7));
        self:SetWidth(scale)
        self:SetHeight(scale)
    else
        self:SetWidth(16)
        self:SetHeight(16)
    end
end

function _Qframe:Unload()
    --Questie:Debug(DEBUG_SPAM, "[_Qframe:Unload]")
    self:SetScript("OnUpdate", nil)
    self:SetScript("OnShow", nil)
    self:SetScript("OnHide", nil)
    self:SetFrameStrata("FULLSCREEN");
    self:SetFrameLevel(0);

    -- Reset questIdFrames so they won't be toggled again
    local frameName = self:GetName()
    if frameName and self.data.Id and QuestieMap.questIdFrames[self.data.Id] and QuestieMap.questIdFrames[self.data.Id][frameName] then
        QuestieMap.questIdFrames[self.data.Id][frameName] = nil
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

    if self.fadeLogicTimer then
      self.fadeLogicTimer:Cancel();
    end
    if self.glowLogicTimer then
      self.glowLogicTimer:Cancel();
    end
    --Unload potential waypoint frames that are used for pathing.
    if self.data and self.data.lineFrames then
        for index, lineFrame in pairs(self.data.lineFrames) do
            lineFrame:Unload();
        end
    end

    if self.OnHide then self:OnHide() end -- the event might trigger after OnHide=nil even if its set after self:Hide()
    self:Hide()
    self.glow:Hide()
    self.data = nil -- Just to be safe
    self.loaded = nil
    self.x = nil
    self.y = nil
    self.AreaID = nil
    self.UiMapID = nil
    self.lastGlowFade = nil
    self.worldX = nil
    self.worldY = nil
    QuestieFramePool:RecycleFrame(self)
end

function _Qframe:FadeOut()
    if not self.faded then
        self.faded = true
        if self.texture then
            local r, g, b = self.texture:GetVertexColor()
            self.texture:SetVertexColor(r, g, b, Questie.db.global.iconFadeLevel)
        end
        if self.glowTexture then
            local r, g, b = self.glowTexture:GetVertexColor()
            self.glowTexture:SetVertexColor(r, g, b, Questie.db.global.iconFadeLevel)
        end
    end
end

function _Qframe:FadeIn()
    if self.faded then
        self.faded = nil
        if self.texture then
            local r, g, b = self.texture:GetVertexColor()
            self.texture:SetVertexColor(r, g, b, 1)
        end
        if self.glowTexture then
            local r, g, b = self.glowTexture:GetVertexColor()
            self.glowTexture:SetVertexColor(r, g, b, 1)
        end
    end
end

function _Qframe:FakeHide()
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

function _Qframe:FakeUnhide()
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

---Checks wheather the frame/icon should be hidden or not
---@return boolean @True if the frame/icon should be hidden and :FakeHide should be called, false otherwise
function _Qframe:ShouldBeHidden()
    local questieGlobalDB = Questie.db.global
    if (not Questie.db.char.enabled)
        or ((not questieGlobalDB.enableObjectives) and (self.data.Type == "monster" or self.data.Type == "object" or self.data.Type == "event" or self.data.Type == "item"))
        or ((not questieGlobalDB.enableTurnins) and self.data.Type == "complete")
        or ((not questieGlobalDB.enableAvailable) and self.data.Type == "available")
        or ((not Questie.db.char.showRepeatableQuests) and QuestieDB:IsRepeatable(self.data.Id))
        or ((not Questie.db.char.showEventQuests) and QuestieDB:IsActiveEventQuest(self.data.Id))
        or ((not Questie.db.char.showDungeonQuests) and QuestieDB:IsDungeonQuest(self.data.Id))
        or ((not Questie.db.char.showRaidQuests) and QuestieDB:IsRaidQuest(self.data.Id))
        or ((not Questie.db.char.showPvPQuests) and QuestieDB:IsPvPQuest(self.data.Id))
        or ((not Questie.db.char.showAQWarEffortQuests) and QuestieDB:IsAQWarEffortQuest(self.data.Id))
        or ((not questieGlobalDB.enableMapIcons) and (not self.miniMapIcon))
        or ((not questieGlobalDB.enableMiniMapIcons) and (self.miniMapIcon))
        or (self.data.ObjectiveData and self.data.ObjectiveData.HideIcons)
        or (self.data.QuestData and self.data.QuestData.HideIcons and self.data.Type ~= "complete") then

        return true
    end

    return false
end
