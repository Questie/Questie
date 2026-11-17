---@class QuestDetailsFrame
local QuestDetailsFrame = QuestieLoader:CreateModule("QuestDetailsFrame")

-------------------------
--Import modules.
-------------------------
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieSearchResults
local QuestieSearchResults = QuestieLoader:ImportModule("QuestieSearchResults")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")

--- QuestieGUI
local QuestieGUI = QuestieLoader:ImportModule("QuestieGUI")

local function ApplyModernButton(button, width)
    if QuestieOptionsControls and QuestieOptionsControls.ApplyStyledButton then
        button:SetWidth(width)
        button:SetHeight(40)
        QuestieOptionsControls.ApplyStyledButton(button.frame, width, button.text)
    end
end

local function ApplyModernInfoLink(link)
    if QuestieJourneyUtils and QuestieJourneyUtils.ApplyModernQuestLinkStyle then
        QuestieJourneyUtils.ApplyModernQuestLinkStyle(link)
    elseif link and link.highlight then
        link.highlight:SetColorTexture(0.08, 0.12, 0.19, 0.78)
        link.highlight:SetBlendMode("BLEND")
    end
end

local stringrep = string.rep

local function rec(theTable, ret, indent)
    ret = ret..stringrep('    ', indent)..'{\n'
    indent = indent + 1
    for k, v in pairs(theTable) do
        local t = type(v)
        if t == 'nil' then
            ret = ret..stringrep('    ', indent)..'['..k..']=nil'
        elseif t == 'table' then
            ret = rec(v, ret..stringrep('    ', indent)..'['..k..']=\n', indent)
        else
            ret = ret..stringrep('    ', indent)..'['..k..']='..v
        end
        ret = ret..'\n'
    end
    return ret..stringrep('    ', indent-1)..'},'
end

local function recurseTable(theTable, theKeys)
    local ret = Questie:Colorize('Raw data (shown because debug is enabled):\n\n', 'red')
    for key, _ in pairs(theKeys) do
        ret = ret..Questie:Colorize(key, 'yellow')..': '
        local t = type(theTable[key])
        if t == 'nil' then
            ret = ret..'nil'
        elseif t == 'table' then
            ret = rec(theTable[key], ret, 0)
        else
            ret = ret..theTable[key]
        end
        ret = ret..'\n'
    end
    return ret
end

---Creates a TomTom waypoint button if TomTom is available and coordinates are valid, otherwise returns nil.
---@param name string
---@param zone AreaId
---@param x number
---@param y number
---@return QuestieGUIWidget|nil
local function CreateTomTomButton(name, zone, x, y)
    if (not (TomTom and TomTom.AddWaypoint)) or (x == -1 and y == -1) then
        return nil
    end

    local tomTomButton = QuestieGUI:Create("Button")
    tomTomButton:SetText(l10n("Set |cFF54e33bTomTom|r Target"))
    ApplyModernButton(tomTomButton, 220)
    tomTomButton:SetCallback("OnClick", function()
        TrackerUtils:SetTomTomTarget(name, zone, x, y)
    end)
    return tomTomButton
end

---@param questId QuestId
---@return string|nil
local function GetReputationRewardString(questId)
    if not questId then
        return nil
    end

    local reputationRewards = QuestieReputation.GetReputationReward(questId)
    if not reputationRewards or not next(reputationRewards) then
        return nil
    end

    return QuestieReputation.GetReputationRewardString(reputationRewards)
end

---@param text string
---@param fullWidth boolean
---@return AceHeader
local function CreateHeading(text, fullWidth)
    if not QuestieOptionsControls or not QuestieOptionsControls.CreateModernDivider then
        local legacyHeader = QuestieGUI:Create("Heading")
        legacyHeader:SetFullWidth(fullWidth)
        legacyHeader:SetText(text)
        return legacyHeader
    end

    local header = QuestieGUI:Create("SimpleGroup")
    header:SetLayout("Fill")
    header:SetFullWidth(fullWidth)
    header:SetHeight(24)
    header.modernDivider = QuestieOptionsControls.CreateModernDivider(header.content, text)
    if header.border then
        header.border:SetBackdropColor(0, 0, 0, 0)
        header.border:SetBackdropBorderColor(0, 0, 0, 0)
    end
    header:SetCallback("OnRelease", function(widget)
        if widget.modernDivider then
            widget.modernDivider:Hide()
        end
    end)

    return header
end

---@param text string
---@param fullWidth boolean
---@return AceLabel
local function CreateLabel(text, fullWidth)
    ---@class AceLabel
    local header = QuestieGUI:Create("Label")
    header:SetFullWidth(fullWidth)
    header:SetText(text)

    return header
end

local function AddInfoPanelSpacing(container)
    local spacer = QuestieGUI:Create("SimpleGroup")
    spacer:SetFullWidth(true)
    spacer:SetHeight(16)
    container:AddChild(spacer)
end

local function GetInlineGroupBorder(group)
    if not group or not group.content then
        return nil
    end

    -- InlineGroup exposes a border, but a custom container may not. The content
    -- parent is the reliable fallback.
    -- implementations, so resolve it from the live frame when necessary.
    if not group.border and group.content.GetParent then
        group.border = group.content:GetParent()
    end
    return group.border
end

local NPC_PORTRAIT_SIZE = 48
local NPC_PORTRAIT_MIN_GROUP_HEIGHT = NPC_PORTRAIT_SIZE + 56

local function EnsureNPCInfoHeight(group)
    if group and group.frame and group.frame.GetHeight and group.SetHeight
        and group.frame:GetHeight() < NPC_PORTRAIT_MIN_GROUP_HEIGHT then
        group:SetHeight(NPC_PORTRAIT_MIN_GROUP_HEIGHT)
    end
end

local RemoveNPCPortraitWaiter

local function ResetNPCInfoLayout(group)
    if not group or not group.content then
        return
    end

    group.npcPortraitLayoutActive = false
    group.itemIconLayoutActive = false
    for _, portrait in pairs(group.npcPortraits or {}) do
        if portrait.npcID then
            RemoveNPCPortraitWaiter(portrait, portrait.npcID)
        end
        portrait:Hide()
        portrait.npcID = nil
    end

    -- InlineGroups are reused. Hide an item icon left by a
    -- previous item-start panel before this group is reused for links or NPCs.
    if group.itemIcon then
        group.itemIcon:Hide()
    end

    local border = GetInlineGroupBorder(group)
    if border then
        group.content:ClearAllPoints()
        group.content:SetPoint("TOPLEFT", border, "TOPLEFT", 10, -10)
        group.content:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -10, 10)
    end
end

local function ApplyNPCInfoLayout(group)
    local border = GetInlineGroupBorder(group)
    if not group or not group.content or not border then
        return
    end

    group.npcPortraitLayoutActive = true

    -- Reapply the same first-level surface used by the quest-link panels.
    -- NPC panels can come from a recycled InlineGroup with its old backdrop.
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernContainer then
        QuestieOptionsControls.ApplyModernContainer(border, false)
    end

    if not group.npcPortraitReleaseHooked and group.SetCallback then
        group.npcPortraitReleaseHooked = true
        local previousOnRelease = group.events and group.events.OnRelease
        group:SetCallback("OnRelease", function(widget, ...)
            widget.npcPortraitReleaseHooked = false
            ResetNPCInfoLayout(widget)
            if previousOnRelease then
                previousOnRelease(widget, ...)
            end
        end)
    end

    -- Leave a fixed column for the still portrait.  Moving the group content
    -- moves every line in the NPC panel, not just the NPC name.
    group.content:ClearAllPoints()
    group.content:SetPoint("TOPLEFT", border, "TOPLEFT", 68, -10)
    group.content:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -10, 10)

    -- Size the group from its text children. Reserve enough
    -- vertical space for the portrait and the panel's top/bottom padding.
    EnsureNPCInfoHeight(group)

    -- Make the minimum part of the group's normal measurement.  The parent
    -- container reads the child's height immediately after LayoutFinished.
    if not group.npcPortraitLayoutFinishedHooked and group.LayoutFinished then
        group.npcPortraitLayoutFinishedHooked = true
        local layoutFinished = group.LayoutFinished
        group.LayoutFinished = function(self, width, height)
            layoutFinished(self, width, height)
            if self.npcPortraitLayoutActive then
                EnsureNPCInfoHeight(self)
            end
        end
    end

    -- InlineGroup recalculates its content size as it is laid out.  Keep the
    -- portrait column when the group is resized after the first layout too.
    if not group.npcPortraitLayoutHooked and group.frame and group.frame.HookScript then
        group.npcPortraitLayoutHooked = true
        group.frame:HookScript("OnSizeChanged", function()
            if group.npcPortraitLayoutActive then
                ApplyNPCInfoLayout(group)
            end
        end)
    end
end

local function ApplyItemInfoLayout(group)
    local border = GetInlineGroupBorder(group)
    if not group or not group.content or not border then
        return
    end

    group.itemIconLayoutActive = true
    group.content:ClearAllPoints()
    group.content:SetPoint("TOPLEFT", border, "TOPLEFT", 68, -10)
    group.content:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -10, 10)
    EnsureNPCInfoHeight(group)

    if not group.itemIconLayoutFinishedHooked and group.LayoutFinished then
        group.itemIconLayoutFinishedHooked = true
        local layoutFinished = group.LayoutFinished
        group.LayoutFinished = function(self, width, height)
            layoutFinished(self, width, height)
            if self.itemIconLayoutActive then
                EnsureNPCInfoHeight(self)
            end
        end
    end

    if not group.itemIconLayoutHooked and group.frame and group.frame.HookScript then
        group.itemIconLayoutHooked = true
        group.frame:HookScript("OnSizeChanged", function()
            if group.itemIconLayoutActive then
                ApplyItemInfoLayout(group)
            end
        end)
    end
end

local function AddItemIcon(group, item)
    local border = GetInlineGroupBorder(group)
    if not group or not border or not item or not item.Id or not border.CreateTexture then
        return
    end

    if not group.itemIcon then
        group.itemIcon = border:CreateTexture(nil, "OVERLAY", nil, 7)
        group.itemIcon:SetSize(NPC_PORTRAIT_SIZE, NPC_PORTRAIT_SIZE)
    end

    local iconTexture
    if QuestieCompat and QuestieCompat.GetItemIcon then
        local ok, texture = pcall(QuestieCompat.GetItemIcon, item.Id)
        if ok then
            iconTexture = texture
        end
    end

    group.itemIcon:ClearAllPoints()
    group.itemIcon:SetPoint("TOPLEFT", border, "TOPLEFT", 12, -24)
    group.itemIcon:SetTexture(iconTexture or "Interface\\Icons\\INV_Misc_QuestionMark")
    group.itemIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    group.itemIcon:Show()
end

---@param group QuestieGUIWidget
---@param npc NPC
---@param portraitIndex integer
---@param anchor QuestieGUIWidget
local npcPortraitDisplays = {}
local npcPortraitRequests = {}
local npcPortraitModels = {}
local npcPortraitWaiters = {}
local npcPortraitProbes
local NPC_PORTRAIT_RETRY_SECONDS = 0.05
local NPC_PORTRAIT_TIMEOUT_SECONDS = 5

local function GetKnownNPCDisplayID(npcID)
    local questFaces = rawget(_G, "SpokenQuestFaces")
    local displayID = questFaces and questFaces[npcID]
    return type(displayID) == "number" and displayID > 0 and displayID or nil
end

local function ReadNPCDisplayID(model)
    local ok, displayID = pcall(function()
        return model and model.GetDisplayInfo and model:GetDisplayInfo()
    end)
    if not ok then
        return nil
    end
    return type(displayID) == "number" and displayID > 0 and displayID or nil
end

local function PaintNPCPortrait(portrait, npcID, displayID)
    if not displayID or not portrait or portrait.npcID ~= npcID or not SetPortraitTextureFromCreatureDisplayID then
        return false
    end

    local painted = pcall(SetPortraitTextureFromCreatureDisplayID, portrait, displayID)
    if painted then
        portrait:Show()
    end
    return painted
end

RemoveNPCPortraitWaiter = function(portrait, npcID)
    local waiters = npcPortraitWaiters[npcID]
    if not waiters then
        return
    end

    waiters[portrait] = nil
    if not next(waiters) then
        npcPortraitWaiters[npcID] = nil
    end
end

local function PaintWaitingNPCPortraits(npcID, displayID)
    local waiters = npcPortraitWaiters[npcID]
    if not waiters then
        return
    end

    for portrait in pairs(waiters) do
        if PaintNPCPortrait(portrait, npcID, displayID) then
            waiters[portrait] = nil
        end
    end

    if not next(waiters) then
        npcPortraitWaiters[npcID] = nil
    end
end

local function RegisterNPCPortraitWaiter(portrait, npcID)
    npcPortraitWaiters[npcID] = npcPortraitWaiters[npcID] or {}
    npcPortraitWaiters[npcID][portrait] = true
end

local function GetNPCDefaultDisplays()
    if npcPortraitProbes == false then
        return nil, nil
    end
    if npcPortraitProbes == nil then
        local ownCreated, own = pcall(CreateFrame, "DressUpModel")
        local blankCreated, blank = pcall(CreateFrame, "DressUpModel")
        if not (ownCreated and blankCreated and own and blank and own.SetUnit and own.GetDisplayInfo and blank.GetDisplayInfo) then
            npcPortraitProbes = false
            return nil, nil
        end
        -- A hidden model may never finish loading its display information.
        -- Keep the probes alive but invisible while the client resolves them.
        own:SetSize(1, 1)
        blank:SetSize(1, 1)
        own:SetAlpha(0)
        blank:SetAlpha(0)
        own:Show()
        blank:Show()
        npcPortraitProbes = { own = own, blank = blank }
    end

    local now = GetTime and GetTime() or 0
    if npcPortraitProbes.at ~= now then
        pcall(npcPortraitProbes.own.SetUnit, npcPortraitProbes.own, "player")
        npcPortraitProbes.at = now
        npcPortraitProbes.ownDisplay = ReadNPCDisplayID(npcPortraitProbes.own)
        npcPortraitProbes.blankDisplay = ReadNPCDisplayID(npcPortraitProbes.blank)
    end
    return npcPortraitProbes.ownDisplay, npcPortraitProbes.blankDisplay
end

local function ResolveNPCPortrait(portrait, npcID)
    local displayID = npcPortraitDisplays[npcID] or GetKnownNPCDisplayID(npcID)
    if PaintNPCPortrait(portrait, npcID, displayID) then
        RemoveNPCPortraitWaiter(portrait, npcID)
        PaintWaitingNPCPortraits(npcID, displayID)
        return
    end

    if not (SetPortraitTextureFromCreatureDisplayID and type(CreateFrame) == "function") then
        return
    end

    local now = GetTime and GetTime() or 0
    local request = npcPortraitRequests[npcID]
    if request and now - request.first > NPC_PORTRAIT_TIMEOUT_SECONDS then
        npcPortraitModels[npcID] = nil
        npcPortraitRequests[npcID] = nil
        -- Stop this retry chain. A later panel acquisition will register a
        -- waiter and start a fresh request.
        return
    end
    if request and now - request.last < NPC_PORTRAIT_RETRY_SECONDS then
        return
    end

    if not request then
        request = { first = now, last = now, sent = now, fresh = true }
        npcPortraitRequests[npcID] = request
    else
        request.last = now
    end

    local model = npcPortraitModels[npcID]
    if not model then
        local created
        created, model = pcall(CreateFrame, "DressUpModel")
        if not (created and model and model.SetCreature and model.GetDisplayInfo) then
            return
        end
        -- DressUpModel loads asynchronously and hidden models can remain on
        -- their default display forever.  Showing a 1x1, fully transparent
        -- model lets the client complete the load without flashing it on UI.
        model:SetSize(1, 1)
        model:SetAlpha(0)
        model:Show()
        npcPortraitModels[npcID] = model
        request.previous = ReadNPCDisplayID(model)
        if model.SetScript then
            pcall(model.SetScript, model, "OnModelLoaded", function(loadedModel)
                local loadedDisplayID = ReadNPCDisplayID(loadedModel)
                if loadedDisplayID then
                    npcPortraitDisplays[npcID] = loadedDisplayID
                    npcPortraitModels[npcID] = nil
                    npcPortraitRequests[npcID] = nil
                    PaintWaitingNPCPortraits(npcID, loadedDisplayID)
                end
            end)
        end
        pcall(model.SetCreature, model, npcID)
    end

    local currentDisplayID = ReadNPCDisplayID(model)
    local ownDisplayID, blankDisplayID
    if currentDisplayID then
        ownDisplayID, blankDisplayID = GetNPCDefaultDisplays()
    end
    local stale = currentDisplayID == ownDisplayID
        or currentDisplayID == blankDisplayID
        or (request.fresh and currentDisplayID == request.previous)
    request.fresh = false
    if currentDisplayID and not stale then
        npcPortraitDisplays[npcID] = currentDisplayID
        npcPortraitModels[npcID] = nil
        npcPortraitRequests[npcID] = nil
        PaintWaitingNPCPortraits(npcID, currentDisplayID)
        return
    end

    if now - request.sent >= 1 then
        request.sent, request.fresh, request.previous = now, true, currentDisplayID
        pcall(model.SetCreature, model, npcID)
    end

    if C_Timer and C_Timer.After and not request.retryScheduled then
        request.retryScheduled = true
        C_Timer.After(NPC_PORTRAIT_RETRY_SECONDS, function()
            local currentRequest = npcPortraitRequests[npcID]
            if currentRequest ~= request then
                return
            end
            request.retryScheduled = false
            for waitingPortrait in pairs(npcPortraitWaiters[npcID] or {}) do
                ResolveNPCPortrait(waitingPortrait, npcID)
            end
        end)
    end
end

local function AddNPCPortrait(group, npc, portraitIndex, anchor)
    local border = GetInlineGroupBorder(group)
    if not group or not border or not group.content or not npc or not npc.id or type(CreateFrame) ~= "function" then
        return
    end

    group.npcPortraits = group.npcPortraits or {}
    local portrait = group.npcPortraits[portraitIndex]
    if not portrait then
        local texture
        local created = pcall(function()
            -- The border is the visible panel.  Parenting to it keeps the
            -- portrait above the backdrop while avoiding the content frame's
            -- child layout moving it out of the reserved column.
            texture = border:CreateTexture(nil, "OVERLAY", nil, 7)
        end)
        if not created or not texture then
            return
        end

        portrait = texture
        group.npcPortraits[portraitIndex] = portrait
        portrait:SetSize(NPC_PORTRAIT_SIZE, NPC_PORTRAIT_SIZE)
        portrait:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end

    portrait:ClearAllPoints()
    portrait:SetPoint("TOPLEFT", border, "TOPLEFT", 12, -24)
    if anchor and anchor.frame then
        portrait:ClearAllPoints()
        portrait:SetPoint("TOPRIGHT", anchor.frame, "TOPLEFT", -8, 0)
    end

    -- Portrait textures are kept by the panel frame and may be reused when a
    -- different quest is selected. Clear the previous NPC image before the
    -- asynchronous display lookup starts, otherwise the old portrait can be
    -- shown until the new model finishes loading.
    portrait:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    portrait:SetTexCoord(0, 1, 0, 1)
    portrait.npcID = npc.id
    RegisterNPCPortraitWaiter(portrait, npc.id)
    ResolveNPCPortrait(portrait, npc.id)

    portrait:Show()
end

---Reset a recycled Journey information panel before changing its content type.
---@param group QuestieGUIWidget
function QuestDetailsFrame:ResetInfoGroup(group)
    ResetNPCInfoLayout(group)
end

---Apply the shared NPC panel layout and portrait to another Journey detail view.
---@param group QuestieGUIWidget
---@param npc NPC
function QuestDetailsFrame:ApplyNPCInfoGroup(group, npc)
    ResetNPCInfoLayout(group)
    ApplyNPCInfoLayout(group)
    AddNPCPortrait(group, npc, 1, nil)
end

---@param questLevel number
---@param questMinLevel number
---@return number|nil red
---@return number|nil orange
---@return number|nil yellow
---@return number|nil green
---@return number|nil gray
local function GetLevelDifficultyRanges(questLevel, questMinLevel)
    local charLevel = UnitLevel("player")
    local red, orange, yellow, green, gray

    -- Gray Level based on level range.
    if (questLevel ~= -1) then
        if Questie.IsClassic then
            -- values observed on wowhead
            if (questLevel <= 4) then
                gray = questLevel + 5
            elseif (questLevel <= 13) then
                gray = questLevel + 6
            elseif (questLevel <= 22) then
                gray = questLevel + 7
            elseif (questLevel <= 31) then
                gray = questLevel + 8
            elseif (questLevel <= 40) then
                gray = questLevel + 9
            elseif (questLevel <= 49) then
                gray = questLevel + 10
            elseif (questLevel <= 58) then
                gray = questLevel + 11
            else
                gray = questLevel + 12
            end
        else
            -- values observed on TBC and MoP. Assuming Wotlk follows same values.
            -- GetQuestGreenRange() returns 8 from 40-90
            if (questLevel <= 4) then
                gray = questLevel + 5
            elseif (questLevel <= 13) then
                gray = questLevel + 6
            elseif (questLevel <= 22) then
                gray = questLevel + 7
            elseif (questLevel <= 31) then
                gray = questLevel + 8
            else
                gray = questLevel + 9
            end
        end

    end

    -- Calculate Base Values
    if questLevel == -1 then
        questLevel = (questMinLevel <= charLevel and charLevel) or (questMinLevel > charLevel and questMinLevel)
        if questMinLevel == questLevel then
            yellow = questLevel
        elseif questMinLevel ~= questLevel then
            yellow = questMinLevel .. "-" .. questLevel
        end
    else
        red = questMinLevel
        orange = questLevel - 4
        yellow = questLevel - 2
        green = questLevel + 3

        -- Double check for negative values
        if yellow <= 0 or yellow < questMinLevel then
            yellow = questMinLevel
        end

        if orange and orange < questMinLevel then
            orange = questMinLevel
        end

        if orange == yellow then
            orange = nil
        end

        if red and (red == orange or not orange) then
            red = nil
        end

        if green and green < questMinLevel then
            green = questMinLevel
        end

        if gray and gray < questMinLevel then
            gray = questMinLevel
        end

    end

    return red, orange, yellow, green, gray
end

---@param questLevel number
---@param questMinLevel number
---@return string
local function GetDifficultyString(questLevel, questMinLevel)
    local red, orange, yellow, green, gray = GetLevelDifficultyRanges(questLevel, questMinLevel)
    local diffStr = ''

    if red then
        diffStr = diffStr .. "|cFFFF1A1A[".. red .."]|r "
    end

    if orange then
        diffStr = diffStr .. "|cFFFF8040[".. orange .."]|r "
    end

    diffStr = diffStr .. "|cFFFFFF00[".. yellow .."]|r "

    if green then
        diffStr = diffStr .. "|cFF40C040[".. green .."]|r "
    end

    if gray then
        diffStr = diffStr .. "|cFFC0C0C0[".. gray .."]|r "
    end

    return Questie:Colorize(l10n('Difficulty Range: %s', diffStr), 'yellow')
end

---Takes a frame and adds a paragraph with a header text and a list of links to other search results
---@param frame ScrollFrame The frame to work on
---@param linkType string The type of result to link to (npc|object|quest|item)
---@param lookup table Table of IDs (npc|object|quest|item)
---@param header string The text header to show above the links
---@param query function The function used to get link name from
local function AddLinkedParagraph(frame, linkType, lookup, header, query)
    if lookup and #lookup > 0 then
        local group = QuestieGUI:Create("InlineGroup")
        ResetNPCInfoLayout(group)
        group:SetFullWidth(true)
        group:SetLayout("List")
        group:SetTitle(header)
        if QuestieOptionsControls and QuestieOptionsControls.ApplyModernInfoGroup then
            QuestieOptionsControls.ApplyModernInfoGroup(group)
        end
        frame:AddChild(group)

        for _, id in pairs(lookup) do
            id = math.abs(id)
            local link = QuestieGUI:Create("InteractiveLabel")
            ApplyModernInfoLink(link)
            -- Labels are 200 pixels wide unless stretched, which wraps long quest names and rewards needlessly.
            link:SetFullWidth(true)
            local name = query(id, "name")
            local text
            if linkType == 'quest' then
                text = QuestieLib:GetColoredQuestName(id, true, true)
            elseif linkType == 'npc' then
                local lvl = query(id, 'maxLevel')
                text = '['..lvl..'] '..name..' ('..id..')'
            else
                text = name.." ("..id..")"
            end
            link:SetText(text)
            if link.modernQuestLinkRefresh then
                link.modernQuestLinkRefresh()
            end
            link:SetUserData("id", id)
            link:SetUserData("type", linkType)
            link:SetUserData("name", name)
            link:SetCallback("OnClick", function()
                QuestieJourneyUtils.HideJourneyTooltip()
                if linkType == "quest" and QuestieJourneyUtils.OpenQuestInJourney then
                    QuestieJourneyUtils.OpenQuestInJourney(id)
                else
                    -- NPC/object/item links still use their existing detail
                    -- search flow; quest links open the target quest directly.
                    QuestieJourney.tabGroup:SelectTab("search")
                    QuestieSearchResults:SetSearch(linkType, id)
                end
            end)
            link:SetCallback("OnEnter", QuestieJourneyUtils.ShowJourneyTooltip)
            link:SetCallback("OnLeave", QuestieJourneyUtils.HideJourneyTooltip)
            group:AddChild(link)
        end
    end
end

---@param container ScrollFrame
---@param quest Quest
function QuestDetailsFrame:Draw(container, quest)
    if not container or not quest then
        Questie.Debug(Questie.DEBUG_CRITICAL, "[QuestDetailsFrame:Draw] Missing quest data.")
        return
    end

    -- Draw is also reached from restored selections and search navigation.
    -- Clear any previous detail widgets before adding the new headings.
    if container.ReleaseChildren then
        container:ReleaseChildren()
    end

    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernScrollbar then
        QuestieOptionsControls.ApplyModernScrollbar(container.scrollbar)
    end

    local questNameHeader = CreateHeading(quest.name, true)
    container:AddChild(questNameHeader)

    QuestieJourneyUtils:Spacer(container)

    local obj = QuestieGUI:Create("Label")
    obj:SetText(QuestieJourneyUtils.CreateObjectiveText(quest.Description))
    obj:SetFullWidth(true)
    container:AddChild(obj)

    QuestieJourneyUtils:Spacer(container)

    local questInfoHeader = CreateHeading(l10n('Quest Information'), true)
    container:AddChild(questInfoHeader)

    -- Complete checkbox (disabled/read-only)
    local completedCheckbox = QuestieGUI:Create("CheckBox")
    completedCheckbox:SetValue(Questie.db.char.complete[quest.Id])
    completedCheckbox:SetLabel(l10n("Complete"))
    completedCheckbox:SetDisabled(true)
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernCheckbox then
        QuestieOptionsControls.ApplyModernCheckbox(completedCheckbox)
    end
    completedCheckbox:SetHeight(16)
    completedCheckbox.text:SetFontObject(GameFontHighlightSmall)
    completedCheckbox:SetFullWidth(true)
    container:AddChild(completedCheckbox)

    -- Hidden by Questie checkbox (disabled/read-only)
    local hiddenByQuestieCheckbox = QuestieGUI:Create("CheckBox")
    hiddenByQuestieCheckbox:SetValue(QuestieCorrections.hiddenQuests[quest.Id])
    hiddenByQuestieCheckbox:SetLabel(l10n("Hidden by Questie"))
    hiddenByQuestieCheckbox:SetDisabled(true)
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernCheckbox then
        QuestieOptionsControls.ApplyModernCheckbox(hiddenByQuestieCheckbox)
    end
    hiddenByQuestieCheckbox:SetHeight(16)
    hiddenByQuestieCheckbox.text:SetFontObject(GameFontHighlightSmall)
    hiddenByQuestieCheckbox:SetFullWidth(true)
    container:AddChild(hiddenByQuestieCheckbox)

    -- Hidden checkbox (interactive with tooltip)
    local hideQuestCheckbox = QuestieGUI:Create("CheckBox")
    hideQuestCheckbox.questId = quest.Id
    hideQuestCheckbox:SetLabel(l10n("Hidden"))
    hideQuestCheckbox:SetValue(Questie.db.char.hidden[quest.Id] ~= nil)
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernCheckbox then
        QuestieOptionsControls.ApplyModernCheckbox(hideQuestCheckbox)
    end
    hideQuestCheckbox.text:SetFontObject(GameFontHighlightSmall)
    hideQuestCheckbox:SetFullWidth(true)
    hideQuestCheckbox:SetCallback("OnValueChanged", function(frame)
        if Questie.db.char.hidden[frame.questId] ~= nil then
            QuestieQuest:UnhideQuest(frame.questId)
        else
            QuestieQuest:HideQuest(frame.questId)
        end
    end)
    hideQuestCheckbox:SetCallback("OnEnter", function(widget)
        if GameTooltip:IsShown() then
            return
        end
        GameTooltip:SetOwner(widget.frame, "ANCHOR_LEFT")
        GameTooltip:AddLine(l10n("Quest is hidden"))
        GameTooltip:AddLine(
            l10n("\nIf checked, hides the quest from the map, even if it is active.\n\nHiding a quest is also possible by Shift-clicking it on the map."), 1, 1,
            1,
            true)
        GameTooltip:SetFrameStrata("TOOLTIP")
        GameTooltip:Show()
    end)
    hideQuestCheckbox:SetCallback("OnLeave", function()
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
        end
    end)
    container:AddChild(hideQuestCheckbox)

    -- Generic Quest Information

    local questIdLabel = CreateLabel(Questie:Colorize(l10n("Quest ID") .. l10n(": "), "yellow") .. quest.Id, true)
    container:AddChild(questIdLabel)

    local questLevel = QuestieLib.GetEffectiveQuestLevel(quest.Id)
    local levelLabel = CreateLabel(Questie:Colorize(l10n("Quest Level") .. l10n(": "), "yellow") .. questLevel, true)
    container:AddChild(levelLabel)

    -- We need to query this so we don't get wrong results for -1 type quests
    local requiredLevel = QuestieDB.QueryQuestSingle(quest.Id, "requiredLevel")
    local questDbLevel = QuestieDB.QueryQuestSingle(quest.Id, "questLevel")
    local minLevelLabel = CreateLabel(Questie:Colorize(l10n("Required Level") .. l10n(": "), 'yellow') .. requiredLevel, true)
    container:AddChild(minLevelLabel)

    -- Required Race / Faction
    local requiredRaces = QuestieDB.QueryQuestSingle(quest.Id, "requiredRaces")
    local reqRaces = QuestieLib:GetRaceString(requiredRaces)
    if (reqRaces ~= "") then
        local requiredLabel = "Required Race"
        if requiredRaces == QuestieDB.raceKeys.ALL_ALLIANCE or requiredRaces == QuestieDB.raceKeys.ALL_HORDE then
            requiredLabel = "Required Faction"
        end
        local factionIcon
        if requiredRaces == QuestieDB.raceKeys.ALL_ALLIANCE then
            factionIcon = Questie.icons and Questie.icons.faction_alliance
        elseif requiredRaces == QuestieDB.raceKeys.ALL_HORDE then
            factionIcon = Questie.icons and Questie.icons.faction_horde
        end
        if factionIcon then
            reqRaces = "|T" .. factionIcon .. ":16:16|t " .. reqRaces
        end
        local reqRacesLabel = CreateLabel(Questie:Colorize(l10n(requiredLabel) .. l10n(": "), 'yellow') .. reqRaces, true)
        container:AddChild(reqRacesLabel)
    end

    -- Required Class
    local requiredClasses = QuestieDB.QueryQuestSingle(quest.Id, "requiredClasses")
    local reqClasses = QuestieLib:GetClassString(requiredClasses)
    if (reqClasses ~= "") then
        local reqClassesLabel = CreateLabel(Questie:Colorize(l10n("Required Class") .. l10n(": "), 'yellow') .. reqClasses, true)
        container:AddChild(reqClassesLabel)
    end

    -- Required Profession
    local requiredSkill = QuestieDB.QueryQuestSingle(quest.Id, "requiredSkill")
    local requiredSpecialization = QuestieDB.QueryQuestSingle(quest.Id, "requiredSpecialization")
    local requiredRanks = QuestieDB.QueryQuestSingle(quest.Id, "requiredRanks")
    local professionParts = {}

    if requiredSkill and requiredSkill[1] and QuestieProfessions:GetProfessionName(requiredSkill[1]) then
        local specializationName = requiredSpecialization and QuestieProfessions:GetSpecializationName(requiredSpecialization)
        local entry = specializationName and l10n(specializationName) or l10n(QuestieProfessions:GetProfessionName(requiredSkill[1]))
        if requiredSkill[2] and requiredSkill[2] >= 1 then
            entry = entry .. " " .. l10n("(") .. requiredSkill[2] .. l10n(")")
        end
        professionParts[#professionParts + 1] = entry
    end

    if requiredRanks then
        for i = 1, #requiredRanks do
            local professionId = requiredRanks[i][1]
            local rankLevel = requiredRanks[i][2]
            local professionName = QuestieProfessions:GetProfessionName(professionId)
            if professionName then
                local absRankLevel = math.abs(rankLevel)
                local rankName = QuestieProfessions:GetRankName(absRankLevel)
                local entry = l10n(professionName)
                if rankName then
                    entry = entry .. " " .. l10n("(") .. l10n(rankName) .. l10n(")")
                end
                if rankLevel < 0 then
                    entry = l10n("Not") .. " " .. entry
                end
                professionParts[#professionParts + 1] = entry
            end
        end
    end

    if #professionParts > 0 then
        local label = Questie:Colorize(l10n("Required Profession") .. l10n(": "), 'yellow')
        local professionString
        if #professionParts == 1 then
            professionString = label .. professionParts[1]
        else
            professionString = label .. "\n  " .. table.concat(professionParts, "\n  ")
        end
        container:AddChild(CreateLabel(professionString, true))
    end

    local levelDiffString = GetDifficultyString(questDbLevel, requiredLevel)
    local levelDiffLabel = CreateLabel(levelDiffString, true)
    container:AddChild(levelDiffLabel)

    local reputationRewardString = GetReputationRewardString(quest.Id)
    if reputationRewardString then
        local labelText = Questie:Colorize(l10n("Reputation Reward") .. l10n(": "), 'yellow') .. Questie:Colorize(reputationRewardString, "reputationBlue")
        local reputationRewardLabel = CreateLabel(labelText, true)
        container:AddChild(reputationRewardLabel)
    end

    local breadcrumbForQuestId = QuestieDB.QueryQuestSingle(quest.Id, "breadcrumbForQuestId")
    if breadcrumbForQuestId and breadcrumbForQuestId ~= 0 then
        local completedStatus = Questie.db.char.complete[quest.Id] and Questie:Colorize(YES, 'green') or Questie:Colorize(NO, 'red')
        local completedLabel = CreateLabel(Questie:Colorize(l10n("Completed") .. l10n(": "), 'yellow') .. completedStatus, true)
        container:AddChild(completedLabel)
    end

    if QuestieDB.IsRepeatable(quest.Id) then
        if QuestieDB.IsDailyQuest(quest.Id) then
            local dailyLabel = CreateLabel(Questie:Colorize(l10n("Repeatable")..l10n(": "), 'yellow') .. l10n("Daily"), true)
            container:AddChild(dailyLabel)
        elseif QuestieDB.IsWeeklyQuest(quest.Id) then
            local weeklyLabel = CreateLabel(Questie:Colorize(l10n("Repeatable")..l10n(": "), 'yellow') .. l10n("Weekly"), true)
            container:AddChild(weeklyLabel)
        elseif QuestieDB.IsMonthlyQuest(quest.Id) then
            local monthlyLabel = CreateLabel(Questie:Colorize(l10n("Repeatable")..l10n(": "), 'yellow') .. l10n("Monthly"), true)
            container:AddChild(monthlyLabel)
        else
            local repeatableLabel = CreateLabel(Questie:Colorize(l10n("Repeatable"), 'yellow'), true)
            container:AddChild(repeatableLabel)
        end
    end

    local eligibilityText, shouldShowDoableLabel = QuestieDB.IsDoableVerbose(quest.Id, false, true, true)
    if shouldShowDoableLabel then
        local eligibilityTextLabel = CreateLabel(Questie:Colorize(l10n("Doable") .. l10n(": "), 'yellow') .. eligibilityText, true)
        container:AddChild(eligibilityTextLabel)
    end

    -- Pre Quests - two separate labeled sections
    if quest.preQuestSingle and next(quest.preQuestSingle) then
        QuestieJourneyUtils:Spacer(container)
        AddLinkedParagraph(container, "quest", quest.preQuestSingle, l10n("Requires one of these quests to be finished"), QuestieDB.QueryQuestSingle)
    end

    if quest.preQuestGroup and next(quest.preQuestGroup) then
        QuestieJourneyUtils:Spacer(container)
        AddLinkedParagraph(container, "quest", quest.preQuestGroup, l10n("Requires all of these quests to be finished"), QuestieDB.QueryQuestSingle)
    end

    local nextQuestInChain = QuestieDB.QueryQuestSingle(quest.Id, "nextQuestInChain")
    if nextQuestInChain == 0 then nextQuestInChain = QuestieDB.QueryQuestSingle(quest.Id, "breadcrumbForQuestId") or 0 end
    if nextQuestInChain and nextQuestInChain > 0 and (not QuestieCorrections.hiddenQuests[nextQuestInChain]) then
        local nextQuestIDs = {}
        local visitedQuestIds = {}
        while nextQuestInChain > 0 and (not visitedQuestIds[nextQuestInChain]) and (not QuestieCorrections.hiddenQuests[nextQuestInChain]) do
            visitedQuestIds[nextQuestInChain] = true
            nextQuestIDs[#nextQuestIDs + 1] = nextQuestInChain
            local nextNextQuestId = QuestieDB.QueryQuestSingle(nextQuestInChain, "nextQuestInChain")
            if nextNextQuestId == 0 then nextNextQuestId = QuestieDB.QueryQuestSingle(nextQuestInChain, "breadcrumbForQuestId") or 0 end
            if nextNextQuestId > 0 then
                nextQuestInChain = nextNextQuestId
            else
                break
            end
        end

        QuestieJourneyUtils:Spacer(container)
        AddLinkedParagraph(container, "quest", nextQuestIDs, l10n("Next in chain"), QuestieDB.QueryQuestSingle)
    end

    AddInfoPanelSpacing(container)

    -- Get Quest Start NPC
    if quest.Starts and quest.Starts.NPC then
        local startNPCGroup = QuestieGUI:Create("InlineGroup")
        ResetNPCInfoLayout(startNPCGroup)
        startNPCGroup:SetLayout("List")
        startNPCGroup:SetTitle(l10n("Quest Start NPC Information"))
        startNPCGroup:SetFullWidth(true)
        if QuestieOptionsControls and QuestieOptionsControls.ApplyModernInfoGroup then
            QuestieOptionsControls.ApplyModernInfoGroup(startNPCGroup)
        end
        ApplyNPCInfoLayout(startNPCGroup)
        container:AddChild(startNPCGroup)

        QuestieJourneyUtils:Spacer(startNPCGroup)

        local startNpc = QuestieDB:GetNPC(quest.Starts.NPC[1])

        local startNPCNameLabel = CreateLabel(startNpc.name, true)
        startNPCNameLabel:SetFontObject(GameFontHighlight)
        startNPCNameLabel:SetColor(255, 165, 0)
        startNPCGroup:AddChild(startNPCNameLabel)
        AddNPCPortrait(startNPCGroup, startNpc, 1, startNPCNameLabel)

        local startNPCIdLabel = QuestieGUI:Create("Label")
        startNPCIdLabel:SetText(l10n("NPC ID").. l10n(": ") .. startNpc.id)
        startNPCIdLabel:SetFullWidth(true)
        startNPCGroup:AddChild(startNPCIdLabel)

        local startNPCZoneLabel = QuestieGUI:Create("Label")
        local startindex = 0
        if (not startNpc.spawns) then
            return
        end
        for i in pairs(startNpc.spawns) do
            startindex = i
        end

        if startindex == 0 then
            return
        end

        local continent = QuestieJourneyUtils:GetZoneName(startindex)

        startNPCZoneLabel:SetText(l10n(continent))
        startNPCZoneLabel:SetFullWidth(true)
        startNPCGroup:AddChild(startNPCZoneLabel)

        local startx = startNpc.spawns[startindex][1][1]
        local starty = startNpc.spawns[startindex][1][2]
        if (startx ~= -1 or starty ~= -1) then
            local startNPCLocLabel = QuestieGUI:Create("Label")
            startNPCLocLabel:SetText("X" .. l10n(": ") .. string.format("%.2f",startx) .." || Y" .. l10n(": ") .. string.format("%.2f",starty))
            startNPCLocLabel:SetFullWidth(true)
            startNPCGroup:AddChild(startNPCLocLabel)
        end

        local tomTomButton = CreateTomTomButton(startNpc.name, startindex, startx, starty)
        if tomTomButton then
            QuestieJourneyUtils:Spacer(startNPCGroup)
            startNPCGroup:AddChild(tomTomButton)
        end

        -- Also Starts
        if startNpc.questStarts and #startNpc.questStarts >= 2 then
            QuestieJourneyUtils:Spacer(startNPCGroup)

            local alsoStartsLabel = QuestieGUI:Create("Label")
            alsoStartsLabel:SetText(l10n('This NPC Also Starts the following quests:'))
            alsoStartsLabel:SetColor(255, 165, 0)
            alsoStartsLabel:SetFontObject(GameFontHighlight)
            alsoStartsLabel:SetFullWidth(true)
            startNPCGroup:AddChild(alsoStartsLabel)

            QuestieJourneyUtils:Spacer(startNPCGroup)
            for _, v in pairs(startNpc.questStarts) do
                if v ~= quest.Id then
                    local startQuest = QuestieDB.GetQuest(v)
                    local label = QuestieJourneyUtils.GetInteractiveQuestLabel(startQuest)
                    startNPCGroup:AddChild(label)
                end
            end
        end

        -- The container may restore default content anchors while laying
        -- out children, so apply the portrait column after the group is built.
        ApplyNPCInfoLayout(startNPCGroup)
    end

    -- Get Quest Start GameObject
    if quest.Starts and quest.Starts.GameObject then
        local startObjectGroup = QuestieGUI:Create("InlineGroup")
        ResetNPCInfoLayout(startObjectGroup)
        startObjectGroup:SetLayout("List")
        startObjectGroup:SetTitle(l10n('Quest Start Object Information'))
        startObjectGroup:SetFullWidth(true)
        if QuestieOptionsControls and QuestieOptionsControls.ApplyModernInfoGroup then
            QuestieOptionsControls.ApplyModernInfoGroup(startObjectGroup)
        end
        container:AddChild(startObjectGroup)

        QuestieJourneyUtils:Spacer(startObjectGroup)

        for _, oid in pairs(quest.Starts.GameObject) do
            local startObj = QuestieDB:GetObject(oid)

            local startObjectNameLabel = QuestieGUI:Create("Label")
            startObjectNameLabel:SetText(startObj.name)
            startObjectNameLabel:SetFontObject(GameFontHighlight)
            startObjectNameLabel:SetColor(255, 165, 0)
            startObjectNameLabel:SetFullWidth(true)
            startObjectGroup:AddChild(startObjectNameLabel)

            local startObjectIdLabel = QuestieGUI:Create("Label")
            startObjectIdLabel:SetText(l10n("Object ID") .. l10n(": ") .. startObj.id)
            startObjectIdLabel:SetFullWidth(true)
            startObjectGroup:AddChild(startObjectIdLabel)

            local startObjectZoneLabel = QuestieGUI:Create("Label")
            local startindex = 0
            for i in pairs(startObj.spawns) do
                startindex = i
            end

            local continent = QuestieJourneyUtils:GetZoneName(startindex)

            startObjectZoneLabel:SetText(l10n(continent))
            startObjectZoneLabel:SetFullWidth(true)
            startObjectGroup:AddChild(startObjectZoneLabel)

            local startx = startObj.spawns[startindex][1][1]
            local starty = startObj.spawns[startindex][1][2]
            if (startx ~= -1 or starty ~= -1) then
                local startObjectLocLabel = QuestieGUI:Create("Label")
                startObjectLocLabel:SetText("X" .. l10n(": ") .. string.format("%.2f",startx) .." || Y" .. l10n(": ") .. string.format("%.2f",starty))
                startObjectLocLabel:SetFullWidth(true)
                startObjectGroup:AddChild(startObjectLocLabel)
            end

            local tomTomButton = CreateTomTomButton(startObj.name, startindex, startx, starty)
            if tomTomButton then
                QuestieJourneyUtils:Spacer(startObjectGroup)
                startObjectGroup:AddChild(tomTomButton)
            end

            -- Also Starts
            if startObj.questStarts and #startObj.questStarts >= 2 then
                QuestieJourneyUtils:Spacer(startObjectGroup)

                local alsoStartsLabel = QuestieGUI:Create("Label")
                alsoStartsLabel:SetText(l10n('This Object Also Starts the following quests:'))
                alsoStartsLabel:SetColor(255, 165, 0)
                alsoStartsLabel:SetFontObject(GameFontHighlight)
                alsoStartsLabel:SetFullWidth(true)
                startObjectGroup:AddChild(alsoStartsLabel)

                QuestieJourneyUtils:Spacer(startObjectGroup)
                for _, v in pairs(startObj.questStarts) do
                    if v ~= quest.Id then
                        local startQuest = QuestieDB.GetQuest(v)
                        local label = QuestieJourneyUtils.GetInteractiveQuestLabel(startQuest)
                        startObjectGroup:AddChild(label)
                    end
                end
            end
        end
    end

    -- Get Quest Start Item
    if quest.Starts and quest.Starts.Item then
        AddInfoPanelSpacing(container)
        local startItemGroup = QuestieGUI:Create("InlineGroup")
        ResetNPCInfoLayout(startItemGroup)
        startItemGroup:SetLayout("List")
        startItemGroup:SetTitle(l10n('Quest Start Item Information'))
        startItemGroup:SetFullWidth(true)
        if QuestieOptionsControls and QuestieOptionsControls.ApplyModernInfoGroup then
            QuestieOptionsControls.ApplyModernInfoGroup(startItemGroup)
        end
        container:AddChild(startItemGroup)

        QuestieJourneyUtils:Spacer(startItemGroup)

        local startItem = QuestieDB:GetItem(quest.Starts.Item[1])

        local startItemNameLabel = QuestieGUI:Create("Label")
        startItemNameLabel:SetText(startItem.name)
        startItemNameLabel:SetFontObject(GameFontHighlight)
        startItemNameLabel:SetColor(255, 165, 0)
        startItemNameLabel:SetFullWidth(true)
        startItemGroup:AddChild(startItemNameLabel)

        local startItemIdLabel = QuestieGUI:Create("Label")
        startItemIdLabel:SetText(l10n("Item ID") .. l10n(": ") .. startItem.Id)
        startItemIdLabel:SetFullWidth(true)
        startItemGroup:AddChild(startItemIdLabel)

        ApplyItemInfoLayout(startItemGroup)
        AddItemIcon(startItemGroup, startItem)
    end

    AddInfoPanelSpacing(container)

    if quest.Finisher.NPC then
        local endNPCGroup = QuestieGUI:Create("InlineGroup")
        ResetNPCInfoLayout(endNPCGroup)
        endNPCGroup:SetLayout("List")
        endNPCGroup:SetTitle(l10n('Quest Turn-in NPC Information'))
        endNPCGroup:SetFullWidth(true)
        if QuestieOptionsControls and QuestieOptionsControls.ApplyModernInfoGroup then
            QuestieOptionsControls.ApplyModernInfoGroup(endNPCGroup)
        end
        ApplyNPCInfoLayout(endNPCGroup)
        container:AddChild(endNPCGroup)

        QuestieJourneyUtils:Spacer(endNPCGroup)

        for i, npcId in ipairs(quest.Finisher.NPC) do
            if i > 1 then
                QuestieJourneyUtils:Spacer(endNPCGroup)
            end

            local endNPC = QuestieDB:GetNPC(npcId)

            local endNPCNameLabel = QuestieGUI:Create("Label")
            endNPCNameLabel:SetText(endNPC.name)
            endNPCNameLabel:SetFontObject(GameFontHighlight)
            endNPCNameLabel:SetColor(255, 165, 0)
            endNPCNameLabel:SetFullWidth(true)
            endNPCGroup:AddChild(endNPCNameLabel)
            AddNPCPortrait(endNPCGroup, endNPC, i, endNPCNameLabel)

            local endNPCIdLabel = QuestieGUI:Create("Label")
            endNPCIdLabel:SetText(l10n("NPC ID") .. l10n(": ") .. endNPC.id)
            endNPCIdLabel:SetFullWidth(true)
            endNPCGroup:AddChild(endNPCIdLabel)

            if endNPC.spawns then
                local endNPCZoneLabel = QuestieGUI:Create("Label")
                local endindex = 0
                for zone in pairs(endNPC.spawns) do
                    endindex = zone
                end

                local continent = QuestieJourneyUtils:GetZoneName(endindex)

                endNPCZoneLabel:SetText(l10n(continent))
                endNPCZoneLabel:SetFullWidth(true)
                endNPCGroup:AddChild(endNPCZoneLabel)

                if next(endNPC.spawns) then
                    local endx = endNPC.spawns[endindex][1][1]
                    local endy = endNPC.spawns[endindex][1][2]
                    if (endx ~= -1 or endy ~= -1) then
                        local endNPCLocLabel = QuestieGUI:Create("Label")
                        endNPCLocLabel:SetText("X" .. l10n(": ") .. string.format("%.2f",endx) .." || Y" .. l10n(": ") .. string.format("%.2f",endy))
                        endNPCLocLabel:SetFullWidth(true)
                        endNPCGroup:AddChild(endNPCLocLabel)
                    end

                    local tomTomButton = CreateTomTomButton(endNPC.name, endindex, endx, endy)
                    if tomTomButton then
                        QuestieJourneyUtils:Spacer(endNPCGroup)
                        endNPCGroup:AddChild(tomTomButton)
                    end
                end
            end

            -- Also ends
            if endNPC.questEnds and #endNPC.questEnds >= 2 then
                QuestieJourneyUtils:Spacer(endNPCGroup)

                local alsoEndsLabel = QuestieGUI:Create("Label")
                alsoEndsLabel:SetText(l10n('This NPC Also Completes the following quests:'))
                alsoEndsLabel:SetFontObject(GameFontHighlight)
                alsoEndsLabel:SetColor(255, 165, 0)
                alsoEndsLabel:SetFullWidth(true)
                endNPCGroup:AddChild(alsoEndsLabel)

                QuestieJourneyUtils:Spacer(endNPCGroup)
                for _, v in ipairs(endNPC.questEnds) do
                    if v ~= quest.Id then
                        local endQuest = QuestieDB.GetQuest(v)
                        local label = QuestieJourneyUtils.GetInteractiveQuestLabel(endQuest)
                        endNPCGroup:AddChild(label)
                    end
                end
            end
        end

        ApplyNPCInfoLayout(endNPCGroup)

        QuestieJourneyUtils:Spacer(endNPCGroup)

        -- Fix for sometimes the scroll content will max out and not show everything until window is resized
        container.content:SetHeight(10000)
    end

    if quest.Finisher.GameObject then
        local endObjectGroup = QuestieGUI:Create("InlineGroup")
        ResetNPCInfoLayout(endObjectGroup)
        endObjectGroup:SetLayout("List")
        endObjectGroup:SetTitle(l10n('Quest Turn-in Object Information'))
        endObjectGroup:SetFullWidth(true)
        if QuestieOptionsControls and QuestieOptionsControls.ApplyModernInfoGroup then
            QuestieOptionsControls.ApplyModernInfoGroup(endObjectGroup)
        end
        container:AddChild(endObjectGroup)

        QuestieJourneyUtils:Spacer(endObjectGroup)

        for i, objectId in ipairs(quest.Finisher.GameObject) do
            if i > 1 then
                QuestieJourneyUtils:Spacer(endObjectGroup)
            end

            local endObject = QuestieDB:GetObject(objectId)

            local endObjectNameLabel = QuestieGUI:Create("Label")
            endObjectNameLabel:SetText(endObject.name)
            endObjectNameLabel:SetFontObject(GameFontHighlight)
            endObjectNameLabel:SetColor(255, 165, 0)
            endObjectNameLabel:SetFullWidth(true)
            endObjectGroup:AddChild(endObjectNameLabel)

            local endObjectIdLabel = QuestieGUI:Create("Label")
            endObjectIdLabel:SetText(l10n("Object ID") .. l10n(": ") .. endObject.id)
            endObjectIdLabel:SetFullWidth(true)
            endObjectGroup:AddChild(endObjectIdLabel)

            if endObject.spawns then
                local endObjectZoneLabel = QuestieGUI:Create("Label")
                local endindex = 0
                for zone in pairs(endObject.spawns) do
                    endindex = zone
                end

                local continent = QuestieJourneyUtils:GetZoneName(endindex)

                endObjectZoneLabel:SetText(l10n(continent))
                endObjectZoneLabel:SetFullWidth(true)
                endObjectGroup:AddChild(endObjectZoneLabel)

                if next(endObject.spawns) then
                    local endx = endObject.spawns[endindex][1][1]
                    local endy = endObject.spawns[endindex][1][2]
                    if (endx ~= -1 or endy ~= -1) then
                        local endObjectLocLabel = QuestieGUI:Create("Label")
                        endObjectLocLabel:SetText("X" .. l10n(": ") .. string.format("%.2f",endx) .." || Y" .. l10n(": ") .. string.format("%.2f",endy))
                        endObjectLocLabel:SetFullWidth(true)
                        endObjectGroup:AddChild(endObjectLocLabel)
                    end

                    local tomTomButton = CreateTomTomButton(endObject.name, endindex, endx, endy)
                    if tomTomButton then
                        QuestieJourneyUtils:Spacer(endObjectGroup)
                        endObjectGroup:AddChild(tomTomButton)
                    end
                end
            end

            -- Also ends
            if endObject.questEnds and #endObject.questEnds >= 2 then
                QuestieJourneyUtils:Spacer(endObjectGroup)

                local alsoEndsLabel = QuestieGUI:Create("Label")
                alsoEndsLabel:SetText(l10n('This Object Also Completes the following quests:'))
                alsoEndsLabel:SetFontObject(GameFontHighlight)
                alsoEndsLabel:SetColor(255, 165, 0)
                alsoEndsLabel:SetFullWidth(true)
                endObjectGroup:AddChild(alsoEndsLabel)

                QuestieJourneyUtils:Spacer(endObjectGroup)
                for _, v in ipairs(endObject.questEnds) do
                    if v ~= quest.Id then
                        local endQuest = QuestieDB.GetQuest(v)
                        local label = QuestieJourneyUtils.GetInteractiveQuestLabel(endQuest)
                        endObjectGroup:AddChild(label)
                    end
                end
            end
        end

        QuestieJourneyUtils:Spacer(endObjectGroup)

        -- Fix for sometimes the scroll content will max out and not show everything until window is resized
        container.content:SetHeight(10000)
    end

    if Questie.db.profile.debugEnabled then
        QuestieJourneyUtils:Spacer(container)
        QuestieJourneyUtils:AddLine(container, recurseTable(quest, QuestieDB.questKeys))
    end
end

return QuestDetailsFrame
