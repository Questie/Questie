---@class QuestieFramePool
local QuestieFramePool = QuestieLoader:CreateModule("QuestieFramePool")
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type MapIconTooltip
local MapIconTooltip = QuestieLoader:ImportModule("MapIconTooltip")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

-- set pins parent to QuestieFrameGroup for easier compatibility with other addons
-- cant use this because it fucks with everything, but we gotta stick with HereBeDragonsQuestie anyway
HBDPins.MinimapGroup = CreateFrame("Frame", "QuestieFrameGroup", Minimap)
local WAYPOINT_COLOR = { 1, 0.72, 0, 0.5}

local _QuestieFramePool = {}
local numberOfFrames = 0

local unusedFrames = {}
local usedFrames = {};
local allFrames = {}


function QuestieFramePool:SetIcons()
    ICON_TYPE_SLAY =  QuestieLib.AddonPath.."Icons\\slay.blp"
    ICON_TYPE_LOOT =  QuestieLib.AddonPath.."Icons\\loot.blp"
    ICON_TYPE_EVENT =  QuestieLib.AddonPath.."Icons\\event.blp"
    ICON_TYPE_OBJECT =  QuestieLib.AddonPath.."Icons\\object.blp"
    ICON_TYPE_TALK = QuestieLib.AddonPath.."Icons\\chatbubblegossipicon.blp"

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
    --Questie:Debug(Questie.DEBUG_SPAM, "[QuestieFramePool:GetFrame]")

    ---@type IconFrame
    local returnFrame = next(unusedFrames)
    returnFrame = returnFrame and unusedFrames[returnFrame]

    if returnFrame and returnFrame.frameId and usedFrames[returnFrame.frameId] then
        -- something went horribly wrong (desync bug?) don't use this frame since its already in use
        Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieFramePool:GetFrame] Tried to reuse frame, but that frame is already in use. frameId:", returnFrame.frameId)
        returnFrame = nil
    end
    if not returnFrame then
        returnFrame = _QuestieFramePool:QuestieCreateFrame()
    else
        --Questie:Debug(Questie.DEBUG_SPAM, "[QuestieFramePool:GetFrame] Reusing frame")
        unusedFrames[returnFrame.frameId] = nil
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

    usedFrames[returnFrame.frameId] = returnFrame
    return returnFrame
end

function QuestieFramePool:UpdateGlowConfig(mini, mode)
    if mode then
        for _, icon in pairs(usedFrames) do
            if (((mini and icon.miniMapIcon) or not mini) and icon.glow) and icon.IsShown and icon:IsShown() then
                icon:GetScript("OnShow")(icon) -- forces a glow update
            end
        end
    else
        for _, icon in pairs(usedFrames) do
            if ((mini and icon.miniMapIcon) or (not mini and not icon.miniMapIcon)) and icon.glow then
                icon.glow:Hide()
            end
        end
    end
end

function QuestieFramePool:UpdateColorConfig(mini, enable)
    if enable then
        for _, icon in pairs(usedFrames) do
            if (mini and icon.miniMapIcon) or (not mini and not icon.miniMapIcon) then
                local colors = {1, 1, 1}
                if icon.data.IconColor ~= nil then
                    colors = icon.data.IconColor
                end
                icon.texture:SetVertexColor(colors[1], colors[2], colors[3], 1)
            end
        end
    else
        for _, icon in pairs(usedFrames) do
            if (mini and icon.miniMapIcon) or (not mini and not icon.miniMapIcon) then
                icon.texture:SetVertexColor(1, 1, 1, 1)
            end
        end
    end
end

function QuestieFramePool:RecycleFrame(frame)
    --Questie:Debug(Questie.DEBUG_SPAM, "[QuestieFramePool:RecycleFrame]")
    usedFrames[frame.frameId] = nil
    unusedFrames[frame.frameId] = frame
end

function _QuestieFramePool:QuestieCreateFrame()
    --Questie:Debug(Questie.DEBUG_SPAM, "[QuestieFramePool:QuestieCreateFrame]")
    numberOfFrames = numberOfFrames + 1
    local newFrame = QuestieFramePool.Qframe:New(numberOfFrames, MapIconTooltip.Show)

    tinsert(allFrames, newFrame)
    return newFrame
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
    local col = color or WAYPOINT_COLOR

    for _, waypointSubTable in pairs(waypointTable) do
        lastPos = nil
        for _, waypoint in pairs(waypointSubTable) do
            if lastPos then
                local lineFrame = QuestieFramePool:CreateLine(iconFrame, lastPos[1], lastPos[2], waypoint[1], waypoint[2], lWidth, col, areaId)
                tinsert(lineFrameList, lineFrame);
            end
            lastPos = waypoint
        end
    end
    return lineFrameList;
end

local lineFrameCount = 1

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
    local frameName = "questieLineFrame".. lineFrameCount;

    --tremove default always picks the last element, however counting arrays is kinda bugged? So just get index 1 instead.
    local lineFrame = tremove(QuestieFramePool.Routes_Lines, 1) or CreateFrame("Button", frameName, iconFrame);
    if not lineFrame.frameId then
        lineFrame.frameId = lineFrameCount;
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
    if not iconFrame.data.lineFrames then
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

    --- This is needed because HBD will show the icons again after switching zones and stuff like that
    function lineFrame:FakeHide()
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

    --- This is needed because HBD will show the icons again after switching zones and stuff like that
    function lineFrame:FakeShow()
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

    lineFrame:Hide();


    --Should we keep these frames in the questIdFrames? Currently it is also a child of the icon.
    --Maybe the unload of the parent should just unload the children.
    --For safety we check this here too.
    --if (QuestieMap.questIdFrames[lineFrame.iconFrame.data.Id] == nil) then
    --    QuestieMap.questIdFrames[lineFrame.iconFrame.data.Id] = {}
    --end
    --tinsert(QuestieMap.questIdFrames[lineFrame.iconFrame.data.Id], lineFrame:GetName());

    --Keep a total lineFrame count for names.
    lineFrameCount = lineFrameCount + 1;
    return lineFrame
end
