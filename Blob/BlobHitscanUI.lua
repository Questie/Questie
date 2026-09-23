-- luacheck: globals GetQuestPOIBlobCount C_SuperTrack SLASH_QUESTIEBLOBHITSCAN1
local _, _, _, interfaceVersion = GetBuildInfo()
if interfaceVersion < 16000 or interfaceVersion >= 17000 then return end

---@class BlobHitscanUI
local UI = QuestieLoader:CreateModule("BlobHitscanUI")
---@type BlobHitscan
local BlobHitscan = QuestieLoader:ImportModule("BlobHitscan")
---@type BlobExtractor
local BlobExtractor = QuestieLoader:ImportModule("BlobExtractor")
local PreciseSecs = GetTimePreciseSec
local panel, viewport, overlay, blob, fields, statusText, hoverText, note
local squares, lines, modeButtons = {}, {}, {}
local modeCells = {grid = "200", outline = "512"}
UI.mode = "grid"
local jobMode, ringIndex, vertexIndex, resultBounds
local phase, phaseAt, phaseFrames, renderIndex, nextStatusAt
local currentQuest
local cancelledPhase
local _OnUpdate
local renderSeconds, maxRenderSlice = 0, 0
local colors = {{1, 0.65, 0.1}, {0.2, 1, 0.3}, {1, 0.3, 0.65}, {1, 1, 0.2}}

local function _HideOverlay()
    for _, square in ipairs(squares) do square:Hide() end
    for _, line in ipairs(lines) do line:Hide() end
end

---Cancels sampling and pending layout/render phases. Repeated cancellation is harmless.
function UI.Cancel()
    if phase then cancelledPhase = phase end
    if UI.job then UI.job:Cancel() end
    phase = nil
end

local function _SetView(centerX, centerY, width)
    blob:ClearAllPoints()
    blob:SetSize(width, width / 1.5)
    blob:SetPoint("TOPLEFT", viewport, "CENTER", -width * centerX, width / 1.5 * centerY)
end

local function _UpdateStatus()
    local job = UI.job
    if not job then return end
    local displayStatus = cancelledPhase and ("cancelled during " .. cancelledPhase .. " (plot incomplete)") or phase or job.status
    local progress
    if jobMode == "outline" then
        progress = string.format("Outline: %s / %s | %d queries | %d rings | %d vertices | %d segments drawn%s",
            displayStatus, job.phase, job.queries, #(job.contours or {}), job.vertices, (renderIndex or 1) - 1,
            job.reason and (" | " .. job.reason) or "")
    else
        progress = string.format("Grid: %s | %d / %d samples | %d hits | %d squares%s",
            displayStatus, job.samples, job.totalSamples, job.matchedSamples, (renderIndex or 1) - 1,
            job.truncatedHits and " | Hit storage capped at 20,000" or "")
    end
    statusText:SetText(string.format(
        "%s\nWork %.2f ms CPU / %.3f s wall | peak slice %.2f ms | plot %.2f ms (peak %.2f ms)",
        progress, job.activeSeconds * 1000, job.wallSeconds, job.maxSliceSeconds * 1000,
        renderSeconds * 1000, maxRenderSlice * 1000))
end

---Switching modes discards stale results; each mode retains its own resolution input.
---@param mode "grid"|"outline"
function UI.SetMode(mode)
    assert(mode == "grid" or mode == "outline", "Unknown blob mode")
    if mode == UI.mode then return end
    UI.Cancel()
    if fields then modeCells[UI.mode] = fields.cells:GetText() end
    UI.mode = mode
    if not panel then return end
    _HideOverlay()
    blob:DrawNone()
    UI.job, currentQuest = nil, nil
    fields.cells.caption:SetText(mode == "grid" and "Grid cells (10-500)" or "Boundary cells (64-4096)")
    fields.cells:SetText(modeCells[mode])
    modeButtons.grid:SetEnabled(mode ~= "grid")
    modeButtons.outline:SetEnabled(mode ~= "outline")
    note:SetText(mode == "grid"
        and "Blue: whole quest. Squares: selected native index. Full-map grid, then auto-fit."
        or "Blue: whole quest. Lines/vertices: extracted index. Discovery 32; crossing tolerance 1/32768.")
    statusText:SetText("Mode changed. Press Hitscan.")
end

---Begins the selected query algorithm; input/mode changes or closing cancel stale work.
function UI.Start()
    UI.Cancel()
    _HideOverlay()
    UI.job = nil
    cancelledPhase = nil
    renderIndex, renderSeconds, maxRenderSlice = 1, 0, 0
    ringIndex, vertexIndex, resultBounds = 1, 1, nil
    jobMode = UI.mode
    if InCombatLockdown() then
        statusText:SetText("Start outside combat. This prototype's native frame behavior is not validated in combat.")
        return
    end
    local questID = tonumber(fields.quest:GetText())
    local mapID = tonumber(fields.map:GetText())
    local objectiveText = fields.objective:GetText():match("^%s*(.-)%s*$")
    local objectiveIndex = objectiveText ~= "" and tonumber(objectiveText) or nil
    local cells = tonumber(fields.cells:GetText())
    if not questID or not (questID >= 1 and questID <= 2147483647) or questID % 1 ~= 0
        or not C_QuestLog.GetLogIndexForQuestID(questID) then
        statusText:SetText("Enter a quest ID from your current quest log.")
        return
    end
    if not mapID or not (mapID >= 1 and mapID <= 2147483647) or mapID % 1 ~= 0 or not C_Map.GetMapInfo(mapID) then
        statusText:SetText("Enter a valid UI map ID.")
        return
    end
    if (objectiveText ~= "" and (objectiveIndex == nil or not (objectiveIndex >= 0 and objectiveIndex <= 2147483647)
        or objectiveIndex % 1 ~= 0)) or not cells then
        statusText:SetText("Use a nonnegative integer native index (or blank for all) and numeric cells.")
        return
    end
    -- Native EditBoxes may deliver SetText notifications after Show/Start in the same UI turn.
    -- Record the values actually being scanned so those notifications cannot cancel this snapshot.
    for _, input in pairs(fields) do input.lastText = input:GetText() end
    local job, err
    if jobMode == "outline" then
        job, err = BlobExtractor.New(function(x, y)
            local id, count = blob:UpdateMouseOverTooltip(x, y)
            if id ~= questID then return false end
            if objectiveIndex == nil then return true end
            for i = 1, count or 0 do
                if blob:GetTooltipIndex(i) == objectiveIndex then return true end
            end
            return false
        end, {boundaryCells = cells})
    else
        job, err = BlobHitscan.New(blob, {questID = questID, objectiveIndex = objectiveIndex, cells = cells})
    end
    if not job then statusText:SetText(err); return end
    if GetQuestPOIBlobCount(questID) == 0 then
        statusText:SetText("No loaded blobs for this quest. This prototype cannot fetch arbitrary quest geometry.")
        return
    end
    UI.job = job
    currentQuest = questID
    blob:DrawNone()
    blob:SetMapID(mapID)
    _SetView(0.5, 0.5, 720)
    blob:Show()
    phase, phaseAt, phaseFrames = "layout", PreciseSecs(), 0
    panel:SetScript("OnUpdate", _OnUpdate)
    _UpdateStatus()
end

local function _BeginFit(bounds, now)
    local spanX = math.max(0.02, bounds.maxX - bounds.minX) * 1.3
    local spanY = math.max(0.02, bounds.maxY - bounds.minY) * 1.3
    local width = math.min(20000, 720 / spanX, 420 * 1.5 / spanY)
    _SetView((bounds.minX + bounds.maxX) / 2, (bounds.minY + bounds.maxY) / 2, width)
    ringIndex, vertexIndex = 1, 1
    phase, phaseAt, phaseFrames = "fit layout", now, 0
end

local function _Tick()
    local now = PreciseSecs()
    local job = UI.job
    if phase then
        if InCombatLockdown() then
            UI.Cancel()
            statusText:SetText("Cancelled on entering combat. Restart when out of combat.")
            return
        end
        phaseFrames = phaseFrames + 1
        -- Redraw after layout settles, then allow a render pass before hit-testing or plotting.
        if phase == "layout" and phaseFrames >= 2 and now - phaseAt >= 0.15 then
            blob:DrawNone()
            blob:DrawBlob(currentQuest, true)
            phase, phaseAt, phaseFrames = "settling", now, 0
        elseif phase == "settling" and phaseFrames >= 2 and now - phaseAt >= 0.15 then
            job.startedAt = now
            phase = "scanning"
        elseif phase == "scanning" then
            job:Step()
            if job.status == "complete" then
                local empty = jobMode == "outline" and #job.contours == 0 or jobMode == "grid" and not job.hitBounds
                if empty then
                    phase = nil
                    _UpdateStatus()
                    statusText:SetText(statusText:GetText() .. "\nNo geometry: check map/index, readiness, or sampling resolution.")
                    return
                end
                if jobMode == "outline" then
                    phase = "bounds"
                else
                    _BeginFit(job.hitBounds, now)
                end
            elseif job.status == "error" or job.status == "cancelled" then
                phase = nil
                _UpdateStatus()
                return
            end
        elseif phase == "bounds" then
            -- Auto-fit preparation is also batched; a large set of rings must not stall the UI.
            local start, count = PreciseSecs(), 0
            while ringIndex <= #job.contours and count < 128 and PreciseSecs() - start < 0.001 do
                local ring = job.contours[ringIndex]
                local point = ring[vertexIndex]
                if not resultBounds then
                    resultBounds = {minX = point[1], maxX = point[1], minY = point[2], maxY = point[2]}
                else
                    resultBounds.minX = math.min(resultBounds.minX, point[1])
                    resultBounds.maxX = math.max(resultBounds.maxX, point[1])
                    resultBounds.minY = math.min(resultBounds.minY, point[2])
                    resultBounds.maxY = math.max(resultBounds.maxY, point[2])
                end
                vertexIndex, count = vertexIndex + 1, count + 1
                if vertexIndex > #ring then ringIndex, vertexIndex = ringIndex + 1, 1 end
            end
            local elapsed = PreciseSecs() - start
            renderSeconds = renderSeconds + elapsed
            maxRenderSlice = math.max(maxRenderSlice, elapsed)
            if ringIndex > #job.contours then _BeginFit(resultBounds, now) end
        elseif phase == "fit layout" and phaseFrames >= 2 and now - phaseAt >= 0.15 then
            blob:DrawNone()
            blob:DrawBlob(currentQuest, true)
            phase, phaseAt, phaseFrames = "fit settling", now, 0
        elseif phase == "fit settling" and phaseFrames >= 2 and now - phaseAt >= 0.15 then
            phase = "plotting"
        elseif phase == "plotting" then
            local start = PreciseSecs()
            local count = 0
            local total = jobMode == "outline" and job.vertices or #job.hits
            local limit = math.min(total, 4096)
            while renderIndex <= limit and count < 128 and PreciseSecs() - start < 0.001 do
                local x, y, color
                if jobMode == "outline" then
                    local ring = job.contours[ringIndex]
                    local point, following = ring[vertexIndex], ring[vertexIndex % #ring + 1]
                    x, y = point[1], point[2]
                    color = colors[(ringIndex - 1) % #colors + 1]
                    local line = lines[renderIndex]
                    if not line then
                        line = overlay:CreateLine(nil, "OVERLAY")
                        line:SetThickness(2)
                        lines[renderIndex] = line
                    end
                    line:SetColorTexture(color[1], color[2], color[3], 0.95)
                    line:SetStartPoint("TOPLEFT", blob, x * blob:GetWidth(), -y * blob:GetHeight())
                    line:SetEndPoint("TOPLEFT", blob, following[1] * blob:GetWidth(), -following[2] * blob:GetHeight())
                    line:Show()
                    vertexIndex = vertexIndex + 1
                    if vertexIndex > #ring then ringIndex, vertexIndex = ringIndex + 1, 1 end
                else
                    local point = job.hits[renderIndex]
                    x, y = point.x, point.y
                    color = colors[((point.objectiveIndices[1] or 0) % #colors) + 1]
                end
                local square = squares[renderIndex]
                if not square then
                    square = overlay:CreateTexture(nil, "OVERLAY")
                    squares[renderIndex] = square
                end
                square:SetSize(jobMode == "outline" and 4 or 3, jobMode == "outline" and 4 or 3)
                square:SetColorTexture(color[1], color[2], color[3], 0.95)
                square:ClearAllPoints()
                square:SetPoint("CENTER", blob, "TOPLEFT", x * blob:GetWidth(), -y * blob:GetHeight())
                square:Show()
                renderIndex = renderIndex + 1
                count = count + 1
            end
            local elapsed = PreciseSecs() - start
            renderSeconds = renderSeconds + elapsed
            maxRenderSlice = math.max(maxRenderSlice, elapsed)
            if renderIndex > limit then
                phase = nil
                _UpdateStatus()
                if total > limit then
                    statusText:SetText(statusText:GetText() .. (jobMode == "outline"
                        and "\nPreview capped at 4,096 segments; full rings remain in the result."
                        or "\nDisplay capped at 4,096 squares; scan metrics include every sample."))
                end
            end
        end
    end

    -- Labels are throttled separately from scan work. Hit indices are never read across queries.
    if now >= (nextStatusAt or 0) then
        nextStatusAt = now + 0.1
        if phase then _UpdateStatus() end
        local id, count
        local indices = {}
        if currentQuest and not phase and viewport:IsMouseOver() then
            local x, y = GetCursorPosition()
            local scale = blob:GetEffectiveScale()
            id, count = blob:UpdateMouseOverTooltip((x / scale - blob:GetLeft()) / blob:GetWidth(),
                (blob:GetTop() - y / scale) / blob:GetHeight())
            for i = 1, count or 0 do indices[#indices + 1] = tostring(blob:GetTooltipIndex(i)) end
        end
        hoverText:SetText("Hover quest: " .. tostring(id) .. " | matched count: " .. tostring(count)
            .. " | native indices: " .. table.concat(indices, ", "))
    end
end

-- Show and a successful restart share the same error boundary.
_OnUpdate = function()
    local ok, err = pcall(_Tick)
    if not ok then
        UI.Cancel()
        panel:SetScript("OnUpdate", nil)
        statusText:SetText("Scan stopped: " .. tostring(err))
        geterrorhandler()(err)
    end
end

local function _CreateInput(parent, label, x, width)
    local caption = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    caption:SetPoint("TOPLEFT", x, -51)
    caption:SetText(label)
    local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    input.caption = caption
    input:SetAutoFocus(false)
    input:SetSize(width, 24)
    input:SetPoint("TOPLEFT", x, -69)
    input:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    input:SetScript("OnTextChanged", function(self)
        local text = self:GetText()
        if text == self.lastText then return end
        self.lastText = text
        UI.Cancel()
        _HideOverlay()
        blob:DrawNone()
        UI.job = nil
        currentQuest = nil
        statusText:SetText("Inputs changed. Press Hitscan.")
    end)
    return input
end

local function _CreateButton(parent, text, x, callback)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(95, 24)
    button:SetPoint("TOPLEFT", x, -69)
    button:SetText(text)
    button:SetScript("OnClick", callback)
    return button
end

---@param questID number|string? Optional loaded quest ID, also accepted by /blob.
function UI.Show(questID)
    local requestedQuest = tonumber(questID)
    if not panel then
        panel = CreateFrame("Frame", nil, UIParent)
        panel:Hide()
        panel:SetSize(760, 620)
        panel:SetPoint("CENTER")
        panel:SetFrameStrata("DIALOG")
        panel:EnableMouse(true)
        panel:SetMovable(true)
        panel:RegisterForDrag("LeftButton")
        panel:SetScript("OnDragStart", function()
            if phase then
                UI.Cancel()
                _HideOverlay()
                blob:DrawNone()
                currentQuest = nil
                statusText:SetText("Moved during scan. Press Hitscan after positioning the panel.")
            end
            panel:StartMoving()
        end)
        panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
        local background = panel:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints()
        background:SetColorTexture(0.025, 0.035, 0.05, 0.96)
        local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", 18, -15)
        title:SetText("Blob workbench")
        local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -3, -3)
        close:SetScript("OnClick", function() panel:Hide() end)
        viewport = CreateFrame("Frame", nil, panel)
        viewport:SetSize(720, 420)
        viewport:SetPoint("TOPLEFT", 20, -118)
        viewport:SetClipsChildren(true)
        blob = CreateFrame("QuestPOIFrame", nil, viewport)
        blob:SetFillTexture("Interface\\WorldMap\\UI-QuestBlob-Inside")
        blob:SetBorderTexture("Interface\\WorldMap\\UI-QuestBlob-Outside")
        blob:SetFillAlpha(100)
        blob:SetBorderAlpha(220)
        blob:SetBorderScalar(1)
        blob:EnableMouse(false)
        blob:Hide()
        -- Put the squares above the native blob's frame level, not merely above its texture layer.
        overlay = CreateFrame("Frame", nil, viewport)
        overlay:SetAllPoints(viewport)
        overlay:SetFrameLevel(blob:GetFrameLevel() + 1)
        overlay:EnableMouse(false)
        statusText = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        statusText:SetPoint("TOPLEFT", 20, -550)
        statusText:SetJustifyH("LEFT")
        statusText:SetWidth(720)
        statusText:SetText("Choose a loaded quest. Blank objective means all; native index 0 is valid.")
        hoverText = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hoverText:SetPoint("TOPLEFT", 20, -595)
        fields = {
            quest = _CreateInput(panel, "Quest ID", 25, 75),
            map = _CreateInput(panel, "UI map ID", 125, 75),
            objective = _CreateInput(panel, "Native index (blank = all)", 225, 140),
            cells = _CreateInput(panel, UI.mode == "grid" and "Grid cells (10-500)" or "Boundary cells (64-4096)", 395, 105),
        }
        _CreateButton(panel, "Hitscan", 525, UI.Start)
        _CreateButton(panel, "Cancel", 635, function() UI.Cancel(); _UpdateStatus() end)
        local nextQuest = _CreateButton(panel, "Next quest", 525, function()
            local quests = {}
            local selected = 0
            for i = 1, C_QuestLog.GetNumQuestLogEntries() do
                local info = C_QuestLog.GetInfo(i)
                if info and not info.isHeader then
                    quests[#quests + 1] = info.questID
                    if info.questID == tonumber(fields.quest:GetText()) then selected = #quests end
                end
            end
            if #quests > 0 then fields.quest:SetText(tostring(quests[selected % #quests + 1])) end
        end)
        nextQuest:ClearAllPoints()
        nextQuest:SetWidth(85)
        nextQuest:SetPoint("RIGHT", close, "LEFT", -5, 0)
        modeButtons.grid = _CreateButton(panel, "Grid hits", 280, function() UI.SetMode("grid") end)
        modeButtons.outline = _CreateButton(panel, "Outline", 385, function() UI.SetMode("outline") end)
        modeButtons.grid:ClearAllPoints()
        modeButtons.grid:SetPoint("TOPLEFT", 280, -12)
        modeButtons.outline:ClearAllPoints()
        modeButtons.outline:SetPoint("TOPLEFT", 385, -12)
        modeButtons.grid:SetEnabled(UI.mode ~= "grid")
        modeButtons.outline:SetEnabled(UI.mode ~= "outline")
        note = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        note:SetPoint("TOPLEFT", 20, -102)
        note:SetText(UI.mode == "grid"
            and "Blue: whole quest. Squares: selected native index. Full-map grid, then auto-fit."
            or "Blue: whole quest. Lines/vertices: extracted index. Discovery 32; crossing tolerance 1/32768.")
        panel:SetScript("OnHide", function()
            UI.Cancel()
            panel:StopMovingOrSizing()
            panel:SetScript("OnUpdate", nil)
            panel:UnregisterAllEvents()
            currentQuest = nil
            blob:DrawNone()
            blob:Hide()
            _HideOverlay()
            statusText:SetText("Preview closed. Press Hitscan to run the selected mode again.")
            hoverText:SetText("")
        end)
        panel:SetScript("OnEvent", function()
            if UI.job then
                UI.Cancel()
                _HideOverlay()
                blob:DrawNone()
                currentQuest = nil
                statusText:SetText("Quest/POI data changed. Results invalidated; press Hitscan to restart.")
            end
        end)
    end
    panel:RegisterEvent("QUEST_LOG_UPDATE")
    panel:RegisterEvent("QUEST_POI_UPDATE")
    panel:Show()
    panel:SetScript("OnUpdate", _OnUpdate)
    if fields.quest:GetText() == "" then
        local defaultQuest = C_SuperTrack.GetSuperTrackedQuestID()
        if not defaultQuest or defaultQuest == 0 then
            for i = 1, C_QuestLog.GetNumQuestLogEntries() do
                local info = C_QuestLog.GetInfo(i)
                if info and not info.isHeader then defaultQuest = info.questID; break end
            end
        end
        fields.quest:SetText(tostring(defaultQuest or ""))
        fields.map:SetText(tostring(C_Map.GetBestMapForUnit("player") or ""))
        fields.cells:SetText(modeCells[UI.mode])
    end
    if requestedQuest then fields.quest:SetText(tostring(requestedQuest)) end
end

SLASH_QUESTIEBLOBHITSCAN1 = "/blob"
SlashCmdList.QUESTIEBLOBHITSCAN = UI.Show
