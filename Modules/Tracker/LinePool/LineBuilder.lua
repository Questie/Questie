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
