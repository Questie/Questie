QuestieNameplate = {};

local activeGUIDs = {};
local npFrames = {};
local npFramesCount = 0;

QuestieNameplate.TimerSet = 2;

-- Frame Management
-- This was created mostly because the current frame pool doesn't support anything 
-- other than world map frames and didn't want to refactor that right now
function QuestieNameplate:getFrame(guid)

    if npFrames[guid] and npFrames[guid] ~= nil then
        return npFrames[guid];
    end

    local parent = C_NamePlate.GetNamePlateForUnit(guid);

    local frame = CreateFrame("Frame");
    frame:SetFrameStrata("HIGH");
    frame:SetFrameLevel(10);
    frame:SetWidth(16)
	frame:SetHeight(16)
    frame:EnableMouse(false);
    frame:SetParent(parent);
    frame:SetPoint("LEFT", parent, -12, -7);

    frame.Icon = frame:CreateTexture(nil, "ARTWORK");
    frame.Icon:ClearAllPoints();
    frame.Icon:SetTexture(ICON_TYPE_AVAILABLE);
    frame.Icon:SetAllPoints(frame)


    npFrames[guid] = frame;
    npFramesCount = npFramesCount + 1;

    return frame;
end

function QuestieNameplate:removeFrame(guid)
    if npFrames[guid] then
        npFrames[guid]:Hide();
        npFrames[guid] = nil;
    end

    npFramesCount = npFramesCount - 1;
end


-- Event Handlers
function QuestieNameplate:NameplateCreated(token)
    -- to avoid memory issues
    if npFramesCount >= 300 then
        return
    end

    local unitGUID = UnitGUID(token);
    local unitName, _ = UnitName(token);

    -- we only need to use put this over creatures.
    -- to avoid running this code over Pet, Player, etc.
    local unitType = strsplit("-", unitGUID);

    if unitType == "Creature" then

        if unitName then
            --[[
                Timer hack to account for delay in populating QuestieTooltips
                Without delay, if nameplates start off toggled, then they need to
                be toggled off and back on again or delay 2 seconds apperas instant
                on the client.  Only needs to be run once, controlled with Timer set.
            ]]
            C_Timer.After(QuestieNameplate.TimerSet, function()
                QuestieNameplate.TimerSet = 0;
                local toKill = QuestieTooltips.tooltipLookup["u_" .. unitName];

                if toKill then
                    activeGUIDs[token] = unitGUID;

                    local f = QuestieNameplate:getFrame(token);
                    f:Show();

                end
            end);
        end
    end
end

function QuestieNameplate:NameplateDestroyed(token)

    if activeGUIDs[token] then
        activeGUIDs[token] = nil;
        QuestieNameplate:removeFrame(token);
    end
    
end

