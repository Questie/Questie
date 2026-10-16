-- luacheck: read globals QuestScrollFrame QuestLogQuests_Update SOUNDKIT IsShiftKeyDown C_Timer
---@class PolygonQuestLogForever
local PolygonQuestLogForever = QuestieLoader:CreateModule("PolygonQuestLogForever")

---@type QuestiePolygon
local QuestiePolygon = QuestieLoader:ImportModule("QuestiePolygon")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- Forever only: area boxes in Blizzard's mainline-style Map & Quest Log (QuestScrollFrame).
-- Only Questie_Camelot.toc loads this file. Other clients need their own quest log track;
-- every track reads and writes area visibility through QuestiePolygon alone.

local BOX_SIZE = 14 -- Matches Blizzard's tracking checkbox.
local BOX_GAP = 4 -- Space between the box and the row's dash.
local BOX_ATLAS = "QuestLog-icon-ticksquare"
-- A muted fill, like the map areas' translucent center, with rounded corners that follow
-- the box's inner shape. The texture is a white rounded square tinted per objective.
local FILL_INSET = 3
local FILL_TEXTURE = "Interface\\Addons\\Questie\\Icons\\quest-log-area-fill.png"
local FILL_ALPHA = 0.5
-- Blizzard's 20-unit quest marker on each title line, fitted into the box column.
local MARKER_SIZE = 16
local MARKER_RAISE = 4 -- Above the title text's top edge; the marker still clears the first box.
local MARKER_GLOW_SCALE = 0.75 -- The selected marker's 64-unit glow, relative to the fitted marker.

---Fractional UI scales stretch the 14-texel box art to non-whole pixel sizes. Snapped
---vertices then land unevenly, so one side of the border looks thicker. Unsnapped,
---filtered drawing keeps both edges and the fill symmetric.
---@param texture Texture
local function _DrawUnsnapped(texture)
    texture:SetSnapToPixelGrid(false)
    texture:SetTexelSnappingBias(0)
end

---@param box Button
local function _ShowTooltip(box)
    local shown = QuestiePolygon.GetObjectiveAreaState(box.questId, box.objectiveIndex)
    GameTooltip:SetOwner(box, "ANCHOR_RIGHT")
    GameTooltip:SetText(shown and l10n("Click to hide this objective's areas on the map.")
        or l10n("Click to show this objective's areas on the map."), 1, 1, 1, 1, true)
    GameTooltip:AddLine(l10n("Shift-click to apply this to the whole quest."), 0.7, 0.7, 0.7, true)
    GameTooltip:Show()
end

-- Hovering previews the objective on the map, like hovering its marker. The previewed identity is
-- captured because a quest log rebuild can reassign this pooled box meanwhile; the preview ends when
-- the cursor leaves or the box hides, whichever comes first.
local function _EndPreview(box)
    if box.previewQuestId then
        QuestiePolygon.SetObjectivePreview(box.previewQuestId, box.previewIndex, false)
        box.previewQuestId, box.previewIndex = nil, nil
    end
end

local function _OnEnter(box)
    _EndPreview(box)
    box.previewQuestId, box.previewIndex = box.questId, box.objectiveIndex
    QuestiePolygon.SetObjectivePreview(box.questId, box.objectiveIndex, true)
    _ShowTooltip(box)
end

local function _OnLeave(box)
    _EndPreview(box)
    if GameTooltip:IsOwned(box) then GameTooltip:Hide() end
end

-- Shift-click applies the clicked row's new state to every objective of the quest.
local function _OnClick(box)
    local shown = not QuestiePolygon.GetObjectiveAreaState(box.questId, box.objectiveIndex)
    if IsShiftKeyDown() then
        QuestiePolygon.SetQuestAreasShown(box.questId, shown)
    else
        QuestiePolygon.SetObjectiveAreaShown(box.questId, box.objectiveIndex, shown)
    end
    PlaySound(shown and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    PolygonQuestLogForever.Update()
    if GameTooltip:IsOwned(box) then _ShowTooltip(box) end
end

---Blizzard pools its objective rows, so each pooled row lazily gets one retained box.
---The box sits in the empty gutter left of the row: text only grows rightward and
---downward from there, so long or wrapped objectives cannot run into it.
---@param row Frame Blizzard objective row.
---@return Button
local function _GetBox(row)
    local box = row.QuestiePolygonAreaBox
    if box then return box end
    box = CreateFrame("Button", nil, row)
    box:SetSize(BOX_SIZE, BOX_SIZE)
    box:SetPoint("TOPRIGHT", row, "TOPLEFT", -BOX_GAP, 1)
    box.smartNavigationIgnored = true
    local border = box:CreateTexture(nil, "ARTWORK")
    border:SetAtlas(BOX_ATLAS)
    border:SetAllPoints()
    _DrawUnsnapped(border)
    local fill = box:CreateTexture(nil, "OVERLAY")
    fill:SetTexture(FILL_TEXTURE)
    fill:SetPoint("TOPLEFT", FILL_INSET, -FILL_INSET)
    fill:SetPoint("BOTTOMRIGHT", -FILL_INSET, FILL_INSET)
    _DrawUnsnapped(fill)
    box.Fill = fill
    box:SetScript("OnClick", _OnClick)
    box:SetScript("OnEnter", _OnEnter)
    box:SetScript("OnLeave", _OnLeave)
    box:SetScript("OnHide", _EndPreview)
    row.QuestiePolygonAreaBox = box
    return box
end

---@param box Button
---@param shown boolean
---@param color number[] Area RGB.
local function _ShowState(box, shown, color)
    box.Fill:SetVertexColor(color[1], color[2], color[3], FILL_ALPHA)
    box.Fill:SetShown(shown)
end

-- Blizzard pools the markers, so this outlives the titles they were fitted for.
---@type table<Button, true>
local fittedMarkers = {}

---Blizzard's quest marker on the title line shares the boxes' gutter and crowds the first
---objective's box. While areas are enabled it is shrunk and centred on the box column, with
---a smaller selection glow. Blizzard clears its anchors and sets only TOPLEFT on every
---rebuild, so replacing that point leaves no stale anchor. Blizzard resets the glow's scale
---whenever it restyles a marker; rebuilds and quest selection both refit it afterwards.
---@param title Button Title row; its marker exists only while Blizzard's quest POIs are on.
---@param enabled boolean
local function _FitQuestMarker(title, enabled)
    local marker = QuestScrollFrame.Contents:FindButtonByQuestID(title.questID)
    if not marker or marker:GetWidth() <= 0 then return end
    if enabled then
        local scale = MARKER_SIZE / marker:GetWidth()
        marker:SetScale(scale)
        -- Anchor offsets are in the marker's own scaled units.
        local left = -(BOX_GAP + (BOX_SIZE + MARKER_SIZE) / 2)
        marker:SetPoint("TOPLEFT", title.Text, "TOPLEFT", left / scale, MARKER_RAISE / scale)
        marker.Glow:SetScale(MARKER_GLOW_SCALE)
        fittedMarkers[marker] = true
    elseif fittedMarkers[marker] then
        fittedMarkers[marker] = nil
        marker:SetScale(1)
        marker.Glow:SetScale(1)
        marker:SetPoint("TOPLEFT", title, 6, -4) -- Blizzard's anchor in QuestLogQuests_AddQuestButton.
    end
end

---Blizzard creates rows only for unfinished leaderboard entries without storing their index,
---and pools enumerate in no fixed order, so each row is matched by its leaderboard text.
---@param title Button Title row of the same quest; it carries the quest log index.
---@param row Frame Objective row.
---@param claimed table<string, boolean> Indexes already matched this pass, keyed "questId:index".
---@return ObjectiveIndex?
local function _ObjectiveIndex(title, row, claimed)
    local text = row.Text:GetText()
    local questLogIndex = title.questLogIndex
    for index = 1, GetNumQuestLeaderBoards(questLogIndex) do
        local key = title.questID .. ":" .. index
        local leaderboardText, _, finished = GetQuestLogLeaderBoard(index, questLogIndex)
        if not finished and leaderboardText == text and not claimed[key] then
            claimed[key] = true
            return index
        end
    end
end

---Mirrors area state on every active objective row. Runs after Blizzard rebuilds the rows,
---after area visibility changes elsewhere, such as marker clicks, and after quest selection.
---Opening the log rebuilds the rows before the scroll frame is visible, and pooled rows keep
---their previous box, so this updates hidden rows too; no later rebuild is guaranteed.
---It only changes Questie's own boxes. Never call Blizzard's quest log updates from here:
---running them from addon code would taint the quest log.
function PolygonQuestLogForever.Update()
    local titles = {}
    local enabled = QuestiePolygon.IsEnabled()
    for title in QuestScrollFrame.titleFramePool:EnumerateActive() do
        titles[title.questID] = title
        _FitQuestMarker(title, enabled)
    end

    -- Completion text and money rows match no leaderboard entry and keep their box hidden,
    -- as do objectives without areas.
    local claimed = {}
    for row in QuestScrollFrame.objectiveFramePool:EnumerateActive() do
        local title = titles[row.questID]
        local index = title and _ObjectiveIndex(title, row, claimed)
        local shown, color
        if index then shown, color = QuestiePolygon.GetObjectiveAreaState(row.questID, index) end
        local box = _GetBox(row)
        if shown == nil then
            box:Hide()
        else
            box.questId, box.objectiveIndex = row.questID, index
            _ShowState(box, shown, color)
            box:Show()
        end
    end
end

hooksecurefunc("QuestLogQuests_Update", PolygonQuestLogForever.Update)
QuestiePolygon.RegisterVisibilityCallback(PolygonQuestLogForever.Update)

-- Selecting a quest restyles markers without a rebuild, resetting the fitted glow. Refit on
-- the next frame, after Blizzard's handlers. Do not hook marker methods instead: on Forever
-- 1.60.x such hooks failed inside the hook wrapper at login, aborting Blizzard's rebuild.
local selectionFrame = CreateFrame("Frame")
selectionFrame:RegisterEvent("SUPER_TRACKING_CHANGED")
selectionFrame:SetScript("OnEvent", function()
    C_Timer.After(0, PolygonQuestLogForever.Update)
end)
