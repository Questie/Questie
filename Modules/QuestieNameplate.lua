QuestieNameplate = {};

local activeGUIDs = {};
local npFrames = {};
local npUnusedFrames = {};
local npFramesCount = 0;

QuestieNameplate.TimerSet = 0.5;
QuestieNameplate.GlobalFrame = nil;

-- Initializer
function QuestieNameplate:Initialize()
    if QuestieNameplate.GlobalFrame == nil then
        QuestieNameplate.GlobalFrame = CreateFrame("Frame");
        QuestieNameplate.GlobalFrame:SetScript("OnUpdate", QuestieNameplate.UpdateNameplate);
    end

    QuestieNameplate.TimerSet = 2.5;
end

-- Frame Management
function QuestieNameplate:getFrame(guid)

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

    frame:SetFrameStrata("HIGH");
    frame:SetFrameLevel(10);
    frame:SetWidth(16 * iconScale)
    frame:SetHeight(16 * iconScale)
    frame:EnableMouse(false);
    frame:SetParent(parent);
    frame:SetPoint("LEFT", parent, Questie.db.global.nameplateX, Questie.db.global.nameplateY);

    frame.Icon = frame:CreateTexture(nil, "ARTWORK");
    frame.Icon:ClearAllPoints();
    frame.Icon:SetAllPoints(frame)


    npFrames[guid] = frame;

    return frame;
end

function QuestieNameplate:redrawIcons()
    for index, frame in pairs(npFrames) do
        local iconScale = Questie.db.global.nameplateScale;

        frame:SetPoint("LEFT", Questie.db.global.nameplateX, Questie.db.global.nameplateY);
        frame:SetWidth(16 * iconScale);
        frame:SetHeight(16 * iconScale);
    end
end

function QuestieNameplate:removeFrame(guid)
    if npFrames[guid] then
        table.insert(npUnusedFrames, npFrames[guid])
        npFrames[guid].Icon:SetTexture(nil); -- fix for overlapping icons
        npFrames[guid]:Hide();
        npFrames[guid] = nil;
    end
end

-- Event Handlers
function QuestieNameplate:NameplateCreated(token)
    -- to avoid memory issues
    if npFramesCount >= 300 then
        return
    end

    local unitGUID = UnitGUID(token);
    local unitName, _ = UnitName(token);

    if not unitGUID or not unitName then return end

    -- we only need to use put this over creatures.
    -- to avoid running this code over Pet, Player, etc.
    local unitType = strsplit("-", unitGUID);

    if unitType == "Creature" then
        --[[
            Timer hack to account for delay in populating QuestieTooltips
            Without delay, if nameplates start off toggled, then they need to
            be toggled off and back on again or delay 2 seconds apperas instant
            on the client.  Only needs to be run once, controlled with TimerSet.
        ]]
        C_Timer.After(QuestieNameplate.TimerSet, function()
            QuestieNameplate.TimerSet = 0;
            local toKill = QuestieTooltips.tooltipLookup["u_" .. unitName];

            if toKill and toKill[1] and toKill[1].Objective then
                local icon = toKill[1].Objective.Icon

                activeGUIDs[unitGUID] = token;

                local f = QuestieNameplate:getFrame(unitGUID);
                f.Icon:SetTexture(icon)
                f:Show();

            end
        end);
    end
end

function QuestieNameplate:NameplateDestroyed(token)

    local unitGUID = UnitGUID(token);

    if unitGUID and activeGUIDs[unitGUID] then
        activeGUIDs[unitGUID] = nil;
        QuestieNameplate:removeFrame(unitGUID);
    end

end


function QuestieNameplate:UpdateNameplate(self)

    for guid, token in pairs(activeGUIDs) do

        unitName, _ = UnitName(token);

        if not unitName then return end

        local toKill = QuestieTooltips.tooltipLookup["u_" .. unitName];

        if toKill then
            -- see if the mob has no objectives
            if #toKill == 0 then
                activeGUIDs[guid] = nil;
                QuestieNameplate:removeFrame(guid);
            elseif toKill[1] and toKill[1].Objective then
                -- Update to current main objective (first in list)
                if toKill[1].Objective.Completed or (tonumber(toKill[1].Objective.Needed) == tonumber(toKill[1].Objective.Collected) and tonumber(toKill[1].Objective.Needed) > 0) then

                    if toKill[2] and toKill[2].Objective then
                        local frame = QuestieNameplate:getFrame(guid);
                        frame.Icon:SetTexture(nil);
                        frame.Icon:SetTexture(toKill[2].Objective.Icon);
                    else
                        activeGUIDs[guid] = nil;
                        QuestieNameplate:removeFrame(guid);
                    end
                else
                    local frame = QuestieNameplate:getFrame(guid);
                    frame.Icon:SetTexture(nil);
                    frame.Icon:SetTexture(toKill[1].Objective.Icon);
                end
            end
        else
            -- tooltip removed but we still have the frame active, remove it
            print ("In the extra else");
            activeGUIDs[guid] = nil;
            QuestieNameplate:removeFrame(guid);
        end
    end
end
