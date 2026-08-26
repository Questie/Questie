---@class QuestieFrame
local QuestieFrame = QuestieLoader:CreateModule("QuestieFrame")
local _QuestieFrame = QuestieFrame.private

---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieDBMIntegration
local QuestieDBMIntegration = QuestieLoader:ImportModule("QuestieDBMIntegration")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")

local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

---@class IconData
---@field Id QuestId
---@field Type string
---@field Icon number
---@field GetIconScale fun(): number
---@field IconScale number
---@field QuestData Quest
---@field Name string
---@field IsObjectiveNote boolean
---@field StarterType string|nil

---@class IconTexture : Texture
---@field r number
---@field g number
---@field b number
---@field a number
---@field OLDSetVertexColor function

---@param frameId number
---@param OnEnter function
---@return IconFrame
function QuestieFrame.CreateIconFrame(frameId, OnEnter)
    ---@class IconFrame : Button
    ---@field isManualIcon boolean
    ---@field data IconData
    local newFrame = CreateFrame("Button", "QuestieFrame" .. frameId)
    newFrame.frameId = frameId

    -- Add the frames to the ignore list of the Minimap Button Bag (MBB) addon
    -- This is quite ugly but the only thing we can do currently from our side
    -- Check #1504
    if MBB_Ignore then
        tinsert(MBB_Ignore, newFrame:GetName())
    end

    newFrame:SetSize(16, 16) -- irrelevant as gets resized when used

    -- IconFrame has 3 textures:
    --     .texture is the main texture
    --     .overlayTexture infront of the main one
    --     .glowTexture behind the main one
    --   All these textures are always in the "OVERLAY" drawlayer and each texture has sublayer set to define ordering within the IconFrame.
    -- IconFrames itself are ordered behind/infront of each other by FrameLevel.
    -- Frames having same FrameLevel (and Strata) show up inorder which is first :Show() (explicit or implicit).
    --! Do not :SetDrawLayer() for these textures. Use parent frame FrameLevel for z-ordering as needed elsewhere in code.

    ---@type IconTexture
    local texture = newFrame:CreateTexture(nil, "OVERLAY", nil, 0)
    texture:SetAllPoints(newFrame) -- Always same size and location as newFrame
    texture:SetTexelSnappingBias(0)
    texture:SetSnapToPixelGrid(false)
    -- .texture is shown always when newFrame is shown. No :Hide() or :Show()

    local overlayTexture = newFrame:CreateTexture(nil, "OVERLAY", nil, 1)
    overlayTexture:SetAllPoints(newFrame) -- Always same size and location as newFrame
    overlayTexture:SetTexelSnappingBias(0)
    overlayTexture:SetSnapToPixelGrid(false)
    overlayTexture:Hide()

    ---@type IconTexture
    local glowTexture = newFrame:CreateTexture(nil, "OVERLAY", nil, -1)
    glowTexture:SetPoint("CENTER", 0, 0) -- Center of the newFrame
    glowTexture:SetTexelSnappingBias(0)
    glowTexture:SetSnapToPixelGrid(false)
    glowTexture:SetSize(18, 18) -- irrelevant as gets resized when used
    glowTexture:SetTexture(Questie.icons["glow"]) -- Always same texture
    glowTexture:Hide()

    -- Replace SetVertexColor method
    texture.OLDSetVertexColor = texture.SetVertexColor
    texture.SetVertexColor = _QuestieFrame.SetVertexColor
    texture:SetVertexColor(1, 1, 1, 1)

    -- Replace SetVertexColor method
    glowTexture.OLDSetVertexColor = glowTexture.SetVertexColor
    glowTexture.SetVertexColor = _QuestieFrame.SetVertexColor
    glowTexture:SetVertexColor(1, 1, 1, 1)

    newFrame.texture = texture
    newFrame.glowTexture = glowTexture
    newFrame.overlayTexture = overlayTexture

    newFrame:SetScript("OnEnter", OnEnter); --Script Toolip
    newFrame:SetScript("OnLeave", _QuestieFrame.OnLeave) --Script Exit Tooltip
    newFrame:RegisterForClicks("RightButtonUp", "LeftButtonUp")
    newFrame:SetScript("OnClick", _QuestieFrame.OnClick);

    newFrame.GlowUpdate = _QuestieFrame.GlowUpdate
    newFrame.BaseOnShow = _QuestieFrame.BaseOnShow
    newFrame.BaseOnHide = _QuestieFrame.BaseOnHide

    newFrame.UpdateTexture = _QuestieFrame.UpdateTexture
    newFrame.Unload = _QuestieFrame.Unload

    -- functions for fake hide/unhide
    newFrame.FadeOut = _QuestieFrame.FadeOut
    newFrame.FadeIn = _QuestieFrame.FadeIn
    newFrame.FakeHide = _QuestieFrame.FakeHide
    newFrame.FakeShow = _QuestieFrame.FakeShow
    newFrame.OnShow = _QuestieFrame.OnShow
    newFrame.OnHide = _QuestieFrame.OnHide
    newFrame.ShouldBeHidden = _QuestieFrame.ShouldBeHidden

    newFrame.data = nil
    newFrame:Hide()

    return newFrame
end

---@param self IconFrame
function _QuestieFrame.OnLeave(self)
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
        for _, lineFrame in pairs(self.data.lineFrames) do
            local line = lineFrame.line
            line:SetColorTexture(line.dR, line.dG, line.dB, line.dA)
        end
    end

    if self.data.touchedPins then
        for i = #self.data.touchedPins, 1, -1 do
            local entry = self.data.touchedPins[i]
            local icon = entry.icon;
            icon.texture:SetVertexColor(unpack(entry.color));
        end
        self.data.touchedPins = nil;
    end
    GameTooltip.ShownAsMapIcon = false
end

---@param self IconTexture
---@param r number
---@param g number
---@param b number
---@param a number
function _QuestieFrame.SetVertexColor(self, r, g, b, a)
    self:OLDSetVertexColor(r, g, b, a)
    --We save the colors to the texture object, this way we don't need to use GetVertexColor
    self.r = r or 1
    self.g = g or 1
    self.b = b or 1
    self.a = a or 1
end

---@param self IconFrame
function _QuestieFrame.OnClick(self, button)
    local uiMapId = self.UiMapID

    if uiMapId and WorldMapFrame:IsShown() and (not IsModifierKeyDown()) and (not self.miniMapIcon) then
        local currentMapId = WorldMapFrame:GetMapID()
        if button == "RightButton" then
            local mapInfo = C_Map.GetMapInfo(currentMapId)
            local currentMapParent = mapInfo.parentMapID

            if currentMapParent and currentMapParent > 0 then
                WorldMapFrame:SetMapID(currentMapParent)
            end
        else
            if uiMapId ~= currentMapId then
                WorldMapFrame:SetMapID(uiMapId);
            end
        end
    else
        -- This will work in either the WorldMapFrame or the MiniMapFrame as long as there is an icon
        if uiMapId and button == "LeftButton" then
            local frameData = self.data
            if ChatEdit_GetActiveWindow() and frameData.QuestData then
                if Questie.db.profile.trackerShowQuestLevel then
                    ChatEdit_InsertLink(QuestieLink:GetQuestLinkStringById(frameData.Id))
                else
                    ChatEdit_InsertLink("[" .. frameData.QuestData.name .. " (" .. frameData.Id .. ")]")
                end
            else
                if frameData.Type == "available" and IsShiftKeyDown() then
                    StaticPopupDialogs["QUESTIE_CONFIRMHIDE"]:SetQuest(frameData.Id)
                    StaticPopup_Show("QUESTIE_CONFIRMHIDE")
                elseif frameData.Type == "manual" and IsShiftKeyDown() and (not frameData.ManualTooltipData.disableShiftToRemove) then
                    QuestieMap:UnloadManualFrames(frameData.id)
                end
            end
        end
    end

    -- TomTom integration
    if uiMapId and IsControlKeyDown() and TomTom and TomTom.AddWaypoint then
        local x = self.x / 100
        local y = self.y / 100
        local title = self.data.Name
        local add = true

        -- Remove old waypoint if set
        if Questie.db.char._tom_waypoint and TomTom.RemoveWaypoint then
            local waypoint = Questie.db.char._tom_waypoint
            TomTom:RemoveWaypoint(waypoint)
            add = (waypoint[1] ~= uiMapId or waypoint[2] ~= x or waypoint[3] ~= y or waypoint.title ~= title or waypoint.from ~= "Questie")
        end

        -- Add waypoint
        Questie.db.char._tom_waypoint = add and TomTom:AddWaypoint(uiMapId, x, y, {title = title, crazy = true, from = "Questie"})
    end

    -- Make sure we don't break the map ping feature - this allows us to ping our own icons.
    if self.miniMapIcon and button == "RightButton" and (not IsModifierKeyDown()) then
        local _, _, _, x, y = self:GetPoint()
        Minimap:PingLocation(x, y)
    end
end

---@param self IconFrame
function _QuestieFrame.GlowUpdate(self)
    if self.glowTexture:IsShown() then
        --Due to this always being 1:1 we can assume that if one isn't correct, the other isn't either
        --We can also assume that both change at the same time so we only check one.
        if (self.glowTexture:GetWidth() ~= self:GetWidth() * 1.13) then ---self.glowTexture:GetHeight() ~= self:GetHeight() * 1.13
            self.glowTexture:SetSize(self:GetWidth() * 1.13, self:GetHeight() * 1.13)
        end
        if self.data and self.data.ObjectiveData and self.data.ObjectiveData.Color then
            --Due to us now saving the alpha inside of the texture we don't need to check the main texture anymore.
            --The question is is it faster to get and compare or just set straight up?
            if (self.glowTexture.r ~= self.data.ObjectiveData.Color[1] or self.glowTexture.g ~= self.data.ObjectiveData.Color[2] or self.glowTexture.b ~= self.data.ObjectiveData.Color[3] or self.texture.a ~= self.glowTexture.a) then
                self.glowTexture:SetVertexColor(self.data.ObjectiveData.Color[1], self.data.ObjectiveData.Color[2], self.data.ObjectiveData.Color[3],
                    self.texture.a or 1)
            end
        end
    end
end

---@param self IconFrame
function _QuestieFrame.BaseOnShow(self)
    local data = self.data

    if ((self.miniMapIcon and Questie.db.profile.alwaysGlowMinimap) or ((not self.miniMapIcon) and Questie.db.profile.alwaysGlowMap)) and
        data and data.ObjectiveData and
        data.ObjectiveData.Color and
        (data.Type and (data.Type ~= "available" and data.Type ~= "complete")
        ) then
        self.glowTexture:SetSize(self:GetWidth() * 1.13, self:GetHeight() * 1.13)
        local _, _, _, alpha = self.texture:GetVertexColor()
        self.glowTexture:SetVertexColor(data.ObjectiveData.Color[1], data.ObjectiveData.Color[2], data.ObjectiveData.Color[3], alpha or 1)
        self.glowTexture:Show()
    end
end

---@param self IconFrame
function _QuestieFrame.BaseOnHide(self)
    self.glowTexture:Hide()
end

---@param self IconFrame
function _QuestieFrame.UpdateTexture(self, texture)
    --Different settings depending on noteType
    local globalScale
    local objectiveColor
    local alpha

    if (self.miniMapIcon) then
        globalScale = Questie.db.profile.globalMiniMapScale;
        objectiveColor = Questie.db.profile.questMinimapObjectiveColors;
        alpha = 0;
    else
        globalScale = Questie.db.profile.globalScale;
        objectiveColor = Questie.db.profile.questObjectiveColors;
        alpha = 1;
    end

    self.texture:SetTexture(texture)
    --self.data.Icon = texture;
    local colors = {1, 1, 1}

    if self.data.StarterType then
        if self.data.StarterType == "itemFromMonster" or self.data.StarterType == "itemFromObject" then
            self.overlayTexture:SetTexture("Interface/AddOns/Questie/Icons/loot_overlay.png")
        elseif self.data.StarterType == "Object" then
            self.overlayTexture:SetTexture("Interface/AddOns/Questie/Icons/object_overlay.png")
        end
        self.overlayTexture:Show()
    else
        self.overlayTexture:Hide()
        self.overlayTexture:SetTexture() -- clear the texture
    end

    --[[if self.data.FinisherType then
        if self.data.FinisherType == "Object" then
            self.overlayTexture:SetTexture("Interface/AddOns/Questie/Icons/object_overlay.png")
        end
        self.overlayTexture:Show()
    else
        self.overlayTexture:Hide()
        self.overlayTexture:SetTexture()
    end]] -- need to see why followup quest from object has no cogwheel anymore

    if self.data.IconColor ~= nil and objectiveColor then
        colors = self.data.IconColor
    end
    self.texture:SetVertexColor(colors[1], colors[2], colors[3], alpha);

    if self.data.IconScale then
        local scale = 16 * ((self.data:GetIconScale() or 1) * (globalScale or 0.7));
        self:SetSize(scale, scale)
    else
        self:SetSize(16, 16)
    end

    -- Party member objectives (quests the local player does not have) are dimmed so they are
    -- visually distinct from the player's own quest icons. Frame alpha composes with the
    -- texture/minimap fade alpha. Runs on every draw, so recycled frames reset to 1.
    if self.data.ObjectiveData and self.data.ObjectiveData.IsPartyObjective then
        self:SetAlpha(0.5)
    else
        self:SetAlpha(1)
    end
end

---@param self IconFrame
function _QuestieFrame.Unload(self)
    if not self._loaded then
        self._needsUnload = true
        return -- icon is still in the draw queue
    end
    self._needsUnload = nil
    self._loaded = nil

    self:SetScript("OnShow", nil)
    self:SetScript("OnHide", nil)
    self.isManualIcon = false

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

    self.texture:SetVertexColor(1, 1, 1, 1)
    self.miniMapIcon = nil;

    --Unload potential waypoint frames that are used for pathing.
    if self.data and self.data.lineFrames then
        for _, lineFrame in pairs(self.data.lineFrames) do
            lineFrame:Unload();
        end
    end

    if self.OnHide then self:OnHide() end -- the event might trigger after OnHide=nil even if its set after self:Hide()
    self:Hide()
    self.glowTexture:Hide()
    self.overlayTexture:Hide()
    self.data = nil -- Just to be safe
    self.x = nil
    self.y = nil
    self.AreaID = nil
    self.UiMapID = nil
    self.lastGlowFade = nil
    self.worldX = nil
    self.worldY = nil
end

---@param self IconFrame
function _QuestieFrame.FadeOut(self)
    if not self.faded then
        self.faded = true
        local r, g, b = self.texture:GetVertexColor()
        self.texture:SetVertexColor(r, g, b, Questie.db.profile.iconFadeLevel)
        r, g, b = self.glowTexture:GetVertexColor()
        self.glowTexture:SetVertexColor(r, g, b, Questie.db.profile.iconFadeLevel)
        if self.data.lineFrames then
            for _, lineFrame in pairs(self.data.lineFrames) do
                local line = lineFrame.line
                if line then
                    line:SetColorTexture(line.dR, line.dG, line.dB, Questie.db.global.iconFadeLevel)
                end
            end
        end
    end
end

---@param self IconFrame
function _QuestieFrame.FadeIn(self)
    if self.faded then
        self.faded = nil
        local r, g, b = self.texture:GetVertexColor()
        self.texture:SetVertexColor(r, g, b, 1)
        r, g, b = self.glowTexture:GetVertexColor()
        self.glowTexture:SetVertexColor(r, g, b, 1)
        if self.data.lineFrames then
            for _, lineFrame in pairs(self.data.lineFrames) do
                local line = lineFrame.line
                if line then
                    line:SetColorTexture(line.dR, line.dG, line.dB, line.dA)
                end
            end
        end
    end
end

--- This is needed because HBD will show the icons again after switching zones and stuff like that
---@param self IconFrame
function _QuestieFrame.FakeHide(self)
    if not self.hidden then
        self.shouldBeShowing = self:IsShown();
        self._show = self.Show;
        self.Show = function()
            self.shouldBeShowing = true;
        end
        self:Hide();
        if self.data.lineFrames then
            for _, line in pairs(self.data.lineFrames) do
                line:FakeHide()
            end
        end
        self._hide = self.Hide;
        self.Hide = function()
            self.shouldBeShowing = false;
        end
        self.hidden = true
    end
end

--- This is needed because HBD will show the icons again after switching zones and stuff like that
---@param self IconFrame
function _QuestieFrame.FakeShow(self)
    if self.hidden then
        self.hidden = false
        self.Show = self._show;
        self.Hide = self._hide;
        self._show = nil
        self._hide = nil
        if self.shouldBeShowing then
            self:Show();
            if self.data.lineFrames then
                for _, line in pairs(self.data.lineFrames) do
                    line:FakeShow()
                end
            end
        end
    end
end

---Checks wheather the frame/icon should be hidden or not. Only for quest icons/frames.
---@param self IconFrame
---@return boolean @True if the frame/icon should be hidden and :FakeHide() should be called, false otherwise
function _QuestieFrame.ShouldBeHidden(self)
    local profile = Questie.db.profile
    local data = self.data
    local iconType = data.Type -- v6.5.1 values: available, complete, manual, monster, object, item, event. This function is not called with manual.
    local questId = data.Id

    local IsSoD = Questie.IsSoD

    --investigate quest and cache results to minimize DB lookups
    local repeatable = QuestieDB.IsRepeatable(questId)
    local event = QuestieDB.IsActiveEventQuest(questId)
    local dungeon = QuestieDB.IsDungeonQuest(questId)
    local raid = QuestieDB.IsRaidQuest(questId)
    local pvp = QuestieDB.IsPvPQuest(questId)
    local normal = not (repeatable or event or dungeon or raid or pvp)
    local itemStart = (data.StarterType ~= nil)

    if (not profile.enabled) -- all quest icons disabled
        or ((not profile.enableMapIcons) and (not self.miniMapIcon))
        or ((not profile.enableMiniMapIcons) and (self.miniMapIcon))
        or ((not profile.enableTurnins) and iconType == "complete")
        or ((not profile.enableObjectives) and (iconType == "monster" or iconType == "object" or iconType == "event" or iconType == "item"))
        or (profile.hideUnexploredMapIcons and not QuestieMap.utils.IsExplored(self.UiMapID, self.x, self.y)) -- Hides unexplored map icons
        or (profile.hideUntrackedQuestsMapIcons and iconType ~= "available" and not QuestieQuest:ShouldShowQuestNotes(questId)) -- Hides untracked map icons
        or (data.ObjectiveData and data.ObjectiveData.HideIcons)
        or (data.QuestData and data.QuestData.HideIcons and iconType ~= "complete")
        -- Hide only available quest icons of following quests. I.e. show objectives and complete icons always (when they are in questlog).
        -- i.e. (iconType == "available")  ==  (iconType ~= "monster" and iconType ~= "object" and iconType ~= "event" and iconType ~= "item" and iconType ~= "complete"):
        or (iconType == "available"
            and (
                ((not profile.enableAvailable) and normal)
                or ((not profile.showRepeatableQuests) and repeatable)
                or ((not profile.showEventQuests) and event)
                or ((not profile.showDungeonQuests) and dungeon)
                or ((not profile.showRaidQuests) and raid)
                or ((not profile.showPvPQuests) and pvp)
                or ((not profile.enableAvailableItems) and itemStart)
                or (IsSoD and QuestieDB.IsRuneAndShouldBeHidden(questId))
            -- this quest group isn't loaded at all while disabled:
            -- or ((not questieCharDB.showAQWarEffortQuests) and QuestieQuestBlacklist.AQWarEffortQuests[questId])
            )
        )
    then
        return true
    end

    return false
end
