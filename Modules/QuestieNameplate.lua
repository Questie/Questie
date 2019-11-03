---@class QuestieNameplate
local QuestieNameplate = QuestieLoader:CreateModule("QuestieNameplate");
-------------------------
--Import modules.
-------------------------
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips");

local activeGUIDs = {};
local npFrames = {};
local npUnusedFrames = {};
local npFramesCount = 0;

QuestieNameplate.ticker = nil;

-- Initializer
function QuestieNameplate:Initialize()
    QuestieNameplate.ticker = C_Timer.NewTicker(0.5, QuestieNameplate.UpdateNameplate);
end

-- Frame Management
function QuestieNameplate:GetFrame(guid)

    if npFrames[guid] and npFrames[guid] ~= nil then
        return npFrames[guid];
    end

    local parent = C_NamePlate.GetNamePlateForUnit(activeGUIDs[guid]);

    local frame = tremove(npUnusedFrames)

    if(not frame) then
        frame = CreateFrame("Frame");
        npFramesCount = npFramesCount + 1;
    end

    local iconScale = Questie.db.global.nameplateScale;

    frame:SetFrameStrata("LOW");
    frame:SetFrameLevel(10);
    frame:SetWidth(16 * iconScale)
    frame:SetHeight(16 * iconScale)
    frame:EnableMouse(false);
    frame:SetParent(parent);
    frame:SetPoint("LEFT", Questie.db.global.nameplateX, Questie.db.global.nameplateY);

    frame.Icon = frame:CreateTexture(nil, "ARTWORK");
    frame.Icon:ClearAllPoints();
    frame.Icon:SetAllPoints(frame)


    npFrames[guid] = frame;

    return frame;
end

function QuestieNameplate:RedrawIcons()
    for index, frame in pairs(npFrames) do
        local iconScale = Questie.db.global.nameplateScale;

        frame:SetPoint("LEFT", Questie.db.global.nameplateX, Questie.db.global.nameplateY);
        frame:SetWidth(16 * iconScale);
        frame:SetHeight(16 * iconScale);
    end
end

function QuestieNameplate:RemoveFrame(guid)
    if npFrames[guid] then
        table.insert(npUnusedFrames, npFrames[guid])
        npFrames[guid].Icon:SetTexture(nil); -- fix for overlapping icons
        npFrames[guid]:Hide();
        npFrames[guid] = nil;
    end
end

local function _GetValidIcon(tooltip) -- helper function to get the first valid (incomplete) icon from the specified tooltip, or nil if there is none
    if tooltip then
        for _,Quest in pairs(tooltip) do
            if Quest.Objective and Quest.Objective.Update then
                Quest.Objective:Update() -- get latest qlog data if its outdated
                if (not Quest.Objective.Completed) and Quest.Objective.Icon then
                    return Quest.Objective.Icon
                end
            end
        end
    end
    return nil
end

-- Event Handlers
function QuestieNameplate:NameplateCreated(token)
    -- if nameplates are disbaled, don't create new nameplates.
    if not Questie.db.global.nameplateEnabled then return end;

    -- to avoid memory issues
    if npFramesCount >= 300 then
        return
    end

    local unitGUID = UnitGUID(token);
    local unitName, _ = UnitName(token);

    if not unitGUID or not unitName then return end

    -- we only need to use put this over creatures.
    -- to avoid running this code over Pet, Player, etc.
    local unitType, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", unitGUID);

    if unitType == "Creature" then
        local icon = _GetValidIcon(QuestieTooltips.tooltipLookup["m_" .. npc_id]);

        if icon then
            activeGUIDs[unitGUID] = token;

            local f = QuestieNameplate:GetFrame(unitGUID);
            f.Icon:SetTexture(icon)
            f.lastIcon = icon -- this is used to prevent updating the texture when it's already what it needs to be
            f:Show();
        end
    end
end

function QuestieNameplate:NameplateDestroyed(token)

    local unitGUID = UnitGUID(token);

    if unitGUID and activeGUIDs[unitGUID] then
        activeGUIDs[unitGUID] = nil;
        QuestieNameplate:RemoveFrame(unitGUID);
    end

end


function QuestieNameplate:UpdateNameplate(self)

    for guid, token in pairs(activeGUIDs) do

        local unitName, _ = UnitName(token);
        local unitType, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", guid);

        if not unitName or not npc_id then return end

        local icon = _GetValidIcon(QuestieTooltips.tooltipLookup["m_" .. npc_id]);

        if icon then
            local frame = QuestieNameplate:GetFrame(guid);
            -- check if the texture needs to be changed
            if (not frame.lastIcon) or icon ~= frame.lastIcon then
                frame.lastIcon = icon
                frame.Icon:SetTexture(nil);
                frame.Icon:SetTexture(icon);
            end
        else
            -- tooltip removed but we still have the frame active, remove it
            activeGUIDs[guid] = nil;
            QuestieNameplate:RemoveFrame(guid);
        end
    end
end

function QuestieNameplate:HideCurrentFrames()
    for guid, token in pairs(activeGUIDs) do
        activeGUIDs[guid] = nil;
        QuestieNameplate:RemoveFrame(guid);
    end
end


local activeTargetFrame = nil;

function QuestieNameplate:DrawTargetFrame()
    if Questie.db.global.nameplateTargetFrameEnabled then

        -- always remove the previous frame if it exists
        if activeTargetFrame ~= nil then
            activeTargetFrame.Icon:SetTexture(nil);
            activeTargetFrame:Hide();
        end

        local unitGUID = UnitGUID("target");
        local unitName = UnitName("target");

        if unitName and unitGUID then 
            local unitType, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", unitGUID);

            if unitType == "Creature" then

                local icon = _GetValidIcon(QuestieTooltips.tooltipLookup["m_" .. npc_id]);

                if icon then

                    if activeTargetFrame == nil then
                        activeTargetFrame = CreateFrame("Frame");

                        local iconScale = Questie.db.global.nameplateTargetFrameScale;

                        activeTargetFrame:SetFrameStrata("LOW");
                        activeTargetFrame:SetFrameLevel(10);
                        activeTargetFrame:SetWidth(16 * iconScale)
                        activeTargetFrame:SetHeight(16 * iconScale)
                        activeTargetFrame:EnableMouse(false);
                        activeTargetFrame:SetParent(TargetFrame);
                        activeTargetFrame:SetPoint("RIGHT", Questie.db.global.nameplateTargetFrameX, Questie.db.global.nameplateTargetFrameY);

                        activeTargetFrame.Icon = activeTargetFrame:CreateTexture(nil, "ARTWORK");
                        activeTargetFrame.Icon:ClearAllPoints();
                        activeTargetFrame.Icon:SetAllPoints(activeTargetFrame)
                    end

                    activeTargetFrame.Icon:SetTexture(icon)
                    activeTargetFrame:Show();

                end
            end
        end
    end
end

function QuestieNameplate:HideCurrentTargetFrame()
    if activeTargetFrame then
        activeTargetFrame.Icon:SetTexture(nil)
        activeTargetFrame:Hide();
        activeTargetFrame = nil;
    end
end


function QuestieNameplate:RedrawFrameIcon()
    if Questie.db.global.nameplateTargetFrameEnabled then
        if activeTargetFrame then
            local iconScale = Questie.db.global.nameplateTargetFrameScale;
            activeTargetFrame:SetWidth(16 * iconScale);
            activeTargetFrame:SetHeight(16 * iconScale);
            activeTargetFrame:SetPoint("RIGHT", Questie.db.global.nameplateTargetFrameX, Questie.db.global.nameplateTargetFrameY);
        end
    end
end