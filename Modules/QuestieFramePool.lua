QuestieFramePool = {...} -- GLobal Functions
local _QuestieFramePool = {...} --Local Functions
qNumberOfFrames = 0

local unusedframes = {}
local usedFrames = {};

local allframes = {}

--TODO: Add all types
ICON_TYPE_AVAILABLE = "Interface\\Addons\\QuestieDev-master\\Icons\\available.blp"
ICON_TYPE_SLAY = "Interface\\Addons\\QuestieDev-master\\Icons\\slay.blp"
ICON_TYPE_COMPLETE = "Interface\\Addons\\QuestieDev-master\\Icons\\complete.blp"
ICON_TYPE_ITEM = "Interface\\Addons\\QuestieDev-master\\Icons\\item.blp"
ICON_TYPE_LOOT = "Interface\\Addons\\QuestieDev-master\\Icons\\loot.blp"
ICON_TYPE_EVENT = "Interface\\Addons\\QuestieDev-master\\Icons\\event.blp"
ICON_TYPE_OBJECT = "Interface\\Addons\\QuestieDev-master\\Icons\\object.blp"

-- Global Functions --
function QuestieFramePool:GetFrame()
    local f = tremove(unusedframes)
    if not f then
        f = _QuestieFramePool:QuestieCreateFrame()
    end
    if f ~= nil and f.hidden and f._show ~= nil and f._hide ~= nil then -- restore state to normal (toggle questie)
        icon.hidden = false
        icon.Show = icon._show;
        icon.Hide = icon._hide;
    end
    f.fadeLogic = nil
    
    --if f.IsShowing ~= nil and f:IsShowing() then
    f:Hide();
    --end
    
    if f.texture then
        f.texture:SetVertexColor(1, 1, 1, 1)
    end
    f.loaded = true;
    f.shouldBeShowing = false;
    usedFrames[f:GetName()] = f
    return f
end

--for i, frame in ipairs(allframes) do
--    if(frame.loaded == nil)then
--        return frame
--    end
--end

function QuestieFramePool:UnloadAll()

    Questie:Debug(DEBUG_DEVELOP, "[QuestieFramePool] Unloading all frames, count:", #allframes)
    for i, frame in ipairs(allframes) do
        --_QuestieFramePool:UnloadFrame(frame);
        frame:Unload()
    end
    qQuestIdFrames = {}
end


-- Local Functions --

--[[Use FRAME.Unload(FRAME) on frame object to unload!
function _QuestieFramePool:UnloadFrame(frame)
    --We are reseting the frames, making sure that no data is wrong.
  HBDPins:RemoveMinimapIcon(Questie, frame);
  HBDPins:RemoveWorldMapIcon(Questie, frame);
  frame.data = nil; -- Just to be safe
  frame.loaded = nil;
    table.insert(unusedframes, frame)
end]]--

function _QuestieFramePool:QuestieCreateFrame()
    qNumberOfFrames = qNumberOfFrames + 1
    local f = CreateFrame("Button", "QuestieFrame"..qNumberOfFrames, nil)
    if(qNumberOfFrames > 5000) then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieFramePool] Over 5000 frames... maybe there is a leak?", qNumberOfFrames)
    end

    f.glow = CreateFrame("Button", "QuestieFrame"..qNumberOfFrames.."Glow", nil) -- glow frame
    f.glow:SetFrameStrata("TOOLTIP");
    f.glow:SetWidth(18) -- Set these to whatever height/width is needed
    f.glow:SetHeight(18)


    f:SetFrameStrata("TOOLTIP");
    f:SetWidth(16) -- Set these to whatever height/width is needed
    f:SetHeight(16) -- for your Texture
    local t = f:CreateTexture(nil, "TOOLTIP")
    --t:SetTexture("Interface\\Icons\\INV_Misc_Eye_02.blp")
    --t:SetTexture("Interface\\Addons\\!Questie\\Icons\\available.blp")
    t:SetWidth(16)
    t:SetHeight(16)
    t:SetAllPoints(f)

    local glowt = f.glow:CreateTexture(nil, "TOOLTIP")
    glowt:SetWidth(18)
    glowt:SetHeight(18)
    glowt:SetAllPoints(f.glow)

    f.texture = t;
    f.glowTexture = glowt
    f:SetPoint("CENTER", 0, 0)
    f.glow:SetPoint("CENTER", - 1, - 1) -- 2 pixels bigger than normal icon
    f.glow:EnableMouse(false)
    f:EnableMouse(true)--f:EnableMouse()
    --f.mouseIsOver = false;
    --f:SetScript("OnUpdate", function()
    --  local mo = MouseIsOver(self); -- function exists in classic but crashes the game
    --  if mo and (not f.mouseIsOver) then
    --    f.mouseIsOver = true
    --    _QuestieFramePool:Questie_Tooltip(self)
    --  elseif (not mo) and f.mouseIsOver then
    --    f.mouseIsOver = false
    --    if(WorldMapTooltip) then WorldMapTooltip:Hide() end if(GameTooltip) then GameTooltip:Hide() end
    --  end
    --end)

    --f:SetScript('OnEnter', function() Questie:Print("Enter") end)
    --f:SetScript('OnLeave', function() Questie:Print("Leave") end)

    f:SetScript("OnEnter", function(self) _QuestieFramePool:Questie_Tooltip(self) end); --Script Toolip
    f:SetScript("OnLeave", function() if(WorldMapTooltip) then WorldMapTooltip:Hide() end if(GameTooltip) then GameTooltip:Hide() end end) --Script Exit Tooltip
    f:SetScript("OnClick", function(self)
        --_QuestieFramePool:Questie_Click(self)
        if self and self.data and self.data.UiMapID and WorldMapFrame and WorldMapFrame:IsShown() and self.data.UiMapID ~= WorldMapFrame:GetMapID() then
            WorldMapFrame:SetMapID(self.data.UiMapID);
        end
    end);
    f:HookScript("OnUpdate", function(self)
        self.glow:SetPoint("BOTTOMLEFT", self, 1, 1)
    end)
    f:HookScript("OnShow", function(self)
        self.glow:Show()
    end)
    f:HookScript("OnHide", function(self)
        self.glow:Hide()
    end)
    --f.Unload = function(frame) _QuestieFramePool:UnloadFrame(frame) end;
    function f:Unload()
        --We are reseting the frames, making sure that no data is wrong.
        HBDPins:RemoveMinimapIcon(Questie, self);
        HBDPins:RemoveWorldMapIcon(Questie, self);
        if(self.texture) then
            self.texture:SetVertexColor(1, 1, 1, 1);
        end
        self.miniMapIcon = nil;
        self:SetScript("OnUpdate", nil)
        self:Hide();
        --self.glow:Hide()
        self.data = nil; -- Just to be safe
        self.loaded = nil;
        table.insert(unusedframes, self)
        usedFrames[self:GetName()] = nil
    end
    f.data = {}
    f:Hide()
    --f.glow:Hide()
    table.insert(allframes, f)
    return f
end

function QuestieFramePool:euclid(x, y, i, e)
    local xd = math.abs(x - i);
    local yd = math.abs(y - e);
    return math.sqrt(xd * xd + yd * yd);
end

_QuestieFramePool.lastTooltipShowHack = GetTime()
function _QuestieFramePool:Questie_Tooltip(self)
    if GetTime() - _QuestieFramePool.lastTooltipShowHack < 0.05 and GameTooltip:IsShown() then
        return
    end
    _QuestieFramePool.lastTooltipShowHack = GetTime()
    local Tooltip = GameTooltip;
    Tooltip:SetOwner(self, "ANCHOR_CURSOR"); --"ANCHOR_CURSOR" or (self, self)

    local maxDistCluster = 1.5
    local mid = WorldMapFrame:GetMapID();
    if mid == 947 then -- world
        maxDistCluster = 8
    elseif mid == 1415 or mid == 1414 then -- kalimdor/ek
        maxDistCluster = 4
    end
    if not WorldMapFrame:IsShown() then -- this should check if its a minimap note or map note instead, some map addons dont use WorldMapFrame
        maxDistCluster = 0.5
    end
    local already = {}; -- per quest
    local alreadyUnique = {}; -- per objective

    local headers = {};
    local footers = {};
    local contents = {};

    -- TODO: change how the logic works, so this can be nil
    if self.data.ObjectiveIndex == nil then -- it is nil on some notes like starters/finishers, because its for objectives. However, it needs to be an integer here for duplicate checks
        self.data.ObjectiveIndex = 0
    end

    --for k,v in pairs(self.data.tooltip) do
    --Tooltip:AddLine(v);
    --end

    local npcOrder = {};
    local questOrder = {};
    if 1 then
        for _, icon in pairs(usedFrames) do -- I added "usedFrames" because I think its a bit more efficient than using _G but I might be wrong
            if icon and icon.data and icon.x and icon.AreaID == self.AreaID then
                local dist = QuestieFramePool:euclid(icon.x, icon.y, self.x, self.y);
                if dist < maxDistCluster then
                    if icon.data.Type == "available" or icon.data.Type == "complete" then
                        if npcOrder[icon.data.Name] == nil then
                            npcOrder[icon.data.Name] = {};
                        end
                        local dat = {};
                        if icon.data.Type == "complete" then
                            dat.type = "(Complete)";
                        else
                            dat.type = "(Available)";
                        end
                        dat.title = icon.data.QuestData:GetColoredQuestName()
                        npcOrder[icon.data.Name][dat.title] = dat
                        --table.insert(npcOrder[icon.data.Name], dat);
                    elseif icon.data.ObjectiveData and icon.data.ObjectiveData.Description then
                        local key = icon.data.QuestData:GetColoredQuestName();
                        if not questOrder[key] then
                            questOrder[key] = {};
                        end
                        icon.data.ObjectiveData:Update(); -- update progress info
                        if icon.data.Type == "event" then
                            questOrder[key][icon.data.ObjectiveData.Description] = true
                        else
                            local text = icon.data.ObjectiveData.Description
                            if icon.data.ObjectiveData.Needed then
                                text = tostring(icon.data.ObjectiveData.Collected) .. "/" .. tostring(icon.data.ObjectiveData.Needed) .. " " .. text
                            end
                            questOrder[key][text] = true
                            --table.insert(questOrder[key], text);--questOrder[key][icon.data.ObjectiveData.Description] = tostring(icon.data.ObjectiveData.Collected) .. "/" .. tostring(icon.data.ObjectiveData.Needed) .. " " .. icon.data.ObjectiveData.Description--table.insert(questOrder[key], tostring(icon.data.ObjectiveData.Collected) .. "/" .. tostring(icon.data.ObjectiveData.Needed) .. " " .. icon.data.ObjectiveData.Description);
                        end
                    end
                end
            end
        end
    end

    for k, v in pairs(npcOrder) do -- this logic really needs to be improved
        Tooltip:AddLine("|cFF33FF33"..k);
        for k2, v2 in pairs(v) do
            if v2.title ~= nil then
                Tooltip:AddDoubleLine("   " .. v2.title, v2.type);
            end
        end
    end
    for k, v in pairs(questOrder) do -- this logic really needs to be improved
        Tooltip:AddLine(k);
        for k2, v2 in pairs(v) do
            Tooltip:AddLine("   |cFF33FF33" .. k2);
        end
    end
    Tooltip:SetFrameStrata("TOOLTIP");
    QuestieTooltips.lastTooltipTime = GetTime() -- hack for object tooltips
    Tooltip:Show();
end

function _QuestieFramePool:Questie_Click(self)
    Questie:Print("Click!");
    --TODO Logic for click!
    -- Preferably call something outside, keep it "abstract" here
end
