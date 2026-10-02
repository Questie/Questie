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

    -- Extract npcId and tooltips once to eliminate duplicate string splitting and table lookups.
    local _, _, _, _, _, npcId, _ = strsplit("-", unitGUID)
    local tooltips = npcId and QuestieTooltips.lookupByKey["m_" .. npcId] or nil
    
    -- Fetch icon and count in a single call to prevent objective desync.
    local icon, countText = _QuestieNameplate.GetIconAndCount(tooltips)

    if icon then
        activeGUIDs[unitGUID] = token

        local f = _QuestieNameplate.GetFrame(unitGUID)
        f.Icon:SetTexture(icon)
        f.lastIcon = icon -- this is used to prevent updating the texture when it's already what it needs to be
        
        -- Apply synchronized count text on frame creation.
        if f.CountText then
            f.CountText:SetText(countText)
        end
        
        f:Show()
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

    for guid, token in pairs(activeGUIDs) do
        local unitName, _ = UnitName(token)
        if unitName then
            -- Extracted string splitting out of the icon check to prevent duplicate parsing overhead on updates.
            local _, _, _, _, _, npcId, _ = strsplit("-", guid)
            local tooltips = npcId and QuestieTooltips.lookupByKey["m_" .. npcId] or nil
            
            -- Fetch both icon and count in one pass.
            local icon, countText = _QuestieNameplate.GetIconAndCount(tooltips)

            if icon then
                local frame = _QuestieNameplate.GetFrame(guid)
                -- check if the texture needs to be changed
                if frame.lastIcon ~= icon then
                    frame.lastIcon = icon
                    frame.Icon:SetTexture(icon)
                end
                
                -- Update text with the synchronized count during update cycles.
                if frame.CountText then
                    frame.CountText:SetText(countText)
                end
            else
                -- tooltip removed but we still have the frame active, remove it
                activeGUIDs[guid] = nil
                _QuestieNameplate.RemoveFrame(guid)
            end
        end
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
    for _, frame in pairs(npFrames) do
        local iconScale = Questie.db.profile.nameplateScale

        frame:SetPoint("LEFT", Questie.db.profile.nameplateX, Questie.db.profile.nameplateY)
        frame:SetWidth(16 * iconScale)
        frame:SetHeight(16 * iconScale)
        
        -- Dynamically update font size based on scale changes to maintain UI proportionality.
        if frame.CountText then
            local font, _, _ = NumberFontNormal:GetFont()
            frame.CountText:SetFont(font, 12 * iconScale, "OUTLINE")
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

    local _, _, _, _, _, npcId, _ = strsplit("-", guid)
    if (not npcId) then
        return nil
    end

    -- Legacy wrapper that now delegates to GetIconAndCount to avoid redundant parsing logic.
    local icon, _ = _QuestieNameplate.GetIconAndCount(QuestieTooltips.lookupByKey["m_" .. npcId])
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
        -- Clear text when resetting the previous target frame.
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

    -- Parse and fetch synchronized target icon and count text.
    local _, _, _, _, _, npcId, _ = strsplit("-", unitGUID)
    local tooltips = npcId and QuestieTooltips.lookupByKey["m_" .. npcId] or nil
    local icon, countText = _QuestieNameplate.GetIconAndCount(tooltips)

    if (not icon) then
        return
    end

    if not activeTargetFrame then
        activeTargetFrame = _QuestieNameplate.GetTargetFrameIconFrame()
    end

    activeTargetFrame.Icon:SetTexture(icon)
    
    -- Populate text on the target frame icon.
    if activeTargetFrame.CountText then
        activeTargetFrame.CountText:SetText(countText)
    end
    
    activeTargetFrame:Show()
end

function QuestieNameplate:HideCurrentTargetFrame()
    if (not activeTargetFrame) then
        return
    end

    activeTargetFrame.Icon:SetTexture(nil)
    -- Clear text when hiding target frame.
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
    
    -- Scale target frame font size proportionally.
    if activeTargetFrame.CountText then
        local font, _, _ = NumberFontNormal:GetFont()
        activeTargetFrame.CountText:SetFont(font, 12 * iconScale, "OUTLINE")
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
    
    -- Create FontString for text counter on standard nameplate frames with an OUTLINE for high legibility.
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
    
    -- Create FontString for text counter on target frame icon with OUTLINE formatting.
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
    -- Clear text when recycling frames to prevent visual ghosting.
    if npFrames[guid].CountText then
        npFrames[guid].CountText:SetText("")
    end
    npFrames[guid]:Hide()
    npFrames[guid] = nil
end


---@param tooltips table<string, table>
---@return string?, string
function _QuestieNameplate.GetIconAndCount(tooltips) -- Computes both icon and count in a single synchronized pass.
    if (not tooltips) then
        return nil, ""
    end

    for _, tooltip in pairs(tooltips) do
        if tooltip.objective and tooltip.objective.Update then
            tooltip.objective:Update() -- get latest qlog data if its outdated
            if (not tooltip.objective.Completed) and tooltip.objective.Icon then
                
                -- Determine Icon mapping
                local iconType = tooltip.objective.Icon
                local icon = nil
                
                if iconType == Questie.ICON_TYPE_LOOT then
                    icon = Questie.db.profile.iconTheme == 'pfquest' and Questie.icons["loot"] or Questie.db.profile.ICON_LOOT or Questie.icons["loot"]
                elseif iconType == Questie.ICON_TYPE_OBJECT then
                    icon = Questie.db.profile.iconTheme == 'pfquest' and Questie.icons["loot"] or Questie.db.profile.ICON_LOOT or Questie.icons["loot"]
                elseif iconType == Questie.ICON_TYPE_SLAY then
                    icon = Questie.db.profile.iconTheme == 'pfquest' and Questie.icons["slay"] or Questie.db.profile.ICON_SLAY or Questie.icons["slay"]
                elseif iconType == Questie.ICON_TYPE_EVENT then
                    icon = Questie.db.profile.iconTheme == 'pfquest' and Questie.icons["event"] or Questie.db.profile.ICON_EVENT or Questie.icons["event"]
                elseif iconType == Questie.ICON_TYPE_TALK then
                    icon = Questie.db.profile.iconTheme == 'pfquest' and Questie.icons["talk"] or Questie.db.profile.ICON_TALK or Questie.icons["talk"]
                elseif iconType == Questie.ICON_TYPE_INTERACT then
                    icon = Questie.db.profile.iconTheme == 'pfquest' and Questie.icons["interact"] or Questie.db.profile.ICON_INTERACT or Questie.icons["interact"]
                elseif iconType == Questie.ICON_TYPE_MOUNT_UP then
                    icon = Questie.db.profile.iconTheme == 'pfquest' and Questie.icons["mount_up"] or Questie.db.profile.MOUNT_UP or Questie.icons["mount_up"]
                elseif iconType == Questie.ICON_TYPE_PET_BATTLE then
                    icon = Questie.db.profile.iconTheme == 'pfquest' and Questie.icons["petbattle"] or Questie.db.profile.ICON_TYPE_PET_BATTLE or Questie.icons["petbattle"]
                elseif iconType == Questie.ICON_TYPE_AVAILABLE or iconType == Questie.ICON_TYPE_AVAILABLE_GRAY then
                    icon = Questie.icons["available"]
                elseif iconType == Questie.ICON_TYPE_REPEATABLE then
                    icon = Questie.icons["repeatable"]
                elseif iconType == Questie.ICON_TYPE_COMPLETE then
                    icon = Questie.icons["complete"]
                end

                -- Determine Count String for this exact matching objective (suppressing single requirements to avoid clutter)
                local countText = ""
                local collected = tooltip.objective.Collected or tooltip.objective.collected
                local needed = tooltip.objective.Needed or tooltip.objective.needed

                if type(collected) == "number" and type(needed) == "number" and needed > 0 then
                    if needed > 1 then
                        countText = tostring(math.max(needed - collected, 0))
                    end
                elseif tooltip.objective.Description then
                    local have, need = string.match(tooltip.objective.Description, "(%d+)/(%d+)")
                    if have and need and tonumber(need) > 0 and tonumber(need) > 1 then
                        countText = tostring(math.max(tonumber(need) - tonumber(have), 0))
                    end
                end

                if icon then
                    return icon, countText
                end
            end
        end
    end
    
    return nil, ""
end
