---@class QuestieFramePool
local QuestieFramePool = QuestieLoader:CreateModule("QuestieFramePool")
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local WRAP_TEXT = 1;

local tinsert = table.insert;
local tremove = table.remove;
local _QuestieFramePool = QuestieFramePool.private
_QuestieFramePool.numberOfFrames = 0

_QuestieFramePool.unusedFrames = {}
_QuestieFramePool.usedFrames = {};

_QuestieFramePool.allFrames = {}

_QuestieFramePool.wayPointColor = {1,0.72,0,0.5}
_QuestieFramePool.wayPointColorHover = {0.93,0.46,0.13,0.8}

local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

-- set pins parent to QuestieFrameGroup for easier compatibility with other addons
-- cant use this because it fucks with everything, but we gotta stick with HereBeDragonsQuestie anyway
HBDPins.MinimapGroup = CreateFrame("Frame", "QuestieFrameGroup", Minimap)
--HBDPins:SetMinimapObject(_CreateMinimapParent())


function QuestieFramePool:SetIcons()
    ICON_TYPE_SLAY =  QuestieLib.AddonPath.."Icons\\slay.blp"
    ICON_TYPE_LOOT =  QuestieLib.AddonPath.."Icons\\loot.blp"
    ICON_TYPE_EVENT =  QuestieLib.AddonPath.."Icons\\event.blp"
    ICON_TYPE_OBJECT =  QuestieLib.AddonPath.."Icons\\object.blp"

    -- TODO Add all types (we gotta stop using globals, needs refactoring)
    ICON_TYPE_AVAILABLE =  QuestieLib.AddonPath.."Icons\\available.blp"
    ICON_TYPE_AVAILABLE_GRAY =  QuestieLib.AddonPath.."Icons\\available_gray.blp"
    ICON_TYPE_COMPLETE =  QuestieLib.AddonPath.."Icons\\complete.blp"
    ICON_TYPE_GLOW = QuestieLib.AddonPath.."Icons\\glow.blp"
    ICON_TYPE_REPEATABLE =  QuestieLib.AddonPath.."Icons\\repeatable.blp"
end


StaticPopupDialogs["QUESTIE_CONFIRMHIDE"] = {
    text = "", -- set before showing
    questID = 0, -- set before showing
    button1 = l10n("Yes"),
    button2 = l10n("No"),
    OnAccept = function()
        QuestieQuest:HideQuest(StaticPopupDialogs["QUESTIE_CONFIRMHIDE"].questID)
    end,
    SetQuest = function(self, id)
        self.questID = id
        self.text = l10n("Are you sure you want to hide the quest '%s'?\nIf this quest isn't actually available, please report it to us!", QuestieLib:GetColoredQuestName(id, Questie.db.global.enableTooltipsQuestLevel, false, true))

        -- locale might not be loaded when this is first created (this does happen almost always)
        self.button1 = l10n("Yes")
        self.button2 = l10n("No")
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
---@return IconFrame
function QuestieFramePool:GetFrame()
    --Questie:Debug(DEBUG_SPAM, "[QuestieFramePool:GetFrame]")

    ---@type IconFrame
    local returnFrame = next(_QuestieFramePool.unusedFrames)
    returnFrame = returnFrame and _QuestieFramePool.unusedFrames[returnFrame]

    if returnFrame and returnFrame.frameId and _QuestieFramePool.usedFrames[returnFrame.frameId] then
        -- something went horribly wrong (desync bug?) don't use this frame since its already in use
        --Questie:Debug(DEBUG_SPAM, "[QuestieFramePool:GetFrame] Tried to reuse frame, but that frame is already in use")
        returnFrame = nil
    end
    if not returnFrame then
        returnFrame = _QuestieFramePool:QuestieCreateFrame()
    else
        --Questie:Debug(DEBUG_SPAM, "[QuestieFramePool:GetFrame] Reusing frame")
        _QuestieFramePool.unusedFrames[returnFrame.frameId] = nil
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

    returnFrame.data = nil
    returnFrame.x = nil;
    returnFrame.y = nil;
    returnFrame.AreaID = nil;
    returnFrame.UiMapID = nil

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

function QuestieFramePool:UnloadAll()
    for _, frame in ipairs(_QuestieFramePool.allFrames) do
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

function QuestieFramePool:RecycleFrame(frame)
    --Questie:Debug(DEBUG_SPAM, "[QuestieFramePool:RecycleFrame]")
    _QuestieFramePool.usedFrames[frame.frameId] = nil
    _QuestieFramePool.unusedFrames[frame.frameId] = frame
end

-- Local Functions --

--[[Use FRAME.Unload(FRAME) on frame object to unload!
function _QuestieFramePool:UnloadFrame(frame)
    --We are reseting the frames, making sure that no data is wrong.
  HBDPins:RemoveMinimapIcon(Questie, frame);
  HBDPins:RemoveWorldMapIcon(Questie, frame);
  frame.data = nil; -- Just to be safe
  frame.loaded = nil;
    tinsert(_QuestieFramePool.unusedFrames, frame)
end]]--
function _QuestieFramePool:QuestieCreateFrame()
    --Questie:Debug(DEBUG_SPAM, "[QuestieFramePool:QuestieCreateFrame]")
    _QuestieFramePool.numberOfFrames = _QuestieFramePool.numberOfFrames + 1
    local newFrame = QuestieFramePool.Qframe:New(_QuestieFramePool.numberOfFrames, _QuestieFramePool.QuestieTooltip)

    tinsert(_QuestieFramePool.allFrames, newFrame)
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

---@param iconFrame IconFrame @The parent frame for the current line.
---@param waypointTable table<number, Point> @A table containing waypoints {{X, Y}, ...}
---@param lineWidth number @Width of the line.
---@param color number[] @A table consisting of 4 variable {1, 1, 1, 1} RGB-Opacity
---@return LineFrame[]
function QuestieFramePool:CreateWaypoints(iconFrame, waypointTable, lineWidth, color, areaId)
    local lineFrameList = {}
    local lastPos
    --Set defaults if needed.
    local lWidth = lineWidth or 1.5;
    local col = color or _QuestieFramePool.wayPointColor

    for _, waypointSubTable in pairs(waypointTable) do
        lastPos = nil
        for _, waypoint in pairs(waypointSubTable) do
            if (lastPos == nil) then
                lastPos = waypoint;
            else
                local lineFrame = QuestieFramePool:CreateLine(iconFrame, lastPos[1], lastPos[2], waypoint[1], waypoint[2], lWidth, col, areaId)
                tinsert(lineFrameList, lineFrame);
                lastPos = waypoint;
            end
        end
    end
    return lineFrameList;
end

local lineFrames = 1

---@param iconFrame IconFrame @The parent frame for the current line.
---@param startX number @A value between 0-100
---@param startY number @A value between 0-100
---@param endX number @A value between 0-100
---@param endY number @A value between 0-100
---@param lineWidth number @Width of the line.
---@param color number[] @A table consisting of 4 variable {1, 1, 1, 1} RGB-Opacity
---@return LineFrame
---@class LineFrame @A frame that contains the line used in waypoints.
function QuestieFramePool:CreateLine(iconFrame, startX, startY, endX, endY, lineWidth, color, areaId)

    --Create the framepool for lines if it does not already exist.
    if not QuestieFramePool.Routes_Lines then
        QuestieFramePool.Routes_Lines={}
    end
    --Names are not stricktly needed, but it is nice for debugging.
    local frameName = "questieLineFrame"..lineFrames;

    --tremove default always picks the last element, however counting arrays is kinda bugged? So just get index 1 instead.
    local lineFrame = tremove(QuestieFramePool.Routes_Lines, 1) or CreateFrame("Button", frameName, iconFrame);
    if not lineFrame.frameId then
        lineFrame.frameId = lineFrames;
    end

    local canvas = WorldMapFrame:GetCanvas()

    local width = canvas:GetWidth();
    local height = canvas:GetHeight();

    --Setting the parent is required to get the correct frame levels.

    lineFrame:SetParent(canvas) --This fixes the pan and zoom for lines
    lineFrame:SetFrameLevel(2015) -- This needs to be high, because of the regular WorldMapFrame.ScrollContainer
    lineFrame:SetFrameStrata("FULLSCREEN")

    --How to identify what the frame actually contains, this is not used atm could easily be changed.
    lineFrame.type = "line"

    --Include the line in the iconFrame.
    if (iconFrame.data.lineFrames == nil) then
        iconFrame.data.lineFrames = {};
    end
    tinsert(iconFrame.data.lineFrames, lineFrame);
    lineFrame.iconFrame = iconFrame;
    lineFrame.data = iconFrame.data
    lineFrame.x = (startX + endX) / 2
    lineFrame.y = (startY + endY) / 2
    lineFrame.AreaID = areaId or iconFrame.AreaID
    lineFrame.texture = iconFrame.texture

    function lineFrame:Unload()
        if not self.iconFrame then
            return -- already unloaded
        end
        self:Hide();
        self.iconFrame = nil;
        self.x = nil
        self.y = nil
        self.data = nil
        self.texture = nil
        self.AreaID = nil
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

    local lineBorder = lineFrame.lineBorder or lineFrame:CreateLine();
    lineFrame.lineBorder = lineBorder;

    lineBorder.dR = color[1];
    lineBorder.dG = color[2];
    lineBorder.dB = color[3];
    lineBorder.dA = color[4];
    lineBorder:SetColorTexture(0,0,0,color[4]/2);

    -- Set texture coordinates and anchors
    --line:ClearAllPoints();

    startX = startX * width / 100
    startY = startY * height / -100 -- We do by / -100 due to using the top left point
    endX = endX * width / 100
    endY = endY * height / -100

    width = abs(startX - endX) + lineWidth * 4
    height = abs(startY - endY) + lineWidth * 4

    local framePosX = max(startX, endX) - lineWidth * 2 - width / 2
    local framePosY = min(startY, endY) + lineWidth * 2 + height / 2

    lineFrame:SetHeight(height);
    lineFrame:SetWidth(width);
    lineFrame:SetPoint("TOPLEFT", canvas, "TOPLEFT", framePosX, framePosY)

    line:SetDrawLayer("OVERLAY", -5)
    line:SetStartPoint("TOPLEFT", startX - framePosX, startY - framePosY)
    line:SetEndPoint("TOPLEFT", endX - framePosX, endY - framePosY)
    line:SetThickness(lineWidth);

    lineBorder:SetDrawLayer("OVERLAY", -6)
    lineBorder:SetStartPoint("TOPLEFT", startX - framePosX, startY - framePosY)
    lineBorder:SetEndPoint("TOPLEFT", endX - framePosX, endY - framePosY)
    lineBorder:SetThickness(lineWidth+2);



    lineFrame:EnableMouse(true)

    --lineFrame:SetBackdrop({ -- mouseover debugging
    --    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    --    edgeFile = nil,
    --    edgeSize = 0,
    --    insets = { left = 0, right = 0, top = 0, bottom = 0 },
    --})

    --lineFrame:SetBackdropColor(1,0,1,1)

    lineFrame:SetScript("OnEnter", function(self)
        if self and self.iconFrame then
            local script = self.iconFrame:GetScript("OnEnter")
            if script then
                script(self.iconFrame)
            end
        end
    end)
    lineFrame:SetScript("OnLeave", function(self)
        if self and self.iconFrame then
            local script = self.iconFrame:GetScript("OnLeave")
            if script then
                script(self.iconFrame)
            end
        end
    end)
    lineFrame:RegisterForClicks("RightButtonUp", "LeftButtonUp")
    lineFrame:SetScript("OnClick", function(self, button)
        if self and self.iconFrame then
            local script = self.iconFrame:GetScript("OnClick")
            if script then
                script(self.iconFrame, button)
            end
        end
    end)

    --line:Hide()
    lineFrame:Hide();


    --Should we keep these frames in the questIdFrames? Currently it is also a child of the icon.
    --Maybe the unload of the parent should just unload the children.
    --For safety we check this here too.
    --if (QuestieMap.questIdFrames[lineFrame.iconFrame.data.Id] == nil) then
    --    QuestieMap.questIdFrames[lineFrame.iconFrame.data.Id] = {}
    --end
    --tinsert(QuestieMap.questIdFrames[lineFrame.iconFrame.data.Id], lineFrame:GetName());

    --Keep a total lineFrame count for names.
    lineFrames = lineFrames + 1;
    return lineFrame
end

function _QuestieFramePool:GetAvailableOrCompleteTooltip(icon)
    local tip = {};
    if icon.data.Type == "complete" then
        tip.type = "(" .. l10n("Complete") .. ")";
    else

        local quest = icon.data.QuestData
        local questType, questTag = quest:GetQuestTagInfo();

        if (QuestieDB:IsRepeatable(icon.data.Id)) then
            tip.type = "(" .. l10n("Repeatable") .. ")";
        elseif (questType == 41 or questType == 81 or questType == 83 or questType == 62 or questType == 1) then
            -- Dungeon or Legendary or Raid or Group(Elite)
            tip.type = "("..questTag..")";
        elseif (QuestieEvent and QuestieEvent.activeQuests[icon.data.Id]) then
            tip.type = "(" .. l10n("Event") .. ")";
        else
            tip.type = "(" .. l10n("Available") .. ")";
        end
    end
    tip.title = QuestieLib:GetColoredQuestName(icon.data.Id, Questie.db.global.enableTooltipsQuestLevel, false, true)
    tip.subData = icon.data.QuestData.Description
    tip.questId = icon.data.Id;

    return tip
end

function _QuestieFramePool:GetEventObjectiveTooltip(icon)
    local tip = {
        [icon.data.ObjectiveData.Description] = {},
    }
    if (icon.data.ObjectiveData.Index) then
        local objectiveDesc = icon.data.QuestData.Objectives[icon.data.ObjectiveData.Index].Description;
        tip[icon.data.ObjectiveData.Description][objectiveDesc] = true;
    end
    return tip
end

function _QuestieFramePool:GetObjectiveTooltip(icon)
    local tooltips = {}
    local iconData = icon.data
    local text = iconData.ObjectiveData.Description
    local color = QuestieLib:GetRGBForObjective(iconData.ObjectiveData)
    if iconData.ObjectiveData.Needed then
        text = color .. tostring(iconData.ObjectiveData.Collected) .. "/" .. tostring(iconData.ObjectiveData.Needed) .. " " .. text
    end
    if QuestieComms then
        local anotherPlayer = false;
        local quest = QuestieComms:GetQuest(iconData.Id)
        if quest then
            for playerName, objectiveData in pairs(quest) do
                local playerInfo = QuestiePlayer:GetPartyMemberByName(playerName)
                local playerColor
                local playerType = ""
                if playerInfo then
                    playerColor = "|c" .. playerInfo.colorHex
                else
                    playerColor = QuestieComms.remotePlayerClasses[playerName]
                    if playerColor then
                        playerColor = Questie:GetClassColor(playerColor)
                        playerType = " (".. l10n("Nearby")..")"
                    end
                end
                if playerColor then
                    local objectiveEntry = objectiveData[iconData.ObjectiveIndex]
                    if not objectiveEntry then
                        Questie:Debug(DEBUG_DEVELOP, "[_QuestieFramePool:GetObjectiveTooltip]", "No objective data for quest", quest.Id)
                        objectiveEntry = {} -- This will make "GetRGBForObjective" return default color
                    end
                    local remoteColor = QuestieLib:GetRGBForObjective(objectiveEntry)
                    local colorizedPlayerName = " ("..playerColor..playerName.."|r"..remoteColor..")|r"..playerType
                    local remoteText = iconData.ObjectiveData.Description

                    if objectiveEntry and objectiveEntry.fulfilled and objectiveEntry.required then
                        local fulfilled = objectiveEntry.fulfilled;
                        local required = objectiveEntry.required;
                        remoteText = remoteColor .. tostring(fulfilled) .. "/" .. tostring(required) .. " " .. remoteText .. colorizedPlayerName;
                    else
                        remoteText = remoteColor .. remoteText .. colorizedPlayerName;
                    end
                    local partyMemberTip = {
                        [remoteText] = {},
                    }
                    if iconData.Name then
                        partyMemberTip[remoteText][iconData.Name] = true;
                    end
                    tinsert(tooltips, partyMemberTip);
                    anotherPlayer = true;
                end
            end
            if anotherPlayer then
                local name = UnitName("player");
                local _, classFilename = UnitClass("player");
                local _, _, _, argbHex = GetClassColor(classFilename)
                name = " (|c"..argbHex..name.."|r"..color..")|r";
                text = text .. name;
            end
        end
    end

    local t = {
        [text] = {},
    }
    if iconData.Name then
        t[text][iconData.Name] = true;
    end
    tinsert(tooltips, 1, t);
    return tooltips
end

function _QuestieFramePool:AddTooltipsForQuest(icon, tip, quest, usedText)
    for text, nameTable in pairs(tip) do
        local data = {}
        data[text] = nameTable;
        --Add the data for the first time
        if usedText[text] == nil then
            tinsert(quest, data)
            usedText[text] = true;
        else
            --We want to add more NPCs as possible candidates when shift is pressed.
            if icon.data.Name then
                for dataIndex, _ in pairs(quest) do
                    if quest[dataIndex][text] then
                        quest[dataIndex][text][icon.data.Name] = true;
                    end
                end
            end
        end
    end
end

function _QuestieFramePool:QuestieTooltip()
    --Questie:Debug(DEBUG_DEVELOP, "[_QuestieFramePool:QuestieTooltip]", "minimapIcon =", self.miniMapIcon)

    local _, _, _, alpha = self.texture:GetVertexColor();
    if alpha == 0 then
        Questie:Debug(DEBUG_DEVELOP, "[_QuestieFramePool:QuestieTooltip]", "Alpha of texture is 0, nothing to show")
        return
    end
    if GetTime() - _QuestieFramePool.lastTooltipShowHack < 0.05 and GameTooltip:IsShown() then
        Questie:Debug(DEBUG_DEVELOP, "[_QuestieFramePool:QuestieTooltip]", "Call has been too fast, not showing again")
        return
    end
    _QuestieFramePool.lastTooltipShowHack = GetTime()
    local Tooltip = GameTooltip;
    Tooltip._owner = self;
    Tooltip:SetOwner(self, "ANCHOR_CURSOR"); --"ANCHOR_CURSOR" or (self, self)

    --if QuestieQuest._isResetting then -- temporary fix for lua errors during smoothreset. We need to dig through this and find a proper fix later
    --    Tooltip:SetFrameStrata("TOOLTIP")
    --    Tooltip:Show()
    --    return
    --end

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

    local r, g, b, a = unpack(QuestieMap.zoneWaypointHoverColorOverrides[self.AreaID] or _QuestieFramePool.wayPointColorHover)
    --Highlight waypoints if they exist.
    for _, lineFrame in pairs(self.data.lineFrames or {}) do
      lineFrame.line:SetColorTexture(
        r,g,b,a
        )
    end

    -- FIXME: `data` can be nil here which leads to an error, will have to debug:
    -- https://discordapp.com/channels/263036731165638656/263040777658171392/627808795715960842
    -- happens when a note doesn't get removed after a quest has been finished, see #1170
    -- TODO: change how the logic works, so this [ObjectiveIndex?] can be nil
    -- it is nil on some notes like starters/finishers, because its for objectives. However, it needs to be an number here for duplicate checks
    if self.data.ObjectiveIndex == nil then
        self.data.ObjectiveIndex = 0
    end

    --for k,v in pairs(self.data.tooltip) do
    --Tooltip:AddLine(v);
    --end

    local usedText = {}
    local npcOrder = {};
    local questOrder = {};
    local manualOrder = {}

    self.data.touchedPins = {}
    ---@param icon IconFrame
    local function handleMapIcon(icon)
        local iconData = icon.data

        if iconData == nil then
            Questie:Error("[_QuestieFramePool:QuestieTooltip] handleMapIcon - iconData is nil! self.data.Id =", self.data.Id, "- Aborting!")
            return
        end

        if not icon.miniMapIcon and self.data.Id == iconData.Id then -- Recolor hovered icons
            local entry = {}
            entry.color = {icon.texture.r, icon.texture.g, icon.texture.b, icon.texture.a};
            entry.icon = icon;
            if Questie.db.global.questObjectiveColors then
                icon.texture:SetVertexColor(1, 1, 1, 1); -- If different colors are active simply change it to the regular icon color
            else
                icon.texture:SetVertexColor(0.6, 1, 1, 1); -- Without colors make it blueish
            end
            tinsert(self.data.touchedPins, entry);
        end
        if icon.x and icon.AreaID == self.AreaID then
            local dist = QuestieLib:Maxdist(icon.x, icon.y, self.x, self.y);
            if dist < maxDistCluster then
                if iconData.Type == "available" or iconData.Type == "complete" then
                    if npcOrder[iconData.Name] == nil then
                        npcOrder[iconData.Name] = {};
                    end

                    local tip = _QuestieFramePool:GetAvailableOrCompleteTooltip(icon)
                    npcOrder[iconData.Name][tip.title] = tip
                elseif iconData.ObjectiveData and iconData.ObjectiveData.Description then
                    local key = iconData.Id
                    if not questOrder[key] then
                        questOrder[key] = {};
                    end

                    local orderedTooltips = {}
                    iconData.ObjectiveData:Update()
                    if iconData.Type == "event" then
                        local tip = _QuestieFramePool:GetEventObjectiveTooltip(icon)

                        -- We need to check for duplicates.
                        local add = true;
                        for _, data in pairs(questOrder[key]) do
                            for text, _ in pairs(data) do
                                if (text == iconData.ObjectiveData.Description) then
                                    add = false;
                                    break;
                                end
                            end
                        end
                        if add then
                            questOrder[key] = tip
                        end
                    else
                        local tooltips = _QuestieFramePool:GetObjectiveTooltip(icon)
                        for _, tip in pairs(tooltips) do
                            tinsert(orderedTooltips, 1, tip);
                        end
                        for _, tip in pairs(orderedTooltips) do
                            local quest = questOrder[key]
                            _QuestieFramePool:AddTooltipsForQuest(icon, tip, quest, usedText)
                        end
                    end
                elseif iconData.CustomTooltipData then
                    questOrder[iconData.CustomTooltipData.Title] = {}
                    tinsert(questOrder[iconData.CustomTooltipData.Title], iconData.CustomTooltipData.Body);
                elseif iconData.ManualTooltipData then
                    manualOrder[iconData.ManualTooltipData.Title] = iconData.ManualTooltipData
                end
            end
        end
    end

    if self.miniMapIcon then
        for icon, _ in pairs(HBDPins.activeMinimapPins) do
            handleMapIcon(icon)
        end
    else
        for pin in HBDPins.worldmapProvider:GetMap():EnumeratePinsByTemplate("HereBeDragonsPinsTemplateQuestie") do
            handleMapIcon(pin.icon)
            if pin.icon.data.lineFrames then
                for _, line in pairs(pin.icon.data.lineFrames) do
                    handleMapIcon(line)
                end
            end
        end
    end

    Tooltip.npcOrder = npcOrder
    Tooltip.questOrder = questOrder
    Tooltip.manualOrder = manualOrder
    Tooltip.miniMapIcon = self.miniMapIcon
    Tooltip._Rebuild = function(self)
        local xpString = l10n('xp');
        local shift = IsShiftKeyDown()
        local haveGiver = false -- hack
        local firstLine = true;
        for questTitle, quests in pairs(self.npcOrder) do -- this logic really needs to be improved
            haveGiver = true
            if (firstLine and not shift) then
                self:AddDoubleLine(questTitle, "(".. l10n('Hold Shift')..")", 0.2, 1, 0.2, 0.43, 0.43, 0.43); --"(Shift+click)"
                firstLine = false;
            elseif (firstLine and shift) then
                self:AddLine(questTitle, 0.2, 1, 0.2);
                firstLine = false;
            else
              self:AddLine(questTitle, 0.2, 1, 0.2);
            end
            for _, questData in pairs(quests) do
                if questData.title ~= nil then
                    local quest = QuestieDB:GetQuest(questData.questId)
                    if (quest and shift) then
                        local rewardString = ""
                        local xpReward = GetQuestLogRewardXP(questData.questId)
                        if xpReward > 0 then -- Quest rewards XP
                            rewardString = QuestieLib:PrintDifficultyColor(quest.level, "(".. FormatLargeNumber(xpReward) .. xpString .. ") ")
                        end

                        local moneyReward = GetQuestLogRewardMoney(questData.questId)
                        if moneyReward > 0 then -- Quest rewards money
                            rewardString = rewardString .. Questie:Colorize("("..GetCoinTextureString(moneyReward)..") ", "white")
                        end
                        self:AddDoubleLine("   " .. questData.title, rewardString .. questData.type, 1, 1, 1, 1, 1, 0);
                    else
                        self:AddDoubleLine("   " .. questData.title, questData.type, 1, 1, 1, 1, 1, 0);
                    end
                end
                if questData.subData and shift then
                    local dataType = type(questData.subData)
                    if dataType == "table" then
                        for _, line in pairs(questData.subData) do
                            self:AddLine(line, 0.86, 0.86, 0.86, WRAP_TEXT);
                        end
                    elseif dataType == "string" then
                        self:AddLine(questData.subData, 0.86, 0.86, 0.86, WRAP_TEXT);
                        --self:AddLine("      |cFFDDDDDD" .. v2.subData);
                    end
                end
            end
        end
        ---@param questId QuestId
        for questId, textList in pairs(self.questOrder) do -- this logic really needs to be improved
            ---@type Quest
            local quest = QuestieDB:GetQuest(questId);
            local questTitle = QuestieLib:GetColoredQuestName(questId, Questie.db.global.enableTooltipsQuestLevel, true, true);
            if haveGiver then
                self:AddLine(" ");
                self:AddDoubleLine(questTitle, "(" .. l10n("Active") .. ")", 1, 1, 1, 1, 1, 0);
                haveGiver = false -- looks better when only the first one shows (active)
            else
                local xpReward = GetQuestLogRewardXP(questId)
                if (quest and shift and xpReward > 0) then
                    r, g, b = QuestieLib:GetDifficultyColorPercent(quest.level);
                    self:AddDoubleLine(questTitle, "("..FormatLargeNumber(xpReward)..xpString..")", 0.2, 1, 0.2, r, g, b);
                    firstLine = false;
                elseif (firstLine and not shift) then
                    self:AddDoubleLine(questTitle, "(".. l10n('Hold Shift')..")", 0.2, 1, 0.2, 0.43, 0.43, 0.43); --"(Shift+click)"
                    firstLine = false;
                else
                    self:AddLine(questTitle);
                end
            end

            local function _GetLevelString(creatureLevels, name)
                local levelString = name
                if creatureLevels[name] then
                    local minLevel = creatureLevels[name][1]
                    local maxLevel = creatureLevels[name][2]
                    local rank = creatureLevels[name][3]
                    if minLevel == maxLevel then
                        levelString = name .. " (" .. minLevel
                    else
                        levelString = name .. " (" .. minLevel .. "-" .. maxLevel
                    end

                    if rank and rank == 1 then
                        levelString = levelString .. "+"
                    end

                    levelString = levelString .. ")"
                end
                return levelString
            end

            -- Used to get the white color for the quests which don't have anything to collect
            local defaultQuestColor = QuestieLib:GetRGBForObjective({})
            if shift then
                local creatureLevels = QuestieDB:GetCreatureLevels(quest) -- Data for min and max level
                for _, textData in pairs(textList) do
                    for textLine, nameData in pairs(textData) do
                        local dataType = type(nameData)
                        if dataType == "table" then
                            for name in pairs(nameData) do
                                name = _GetLevelString(creatureLevels, name)
                                self:AddLine("   |cFFDDDDDD" .. name);
                            end
                        elseif dataType == "string" then
                            nameData = _GetLevelString(creatureLevels, nameData)
                            self:AddLine("   |cFFDDDDDD" .. nameData);
                        end
                        self:AddLine("      " .. defaultQuestColor .. textLine);
                    end
                end
            else
                for _, textData in pairs(textList) do
                    for textLine, _ in pairs(textData) do
                        self:AddLine("   " .. defaultQuestColor .. textLine);
                    end
                end
            end
        end
        for title, data in pairs(self.manualOrder) do
            local body = data.Body
            self:AddLine(title)
            for _, stringOrTable in ipairs(body) do
                local dataType = type(stringOrTable)
                if dataType == "string" then
                    self:AddLine(stringOrTable)
                elseif dataType == "table" then
                    self:AddDoubleLine(stringOrTable[1], '|cFFffffff'..stringOrTable[2]..'|r') --normal, white
                end
            end
            if self.miniMapIcon == false and not data.disableShiftToRemove then
                self:AddLine('|cFFa6a6a6Shift-click to hide|r') -- grey
            end
        end
    end
    Tooltip:_Rebuild() -- we separate this so things like MODIFIER_STATE_CHANGED can redraw the tooltip
    Tooltip:SetFrameStrata("TOOLTIP");
    Tooltip:Show();
end
