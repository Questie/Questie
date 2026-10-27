-- Shared layout state and helpers for drawing the tracker sections.
-- Imports no other tracker module. QuestieTracker hands in its frames and resize functions on Initialize.
---@class TrackerLayout
local TrackerLayout = QuestieLoader:CreateModule("TrackerLayout")

TrackerLayout.MARGIN_LEFT = 14
TrackerLayout.MARGIN_RIGHT = 30

---@class TrackerMargins
---@field left number
---@field right number
---@field quest number Left margin of quest/achievement/recipe titles
---@field objective number Left margin of objective lines
---@field itemButtonSize number

local baseFrame
local updateWidth, updateHeight
-- Width of the widest line drawn since the last reset
local lineWidth = 0

---@param trackerBaseFrame Frame
---@param updateWidthCallback fun(width: number) Resizes the tracker to the given content width
---@param updateHeightCallback fun() Resizes the tracker to its content height
function TrackerLayout.Initialize(trackerBaseFrame, updateWidthCallback, updateHeightCallback)
    baseFrame = trackerBaseFrame
    updateWidth = updateWidthCallback
    updateHeight = updateHeightCallback
end

---@return TrackerMargins
function TrackerLayout.GetMargins()
    local fontSizeQuest = Questie.db.profile.trackerFontSizeQuest
    local quest = (TrackerLayout.MARGIN_LEFT + TrackerLayout.MARGIN_RIGHT) - (18 - fontSizeQuest)
    return {
        left = TrackerLayout.MARGIN_LEFT,
        right = TrackerLayout.MARGIN_RIGHT,
        quest = quest,
        objective = quest + fontSizeQuest,
        itemButtonSize = 12 + fontSizeQuest,
    }
end

---@return Frame
function TrackerLayout.GetBaseFrame()
    return baseFrame
end

---@return number
function TrackerLayout.GetBaseFrameWidth()
    return baseFrame:GetWidth()
end

function TrackerLayout.ResetLineWidth()
    lineWidth = 0
end

---@return number
function TrackerLayout.GetLineWidth()
    return lineWidth
end

---@param width number
function TrackerLayout.TrackLineWidth(width)
    lineWidth = math.max(lineWidth, width)
end

---@param width number
function TrackerLayout.UpdateWidth(width)
    updateWidth(width)
end

function TrackerLayout.UpdateHeight()
    updateHeight()
end

--- Sizes an objective line and the tracker to its text, wrapping the text when it exceeds the max tracker width.
---@param line TrackerLineFrame
---@param marginLeft number
function TrackerLayout.UpdateLineWidth(line, marginLeft)
    local trackerMaxWidth = GetScreenWidth() * Questie.db.profile.trackerWidthRatio
    local margin = marginLeft + TrackerLayout.MARGIN_RIGHT
    local contentMaxWidth = trackerMaxWidth - margin

    local unboundedWidth = line.label:GetUnboundedStringWidth()
    if (unboundedWidth + margin) < contentMaxWidth then
        -- If the text width is less than the max tracker width, we update the base frame width to fit the text
        TrackerLayout.UpdateWidth(unboundedWidth + margin)
    else
        -- If the text width exceeds the max tracker width, we set the base frame width to the max and allow text to wrap
        TrackerLayout.UpdateWidth(trackerMaxWidth)
    end

    line.label:SetWidth(baseFrame:GetWidth() - margin)
    line:SetWidth(line.label:GetWidth() + marginLeft)

    -- If the line width is less than the minimum Tracker width then don't wrap text
    if unboundedWidth + marginLeft < contentMaxWidth then
        TrackerLayout.TrackLineWidth(unboundedWidth + marginLeft)
    else
        -- We use the fontSize as reliable way to determine the line height. GetStringHeight can be inconsistent.
        -- We add an extra pixel per line to account for WoW's internal line spacing on top of the raw font size.
        local _, fontSize = line.label:GetFont()
        local lineHeight = ((fontSize + 1) * line.label:GetNumLines()) + 1 -- add an extra pixel to make sure it really wraps
        line.label:SetHeight(lineHeight)
        line:SetHeight(line.label:GetHeight() + (Questie.db.profile.trackerQuestPadding + 2))

        TrackerLayout.TrackLineWidth(line.label:GetWrappedWidth() + marginLeft)
    end
end
