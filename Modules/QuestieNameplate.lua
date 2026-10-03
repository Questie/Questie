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


---@param token string
function QuestieNameplate:NameplateCreated(token)
    Questie.Debug(Questie.DEBUG_SPAM, "[QuestieNameplate:NameplateCreated]")
    -- if nameplates are disabled, don't create new nameplates.
    if (not Questie.db.profile.nameplateEnabled) or (Questie.IsForever and IsInInstance()) then
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

    local unitType, _, _, _, _, _, _ = strsplit("-", unitGUID)
    if unitType ~= "Creature" and unitType ~= "Vehicle" then
        -- We only draw name plates on NPCs/creatures and Vehicles (oddness with Chillmaw being a Vehicle?!?!) and skip players, pets, etc
        return
    end

    -- Fetch icon and objective count
    local formatMode = tonumber(Questie.db.profile.nameplateCountFormat) or 0
    local icon, countText = _QuestieNameplate.GetIconAndCount(unitGUID, formatMode)

    if icon then
        activeGUIDs[unitGUID] = token

        local frame = _QuestieNameplate.GetFrame(unitGUID)
        if frame.lastIcon ~= icon then
            frame.lastIcon = icon
            frame.Icon:SetTexture(icon)
        end

        if frame.CountText then
            if frame.lastCountText ~= countText then
                frame.lastCountText = countText
                frame.CountText:SetText(countText)
            end
        end

        frame:Show()
    end
end

---@param token string
function QuestieNameplate:NameplateDestroyed(token)
    Questie.Debug(Questie.DEBUG_SPAM, "[QuestieNameplate:NameplateDestroyed]")

    if (not Questie.db.profile.nameplateEnabled) or (Questie.IsForever and IsInInstance()) then
        return
    end

    local unitGUID = UnitGUID(token)

    if unitGUID and activeGUIDs[unitGUID] then
        activeGUIDs[unitGUID] = nil
        _QuestieNameplate.RemoveFrame(unitGUID)
    end
end

function QuestieNameplate:UpdateNameplate()
    Questie.Debug(Questie.DEBUG_SPAM, "[QuestieNameplate:UpdateNameplate]")

    local formatMode = tonumber(Questie.db.profile.nameplateCountFormat) or 0

    for guid, token in pairs(activeGUIDs) do
        local unitName, _ = UnitName(token)
        if unitName then
            local icon, countText = _QuestieNameplate.GetIconAndCount(guid, formatMode)

            if icon then
                local frame = _QuestieNameplate.GetFrame(guid)
                -- check if the texture needs to be changed
                if frame.lastIcon ~= icon then
                    frame.lastIcon = icon
                    frame.Icon:SetTexture(icon)
                end

                if frame.CountText then
                    if frame.lastCountText ~= countText then
                        frame.lastCountText = countText
                        frame.CountText:SetText(countText)
                    end
                end
            else
                -- tooltip removed but we still have the frame active, remove it
                activeGUIDs[guid] = nil
                _QuestieNameplate.RemoveFrame(guid)
            end
        end
    end

    if UnitExists("target") then
        QuestieNameplate:DrawTargetFrame()
    else
        QuestieNameplate:HideCurrentTargetFrame()
    end
end

---@param xPos number
---@param yPos number
---@param scale number
function QuestieNameplate.SetIconPosition(xPos, yPos, scale)
    QuestieNameplate.SetIconXPosition(xPos)
    QuestieNameplate.SetIconYPosition(yPos)
    QuestieNameplate.SetIconScale(scale)

    QuestieNameplate:RedrawIcons()
end

---@param xPos number
function QuestieNameplate.SetIconXPosition(xPos)
    if (type(xPos) ~= "number") then
        return
    end

    Questie.db.profile.nameplateX = xPos
end

---@param yPos number
function QuestieNameplate.SetIconYPosition(yPos)
    if (type(yPos) ~= "number") then
        return
    end

    Questie.db.profile.nameplateY = yPos
end

---@param scale number
function QuestieNameplate.SetIconScale(scale)
    if (type(scale) ~= "number") then
        return
    end

    Questie.db.profile.nameplateScale = scale
end

function QuestieNameplate:RedrawIcons()
    local formatMode = tonumber(Questie.db.profile.nameplateCountFormat) or 0

    for guid, frame in pairs(npFrames) do
        local iconScale = Questie.db.profile.nameplateScale

        frame:SetPoint("LEFT", Questie.db.profile.nameplateX, Questie.db.profile.nameplateY)
        frame:SetWidth(16 * iconScale)
        frame:SetHeight(16 * iconScale)

        if frame.CountText then
            local font, _, _ = NumberFontNormal:GetFont()
            frame.CountText:SetFont(font, 12 * iconScale, "OUTLINE")

            local _, countText = _QuestieNameplate.GetIconAndCount(guid, formatMode)
            
            if frame.lastCountText ~= countText then
                frame.lastCountText = countText
                frame.CountText:SetText(countText)
            end
        end
    end
end

function QuestieNameplate:HideCurrentFrames()
    for guid, _ in pairs(activeGUIDs) do
        activeGUIDs[guid] = nil
        _QuestieNameplate.RemoveFrame(guid)
    end
end

---@param guid string
---@return string | nil
function QuestieNameplate.GetIcon(guid)
    if (not guid) then
        return nil
    end

    local icon, _ = _QuestieNameplate.GetIconAndCount(guid, 0)
    return icon
end

function QuestieNameplate:DrawTargetFrame()
    Questie.Debug(Questie.DEBUG_SPAM, "[QuestieNameplate:DrawTargetFrame]")

    if (not Questie.db.profile.nameplateTargetFrameEnabled) or (Questie.IsForever and IsInInstance()) then
        return
    end

    -- always remove the previous frame if it exists
    if activeTargetFrame ~= nil then
        activeTargetFrame.Icon:SetTexture(nil)
        activeTargetFrame.lastIcon = nil
        activeTargetFrame.lastCountText = nil
        if activeTargetFrame.CountText then
            activeTargetFrame.CountText:SetText("")
        end
        activeTargetFrame:Hide()
    end

    local unitGUID = UnitGUID("target")
    local unitName = UnitName("target")

    if (not unitName) or (not unitGUID) then
        -- We need the GUID and name, this should not happen
        return
    end

    local unitType, _, _, _, _, _, _ = strsplit("-", unitGUID)
    if unitType ~= "Creature" and unitType ~= "Vehicle" then
        -- We only draw name plates on NPCs/creatures and Vehicles (oddness with Chillmaw being a Vehicle?!?!) and skip players, pets, etc
        return
    end

    local formatMode = tonumber(Questie.db.profile.nameplateTargetFrameCountFormat) or 0
    local icon, countText = _QuestieNameplate.GetIconAndCount(unitGUID, formatMode)

    if (not icon) then
        return
    end

    if not activeTargetFrame then
        activeTargetFrame = _QuestieNameplate.GetTargetFrameIconFrame()
    end

    if activeTargetFrame.lastIcon ~= icon then
        activeTargetFrame.lastIcon = icon
        activeTargetFrame.Icon:SetTexture(icon)
    end

    if activeTargetFrame.CountText then
        if activeTargetFrame.lastCountText ~= countText then
            activeTargetFrame.lastCountText = countText
            activeTargetFrame.CountText:SetText(countText)
        end
    end

    activeTargetFrame:Show()
end

function QuestieNameplate:HideCurrentTargetFrame()
    if (not activeTargetFrame) then
        return
    end

    activeTargetFrame.Icon:SetTexture(nil)
    activeTargetFrame.lastIcon = nil
    activeTargetFrame.lastCountText = nil
    if activeTargetFrame.CountText then
        activeTargetFrame.CountText:SetText("")
    end
    activeTargetFrame:Hide()
    activeTargetFrame = nil
end

function QuestieNameplate:RedrawFrameIcon()
    if (not Questie.db.profile.nameplateTargetFrameEnabled) or (not activeTargetFrame) then
        return
    end

    local iconScale = Questie.db.profile.nameplateTargetFrameScale
    activeTargetFrame:SetWidth(16 * iconScale)
    activeTargetFrame:SetHeight(16 * iconScale)
    activeTargetFrame:SetPoint("RIGHT", Questie.db.profile.nameplateTargetFrameX, Questie.db.profile.nameplateTargetFrameY)

    if activeTargetFrame.CountText then
        local font, _, _ = NumberFontNormal:GetFont()
        activeTargetFrame.CountText:SetFont(font, 12 * iconScale, "OUTLINE")

        local unitGUID = UnitGUID("target")
        if unitGUID then
            local formatMode = tonumber(Questie.db.profile.nameplateTargetFrameCountFormat) or 0
            local _, countText = _QuestieNameplate.GetIconAndCount(unitGUID, formatMode)

            if activeTargetFrame.lastCountText ~= countText then
                activeTargetFrame.lastCountText = countText
                activeTargetFrame.CountText:SetText(countText)
            end
        end
    end
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

    local iconScale = Questie.db.profile.nameplateScale

    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(10)
    frame:SetWidth(16 * iconScale)
    frame:SetHeight(16 * iconScale)
    frame:EnableMouse(false)
    frame:SetParent(parent)
    frame:SetPoint("LEFT", Questie.db.profile.nameplateX, Questie.db.profile.nameplateY)

    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:ClearAllPoints()
    frame.Icon:SetAllPoints(frame)

    if not frame.CountText then
        frame.CountText = frame:CreateFontString(nil, "OVERLAY")
        frame.CountText:SetTextColor(1, 1, 1, 1)
        frame.CountText:SetPoint("RIGHT", frame, "LEFT", -2, 0)
        frame.CountText:SetJustifyH("RIGHT")
    end

    local font, _, _ = NumberFontNormal:GetFont()
    frame.CountText:SetFont(font, 12 * iconScale, "OUTLINE")

    npFrames[guid] = frame

    return frame
end

function _QuestieNameplate.GetTargetFrameIconFrame()
    local frame = CreateFrame("Frame")

    local iconScale = Questie.db.profile.nameplateTargetFrameScale
    local strata = "MEDIUM"

    local targetFrame = TargetFrame -- Default Blizzard target frame
    if ElvUF_Target then
        targetFrame = ElvUF_Target
        strata = "LOW"
    elseif PitBull4_Frames_Target then
        targetFrame = PitBull4_Frames_Target
    elseif AzeriteUnitFrameTarget then
        targetFrame = AzeriteUnitFrameTarget
        strata = "LOW"
    elseif GwTargetUnitFrame then
        targetFrame = GwTargetUnitFrame
        strata = "LOW"
    elseif InvenUnitFrames_Target then
        targetFrame = InvenUnitFrames_Target
        strata = "LOW"
    elseif SUFUnittarget then
        targetFrame = SUFUnittarget
        frame:SetFrameLevel(SUFUnittarget:GetFrameLevel() + 1)
    elseif XPerl_Target then
        targetFrame = XPerl_Target
    end

    frame:SetParent(targetFrame)
    frame:SetFrameStrata(strata)
    frame:SetFrameLevel(11)
    frame:SetWidth(16 * iconScale)
    frame:SetHeight(16 * iconScale)
    frame:EnableMouse(false)

    frame:SetPoint("RIGHT", Questie.db.profile.nameplateTargetFrameX, Questie.db.profile.nameplateTargetFrameY)

    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:ClearAllPoints()
    frame.Icon:SetAllPoints(frame)

    if not frame.CountText then
        frame.CountText = frame:CreateFontString(nil, "OVERLAY")
        frame.CountText:SetTextColor(1, 1, 1, 1)
        frame.CountText:SetPoint("LEFT", frame, "RIGHT", 0, 0)
        frame.CountText:SetJustifyH("LEFT")
    end

    local font, _, _ = NumberFontNormal:GetFont()
    frame.CountText:SetFont(font, 12 * iconScale, "OUTLINE")

    return frame
end

---@param guid string
function _QuestieNameplate.RemoveFrame(guid)
    if (not npFrames[guid]) then
        return
    end

    table.insert(npUnusedFrames, npFrames[guid])
    npFrames[guid].Icon:SetTexture(nil) -- fix for overlapping icons
    npFrames[guid].lastIcon = nil      -- fix for missing icons on recycled frames
    npFrames[guid].lastCountText = nil -- fix for stale count text on recycled frames
    if npFrames[guid].CountText then
        npFrames[guid].CountText:SetText("")
    end
    npFrames[guid]:Hide()
    npFrames[guid] = nil
end

---@param unitGUID string
---@param formatMode number
---@return string?, string
function _QuestieNameplate.GetIconAndCount(unitGUID, formatMode) -- helper function to extract npcId, lookup tooltips, and return first valid icon and count text
    if (not unitGUID) then
        return nil, ""
    end

    local _, _, _, _, _, npcId, _ = strsplit("-", unitGUID)
    if (not npcId) then
        return nil, ""
    end

    local tooltips = QuestieTooltips.lookupByKey["m_" .. npcId]
    if (not tooltips) then
        return nil, ""
    end

    for _, tooltip in pairs(tooltips) do
        if tooltip.objective and tooltip.objective.Update then
            tooltip.objective:Update() -- get latest qlog data if its outdated
            if (not tooltip.objective.Completed) and tooltip.objective.Icon then
                local icon = _QuestieNameplate.GetIconForObjective(tooltip.objective)

                if icon then
                    local countText = ""
                    local activeFormatMode = tonumber(formatMode) or 0
                    
                    if activeFormatMode > 0 then
                        local collected = tooltip.objective.Collected or tooltip.objective.collected
                        local needed = tooltip.objective.Needed or tooltip.objective.needed

                        if type(collected) ~= "number" or type(needed) ~= "number" then
                            if tooltip.objective.Description then
                                local cStr, nStr = string.match(tooltip.objective.Description, "(%d+)/(%d+)")
                                collected, needed = tonumber(cStr), tonumber(nStr)
                            end
                        end

                        if type(collected) == "number" and type(needed) == "number" and needed > 0 then
                            if activeFormatMode == 1 then
                                countText = collected .. "/" .. needed
                            elseif activeFormatMode == 2 then
                                countText = tostring(math.max(needed - collected, 0))
                            end
                        end
                    end

                    return icon, countText
                end
            end
        end
    end
    return nil, ""
end

---@param tooltips table<string, table>
function _QuestieNameplate.GetValidIcon(tooltips) -- legacy wrapper for compatibility
    if (not tooltips) then
        return
    end

    for _, tooltip in pairs(tooltips) do
        if tooltip.objective and tooltip.objective.Update then
            tooltip.objective:Update() -- get latest qlog data if its outdated
            if (not tooltip.objective.Completed) and tooltip.objective.Icon then
                local icon = _QuestieNameplate.GetIconForObjective(tooltip.objective)
                if icon then
                    return icon
                end
            end
        end
    end
end

---@param objective table
---@return string?
function _QuestieNameplate.GetIconForObjective(objective)
    -- If the tooltip icon is Questie.ICON_TYPE_OBJECT we use Questie.ICON_TYPE_LOOT because NPCs should never show
    -- a cogwheel icon (for pfquest only).
    local iconType = objective.Icon
    if iconType == Questie.ICON_TYPE_LOOT or iconType == Questie.ICON_TYPE_OBJECT then
        return Questie.db.profile.iconTheme == 'pfquest' and Questie.icons["loot"] or Questie.db.profile.ICON_LOOT or Questie.icons["loot"]
    elseif iconType == Questie.ICON_TYPE_SLAY then
        return Questie.db.profile.iconTheme == 'pfquest' and Questie.icons["slay"] or Questie.db.profile.ICON_SLAY or Questie.icons["slay"]
    elseif iconType == Questie.ICON_TYPE_EVENT then
        return Questie.db.profile.iconTheme == 'pfquest' and Questie.icons["event"] or Questie.db.profile.ICON_EVENT or Questie.icons["event"]
    elseif iconType == Questie.ICON_TYPE_TALK then
        return Questie.db.profile.iconTheme == 'pfquest' and Questie.icons["talk"] or Questie.db.profile.ICON_TALK or Questie.icons["talk"]
    elseif iconType == Questie.ICON_TYPE_INTERACT then
        return Questie.db.profile.iconTheme == 'pfquest' and Questie.icons["interact"] or Questie.db.profile.ICON_INTERACT or Questie.icons["interact"]
    elseif iconType == Questie.ICON_TYPE_MOUNT_UP then
        return Questie.db.profile.iconTheme == 'pfquest' and Questie.icons["mount_up"] or Questie.db.profile.MOUNT_UP or Questie.icons["mount_up"]
    elseif iconType == Questie.ICON_TYPE_PET_BATTLE then
        return Questie.db.profile.iconTheme == 'pfquest' and Questie.icons["petbattle"] or Questie.db.profile.ICON_TYPE_PET_BATTLE or Questie.icons["petbattle"]
    elseif iconType == Questie.ICON_TYPE_AVAILABLE or iconType == Questie.ICON_TYPE_AVAILABLE_GRAY then
        return Questie.icons["available"]
    elseif iconType == Questie.ICON_TYPE_REPEATABLE then
        return Questie.icons["repeatable"]
    elseif iconType == Questie.ICON_TYPE_COMPLETE then
        return Questie.icons["complete"]
    end

    return nil
end
