---@class QuestieNameplate
local QuestieNameplate = QuestieLoader:CreateModule("QuestieNameplate")
local _QuestieNameplate = {}
-------------------------
--Import modules.
-------------------------
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")

local activeGUIDs = {}
local npFrames = {}
local npUnusedFrames = {}
local npFramesCount = 0

local activeTargetFrame


function QuestieNameplate:Initialize()
    -- Nothing to initialize
end

---@param token string
function QuestieNameplate:NameplateCreated(token)
    Questie:Debug(Questie.DEBUG_SPAM, "[QuestieNameplate:NameplateCreated]")
    -- if nameplates are disabled, don't create new nameplates.
    if (not Questie.db.global.nameplateEnabled) then
        return
    end

    -- to avoid memory issues
    if npFramesCount >= 300 then
        return
    end

    local unitGUID = UnitGUID(token)
    local unitName, _ = UnitName(token)

    if (not unitGUID) or (not unitName) then
        return
    end

    local unitType, _, _, _, _, npcId, _ = strsplit("-", unitGUID)
    if unitType ~= "Creature" then
        -- We only draw name plates on NPCs/creatures and skip players, pets, etc
        return
    end

    local icon = _QuestieNameplate.GetValidIcon(QuestieTooltips.lookupByKey["m_" .. npcId])

    if icon then
        activeGUIDs[unitGUID] = token

        local f = _QuestieNameplate.GetFrame(unitGUID)
        f.Icon:SetTexture(icon)
        f.lastIcon = icon -- this is used to prevent updating the texture when it's already what it needs to be
        f:Show()
    end
end

---@param token string
function QuestieNameplate:NameplateDestroyed(token)
    Questie:Debug(Questie.DEBUG_SPAM, "[QuestieNameplate:NameplateDestroyed]")

    if (not Questie.db.global.nameplateEnabled) then
        return
    end

    local unitGUID = UnitGUID(token)

    if unitGUID and activeGUIDs[unitGUID] then
        activeGUIDs[unitGUID] = nil
        _QuestieNameplate.RemoveFrame(unitGUID)
    end
end

function QuestieNameplate:UpdateNameplate()
    Questie:Debug(Questie.DEBUG_SPAM, "[QuestieNameplate:UpdateNameplate]")

    for guid, token in pairs(activeGUIDs) do

        local unitName, _ = UnitName(token)
        local _, _, _, _, _, npcId, _ = strsplit("-", guid)

        if (not unitName) or (not npcId) then
            return
        end

        local icon = _QuestieNameplate.GetValidIcon(QuestieTooltips.lookupByKey["m_" .. npcId])

        if icon then
            local frame = _QuestieNameplate.GetFrame(guid)
            -- check if the texture needs to be changed
            if (not frame.lastIcon) or icon ~= frame.lastIcon then
                frame.lastIcon = icon
                frame.Icon:SetTexture(nil)
                frame.Icon:SetTexture(icon)
            end
        else
            -- tooltip removed but we still have the frame active, remove it
            activeGUIDs[guid] = nil
            _QuestieNameplate.RemoveFrame(guid)
        end
    end
end

function QuestieNameplate:RedrawIcons()
    for _, frame in pairs(npFrames) do
        local iconScale = Questie.db.global.nameplateScale

        frame:SetPoint("LEFT", Questie.db.global.nameplateX, Questie.db.global.nameplateY)
        frame:SetWidth(16 * iconScale)
        frame:SetHeight(16 * iconScale)
    end
end

function QuestieNameplate:HideCurrentFrames()
    for guid, _ in pairs(activeGUIDs) do
        activeGUIDs[guid] = nil
        _QuestieNameplate.RemoveFrame(guid)
    end
end

function QuestieNameplate:DrawTargetFrame()
    Questie:Debug(Questie.DEBUG_SPAM, "[QuestieNameplate:DrawTargetFrame]")

    if (not Questie.db.global.nameplateEnabled) or (not Questie.db.global.nameplateTargetFrameEnabled) then
        return
    end

    -- always remove the previous frame if it exists
    if activeTargetFrame ~= nil then
        activeTargetFrame.Icon:SetTexture(nil)
        activeTargetFrame:Hide()
    end

    local unitGUID = UnitGUID("target")
    local unitName = UnitName("target")

    if (not unitName) or (not unitGUID) then
        -- We need the GUID and name, this should not happen
        return
    end

    local unitType, _, _, _, _, npcId, _ = strsplit("-", unitGUID)
    if unitType ~= "Creature" then
        -- We only draw name plates on NPCs/creatures and skip players, pets, etc
        return
    end

    local icon = _QuestieNameplate.GetValidIcon(QuestieTooltips.lookupByKey["m_" .. npcId])
    if (not icon) then
        return
    end

    if not activeTargetFrame then
        activeTargetFrame = _QuestieNameplate.GetTargetFrameIconFrame()
    end

    activeTargetFrame.Icon:SetTexture(icon)
    activeTargetFrame:Show()
end

function QuestieNameplate:HideCurrentTargetFrame()
    if (not activeTargetFrame) then
        return
    end

    activeTargetFrame.Icon:SetTexture(nil)
    activeTargetFrame:Hide()
    activeTargetFrame = nil
end

function QuestieNameplate:RedrawFrameIcon()
    if (not Questie.db.global.nameplateTargetFrameEnabled) or (not activeTargetFrame) then
        return
    end

    local iconScale = Questie.db.global.nameplateTargetFrameScale
    activeTargetFrame:SetWidth(16 * iconScale)
    activeTargetFrame:SetHeight(16 * iconScale)
    activeTargetFrame:SetPoint("RIGHT", Questie.db.global.nameplateTargetFrameX, Questie.db.global.nameplateTargetFrameY)
end


---@param guid string
function _QuestieNameplate.GetFrame(guid)
    if npFrames[guid] then
        return npFrames[guid]
    end

    local parent = C_NamePlate.GetNamePlateForUnit(activeGUIDs[guid])

    local frame = tremove(npUnusedFrames)

    if (not frame) then
        frame = CreateFrame("Frame")
        npFramesCount = npFramesCount + 1
    end

    local iconScale = Questie.db.global.nameplateScale

    frame:SetFrameStrata("LOW")
    frame:SetFrameLevel(10)
    frame:SetWidth(16 * iconScale)
    frame:SetHeight(16 * iconScale)
    frame:EnableMouse(false)
    frame:SetParent(parent)
    frame:SetPoint("LEFT", Questie.db.global.nameplateX, Questie.db.global.nameplateY)

    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:ClearAllPoints()
    frame.Icon:SetAllPoints(frame)

    npFrames[guid] = frame

    return frame
end

function _QuestieNameplate.GetTargetFrameIconFrame()
    local frame = CreateFrame("Frame")

    local iconScale = Questie.db.global.nameplateTargetFrameScale

    frame:SetFrameStrata("LOW")
    frame:SetFrameLevel(10)
    frame:SetWidth(16 * iconScale)
    frame:SetHeight(16 * iconScale)
    frame:EnableMouse(false)

    local targetFrame = TargetFrame -- Default Blizzard target frame
    if ElvUF_Target then
        targetFrame = ElvUF_Target
    elseif PitBull4_Frames_Target then
        targetFrame = PitBull4_Frames_Target
    elseif SUFUnittarget then
        targetFrame = SUFUnittarget
        frame:SetFrameLevel(SUFUnittarget:GetFrameLevel() + 1)
    end

    frame:SetParent(targetFrame)
    frame:SetPoint("RIGHT", Questie.db.global.nameplateTargetFrameX, Questie.db.global.nameplateTargetFrameY)

    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:ClearAllPoints()
    frame.Icon:SetAllPoints(frame)

    return frame
end

---@param guid string
function _QuestieNameplate.RemoveFrame(guid)
    if (not npFrames[guid]) then
        return
    end

    table.insert(npUnusedFrames, npFrames[guid])
    npFrames[guid].Icon:SetTexture(nil) -- fix for overlapping icons
    npFrames[guid]:Hide()
    npFrames[guid] = nil
end

---@param tooltips table<string, table>
function _QuestieNameplate.GetValidIcon(tooltips) -- helper function to get the first valid (incomplete) icon from the specified tooltip, or nil if there is none
    if (not tooltips) then
        return
    end

    for _, tooltip in pairs(tooltips) do
        if tooltip.objective and tooltip.objective.Update then
            tooltip.objective:Update() -- get latest qlog data if its outdated
            if (not tooltip.objective.Completed) and tooltip.objective.Icon then
                -- If the tooltip icon is ICON_TYPE_OBJECT we use ICON_TYPE_LOOT because NPCs should never show
                -- a cogwheel icon.
                return tooltip.objective.Icon == ICON_TYPE_OBJECT and ICON_TYPE_LOOT or tooltip.objective.Icon
            end
        end
    end
end
