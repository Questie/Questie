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

---@param npcId number
---@param zone AreaId
---@param x number Coordinates in percent (0..100).
---@param y number Coordinates in percent (0..100).
---@return QuestieGUIWidget|nil
local function CreateNPCMapLink(npcId, zone, x, y)
    if type(npcId) ~= "number" or type(zone) ~= "number"
        or type(x) ~= "number" or type(y) ~= "number"
        or x < 0 or x > 100 or y < 0 or y > 100 then
        return nil
    end

    local link = QuestieGUI:Create("InteractiveLabel")
    ApplyModernInfoLink(link)
    link:SetText("[" .. l10n("Click to show on map") .. "]")
    link:SetColor(0.25, 1, 0.25)
    link:SetFullWidth(true)
    link:SetUserData("id", npcId)
    link:SetUserData("type", "npc")
    link:SetCallback("OnClick", function()
        QuestieJourneyUtils.HideJourneyTooltip()
        TrackerUtils:ShowNPCOnMap(npcId, zone, x, y)
    end)
    link:SetCallback("OnEnter", QuestieJourneyUtils.ShowJourneyTooltip)
    link:SetCallback("OnLeave", QuestieJourneyUtils.HideJourneyTooltip)
    return link
end

---@param questId QuestId
---@return string|nil
local function GetReputationRewardString(questId)
    if not questId then
        return nil
    end

    local rewardOk, reputationRewards = pcall(QuestieReputation.GetReputationReward, questId)
    if not rewardOk then
        return nil
    end
    if not reputationRewards or not next(reputationRewards) then
        return nil
    end

    local stringOk, rewardString = pcall(QuestieReputation.GetReputationRewardString, reputationRewards)
    return stringOk and rewardString or nil
end

local function SafeQueryQuestSingle(questId, field)
    local ok, value = pcall(QuestieDB.QueryQuestSingle, questId, field)
    return ok and value or nil
end

local function SafeEffectiveQuestLevel(questId)
    local ok, level = pcall(QuestieLib.GetEffectiveQuestLevel, questId)
    if ok and tonumber(level) then
        return tonumber(level)
    end
    return tonumber(SafeQueryQuestSingle(questId, "questLevel")) or 0
end

local function SafeGetQuest(questId)
    if not questId then
        return nil
    end
    local ok, quest = pcall(QuestieDB.GetQuest, questId)
    return ok and quest or nil
end

local function SafeGetNPC(npcId)
    if not npcId then
        return nil
    end
    local ok, npc = pcall(QuestieDB.GetNPC, QuestieDB, npcId)
    return ok and npc or nil
end

local function SafeGetObject(objectId)
    if not objectId then
        return nil
    end
    local ok, object = pcall(QuestieDB.GetObject, QuestieDB, objectId)
    return ok and object or nil
end

local function SafeGetItem(itemId)
    if not itemId then
        return nil
    end
    local ok, item = pcall(QuestieDB.GetItem, QuestieDB, itemId)
    return ok and item or nil
end

---Return the first entity ID from either the normal QuestieDB list shape or a
---single ID supplied by a provider.
---@param ids number|table|nil
---@return number|nil
local function FirstEntityId(ids)
    if type(ids) == "number" then
        return ids
    end
    if type(ids) ~= "table" then
        return nil
    end
    if type(ids[1]) == "number" then
        return ids[1]
    end
    for key, value in pairs(ids) do
        if type(value) == "number" then
            return value
        elseif type(key) == "number" and value == true then
            return key
        end
    end
    return nil
end

---@param ids number|table|nil
---@return number[]
local function EntityIds(ids)
    if type(ids) == "number" then
        return {ids}
    end
    if type(ids) ~= "table" then
        return {}
    end

    local result = {}
    if type(ids[1]) == "number" then
        for _, id in ipairs(ids) do
            result[#result + 1] = id
        end
    else
        for key, value in pairs(ids) do
            if type(value) == "number" then
                result[#result + 1] = value
            elseif type(key) == "number" and value == true then
                result[#result + 1] = key
            end
        end
        table.sort(result)
    end
    return result
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

local function AddInfoPanelSpacing(container, height)
    local spacer = QuestieGUI:Create("SimpleGroup")
    spacer:SetFullWidth(true)
    spacer:SetHeight(height or 16)
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
    if group and group.frame and group.frame.GetHeight and group.SetHeight then
        group.minHeight = math.max(group.minHeight or 0, NPC_PORTRAIT_MIN_GROUP_HEIGHT)
        if group.frame:GetHeight() < group.minHeight then
            group:SetHeight(group.minHeight)
        end
    end
end

local RemoveNPCPortraitWaiter

local function ResetNPCInfoLayout(group)
    if not group or not group.content then
        return
    end

    group.npcPortraitLayoutActive = false
    group.itemIconLayoutActive = false
    group.minHeight = nil
    local portraits = group.npcPortraits or {}
    for _, portrait in pairs(portraits) do
        if portrait.npcID then
            RemoveNPCPortraitWaiter(portrait, portrait.npcID)
        end
        portrait:Hide()
        portrait.npcID = nil
    end
    -- Keep the cache table on the pooled group even when this is its first
    -- reset, so later acquisitions always reuse the same texture slots.
    group.npcPortraits = portraits

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
    if group.npcPortraitLayoutApplying then
        return
    end

    group.npcPortraitLayoutApplying = true
    group.npcPortraitLayoutActive = true

    -- Reapply the same first-level surface used by the quest-link panels.
    -- NPC panels can come from a recycled InlineGroup with its old backdrop.
    if QuestieOptionsControls and QuestieOptionsControls.ApplyJourneyInfoContainer then
        QuestieOptionsControls.ApplyJourneyInfoContainer(border)
    elseif QuestieOptionsControls and QuestieOptionsControls.ApplyModernContainer then
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
            if group.npcPortraitLayoutActive and not group.npcPortraitLayoutApplying then
                ApplyNPCInfoLayout(group)
            end
        end)
    end
    group.npcPortraitLayoutApplying = false
end

local function ApplyItemInfoLayout(group)
    local border = GetInlineGroupBorder(group)
    if not group or not group.content or not border then
        return
    end
    if group.itemIconLayoutApplying then
        return
    end

    group.itemIconLayoutApplying = true
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
            if group.itemIconLayoutActive and not group.itemIconLayoutApplying then
                ApplyItemInfoLayout(group)
            end
        end)
    end
    group.itemIconLayoutApplying = false
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
    local previousNPCID = portrait.npcID
    if previousNPCID and previousNPCID ~= npcID then
        RemoveNPCPortraitWaiter(portrait, previousNPCID)
    end
    portrait.npcID = npcID
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
        request.expired = true
        request.retryScheduled = false
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
        if group.BeginUpdate then
            group:BeginUpdate()
        end

        for _, rawId in pairs(lookup) do
            local id = tonumber(rawId)
            if id then
                id = math.abs(id)
                local ok, errorMessage = pcall(function()
                    local link = QuestieGUI:Create("InteractiveLabel")
                    ApplyModernInfoLink(link)
                    -- Labels are 200 pixels wide unless stretched, which wraps long quest names and rewards needlessly.
                    link:SetFullWidth(true)
                    local name = query(id, "name")
                    if not name and linkType ~= "quest" then
                        return
                    end
                    local text
                    if linkType == 'quest' then
                        text = QuestieLib:GetColoredQuestName(id, true, true)
                    elseif linkType == 'npc' then
                        local lvl = query(id, 'maxLevel') or 0
                        text = '['..lvl..'] '..name..' ('..id..')'
                    else
                        text = name.." ("..id..")"
                    end
                    if not text then
                        return
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
                end)
                if not ok then
                    Questie.Debug(Questie.DEBUG_DEVELOP, "[QuestDetailsFrame] Skipping bad relationship link:", id, errorMessage)
                end
            end
        end
        if group.EndUpdate then
            group:EndUpdate()
        end
    end
end

---Add a quest link only when the linked quest exists in the active database.
---Some Forever NPC/object relation lists can contain IDs from another data set;
---one stale relation must not abort the whole quest detail render.
---@param container table
---@param questId QuestId
local function AddInteractiveQuestLinkIfPresent(container, questId)
    local linkedQuest = SafeGetQuest(questId)
    if not linkedQuest then
        Questie.Debug(Questie.DEBUG_DEVELOP, "[QuestDetailsFrame] Skipping missing linked quest:", questId)
        return
    end

    local ok, linkOrError = pcall(QuestieJourneyUtils.GetInteractiveQuestLabel, linkedQuest)
    if not ok or not linkOrError then
        Questie.Debug(Questie.DEBUG_DEVELOP, "[QuestDetailsFrame] Skipping bad linked quest label:", questId, linkOrError)
        return
    end

    local added, addError = pcall(container.AddChild, container, linkOrError)
    if not added then
        Questie.Debug(Questie.DEBUG_DEVELOP, "[QuestDetailsFrame] Could not add linked quest label:", questId, addError)
    end
end

---@param container ScrollFrame
---@param quest Quest
local function DrawQuestDetails(container, quest)
    if not container or not quest then
        Questie.Debug(Questie.DEBUG_CRITICAL, "[QuestDetailsFrame:Draw] Missing quest data.")
        return
    end

    if container.BeginUpdate then
        container:BeginUpdate()
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

    local questLevel = SafeEffectiveQuestLevel(quest.Id)
    local levelLabel = CreateLabel(Questie:Colorize(l10n("Quest Level") .. l10n(": "), "yellow") .. questLevel, true)
    container:AddChild(levelLabel)

    -- We need to query this so we don't get wrong results for -1 type quests
    local requiredLevel = tonumber(SafeQueryQuestSingle(quest.Id, "requiredLevel")) or 0
    local questDbLevel = tonumber(SafeQueryQuestSingle(quest.Id, "questLevel")) or questLevel
    local minLevelLabel = CreateLabel(Questie:Colorize(l10n("Required Level") .. l10n(": "), 'yellow') .. requiredLevel, true)
    container:AddChild(minLevelLabel)

    -- Required Race / Faction
    local requiredRaces = SafeQueryQuestSingle(quest.Id, "requiredRaces")
    local raceOk, reqRaces = pcall(QuestieLib.GetRaceString, QuestieLib, requiredRaces)
    if not raceOk then
        reqRaces = ""
    end
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
    local requiredClasses = SafeQueryQuestSingle(quest.Id, "requiredClasses")
    local classOk, reqClasses = pcall(QuestieLib.GetClassString, QuestieLib, requiredClasses)
    if not classOk then
        reqClasses = ""
    end
    if (reqClasses ~= "") then
        local reqClassesLabel = CreateLabel(Questie:Colorize(l10n("Required Class") .. l10n(": "), 'yellow') .. reqClasses, true)
        container:AddChild(reqClassesLabel)
    end

    -- Required Profession
    local requiredSkill = SafeQueryQuestSingle(quest.Id, "requiredSkill")
    local requiredSpecialization = SafeQueryQuestSingle(quest.Id, "requiredSpecialization")
    local requiredRanks = SafeQueryQuestSingle(quest.Id, "requiredRanks")
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

    local breadcrumbForQuestId = SafeQueryQuestSingle(quest.Id, "breadcrumbForQuestId")
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

    local doableOk, eligibilityText, shouldShowDoableLabel = pcall(QuestieDB.IsDoableVerbose, quest.Id, false, true, true)
    if doableOk and shouldShowDoableLabel then
        local eligibilityTextLabel = CreateLabel(Questie:Colorize(l10n("Doable") .. l10n(": "), 'yellow') .. eligibilityText, true)
        container:AddChild(eligibilityTextLabel)
    end

    -- Pre Quests - two separate labeled sections
    if type(quest.preQuestSingle) == "table" and next(quest.preQuestSingle) then
        QuestieJourneyUtils:Spacer(container)
        AddLinkedParagraph(container, "quest", quest.preQuestSingle, l10n("Requires one of these quests to be finished"), QuestieDB.QueryQuestSingle)
    end

    if type(quest.preQuestGroup) == "table" and next(quest.preQuestGroup) then
        QuestieJourneyUtils:Spacer(container)
        AddLinkedParagraph(container, "quest", quest.preQuestGroup, l10n("Requires all of these quests to be finished"), QuestieDB.QueryQuestSingle)
    end

    local nextQuestInChain = tonumber(SafeQueryQuestSingle(quest.Id, "nextQuestInChain")) or 0
    if nextQuestInChain == 0 then nextQuestInChain = tonumber(SafeQueryQuestSingle(quest.Id, "breadcrumbForQuestId")) or 0 end
    if nextQuestInChain and nextQuestInChain > 0 and (not QuestieCorrections.hiddenQuests[nextQuestInChain]) then
        local nextQuestIDs = {}
        local visitedQuestIds = {}
        while nextQuestInChain > 0 and (not visitedQuestIds[nextQuestInChain]) and (not QuestieCorrections.hiddenQuests[nextQuestInChain]) do
            visitedQuestIds[nextQuestInChain] = true
            nextQuestIDs[#nextQuestIDs + 1] = nextQuestInChain
            local nextNextQuestId = tonumber(SafeQueryQuestSingle(nextQuestInChain, "nextQuestInChain")) or 0
            if nextNextQuestId == 0 then nextNextQuestId = tonumber(SafeQueryQuestSingle(nextQuestInChain, "breadcrumbForQuestId")) or 0 end
            if nextNextQuestId > 0 then
                nextQuestInChain = nextNextQuestId
            else
                break
            end
        end

        -- Match the section spacing used before the quest starter panel.
        AddInfoPanelSpacing(container)
        AddLinkedParagraph(container, "quest", nextQuestIDs, l10n("Next in chain"), QuestieDB.QueryQuestSingle)
    end

    -- Keep the turn-in panel close to the preceding quest content so the
    -- final panel remains comfortably inside the detail viewport.
    AddInfoPanelSpacing(container, 6)

    -- Get Quest Start NPC. Some database records reference an NPC that is not
    -- present in the active client data set; skip that panel instead of
    -- aborting the entire quest detail render.
    local startNpcId = quest.Starts and FirstEntityId(quest.Starts.NPC)
    local startNpc = SafeGetNPC(startNpcId)
    if startNpc then
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
        if startNPCGroup.BeginUpdate then
            startNPCGroup:BeginUpdate()
        end

        QuestieJourneyUtils:Spacer(startNPCGroup)

        local startNPCNameLabel = CreateLabel(startNpc.name, true)
        startNPCNameLabel:SetFontObject(GameFontHighlight)
        startNPCNameLabel:SetColor(255, 165, 0)
        startNPCGroup:AddChild(startNPCNameLabel)
        AddNPCPortrait(startNPCGroup, startNpc, 1, startNPCNameLabel)

        local startNPCIdLabel = QuestieGUI:Create("Label")
        startNPCIdLabel:SetText(l10n("NPC ID").. l10n(": ") .. startNpc.id)
        startNPCIdLabel:SetFullWidth(true)
        startNPCGroup:AddChild(startNPCIdLabel)

        local startindex = 0
        if startNpc.spawns then
            for i in pairs(startNpc.spawns) do
                startindex = i
            end

            if startindex > 0 then
                local startSpawn = startNpc.spawns[startindex]
                local startCoordinates = startSpawn and startSpawn[1]
                if startCoordinates then
                    local startx = startCoordinates[1] or -1
                    local starty = startCoordinates[2] or -1
                    local mapLink = CreateNPCMapLink(startNpc.id, startindex, startx, starty)
                    if mapLink then
                        startNPCGroup:AddChild(mapLink)
                    end
                end

                -- Also Starts
                if startNpc.questStarts and #startNpc.questStarts >= 2 then
                    -- Keep the related-quest list close to the NPC location.
                    AddInfoPanelSpacing(startNPCGroup, 6)

                    local alsoStartsLabel = QuestieGUI:Create("Label")
                    alsoStartsLabel:SetText(l10n('This NPC Also Starts the following quests:'))
                    alsoStartsLabel:SetColor(255, 165, 0)
                    alsoStartsLabel:SetFontObject(GameFontHighlight)
                    alsoStartsLabel:SetFullWidth(true)
                    startNPCGroup:AddChild(alsoStartsLabel)

                    for _, v in pairs(startNpc.questStarts) do
                        if v ~= quest.Id then
                            AddInteractiveQuestLinkIfPresent(startNPCGroup, v)
                        end
                    end
                end
            end
        end
        -- The container may restore default content anchors while laying
        -- out children, so apply the portrait column after the group is built.
        if startNPCGroup.EndUpdate then
            startNPCGroup:EndUpdate()
        end
        ApplyNPCInfoLayout(startNPCGroup)
    end

    -- Get Quest Start GameObject
    local startObjects = quest.Starts and EntityIds(quest.Starts.GameObject)
    if startObjects and #startObjects > 0 then
        local startObjectGroup = QuestieGUI:Create("InlineGroup")
        ResetNPCInfoLayout(startObjectGroup)
        startObjectGroup:SetLayout("List")
        startObjectGroup:SetTitle(l10n('Quest Start Object Information'))
        startObjectGroup:SetFullWidth(true)
        if QuestieOptionsControls and QuestieOptionsControls.ApplyModernInfoGroup then
            QuestieOptionsControls.ApplyModernInfoGroup(startObjectGroup)
        end
        container:AddChild(startObjectGroup)
        if startObjectGroup.BeginUpdate then
            startObjectGroup:BeginUpdate()
        end

        QuestieJourneyUtils:Spacer(startObjectGroup)

        for _, oid in ipairs(startObjects) do
            local startObj = SafeGetObject(oid)
            if startObj then
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

                if startObj.spawns and next(startObj.spawns) then
                    local startObjectZoneLabel = QuestieGUI:Create("Label")
                    local startindex = 0
                    for i in pairs(startObj.spawns) do
                        startindex = i
                    end

                    local continent = QuestieJourneyUtils:GetZoneName(startindex)

                    startObjectZoneLabel:SetText(l10n(continent))
                    startObjectZoneLabel:SetFullWidth(true)
                    startObjectGroup:AddChild(startObjectZoneLabel)

                    local startSpawn = startObj.spawns[startindex]
                    local startCoordinates = startSpawn and startSpawn[1]
                    if startCoordinates then
                        local startx = startCoordinates[1] or -1
                        local starty = startCoordinates[2] or -1
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
                    end
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
                            AddInteractiveQuestLinkIfPresent(startObjectGroup, v)
                        end
                    end
                end
            end
        end
        if startObjectGroup.EndUpdate then
            startObjectGroup:EndUpdate()
        end
    end

    -- Get Quest Start Item
    local startItemId = quest.Starts and FirstEntityId(quest.Starts.Item)
    local startItem = SafeGetItem(startItemId)
    if startItem then
        -- Item-start details follow the generic quest information directly;
        -- keep only a small visual separation instead of the full panel gap.
        AddInfoPanelSpacing(container, 6)
        local startItemGroup = QuestieGUI:Create("InlineGroup")
        ResetNPCInfoLayout(startItemGroup)
        startItemGroup:SetLayout("List")
        startItemGroup:SetTitle(l10n('Quest Start Item Information'))
        startItemGroup:SetFullWidth(true)
        if QuestieOptionsControls and QuestieOptionsControls.ApplyModernInfoGroup then
            QuestieOptionsControls.ApplyModernInfoGroup(startItemGroup)
        end
        container:AddChild(startItemGroup)
        if startItemGroup.BeginUpdate then
            startItemGroup:BeginUpdate()
        end

        QuestieJourneyUtils:Spacer(startItemGroup)

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
        if startItemGroup.EndUpdate then
            startItemGroup:EndUpdate()
        end
    end

    AddInfoPanelSpacing(container)

    local finisherNPCs = quest.Finisher and EntityIds(quest.Finisher.NPC)
    if finisherNPCs and #finisherNPCs > 0 then
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
        if endNPCGroup.BeginUpdate then
            endNPCGroup:BeginUpdate()
        end

        QuestieJourneyUtils:Spacer(endNPCGroup)

        for i, npcId in ipairs(finisherNPCs) do
            if i > 1 then
                QuestieJourneyUtils:Spacer(endNPCGroup)
            end

            local endNPC = SafeGetNPC(npcId)
            if endNPC then
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
                    local endindex = 0
                    for zone in pairs(endNPC.spawns) do
                        endindex = zone
                    end

                    if next(endNPC.spawns) then
                        local endSpawn = endNPC.spawns[endindex]
                        local endCoordinates = endSpawn and endSpawn[1]
                        if endCoordinates then
                            local endx = endCoordinates[1] or -1
                            local endy = endCoordinates[2] or -1
                            local mapLink = CreateNPCMapLink(endNPC.id, endindex, endx, endy)
                            if mapLink then
                                endNPCGroup:AddChild(mapLink)
                            end
                        end
                    end
                end

                -- Also ends
                if endNPC.questEnds and #endNPC.questEnds >= 2 then
                    -- Keep the related-quest list close to the NPC location.
                    AddInfoPanelSpacing(endNPCGroup, 6)

                    local alsoEndsLabel = QuestieGUI:Create("Label")
                    alsoEndsLabel:SetText(l10n('This NPC Also Completes the following quests:'))
                    alsoEndsLabel:SetFontObject(GameFontHighlight)
                    alsoEndsLabel:SetColor(255, 165, 0)
                    alsoEndsLabel:SetFullWidth(true)
                    endNPCGroup:AddChild(alsoEndsLabel)

                    for _, v in ipairs(endNPC.questEnds) do
                        if v ~= quest.Id then
                            AddInteractiveQuestLinkIfPresent(endNPCGroup, v)
                        end
                    end
                end
            end
        end

        if endNPCGroup.EndUpdate then
            endNPCGroup:EndUpdate()
        end
        ApplyNPCInfoLayout(endNPCGroup)

    end

    local finisherObjects = quest.Finisher and EntityIds(quest.Finisher.GameObject)
    if finisherObjects and #finisherObjects > 0 then
        local endObjectGroup = QuestieGUI:Create("InlineGroup")
        ResetNPCInfoLayout(endObjectGroup)
        endObjectGroup:SetLayout("List")
        endObjectGroup:SetTitle(l10n('Quest Turn-in Object Information'))
        endObjectGroup:SetFullWidth(true)
        if QuestieOptionsControls and QuestieOptionsControls.ApplyModernInfoGroup then
            QuestieOptionsControls.ApplyModernInfoGroup(endObjectGroup)
        end
        container:AddChild(endObjectGroup)
        if endObjectGroup.BeginUpdate then
            endObjectGroup:BeginUpdate()
        end

        QuestieJourneyUtils:Spacer(endObjectGroup)

        for i, objectId in ipairs(finisherObjects) do
            if i > 1 then
                QuestieJourneyUtils:Spacer(endObjectGroup)
            end

            local endObject = SafeGetObject(objectId)
            if endObject then
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
                        local endSpawn = endObject.spawns[endindex]
                        local endCoordinates = endSpawn and endSpawn[1]
                        if endCoordinates then
                            local endx = endCoordinates[1] or -1
                            local endy = endCoordinates[2] or -1
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

                    for _, v in ipairs(endObject.questEnds) do
                        if v ~= quest.Id then
                            AddInteractiveQuestLinkIfPresent(endObjectGroup, v)
                        end
                    end
                end
            end
        end

        if endObjectGroup.EndUpdate then
            endObjectGroup:EndUpdate()
        end
        QuestieJourneyUtils:Spacer(endObjectGroup)

    end

    -- Leave a small amount of parent-level breathing room after the final
    -- information panel. Padding inside the panel does not move its bottom
    -- edge away from the scroll viewport boundary.
    AddInfoPanelSpacing(container, 6)

    if Questie.db.profile.debugEnabled then
        QuestieJourneyUtils:Spacer(container)
        QuestieJourneyUtils:AddLine(container, recurseTable(quest, QuestieDB.questKeys))
    end

    if container.EndUpdate then
        container:EndUpdate()
    end
    -- Measure the real child stack. A fixed 10000px scroll child makes the
    -- final relation panel escape the visible detail pane when debug output is
    -- disabled.
    if container.RefreshLayout then
        container:RefreshLayout()
    end
end

---Draw quest details without allowing one malformed database relation to leave
---the custom Journey pane permanently suspended and blank.
---@param container ScrollFrame
---@param quest Quest
function QuestDetailsFrame:Draw(container, quest)
    if not container or not quest then
        Questie.Debug(Questie.DEBUG_CRITICAL, "[QuestDetailsFrame:Draw] Missing quest data.")
        return
    end

    local function ErrorHandler(message)
        if debugstack then
            return debugstack(2, 1, 0) .. "\n" .. tostring(message)
        end
        return tostring(message)
    end

    local ok, errorMessage = xpcall(function()
        DrawQuestDetails(container, quest)
    end, ErrorHandler)

    if ok then
        return
    end

    if Questie.Debug then
        Questie.Debug(Questie.DEBUG_CRITICAL, "[QuestDetailsFrame:Draw] Failed to render quest", quest.Id, errorMessage)
    end

    -- DrawQuestDetails begins one update batch on the detail scroll frame.
    -- Reset that native widget state before attempting the fallback label.
    if container.layoutSuspended then
        container.layoutSuspended = 0
    end
    if container.EndUpdate then
        pcall(container.EndUpdate, container)
    end

    -- Keep any widgets that were already rendered. Clearing them here made a
    -- single optional relation failure look like the entire quest had no
    -- details at all (only the fallback title remained). Add the fallback only
    -- when the failure happened before the first widget was created.
    local hasPartialDetails = container.children and #container.children > 0
    if not hasPartialDetails and container.AddChild then
        local fallback = QuestieGUI:Create("Label")
        fallback:SetText(quest.name or ("Quest " .. tostring(quest.Id)))
        fallback:SetFullWidth(true)
        container:AddChild(fallback)
    end
    if container.RefreshLayout then
        pcall(container.RefreshLayout, container)
    end
end

return QuestDetailsFrame
