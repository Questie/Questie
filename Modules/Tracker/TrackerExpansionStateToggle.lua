---@class TrackerExpansionStateToggle
local TrackerExpansionStateToggle = QuestieLoader:CreateModule("TrackerExpansionStateToggle")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")

local btn

function TrackerExpansionStateToggle.Initialize()
    -- Create a secure button to execute TrackerExpansionStateToggle with ESC
    btn = CreateFrame("Button", "TESTButton", UIParent, "SecureActionButtonTemplate")
    btn:SetAttribute("type", "macro")
    btn:SetAttribute("macrotext", "/run G_TrackerExpansionStateToggle()")
end

-- Toggles the Questie tracker expansion state (called by the keybind)
function TrackerExpansionStateToggle.Toggle()
    if Questie.db.char.isTrackerExpanded then
        QuestieTracker:Collapse()
        ClearOverrideBindings(btn)  -- Remove the override when collapsed
    else
        QuestieTracker:Expand()
        if TrackerBaseFrame and Questie.db.char.isTrackerExpanded then
            SetOverrideBinding(btn, false, "ESCAPE", "CLICK TESTButton:LeftButton")  -- Set the override if initially expanded
        end
    end
end

-- Global function to toggle the tracker
function G_TrackerExpansionStateToggle()
    TrackerExpansionStateToggle:Toggle()
end
