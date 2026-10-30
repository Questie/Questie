-- Builds the header, title and objective lines of the tracker sections.
-- A section decides what to show, the builder decides how a line is sized and placed.
---@class LineBuilder
local LineBuilder = QuestieLoader:CreateModule("LineBuilder")

---@type TrackerLayout
local TrackerLayout = QuestieLoader:ImportModule("TrackerLayout")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")

---@class HeaderLineOptions
---@field key string The collapsedZones key, e.g. "Elwynn Forest", "Achievements" or "Recipes"
---@field text string The shown text, e.g. "Achievements: 3/10"
---@field collapsedText string? Defaults to text .. " +"

--- Zero out the minAllQuestsInZone table of a zone, when it holds no more quest ids.
---@param key string
local function _CleanUpMinAllQuestsInZone(key)
    local minAllQuests = Questie.db.char.minAllQuestsInZone[key]
    if minAllQuests == nil or minAllQuests.isTrue or Questie.db.char.collapsedZones[key] then
        return
    end

    for minQuestId, _ in pairs(minAllQuests) do
        if type(minQuestId) == "number" then
            return
        end
    end

    Questie.db.char.minAllQuestsInZone[key] = nil
end

---@alias LineClickMode "quest"|"achieve"|"recipe"

---@param line TrackerLineFrame
---@param clickMode LineClickMode
---@param target table The quest, achievement or recipe stored on the line
---@param objective table?
local function _SetTarget(line, clickMode, target, objective)
    line:SetOnClick(clickMode)
    if clickMode == "recipe" then
        line:SetRecipe(target)
    else
        line:SetQuest(target)
        line:SetObjective(objective)
    end
end

---@param options HeaderLineOptions
---@return TrackerLineFrame|nil line, boolean collapsed
function LineBuilder.AddHeader(options)
    local line = TrackerLinePool.GetNextLine()
    if (not line) then
        return nil, false
    end

    local margins = TrackerLayout.GetMargins()
    local collapsed = Questie.db.char.collapsedZones[options.key] and true or false

    line:SetMode("zone")
    line:SetZone(options.key)
    line.expandQuest:Hide()
    line.criteriaMark:Hide()
    line.playButton:Hide()

    line.label:ClearAllPoints()
    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)

    if collapsed then
        line.expandZone:SetMode(0)
        line.label:SetText("|cFFC0C0C0" .. (options.collapsedText or (options.text .. " +")) .. "|r")
    else
        line.expandZone:SetMode(1)
        line.label:SetText("|cFFC0C0C0" .. options.text .. "|r")
    end

    _CleanUpMinAllQuestsInZone(options.key)

    TrackerLayout.UpdateWidth(line.label:GetUnboundedStringWidth() + margins.left + margins.right)
    line.label:SetWidth(TrackerLayout.GetBaseFrameWidth() - margins.left - margins.right)
    line:SetWidth(line.label:GetWidth())
    TrackerLayout.TrackLineWidth(line.label:GetUnboundedStringWidth() + margins.left)

    line.expandZone:ClearAllPoints()
    line.expandZone:SetPoint("TOPLEFT", line.label, "TOPLEFT", 0, 0)
    line.expandZone:SetWidth(line.label:GetWidth())
    line.expandZone:SetHeight(line.label:GetHeight())
    line.expandZone:Show()

    -- Adds 4 pixels between the header and the first title
    line:SetHeight(line.label:GetHeight() + 4)
    line:Show()
    line.label:Show()
    line.Quest = nil
    line.Objective = nil
    line.Recipe = nil

    return line, collapsed
end

---@class TitleLineOptions
---@field text string The shown text, it is colored yellow
---@field clickMode LineClickMode
---@field target table The quest, achievement or recipe stored on the line
---@field collapseId number? Shows the expand button and uses collapsedQuests[collapseId]
---@field zoneKey string? The collapsedZones key of the header above, for the minAllQuestsInZone bookkeeping

---@param options TitleLineOptions
---@return TrackerLineFrame|nil line, boolean collapsed
function LineBuilder.AddTitle(options)
    local line = TrackerLinePool.GetNextLine()
    if (not line) then
        return nil, false
    end

    local margins = TrackerLayout.GetMargins()
    local collapseId = options.collapseId
    local collapsed = collapseId ~= nil and Questie.db.char.collapsedQuests[collapseId] and true or false

    -- Achievement titles must not be mistaken for quest titles by TrackerLinePool.UpdateQuestTitleLines
    line:SetMode(options.clickMode == "achieve" and "achieve" or "quest")
    _SetTarget(line, options.clickMode, options.target)
    line.expandZone:Hide()
    line.criteriaMark:Hide()
    line.playButton:Hide()

    line.label:ClearAllPoints()
    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", margins.quest, 0)

    if collapseId == nil then
        line.expandQuest:Hide()
    else
        line.expandQuest:Show()
        line.expandQuest:SetPoint("TOPRIGHT", line, "TOPLEFT", margins.quest - 8, 1)
        line.expandQuest.zoneId = options.zoneKey

        -- The minAllQuestsInZone table is always blank until a player Shift+Clicks the zone header (MouseDown).
        -- QuestieTracker:Update is triggered and the table is then filled with all ids in the same zone.
        local minAllQuests = options.zoneKey and Questie.db.char.minAllQuestsInZone[options.zoneKey]
        if minAllQuests and minAllQuests.isTrue then
            minAllQuests[collapseId] = true
        end

        line.expandQuest:SetMode(collapsed and 0 or 1)
    end

    line.label:SetText("|cFFFFFF00" .. options.text .. "|r")

    TrackerLayout.UpdateWidth(line.label:GetUnboundedStringWidth() + margins.quest + margins.right)
    line.label:SetWidth(TrackerLayout.GetBaseFrameWidth() - margins.quest - margins.right)
    line:SetWidth(line.label:GetWidth() + margins.quest)
    TrackerLayout.TrackLineWidth(line.label:GetUnboundedStringWidth() + margins.quest)

    -- Adds 4 pixels between the title and the first objective
    line:SetHeight(line.label:GetHeight() + 4)
    line:Show()
    line.label:Show()

    return line, collapsed
end

---@class ObjectiveLineOptions
---@field text string
---@field clickMode LineClickMode
---@field target table The quest, achievement or recipe stored on the line
---@field objective table? The quest objective, for combat text updates
---@field marginLeft number? Defaults to TrackerLayout.GetMargins().objective, quest item buttons add to it

---@param options ObjectiveLineOptions
---@return TrackerLineFrame|nil
function LineBuilder.AddObjective(options)
    local line = TrackerLinePool.GetNextLine()
    if (not line) then
        return nil
    end

    local marginLeft = options.marginLeft or TrackerLayout.GetMargins().objective

    line:SetMode("objective")
    _SetTarget(line, options.clickMode, options.target, options.objective)
    line.expandZone:Hide()
    line.expandQuest:Hide()
    line.criteriaMark:Hide()
    line.playButton:Hide()

    line.label:ClearAllPoints()
    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", marginLeft, 0)

    line.label:SetText(options.text)
    TrackerLayout.UpdateLineWidth(line, marginLeft)

    -- Adds 1 pixel between multiple objectives
    line:SetHeight(line.label:GetHeight() + 1)
    line:Show()
    line.label:Show()

    return line
end

--- Adds the "Padding Between Quests" setting of the tracker options below the last line of an entry.
---@param line TrackerLineFrame|nil The last line of the entry, nil when the line pool was exhausted
function LineBuilder.FinishEntry(line)
    line = line or TrackerLinePool.GetLastLine()

    -- Adds 2 pixels and the "Padding Between Quests" setting
    line:SetHeight(line.label:GetHeight() + (Questie.db.profile.trackerQuestPadding + 2))
end
